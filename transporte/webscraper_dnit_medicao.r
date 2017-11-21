rm(list=ls())
library("RCurl")
library("rvest")
library("stringr")
library("jsonlite")
library("httr")
library("dplyr")
library("pdftools")

Sys.setenv(LANG = "pt_BR.UTF-8")
URL <- "http://www.dnit.gov.br/boletim_eletronico_medicao"

page <- read_html(URL)
uf_sigla <- page %>%
     html_nodes(xpath = '//*[@id="uf"]/option ') %>%
     html_text()
uf_codigo <- page %>%
    html_nodes(xpath = '//*[@id="uf"]/option ') %>%
    html_attr("value")
df_ufs <-data.frame(cbind(uf_sigla,uf_codigo))  

for (i in 2:nrow(df_ufs)){  
  nm_uf<-as.character(df_ufs[i,1]) 
  cd_uf<-as.character(df_ufs[i,2])
  req <- httr::POST('http://www.dnit.gov.br/busca_itens_relatorio_medicao',
                    add_headers(Referer = "http://www.dnit.gov.br"),
                    body = list(
                      metodo = "listarRodovia",
                      idUf = cd_uf
                    ),
                    encode="form") 
  result <- httr::content(req, as = "text")
  
  page <- read_html(result)
  uf_sigla_rodovias <- page %>%
    html_nodes('option') %>%
    html_text()
  uf_codigo_rodovias <- page %>%
    html_nodes('option') %>%  
    html_attr("value")
  
  qt_rodo <- length(uf_sigla_rodovias)
  df_rodovias <- cbind(rep(cd_uf,length(uf_sigla_rodovias)),uf_sigla_rodovias,uf_codigo_rodovias,rep(as.character(nm_uf),length(uf_sigla_rodovias)))

  nm_arquivo <- "uf_rodovias.csv"
  #write.table(df_rodovias,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
  #t <- cbind(rep(cd_uf,length(uf_sigla_rodovias)),uf_sigla_rodovias,uf_codigo_rodovias,rep(nm_uf,length(uf_sigla_rodovias)))
  
  for( i1 in 2:nrow(df_rodovias)){
    nm_br <- df_rodovias[i1,2]
    cd_br <- df_rodovias[i1,3]
#    tt <- cbind(cd_uf,nm_uf,nm_br,cd_br)
#     colnames(tt) <-c("cd_uf","sg_uf","sg_rodovias","cd_rodovias")
#     write.table(tt,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
    URL<-paste0("http://www.dnit.gov.br/busca_grafico_relatorio_medicao?uf=",cd_uf,"&rodovia=",URLencode(cd_br, reserve = TRUE))
    download.file( URL, destfile = paste0("dados_scraper_medicoes/",nm_uf,"_",nm_br,".html"), method="libcurl")
  }
  
}

# tt <- read.csv("uf_rodovias.csv")
# URL <-paste0("dados_scraper_medicoes/",tt[1,2],"_",tt[1,3],".html")
# page <- read_html(URL)    
#        contrato_vl <- page %>%
#          html_nodes('input') %>%
#          html_attr('value')
#        contrato_nm <- page %>%
#          html_nodes('input') %>%
#          html_attr('class')      
#        contratos = cbind(contrato_nm,contrato_vl)

aUF_rodovias <- read.csv("uf_rodovias.csv")
id_uf <-''
sg_uf <-''
id_rodovia <-''
sg_rodovia <-''
id_contrato <-''
cd_contrato <-''
km_ini         <-''
km_fim         <-''
nr_ano_medicao <-''
nr_mes_medicao <-''

for (i2 in 1:nrow(aUF_rodovias)){
  id_uf      <- as.character(aUF_rodovias[i2,1])
  sg_uf      <- as.character(aUF_rodovias[i2,2])
  id_rodovia <- as.character(aUF_rodovias[i2,4])
  sg_rodovia <- as.character(aUF_rodovias[i2,3]) 
  #print(id_rodovia)
  URL <-paste0("dados_scraper_medicoes/",sg_uf,"_",sg_rodovia,".html")
  page <- read_html(URL)    
  
    IdContratos <- page %>%
    html_nodes(xpath='//*[@class="ctrs"]/div') %>%
    html_attr('onclick') %>%
    str_extract("\\(.*\\)")  %>%
    { gsub("[(]|[)]","", .) } %>%
    { gsub("',t", "','t", .) } %>%
    { gsub("[']+[,]+[']", ";", .) } %>%
    { gsub("'", "", .) } %>%  
    str_split( ";") 

  for (i3 in 1:length(IdContratos)) {    
#      if (length(IdContratos[[i3]])==4 ){
#        km_ini         <- IdContratos[[i3]][3]      
#        km_fim         <- IdContratos[[i3]][4]      
#        
#          ##Pega os contratos do segmento km_inicial e km_final
#          # http://www.dnit.gov.br/busca_contratos_relatorio_medicao?uf=2&rodovia=9%230%2C00&trecho_inicial=0.00&trecho_final=46.35
#          URL2 <-paste0("http://www.dnit.gov.br/busca_contratos_relatorio_medicao?uf=",id_uf,"&rodovia=",URLencode(id_rodovia, reserve = TRUE),"&trecho_inicial=",km_ini,"&trecho_final=",km_fim)
#          print(URL2)
#           page_contratos <- read_html(URL2)    
#           IdContratos_2 <- page_contratos %>%
#             html_nodes('option') %>%
#             html_attr('value')  
#           IdContratos_2_ds <- page_contratos %>%
#             html_nodes('option') %>%
#             html_text()       
#        
#            for (i4 in 2:length(IdContratos_2)){
#              print(IdContratos_2[i4])            
#              id_contrato    <- IdContratos_2[i4]
#              cd_contrato    <- IdContratos_2_ds[i4]
#              #      cd_contrato    <- 
#              gr_contratos <- cbind(paste0("id_uf:",id_uf),paste0("sg_uf:",sg_uf),paste0("id_rodovia:",id_rodovia),paste0("sg_rodovia:",sg_rodovia),paste0("id_contrato:",id_contrato),paste0("km_ini:",km_ini),paste0("km_fim:",km_fim), paste0("cd_contrato:",cd_contrato))  
#              nm_arquivo <- "gr_contratos_1.csv"     
#              write.table(gr_contratos,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
#              rm(gr_contratos)
#              gr_contratos <- cbind(id_uf,sg_uf,id_rodovia,sg_rodovia,id_contrato,km_ini,km_fim, cd_contrato)  
#              nm_arquivo <- "contratos_maisde1.csv"     
#              write.table(gr_contratos,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
#              rm(gr_contratos)             
#            }             
# 
#      } else { 
#       id_contrato    <- IdContratos[[i3]][3]
# #      cd_contrato    <- 
#       km_ini         <- IdContratos[[i3]][4]      
#       km_fim         <- IdContratos[[i3]][5]      
#       gr_contratos <- cbind(paste0("id_uf:",id_uf),paste0("sg_uf:",sg_uf),paste0("id_rodovia:",id_rodovia),paste0("sg_rodovia:",sg_rodovia),paste0("id_contrato:",id_contrato),paste0("km_ini:",km_ini),paste0("km_fim:",km_fim))  
#       nm_arquivo <- "gr_contratos.csv"     
#       write.table(gr_contratos,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
#       rm(gr_contratos)
#      }
         if (length(IdContratos[[i3]])==4 ){
           km_ini         <- IdContratos[[i3]][3]      
           km_fim         <- IdContratos[[i3]][4]                     
         } else { 
          km_ini         <- IdContratos[[i3]][4]      
          km_fim         <- IdContratos[[i3]][5]      
         }
             ##Pega os contratos do segmento km_inicial e km_final
             # http://www.dnit.gov.br/busca_contratos_relatorio_medicao?uf=2&rodovia=9%230%2C00&trecho_inicial=0.00&trecho_final=46.35
             URL2 <-paste0("http://www.dnit.gov.br/busca_contratos_relatorio_medicao?uf=",id_uf,"&rodovia=",URLencode(id_rodovia, reserve = TRUE),"&trecho_inicial=",km_ini,"&trecho_final=",km_fim)
             print(URL2)
              page_contratos <- read_html(URL2)    
              IdContratos_2 <- page_contratos %>%
                html_nodes('option') %>%
                html_attr('value')  
              IdContratos_2_ds <- page_contratos %>%
                html_nodes('option') %>%
                html_text()       
           
               for (i4 in 2:length(IdContratos_2)){
                 #print(IdContratos_2[i4])            
                 id_contrato    <- IdContratos_2[i4]
                 cd_contrato    <- IdContratos_2_ds[i4]
                 #      cd_contrato    <- 
                 gr_contratos <- cbind(paste0("id_uf:",id_uf),paste0("sg_uf:",sg_uf),paste0("id_rodovia:",id_rodovia),paste0("sg_rodovia:",sg_rodovia),paste0("id_contrato:",id_contrato),paste0("km_ini:",km_ini),paste0("km_fim:",km_fim), paste0("cd_contrato:",cd_contrato))  
                 nm_arquivo <- "todos_contratos_dbug.csv"     
                 write.table(gr_contratos,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
                 rm(gr_contratos)
                 gr_contratos <- cbind(id_uf,sg_uf,id_rodovia,sg_rodovia,id_contrato,km_ini,km_fim, cd_contrato)  
                 nm_arquivo <- "todos_contratos.csv"     
                 write.table(gr_contratos,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
                 rm(gr_contratos)             
               }        
  
  }
    
}





#https://rpubs.com/NickPTaylor/204298
aContratoaAnos <- read.csv("todos_contratos.csv")


## Busca Anos das Medições 
# http://www.dnit.gov.br/busca_medicoes_relatorio_medicao
# ?uf=2&rodovia=9%230%2C00&idcontrato=5923&trechoInicial=0.00&trechoFinal=46.35  
scraper_ano_contrato <- aContratoaAnos %>%
mutate(id=paste0(sg_uf,"_",sg_rodovia,"_",id_contrato,
                 "_",gsub("[.]","-",km_ini),"_",gsub("[.]","-",km_fim))
       ) %>%
select(id,id_uf,id_rodovia,id_contrato,km_ini,km_fim)
id    <-''
id_uf <-''
sg_uf <-''
id_rodovia <-''
sg_rodovia <-''
id_contrato <-''
cd_contrato <-''
km_ini         <-''
km_fim         <-''
for (i6 in 1:nrow(scraper_ano_contrato)){

  id          <- scraper_ano_contrato[i6,1]
  id_uf       <- scraper_ano_contrato[i6,2]
  id_rodovia  <- URLencode(as.character(scraper_ano_contrato[i6,3]), reserve = TRUE)
  id_contrato <- scraper_ano_contrato[i6,4]
  km_ini      <- as.character(scraper_ano_contrato[i6,5])
  km_fim      <- as.character(scraper_ano_contrato[i6,6])   
    URL <- paste0("http://www.dnit.gov.br/busca_medicoes_relatorio_medicao?uf=",id_uf
                  ,"&rodovia=",id_rodovia,"&idcontrato=",
                  id_contrato,"&trechoInicial=",
                  km_ini,"&trechoFinal=",
                  km_fim)
  #print(URL)
  #download.file( URL,destfile = paste0("dados_scraper_medicoes/",id,".html"), method="libcurl")  
  
  URL_segmentos <- paste0("dados_scraper_medicoes/segmentos/",id,".html")
  page_medicoes_ano <- read_html(URL_segmentos)    
  medicoes_anos <- page_medicoes_ano %>%
    html_nodes('option') %>%
    html_text()  
  for ( i7 in 2:length(medicoes_anos)){
    nr_ano <- medicoes_anos[i7]
    arq_medicao <- paste0("dados_scraper_medicoes/medicoes/",id,"_",nr_ano,".html")
    print(arq_medicao)
    if (!file.exists(arq_medicao)){
      ##Busca Meses das Medições
      # http://www.dnit.gov.br/busca_meses_medicao_relatorio_medicao
      # ?idcontrato=5903&ano=2014
      URL_IdMedicoes <- paste0("http://www.dnit.gov.br/busca_meses_medicao_relatorio_medicao?idcontrato=",id_contrato,"&ano=",nr_ano)
      download.file( URL_IdMedicoes,destfile = arq_medicao, method="libcurl")
     Sys.sleep(2)
      page_id_medicoes <- read_html(arq_medicao)  
      ds_mes_medicoes <- page_id_medicoes %>%
        html_nodes('option') %>%
        html_text() 
      ds_id_medicoes <- page_id_medicoes %>%
        html_nodes('option') %>%
        html_attr('value') 
      qtd <- length(id_medicoes)
      
      tst <- data.frame(cbind(rep(nr_ano,qtd),rep(id_contrato,qtd),rep(id,qtd),ds_mes_medicoes,ds_id_medicoes)) %>%
        filter(ds_mes_medicoes!='Selecione') %>%
        mutate(id_medicoes = gsub(".*idmedicao=","",ds_id_medicoes)) %>%
        select(V3,V2,V1,ds_mes_medicoes,id_medicoes) 
      nm_arquivo <- "medicoes.csv"     
      write.table(tst,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
      rm(tst)   
      
      
    }
  }   
}



aMedicoes_Full <- read.csv("medicoes.csv")

  aMedicoes <- aMedicoes_Full %>%
  group_by(id_contrato,id_medicoes) %>%
  summarise() %>%
  select(unique.id_contrato=id_contrato,unique.id_medicoes=id_medicoes) 

   for ( i1 in 1:nrow(aMedicoes)){
     gr_path     <- "dados_scraper_medicoes/pdf/"
     id_contrato <- aMedicoes[i1,1]
     id_medicao  <- aMedicoes[i1,2]
     nm_arquivo <- paste0(id_contrato,"_",id_medicao,".pdf")
     URL_PDF <- paste0("http://www.dnit.gov.br/emitir_relatorio_medicao?idcontrato=",id_contrato,"&idmedicao=",id_medicao)
     print(nm_arquivo)

      ####
      ## Baixar Relatorios de Medicao
      ##
       if(!file.exists(paste0(gr_path,nm_arquivo))){
         Sys.sleep(1)       
         print("x")
         result <- try({
              curl = getCurlHandle()
              bfile=getBinaryURL (
                URL_PDF,
                curl= curl,
                progressfunction = function(down, up) {print(down)}, noprogress = FALSE
              )
              writeBin(bfile, paste0(gr_path,nm_arquivo))
              rm(curl, bfile)
              }, silent=TRUE)      
       }    

      ###
      ## Tabulando
      ##
        try({
          txt <- pdf_text(paste0(gr_path,nm_arquivo))
          qq<-length(txt)
          pdf_contrato <- txt[qq] %>% 
            str_extract("Contrato.*") 
          b<-txt[qq] %>% 
            str_extract("\\r\\nSOMA.*") %>%
            str_split( "\\s") %>%
            unlist() %>%
            data.frame() %>%
            filter(.!="")
          nm_arquivo <- "medicoes_vl_2.csv"          
          tst<- c(pdf_contrato[1],id_contrato,id_medicao,as.character(b[2,1]),as.character(b[3,1]),as.character(b[4,1]))
          write.table(tst,file=nm_arquivo, append=TRUE,col.names = !file.exists(nm_arquivo),row.names = FALSE,quote = TRUE, sep=",",fileEncoding="UTF-8")
          rm(tst)  
        }, silent=TRUE) 
    
   
   }




  
  
  


