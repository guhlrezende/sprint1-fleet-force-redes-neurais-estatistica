"""Limpa o dump bruto do PBE Veicular 2026: remove cabecalhos, conserta texto duplicado e grava pbe_limpo.csv."""
import csv, json, sys, collections

COLS = ["categoria", "marca", "modelo", "versao", "motor", "propulsao", "transmissao",
        "ar_cond", "direcao", "combustivel", "nmog_nox_mgkm", "co_mgkm", "nox_mgkm",
        "reducao_poluentes", "co2_fossil_etanol", "co2_total_gasolina", "co2_fossil_gasolina",
        "co2e_fossil_vehp", "etanol_cidade", "etanol_estrada", "etanol_comb",
        "gasolina_cidade", "gasolina_estrada", "gasolina_comb", "ele_cidade", "ele_estrada",
        "ele_vehp_cidade", "ele_vehp_estrada", "consumo_energetico_mjkm", "autonomia_eletrica_km",
        "ence_relativa", "ence_absoluta", "selo_conpet"]

def desduplica(s):
    """Texto com cada letra repetida k vezes ('MMééddiioo') ou frase repetida ('Picape Picape')."""
    for k in range(5, 1, -1):
        if len(s) % k == 0 and len(s) >= k and all(s[i] == s[i + j] for i in range(0, len(s), k) for j in range(k)):
            return s[::k]
    p = s.split(" ")
    if len(p) % 2 == 0 and p[: len(p) // 2] == p[len(p) // 2:]:
        return " ".join(p[: len(p) // 2])
    return s

def main(raw_json, saida):
    raw = json.load(open(raw_json, encoding="utf-8"))
    linhas = []
    for t in raw:
        for item in t["linhas"]:
            r = item["l"]
            if len(r) != len(COLS) or not r[0] or r[0] == "Categoria":
                continue
            r = [desduplica(c) if i in (0, 5) else c for i, c in enumerate(r)]
            linhas.append([t["pagina"]] + r)
    with open(saida, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["pagina"] + COLS)
        w.writerows(linhas)
    print(len(linhas), "linhas")
    for col in ("categoria", "propulsao", "combustivel", "ence_absoluta", "ence_relativa", "transmissao"):
        i = COLS.index(col) + 1
        print(col, dict(collections.Counter(l[i] for l in linhas).most_common(40)))

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])

