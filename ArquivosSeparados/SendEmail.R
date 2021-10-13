#install.packages("RDCOMClient", repos = "http://www.omegahat.net/R")

library (RDCOMClient)
Outlook <- COMCreate("Outlook.Application")
Email = Outlook$CreateItem(0)
Email[["to"]] = "amanda.xavier@dtidigital.com.br"
Email[["cc"]] = ""
Email[["bcc"]] = ""
Email[["importance"]] = "2"
Email[["subject"]] = "TESTE 1 MVP Moedas"
Email[["body"]] = 
  "Primeira versão só pra testar o uso de imagem e mandar o email via código"
Email[["attachments"]]$Add("C:\\Users\\DPCDTI\\Desktop\\Automatizando-emails-plataforma-Round\\top3d.png")
Email[["attachments"]]$Add("C:\\Users\\DPCDTI\\Desktop\\Automatizando-emails-plataforma-Round\\top3r.png")
#C:\Users\DPCDTI\Desktop\Automatizando-emails-plataforma-Round
Email$Send()
rm(Outlook, Email)
