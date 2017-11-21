#library("stringr")
#library("jsonlite")
library("httr")
#library("rvest")
Sys.setenv(LANG = "pt_BR.UTF-8")

# url <- "http://veiculos.fipe.org.br/api/veiculos/ConsultarValorComTodosParametros"
# tst %>%
# httr::POST(
#   url,
#   encode="form",
#   httr::add_headers(Referer = "http://veiculos.fipe.org.br/"),
#   body = list(
#     codigoTabelaReferencia = "215",
#     codigoMarca = "2",
#     codigoModelo = "4564",
#     codigoTipoVeiculo = "1",
#     anoModelo = "2015",
#     codigoTipoCombustivel = "3",
#     tipoVeiculo = "carro",
#     modeloCodigoExterno = "",
#     tipoConsulta = "tradicional"
#   )
# ) %>% 
#   httr::content()
# 
# httr::POST('https://api.hipchat.com/v2/rooms/room_id/notification?auth_token=token',
#            body = list(message = jsonlite::unbox('hello everyone') ), encode = 'json')

req <- httr::POST('http://servicos.dnit.gov.br/segmentador/api/values',
           add_headers("Content-Type" = "application/json"),
           body = '{ "uf":"SP", "br":"101", "tipo":"B" ,"km_inicial":"42.6" ,"km_final":"43","data":"01/09/2017"   }', 
           httr::content_type_json()) 
json <- httr::content(req, as = "text")

write(json,file="test.json",append = FALSE)

tst <- fromJSON(json)
tst$Retorno$type
tst$Retorno$coordinates
t<-paste0("{\"type\":\"",tst$Retorno$type,"\",\"coordinates\":",toJSON(tst$Retorno$coordinates),"}")

##httr
#https://pt.stackoverflow.com/questions/220833/post-request-com-httr-n%C3%A3o-completa-site-tabela-fipe
#http://curso-r.com/blog/2017/05/19/2017-05-19-scrapper-ssp/

##Referencia
#https://cran.r-project.org/web/packages/jsonlite/vignettes/json-apis.html
#http://geojsonlint.com/
#http://geojson.org/
#http://geojson.io
#https://rstudio.github.io/leaflet/json.html
#http://mundogeo.com/blog/2008/05/31/ogc-aprova-o-formato-de-arquivo-kml-como-padrao-aberto-2/
