suppressMessages(library(dada2))

Dir <- snakemake@params[["dir"]]

if (!dir.exists(Dir)) {
  dir.create(Dir)
}

####Checking presence of primers before removing the primers

fnFs <- snakemake@input[['R1']]

fnFs.filtN <- snakemake@output[['R1']] # Put N-filtered files in filtN/ subdirectory

out<-filterAndTrim(fnFs, fnFs.filtN, maxN = 0, multithread = TRUE)

