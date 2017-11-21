library("RCurl")
library("rvest")
library("stringr")
library("jsonlite")
Sys.setenv(LANG = "pt_BR.UTF-8")

#Carrega Contratos do arquivo
##Busca de Arquivo 
##dados <- read.csv2("contratos",header=T)
page <- read_html("http://servicos.dnit.gov.br/portalcidadao")
dados <- page %>%
  html_nodes(xpath = '//*[@id="contrato"]/option') %>%
  html_text()%>%
  .[ .!= "" ]  %>%
  data.frame(., stringsAsFactors = FALSE)   

names(dados) <-c("contratos")

URL <- "http://servicos.dnit.gov.br/portalcidadao?contrato="
if (!file.exists("dados_originais")){
  dir.create("dados_originais")
}
  for ( i in 1:nrow(dados)){
    contrato <- URLencode(as.character(dados[i,1]))
    num_contrato <- gsub("/|| ", "",   as.character(dados[i,1]))
    if (!file.exists(paste0("dados_originais/",num_contrato,".html"))){
      download.file( paste0(URL,contrato), destfile = paste0("dados_originais/",num_contrato,".html"), method="libcurl")
    }
  }  

#http://compras.dados.gov.br:8080/contratos/v1/contratos.json?uasg=393003&offset=0
#http://compras.dados.gov.br/licitacoes/v1/orgaos.html?nome=dep
#http://compras.dados.gov.br/licitacoes/v1/uasgs?id_orgao=39252

###Exemplo consumo on-line
# 00003382006 http://servicos.dnit.gov.br/portalcidadao?contrato=00%00338/2006
# num_contrato <- "00000812010"
# page <- read_html(paste0(getwd(),"/dados_originais/",num_contrato,".html"))
#
# page <- read_html("http://servicos.dnit.gov.br/portalcidadao?contrato=08%2000226/2016")
#   info_contrato <- page %>%
#      html_nodes(xpath = '//*[@id="content"]/div[2]/div/div/div/div') %>%
#      html_text()
#      temp <- gsub("\\t||\\n||\\r", "", info_contrato)


# <select style="width: 100%" id="contrato" name="contrato" onchange="submit();">
#   <option value=""></option>
#   <option value="15 00495/2017">15 00495/2017</option>


file.remove("contratos.csv")
file.remove("segmentos.csv")

for ( i in 1:nrow(dados)){
  num_contrato <- gsub("/|| ", "",   as.character(dados[i,1]))
  page <- read_html(paste0(getwd(),"/dados_originais/",num_contrato,".html"))

##Informações para geocoding   
   segmento <- page %>%
     html_nodes("script") %>%
     html_text() %>%
     str_extract("montarMapa\\(\\[\\{*.*\\}\\]") %>%    
     str_extract("\\[\\{*.*\\}\\]")
#     print(paste0("*",num_contrato))     
    df_seg <- NULL 

    result <- try({
            df_seg <- fromJSON(segmento[!is.na(segmento)])
            print(paste0(num_contrato,"->",nrow(df_seg)))
            }, silent=FALSE)
    if (!is.null(df_seg)){
      nm_arquivo <-"segmentos.csv"     
      write.table(df_seg,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
      #write.table(df_seg,file="segmentos.csv", append=TRUE,col.names = FALSE,row.names = FALSE,quote = FALSE)
    }     
 

   info_contrato <- page %>%
      html_nodes(xpath = '//*[@id="content"]/div[2]/div/div/div/div') %>%
      html_text()
      temp <- gsub("\\t||\\n||\\r", "", info_contrato)

      info_1 <-  unlist( strsplit(temp[1], ":"))     
      info_2 <-  unlist( strsplit(temp[2], ":"))     
      info_3 <-  unlist( strsplit(temp[3], ":"))     
      info_4 <-  unlist( strsplit(temp[4], ":"))     
      info_5 <-  unlist( strsplit(temp[5], ":"))     
      info_6 <-  unlist( strsplit(temp[6], ":"))     
      info_7 <-  unlist( strsplit(temp[7], ":"))     
      info_8 <-  unlist( strsplit(temp[8], ":"))     
      info_9 <-  unlist( strsplit(temp[9], ":"))     
      info_10 <-  unlist( strsplit(temp[10], ":"))     
      info_11 <-  unlist( strsplit(temp[11], ":"))
      info_12 <-  unlist( strsplit(temp[12], ":"))
      info_13 <-  unlist( strsplit(temp[13], ":"))     
      info_14 <-  unlist( strsplit(temp[14], ":"))     
      info_15 <-  unlist( strsplit(temp[15], ":"))     
      info_16 <-  unlist( strsplit(temp[16], ":"))     
      info_17 <-  unlist( strsplit(temp[17], ":"))     
   status_obra <- page %>%
     html_nodes(xpath = '//*[@id="content"]/div[3]/div/div[1]/div') %>%
     html_text()
     st_obra <-  unlist( strsplit(gsub("\\t||\\n||\\r", "", status_obra), ":"))     

     df <-data.frame(cbind(info_1[2],info_2[2],info_3[2],info_4[2],info_5[2],info_6[2],info_7[2],info_8[2],info_9[2],info_10[2],info_11[2],info_12[2],info_13[2],info_14[2],info_15[2],info_16[2],info_17[2],st_obra[2]))
     colnames(df) <- cbind(info_1[1],info_2[1],info_3[1],info_4[1],info_5[1],info_6[1],info_7[1],info_8[1],info_9[1],info_10[1],info_11[1],info_12[1],info_13[1],info_14[1],info_15[1],info_16[1],info_17[1],st_obra[1])
     nm_arquivo <-"contratos.csv"     
     write.table(df,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
    
#    imagesEmprendimento <- page %>%
#      html_nodes(".imgModal ") %>%
#      html_attr("src")
#      write.table(paste0(num_contrato,",",imagesEmprendimento),file="images.csv", append=TRUE,col.names = FALSE,row.names = FALSE,quote = FALSE)
#     for ( i1 in 1:length(imagesEmprendimento)){
#      URLImagem <- imagesEmprendimento[i1]
#      result <- try({
#      curl = getCurlHandle()
#      bfile=getBinaryURL (
#        URLImagem,
#        curl= curl,
#        progressfunction = function(down, up) {print(down)}, noprogress = FALSE
#      )
#      writeBin(bfile, paste0("d:/scraper_images/",num_contrato,"_",gsub("http://servicos.dnit.gov.br/supra/img/sigacont/", "", imagesEmprendimento[i1])))
#      rm(curl, bfile)
#      }, silent=TRUE)  
#     }

}


# library("stringr")
# grep(segmento[[6]], "montarMapa")
# str_extract(segmento[[6]], "montarMapa\\(\\[\\{*.*\\}\\]")

#temp <- gsub("\\t||\\n", "", sources)
#as.list(temp)
###Referencia 
# http://listas.inf.ufpr.br/pipermail/r-br/2015-March/015285.html
# https://www.r-bloggers.com/using-rvest-and-dplyr-to-look-at-aviation-incidents/
# https://www.rdocumentation.org/packages/rvest/versions/0.3.2/topics/html_nodes
### file
#http://www.leg.ufpr.br/~paulojus/embrapa/Rembrapa/Rembrapase34.html
###try
# http://mazamascience.com/WorkingWithData/?p=929
#grepl( "montarMapa",segmento)
#http://servicos.dnit.gov.br/portalcidadao?contrato=00 00831/2013


##http://servicos.dnit.gov.br/portalcidadao?contrato=00 00080/2010


#Medições
##http://www.dnit.gov.br/emitir_relatorio_medicao?idcontrato=6899&idmedicao=1


