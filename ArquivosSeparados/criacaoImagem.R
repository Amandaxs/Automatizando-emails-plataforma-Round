library(magick)

#### as moedas doadas , recebidas e numero de pessoas foram calculados no script de analises
## Imagens que foram salvas no script de analises
top3d<- image_read("top3d.png") %>% image_scale("900")
top3r<- image_read("top3r.png")%>% image_scale("900")
wordcl <- image_read("wordcl.png") %>% image_scale("770")
## Carregando os fundos
fundo <- image_read("imagens/mvp_round_1.png")
fundo2 <- image_read("imagens/mvp_round_2.png")
#fundo <- image_scale(fundo, "300")

########### Ciação da imagem 1
## Colocando o nome
image_annotate(fundo , nome, 
    size = 65, color = "#ea268b",
    location = "+320+230" )%>%
  ## inserindo a quantidade de moedas recebida
  image_annotate( moedasrecebidas, 
    size = 50, color = "#ea268b",
                  location = "+200+463" )%>%
  ## inserindo a quantidade de moedas doadas
  image_annotate( moedasdoadas, 
                  size = 50, color = "#ea268b",
                  location = "+510+715" ) %>%
  ## inserindo a quandidade de pessoas que doaram  
  image_annotate( pessoasrecebidas, 
                    size = 50, color = "#3c3691",
                    location = "+200+550" )  %>%
  ## inserindo a quantidade de pessoas para quem doou  
  image_annotate( pessoasdoadas, 
                    size = 50, color = "#3c3691",
                    location = "+575+805" ) %>%
  ##  Inserindo imagem do top3 recebidos
  image_composite( top3r, offset = "+115+1000") %>%
  ##  Inserindo imagem do top3 doados
  image_composite( top3d, offset = "+115+1440")

  
  
  
##### Criando a imagem com a nuvem de palavras
  
image_composite(fundo2,wordcl ,offset ="+150+575")



