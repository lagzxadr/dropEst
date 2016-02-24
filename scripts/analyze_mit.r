#!/usr/bin/env Rscript
library(preseqR)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
#args <- c("/home/victor/InDrop/data/work/MurineSample1_S2_L001.1_new.rds")
if (length(args) != 1) {
  stop("You should pass name of one rds file")
}

base_name <- basename(args[1])
prefix <- paste0(base_name, "_")
d <- readRDS(args[1])

get_mit_fraction <- function(ex_cells, nonex_cells) {
  mit_id = match("chrM", names(nonex_cells))
  full_mit_fractions <- c(); ex_mit_fractions <- c();
  mit_counts <- c(); all_counts <- c();
  
  for (name in rownames(ex_cells)) {
    ex_row <- ex_cells[name,]; nonex_row <- nonex_cells[name,]
    nonex_sum <- sum(nonex_row); ex_sum <- sum(ex_row); mit_count <- nonex_row[mit_id];
    if (is.na(mit_count)) {
      mit_count <- 0; nonex_sum <- 0;
    }
    
    full_mit_fractions <- c(full_mit_fractions, mit_count / (nonex_sum + ex_sum))
    ex_mit_fractions <- c(ex_mit_fractions, mit_count / ex_sum)
    mit_counts <- c(mit_counts, mit_count)
    all_counts <- c(all_counts, nonex_sum + ex_sum)
  }
  list("full" = full_mit_fractions, "exone" = ex_mit_fractions, "mit_counts" = mit_counts, "all_counts" = all_counts)
}

plot_mit_per_exonic <- function(ex_mit_fractions) {
  percent = c()
  x_ax = seq(0, 1.5, 0.02);
  for (i in x_ax) {
    percent = c(percent, length(ex_mit_fractions[ex_mit_fractions >= i]) / length(ex_mit_fractions))
  }
  plot(x_ax, percent, "l", main = base_name, xlab = "(Mitochondrial reads) / (exonic reads)", ylab = "Part of cells with >= x fraction")
}

plot_exclude_extrims <- function(fraction, mit_countss, all_countss) {
  indexes = sort(fraction, decreasing = TRUE, index.return = TRUE)
  
  sum_met = sum(mit_countss)
  sum_all = sum(all_countss)
  total_fraction = c(sum_met / sum_all)
  for (index in indexes$ix) {
    sum_met <- sum_met - mit_countss[index]
    sum_all <- sum_all - all_countss[index]
    total_fraction <- c(total_fraction, sum_met / sum_all)
  }
  
  plot(0:(length(total_fraction) - 1), total_fraction, "l", main = base_name, xlab = "Excludes count", ylab = "Total mitochondrial fraction")
}


plot_preseq <- function(reads_by_umig) {
  counts <- as.vector(table(reads_by_umig))
  freqs <- sort(unique(reads_by_umig))
  reads_count <- sum(reads_by_umig)
  
  predicted <- preseqR.pf.mincount(ss = round(reads_count / 3), n=cbind(freqs, counts))
  df <- as.data.frame(predicted$yield.estimates)
  ggplot() + geom_line(aes(x=df$sample.size, y=df$yield.estimates.r.1., colour = "Predicted")) + 
    geom_abline(slope = pi/4, col="red", lty = 2) + 
    geom_vline(aes(xintercept = reads_count, colour="Current"), show.legend = F) + 
    scale_colour_manual(values = c("Predicted"="blue", "biss" = "red", "Current" = "green")) + 
    xlab("Exonic reads count") + ylab("Unique UMIgs") + ggtitle(base_name) + xlim(1, reads_count * 10)
}


plot_all <- function() {
  fractions <- get_mit_fraction(d$ex_cells_chr_counts, d$nonex_cells_chr_counts)

  jpeg(paste0(prefix, "mit_frac.jpeg"))
  hist(as.numeric(fractions$full), breaks = 30, main = base_name, xlab = "Mitochondrial Fraction", ylab = "Cells Count")
  dev.off()
  jpeg(paste0(prefix, "mit_per_ex.jpeg"))
  plot_mit_per_exonic(fractions$exon)
  dev.off()
  jpeg(paste0(prefix, "exclude_extrims.jpeg"))
  plot_exclude_extrims(as.numeric(fractions$full), as.numeric(fractions$mit_counts), as.numeric(fractions$all_counts))
  dev.off()

  plot_preseq(d$reads_by_umig)
  ggsave(paste0(prefix, "preseq.jpeg"))
}

plot_all();
write(paste0(sum(d$reads_by_umig), ": ", length(d$reads_by_umig)), file=paste0(base_name, ".pred_out"))