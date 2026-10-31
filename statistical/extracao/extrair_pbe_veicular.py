"""Extrai a tabela PBE Veicular 2026 (Inmetro/CONPET) do PDF oficial para JSON bruto.
O find_tables do PyMuPDF so serve para achar a caixa da tabela e os limites das 33 colunas;
o texto de cada linha vem das palavras posicionadas (agrupadas por altura), porque o texto
das celulas do find_tables perde digitos e funde linhas vizinhas.
Uso: python extrair_pbe_veicular.py fonte/<pdf> pbe_raw3.json
"""
import json, sys
import pymupdf

TOL = 1.6  # pt; passo entre linhas e ~3,24 pt, entao metade separa linhas vizinhas

def col_edges(tabela):
    for r in tabela.rows:
        cel = [c for c in r.cells if c is not None]
        if len(cel) == 33 and (r.bbox[3] - r.bbox[1]) < 5:
            return [c[0] for c in r.cells] + [r.cells[-1][2]]
    return None

def main(pdf, saida):
    doc = pymupdf.open(pdf)
    out = []
    for i, page in enumerate(doc, 1):
        palavras = page.get_text("words")
        for t, txt in ((t, t.extract()) for t in page.find_tables().tables):
            edges = col_edges(t)
            ini = next(r.bbox[1] for r, x in zip(t.rows, txt) if x[0] not in (None, "", "Categoria"))
            x0, _, x1, y1 = t.bbox
            ws = sorted((w for w in palavras
                         if ini - 0.8 <= (w[1] + w[3]) / 2 <= y1 + 0.8 and x0 - 1 <= (w[0] + w[2]) / 2 <= x1 + 1),
                        key=lambda w: (w[1] + w[3]) / 2)
            grupos, atual, ult = [], [], None
            for w in ws:
                yc = (w[1] + w[3]) / 2
                if ult is not None and yc - ult > TOL:
                    grupos.append(atual); atual = []
                atual.append(w); ult = yc
            if atual: grupos.append(atual)
            linhas = []
            for g in grupos:
                cel = [[] for _ in range(33)]
                for w in g:
                    xc = (w[0] + w[2]) / 2
                    c = next((k for k in range(33) if edges[k] <= xc < edges[k + 1]), 32 if xc >= edges[33] else 0)
                    cel[c].append((w[0], w[4]))
                linhas.append(dict(l=[" ".join(tx for _, tx in sorted(c)) for c in cel], dividida=False))
            out.append({"pagina": i, "linhas": linhas})
            print("pagina", i, "linhas", len(linhas), flush=True)
    json.dump(out, open(saida, "w", encoding="utf-8"), ensure_ascii=False)

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
