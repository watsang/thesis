
# OBJECTIVE
# ==============
#
# 1)  Calculate S^T and S for organisms
# 
# 2)  Perform PCA on both S and S^T
#
# 3) visualise eigenvectors
#
#

# ===========================================================

setwd("D:/univ/2014-2015/thesis/KERMIT/bacterial similarity/data mining/analysis 10 bacteria")

#setwd("~/univ/2014-2015/thesis/KERMIT/bacterial similarity/data mining/analysis 10 bacteria")
df_rhizobium <- read.csv("data 10 bacteria/394.7.txt")
df_agro <- read.csv("data 10 bacteria/176299.3.txt")
df_burkho <- read.csv("data 10 bacteria/269483.3.txt")
df_para <- read.csv("data 10 bacteria/318586.5.txt")
df_bacillus <- read.csv("data 10 bacteria/388400.4.txt")

# Change Lipid A disaccharide to Lipid A2
ModelSEED.compounds.db <- read.csv("ModelSEED-compounds-db.csv")
ModelSEED.reactions.db <- read.csv("ModelSEED-reactions-db.csv")

find_cp <- function(stoichiometric_matrix){
  compound_names <- c()
  for (compound in 1:nrow(stoichiometric_matrix))
  {
    compound_names <- c(compound_names, toString(subset(ModelSEED.compounds.db, DATABASE == toString(stoichiometric_matrix$X[compound]) )$PRIMARY.NAME) )
  }
  return(compound_names)
}

find_reaction <- function(stoichiometric_matrix){
  reaction_names <- c()
  for (reaction in 1:dim(stoichiometric_matrix)[2])
  {
    reaction_names <- c(reaction_names, toString(subset(ModelSEED.reactions.db, DATABASE == toString(names(stoichiometric_matrix)[reaction]))$NAME) )
  }
  return(reaction_names)
}

find_full_reaction <- function(stoichiometric_matrix){
  reaction_names <- c()
  for (reaction in 1:dim(stoichiometric_matrix)[2])
  {
    reaction_names <- c(reaction_names, toString(subset(ModelSEED.reactions.db, DATABASE == toString(names(stoichiometric_matrix)[reaction]))$NAME.EQ) )
  }
  return(reaction_names)
}

df_rhizo.NAME.EQ <- find_full_reaction(df_rhizobium[,2:dim(df_rhizobium)[2]])
df_agro.NAME.EQ <- find_full_reaction(df_agro[,2:dim(df_agro)[2]])
df_para.NAME.EQ <- find_full_reaction(df_para[,2:dim(df_para)[2]])
df_burkho.NAME.EQ <- find_full_reaction(df_burkho[,2:dim(df_burkho)[2]])
df_bacillus.NAME.EQ <- find_full_reaction(df_bacillus[,2:dim(df_bacillus)[2]])

# Switch compound code with real compound name
# Switch reaction code with reaction name
names(df_rhizobium) <- c("X", find_reaction(df_rhizobium[,2:dim(df_rhizobium)[2]]))
names(df_agro) <- c("X", find_reaction(df_agro[,2:dim(df_agro)[2]]))
names(df_para) <- c("X", find_reaction(df_para[,2:dim(df_para)[2]]))
names(df_burkho) <- c("X", find_reaction(df_burkho[,2:dim(df_burkho)[2]]))
names(df_bacillus) <- c("X", find_reaction(df_bacillus[,2:dim(df_bacillus)[2]]))

df_rhizobium$X <- find_cp(df_rhizobium)
df_agro$X <- find_cp(df_agro)
df_burkho$X <- find_cp(df_burkho)
df_para$X <- find_cp(df_para)
df_bacillus$X <- find_cp(df_bacillus)

# Calculate Stoichiometric matrix 
# ------------------------------------------------------------
S_rhizo <- data.matrix( df_rhizobium[,2:dim(df_rhizobium)[2]] )
row.names(S_rhizo) <- df_rhizobium$X

S_agro <- data.matrix( df_agro[,2:dim(df_agro)[2]] )
row.names(S_agro) <- df_agro$X

S_burkho <- data.matrix( df_burkho[,2:dim(df_burkho)[2]] )
row.names(S_burkho) <- df_burkho$X

S_para <- data.matrix( df_para[,2:dim(df_para)[2]] )
row.names(S_para) <- df_para$X

S_bacillus <- data.matrix( df_bacillus[,2:dim(df_bacillus)[2]] )
row.names(S_bacillus) <- df_bacillus$X

row.names(S_bacillus)
# Calculate SVD
# ------------------------------------------------------------
library(dplyr)
library(gridExtra)
library(ggplot2)

names(df_rhizobium)

S_rhizo.svd <- svd( S_rhizo)
S_agro.svd <- svd( S_agro)
S_burkho.svd <- svd( S_burkho)
S_para.svd <- svd( S_para)
S_bacillus.svd <- svd( S_bacillus)

dim(S_rhizo)
row.names(S_rhizo)

d_rhizo <- S_rhizo.svd$d
d_para <- S_para.svd$d
d_burkho <- S_burkho.svd$d
d_bacillus <- S_bacillus.svd$d
d_agro <- S_agro.svd$d

d_rhizo1 <- d_rhizo[1] / sum(d_rhizo)
d_agro1 <- d_agro[1] / sum(d_agro)
d_bacillus1 <- d_bacillus[1] / sum(d_bacillus)
d_para1 <- d_para[1] / sum(d_para)
d_burkho1 <- d_burkho[1] / sum(d_burkho)

d_rhizo2 <- d_rhizo[2] / sum(d_rhizo)
d_agro2 <- d_agro[2] / sum(d_agro)
d_bacillus2 <- d_bacillus[2] / sum(d_bacillus)
d_para2 <- d_para[2] / sum(d_para)
d_burkho2 <- d_burkho[2] / sum(d_burkho)

d_rhizo[1]
S_rhizo.svd_eigenreaction <- S_rhizo.svd$u
S_rhizo.svd_eigenreaction <- cbind(as.data.frame(S_rhizo.svd_eigenreaction), compound_name = df_rhizobium$X)

p1_rhizo_U <- arrange(S_rhizo.svd_eigenreaction, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U1") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_rhizo1, digits = 4), sep =": ")))
p1_rhizo_U


S_agro.svd_eigenreaction <- S_agro.svd$u
S_agro.svd_eigenreaction <- cbind(as.data.frame(S_agro.svd_eigenreaction), compound_name = df_agro$X)

p1_agro_U <- arrange(S_agro.svd_eigenreaction, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("agrobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U1") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_agro1, digits = 4), sep =": ")))
p1_agro_U

S_para.svd_eigenreaction <- S_para.svd$u
S_para.svd_eigenreaction <- cbind(as.data.frame(S_para.svd_eigenreaction), compound_name = df_para$X)

p1_para_U <- arrange(S_para.svd_eigenreaction, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("parabium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U1") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_para1, digits = 4), sep =": ")))
p1_para_U

S_bacillus.svd_eigenreaction <- S_bacillus.svd$u
S_bacillus.svd_eigenreaction <- cbind(as.data.frame(S_bacillus.svd_eigenreaction), compound_name = df_bacillus$X)

p1_bacillus_U <- arrange(S_bacillus.svd_eigenreaction, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("bacillusbium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U1") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_bacillus1, digits = 4), sep =": ")))
p1_bacillus_U

S_burkho.svd_eigenreaction <- S_burkho.svd$u
S_burkho.svd_eigenreaction <- cbind(as.data.frame(S_burkho.svd_eigenreaction), compound_name = df_burkho$X)

p1_burkho_U <- arrange(S_burkho.svd_eigenreaction, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("burkhobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U1") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_burkho1, digits = 4), sep =": ")))
p1_burkho_U

grid.arrange(p1_burkho_U, p1_rhizo_U, p1_agro_U, p1_para_U, p1_bacillus_U, ncol = 5)


p2_rhizo_U <- arrange(S_rhizo.svd_eigenreaction, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U2") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_rhizo1, digits = 4), sep =": ")))
p2_rhizo_U


S_agro.svd_eigenreaction <- S_agro.svd$u
S_agro.svd_eigenreaction <- cbind(as.data.frame(S_agro.svd_eigenreaction), compound_name = df_agro$X)

p2_agro_U <- arrange(S_agro.svd_eigenreaction, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Agrobacterium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U2") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_agro1, digits = 4), sep =": ")))
p2_agro_U

S_para.svd_eigenreaction <- S_para.svd$u
S_para.svd_eigenreaction <- cbind(as.data.frame(S_para.svd_eigenreaction), compound_name = df_para$X)

p2_para_U <- arrange(S_para.svd_eigenreaction, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Paracoccus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U2") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_para1, digits = 4), sep =": ")))
p2_para_U

S_bacillus.svd_eigenreaction <- S_bacillus.svd$u
S_bacillus.svd_eigenreaction <- cbind(as.data.frame(S_bacillus.svd_eigenreaction), compound_name = df_bacillus$X)

p2_bacillus_U <- arrange(S_bacillus.svd_eigenreaction, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Bacillus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U2") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_bacillus1, digits = 4), sep =": ")))
p2_bacillus_U

S_burkho.svd_eigenreaction <- S_burkho.svd$u
S_burkho.svd_eigenreaction <- cbind(as.data.frame(S_burkho.svd_eigenreaction), compound_name = df_burkho$X)

p2_burkho_U <- arrange(S_burkho.svd_eigenreaction, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Burkholderia ") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse() + xlab("U2") +
  geom_text(aes(.9, .5, label=paste("Proportional eigenvalue", round(d_burkho1, digits = 4), sep =": ")))
p2_burkho_U

grid.arrange(p2_burkho_U, p2_rhizo_U, p2_agro_U, p2_para_U, p2_bacillus_U, ncol = 5)


p3_rhizo_U <- arrange(S_rhizo.svd_eigenreaction, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) + xlab("U3") +
  xlim(0,1) + scale_y_reverse()


S_agro.svd_eigenreaction <- S_agro.svd$u
S_agro.svd_eigenreaction <- cbind(as.data.frame(S_agro.svd_eigenreaction), compound_name = df_agro$X)

p3_agro_U <- arrange(S_agro.svd_eigenreaction, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Agrobacterium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U3")

S_para.svd_eigenreaction <- S_para.svd$u
S_para.svd_eigenreaction <- cbind(as.data.frame(S_para.svd_eigenreaction), compound_name = df_para$X)

p3_para_U <- arrange(S_para.svd_eigenreaction, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Paracoccus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U3")

S_bacillus.svd_eigenreaction <- S_bacillus.svd$u
S_bacillus.svd_eigenreaction <- cbind(as.data.frame(S_bacillus.svd_eigenreaction), compound_name = df_bacillus$X)

p3_bacillus_U <- arrange(S_bacillus.svd_eigenreaction, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Bacillus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U3")

S_burkho.svd_eigenreaction <- S_burkho.svd$u
S_burkho.svd_eigenreaction <- cbind(as.data.frame(S_burkho.svd_eigenreaction), compound_name = df_burkho$X)

p3_burkho_U <- arrange(S_burkho.svd_eigenreaction, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Burkholderia") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U3")

grid.arrange(p3_burkho_U, p3_rhizo_U, p3_agro_U, p3_para_U, p3_bacillus_U, ncol = 5)


p4_rhizo_U <- arrange(S_rhizo.svd_eigenreaction, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U4")


S_agro.svd_eigenreaction <- S_agro.svd$u
S_agro.svd_eigenreaction <- cbind(as.data.frame(S_agro.svd_eigenreaction), compound_name = df_agro$X)

p4_agro_U <- arrange(S_agro.svd_eigenreaction, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Agrobacterium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U4")

S_para.svd_eigenreaction <- S_para.svd$u
S_para.svd_eigenreaction <- cbind(as.data.frame(S_para.svd_eigenreaction), compound_name = df_para$X)

p4_para_U <- arrange(S_para.svd_eigenreaction, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Paracoccus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U4")

S_bacillus.svd_eigenreaction <- S_bacillus.svd$u
S_bacillus.svd_eigenreaction <- cbind(as.data.frame(S_bacillus.svd_eigenreaction), compound_name = df_bacillus$X)

p4_bacillus_U <- arrange(S_bacillus.svd_eigenreaction, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Bacillus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U4")

S_burkho.svd_eigenreaction <- S_burkho.svd$u
S_burkho.svd_eigenreaction <- cbind(as.data.frame(S_burkho.svd_eigenreaction), compound_name = df_burkho$X)

p4_burkho_U <- arrange(S_burkho.svd_eigenreaction, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = compound_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Burkholderia") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + xlab("U4")

grid.arrange(p4_burkho_U, p4_rhizo_U, p4_agro_U, p4_para_U, p4_bacillus_U, ncol = 5)

grid.arrange(
  p1_burkho_U, p1_rhizo_U, p1_agro_U, p1_para_U, p1_bacillus_U,
  p2_burkho_U, p2_rhizo_U, p2_agro_U, p2_para_U, p2_bacillus_U,
  p3_burkho_U, p3_rhizo_U, p3_agro_U, p3_para_U, p3_bacillus_U,
  p4_burkho_U, p4_rhizo_U, p4_agro_U, p4_para_U, p4_bacillus_U, ncol = 5, nrow = 4)

# Create eigen connectivity plots
S_rhizo.svd_eigenconnect <- S_rhizo.svd$v
S_rhizo.svd_eigenconnect <- cbind(as.data.frame(S_rhizo.svd_eigenconnect), reaction_name =  names(df_rhizobium)[-1])

test <- as.data.frame(arrange(S_rhizo.svd_eigenconnect, desc(V1))[1:15,]$reaction_name)
names(test) <- c("reaction_name")

grid.arrange(p1_burkho_U, t, nrow =2)

#t <- tableGrob(test,  gpar.coretext =gpar(fontsize=8), gpar.coltext=gpar(fontsize=10, fontface='bold'))
#t

p1_rhizo_V <- arrange(S_rhizo.svd_eigenconnect, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() + scale_y_reverse()
p1_rhizo_V

S_agro.svd_eigenconnect <- S_agro.svd$v
S_agro.svd_eigenconnect <- cbind(as.data.frame(S_agro.svd_eigenconnect), reaction_name =  names(df_agro)[-1])

p1_agro_V <- arrange(S_agro.svd_eigenconnect, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Agrobacterium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse() 

S_para.svd_eigenconnect <- S_para.svd$v
S_para.svd_eigenconnect <- cbind(as.data.frame(S_para.svd_eigenconnect), reaction_name =  names(df_para)[-1])

p1_para_V <- arrange(S_para.svd_eigenconnect, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Paracoccus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_bacillus.svd_eigenconnect <- S_bacillus.svd$v
S_bacillus.svd_eigenconnect <- cbind(as.data.frame(S_bacillus.svd_eigenconnect), reaction_name =  names(df_bacillus)[-1])

p1_bacillus_V <- arrange(S_bacillus.svd_eigenconnect, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Bacillus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_burkho.svd_eigenconnect <- S_burkho.svd$v
S_burkho.svd_eigenconnect <- cbind(as.data.frame(S_burkho.svd_eigenconnect), reaction_name =  names(df_burkho)[-1])

p1_burkho_V <- arrange(S_burkho.svd_eigenconnect, desc(V1))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V1, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Burkholderia") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

grid.arrange(p1_burkho_V, p1_rhizo_V, p1_agro_V, p1_para_V, p1_bacillus_V, ncol = 5)


p2_rhizo_V <- arrange(S_rhizo.svd_eigenconnect, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()


S_agro.svd_eigenconnect <- S_agro.svd$v
S_agro.svd_eigenconnect <- cbind(as.data.frame(S_agro.svd_eigenconnect), reaction_name =  names(df_agro)[-1])

p2_agro_V <- arrange(S_agro.svd_eigenconnect, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Agrobacterium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_para.svd_eigenconnect <- S_para.svd$v
S_para.svd_eigenconnect <- cbind(as.data.frame(S_para.svd_eigenconnect), reaction_name =  names(df_para)[-1])

p2_para_V <- arrange(S_para.svd_eigenconnect, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Paracoccus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_bacillus.svd_eigenconnect <- S_bacillus.svd$v
S_bacillus.svd_eigenconnect <- cbind(as.data.frame(S_bacillus.svd_eigenconnect), reaction_name =  names(df_bacillus)[-1])

p2_bacillus_V <- arrange(S_bacillus.svd_eigenconnect, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Bacillus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_burkho.svd_eigenconnect <- S_burkho.svd$v
S_burkho.svd_eigenconnect <- cbind(as.data.frame(S_burkho.svd_eigenconnect), reaction_name =  names(df_burkho)[-1])

p2_burkho_V <- arrange(S_burkho.svd_eigenconnect, desc(V2))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V2, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Burkholderia") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

grid.arrange(p2_burkho_V, p2_rhizo_V, p2_agro_V, p2_para_V, p2_bacillus_V, ncol = 5)


p3_rhizo_V <- arrange(S_rhizo.svd_eigenconnect, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()


S_agro.svd_eigenconnect <- S_agro.svd$v
S_agro.svd_eigenconnect <- cbind(as.data.frame(S_agro.svd_eigenconnect), reaction_name =  names(df_agro)[-1])

p3_agro_V <- arrange(S_agro.svd_eigenconnect, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Agrobacterium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_para.svd_eigenconnect <- S_para.svd$v
S_para.svd_eigenconnect <- cbind(as.data.frame(S_para.svd_eigenconnect), reaction_name =  names(df_para)[-1])

p3_para_V <- arrange(S_para.svd_eigenconnect, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Paracoccus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_bacillus.svd_eigenconnect <- S_bacillus.svd$v
S_bacillus.svd_eigenconnect <- cbind(as.data.frame(S_bacillus.svd_eigenconnect), reaction_name =  names(df_bacillus)[-1])

p3_bacillus_V <- arrange(S_bacillus.svd_eigenconnect, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Bacillus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_burkho.svd_eigenconnect <- S_burkho.svd$v
S_burkho.svd_eigenconnect <- cbind(as.data.frame(S_burkho.svd_eigenconnect), reaction_name =  names(df_burkho)[-1])

p3_burkho_V <- arrange(S_burkho.svd_eigenconnect, desc(V3))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V3, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Burkholderia") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

grid.arrange(p3_burkho_V, p3_rhizo_V, p3_agro_V, p3_para_V, p3_bacillus_V, ncol = 5)


p4_rhizo_V <- arrange(S_rhizo.svd_eigenconnect, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Rhizobium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()


S_agro.svd_eigenconnect <- S_agro.svd$v
S_agro.svd_eigenconnect <- cbind(as.data.frame(S_agro.svd_eigenconnect), reaction_name =  names(df_agro)[-1])

p4_agro_V <- arrange(S_agro.svd_eigenconnect, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Agrobacterium") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_para.svd_eigenconnect <- S_para.svd$v
S_para.svd_eigenconnect <- cbind(as.data.frame(S_para.svd_eigenconnect), reaction_name =  names(df_para)[-1])

p4_para_V <- arrange(S_para.svd_eigenconnect, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Paracoccus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_bacillus.svd_eigenconnect <- S_bacillus.svd$v
S_bacillus.svd_eigenconnect <- cbind(as.data.frame(S_bacillus.svd_eigenconnect), reaction_name =  names(df_bacillus)[-1])

p4_bacillus_V <- arrange(S_bacillus.svd_eigenconnect, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Bacillus") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

S_burkho.svd_eigenconnect <- S_burkho.svd$v
S_burkho.svd_eigenconnect <- cbind(as.data.frame(S_burkho.svd_eigenconnect), reaction_name =  names(df_burkho)[-1])

p4_burkho_V <- arrange(S_burkho.svd_eigenconnect, desc(V4))[1:15,] %>%
  mutate(index = 1:15) %>%
  ggplot(aes(x = V4, y = index, label = reaction_name)) + geom_point() + geom_text(hjust = -.1) +
  ggtitle("Burkholderia") + theme(plot.title = element_text(size=20, face="bold", vjust=2)) +
  xlim(0,1) + scale_y_reverse()

grid.arrange(p4_burkho_V, p4_rhizo_V, p4_agro_V, p4_para_V, p4_bacillus_V, ncol = 5)

test_arrange <- grid.arrange(
  p1_burkho_V, p1_rhizo_V, p1_agro_V, p1_para_V, p1_bacillus_V,
  p2_burkho_V, p2_rhizo_V, p2_agro_V, p2_para_V, p2_bacillus_V,
  p3_burkho_V, p3_rhizo_V, p3_agro_V, p3_para_V, p3_bacillus_V,
  p4_burkho_V, p4_rhizo_V, p4_agro_V, p4_para_V, p4_bacillus_V, ncol = 5, nrow = 4)


###########
# Plotting stuff nicely
##########
source("highqualgraphR.R") #this requires that the file is in your working directory (check with getwd())
#Sourcing only needs to be executed once, preferably at the top of your script

return_contents <- function(string)
{
  return(eval(parse( text = string)))
}

a <- ls.str()
a[grep("_U", a)]
a[grep("_V", a)]

library("extrafont")

loadfonts(device = "postscript")


for (plot in a[grep("_U", a)])
{
  highqualgraphR(return_contents(plot), plot, res=1200,pointsize=12, extension = c("pdf", "png")) #here x is a ggplot object
}

for (plot in a[grep("_V", a)])
{
  highqualgraphR(return_contents(plot), plot, res=1200,pointsize=12) #here x is a ggplot object
}
