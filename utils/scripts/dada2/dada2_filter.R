suppressMessages(library(dada2))


fnFs <- snakemake@input[['R1']]

filtFs <- snakemake@output[['R1']]


track.filt <- filterAndTrim(fnFs,filtFs, 
#                            truncLen= snakemake@config[["truncLen"]],
                            maxN=0,
                            maxEE=snakemake@config[["maxEE"]], 
                            truncQ=snakemake@config[["truncQ"]],
                            compress=TRUE,
                            verbose=TRUE,
                            multithread=snakemake@threads,
                            rm.phix=TRUE)

row.names(track.filt) <- snakemake@params[["samples"]]

colnames(track.filt) = c('afterCutadapt','filtered')

track.filt<-data.frame(track.filt)
track.filt <- track.filt[track.filt$filtered > 0, ]

write.table(track.filt,snakemake@output[['nread']],  sep='\t')

