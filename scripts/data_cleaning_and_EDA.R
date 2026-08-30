#-------------------------------------------------------------------------------
# Data cleanning
#-------------------------------------------------------------------------------
####################################
#---------Import data---------
####################################

rm(list=ls())

data <- read.delim("C:/Escritorio/máster/Multivariata Analysis/first assignment/EGHE_2023.tab", stringsAsFactors=TRUE)
#Sexo, Edad, Nacionalidad, Estudiante(si realiza algun tipo de estudios), C01(Tipo de enseñanza), 
#MCL(Importe del gasto en matricula y clases lectivas), C11A(Importe del gasto en transporte), 
#C19A(Importe del gasto en extraescolares), LIB(Importe del gasto en libros y de ayuda al estudio),
#D54(Importe del gasto en productos infomaticos), E59(Becas o ayudas)

####################################
#---------Data cleaning---------
####################################

data <- data[, c("SEXO", "EDAD", "NACIONALIDAD", "ESTUDIANTE", "C01","D45", "C09A", "LIB","E59","D54","C19A")]

colnames(data) <-c("sex", "age", "nationality", "student", "type", "uniform", "food", "books", "help","computer","activities")
cols_to_factor <- c("sex", "nationality","student", "type", "help")
data[cols_to_factor] <- lapply(data[cols_to_factor], as.factor)
colSums(is.na(data))
sum(is.na(data))

#Delete students 0 (no students)
ind<-which(data$student==0) 
data <- data[-ind, ]
colSums(is.na(data))
data$student <- NULL

dim(data) #5061   10

sum(is.na(data$sex)) #0
sum(is.na(data$age)) #0
sum(is.na(data$nationality))#0
sum(is.na(data$type)) #802
sum(is.na(data$tuition)) #802
sum(is.na(data$uniform)) #3415
sum(is.na(data$food)) #3957
sum(is.na(data$books)) #1698
sum(is.na(data$cost)) #4298
sum(is.na(data$help)) #802
sum(is.na(data$computer)) # 4038
sum(is.na(data$activities)) # 4147

# Delete rows with several NAs
na<- rowSums(is.na(data))
names(na) <- NULL
data <- data[na<2,]
dim(data)

colSums(is.na(data))

####################################
#---------Imputation of data---------
####################################
library(mice)
imp <- mice(data, m = 5, method = "pmm", seed = 123)
data <- complete(imp)

#Transform binary variables
data$help <- ifelse(data$help == 2, 0, 1)
data$sex <- ifelse(data$sex == 2, 0, 1)

summary(data)

write.csv(data, "data_cleaning.csv", row.names = FALSE)

#-------------------------------------------------------------------------------
# EDA
#-------------------------------------------------------------------------------
rm(list=ls())

df <- read.csv("data_cleaning.csv", header = TRUE, sep = ",", dec=".", stringsAsFactors = TRUE)

cols_to_factor <- c("sex", "nationality", "type", "help")
df[cols_to_factor] <- lapply(df[cols_to_factor], as.factor)

# Libraries
#-------------------------------------------------------------------------------
if (!require("ggplot2")) {
  install.packages("ggplot2")
}
library(ggplot2)

if (!require("patchwork")) {
  install.packages("patchwork")
}
library("patchwork")

if (!require("tidyverse")) {
  install.packages("tidyverse")
}
library(tidyverse)

################################################################################
# BINARY AND CATEGORICAL VARIABLES
################################################################################
summary(df[,c("sex","nationality","help","type")])

# Barplots: binary and categorical variables
# (sex, nationality, help, type)
#-------------------------------------------------------------------------------
levels(df$sex) <- c("male", "female")
g7 <- ggplot(data = df, aes(x = sex)) +
  geom_bar(color = "black", fill = "skyblue", position = "dodge") +
  labs(x = "sex", y = "absolute frequency")+
  theme_minimal(base_size = 13)

levels(df$nationality) <- c("Spanish", "Foreign", "2 nationalies")
g8 <- ggplot(data = df, aes(x = nationality)) +
  geom_bar(color = "black", fill = "skyblue", position = "dodge") +
  labs(x = "nationality", y = "absolute frequency")+
  theme_minimal(base_size = 13)

levels(df$help) <- c("no", "yes")
g9 <- ggplot(data = df, aes(x = help)) +
  geom_bar(color = "black", fill = "skyblue", position = "dodge") +
  labs(x = "help", y = "absolute frequency")+
  theme_minimal(base_size = 13)

levels(df$type) <- c("public", "funded-private", "private")
g10 <- ggplot(data = df, aes(x = type)) +
  geom_bar(color = "black", fill = "skyblue", position = "dodge") +
  labs(x = "type", y = "absolute frequency")+
  theme_minimal(base_size = 13)

(g7 + g8)/(g9 + g10) +
  plot_annotation(
    title = "Bar plots: binary and categorical variables")


################################################################################
# CONTINUOUS VARIABLES
################################################################################

summary(df[,c("age","uniform","food","books", "computer", "activities")])

# Histograms: continuous variables
# (age, tuition, uniform, food, books, cost)
#-------------------------------------------------------------------------------
g1 <- ggplot(data = df, aes(x = age)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 15) +
  labs(x = "age", y = "Absolute frequency")+
  theme_minimal(base_size = 13)
g2 <- ggplot(data = df, aes(x = uniform)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 15) +
  labs(x = "uniform", y = "Absolute frequency")+
  theme_minimal(base_size = 13)
g3 <- ggplot(data = df, aes(x = food)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 15) +
  labs(x = "food", y = "Absolute frequency")+
  theme_minimal(base_size = 13)
g4 <- ggplot(data = df, aes(x = books)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 20) +
  labs(x = "books", y = "Absolute frequency")+
  theme_minimal(base_size = 13)
g5 <- ggplot(data = df, aes(x = computer)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 20) +
  labs(x = "computer", y = "Absolute frequency")+
  theme_minimal(base_size = 13)
g6 <- ggplot(data = df, aes(x = activities)) +
  geom_histogram(fill = "skyblue", color = "black", bins=25) +
  labs(x = "activities", y = "Absolute frequency")+
  theme_minimal(base_size = 13)

(g1 + g2 + g3)/(g4+g5+g6) +
  plot_annotation(
    title = "Histograms: continuous variables"
  )


# Boxplots
#-------------------------------------------------------------------------------
df_long <- df %>%
  pivot_longer(cols = c(age, uniform, food, books, computer, activities),
               names_to = "variable",
               values_to = "value")

ggplot(df_long, aes(x = variable, y = value)) +
  geom_boxplot(fill = "skyblue") +
  scale_y_log10() +
  theme_minimal(base_size = 15) +
  labs(x = "Variables", y = "Values (log10)",
       title = "Boxplots in Logaritmic Scale")
