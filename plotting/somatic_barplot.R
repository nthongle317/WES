library(ggplot2)
library(reshape2)


InPath <- "/home/thong/Documents/project/WES/data"
OutPath <- "/home/thong/Documents/project/WES/fig"


dt <- read.table(paste0(InPath, "/somatic_count.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

dt$color <- ifelse(dt$Group=="WT", "red", "lightblue")
dt$Sample <- factor(dt$Sample, levels=c("083T", "135T", "147T", "128T", "157T", "168T"))

p <- ggplot(dt, aes(x=Sample, y=Count, fill=Group)) + geom_bar(stat="identity") + labs(title="Number of somatic mutation per sample", x="Sample", y = "Count") + theme_classic()

p + theme(text=element_text(size=25),
        axis.text=element_text(size=25),
        axis.text.x = element_text(angle=35, hjust=1),
        axis.title=element_text(size=25), 
        plot.title=element_text(size=25), 
        legend.text=element_text(size=25), 
        legend.title=element_text(size=25))

ggsave(paste0(OutPath, "/somatic_count.pdf"))

### before/after filtering

InPath <- "/home/thong/Documents/project/WES/data"
OutPath <- "/home/thong/Documents/project/WES/fig"


dt <- read.table(paste0(InPath, "/somatic_count.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

dt <- dt[,c("Sample", "High.confident", "Low.confident", "Group")]

df <- melt(dt)

df$Sample <- factor(df$Sample, levels=c("083T", "135T", "147T", "128T", "157T", "168T"))

p <- ggplot(df, aes(fill=variable, y=value, x=Sample)) + 
geom_bar(position="fill", stat="identity") +
ggtitle("Before/After applying hard-filtering") +
xlab("Sample") + ylab("Density (0-1)") + scale_fill_discrete(name = "Hard-filter", labels = c("High confident", "Low confident"))
# Adjust font size
p + theme(text=element_text(size=25),
        axis.text=element_text(size=25),
        axis.text.x = element_text(angle=35, hjust=1),
        axis.title=element_text(size=25), 
        plot.title=element_text(size=25), 
        legend.text=element_text(size=25), 
        legend.title=element_text(size=25))
ggsave(paste0(OutPath, "/somatic_hardFilter.pdf"), width=15, height=10)

