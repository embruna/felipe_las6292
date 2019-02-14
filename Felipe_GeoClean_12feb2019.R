library(tidyverse)
library(tidyxl)
library(readxl)

source("ibge_clean.R")

##############################
# TABELA 14
##############################
Tabela14<-'./Raw_data/Tabela14.xlsx' #put the location of your data
ibge_table_14<-ibge_clean(Tabela14)
head(ibge_table_14,10)

ibge_table<-'./Raw_data/Tabela14.xlsx' #put the location of your data
ibge_table_14<-ibge_clean(ibge_table)
head(ibge_table_14,10)


ibge_table_14 <- rename(ibge_table_14, "acai_pro" = "B")
ibge_table_14 <- rename(ibge_table_14, "acai_val" = "C")
ibge_table_14 <- rename(ibge_table_14, "cascaju_pro" = "D")
ibge_table_14 <- rename(ibge_table_14, "cascaju_val" = "E")
ibge_table_14 <- rename(ibge_table_14, "caspara_pro" = "F")
ibge_table_14 <- rename(ibge_table_14, "caspara_val" = "G")
colnames(ibge_table_14)
head(ibge_table_14,10)
#SAVE THE CLEAN DATA
# write_csv(ibge_table_14, "./data_clean/ibge_table_14.csv")
write_excel_csv(ibge_table_14, "./Clean_data/ibge_table_14.csv",delim=",",col_names=TRUE)

##############################
# TABELA XX
##############################

Tabela15<-'./data_clean/Tabela14.xlsx' #put the location of your data
ibge_table_15<-ibge_clean(Tabela14)

#NO SAVE THE CLEAN DATA
write_excel_csv(ibge_table_15, "./Clean_data/ibge_table_14.csv",delim=",",col_names=TRUE)

##############################
# TABELA XX
##############################


COMBINED_DATA<-full_join(ibge_table_14,ibge_table_XX,ibge_table_XX,by=c("state_code","state","meso_region","micro_region","municipality"))
summary(COMBINED_DATA)
write_excel_csv(COMBINED_DATA, "./Clean_data/COMBINED_DATA.csv",delim=",",col_names=TRUE)
