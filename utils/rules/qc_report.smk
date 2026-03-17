rule qc_report:
    input:
        rules.combineReadCounts.output,
        rules.plotASVLength.output,
        rules.plotQualityProfileAfterdada2.output,
        rules.plotQualityProfileRaw.output,
        rules.plotQualityProfileAfterQC.output,
        rules.separate_vsearch_hits.output,
        rules.vsearchParse.output,
        rules.combining_annotations.output
    singularity:
        "apptainer/rmd-1.0.0.sif"
    params:
        path=config["path"],
        outdir=config["path"]+"/"+ config["output_dir"],
        fwd=config["forward_read_suffix"],
        primer_removal=config["primer_removal"],
        primer_investigation=config["primer_investigation"],
        Nread=config["path"]+"/"+config["output_dir"]+"/dada2/Nreads.tsv",
        quality=config["path"]+"/"+config["output_dir"]+"/figures/quality/",
        taxonomy=config["path"]+"/"+config["output_dir"]+"/taxonomy/dada2_tables/GTDB_RDP.tsv",
        seqtab=config["path"]+"/"+config["output_dir"]+"/dada2/seqtab_nochimeras.rds",
        source=config["path"]+"/utils/scripts/dada2/pos_ctrl_references.R",
        pos=config["Positive_samples"],
        ref=config["path"]+"/utils/databases/",
        length_distribution=config["path"]+"/"+config["output_dir"]+"/figures/length_distribution/",
        krona=config["path"]+"/"+config["output_dir"]+"/QC_html_report/"+"krona_Species_result"
    output:
        config["output_dir"]+"/QC_html_report/"+"qc_report.html",
    shell:
        """
        Rscript -e 'rmarkdown::render(input="{params.path}/utils/scripts/dada2/qc_report.Rmd",output_file="{params.path}/{output}", params= list(quality="{params.quality}", out_dir="{params.outdir}", fwd_suffix= "{params.fwd}", primer_removal= "{params.primer_removal}", primer_investigation= "{params.primer_investigation}", Nread ="{params.Nread}", seqtab="{params.seqtab}", taxonomy="{params.taxonomy}", pos="{params.pos}", ref="{params.ref}", source="{params.source}", krona="{params.krona}", length_dist="{params.length_distribution}"))'
        """

