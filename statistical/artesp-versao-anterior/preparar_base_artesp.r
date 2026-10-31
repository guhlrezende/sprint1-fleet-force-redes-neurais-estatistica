# Prepara a base de analise: volume de veiculos por praca de pedagio, rodovias concedidas de SP, 2025.
#
# Fonte: ARTESP, Dados Abertos, "Trafego nas pracas de pedagio por dia em 2025"
# https://dadosabertos.artesp.sp.gov.br/dataset/volume-de-trafego
# Licenca: Creative Commons Atribuicao.
#
# Uso:
#   Rscript preparar_base_artesp.r <pasta_com_os_csv_da_artesp> <arquivo_de_saida.csv>
#
# Cada CSV da ARTESP (um por lote de concessao) tem uma linha por dia, praca, sentido,
# tipo de cabine, tipo de passagem e forma de pagamento, com uma coluna de contagem por
# categoria de veiculo (ex.: "LEVE-EIXOS 2", "PESADO-EIXOS 5"). Aqui somamos tudo para
# uma linha por dia, praca e sentido, e criamos as variaveis usadas na analise.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Uso: Rscript preparar_base_artesp.r <pasta_csv> <saida.csv>")
pasta <- args[1]
saida <- args[2]

arquivos <- list.files(pasta, pattern = "^VOLUME_PEDAGIADO-.*\\.csv$", full.names = TRUE)
if (length(arquivos) == 0) stop("Nenhum arquivo VOLUME_PEDAGIADO-*.csv em ", pasta)

# le um arquivo e devolve uma linha por registro com os totais que interessam
ler_lote <- function(f) {
  d <- read.csv(f, encoding = "UTF-8", stringsAsFactors = FALSE, check.names = FALSE,
                na.strings = character(0))
  veic <- grep("-EIXOS ", names(d), value = TRUE)
  eixos <- as.numeric(sub(".*-EIXOS ", "", veic))
  m <- as.matrix(d[, veic])
  eh_pesado <- grepl("^PESADO", veic)
  eh_tag <- d$TP_PAGAMENTO == "TAG"
  eh_vale <- d$TP_PAGAMENTO == "VALE PEDÁGIO"
  total <- rowSums(m)
  pesados <- rowSums(m[, eh_pesado, drop = FALSE])
  data.frame(
    data = d$DATA, lote = d$LOTE, praca = d$PRACA, sentido = d$SENTIDO,
    total = total,
    pesados = pesados,
    eixos_x_veiculos = as.vector(m %*% eixos),
    tag = ifelse(eh_tag, total, 0),
    pesados_tag = ifelse(eh_tag, pesados, 0),
    vale_pedagio = ifelse(eh_vale, total, 0),
    stringsAsFactors = FALSE
  )
}

cat("Lendo", length(arquivos), "arquivos...\n")
registros <- do.call(rbind, lapply(arquivos, ler_lote))
cat("Registros lidos:", nrow(registros), "\n")

# um registro da base original nao traz o sentido da praca: removido
sem_sentido <- registros$sentido == ""
cat("Registros sem sentido removidos:", sum(sem_sentido), "\n")
registros <- registros[!sem_sentido, ]

base <- aggregate(
  cbind(total, pesados, eixos_x_veiculos, tag, pesados_tag, vale_pedagio) ~ data + lote + praca + sentido,
  data = registros, FUN = sum
)
base <- base[base$total > 0, ]
base <- base[order(base$data, base$lote, base$praca, base$sentido), ]

# variaveis finais
base$volume_total <- base$total
base$veiculos_pesados <- base$pesados
base$passagens_tag <- base$tag
base$pct_tag <- round(100 * base$tag / base$total, 2)
base$pct_pesados <- round(100 * base$pesados / base$total, 2)
base$eixos_medios <- round(base$eixos_x_veiculos / base$total, 3)
base$passagens_vale_pedagio <- base$vale_pedagio
base$pesados_com_tag <- base$pesados_tag
base$pct_tag_pesados <- ifelse(base$pesados > 0, round(100 * base$pesados_tag / base$pesados, 2), NA)

# ordinais: trimestre (ordem do calendario) e faixa de volume do dia (quartis do volume_total)
mes <- as.integer(substr(base$data, 6, 7))
base$trimestre <- paste0("T", (mes - 1) %/% 3 + 1)
cortes <- quantile(base$volume_total, c(0, .25, .5, .75, 1))
rotulos <- c("1 Baixo", "2 Médio", "3 Alto", "4 Muito alto")
base$faixa_volume <- as.character(cut(base$volume_total, breaks = cortes, labels = rotulos,
                                      include.lowest = TRUE))

final <- base[, c("data", "lote", "praca", "sentido", "trimestre", "faixa_volume",
                  "volume_total", "veiculos_pesados", "passagens_tag",
                  "passagens_vale_pedagio", "pesados_com_tag",
                  "pct_tag", "pct_pesados", "eixos_medios", "pct_tag_pesados")]
write.csv(final, saida, row.names = FALSE, fileEncoding = "UTF-8", na = "")
cat("Base gravada:", saida, "com", nrow(final), "linhas e", ncol(final), "colunas\n")
cat("Cortes da faixa de volume (quartis):", paste(round(cortes), collapse = " | "), "\n")
