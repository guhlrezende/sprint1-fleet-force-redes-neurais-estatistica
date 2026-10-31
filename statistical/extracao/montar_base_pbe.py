"""Valida o PBE limpo e monta a base de analise (csv). Linhas com celulas corrompidas pela
sobreposicao de texto do PDF sao descartadas e listadas em descartadas.csv."""
import csv, re, sys

PROP = {"Combustão", "Híbrido", "Plug-in", "Elétrico"}
COMB = {"G", "F", "E", "D", "E100"}
CAT = {"Sub Compacto", "Compacto", "Médio", "Grande", "Extra Grande", "Utilitário Esportivo Compacto",
       "Utilitário Esportivo Compacto 4x4", "Utilitário Esportivo Grande", "Utilitário Esportivo Grande 4x4",
       "Picape", "Picape Compacta", "Comercial", "Esportivo", "Fora de Estrada Compacto",
       "Fora de Estrada Grande", "Minivan"}
ENCE = set("ABCDE")

def num(s):
    s = s.strip()
    if s in ("", "\\", "-", "ND", "N.A.", "NA"):
        return ""
    try:
        return float(s.replace(",", "."))
    except ValueError:
        return None  # corrompido

def main(entrada, saida, descartadas):
    ok, ruins = [], []
    for r in csv.DictReader(open(entrada, encoding="utf-8")):
        motivo = []
        if r["categoria"] not in CAT: motivo.append("categoria")
        if r["propulsao"].replace("In", "in") not in PROP: motivo.append("propulsao")
        if r["combustivel"] not in COMB: motivo.append("combustivel")
        if r["ence_absoluta"] not in ENCE: motivo.append("ence_absoluta")
        if r["ence_relativa"] not in ENCE: motivo.append("ence_relativa")
        if not re.fullmatch(r"[A-Za-z0-9ÀÁÂÃÇÉÊÍÓÔÕÚ&.\- /+]+", r["marca"]) or not r["modelo"]:
            motivo.append("marca/modelo")
        n = {k: num(r[k]) for k in ("co_mgkm", "nox_mgkm", "co2_fossil_gasolina", "gasolina_cidade",
                                    "gasolina_estrada", "gasolina_comb", "etanol_comb", "consumo_energetico_mjkm",
                                    "autonomia_eletrica_km")}
        if any(v is None for v in n.values()): motivo.append("numero")
        else:
            for k, lo, hi in (("gasolina_comb", 2, 40), ("co2_fossil_gasolina", 0, 700), ("consumo_energetico_mjkm", 0.1, 6)):
                if n[k] != "" and not (lo <= n[k] <= hi): motivo.append("faixa_" + k)
        t = r["transmissao"]
        mv = re.search(r"(\d+)\s*$", t)
        if not re.fullmatch(r"(A|M|AT|MT|AMT|CVT|eCVT|DCT|DHT|Automática \(A\)|N\.A\.|-)?\s*-?\s*\d*", t) and not mv:
            motivo.append("transmissao")
        m = re.match(r"^(\d\.\d)", r["motor"])
        mval = re.search(r"(?<![\d.])(\d+)\s*V(?!\d)", r["motor"])
        if motivo:
            r["motivo"] = "+".join(motivo); ruins.append(r); continue
        ok.append(dict(
            categoria=r["categoria"], marca=r["marca"].upper().replace("CAOACHANGAN", "CAOA CHANGAN"), modelo=r["modelo"], versao=r["versao"],
            propulsao=r["propulsao"].replace("In", "in"), combustivel=r["combustivel"],
            transmissao=t, n_velocidades=1 if r["propulsao"] == "Elétrico" else (int(mv.group(1)) if mv else ""),
            cilindrada_l=float(m.group(1)) if m else "", n_valvulas=int(mval.group(1)) if mval else "",
            direcao_assistida=r["direcao"], co_mgkm=n["co_mgkm"], nox_mgkm=n["nox_mgkm"],
            co2_fossil_gkm=n["co2_fossil_gasolina"], km_l_cidade=n["gasolina_cidade"],
            km_l_estrada=n["gasolina_estrada"], km_l_combinado=n["gasolina_comb"], km_l_etanol_combinado=n["etanol_comb"],
            consumo_energetico_mjkm=n["consumo_energetico_mjkm"], autonomia_eletrica_km=n["autonomia_eletrica_km"],
            ence_relativa=r["ence_relativa"], ence_absoluta=r["ence_absoluta"]))
    sem_dup = ok  # linhas identicas consecutivas existem no proprio PDF (ex.: Audi Q3 Launch edition), entao ficam
    print("duplicatas consecutivas removidas:", len(ok) - len(sem_dup))
    ok = sem_dup
    with open(saida, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(ok[0])); w.writeheader(); w.writerows(ok)
    import openpyxl
    wb = openpyxl.Workbook(); ws = wb.active; ws.title = "PBE_Veicular_2026"
    ws.append(list(ok[0]))
    for x in ok: ws.append([None if v == "" else v for v in x.values()])
    wb.save(saida.replace(".csv", ".xlsx"))
    with open(descartadas, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(ruins[0])); w.writeheader(); w.writerows(ruins)
    print("validas", len(ok), "descartadas", len(ruins))
    import collections
    print(collections.Counter(x["motivo"] for x in ruins).most_common(8))
    print("marcas", len({x["marca"] for x in ok}))
    for col in ("km_l_combinado", "co2_fossil_gkm", "cilindrada_l", "n_valvulas", "n_velocidades"):
        print(col, sum(1 for x in ok if x[col] != ""))

if __name__ == "__main__":
    main(*sys.argv[1:4])
