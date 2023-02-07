library(ggplot2)
library(reshape2)


InPath <- "/home/thong/Documents/project/WES/data"
OutPath <- "/home/thong/Documents/project/WES/fig"


# before filtering
dt <- read.table(paste0(InPath, "/germline_mut_beforeFiltering.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

df <- melt(dt[-2,],id.vars="Type")

df$variable <- factor(df$variable, levels=c("083N", "083T", "135N", "135T", "147N", "147T", "128N", "128T", "157N", "157T", "168N", "168T"))

p <- ggplot(df, aes(fill=Type, y=value, x=variable)) + 
geom_bar(position="stack", stat="identity") +
ggtitle("Type of Variant (Before filtering)") +
xlab("Sample") + ylab("Count") + scale_fill_discrete(name = "Type", labels = c("Deletion", "Insertion", "Single Nucleotide Polymorphism"))
# Adjust font size
p + theme(text=element_text(size=25),
        axis.text=element_text(size=25),
        axis.text.x = element_text(angle=35, hjust=1),
        axis.title=element_text(size=25), 
        plot.title=element_text(size=25), 
        legend.text=element_text(size=25), 
        legend.title=element_text(size=25))
ggsave(paste0(OutPath, "/germline_typeOfvariant_beforeFiltering.pdf"), width=15, height=10)

# after filtering

dt <- read.table(paste0(InPath, "/germline_mut_afterFiltering.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

df <- melt(dt[-2,],id.vars="Type")

df$variable <- factor(df$variable, levels=c("083N", "083T", "135N", "135T", "147N", "147T", "128N", "128T", "157N", "157T", "168N", "168T"))

p <- ggplot(df, aes(fill=Type, y=value, x=variable)) + 
geom_bar(position="stack", stat="identity") +
ggtitle("Type of Variant (After filtering)") +
xlab("Sample") + ylab("Count") + scale_fill_discrete(name = "Type", labels = c("Deletion", "Insertion", "Single Nucleotide Polymorphism"))
# Adjust font size
p + theme(text=element_text(size=25),
        axis.text=element_text(size=25),
        axis.text.x = element_text(angle=35, hjust=1),
        axis.title=element_text(size=25), 
        plot.title=element_text(size=25), 
        legend.text=element_text(size=25), 
        legend.title=element_text(size=25))
ggsave(paste0(OutPath, "/germline_typeOfvariant_afterFiltering.pdf"), width=15, height=10)