library("RCurl")
ufs<-read.csv("UFs.csv")
#ufs<-unlist(ufs)
for ( i in 1:nrow(ufs)){
     #URL <- "http://servicos.dnit.gov.br/arcgis/rest/services/dynatest/contratos/MapServer/0/query?where=UF_ESTADO%3D%27DF%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=kmz"
     nm_uf<- ufs[i,1]
  if(!file.exists(paste0("./dados_scraper/",nm_uf,".json"))){
    URL <- paste0("http://servicos.dnit.gov.br/arcgis/rest/services/dynatest/contratos/MapServer/0/query?where=UF_ESTADO%3D%27",nm_uf,"%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")
#    print(nm_uf)    
#     #Dividir extração MG      
#    URL <- paste0("http://servicos.dnit.gov.br/arcgis/rest/services/dynatest/contratos/MapServer/0/query?where=UF_ESTADO%3D%27",nm_uf,"%27+and+id_interve+in+%28%2717%27%2C%276%27%29&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")
#     #where=UF_ESTADO%3D%27MG%27+and+id_interve+not+in+%28%2717%27%2C%276%27%29
    curl = getCurlHandle()
    bfile=getBinaryURL (
      URL,
      curl= curl,
      progressfunction = function(down, up) {print(down)}, noprogress = FALSE
    )
    writeBin(bfile, paste0(nm_uf,".json"))    
    #rm(curl, bfile)   
    
  }

}     

