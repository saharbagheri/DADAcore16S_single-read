rule filterNsRaw:
    input:
        R1= config["input_dir"]+"/{sample}" + config["forward_read_suffix"] + config["compression_suffix"]
    params:
        dir=config["output_dir"]+"/filtN/"
    output:
        R1=config["output_dir"]+"/filtN/{sample}" + config["forward_read_suffix"] + config["compression_suffix"]
    singularity:
        "apptainer/dada2-1.0.0.sif"
    script:
        "../scripts/dada2/filtN.R"

