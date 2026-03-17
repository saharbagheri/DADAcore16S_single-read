#!/usr/bin/env Rscript
suppressMessages(library(dada2))

# Load the per-sample results
ddF=lapply(snakemake@input[["ddF"]], readRDS)



names(ddF)<-gsub("ddF_","",sub("\\.rds$", "",basename(snakemake@input[["ddF"]]), ignore.case = TRUE))



# Build the final sequence table from all samples
seqtab.all <- makeSequenceTable(ddF)

# Save the sequence table
saveRDS(seqtab.all, snakemake@output[["seqtab"]])

# Function to count the unique reads
getNreads <- function(x) sum(getUniques(x))


# Create a tracking matrix (rows for samples; columns for "denoised" and "merged")
track <- cbind(sapply(ddF, getNreads))
colnames(track) <- c("denoised")

# Write the tracking info to a file
write.table(track, snakemake@output[["nreads"]], sep="\t", quote=FALSE)
