#!/usr/bin/env Nextflow
nextflow.enable.dsl=2

include { processCSV; sashimi} from './modules/create_plots'

// ---- Input files ----
gtf = Channel.value(params.ref_gtf)
plots_csv = Channel.fromPath(params.plots_config)
input_bams = Channel.fromPath("$params.input_bam/*.bam*", checkIfExists: true)

// ---- Run the pipeline ----
workflow {

    // ---- Create plots ----
    input_bams | collect \
    | set { all_bams }
    
    processCSV(plots_csv)

    processCSV.out.sashimi_inputs.flatten()
        .set { bams_tsvs }

    processCSV.out.palette.flatten()
        .set { sashimi_palette }

    sashimi(all_bams, sashimi_palette, bams_tsvs)
}
