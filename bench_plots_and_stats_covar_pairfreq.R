#!/usr/bin/env Rscript

# script that makes an aggregate list of mean precision values for all DeepCov architectures
# This list can then be used for plotting.
# UPDATE 22/01/2018 to include min and max sequence separation as parameters

argv <- commandArgs(trailingOnly = T)
argc <- length(argv)

if (argc != 5){
    stop("Usage: Rscript bench_plots_and_stats_covar_pairfreq.R input_type min_seq_separation max_seq_separation beanplot_script_dir dir_with_all_results", call. = F)    
}

ip_type <- argv[1]
topomin <- argv[2]
topomax <- argv[3]
bp_script_dir <- argv[4]
derp <- argv[5]

source(file.path(bp_script_dir, 'KeyBeanplotFunctions.R'))

wd <- getwd()

# this file is generated by running the benchmark and postprocessing scripts.
d <-
    read.table(
        paste0(wd, "/aggregate_results_min", topomin, "_max", topomax, ".txt"),
        header = T,
        stringsAsFactors = F
    )

cols_to_plot <- 3:7
col_names <- c('L', 'L/2', 'L/5', 'L/10', 'L = 100')

stopifnot(length(cols_to_plot) == length(col_names))

pdf(file = file.path(wd, paste0("precision_beanplots_", ip_type,"_min", topomin, "_max", topomax, ".pdf")),
    height = 7,
    width = 7)

# RStudio graphics device sets oma = rep(0,4) by default
par(mar = c(5, 4, 1, 1), oma = rep(1, 4))

#beanplot parameters
bw <- 0.05
beanlinelength <- 0.7 # default is 1

bp <- beanplot(
    d[cols_to_plot],
    col = 'dodger blue',
    border = NA,
    beanlines = 'quantiles',
    what = c(0, 1, 1, 0),
    xlab = 'Number of contacts',
    ylab = 'Precision',
    ylim = c(0, 1),
    cut = 0,
    names = col_names,
    bw = bw,
    beanline.length = beanlinelength,
    log = ''
)

abline(h = seq(0, 1, 0.5), lty = 2)

mtext(
    text = paste0('n = ', nrow(d), ', Bandwidth = ', bp$bw),
    side = 1,
    adj = 1,
    outer = T
)

#dev.copy2pdf(
#    file = file.path(wd, 'precision_beanplots.pdf'),
#    height = 7,
#    width = 7
#)
dummy <- dev.off()

# writeLines("Mean precision values:")
res <- apply(d[cols_to_plot], 2, mean)
names(res) <- NULL
mean_output_file <- file.path(derp, paste0("all_windowsize_results_MEAN_",ip_type,"_min", topomin, "_max", topomax, ".txt"))
write(x = res, file = mean_output_file, append = T)

writeLines(paste("Results in", mean_output_file))

# writeLines("Median precision values:")
# res <- apply(d[cols_to_plot], 2, median)
# names(res) <- NULL
# median_output_file <- file.path(derp, paste0("all_windowsize_results_MEDIAN_",ip_type,"_min", topomin, "_max", topomax, ".txt"))
# write(x = res, file = median_output_file, append = T)
