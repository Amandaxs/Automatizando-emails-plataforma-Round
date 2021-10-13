############ Lendo o json
library(tidyverse)
library(flextable)
library(webshot)
library(wordcloud2)
library(tm)
library("htmlwidgets")
library(stringr)
library (RDCOMClient)
library(magick)
############### Lendo o banco de dados ##############
dados <- readRDS(file = "data/dadosJulhoASetembro.rds")
#user = "amanda.xavier@dtidigital.com.br"

AnaliseDados <- function(user){
  ### Moedas doadas
  dfdoados<- dados %>%
    filter(senderEmail == user) %>%
    mutate(quantity = as.numeric(quantity))
  
  ### Moedas recebidas
  dfrecebido<- dados %>%
    filter(receiverEmail == user)%>% 
    mutate(quantity = as.numeric(quantity))
  
  nome =str_extract(max(dfrecebido$receiverName), "[^ ]+ [^ ]+")
  
  # Top 3 doados
  
  top3doados <- dfdoados %>% 
    select(receiverName, quantity) %>%
    filter(receiverName != "Usuário Inativo" | receiverName != "Plataforma Round")%>%
    group_by(receiverName) %>%
    summarise(quantity = sum(quantity)) %>%
    arrange(desc(quantity)) %>% 
    rename(Nome = receiverName, Quantidade = quantity ) %>%
    arrange(desc(Quantidade)) %>% 
    head(3) %>% 
    flextable::flextable() %>% autofit()
  top3doados
  save_as_image(top3doados, path = "top3d.png")
  
  #####
  
  top3recebidos <- dfrecebido %>% 
    select(senderName, quantity) %>%
    filter(senderName != "Usuário Inativo" & senderName != "Plataforma Round")%>%
    group_by(senderName) %>%
    summarise(quantity = sum(quantity)) %>%
    arrange(desc(quantity)) %>% 
    rename(Nome = senderName , Quantidade = quantity ) %>%
    head(3)%>% 
    flextable::flextable() %>%
    autofit()
  top3recebidos
  save_as_image(top3recebidos, path = "top3r.png")
  
  ## Contando  pessoas e moedas
  
  moedasrecebidas <- sum(dfrecebido$quantity)
  pessoasdoadas <- n_distinct(dfdoados$receiverEmail)
  moedasdoadas <- sum(dfdoados$quantity)
  pessoasrecebidas <- n_distinct(dfrecebido$senderEmail)
  
  
  #################  Criando nuvem de palavras
  
  text <- as.character( dfrecebido$reason) 
  text <- text[text != "Parabéns por você ter doado todas suas moedas esse mês!"]
  #install.packages("wordcloud2")
  docs <- Corpus(VectorSource(text))
  docs <- docs %>%
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace)
  docs <- tm_map(docs, content_transformer(tolower))
  docs <- tm_map(docs, removeWords, stopwords("portuguese"))
  dtm <- TermDocumentMatrix(docs) 
  matrix <- as.matrix(dtm) 
  words <- sort(rowSums(matrix),decreasing=TRUE) 
  df <- data.frame(word = names(words),freq=words)
  
  
  word <- wordcloud2(data=df, color='random-dark')
  word
  
  saveWidget(word,"tmp.html",selfcontained = F)
  
  # and in png or pdf
  webshot("tmp.html","wordcl.png", delay =5, vwidth = 480, vheight=480)
  
  

  
  top3d<- image_read("top3D.png") %>% image_scale("900")
  top3r<- image_read("top3R.png")%>% image_scale("900")
  wordcl <- image_read("wordcl.png") %>% image_scale("770")
  
  
  
  fundo <- image_read("imagens/mvp_round_1.png")
  fundo2 <- image_read("imagens/mvp_round_2.png")
  #fundo <- image_scale(fundo, "300")
  textoteste<- "teste"
  cartaz1<-  image_annotate(fundo , nome, 
                            size = 65, color = "#ea268b",
                            location = "+320+230" )%>%
    image_annotate( moedasrecebidas, 
                    size = 50, color = "#ea268b",
                    location = "+200+463" )%>%
    
    image_annotate( moedasdoadas, 
                    size = 50, color = "#ea268b",
                    location = "+510+715" ) %>%
    
    image_annotate( pessoasrecebidas, 
                    size = 50, color = "#3c3691",
                    location = "+200+550" )  %>%
    
    image_annotate( pessoasdoadas, 
                    size = 50, color = "#3c3691",
                    location = "+575+805" ) %>%
    
    image_composite( top3r, offset = "+115+1000") %>%
    
    image_composite( top3d, offset = "+115+1440")
  
    image_write(cartaz1, path = "Resumo.png", format = "png")
    
    
    cartaz2 <- image_composite(fundo2,wordcl ,offset ="+150+575")
    image_write(cartaz2, path = "Nuvem.png", format = "png")
    
  #cartaz
 
  
  Outlook <- COMCreate("Outlook.Application")
  Email = Outlook$CreateItem(0)
  Email[["to"]] = user
  Email[["cc"]] = ""
  Email[["bcc"]] = ""
  Email[["importance"]] = "2"
  Email[["subject"]] = "Resumo Round nos ultimos 3 meses"
  Email[["body"]] = 
    "Bom dia!!
    
    Você está recebendo um resumo das suas moedas doadas e recebidas na plataforma ROUND nos meses Julho, agosto e Setembro.
    Este resumo ainda é um um MVP, portanto se tiver algo estranho ou tiver alguma sugestão, entra em contato comigo :).
    
    Obrigada!
"
  Email[["attachments"]]$Add("C:\\Users\\DPCDTI\\Desktop\\Automatizando-emails-plataforma-Round\\Resumo.png")
  Email[["attachments"]]$Add("C:\\Users\\DPCDTI\\Desktop\\Automatizando-emails-plataforma-Round\\Nuvem.png")
  Email$Send()
  rm(Outlook, Email) 
  message = paste("email enviado para: ", user)
  print(message)
  file.remove("wordcl.png")
  file.remove("top3d.png")
  file.remove("top3r.png")
  file.remove("Resumo.png")
  file.remove("Nuvem.png")
  
}

#####################################################################
########################  FIltrar ususarios inativos e round ######
######################################################################
options(warn=-1)
#user = "amanda.xavier@dtidigital.com.br"
#AnaliseDados(user)


#emails <- readRDS("envioMVP.rds")


system.time({
  teste <- c("amanda.xavier@dtidigital.com.br", "amanda02.x@gmail.com" , "amanda.xavier@dtidigital.com.br" )

for( i in teste){
  tryCatch({
      AnaliseDados(i)} , error = function(msg){
    message(paste("Erro com o email:", i))}) 
}
  
})

