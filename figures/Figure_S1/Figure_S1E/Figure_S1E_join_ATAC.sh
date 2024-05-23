#split -b 40M ./ATAC_seq_2cell_DMSO_merged_rep1_rep2_from_Gassler_et_al_Science_2022.bedgraph ./ATAC_segments/ATAC_segment

# Please assemble the complete file before starting the analysis
cat ./ATAC_segments/ATAC_segment* > ./ATAC_seq_2cell_DMSO_merged_rep1_rep2_from_Gassler_et_al_Science_2022.bedgraph
