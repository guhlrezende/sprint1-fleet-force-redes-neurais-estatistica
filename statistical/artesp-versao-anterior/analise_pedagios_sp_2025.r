# Analise exploratoria: volume de veiculos nas pracas de pedagio das rodovias concedidas de SP, 2025.
#
# Fonte dos dados: ARTESP, Dados Abertos (https://dadosabertos.artesp.sp.gov.br/dataset/volume-de-trafego),
# licenca Creative Commons Atribuicao. A base de analise (base_pedagios_sp_2025.csv) e gerada pelo
# script preparar_base_artesp.r, com uma linha por dia, praca e sentido.
#
# Uso:
#   Rscript analise_pedagios_sp_2025.r <base_pedagios_sp_2025.csv> <pasta_de_saida>
#
# O que faz:
#   1. tabela de distribuicao de frequencias de 1 variavel discreta (veiculos_pesados)
#      e de 1 continua (pct_tag), em classes pela regra de Sturges;
#   2. tabelas de frequencia das variaveis qualitativas;
#   3. medidas de tendencia central, dispersao e separatrizes das 4 variaveis quantitativas;
#   4. os numeros usados nos insights do relatorio (insights.txt) e dois histogramas.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Uso: Rscript analise_pedagios_sp_2025.r <base.csv> <pasta_saida>")
entrada <- args[1]
saida <- args[2]
dir.create(saida, showWarnings = FALSE, recursive = TRUE)

base <- read.csv(entrada, encoding = "UTF-8", stringsAsFactors = FALSE)
base$trimestre <- factor(base$trimestre, levels = c("T1", "T2", "T3", "T4"), ordered = TRUE)
base$faixa_volume <- factor(base$faixa_volume,
                            levels = c("1 Baixo", "2 Médio", "3 Alto", "4 Muito alto"), ordered = TRUE)
n <- nrow(base)

# ---------------------------------------------------------------- funcoes
fmt <- function(x, d = 2) format(round(x, d), big.mark = ".", decimal.mark = ",", nsmall = d, trim = TRUE)

# tabela de distribuicao de frequencias em classes [a, b), amplitude pela regra de Sturges
fmtn <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)

tabela_classes <- function(x, discreta = FALSE) {
  k <- ceiling(1 + 3.322 * log10(length(x)))
  amplitude <- (max(x) - min(x)) / k
  amplitude <- if (discreta) ceiling(amplitude) else ceiling(amplitude * 10) / 10
  cortes <- min(x) + amplitude * (0:k)
  if (max(x) >= cortes[k + 1]) cortes <- c(cortes, cortes[k + 1] + amplitude)
  classe <- cut(x, breaks = cortes, right = FALSE, include.lowest = TRUE)
  fi <- as.vector(table(classe))
  d <- if (discreta) 0 else 1
  data.frame(
    classe = paste0(fmt(cortes[-length(cortes)], d), " |-- ", fmt(cortes[-1], d)),
    fi = fi,
    fr_pct = round(100 * fi / sum(fi), 2),
    Fi = cumsum(fi),
    Fr_pct = round(100 * cumsum(fi) / sum(fi), 2)
  )
}

tabela_simples <- function(x) {
  fi <- table(x)
  data.frame(categoria = names(fi), fi = as.vector(fi),
             fr_pct = round(100 * as.vector(fi) / sum(fi), 2),
             Fi = cumsum(as.vector(fi)), Fr_pct = round(100 * cumsum(as.vector(fi)) / sum(fi), 2))
}

moda <- function(x, casas) {
  v <- round(x, casas)
  tb <- table(v)
  as.numeric(names(tb)[which.max(tb)])
}

medidas <- function(x, casas = 2) {
  q <- quantile(x, c(.01, .05, .10, .20, .25, .30, .40, .50, .60, .70, .75, .80, .90, .95, .99), names = FALSE)
  m <- mean(x)
  s <- sd(x)
  c(
    n = length(x), media = m, mediana = median(x), moda = moda(x, casas),
    minimo = min(x), maximo = max(x), amplitude_total = max(x) - min(x),
    variancia = var(x), desvio_padrao = s, coef_variacao_pct = 100 * s / m,
    amplitude_interquartilica = q[11] - q[5],
    assimetria = mean((x - m)^3) / s^3,
    P1 = q[1], P5 = q[2], D1 = q[3], D2 = q[4], Q1 = q[5], D3 = q[6], D4 = q[7],
    D5_mediana = q[8], D6 = q[9], D7 = q[10], Q3 = q[11], D8 = q[12], D9 = q[13], P95 = q[14], P99 = q[15]
  )
}

# ---------------------------------------------------------------- 1. tabelas de frequencia
t_disc <- tabela_classes(base$veiculos_pesados, discreta = TRUE)
t_cont <- tabela_classes(base$pct_tag, discreta = FALSE)
write.csv(t_disc, file.path(saida, "tabela_freq_discreta_veiculos_pesados.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(t_cont, file.path(saida, "tabela_freq_continua_pct_tag.csv"), row.names = FALSE, fileEncoding = "UTF-8")

con <- file(file.path(saida, "tabelas_de_frequencia.txt"), "w", encoding = "UTF-8")
writeLines(c("== veiculos_pesados (quantitativa discreta, classes de Sturges) ==",
             capture.output(print(t_disc, row.names = FALSE)), "",
             "== pct_tag (quantitativa continua, classes de Sturges) ==",
             capture.output(print(t_cont, row.names = FALSE)), ""), con)
for (v in c("lote", "sentido", "trimestre", "faixa_volume")) {
  writeLines(c(paste0("== ", v, " =="), capture.output(print(tabela_simples(base[[v]]), row.names = FALSE)), ""), con)
}
close(con)

# ---------------------------------------------------------------- 2. medidas descritivas
quant <- c("volume_total", "veiculos_pesados", "pct_tag", "eixos_medios")
med <- sapply(quant, function(v) medidas(base[[v]], casas = if (v == "eixos_medios") 2 else if (v == "pct_tag") 1 else 0))
med <- round(med, 3)
write.csv(data.frame(medida = rownames(med), med, row.names = NULL), file.path(saida, "medidas_descritivas.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

# ---------------------------------------------------------------- 3. insights
pct <- function(a, b) 100 * sum(a) / sum(b)
total_veic <- sum(base$volume_total)
lote_tab <- do.call(rbind, lapply(split(base, base$lote), function(g)
  data.frame(lote = g$lote[1], veiculos = sum(g$volume_total), pct_tag = pct(g$passagens_tag, g$volume_total),
             pct_pesados = pct(g$veiculos_pesados, g$volume_total))))
lote_tab <- lote_tab[order(-lote_tab$pct_tag), ]
praca_tab <- aggregate(volume_total ~ praca + lote, data = base, FUN = sum)
praca_tab <- praca_tab[order(-praca_tab$volume_total), ]
dow <- weekdays(as.Date(base$data))
fim_semana <- dow %in% c("sábado", "domingo", "Saturday", "Sunday")
tri_tab <- do.call(rbind, lapply(split(base, base$trimestre), function(g)
  data.frame(trimestre = g$trimestre[1], media_dia = mean(g$volume_total), pct_tag = pct(g$passagens_tag, g$volume_total),
             pct_pesados = pct(g$veiculos_pesados, g$volume_total))))

lin <- c(
  paste("Registros (dia x praca x sentido):", n),
  paste("Pracas:", length(unique(base$praca)), "| Lotes:", length(unique(base$lote))),
  paste("Periodo:", min(base$data), "a", max(base$data)),
  paste("Veiculos no ano:", fmtn(total_veic)),
  "",
  paste("TAG: % das passagens (global):", fmt(pct(base$passagens_tag, base$volume_total))),
  paste("Vale-Pedagio: % das passagens (global):", fmt(pct(base$passagens_vale_pedagio, base$volume_total), 3)),
  paste("Pesados: % dos veiculos (global):", fmt(pct(base$veiculos_pesados, base$volume_total))),
  paste("TAG entre os pesados (%):", fmt(pct(base$pesados_com_tag, base$veiculos_pesados))),
  paste("TAG entre os nao pesados (%):", fmt(pct(base$passagens_tag - base$pesados_com_tag, base$volume_total - base$veiculos_pesados))),
  paste("Eixos medios por veiculo (ponderado pelo volume):", fmt(sum(base$eixos_medios * base$volume_total) / total_veic, 3)),
  paste("Correlacao de Pearson, pct_pesados x eixos_medios:", fmt(cor(base$pct_pesados, base$eixos_medios), 3)),
  "",
  "== % TAG por lote (ponderado), do maior ao menor ==",
  capture.output(print(transform(lote_tab, veiculos = fmtn(veiculos), pct_tag = round(pct_tag, 2), pct_pesados = round(pct_pesados, 2)), row.names = FALSE)),
  "",
  "== 10 pracas com maior volume no ano ==",
  capture.output(print(head(transform(praca_tab, volume_total = fmtn(volume_total)), 10), row.names = FALSE)),
  "",
  "== por trimestre ==",
  capture.output(print(transform(tri_tab, media_dia = round(media_dia), pct_tag = round(pct_tag, 2), pct_pesados = round(pct_pesados, 2)), row.names = FALSE)),
  "",
  paste("Media de veiculos por praca-sentido-dia: dias uteis", fmt(mean(base$volume_total[!fim_semana]), 0),
        "| fim de semana", fmt(mean(base$volume_total[fim_semana]), 0)),
  paste("% pesados (ponderado): dias uteis", fmt(pct(base$veiculos_pesados[!fim_semana], base$volume_total[!fim_semana])),
        "| fim de semana", fmt(pct(base$veiculos_pesados[fim_semana], base$volume_total[fim_semana])))
)
writeLines(lin, file.path(saida, "insights.txt"), useBytes = FALSE)

# ---------------------------------------------------------------- 4. graficos
azul <- "#0750ED"; grafite <- "#2E2D2D"
png(file.path(saida, "g1_pct_tag_histograma.png"), width = 1600, height = 1000, res = 200, type = "cairo")
par(mar = c(5, 5, 3, 1), family = "sans")
hist(base$pct_tag, breaks = nclass.Sturges(base$pct_tag), col = azul, border = "white",
     main = "Percentual de passagens pagas com TAG, por praça, sentido e dia",
     xlab = "% de passagens com TAG", ylab = "Quantidade de registros", cex.main = .95)
abline(v = c(mean(base$pct_tag), median(base$pct_tag)), col = grafite, lty = c(1, 2), lwd = 2)
legend("topleft", legend = c(paste0("média ", fmt(mean(base$pct_tag), 1), "%"), paste0("mediana ", fmt(median(base$pct_tag), 1), "%")),
       lty = c(1, 2), col = grafite, bty = "n", lwd = 2)
dev.off()

png(file.path(saida, "g2_veiculos_pesados_histograma.png"), width = 1600, height = 1000, res = 200, type = "cairo")
par(mar = c(5, 5, 3, 1), family = "sans")
hist(base$veiculos_pesados, breaks = nclass.Sturges(base$veiculos_pesados), col = azul, border = "white",
     main = "Veículos pesados por praça, sentido e dia", xlab = "Veículos pesados no dia", ylab = "Quantidade de registros", cex.main = .95)
abline(v = c(mean(base$veiculos_pesados), median(base$veiculos_pesados)), col = grafite, lty = c(1, 2), lwd = 2)
legend("topright", legend = c(paste0("média ", fmt(mean(base$veiculos_pesados), 0)), paste0("mediana ", fmt(median(base$veiculos_pesados), 0))),
       lty = c(1, 2), col = grafite, bty = "n", lwd = 2)
dev.off()

cat("Analise concluida em", saida, "\n")
cat("Linhas:", n, "| TAG global:", fmt(pct(base$passagens_tag, base$volume_total)), "%\n")
