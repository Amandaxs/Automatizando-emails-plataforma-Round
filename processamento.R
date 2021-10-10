### Tratamento de dados
library(rjson)
library(tidyverse)

### Função para extrair dados
extracao <- function(file){
## Lendo o arquivo json e extraindo a parte de transactions
dados <- fromJSON(file = file)[['transactions']]


## Extraindo as colunas que estavam dentro de outras
dados2<- data.frame(Reduce(rbind, dados)) %>%
  unnest_wider(sender,names_repair = "unique") %>%
  rename(senderEmail = "email", senderId = "_id", senderName = "name",
         SenderUserAvatar = "user_avatar", senderDepart = "depart",
         SenderPosition = "position", Senderwallet = "wallet",
         senderActive = "active") %>%
    unnest_wider(receiver, names_repair = "unique")%>%
  rename(receiverEmail = "email", receiverId = "_id", receiverName = "name",
         receiverUserAvatar = "user_avatar", receiverDepart = "depart",
         receiverPosition = "position", receiverwallet = "wallet",
         receiverActive = "active")
return(dados2)
}


### Extraindo dados de cada mês
julho <- extracao("data/julho.json")
agosto <- extracao("data/agosto.json")
setembro <- extracao("data/setembro.json")
#setembro <- setembro[,1:24]

## Juntando os dados dos meses
dadosJulhoASetembro<- union( julho, agosto) %>% 
  union(setembro)

### Salvando os dados
saveRDS(dadosJulhoASetembro, file = "data/dadosJulhoASetembro.rds")
# Restore the object
#readRDS(file = "joinedData.rds")


## Selecionando as pessoas que vão receber o email

# Pessoas da tribo dataflix que doaram
sen = setembro %>% filter( senderDepart == 'RACKERS - DATAFLIX' )
## Pessoas da tribo dataflix que receberam
rec = setembro %>% filter( receiverDepart == 'RACKERS - DATAFLIX' )
## Algumas pessoas específicas que não estão na lista da tribo dataflix
especificos <- c("isadora.fernandes@dtidigital.com.br", 
                 "raphael.louzada@dtidigital.com.br",
                 "gabrielle.braga@dtidigital.com.br",
                 "daniela.santos@dtidigital.com.br",
                 "matheus.miranda@dtidigital.com.br",
                 "gustavo.moreira@dtidigital.com.br",
                 "gustavo.lemos@dtidigital.com.br",
                 "alan.silveira@dtidigital.com.br")
## Tirando duplicados
l1 <- unique(sen$senderEmail)
l2 <- unique(rec$receiverEmail)
## Juntando tudo e tirando duplciados
listaenvio <- c(l1,l2,especificos) %>% unique()
##  Salvando a lista
saveRDS(listaenvio, "envioMVp.rds")

