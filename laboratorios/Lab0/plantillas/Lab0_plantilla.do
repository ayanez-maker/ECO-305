*===============================================================================
* ECO-305  COMERCIO INTERNACIONAL  |  Universidad Catolica Boliviana
* LABORATORIO 0  ---  La matriz exportadora de Bolivia, 2000-2024
* Archivo : Lab0_plantilla.do      (PLANTILLA PARA EL ESTUDIANTE)
* Nombre  : ____________________________   Fecha: __________
*-------------------------------------------------------------------------------
* INSTRUCCIONES
*  - Completa cada bloque marcado con TODO.  No borre los encabezados.
*  - El do-file debe correr de principio a fin sin errores ("do Lab0_plantilla").
*  - Ejecutalo desde la carpeta Lab0/.  
*  - Entrega: este .do + el memo (4 pag) + base
*  - Debe desarrollarse solo con comandos de base de Stata (no paquetes externos).
*===============================================================================
clear all
set more off
* cd "C:/.../........./Lab0"
capture mkdir output
capture mkdir figuras
capture log close
log using "output/Lab0_estudiante.log", replace text

*-------------------------------------------------------------------------------
* PARTE A. IMPORTACION Y DEPURACION                           [resuelto, NO TOCAR]
*-------------------------------------------------------------------------------
* Asegura tener los datos dentro la carpeta .../Lab0/datos
import delimited "datos/comtrade_bol_2000_2024.csv", varnames(1) stringcols(3) clear

* Tipos y etiquetas
capture destring year, replace
capture destring value_usd, replace
encode flow, gen(flowc)                  // X / M
label var value_usd "Valor comerciado (US$ corrientes)"
gen double value_mn = value_usd/1e6
label var value_mn  "Valor (US$ millones)"

* Clasificacion en macro-secciones 
gen section = "Otros"
replace section = "Hidrocarburos" if cmd_code=="27"
replace section = "Minerales"     if inlist(cmd_code,"26","71","80","25")
replace section = "Agroindustria" if inlist(cmd_code,"02","08","12","15","23")

* Chequeos de integridad
assert value_usd>0 & !missing(value_usd)
isid year flow cmd_code partner_iso3
tab year flow
compress
save "output/bol_trade_long.dta", replace

*-------------------------------------------------------------------------------
* PARTE B. HHI DE PRODUCTOS Y DESTINOS POR ANIO           [TODO #B]                   
* Pista: collapse a (year cmd_code); s_p = valor/total_anual; HHI = sum s_p^2
*-------------------------------------------------------------------------------
* 1--- HHI de PRODUCTOS por anio                                  [TODO #B1]
preserve
    keep if flow=="X"
    collapse (sum) v=value_usd, by(year cmd_code)
    bysort year: egen toty = total(v)
    // TODO: genera la participacion sh y su cuadrado sh2
    // gen sh  = ____
    // gen sh2 = ____
    // TODO: colapsa a nivel anio para obtener hhi_prod (suma de sh2) y n_prod
    // collapse (sum) hhi_prod=____ (count) n_prod=____, by(year)
	// etiqueta variable
    tempfile hhip
    save `hhip'
restore

* 2--- HHI de DESTINOS por anio                                   [TODO #B2]
preserve
    keep if flow=="X"
    // TODO: replica la logica del bloque 2 pero por (year partner_iso3)
    // y guarda hhi_dest en un tempfile `hhid'
    tempfile hhid
    save `hhid'
restore

*-------------------------------------------------------------------------------
* C. INDICE DE THEIL y  descomposicion between/within            [TODO #C]
* Theil normalizado de productos: T = sum_p s_p * ln(s_p / (1/N)),  T in [0, ln N]
* Descomposicion por macro-seccion g:
* T_between = sum_g S_g * ln( S_g / (N_g/N) )      ; T_within = T - T_between
*-------------------------------------------------------------------------------
preserve
    keep if flow=="X"
    // TODO: construye un tempfile que calcule theil_prod, theil_between year
	// theil_within
    label var theil_prod    "Theil de productos (mayor=mas concentrada)"
    label var theil_between  "Theil entre secciones"
    label var theil_within   "Theil intra seccion"
    tempfile theil
    save `theil'
restore

*-------------------------------------------------------------------------------
* D. MARGENES EXTENSIVO E INTENSIVO                              [TODO #D]
* Extensivo = N de pares (producto x destino) activos
* Intensivo = valor medio/par
*-------------------------------------------------------------------------------
preserve
    keep if flow=="X"
    gen pair = 1
    // TODO: construye ambos margenes
    save `marg'
restore

*-------------------------------------------------------------------------------
* E. COMERCIO INTRA-INDUSTRIAL:  INDICE  GDERUBEL-LLOYD         [TODO #E]
*    GL = 1 - sum|X_p - M_p| / sum(X_p + M_p).  Usa reshape wide por flujo.
*    Nota: Stata no admite preserve anidado asi que usa un .dta intermedio 
*    guardalo en output como _gl_cell.dta
*    Calcula tambien GL excluyendo los capitulos "27" y "99" y compara.
*-------------------------------------------------------------------------------
* 1--- GL                                                      [TODO #E1]
tempfile glf
preserve
    collapse (sum) v=value_usd, by(year flow cmd_code)
    reshape wide v, i(year cmd_code) j(flow) string
    replace vX=0 if missing(vX)
    replace vM=0 if missing(vM)
    // TODO: genera absdiff y suma; colapsa por year; gl = 1 - absdiff/suma
    //       guarda gl y gl_excl en `glf'
    save `glf'
* 2--- GL agregado                                             [TODO #E2]	
    collapse (sum) absdiff suma, by(year)
    // TODO: calcula GL agregado y etiquetalo
    save `gl_all'
* 3--- GL capitulos 27 (gas/diesel) y 99 (no especificado)     [TODO #E3]	
	* GL excluyendo 
    use "output/_gl_cell.dta", clear
    drop if inlist(cmd_code,"27","99") 
    // TODO: calcula GL excluyendo gas/diesel y otro y etiquetalo
    save `glf'
    erase "output/_gl_cell.dta"
restore

*-------------------------------------------------------------------------------
* F.PANEL DE INDICES, EXPORTACION DE RESULTADOS                [TODO #F]
*-------------------------------------------------------------------------------
use `hhip', clear
// TODO: merge 1:1 year con `hhid', `theil, `marg', `glf'
// export excel using "output/indices_lab0.xlsx", replace firstrow(varl)
// save "output/indices_lab0.dta", replace

*-------------------------------------------------------------------------------
* G. FIGURAS                                                  [TODO #G]
*    Produce al menos: (a) HHI productos vs destinos; (b) Theil; (c) GL vs GL_excl;
*    (d) composicion por seccion (area apilada); (e) destinos 2024.  
*    Exporta a figuras/*.pdf
*-------------------------------------------------------------------------------
// TODO: twoway line ... ; graph export "figuras/fig_hhi.pdf", replace

log close
display as result "Completaste el Lab 0. Revisa output/ y figuras/."
*=============================== fin de la plantilla ===========================
