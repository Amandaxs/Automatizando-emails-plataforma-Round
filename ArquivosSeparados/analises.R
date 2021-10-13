############ Carregando pacotes nescessários
library(tidyverse)
library(flextable)
library(webshot)
library(wordcloud2)
library(tm)
library("htmlwidgets")
library(stringr)
library (RDCOMClient)

############### Lendo o banco de dados ##############
dados <- readRDS(file = "data/dadosJulhoASetembro.rds")
user = "amanda.xavier@dtidigital.com.br"


### Data frame de moedas doadas
dfdoados<- dados %>%
  filter(senderEmail == user) %>%
  mutate(quantity = as.numeric(quantity))
    
### data frame de moedas recebidas
dfrecebido<- dados %>%
  filter(receiverEmail == user)%>% 
  mutate(quantity = as.numeric(quantity))

## Pegando o nome da pessoa
nome =str_extract(max(dfrecebido$receiverName), "[^ ]+ [^ ]+")
nome
## Tabela com o top3 doados
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
# Vendo a tabela de resultado
top3doados
# Salvando como imagem
save_as_image(top3doados, path = "top3d.png")
    
## Tabela com o top3 recebidos
top3recebidos <- dfrecebido %>% 
  select(senderName, quantity) %>%
  filter(senderName != "Usuário Inativo" & senderName != "Plataforma Round")%>%
  group_by(senderName) %>%
  summarise(quantity = sum(quantity)) %>%
  arrange(desc(quantity)) %>% 
  rename(Nome = senderName , Quantidade = quantity ) %>%
  head(3)%>% 
  flextable() %>%
  autofit()
# Vendo a tabela
top3recebidos
# Salvando a tabela
save_as_image(top3recebidos, path = "top3r.png")
    
## Contando  pessoas e moedas

## Total de moedas recebidas
moedasrecebidas <- sum(dfrecebido$quantity)
moedasrecebidas
## Total de pessoas que doaram moedas
pessoasrecebidas <- n_distinct(dfrecebido$senderEmail)
pessoasrecebidas
## Total de pessoas para quem foram doadas moedas
pessoasdoadas <- n_distinct(dfdoados$receiverEmail)
pessoasdoadas
## Total de moedas doadas
moedasdoadas <- sum(dfdoados$quantity)
moedasdoadas

    
    
#################  Criando nuvem de palavras
    
text <- as.character( dfrecebido$reason) 
## Tirando a msg padrão da round
text <- text[text != "Parabéns por você ter doado todas suas moedas esse mês!"]
#Fazendo a limpesa nas palavras
docs <- Corpus(VectorSource(text))
docs <- docs %>%
  tm_map(removeNumbers) %>% ## tira numero
  tm_map(removePunctuation) %>% # tira pontuação
  tm_map(stripWhitespace)
docs <- tm_map(docs, content_transformer(tolower)) ## coloca tudo em minusculo
docs <- tm_map(docs, removeWords, stopwords("portuguese")) # tira stopwords
dtm <- TermDocumentMatrix(docs) 
matrix <- as.matrix(dtm)  # faz uma matriz com as plavras
words <- sort(rowSums(matrix),decreasing=TRUE)   # conta
df <- data.frame(word = names(words),freq=words) # tansforma num DF
    
## criando a nuvem de palavras
word <- wordcloud2(data=df, color='random-dark')
word
    
    
## Salvando a wordcloud
saveWidget(word,"tmp.html",selfcontained = F)
# and in png or pdf
webshot("tmp.html","wordcl.png", delay =5, vwidth = 480, vheight=480)
    
    

