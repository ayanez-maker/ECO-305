*===============================================================================
* ECO-305  COMERCIO INTERNACIONAL  |  Universidad Catolica Boliviana
* LABORATORIO 0  ---  La matriz exportadora de Bolivia, 2000-2024
* Archivo : Lab0_solucion.do      
* Autor   : E. Yanez
* Objeto  : construir la matriz producto x destino x anio y medir concentracion,
*           diversificacion y comercio intra-industrial de las exportaciones.
* Requisitos: Comandos de base; no requiere paquetes externos.
*===============================================================================
clear all
set more off
* --- Ruta de trabajo: ejecutar desde la carpeta Lab0/ -------------------------
cd "C:\Users\Usuario\Desktop\ucb-ci\Nuevo curso de comercio internacional\Lab0"
capture mkdir output
capture mkdir figuras
capture log close
log using "output/Lab0_solucion.log", replace text

*-------------------------------------------------------------------------------
* PARTE A.  ADQUISICION DEL DATO REAL EN UN COMTRADE
*-------------------------------------------------------------------------------
* El extracto distribuido (datos/comtrade_bol_2000_2024.csv) esta CALIBRADO a los
* agregados oficiales (INE/IBCE/UN Comtrade) para que el do-file sea reproducible
* sin clave. Para reemplazarlo por la descarga LITERAL de UN Comtrade:
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* PARTE B.  IMPORTACION Y DEPURACION
*-------------------------------------------------------------------------------
import delimited "datos/comtrade_bol_2000_2024.csv", varnames(1) stringcols(3) clear
* cmd_code se fuerza a texto (stringcols 3) para preservar ceros: "02","08".

* Tipos y etiquetas
capture destring year, replace
capture destring value_usd, replace
encode flow, gen(flowc)                  // X / M
label var value_usd "Valor comerciado (US$ corrientes)"
gen double value_mn = value_usd/1e6
label var value_mn  "Valor (US$ millones)"

* Clasificacion en macro-secciones (para la descomposicion de Theil y figuras)
gen section = "Otros"
replace section = "Hidrocarburos" if cmd_code=="27"
replace section = "Minerales"     if inlist(cmd_code,"26","71","80","25")
replace section = "Agroindustria" if inlist(cmd_code,"02","08","12","15","23")
* (en importaciones 27 = combustibles refinados; se mantiene como Hidrocarburos)

* Chequeos de integridad
assert value_usd>0 & !missing(value_usd)
isid year flow cmd_code partner_iso3       // clave unica de la celda
tab year flow
compress
save "output/bol_trade_long.dta", replace

*===============================================================================
* PARTE C.  MATRIZ EXPORTADORA  (producto x destino)  +  evolucion
*===============================================================================
* Matriz producto x destino del ultimo anio (formato ancho para inspeccion)
preserve
    keep if flow=="X" & year==2024
    collapse (sum) value_mn, by(cmd_code partner_iso3)
    reshape wide value_mn, i(cmd_code) j(partner_iso3) string
    export excel using "output/matriz_2024_prod_x_destino.xlsx", replace firstrow(variables)
restore

*===============================================================================
* PARTE D.  CONCENTRACION:  HERFINDAHL-HIRSCHMAN  (productos y destinos)
*===============================================================================
* --- HHI de PRODUCTOS por anio: HHI = sum_p s_p^2 -----------------------------
preserve
    keep if flow=="X"
    collapse (sum) v=value_usd, by(year cmd_code)
    bysort year: egen toty = total(v)
    gen sh  = v/toty
    gen sh2 = sh^2
    collapse (sum) hhi_prod=sh2 (count) n_prod=v, by(year)
    label var hhi_prod "HHI de productos (0-1)"
    label var n_prod   "N de productos exportados"
    tempfile hhip
    save `hhip'
restore

* --- HHI de DESTINOS por anio -------------------------------------------------
preserve
    keep if flow=="X"
    collapse (sum) v=value_usd, by(year partner_iso3)
    bysort year: egen toty = total(v)
    gen sh2 = (v/toty)^2
    collapse (sum) hhi_dest=sh2, by(year)
    label var hhi_dest "HHI de destinos (0-1)"
    tempfile hhid
    save `hhid'
restore

*===============================================================================
* PARTE E.  DIVERSIFICACION:  INDICE DE THEIL  y  descomposicion between/within
*===============================================================================
* Theil normalizado de productos: T = sum_p s_p * ln(s_p / (1/N)),  T in [0, ln N]
* Descomposicion por macro-seccion g:
* T_between = sum_g S_g * ln( S_g / (N_g/N) )      ; T_within = T - T_between
preserve
    keep if flow=="X"
    collapse (sum) v=value_usd, by(year cmd_code section)
    bysort year: egen toty   = total(v)
    bysort year: egen Nprod  = count(cmd_code)            // N productos en el anio
    gen  s   = v/toty
    gen  t_p = s*ln(s*Nprod)                              // termino producto (within total)
    * agregados de seccion
    bysort year section: egen vsec = total(v)
    bysort year section: egen Nsec = count(cmd_code)      // N productos en la seccion
    bysort year section: gen  uno  = (_n==1)              // marca 1 fila por seccion
    gen  Sg  = vsec/toty
    gen  t_b = Sg*ln( Sg/(Nsec/Nprod) ) if uno==1         // termino between (1 vez/seccion)
    collapse (sum) theil_prod=t_p theil_between=t_b, by(year)
    gen theil_within = theil_prod - theil_between
    label var theil_prod    "Theil de productos (mayor=mas concentrada)"
    label var theil_between  "Theil entre secciones"
    label var theil_within   "Theil intra seccion"
    tempfile theil
    save `theil'
restore

*===============================================================================
* PARTE F.  MARGENES EXTENSIVO E INTENSIVO
*===============================================================================
* Extensivo = N de pares (producto x destino) activos
* Intensivo = valor medio/par
preserve
    keep if flow=="X"
    gen pair = 1
    collapse (sum) exp_tot=value_usd (count) n_lines=pair, by(year)
    gen val_per_line = exp_tot/n_lines
    label var n_lines      "Margen extensivo (pares producto x destino)"
    label var val_per_line "Margen intensivo (US$ por par)"
    tempfile marg
    save `marg'
restore

*===============================================================================
* PARTE G.  COMERCIO INTRA-INDUSTRIAL:  INDICE DE GRUBEL-LLOYD
*===============================================================================
* GL_t = 1 - sum_p |X_p - M_p| / sum_p (X_p + M_p)     (agregado a HS2)
* (Stata no admite preserve anidado: usamos un .dta intermedio en output/.)
tempfile gl_all glf
preserve
    collapse (sum) v=value_usd, by(year flow cmd_code)
    reshape wide v, i(year cmd_code) j(flow) string      // vX  vM
    replace vX=0 if missing(vX)
    replace vM=0 if missing(vM)
    gen absdiff = abs(vX-vM)
    gen suma    = vX+vM
    save "output/_gl_cell.dta", replace
    * GL agregado
    collapse (sum) absdiff suma, by(year)
    gen gl = 1 - absdiff/suma
    label var gl "Grubel-Lloyd agregado (HS2)"
    save `gl_all'
    * GL excluyendo capitulos 27 (gas/diesel) y 99 (no especificado)
    use "output/_gl_cell.dta", clear
    drop if inlist(cmd_code,"27","99")
    collapse (sum) absdiff suma, by(year)
    gen gl_excl = 1 - absdiff/suma
    label var gl_excl "Grubel-Lloyd sin cap. 27 y 99"
    merge 1:1 year using `gl_all', nogen
    save `glf'
    erase "output/_gl_cell.dta"
restore

*===============================================================================
* PARTE H.  PANEL DE INDICES, EXPORTACION DE RESULTADOS
*===============================================================================
use `hhip', clear
merge 1:1 year using `hhid',  nogen
merge 1:1 year using `theil', nogen
merge 1:1 year using `marg',  nogen
merge 1:1 year using `glf',   nogen
order year exp_tot n_prod n_lines val_per_line hhi_prod hhi_dest ///
      theil_prod theil_between theil_within gl gl_excl
format hhi_* theil_* gl gl_excl %6.3f
list year hhi_prod hhi_dest theil_prod gl gl_excl if inlist(year,2000,2008,2014,2020,2024), ///
     noobs sep(0)
export excel using "output/indices_lab0.xlsx", replace firstrow(varlabels)
save "output/indices_lab0.dta", replace

*===============================================================================
* PARTE I.  FIGURAS
*===============================================================================
* Fig 2 -- Concentracion (HHI productos y destinos)
twoway (line hhi_prod year, lcolor(navy) lwidth(medthick))                     ///
       (line hhi_dest year, lcolor(orange) lwidth(medthick) lpattern(dash)),   ///
       yline(0.25, lpattern(shortdash) lcolor(gs10))                           ///
       ytitle("Indice de Herfindahl-Hirschman") xtitle("") xlabel(2000(4)2024) ///
       legend(order(1 "HHI productos" 2 "HHI destinos") rows(1) pos(6))        ///
       title("Concentracion de la canasta exportadora, Bolivia 2000-2024")     ///
       note("Umbral 0,25 = concentracion alta.  Fuente: extracto Lab 0.")
graph export "figuras/do_fig2_hhi.pdf", replace

* Fig 3 -- Theil total y descomposicion
twoway (line theil_prod year, lcolor(orange) lwidth(medthick))                 ///
       (line theil_between year, lcolor(navy))                                 ///
       (line theil_within year, lcolor(green)),                                ///
       ytitle("Indice de Theil") xtitle("") xlabel(2000(4)2024)                ///
       legend(order(1 "Total" 2 "Entre secciones" 3 "Intra seccion") rows(1) pos(6)) ///
       title("Diversificacion exportadora: descomposicion de Theil")
graph export "figuras/do_fig3_theil.pdf", replace

* Fig 4 -- Margenes
twoway (bar n_lines year, yaxis(1) color(navy%70))                             ///
       (line val_per_line year, yaxis(2) lcolor(orange) lwidth(medthick)),     ///
       ytitle("Pares activos", axis(1)) ytitle("US$ por par", axis(2))         ///
       xtitle("") xlabel(2000(4)2024)                                          ///
       legend(order(1 "Margen extensivo" 2 "Margen intensivo") rows(1) pos(6)) ///
       title("Margenes extensivo e intensivo de las exportaciones")
graph export "figuras/do_fig4_margenes.pdf", replace

* Fig 5 -- Grubel-Lloyd y sesgo de agregacion
twoway (line gl year, lcolor(green) lwidth(medthick))                          ///
       (line gl_excl year, lcolor(red) lpattern(dash)),                        ///
       ytitle("Indice de Grubel-Lloyd") xtitle("") xlabel(2000(4)2024)         ///
       yscale(range(0 0.35)) ylabel(0(0.1)0.3)                                 ///
       legend(order(1 "GL agregado (HS2)" 2 "GL sin cap. 27 y 99") rows(1) pos(6)) ///
       title("Comercio intra-industrial: el sesgo de agregacion")             ///
       note("GL agregado lo infla el cap.27 (exporta gas, importa diesel). Sin 27 y 99 -> ~0.")
graph export "figuras/do_fig5_gl.pdf", replace

* Fig 1 -- Composicion por macro-seccion (area apilada)
preserve
    use "output/bol_trade_long.dta", clear
    keep if flow=="X"
    collapse (sum) value_mn, by(year section)
    replace value_mn = value_mn/1000        // a miles de millones
    reshape wide value_mn, i(year) j(section) string
    foreach v in Hidrocarburos Minerales Agroindustria Otros {
        capture confirm variable value_mn`v'
        if _rc gen value_mn`v'=0
    }
    gen c1 = value_mnHidrocarburos
    gen c2 = c1 + value_mnMinerales
    gen c3 = c2 + value_mnAgroindustria
    gen c4 = c3 + value_mnOtros
    twoway (area c4 year, color(gs12)) (area c3 year, color(green%60))          ///
           (area c2 year, color(orange%70)) (area c1 year, color(navy)),        ///
           ytitle("Exportaciones (miles de millones US$)") xtitle("")           ///
           xlabel(2000(4)2024)                                                  ///
           legend(order(4 "Hidrocarburos" 3 "Minerales" 2 "Agroindustria" 1 "Otros") ///
                  rows(1) pos(6))                                               ///
           title("Composicion de las exportaciones por macro-seccion")
    graph export "figuras/do_fig1_composicion.pdf", replace
restore

* Fig 6 -- Destinos 2024
preserve
    use "output/bol_trade_long.dta", clear
    keep if flow=="X" & year==2024
    collapse (sum) value_mn, by(partner)
    gsort -value_mn
    keep in 1/10
    graph hbar (asis) value_mn, over(partner, sort(1) descending)               ///
        ytitle("Exportaciones 2024 (US$ millones)")                             ///
        title("Principales destinos de las exportaciones, 2024")
    graph export "figuras/do_fig6_destinos.pdf", replace
restore

*log close
display as result "Lab 0: indices y figuras generados en output/ y figuras/."
*=============================== fin del do-file ===============================
