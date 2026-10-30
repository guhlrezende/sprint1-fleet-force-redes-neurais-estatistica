# Sprint 1 do Challenge Sem Parar: Redes Neurais e Statistical Computing

Entregas da equipe Fleet Force (turma 1TIAPR, FIAP, 2026) para a Sprint 1 do Challenge Sem Parar, nas disciplinas **Redes Neurais Artificiais, Deep Learning e Algoritmos Genéticos** e **Statistical Computing with R & Python**. O tema da Sprint é uma Calculadora Inteligente de Custos de Frota, para o gestor descobrir onde a frota perde dinheiro.

Os enunciados oficiais das duas disciplinas (e das outras sete, só como referência) estão em [enunciados/](enunciados/sprint-1-todas-as-disciplinas.md).

## O que tem aqui

```
enunciados/            texto das 9 disciplinas da Sprint 1, como aparece no Portal
redes-neurais/         entrega de Redes Neurais
  enunciado.md
  Portal8_Redes_Neurais_Pipeline_FleetForce.pdf
statistical/           entrega de Statistical Computing (em R)
  enunciado.md
  base_pedagios_sp_2025.csv
  preparar_base_artesp.r
  analise_pedagios_sp_2025.r
  Relatorio_Insights_Pedagios_SP_2025.pdf
  saidas/              tabelas de frequência, medidas e gráficos gerados pelo script
```

## Redes Neurais: pipeline para classificar a condução

PDF de 9 páginas, sem treinar nada, como o enunciado permite.

- **Problema:** classificar janelas de 5 segundos de acelerômetro e GPS (kit ESP32) em condução normal, frenagem brusca ou arrancada brusca. O indicador de eventos bruscos por 100 km completa o diagnóstico de custo da calculadora.
- **Redes comparadas:** Perceptron, MLP e LSTM. A MLP é a escolhida, porque a entrada é tabular e foi a rede vista em aula.
- **Dados:** o arquivo de eventos do kit é simulado (um único caminhão, 132 linhas). O PDF explica como foi gerado, os problemas que ele tem e por que não treinamos agora.
- **Honestidade:** o que ainda não foi medido está marcado como `Suposição` no texto.

## Statistical Computing: pedágio nas rodovias de São Paulo em 2025

- **Base:** dados abertos da ARTESP, "Tráfego nas praças de pedágio por dia em 2025", licença Creative Commons Atribuição. Fonte: <https://dadosabertos.artesp.sp.gov.br/dataset/volume-de-trafego>. São 927.516 registros originais, somados para **117.548 linhas, uma por dia, praça e sentido**, em 209 praças e 23 lotes de concessão. Cobre só as rodovias estaduais concedidas de São Paulo.
- **Por que essa base:** pedágio é custo de frota e é o produto da Sem Parar. A base traz a forma de pagamento (TAG, Vale-Pedágio, dinheiro, cartão) e a categoria do veículo por eixos.
- **Variáveis:** 2 nominais (`lote`, `sentido`), 2 ordinais (`trimestre`, `faixa_volume`), 2 discretas (`volume_total`, `veiculos_pesados`) e 2 contínuas (`pct_tag`, `eixos_medios`). As ordinais são derivadas (da data e dos quartis do volume), e o relatório diz isso.
- **Tabelas de frequência:** `veiculos_pesados` (discreta) e `pct_tag` (contínua), em 18 classes pela regra de Sturges. O script também calcula tendência central, dispersão e separatrizes das quatro variáveis quantitativas.
- **Relatório:** insights para a decisão de uma frota (TAG em 74,0% das passagens, 91,9% entre os veículos pesados, e pesados caindo de 24,9% nos dias úteis para 13,5% no fim de semana), com os limites da análise.

### Como rodar

Só R base, sem pacotes extras. Testado no R 4.6.1.

```bash
# 1. gerar a base a partir dos CSVs da ARTESP (opcional: a base já está aqui)
Rscript statistical/preparar_base_artesp.r <pasta_com_os_csv_da_artesp> base_pedagios_sp_2025.csv

# 2. rodar a análise
Rscript statistical/analise_pedagios_sp_2025.r statistical/base_pedagios_sp_2025.csv saida
```

A análise grava na pasta `saida` as tabelas de frequência, as medidas descritivas, o `insights.txt` e dois histogramas.

## Observações

- Os RMs dos integrantes foram retirados dos PDFs desta versão pública. As versões enviadas ao Portal têm os RMs na capa.
- Os enunciados são material da FIAP, copiados aqui para registrar o que foi pedido.
- Este repositório não tem licença definida. Sem licença, o código e os textos continuam com os autores.
