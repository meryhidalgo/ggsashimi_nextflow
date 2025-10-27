
process processCSV {
    input:
        path plots_config
    
    output:
        path "*.tsv", emit: sashimi_inputs
        path "*.txt", emit: palette
    
    when:
        params.get_sashimis == true

    script:
    """
    # get all the unique elements in the first column
    plotIDs=\$(awk -F ";" 'NR>1 {print \$1}' ${plots_config} | sort | uniq)

    # for each unique element, get all the rows with that element in the first column, and plot their 2nd and 3rd columns
    for plotID in \$plotIDs
    do
        # get the second column for the first occurence of the plotID
        coord=\$(awk -F ";" -v plotID="\$plotID" 'NR>1 && \$1==plotID {print \$2; exit}' ${plots_config})
        safe_coord=\$(echo "\$coord" | sed 's/[:]/_/g')
        awk -F ";" -v plotID="\$plotID" 'BEGIN {OFS="\\t"} NR>1 && \$1==plotID {print \$3, \$3".bam", \$4}' ${plots_config} > \$safe_coord.tsv
        
        # generate palette.txt (colors in column 5)
        awk -F ";" -v plotID="\$plotID" 'NR>1 && \$1==plotID { if (!seen[\$4]++) print \$5}' ${plots_config} > \${safe_coord}_palette.txt
        
    done
    """
}

process sashimi {
    tag "Sashimi-plot"

    publishDir "${params.output_dir}/sashimis", mode: 'copy', pattern: "*.pdf"

    input:
        path bams
        path palette
        path configs
    
    output:
        path "*.pdf"

    when:
        params.get_sashimis == true
    
    script:
    
    """
    correct_coord=\$(echo ${configs.simpleName} | sed 's/\\(.*\\)_/\\1:/')
    
    /ggsashimi.py \\
        -b ${configs} \\
        -c \$correct_coord \\
        --palette ${palette} \\
        -o sashimi_${configs.simpleName}.pdf \\
        -M ${params.sashimi_min_cov} \\
        --alpha ${params.sashimi_alpha} \\
        --ann-height ${params.sashimi_annot_height} \\
        --width ${params.sashimi_width} \\
        ${params.sashimi_collapse_groups ? '-C 3 -O 3' : ''} \\
        ${params.sashimi_gtf_annotations ? "-g \"${params.ref_gtf}\"" : ''} \\
        ${params.sashimi_fix_scale ? '--fix-y-scale' : ''}  \\
        ${params.sashimi_shrink ? '--shrink' : ''}
        

    """

}
