# Codebook — `cdk_prod_comercio_2018.csv` (Lab 1, ECO-305)

Corte transversal país × sector (manufactura, ISIC Rev.3 a 2 dígitos), ~2018,
para el test ricardiano moderno (lógica Costinot–Donaldson–Komunjer, 2012).
Una fila = un par país-sector.

## Variables

| Variable | Tipo | Descripción |
|---|---|---|
| `country_iso3` | str | País (ISO-3) |
| `country` | str | Nombre del país |
| `isic2` | str | Sector manufacturero ISIC Rev.3, 2 dígitos (preservar como texto) |
| `sector_name` | str | Nombre del sector |
| `productivity_usd` | num | Productividad fundamental = output por trabajador (US$) |
| `employment` | num | Ocupados del sector |
| `output_usd` | num | Producción bruta del sector (US$) = productividad × empleo |
| `exports_usd` | num | Exportaciones del sector (US$); **0 = sector sin exportación** |

Clave única: (`country_iso3`, `isic2`). Cobertura: 30 países, 19 sectores
(570 pares; ~25% con exportación cero).

## Procedencia y estatuto del dato

Extracto **de práctica calibrado**, no descarga literal. Se generó con un proceso
estructural coherente con Eaton–Kortum/CDK:
\[
\ln x_{ik} = \delta_i + \delta_k + \theta\,\ln z_{ik} + u_{ik},\qquad \theta_{\text{verdadero}} = 6{,}5,
\]
donde los efectos fijos de país ($\delta_i$) y sector ($\delta_k$) absorben ventaja
absoluta, tamaño y costos; $\theta$ se identifica de la variación intra-país e
intra-sector (ventaja comparativa). Se introdujeron ceros por selección (sectores
de baja ventaja comparativa en economías pequeñas) para PPML. Las
estimaciones de referencia recuperan $\hat\theta_{OLS}=6{,}52$ y
$\hat\theta_{PPML}=6{,}62$ (rango de la literatura: EK 2002 ≈ 8,3; CDK 2012 ≈ 6,5;
Simonovska–Waugh 2014 ≈ 4).

> Los niveles individuales (productividad, empleo, exportación de cada celda) son
> ilustrativos. 

## Para usar datos reales

1. **Productividad**: UNIDO INDSTAT 2 (ISIC Rev.3, 2 díg.) — valor agregado o
   producción sobre ocupados → output por trabajador (<https://stat.unido.org>).
   Alternativas: OECD STAN, GGDC Productivity.
2. **Exportaciones**: BACI (CEPII) o UN Comtrade a HS6 → concordancia HS→ISIC
   (tablas WITS/UN) → colapsar a ISIC2.
3. Unir por (`country_iso3`,`isic2`) **conservando los ceros**.
4. (Opcional, VCR) totales mundiales por sector para Balassa.
