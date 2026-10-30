# Sprint 1 do Challenge Sem Parar: Redes Neurais e Statistical Computing

Entregas da equipe Fleet Force (turma 1TIAPR, FIAP, 2026) para a Sprint 1 do Challenge Sem Parar, nas disciplinas **Redes Neurais Artificiais, Deep Learning e Algoritmos Genéticos** e **Statistical Computing with R & Python**. O tema da Sprint é uma Calculadora Inteligente de Custos de Frota, para o gestor descobrir onde a frota perde dinheiro.

Os enunciados oficiais das duas disciplinas (e das outras sete, só como referência) estão em [enunciados/](enunciados/sprint-1-todas-as-disciplinas.md).

## O que tem aqui

```
enunciados/            texto das 9 disciplinas da Sprint 1, como aparece no Portal
redes-neurais/         entrega de Redes Neurais
  enunciado.md
  Portal8_Redes_Neurais_Pipeline_FleetForce.pdf
  pipeline.png
statistical/           entrega de Statistical Computing
  enunciado.md
  base_prf_acidentes_2025.csv
  eda_prf_acidentes_2025.py
  Relatorio_Insights_Acidentes_PRF_2025.pdf
  saidas/              tabelas, medidas e gráficos gerados pelo script
requirements.txt
```

## Redes Neurais: pipeline para classificar a condução

PDF de 9 páginas, sem treinar nada, como o enunciado permite.

- **Problema:** classificar janelas de 5 segundos de acelerômetro e GPS (kit ESP32) em condução normal, frenagem brusca ou arrancada brusca. O indicador de eventos bruscos por 100 km completa o diagnóstico de custo da calculadora.
- **Redes comparadas:** Perceptron, MLP e LSTM. A MLP é a escolhida, porque a entrada é tabular e foi a rede vista em aula.
- **Dados:** o arquivo de eventos do kit é simulado (um único caminhão, 132 linhas). O PDF explica como foi gerado, os problemas que ele tem e por que não treinamos agora.
- **Honestidade:** o que ainda não foi medido está marcado como `[Suposição]` no texto.

## Statistical Computing: acidentes nas rodovias federais em 2025

- **Base:** dados abertos da Polícia Rodoviária Federal (PRF), acidentes de 2025 agrupados por ocorrência, 72.528 registros. Fonte: <https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-da-prf>. A base aqui é um recorte do arquivo original, com as variáveis usadas e uma linha removida por falta de classificação do acidente.
- **Variáveis:** 2 nominais (`tipo_acidente`, `condicao_metereologica`), 2 ordinais (`classificacao_acidente`, `fase_dia`), 2 discretas (`pessoas`, `veiculos`) e 2 contínuas (`km`, `hora_decimal`).
- **Tabelas de frequência:** `veiculos` (discreta) e `km` (contínua, 17 classes pela regra de Sturges). O script também calcula as medidas descritivas, os quartis, decis e percentis, e gera os gráficos.
- **Relatório:** insights para a decisão de uma frota, com os limites da análise. As associações são descritivas e não provam causa. A base mede a gravidade dos acidentes, não o custo em reais.

### Como rodar

Python 3.10 ou mais novo.

```bash
pip install -r requirements.txt
python statistical/eda_prf_acidentes_2025.py statistical/base_prf_acidentes_2025.csv saida
```

O script também aceita o arquivo original da PRF (`datatran2025.csv`). Ele grava as tabelas, as medidas, os gráficos e o `resultados.json` na pasta `saida`.

## Observações

- Os RMs dos integrantes foram retirados dos PDFs desta versão pública. As versões enviadas ao Portal têm os RMs na capa.
- Os enunciados são material da FIAP, copiados aqui para registrar o que foi pedido.
- Este repositório não tem licença definida. Sem licença, o código e os textos continuam com os autores.
