"""Análise Exploratória de Dados: acidentes nas rodovias federais em 2025 (PRF, BAT).

Fonte: Polícia Rodoviária Federal, Dados Abertos, "Documento CSV de Acidentes 2025
(agrupados por ocorrência)", https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-da-prf

Uso:
    python eda_prf_acidentes_2025.py <datatran2025.csv> <pasta_de_saida>

Gera na pasta de saída: a base recortada (CSV), as tabelas de frequência, as medidas
estatísticas, os gráficos (PNG) e o arquivo resultados.json com os números usados no relatório.
"""
import json
import math
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats

ORDEM_GRAVIDADE = ["Sem Vítimas", "Com Vítimas Feridas", "Com Vítimas Fatais"]
ORDEM_FASE_DIA = ["Amanhecer", "Pleno dia", "Anoitecer", "Plena Noite"]
ORDEM_SEMANA = ["segunda-feira", "terça-feira", "quarta-feira", "quinta-feira",
                "sexta-feira", "sábado", "domingo"]

VAR_NOMINAIS = ["tipo_acidente", "condicao_metereologica"]
VAR_ORDINAIS = ["classificacao_acidente", "fase_dia"]
VAR_DISCRETAS = ["pessoas", "veiculos"]
VAR_CONTINUAS = ["km", "hora_decimal"]

COR = "#1F4E79"
COR2 = "#C0504D"


def carregar(caminho):
    # a base original da PRF vem em latin1; a base entregue (recortada) vem em UTF-8 com BOM
    try:
        df = pd.read_csv(caminho, sep=";", decimal=",", encoding="utf-8-sig", na_values=["NA"])
    except UnicodeDecodeError:
        df = pd.read_csv(caminho, sep=";", decimal=",", encoding="latin1", na_values=["NA"])
    # um registro sem classificação do acidente não serve para a variável ordinal
    df = df.dropna(subset=["classificacao_acidente"]).copy()
    h = pd.to_datetime(df["horario"], format="%H:%M:%S")
    df["hora_decimal"] = (h.dt.hour + h.dt.minute / 60).round(2)
    df["classificacao_acidente"] = pd.Categorical(
        df["classificacao_acidente"], ORDEM_GRAVIDADE, ordered=True)
    df["fase_dia"] = pd.Categorical(df["fase_dia"], ORDEM_FASE_DIA, ordered=True)
    df["dia_semana"] = pd.Categorical(df["dia_semana"], ORDEM_SEMANA, ordered=True)
    return df


def tabela_frequencia(serie, ordem=None, por_valor=False):
    contagem = serie.value_counts()
    if por_valor:
        contagem = contagem.sort_index()
    if ordem is not None:
        contagem = contagem.reindex(ordem)
    t = pd.DataFrame({"fi": contagem})
    t["fr"] = t["fi"] / t["fi"].sum()
    t["fr_%"] = (t["fr"] * 100).round(2)
    t["Fi"] = t["fi"].cumsum()
    t["Fr_%"] = (t["fr"].cumsum() * 100).round(2)
    return t


def tabela_discreta(serie, limite=5):
    """Frequência de uma variável discreta, agrupando valores >= limite em '5 ou mais'."""
    agrupada = serie.clip(upper=limite).astype(int)
    t = tabela_frequencia(agrupada, por_valor=True)
    t.index = [str(i) if i < limite else f"{limite} ou mais" for i in t.index]
    t.index.name = serie.name
    return t


def tabela_continua(serie):
    """Distribuição em classes pela regra de Sturges, classes [a, b)."""
    n = len(serie)
    k = int(round(1 + 3.322 * math.log10(n)))
    amplitude = serie.max() - serie.min()
    h = math.ceil(amplitude / k)
    limites = [serie.min() + i * h for i in range(k + 1)]
    if limites[-1] <= serie.max():
        limites.append(limites[-1] + h)
    classes = pd.cut(serie, bins=limites, right=False, include_lowest=True)
    t = tabela_frequencia(classes, ordem=classes.cat.categories)
    t.index = [f"{int(i.left)} |-- {int(i.right)}" for i in t.index]
    t.index.name = serie.name
    ponto_medio = [(a + b) / 2 for a, b in zip(limites[:-1], limites[1:])]
    t.insert(0, "ponto_medio", ponto_medio[: len(t)])
    return t, k, h


def medidas(serie):
    s = serie.astype(float)
    q1, q2, q3 = s.quantile([0.25, 0.5, 0.75])
    moda = stats.mode(s, keepdims=False).mode
    positiva = s[s > 0]
    r = {
        # tendência central
        "média aritmética": s.mean(),
        "mediana": s.median(),
        "moda": moda,
        "média geométrica (valores > 0)": stats.gmean(positiva),
        "média harmônica (valores > 0)": stats.hmean(positiva),
        # dispersão
        "mínimo": s.min(),
        "máximo": s.max(),
        "amplitude total": s.max() - s.min(),
        "variância (amostral)": s.var(ddof=1),
        "desvio padrão (amostral)": s.std(ddof=1),
        "erro padrão da média": s.std(ddof=1) / math.sqrt(len(s)),
        "coeficiente de variação (%)": s.std(ddof=1) / s.mean() * 100,
        "desvio médio absoluto": (s - s.mean()).abs().mean(),
        "amplitude interquartílica (Q3 - Q1)": q3 - q1,
        # forma
        "assimetria": stats.skew(s),
        "curtose (excesso)": stats.kurtosis(s),
        # separatrizes
        "Q1 (25%)": q1,
        "Q2 (50%)": q2,
        "Q3 (75%)": q3,
    }
    for d in range(1, 10):
        r[f"D{d} ({d * 10}%)"] = s.quantile(d / 10)
    for p in (1, 5, 95, 99):
        r[f"P{p}"] = s.quantile(p / 100)
    return pd.Series(r)


def grafico_barras(serie_freq, titulo, rotulo_x, arquivo, horizontal=False):
    fig, ax = plt.subplots(figsize=(8, 4.5))
    if horizontal:
        serie_freq = serie_freq.sort_values()
        ax.barh(serie_freq.index.astype(str), serie_freq.values, color=COR)
        ax.set_xlabel("Número de acidentes")
    else:
        ax.bar(serie_freq.index.astype(str), serie_freq.values, color=COR)
        ax.set_ylabel("Número de acidentes")
        ax.set_xlabel(rotulo_x)
    ax.set_title(titulo)
    total = serie_freq.sum()
    for i, v in enumerate(serie_freq.values):
        txt = f"{v:,} ({v / total:.1%})".replace(",", ".")
        if horizontal:
            ax.text(v, i, " " + txt, va="center", fontsize=8)
        else:
            ax.text(i, v, txt, ha="center", va="bottom", fontsize=8)
    ax.spines[["top", "right"]].set_visible(False)
    if horizontal:
        ax.margins(x=0.25)
    else:
        ax.margins(y=0.15)
    fig.tight_layout()
    fig.savefig(arquivo, dpi=150)
    plt.close(fig)


def grafico_pizza(serie_freq, titulo, arquivo):
    fig, ax = plt.subplots(figsize=(6.5, 4.8))
    cores = ["#8FAADC", COR, "#F4B183", "#404040"]
    ax.pie(serie_freq.values, labels=serie_freq.index.astype(str), autopct="%1.1f%%",
           startangle=90, colors=cores, wedgeprops={"edgecolor": "white"})
    ax.set_title(titulo)
    fig.tight_layout()
    fig.savefig(arquivo, dpi=150)
    plt.close(fig)


def grafico_histograma(serie, titulo, rotulo_x, arquivo, bins):
    fig, ax = plt.subplots(figsize=(8, 4.5))
    ax.hist(serie, bins=bins, color=COR, edgecolor="white")
    ax.axvline(serie.mean(), color=COR2, ls="--", label=f"média = {serie.mean():.1f}")
    ax.axvline(serie.median(), color="#548235", ls="-.", label=f"mediana = {serie.median():.1f}")
    ax.set_title(titulo)
    ax.set_xlabel(rotulo_x)
    ax.set_ylabel("Número de acidentes")
    ax.legend()
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig(arquivo, dpi=150)
    plt.close(fig)


def grafico_boxplot(serie, titulo, rotulo, arquivo):
    fig, ax = plt.subplots(figsize=(8, 3.6))
    ax.boxplot(serie, vert=False, showfliers=True, flierprops={"markersize": 3, "alpha": 0.4},
               boxprops={"color": COR}, medianprops={"color": COR2})
    ax.set_title(titulo)
    ax.set_xlabel(rotulo)
    ax.set_yticks([])
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig(arquivo, dpi=150)
    plt.close(fig)


def pct_fatal(df, coluna):
    t = df.groupby(coluna, observed=True)["classificacao_acidente"].agg(
        total="size",
        fatais=lambda s: (s == "Com Vítimas Fatais").sum())
    t["% fatais"] = (t["fatais"] / t["total"] * 100).round(2)
    return t


def grafico_fatal(df, coluna, titulo, arquivo, ordem=None):
    t = pct_fatal(df, coluna)
    if ordem is not None:
        t = t.reindex(ordem)
    fig, ax = plt.subplots(figsize=(8, 4.2))
    ax.bar(t.index.astype(str), t["% fatais"], color=COR2)
    for i, v in enumerate(t["% fatais"]):
        ax.text(i, v, f"{v:.1f}%", ha="center", va="bottom", fontsize=9)
    ax.set_ylabel("% de acidentes com vítimas fatais")
    ax.set_title(titulo)
    ax.spines[["top", "right"]].set_visible(False)
    ax.margins(y=0.15)
    fig.tight_layout()
    fig.savefig(arquivo, dpi=150)
    plt.close(fig)


def main(entrada, saida):
    saida = Path(saida)
    saida.mkdir(parents=True, exist_ok=True)
    df = carregar(entrada)
    n = len(df)
    resultados = {"n": n, "periodo": [df["data_inversa"].min(), df["data_inversa"].max()]}

    # 1. Base recortada para a entrega (variáveis exigidas + apoio)
    colunas = (["id", "data_inversa", "dia_semana", "horario", "uf", "br", "km", "municipio",
                "causa_acidente"] + VAR_NOMINAIS + VAR_ORDINAIS +
               ["tipo_pista", "mortos", "feridos"] + VAR_DISCRETAS +
               ["hora_decimal", "latitude", "longitude"])
    colunas = list(dict.fromkeys(colunas))
    df[colunas].to_csv(saida / "base_prf_acidentes_2025.csv", sep=";", decimal=",",
                       index=False, encoding="utf-8-sig")

    # 2. Tabelas de frequência
    tabelas = {
        "freq_classificacao_acidente (ordinal)": tabela_frequencia(
            df["classificacao_acidente"], ORDEM_GRAVIDADE),
        "freq_fase_dia (ordinal)": tabela_frequencia(df["fase_dia"], ORDEM_FASE_DIA),
        "freq_condicao_metereologica (nominal)": tabela_frequencia(df["condicao_metereologica"]),
        "freq_tipo_acidente (nominal)": tabela_frequencia(df["tipo_acidente"]),
        "freq_veiculos (discreta)": tabela_discreta(df["veiculos"]),
        "freq_pessoas (discreta)": tabela_discreta(df["pessoas"]),
    }
    t_km, k, h = tabela_continua(df["km"])
    tabelas["freq_km (contínua, classes de Sturges)"] = t_km
    resultados["sturges_km"] = {"classes": k, "amplitude_classe": h}
    with open(saida / "tabelas_de_frequencia.txt", "w", encoding="utf-8") as f:
        for nome, t in tabelas.items():
            f.write(f"== {nome} ==\n{t.to_string()}\n\n")
    for nome, t in tabelas.items():
        resultados[nome] = t.reset_index().to_dict(orient="records")

    # 3. Medidas descritivas
    quanti = VAR_CONTINUAS + VAR_DISCRETAS
    med = pd.DataFrame({v: medidas(df[v]) for v in quanti})
    med.round(3).to_csv(saida / "medidas_descritivas.csv", sep=";", decimal=",",
                        encoding="utf-8-sig")
    with open(saida / "medidas_descritivas.txt", "w", encoding="utf-8") as f:
        f.write(med.round(3).to_string())
    resultados["medidas"] = med.round(4).to_dict()

    # 4. Gráficos
    grafico_barras(df["classificacao_acidente"].value_counts().reindex(ORDEM_GRAVIDADE),
                   "Acidentes por classificação (PRF, 2025)", "Classificação",
                   saida / "g1_classificacao_barras.png")
    grafico_pizza(df["fase_dia"].value_counts().reindex(ORDEM_FASE_DIA),
                  "Acidentes por fase do dia (PRF, 2025)", saida / "g2_fase_dia_pizza.png")
    grafico_barras(df["tipo_acidente"].value_counts(), "Acidentes por tipo (PRF, 2025)", "",
                   saida / "g3_tipo_acidente_barras.png", horizontal=True)
    grafico_histograma(df["km"], "Distribuição do km da rodovia onde ocorreu o acidente",
                       "km da rodovia", saida / "g4_km_histograma.png", bins=k)
    grafico_boxplot(df["pessoas"], "Pessoas envolvidas por acidente", "pessoas",
                    saida / "g5_pessoas_boxplot.png")
    grafico_histograma(df["hora_decimal"], "Horário do acidente (hora do dia)", "hora do dia",
                       saida / "g6_horario_histograma.png", bins=24)
    grafico_fatal(df, "fase_dia", "Gravidade por fase do dia", saida / "g7_fatal_fase_dia.png",
                  ORDEM_FASE_DIA)
    grafico_fatal(df, "tipo_pista", "Gravidade por tipo de pista", saida / "g8_fatal_tipo_pista.png")

    # 5. Insights para a decisão da empresa
    fatal_fase = pct_fatal(df, "fase_dia").reindex(ORDEM_FASE_DIA)
    fatal_pista = pct_fatal(df, "tipo_pista")
    fatal_tipo = pct_fatal(df, "tipo_acidente").sort_values("% fatais", ascending=False)
    fatal_cond = pct_fatal(df, "condicao_metereologica")
    causas = df["causa_acidente"].value_counts()
    uf = df["uf"].value_counts()
    fatal_uf = pct_fatal(df, "uf")
    fds = df["dia_semana"].isin(["sábado", "domingo"])
    cenario = pd.DataFrame({
        "dias úteis (seg a sex)": {
            "acidentes": int((~fds).sum()),
            "acidentes por dia": round((~fds).sum() / df.loc[~fds, "data_inversa"].nunique(), 1),
            "% fatais": round((df.loc[~fds, "classificacao_acidente"] == "Com Vítimas Fatais").mean() * 100, 2),
            "pessoas (média)": round(df.loc[~fds, "pessoas"].mean(), 2)},
        "fim de semana": {
            "acidentes": int(fds.sum()),
            "acidentes por dia": round(fds.sum() / df.loc[fds, "data_inversa"].nunique(), 1),
            "% fatais": round((df.loc[fds, "classificacao_acidente"] == "Com Vítimas Fatais").mean() * 100, 2),
            "pessoas (média)": round(df.loc[fds, "pessoas"].mean(), 2)},
    })
    top_uf = uf.head(5).index.tolist()
    cenario_uf = df[df["uf"].isin(top_uf)].groupby("uf", observed=True).agg(
        acidentes=("id", "size"), km_mediana=("km", "median"),
        pessoas_media=("pessoas", "mean"), mortos=("mortos", "sum")).round(2)
    cenario_uf["% fatais"] = fatal_uf.loc[top_uf, "% fatais"]

    resultados["insights"] = {
        "fatal_por_fase_dia": fatal_fase.reset_index().to_dict(orient="records"),
        "fatal_por_tipo_pista": fatal_pista.reset_index().to_dict(orient="records"),
        "fatal_por_tipo_acidente": fatal_tipo.reset_index().to_dict(orient="records"),
        "fatal_por_condicao": fatal_cond.reset_index().to_dict(orient="records"),
        "top_causas": causas.head(5).to_dict(),
        "top_uf": uf.head(5).to_dict(),
        "cenario_dias": cenario.to_dict(),
        "cenario_uf": cenario_uf.reset_index().to_dict(orient="records"),
        "total_mortos": int(df["mortos"].sum()),
        "total_feridos": int(df["feridos"].sum()),
        "total_pessoas": int(df["pessoas"].sum()),
    }
    with open(saida / "insights.txt", "w", encoding="utf-8") as f:
        f.write(f"Acidentes analisados: {n}\n\n")
        f.write("% de acidentes fatais por fase do dia\n" + fatal_fase.to_string() + "\n\n")
        f.write("% fatais por tipo de pista\n" + fatal_pista.to_string() + "\n\n")
        f.write("% fatais por tipo de acidente\n" + fatal_tipo.to_string() + "\n\n")
        f.write("% fatais por condição meteorológica\n" + fatal_cond.to_string() + "\n\n")
        f.write("Top 5 causas\n" + causas.head(5).to_string() + "\n\n")
        f.write("Cenário 1: dias úteis x fim de semana\n" + cenario.to_string() + "\n\n")
        f.write("Cenário 2: as 5 UFs com mais acidentes\n" + cenario_uf.to_string() + "\n")

    with open(saida / "resultados.json", "w", encoding="utf-8") as f:
        json.dump(resultados, f, ensure_ascii=False, indent=2, default=str)

    # Resumo na tela
    print(f"Acidentes analisados: {n}  ({resultados['periodo'][0]} a {resultados['periodo'][1]})")
    for nome in ["freq_classificacao_acidente (ordinal)", "freq_veiculos (discreta)",
                 "freq_km (contínua, classes de Sturges)"]:
        print(f"\n== {nome} ==\n{tabelas[nome].to_string()}")
    print("\n== Medidas descritivas ==\n" + med.round(3).to_string())
    print("\n" + open(saida / "insights.txt", encoding="utf-8").read())


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
