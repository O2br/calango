#rm(list=ls())
library("dplyr")
library("jsonlite")
library("RCurl")
library("tibble")
raw_data <- getURL("http://tr.ons.org.br/Content/Get/Carga_SIN")
data <- fromJSON(raw_data)

itens <- seq(1:length(data$rows$c))

dados <- tibble::data_frame(item = itens) %>%
  dplyr::distinct(item) %>%
  dplyr::group_by(item) %>%
  dplyr::do({
    mutate(., dia = Sys.Date()  
           , medicao =  data$rows$c[[.$item]]$v[2]
           , minuto =data$rows$c[[.$item]]$v[1]  ) 
  }) %>%
  dplyr::ungroup() %>%
  dplyr::select(dia,minuto,medicao)
##Remove objetos desnecessarios para economizar memoria
rm(raw_data,data,itens)

write.csv2(dados,file = paste0("ons_files/",Sys.Date(),as.numeric(Sys.time()),"_ons.csv"))
