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
  Relatorio_Insights_PBE_Veicular_2026.pdf
  analise_pbe_veicular_2026.r
  base_pbe_veicular_2026.csv / .xlsx
  anp_precos_2026-10-18_a_24.csv
  saidas/              tabelas de frequência, medidas, gráficos e insights gerados pelo script
  fonte/               PDF oficial do Inmetro e planilha da ANP
  extracao/            scripts em Python que tiraram a tabela do PDF do Inmetro
  artesp-versao-anterior/   primeira versão (pedágios da ARTESP), mantida como histórico
```

## Redes Neurais: pipeline para classificar a condução

PDF de 14 páginas, sem treinar nada, como o enunciado permite.

- **Problema:** classificar janelas de 5 segundos de aceleração, velocidade e rotação em condução normal, frenagem brusca ou arrancada brusca. O indicador de eventos bruscos por 100 km completa o diagnóstico de custo da calculadora. O problema vale para as três personas do material do Challenge: gestor de frota, CFO/liderança e Sem Parar Empresas.
- **Redes comparadas:** autoencoder, MLP e LSTM. A MLP é o classificador escolhido, porque a entrada é tabular e foi a rede vista em aula. O autoencoder entra como complemento para eventos raros.
- **Dados:** a fonte principal proposta é a telemetria da mobway, de carros conectados de fábrica. O kit ESP32 do Challenge e o projeto de sensores da equipe são alternativas. O arquivo de eventos do kit é simulado (um único caminhão, 132 linhas), e o PDF explica como ele foi gerado, os problemas que tem e por que não treinamos agora.
- **Ligação com os outros trabalhos da equipe:** sensores, API, banco de dados, calculadora em Python e o relatório de Statistical aparecem como proposta para a Sprint 2.
- **Honestidade:** o que ainda não foi medido está marcado como `Suposição` no texto, com uma tabela de suposições a validar.

## Statistical Computing: consumo e emissões dos veículos leves (Inmetro, 2026)

- **Base:** tabela PBE Veicular 2026 do Inmetro/CONPET (veículos leves), em PDF público, atualizada em 14/08/2026. O PDF declara 976 modelos/versões e 43 marcas. O script de extração leu 967 linhas e 966 passaram na validação, de 42 marcas. A diferença está explicada no relatório. O PDF original está em [statistical/fonte/](statistical/fonte/).
- **Por que essa base:** o custo de combustível por km é o maior custo de uma frota, e a etiqueta de consumo (ENCE) permite comparar modelos antes da compra.
- **Preços dos combustíveis:** ANP, Levantamento de Preços de Combustíveis, média Brasil na semana de 18 a 24/10/2026 (gasolina comum R$ 6,49, etanol R$ 4,11, diesel S10 R$ 7,32). O script lê os preços de `anp_precos_2026-10-18_a_24.csv` e aceita trocar a referência por um estado na variável `uf_referencia`.
- **Variáveis:** 2 nominais (`marca`, `propulsao`), 2 ordinais (`ence_absoluta`, `ence_relativa`), 2 discretas (`n_velocidades`, `n_valvulas`) e 2 contínuas (`km_l_combinado`, `co2_fossil_gkm`), todas com mais de 100 observações válidas.
- **Tabelas de frequência:** `n_velocidades` (discreta) e `km_l_combinado` (contínua, 11 classes pela regra de Sturges). O script também calcula medidas descritivas, custo por km por combustível e a comparação etanol x gasolina nos modelos flex, inclusive por estado.
- **Relatório:** insights para a decisão de uma frota, com os limites da análise (valores de laboratório, só veículos leves) e uma seção que liga o trabalho aos outros da equipe.

### Como rodar

Só R base, sem pacotes extras. Testado no R 4.6.1. Os dois `.csv` precisam estar na mesma pasta do script.

```bash
cd statistical
Rscript analise_pbe_veicular_2026.r
```

No RStudio, abra o script, use Session > Set Working Directory > To Source File Location e rode o arquivo inteiro com Ctrl+Shift+S. A análise grava na pasta `saida` as tabelas de frequência, as medidas, os gráficos e o `insights.txt` (aqui já gerados em `saidas/`).

Para refazer a base a partir do PDF do Inmetro, veja os scripts em `statistical/extracao/` (Python, PyMuPDF).

## Observações

- Os RMs dos integrantes foram retirados dos PDFs e do cabeçalho do script desta versão pública. As versões enviadas ao Portal têm os RMs na capa.
- Os enunciados são material da FIAP, copiados aqui para registrar o que foi pedido.
- O PDF do Inmetro e a planilha da ANP são dados públicos, guardados em `statistical/fonte/` para reprodução.
- Este repositório não tem licença definida. Sem licença, o código e os textos continuam com os autores.
