*===============================================================================
* ECO-305  COMERCIO INTERNACIONAL  |  Universidad Catolica Boliviana
* LABORATORIO 1  ---  Test ricardiano moderno (logica CDK 2012)
* Archivo : Lab1_plantilla.do      (PLANTILLA DEL ESTUDIANTE)
* Nombre  : ____________________________   Fecha: __________
*-------------------------------------------------------------------------------
* INSTRUCCIONES
*  - Completa cada bloque marcado con TODO. No borres los encabezados.
*  - El do-file debe correr de principio a fin sin errores.
*  - Ejecutalo desde la carpeta Lab1/. 
*  - Entrega: este .do + el memo (4 pag) + base
*  - Requiere: reghdfe, ppmlhdfe, ftools, binscatter (se instalan abajo).
*===============================================================================
clear all
set more off

* cd "C:/.../........./Lab0"
capture mkdir output
capture mkdir figuras
capture log close
log using "output/Lab1_estudiante.log", replace text

* --- Paquetes (corra una sola vez, requieren conexion) 
foreach p in ftools reghdfe ppmlhdfe binscatter {
    capture which `p'
    if _rc ssc install `p', replace
}

*-------------------------------------------------------------------------------
* A. IMPORTACION Y DEPURACION                               [resuelto, NO TOCAR]
*-------------------------------------------------------------------------------
import delimited "datos/cdk_prod_comercio_2018.csv", varnames(1) stringcols(3) clear
destring productivity_usd employment output_usd exports_usd, replace force
encode country_iso3, gen(pais)
encode isic2, gen(sector)
gen double ln_z = ln(productivity_usd)
gen double ln_x = ln(exports_usd)      // missing cuando exports_usd==0

isid country_iso3 isic2
count if exports_usd==0
display "Celdas con exportacion cero: " r(N)
compress
save "output/cdk_panel.dta", replace

*-------------------------------------------------------------------------------
* B. ESTIMACION OLS CON EFECTOS FIJOS                               [TODO #B]
*    Modelo: ln x_ik = theta*ln z_ik + delta_pais + delta_sector + e
*   Los EF de pais y sector absorben ventaja absoluta, tamanio y costos:
*   theta se identifica de la variacion intra-pais e intra-sector (vent. comparativa).
*-------------------------------------------------------------------------------
// TODO: estima por OLS-EF y guarda el resultado (estimates store OLS)


*-------------------------------------------------------------------------------
* C. ESTIMACION PPML  (Santos Silva-Tenreyro):                      [TODO #C]
*    La dependiente es el NIVEL de exportaciones (retiene los ceros).
*-------------------------------------------------------------------------------
// TODO: estima por PPML-EF y guarda el resultado (estimates store PPML)


*-------------------------------------------------------------------------------
* D. COMPARACION                                                    [TODO #D]
*    Compara theta_OLS y theta_PPML; cuantos obs usa cada uno (ceros)?
*-------------------------------------------------------------------------------
// TODO: esttab OLS PPML, keep(ln_z) b(3) se(3)   (y/o coefplot)


*-------------------------------------------------------------------------------
* E. RELACION PARCIAL (binscatter)                                  [TODO #E]
*    Visualiza la relacion productividad-exportaciones neta de EF.
*-------------------------------------------------------------------------------
// TODO: genera un grafioc de tipo binscatter 


*-------------------------------------------------------------------------------
* F. VCR DE BALASSA                                                 [TODO #F]
*    RCA_ik = (x_ik/sum_k x_ik)/(sum_i x_ik/sum_ik x_ik). Elige Bolivia (BOL).
*-------------------------------------------------------------------------------
// TODO: construye rca y lista/grafica los sectores de BOL con rca>1


*-------------------------------------------------------------------------------
* G. INTERPRETACION (en el memo)                                    [TODO #6]
*    theta>0. Interpreta su magnitud (fuerza de la ventaja comparativa y
*    elasticidad de comercio). Discute ceros, endogeneidad y error de medicion.
*-------------------------------------------------------------------------------

log close
display as result "Completaste el Lab 1. Revisa output/ y figuras/."
*=============================== fin de la plantilla ===========================
