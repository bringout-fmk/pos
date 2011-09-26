/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "pos.ch"


/*! \fn Fissta_mnu()
 *  \brief Menij za rad sa FISSTA
 */
function Fissta_mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. startanje interfejsa FisCTT    ")
AADD(opcexe, {|| CheckFisCTTStarted() })

if kLevel<>L_PRODAVAC
	AADD(opc, "2. fiskalni izvjestaji               ")
	AADD(opcexe, {|| FisRpt_Mnu() })
	AADD(opc, "3. servisne funkcije              ")
	AADD(opcexe, {|| FisServ_Mnu() })
endif


Menu_Sc("fst")

return
*}



/*! \fn FisRpt_Mnu()
 *  \brief Menij sa fiskalnim izvjestajima
 */
function FisRpt_Mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fiskalni dnevni izvjestaj         ")
AADD(opcexe, {|| FormRptDnevni() })
AADD(opc, "2. fiskalni izvjestaj za period      ")
AADD(opcexe, {|| FormRptPeriod() })
AADD(opc, "3. fiskalni izvjestaj presjek stanja ")
AADD(opcexe, {|| FormRptPresjek() })

Menu_Sc("frt")

return
*}


/*! \fn FisServ_Mnu()
 *  \brief Menij sa servisnim funkcijama
 */
function FisServ_Mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. ponistavanje racuna - nestalo papira    ")
AADD(opcexe, {|| FormRnErase() })

Menu_Sc("fsv")

return
*}



