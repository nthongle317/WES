library(ggplot2)
library(reshape2)

InPath <- "/home/thong/Documents/project/WES/data"
OutPath <- "/home/thong/Documents/project/WES/fig"

### SBSA
dt <- read.table(paste0(InPath, "/SBSA.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

df <- melt(dt)

p <- ggplot(df, aes(x=SBS, y=value, fill=variable)) + geom_bar(stat="identity", position=position_dodge()) + labs(title="Signature profiling (SBS)", x="Single base subtitution", y = "Cosmic prediction signature (%)") + theme_classic()

p + theme(text=element_text(size=25),
        axis.text=element_text(size=25),
        axis.text.x = element_text(angle=35, hjust=1),
        axis.title=element_text(size=25), 
        plot.title=element_text(size=25), 
        legend.text=element_text(size=25), 
        legend.title=element_text(size=25))

ggsave(paste0(OutPath, "/SBSA.pdf"))

### SBSB
dt <- read.table(paste0(InPath, "/SBSB.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

df <- melt(dt)

p <- ggplot(df, aes(x=SBS, y=value, fill=variable)) + geom_bar(stat="identity", position=position_dodge()) + labs(title="Signature profiling (SBS)", x="Single base subtitution", y = "Cosmic prediction signature (%)") + theme_classic()

p + theme(text=element_text(size=25),
        axis.text=element_text(size=25),
        axis.text.x = element_text(angle=35, hjust=1),
        axis.title=element_text(size=25), 
        plot.title=element_text(size=25), 
        legend.text=element_text(size=25), 
        legend.title=element_text(size=25))

ggsave(paste0(OutPath, "/SBSB.pdf"))

### DBSA
dt <- read.table(paste0(InPath, "/DBSA.csv"), header=T, sep=",", stringsAsFactors=F, check.names=F)

df <- melt(dt, id=c("DBS"))

df$DBS <- factor(df$DBS, levels=c("DBS7", "DBS9", "DBS10", "DBS11"))

p <- ggplot(df, aes(x=DBS, y=value, fill=variable)) + geom_bar(stat="identity", position=position_dodge()) + labs(title="Signature profiling (DBS)", x="Double base subtitution", y = "Cosmic prediction signature (%)") + theme_classic()

p + theme(text=element_text(size=25),
        axis.text=element_text(size=25),
        axis.text.x = element_text(angle=35, hjust=1),
        axis.title=element_text(size=25), 
        plot.title=element_text(size=25), 
        legend.text=element_text(size=25), 
        legend.title=element_text(size=25))

ggsave(paste0(OutPath, "/DBSA.pdf"))