# ==============================================================================
# FIAP - TECNOLOGO EM INTELIGENCIA ARTIFICIAL
# STATISTICAL COMPUTING WITH R & PYTHON - PORTAL 9 (SPRINT 1 - CHALLENGE SEM PARAR)
# TEMA: CONSUMO E EMISSOES DOS VEICULOS LEVES NO BRASIL (INMETRO - PBE VEICULAR 2026)
#
# INTEGRANTES (GRUPO FLEET FORCE):
#   GUSTAVO HENRIQUE LOPES REZENDE
#   JOAO PAULO DIAS VENTURA
#   LUDSON RODRIGO MARCIANO FERNANDES
#   RAFAEL MEDICI
#   VINI DOS SANTOS PEREIRA
#
# FONTE DOS DADOS: INMETRO/CONPET - Tabela PBE Veicular 2026 (veiculos leves)
# FONTE DOS PRECOS: ANP - Levantamento de Precos de Combustiveis, media Brasil,
#                   semana de 18 a 24/10/2026
# ==============================================================================

# Este script usa so funcoes basicas do R (nenhum pacote para instalar).

#----------------------------------

# IMPORTANDO A BASE DE DADOS

getwd()   # a base (arquivo CSV) precisa estar nesta pasta
# Se estiver em outra pasta, tire o # da linha abaixo e coloque o endereco certo:
# setwd("C:/Users/SEU_USUARIO/Downloads/Portal9")

if (!file.exists("base_pbe_veicular_2026.csv")) {
  stop("Nao achei base_pbe_veicular_2026.csv em ", getwd(), ". Use setwd() para a pasta da base.")
}

# A base usa "," como separador e "." como decimal -> read.csv
dados <- read.csv("base_pbe_veicular_2026.csv", header = TRUE, sep = ",", dec = ".",
                  stringsAsFactors = FALSE, fileEncoding = "UTF-8")

head(dados)   # primeiras linhas
nrow(dados)   # quantidade de modelos/versoes
ncol(dados)   # quantidade de colunas

# Pasta onde os resultados (tabelas, graficos e insights) serao gravados
saida <- "saida"
dir.create(saida, showWarnings = FALSE)

#----------------------------------

# PRECOS DOS COMBUSTIVEIS (R$ por litro) - nao fazem parte da base do Inmetro
# ANP, media Brasil, semana de 18 a 24/10/2026 (aba BRASIL do resumo semanal)

# Os precos vem do arquivo anp_precos_2026-10-18_a_24.csv (copiado da planilha oficial da ANP).
# uf_referencia: "BRASIL" (media nacional) ou um estado em maiusculas e sem acento, por exemplo "SAO PAULO"
uf_referencia <- "BRASIL"
arq_anp <- "anp_precos_2026-10-18_a_24.csv"

if (file.exists(arq_anp)) {
  anp <- read.csv(arq_anp, stringsAsFactors = FALSE)
  pega_preco <- function(produto) {
    return(anp$preco_medio[anp$uf == uf_referencia & anp$produto == produto])
  }
  preco_gasolina <- pega_preco("GASOLINA COMUM")   # gasolina comum
  preco_etanol   <- pega_preco("ETANOL HIDRATADO") # etanol hidratado
  preco_diesel   <- pega_preco("OLEO DIESEL S10")  # oleo diesel S10
} else {
  print("Arquivo da ANP nao encontrado: usando os precos medios do Brasil digitados abaixo.")
  anp <- NULL
  preco_gasolina <- 6.49
  preco_etanol   <- 4.11
  preco_diesel   <- 7.32
}
rotulo_preco <- ifelse(uf_referencia == "BRASIL", "media Brasil", paste("media em", uf_referencia))
print(paste("Precos usados (", rotulo_preco, "): gasolina", preco_gasolina, "etanol", preco_etanol, "diesel", preco_diesel))

#----------------------------------

# SEPARANDO AS VARIAVEIS DO TRABALHO
# Qualitativas nominais:   marca e propulsao
# Qualitativas ordinais:   ence_absoluta e ence_relativa (A = melhor, E = pior)
# Quantitativas discretas: n_velocidades e n_valvulas
# Quantitativas continuas: km_l_combinado e co2_fossil_gkm

# A propulsao tem acento (Combustao, Hibrido, Eletrico). Para o codigo funcionar em
# qualquer computador, escolhemos cada nome pela primeira letra: C, H, P e E.
primeira <- substr(dados$propulsao, 1, 1)
niveis <- c(unique(dados$propulsao[primeira == "C"]), unique(dados$propulsao[primeira == "H"]),
            unique(dados$propulsao[primeira == "P"]), unique(dados$propulsao[primeira == "E"]))
nome_comb <- niveis[1]   # combustao
nome_hib  <- niveis[2]   # hibrido

dados$propulsao <- factor(dados$propulsao, levels = niveis)
dados$ence_absoluta <- factor(dados$ence_absoluta, levels = c("A", "B", "C", "D", "E"), ordered = TRUE)
dados$ence_relativa <- factor(dados$ence_relativa, levels = c("A", "B", "C", "D", "E"), ordered = TRUE)

# Conferindo se cada variavel tem 100 ou mais observacoes validas
variaveis <- c("marca", "propulsao", "ence_absoluta", "ence_relativa",
               "n_velocidades", "n_valvulas", "km_l_combinado", "co2_fossil_gkm")
for (v in variaveis) {
  n <- sum(!is.na(dados[[v]]))
  if (n >= 100) {
    print(paste(v, ":", n, "observacoes validas - ok"))
  } else {
    print(paste(v, ":", n, "observacoes validas - ABAIXO DE 100"))
  }
}

#----------------------------------

# FUNCOES QUE VAMOS USAR (moda, assimetria, medidas e frequencia simples)

moda <- function(x) {
  x <- x[!is.na(x)]
  tabela <- table(x)
  return(as.numeric(names(tabela)[which.max(tabela)]))
}

assimetria <- function(x) {
  x <- x[!is.na(x)]
  return(mean((x - mean(x))^3) / sd(x)^3)
}

medidas <- function(x) {
  x <- x[!is.na(x)]
  q <- quantile(x, c(0.25, 0.75), names = FALSE)
  return(c(n = length(x), media = mean(x), mediana = median(x), moda = moda(x),
           dp = sd(x), cv_pct = 100 * sd(x) / mean(x), minimo = min(x),
           q1 = q[1], q3 = q[2], maximo = max(x), assimetria = assimetria(x)))
}

freq_simples <- function(x, acumulada = FALSE) {
  tabela <- table(x)
  fi <- as.numeric(tabela)
  r <- data.frame(valor = names(tabela), fi = fi, fr = round(fi / sum(fi), 4),
                  fr_pct = round(100 * fi / sum(fi), 2))
  if (acumulada) {
    r$Fi <- cumsum(r$fi)
    r$Fr_pct <- round(100 * cumsum(r$fi) / sum(r$fi), 2)
  }
  return(r)
}

#----------------------------------

# MEDIDAS DESCRITIVAS DAS QUATRO VARIAVEIS QUANTITATIVAS

md <- as.data.frame(t(sapply(list(n_velocidades = dados$n_velocidades,
                                  n_valvulas = dados$n_valvulas,
                                  km_l_combinado = dados$km_l_combinado,
                                  co2_fossil_gkm = dados$co2_fossil_gkm), medidas)))
md <- cbind(variavel = rownames(md), round(md, 3))
print(md)
write.csv(md, file.path(saida, "medidas_descritivas.csv"), row.names = FALSE, fileEncoding = "UTF-8")

#----------------------------------

# TABELA DE FREQUENCIAS - VARIAVEL DISCRETA (n_velocidades)

x_vel <- dados$n_velocidades[!is.na(dados$n_velocidades)]
freq_vel <- freq_simples(x_vel, acumulada = TRUE)
print(freq_vel)
write.csv(freq_vel, file.path(saida, "frequencias_n_velocidades.csv"), row.names = FALSE, fileEncoding = "UTF-8")

#----------------------------------

# TABELA DE FREQUENCIAS - VARIAVEL CONTINUA (km_l_combinado), CLASSES PELA REGRA DE STURGES

x <- dados$km_l_combinado[!is.na(dados$km_l_combinado)]
k <- ceiling(1 + 3.322 * log10(length(x)))                  # numero de classes
h <- ceiling(((max(x) - min(x)) / k) * 10) / 10             # amplitude de cada classe
limites <- min(x) + h * (0:k)
classes <- cut(x, breaks = limites, right = FALSE, include.lowest = TRUE)
fi <- as.numeric(table(classes))
freq_kml <- data.frame(classe = sprintf("%.1f |- %.1f", limites[-(k + 1)], limites[-1]),
                       xi = round((limites[-(k + 1)] + limites[-1]) / 2, 2),   # ponto medio
                       fi = fi, fr_pct = round(100 * fi / sum(fi), 2),
                       Fi = cumsum(fi), Fr_pct = round(100 * cumsum(fi) / sum(fi), 2))
print(freq_kml)
write.csv(freq_kml, file.path(saida, "frequencias_km_l_combinado.csv"), row.names = FALSE, fileEncoding = "UTF-8")

#----------------------------------

# VARIAVEIS QUALITATIVAS (marca, propulsao, ENCE absoluta e ENCE relativa)

freq_marca <- freq_simples(dados$marca)
freq_marca <- freq_marca[order(-freq_marca$fi), ]
dez_maiores <- head(freq_marca, 10)
outras <- data.frame(valor = "Outras", fi = sum(freq_marca$fi[-(1:10)]), fr = NA, fr_pct = NA)
outras$fr <- round(outras$fi / sum(freq_marca$fi), 4)
outras$fr_pct <- round(100 * outras$fi / sum(freq_marca$fi), 2)
write.csv(rbind(dez_maiores, outras), file.path(saida, "frequencias_marca.csv"), row.names = FALSE, fileEncoding = "UTF-8")

write.csv(freq_simples(dados$propulsao), file.path(saida, "frequencias_propulsao.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(freq_simples(dados$ence_absoluta, acumulada = TRUE), file.path(saida, "frequencias_ence_absoluta.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(freq_simples(dados$ence_relativa, acumulada = TRUE), file.path(saida, "frequencias_ence_relativa.csv"), row.names = FALSE, fileEncoding = "UTF-8")

print(freq_simples(dados$propulsao))
print(freq_simples(dados$ence_absoluta, acumulada = TRUE))

#----------------------------------

# COMPARATIVOS: combustao x hibrido e faixas da ENCE absoluta (so quem tem km/l)

comb <- dados[(dados$propulsao %in% c(nome_comb, nome_hib)) & !is.na(dados$km_l_combinado), ]

por_prop <- aggregate(km_l_combinado ~ propulsao, data = comb,
                      FUN = function(v) c(n = length(v), media = mean(v), mediana = median(v)))
por_prop <- do.call(data.frame, por_prop)
print(por_prop)
write.csv(por_prop, file.path(saida, "km_l_por_propulsao.csv"), row.names = FALSE, fileEncoding = "UTF-8")

por_ence <- aggregate(cbind(km_l_combinado, co2_fossil_gkm) ~ ence_absoluta, data = comb,
                      FUN = function(v) round(mean(v), 2))
print(por_ence)
write.csv(por_ence, file.path(saida, "medias_por_ence_absoluta.csv"), row.names = FALSE, fileEncoding = "UTF-8")

#----------------------------------

# CUSTO DE COMBUSTIVEL POR KM (R$/km) = preco do litro / km por litro
# G = gasolina, F = flex, D = diesel. Nos flex tambem calculamos com etanol.

dados$custo_km_gasolina <- ifelse(dados$combustivel %in% c("G", "F") & !is.na(dados$km_l_combinado),
                                  preco_gasolina / dados$km_l_combinado, NA)
dados$custo_km_etanol <- ifelse(dados$combustivel == "F" & !is.na(dados$km_l_etanol_combinado),
                                preco_etanol / dados$km_l_etanol_combinado, NA)
dados$custo_km_diesel <- ifelse(dados$combustivel == "D" & !is.na(dados$km_l_combinado),
                                preco_diesel / dados$km_l_combinado, NA)

resumo_custo <- function(nome, v) {
  v <- v[!is.na(v)]
  return(data.frame(grupo = nome, n = length(v), mediana_rs_km = round(median(v), 3),
                    media_rs_km = round(mean(v), 3), q1 = round(quantile(v, 0.25, names = FALSE), 3),
                    q3 = round(quantile(v, 0.75, names = FALSE), 3)))
}
flex_ok <- dados$combustivel == "F" & !is.na(dados$custo_km_etanol)
custo <- rbind(resumo_custo("Gasolina (G e F)", dados$custo_km_gasolina),
               resumo_custo("Etanol (flex)", dados$custo_km_etanol),
               resumo_custo("Gasolina nos mesmos flex", dados$custo_km_gasolina[flex_ok]),
               resumo_custo("Diesel S10 (D)", dados$custo_km_diesel))
print(custo)
write.csv(custo, file.path(saida, "custo_por_km.csv"), row.names = FALSE, fileEncoding = "UTF-8")

flex <- dados[dados$combustivel == "F" & !is.na(dados$custo_km_gasolina) & !is.na(dados$custo_km_etanol), ]
pct_etanol <- round(100 * mean(flex$custo_km_etanol < flex$custo_km_gasolina), 1)
razao_km <- median(flex$km_l_etanol_combinado / flex$km_l_combinado)
paridade <- round(100 * preco_etanol / preco_gasolina, 1)

#----------------------------------

# NUMEROS EXTRAS CITADOS NO RELATORIO (desvio padrao, CO2 por propulsao e etanol x gasolina)

dp_prop <- aggregate(km_l_combinado ~ propulsao, data = comb, FUN = sd)
names(dp_prop)[2] <- "dp_km_l"
print(dp_prop)
write.csv(dp_prop, file.path(saida, "dp_km_l_por_propulsao.csv"), row.names = FALSE, fileEncoding = "UTF-8")

co2_prop <- aggregate(co2_fossil_gkm ~ propulsao, data = dados, FUN = median)
names(co2_prop)[2] <- "mediana_co2_gkm"
print(co2_prop)
write.csv(co2_prop, file.path(saida, "mediana_co2_por_propulsao.csv"), row.names = FALSE, fileEncoding = "UTF-8")

# razao entre o km/l do etanol e o da gasolina em cada flex
razao <- flex$km_l_etanol_combinado / flex$km_l_combinado
print(paste("razao etanol/gasolina: minimo", round(100 * min(razao), 1), "% e maximo", round(100 * max(razao), 1), "%"))

# preco do etanol / preco da gasolina em cada estado (arquivo da ANP): abaixo de 70% o etanol costuma compensar
paridade_uf <- NULL
if (!is.null(anp)) {
  est <- anp[anp$nivel == "ESTADO", ]
  gas_uf <- est[est$produto == "GASOLINA COMUM", c("uf", "preco_medio")]
  eta_uf <- est[est$produto == "ETANOL HIDRATADO", c("uf", "preco_medio")]
  paridade_uf <- merge(gas_uf, eta_uf, by = "uf", suffixes = c("_gasolina", "_etanol"))
  paridade_uf$paridade_pct <- round(100 * paridade_uf$preco_medio_etanol / paridade_uf$preco_medio_gasolina, 2)
  paridade_uf <- paridade_uf[order(paridade_uf$paridade_pct), ]
  print(paridade_uf)
  write.csv(paridade_uf, file.path(saida, "etanol_gasolina_por_uf.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  print(paste(nrow(paridade_uf), "estados com preco de etanol;", sum(paridade_uf$paridade_pct >= 70), "com paridade de 70% ou mais"))
}

# o etanol sai mais barato por km quando (preco do etanol / preco da gasolina) < razao de km/l do modelo
pct_vantagem <- function(paridade_preco) {
  return(round(100 * mean(razao > paridade_preco), 1))
}
paridades <- data.frame(referencia = paste(rotulo_preco, "(ANP 18 a 24/10/2026)"),
                        paridade_pct = round(100 * preco_etanol / preco_gasolina, 1))
if (!is.null(paridade_uf)) {
  menor <- paridade_uf[1, ]
  maior <- paridade_uf[nrow(paridade_uf), ]
  paridades <- rbind(paridades, data.frame(referencia = menor$uf, paridade_pct = round(menor$paridade_pct, 1)),
                     data.frame(referencia = maior$uf, paridade_pct = round(maior$paridade_pct, 1)))
}
paridades$flex_com_vantagem_pct <- sapply(paridades$paridade_pct / 100, pct_vantagem)
print(paridades)
write.csv(paridades, file.path(saida, "etanol_vantagem_por_paridade.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(data.frame(razao_min_pct = round(100 * min(razao), 1), razao_max_pct = round(100 * max(razao), 1),
                     razao_mediana_pct = round(100 * median(razao), 1)),
          file.path(saida, "razao_km_etanol_gasolina.csv"), row.names = FALSE, fileEncoding = "UTF-8")

#----------------------------------

# GRAFICOS

png(file.path(saida, "grafico_ence_absoluta.png"), 900, 600)
barplot(table(dados$ence_absoluta), col = c("#2e7d32", "#7cb342", "#fdd835", "#fb8c00", "#d32f2f"),
        main = "Modelos por classificacao ENCE absoluta (A melhor, E pior)",
        xlab = "ENCE absoluta", ylab = "Modelos/versoes")
dev.off()

png(file.path(saida, "grafico_hist_km_l.png"), 900, 600)
hist(x, breaks = limites, col = "#1f5e8e", border = "white",
     main = "Consumo combinado (km/l, gasolina ou diesel)", xlab = "km/l", ylab = "Modelos/versoes")
dev.off()

png(file.path(saida, "grafico_box_km_l_propulsao.png"), 900, 600)
boxplot(km_l_combinado ~ droplevels(propulsao), data = comb, col = c("#8aa4b8", "#1f5e8e"),
        main = "km/l combinado: combustao x hibrido", xlab = "Propulsao", ylab = "km/l")
dev.off()

#----------------------------------

# INSIGHTS PARA A DECISAO (gravados em insights.txt)

med_c <- median(comb$km_l_combinado[comb$propulsao == nome_comb])
med_h <- median(comb$km_l_combinado[comb$propulsao == nome_hib])
c_km_c <- preco_gasolina / med_c
c_km_h <- preco_gasolina / med_h
pct_ab <- round(100 * mean(dados$ence_absoluta %in% c("A", "B")), 1)
pct_de <- round(100 * mean(dados$ence_absoluta %in% c("D", "E")), 1)

insights <- c(
  sprintf("Base real do Inmetro: %d modelos/versoes validos de %d marcas; %d tem km/l informado (faltam eletricos, modelos E100 e poucas versoes sem esse dado na tabela).", nrow(dados), length(unique(dados$marca)), length(x)),
  sprintf("Consumo combinado mediano de %.1f km/l (coluna gasolina ou diesel da tabela); metade dos modelos fica entre %.1f e %.1f km/l.", median(x), quantile(x, 0.25), quantile(x, 0.75)),
  sprintf("Hibridos rodam em mediana %.1f km/l contra %.1f km/l dos modelos a combustao.", med_h, med_c),
  sprintf("Com a gasolina comum a R$ %.2f/l (%s, ANP, semana de 18 a 24/10/2026), o custo de combustivel por km e de R$ %.3f no modelo a combustao mediano e R$ %.3f no hibrido mediano.", preco_gasolina, rotulo_preco, c_km_c, c_km_h),
  sprintf("Nos %d modelos flex com km/l nos dois combustiveis, o etanol (R$ %.2f/l na ANP) sai mais barato por km em %.1f%% deles: o etanol rende em mediana %.0f%% do km/l da gasolina e o preco dele esta em %.1f%% do da gasolina.", nrow(flex), preco_etanol, pct_etanol, 100 * razao_km, paridade),
  sprintf("%.1f%% dos modelos estao nas faixas A e B da ENCE absoluta e %.1f%% nas faixas D e E: a etiqueta serve de filtro rapido na compra de frota.", pct_ab, pct_de),
  sprintf("O CO2 fossil mediano e de %.0f g/km; a dispersao e alta (CV de %.0f%%), entao escolher o modelo muda bastante a emissao da frota.", median(dados$co2_fossil_gkm, na.rm = TRUE), md$cv_pct[md$variavel == "co2_fossil_gkm"]),
  "Limite: os valores sao de ensaio padronizado de laboratorio e cobrem so veiculos leves; o consumo real da frota depende de carga, rota e condutor."
)
writeLines(insights, file.path(saida, "insights.txt"), useBytes = TRUE)
cat(insights, sep = "\n")
