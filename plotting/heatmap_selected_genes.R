library(ComplexHeatmap)

InPath <- "/home/thong/Documents/project/WES/data"
OutPath <- "/home/thong/Documents/project/WES/fig"

lgene <- read.table(paste0(InPath, "/List_of_genes.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)
fgene <- read.table(paste0(InPath, "/summary_gene.mut.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

dt <- merge(lgene, fgene, by.x="Gene names", by.y="GeneID", all.x=T)

# remove description column
dt <- dt[,-2]
# NA == 0
dt[is.na(dt)] <- 0

write.table(dt, paste0(OutPath, "/summary_selectedGene.mut.csv"))

dt$Total <- apply(dt[,-1], 1, sum )

df <- dt[order(dt$Total, decreasing=T),-1]

rownames(df) <- dt[,1]

pdf(paste0(OutPath, "/heatmap_SelectedGene.pdf"), width=35, height=35)
Heatmap(df[,-7], cluster_columns = F, cluster_rows = F,
        row_names_side = "left", 
        column_names_side = "bottom",
        column_names_rot = 50,
        column_title_side = "bottom",
        row_names_gp = gpar(fontsize = 30),
        column_names_gp = gpar(fontsize = 30),
        width = unit(75, "cm"), height = unit(80, "cm"),
        heatmap_legend_param=list(legend_height = unit(10, "cm"), legend_width = unit(30, "cm"), labels_gp = gpar(fontsize = 30)),
        column_order = c("083T", "135T", "147T", "128T", "157T", "168T"),
        name = " ")
dev.off()