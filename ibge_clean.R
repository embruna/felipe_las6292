ibge_clean <- function(ibge_table) {
  
  library(tidyverse)
  library(tidyxl)
  library(readxl)
  
  # STEP 4: Figure out the structure of the indentation on the column telling you
  # estado, macro, micro, municipio
  
  formats = xlsx_formats(ibge_table)
  x = xlsx_cells(ibge_table)
  formats$local$alignment$indent
  estados<-x[x$local_format_id %in% which(formats$local$alignment$indent==3),c("address", "character")]
  estados
  estados$unit<-"state"
  estados
  meso<-x[x$local_format_id %in% which(formats$local$alignment$indent==4),c("address", "character")]
  meso
  meso$unit<-"meso-region"
  meso
  micro<-x[x$local_format_id %in% which(formats$local$alignment$indent==6),c("address", "character")]
  micro 
  micro$unit<-"micro-region"
  micro
  muni<-x[x$local_format_id %in% which(formats$local$alignment$indent==7), c("address", "character")]
  muni 
  muni$unit<-"municipality"
  muni 
  geo_units<-bind_rows(estados,meso,micro,muni) 
  head(geo_units,10)
  geo_units<-rename(geo_units,"cell"="address","name"="character")
  head(geo_units,10)
  
  #delete the letter A
  geo_units$cell<-gsub("A", "", geo_units$cell)
  
  # Change the "units column from chr to a unteger
  geo_units$cell<-as.numeric(as.character(geo_units$cell))
  
  # sort them by nunber. 
  # This will put them in the same order as they were in the original file
  geo_units<-arrange(geo_units,by=cell)
  
  # STEP 5: now read the excel file
  raw_data<-read_xlsx(ibge_table)
  raw_data
  
  
  
  # You can see that the first line of data is line #4
  # lets read it in again but this time ignore the first three lines with "skip = 3"   
  raw_data<-read_xlsx(ibge_table, skip=3)
  raw_data
  
  original_column_names<-as.data.frame(colnames(raw_data))
  
  #this will take the ugly column names and repakce them with easier ones so you can fix them
  # how many columns does the DF have?
  column_count<-ncol(raw_data)
  column_count
  # Now create a vector with as many letters as there are column names
  col_index<-LETTERS[seq(from = 1, to = column_count )]
  # rename the columns with that vector
  colnames(raw_data)<-col_index
  colnames(raw_data)
  
  #Delete the last row if the first cell has "Fonte: IBGE, Produção Vegetal e Silvicultura 2016"
  if (raw_data[nrow(raw_data),1]=="Fonte: IBGE, Produção Vegetal e Silvicultura 2016") {
    raw_data<-raw_data[-nrow(raw_data),]  
  }
  
  # you have to replace the - with NA first or it will mess up the conversion of the columsn from characer to numbers 
  raw_data[2:column_count][raw_data[2:column_count] == "-"] <- NA
  
  # This changes all the columns after the second one from character to number
  raw_data[2:column_count] <- sapply(raw_data[2:column_count],as.numeric)
  
  
  # Add the geographic info
  raw_data<-cbind(geo_units, raw_data)
  # delete the first two columns
  raw_data<-select(raw_data, -cell,-name)
  # see what it looks like
  head(raw_data,10)
  
  
  # This adds a column for each unit, them fills it in so that you know have the complete data
  raw_data<-raw_data %>% mutate(state = ifelse(unit == "state", A,NA)) %>% fill(state)
  raw_data<-raw_data %>% mutate(meso_region = ifelse(unit == "meso-region", A,NA)) %>% fill("meso_region")
  raw_data<-raw_data %>% fill(meso_region,.direction="up")
  
  raw_data<-raw_data %>% mutate(micro_region = ifelse(unit == "micro-region", A,NA)) %>% fill("micro_region")
  raw_data<-raw_data %>% fill(micro_region,.direction="up")
  
  raw_data<-raw_data %>% mutate(municipality = ifelse(unit == "municipality", A,NA)) %>% fill("municipality")
  raw_data<-raw_data %>% fill(municipality,.direction="up")
  
  
  # This rearranges them in usable format
  raw_data<-raw_data %>% select(state, meso_region, micro_region, municipality,col_index,-A)
  head(raw_data,10)
  

  raw_data$state<-as.factor(raw_data$state)
  raw_data$meso_region<-as.factor(raw_data$meso_region)
  raw_data$micro_region<-as.factor(raw_data$micro_region)
  raw_data$municipality<-as.factor(raw_data$municipality)
  

  ##### change the state names to codes
  levels(raw_data$state)
  
  
  state_codes<-read_excel("./Raw_data/State_codes.xlsx",col_names=TRUE)
  state_codes$state<-as.factor(state_codes$state)
  
  raw_data<-full_join(raw_data,state_codes,by="state")
  # raw_data$state<-raw_data$state_abrev
  raw_data$state<-as.factor(raw_data$state)
  raw_data$state_code<-as.factor(raw_data$state_code)
  raw_data <- select(raw_data,state_code, everything())
  
  
  return(raw_data)
}
