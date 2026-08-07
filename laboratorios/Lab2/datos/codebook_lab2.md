# Codebook — `hov_dotaciones_comercio.csv` (Lab 2, ECO-305)

Corte transversal por país (~2018) con dotaciones factoriales (estilo Penn World
Table 10.01) y contenido factorial neto del comercio, para el test de
Heckscher–Ohlin–Vanek (Bowen–Leamer–Sveikauskas 1987; Trefler 1995). Una fila =
un país.

## Variables

| Variable | Tipo | Descripción |
|---|---|---|
| `country_iso3` | str | País (ISO-3) |
| `country` | str | Nombre del país |
| `gdp` | num | PIB real (rgdpo, miles de millones US$ PPP) — base del consumo mundial |
| `K` | num | Stock de capital (miles de millones US$ PPP) |
| `L` | num | Ocupados (millones) |
| `hc` | num | Índice de capital humano (PWT `hc`, ~1–4) |
| `H` | num | Trabajo ajustado por calificación = `L`×`hc` (millones equiv.) |
| `delta_c` | num | Productividad Hicks-neutral relativa = (gdp/L) normalizada a la frontera |
| `F_K` | num | Contenido factorial **neto** del comercio en capital (unidades de cuota) |
| `F_L` | num | Contenido factorial neto en trabajo |
| `F_H` | num | Contenido factorial neto en trabajo calificado |

Cobertura: 30 países, 3 factores (90 pares país-factor).

## La prueba

Abundancia estricta de Vanek: $\text{abund}_{fc}=V_{fc}/V_{fw}-s_c$, con
$s_c=$ gdp$_c$/gdp mundial. HOV predice $\text{sign}(F_{fc})=\text{sign}(\text{abund}_{fc})$.
Ajuste de productividad (Trefler): dotación **efectiva** $\delta_c V_{fc}$;
abundancia efectiva $=\delta_c V_{fc}/\sum_c \delta_c V_{fc}-s_c$.

## Procedencia y estatuto del dato

Extracto **de práctica calibrado**, no descarga literal. El contenido factorial
medido se construyó siguiendo la abundancia **efectiva** más ruido, de modo que
reproduce los hechos clásicos: **test de signo estricto ≈ 61 %** (BLS 1987);
la prediccíon estricta apenas se relaciona con lo medido (pendiente ≈ 0,05);
al medir las dotaciones en unidades **efectivas** (ajuste de productividad) la
pendiente medido-vs-predicho **→ 1** (Davis–Weinstein 2001) y el signo mejora.

> Los `F_*` y las dotaciones son ilustrativos; el ejercicio y los órdenes de
> magnitud son válidos. No citar como dato oficial.

## Para usar datos reales

1. **Dotaciones**: Penn World Table 10.01 (`pwt1001.dta`) — `rnna`/`cn` (capital),
   `emp` (trabajo), `emp`×`hc` (trabajo calificado), `rgdpo` (PIB).
2. **Contenido factorial** $F=B\,T$: matriz $B$ de requerimientos factoriales de
   WIOD (Socio-Economic Accounts) u OECD-ICIO; comercio neto $T$ de BACI/Comtrade.
3. `delta_c` = (rgdpo/emp) normalizada a la frontera (EE. UU.).
