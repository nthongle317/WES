library(ComplexHeatmap)

InPath <- "/home/thong/Documents/project/WES/data"
OutPath <- "/home/thong/Documents/project/WES/fig"


dt <- read.table(paste0(InPath, "/summary_gene.mut.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

dt$Total <- apply(dt[,-1], 1, sum )

dt <- dt[order(dt$Total, decreasing=T),]

df <- dt[1:50,-c(1,8)]
rownames(df) <- dt[1:50,1]

pdf(paste0(OutPath, "/heatmap.pdf"), width=35, height=35)
Heatmap(df, cluster_columns = F, cluster_rows = F,
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