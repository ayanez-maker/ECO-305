# Codebook — `comtrade_bol_2000_2024.csv` (Lab 0, ECO-305)

Panel de comercio exterior de Bolivia, (producto (HS2) × socio × año × flujo),
2000–2024. Formato largo (long). Una fila = una celda de comercio.

## Variables

| Variable | Tipo | Descripción |
|---|---|---|
| `year` | num | Año (2000–2024) |
| `flow` | str | Flujo: `X` = exportación, `M` = importación |
| `cmd_code` | str | Capítulo HS de 2 dígitos (preservar ceros: `02`, `08`) |
| `cmd_desc` | str | Descripción del capítulo |
| `partner_iso3` | str | Socio (ISO-3); `ROW` = resto del mundo |
| `partner` | str | Nombre del socio |
| `value_usd` | num | Valor en US$ corrientes |

Clave única: (`year`, `flow`, `cmd_code`, `partner_iso3`).
Cobertura: 25 años, 12 capítulos de exportación, 10 de importación, ~21 socios.

## Procedencia y estatuto del dato

Este archivo es un **extracto de práctica **, no la descarga literal de
UN Comtrade. 

Se construyó reproduciendo agregados oficiales publicados, con el fin de que el do-file corra de forma reproducible sin clave de API. 

Anclas de calibración (fuentes reales):
- Exportación total **2024 = US$ 8.922,9 M**; **2023 = US$ 10.911 M**; **2022 = US$ 13.671 M** (INE/ABI/IBCE).
- Composición **2024**: gas 18,1%; zinc 15,9%; plata 13,4%; soya y derivados 11,0%; oro metálico 7,7%; estaño 5,9% (INE, 2024).
- Gas natural: pico **2014 ≈ US$ 6,0 mil M ≈ 46,5%** del total; declive posterior por caída de producción y precios (EIA, Gas Outlook).
- Destinos de gas 2023: Brasil ≈ US$ 1,36 mil M; Argentina ≈ US$ 0,69 mil M (WITS/Comtrade).

En `value_usd` los **niveles producto×socio** son ilustrativos (interpolados y
con ruido) aunque consistentes con los totales y la composición oficiales. No
citar celdas individuales como dato oficial. 



