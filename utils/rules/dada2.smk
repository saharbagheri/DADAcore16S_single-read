rule plotQualityProfileRaw:
    input:
        R1= expand(config["input_dir"]+"/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],sample=SAMPLES)
    output:
        R1=config["output_dir"]+"/figures/quality/rawFilterQualityPlots"+ config["forward_read_suffix"]+".png"
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/plotQualityProfile.R"



rule plotQualityProfileAfterQC:
    input:
        R1= expand(config["output_dir"]+"/cutadapt_qc/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],sample=SAMPLES) 
    output:
        R1=config["output_dir"]+"/figures/quality/afterQCQualityPlots"+ config["forward_read_suffix"]+".png"
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/plotQualityProfile.R"



rule dada2Filter:
    input:
        R1= expand(config["output_dir"]+"/cutadapt_qc/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],sample=SAMPLES)
    output:
        R1= expand(config["output_dir"]+"/dada2/dada2_filter/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],sample=SAMPLES),
        nreads= temp(config["output_dir"]+"/dada2/Nreads_filtered.txt")
    params:
        samples=SAMPLES
    threads:
         config["threads"]
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/dada2_filter.R"



rule plotQualityProfileAfterdada2:
    input:
        R1= rules.dada2Filter.output.R1
    output:
        R1=config["output_dir"]+"/figures/quality/afterdada2FilterQualityPlots"+ config["forward_read_suffix"]+".png"
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/plotQualityProfile.R"



rule learnErrorRates:
    input:
        R1= rules.dada2Filter.output.R1
    output:
        errR1= config["output_dir"]+"/dada2/learnErrorRates/ErrorRates" + config["forward_read_suffix"]+ ".rds",
        plotErr1=config["output_dir"]+"/figures/errorRates/ErrorRates" + config["forward_read_suffix"]+ ".pdf"
    threads:
        config['threads']
    singularity:
        "apptainer/dada2-1.0.0.sif"
    params:
        neg=config["Negative_samples"]
    script:
        "../scripts/dada2/learnErrorRates.R"



rule process_sample:
    input:
        R1= config["output_dir"]+"/dada2/dada2_filter/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],
        errR1= rules.learnErrorRates.output.errR1
    output:
        ddF = config["output_dir"]+"/dada2/intermediate_files/ddF_{sample}.rds",
        derepF = config["output_dir"] + "/dada2/intermediate_files/derepF_{sample}.rds"
    threads:
        config["generateSeqtab_threads"]
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/process_sample.R"


rule merge_seqtabs:
    input:
        # This expands to a list of per-sample RDS files using the SAMPLES list.
        ddF = expand(config["output_dir"]+"/dada2/intermediate_files/ddF_{sample}.rds",sample=SAMPLES),
        derepF = expand(config["output_dir"] + "/dada2/intermediate_files/derepF_{sample}.rds",sample=SAMPLES)
    output:
        seqtab = config["output_dir"] + "/dada2/seqtab_with_chimeras.rds",
        nreads = config["output_dir"] + "/dada2/Nreads_with_chimeras.txt"
    singularity:
        "apptainer/dada2-1.0.0.sif"
    params:
        sample=SAMPLES
    script:
        "../scripts/dada2/merge_seqtabs.R"



rule removeChimeras:
    input:
        seqtab= rules.merge_seqtabs.output.seqtab
    output:
        rds= config["output_dir"]+"/dada2/seqtab_nochimeras.rds",
        csv= config["output_dir"]+"/dada2/seqtab_nochimeras.csv",
        nreads=temp(config["output_dir"]+"/dada2/Nreads_nochimera.txt")
    threads:
        config['threads']
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/removeChimeras.R"



##plots the distribution of ASV length count and abundance based on length
rule plotASVLength:
    input:
        seqtab= rules.removeChimeras.output.rds
    output:
        plot_seqlength= config["output_dir"]+"/figures/length_distribution/Sequence_Length_distribution.png"
    threads:
        config["threads"]
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/asv_length_distribution_plotting.R"



rule RDPtaxa:
    input:
        seqtab=rules.removeChimeras.output.rds,
        ref= lambda wc: config['RDP_dbs'][wc.ref],
        species= lambda wc: config['RDP_species'][wc.ref]
    output:
        taxonomy= config["output_dir"]+"/taxonomy/dada2_tables/{ref}_RDP.tsv",
        rds_bootstrap=config["output_dir"]+"/taxonomy/dada2_tables/{ref}_RDP_boostrap.rds"
    threads:
        config['taxonomy_threads']
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/RDPtaxa.R"
