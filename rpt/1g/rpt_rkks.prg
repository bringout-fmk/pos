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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_rkks.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.23 $
 * $Log: rpt_rkas.prg,v $
 *
 *
 */

/*! \file fmk/pos/rpt/1g/rpt_rkks.prg
 *  \brief Izvjestaj: pregled reklamacija
 */


/*! \fn ReklKase(dDat0, dDat1)
 *  \param dDat0 - datum od
 *  \param dDat1 - datum do
 *  \param cVarijanta - varijanta izvjestaja
 *  \brief Izvjestaj: pregled reklamacija kase
 */
function ReklKase(dDOd, dDDo, cVarijanta)
*{
private cIdPos:=gIdPos
private dDat0
private dDat1
private cFilter:=".t."

set cursor on

if (dDOd == nil)  
	dDat0:=gDatum
	dDat1:=gDatum
else
	dDat0:=dDOd
	dDat1:=dDDo
endif

if (cVarijanta==nil)
	cVarijanta:="0"
endif

ODbRpt()

if (cVarijanta == "0")
	cIdPos:=gIdPos
else
	if FrmRptVars(@cIdPos, @dDat0, @dDat1)==0
		return 0
	endif
endif

START PRINT CRET
Zagl(dDat0, dDat1, cIdPos)


O_DOKS
SetFilter(@cFilter, cIdPos, dDat0, dDat1)

nCnt:=0
? "----------------------------------------"
? "Rbr  Datum     BrDok           Iznos"
? "----------------------------------------"
go top

do while !EOF() .and. idvd == VD_REK
	++ nCnt
	? STR(nCnt, 3)
	?? SPACE(2) + DTOC(field->datum)
	?? SPACE(2) + PADR(ALLTRIM(field->idvd) + "-" +  ALLTRIM(field->brdok),10)
	?? SPACE(2) + DokIznos(.t., field->idpos, field->idvd, field->datum, field->brdok)
	skip
enddo

END PRINT

close all

return .t.
*}


/*! \fn FrmRptVars(cIdPos, dDat0, dDat1)
 *  \brief Uzmi varijable potrebne za izvjestaj
 *  \return 0 - nije uzeo, 1 - uzeo uspjesno
 */
static function FrmRptVars(cIdPos, dDat0, dDat1)
*{
local aNiz

aNiz:={}
cIdPos:=gIdPos

if gVrstaRS<>"K"
	AADD(aNiz,{"Prod. mjesto (prazno-sve)","cIdPos","cidpos='X'.or.EMPTY(cIdPos) .or. P_Kase(@cIdPos)","@!",})
endif

AADD(aNiz,{"Izvjestaj se pravi od datuma","dDat0",,,})
AADD(aNiz,{"                   do datuma","dDat1",,,})

do while .t.
	if cVarijanta<>"1"  // onda nema read-a
		if !VarEdit(aNiz,6,5,24,74,"USLOVI ZA IZVJESTAJ PREGLED REKLAMACIJA","B1")
			CLOSE ALL 
			return 0
		endif
	endif
enddo

return 1
*}


static function Zagl(dDat0, dDat1, cIdPos)
*{

?? gP12CPI
if glRetroakt
	? PADC("REKLAMACIJE NA DAN "+FormDat1(dDat1),40)
else
	? PADC("REKLAMACIJE NA DAN "+FormDat1(gDatum),40)
endif
? PADC("-------------------------------------",40)

O_KASE
if EMPTY(cIdPos)
	? "PRODAJNO MJESTO: SVA"
else
	? "PRODAJNO MJESTO: "+cIdPos+"-"+Ocitaj(F_KASE,cIdPos,"NAZ")
endif

? "PERIOD     : "+FormDat1(dDat0)+" - "+FormDat1(dDat1)

return
*}


static function SetFilter(cFilter, cIdPos, dDat0, dDat1)
*{

SELECT DOKS
SET ORDER TO TAG "2"  // "2" - "IdVd+DTOS (Datum)+Smjena"

cFilter += " .and. idvd == '98' .and. sto <> 'P   ' " 
cFilter += " .and. idpos == '" + cIdPos + "'"
if (dDat0 <> nil)
	cFilter += " .and. datum >= " + Cm2Str(dDat0) 
endif
if (dDat1 <> nil)
	cFilter += " .and. datum <= " + Cm2Str(dDat1) 
endif

if !(cFilter==".t.")
	SET FILTER TO &cFilter
endif

return
*}

/*! \fn TblCrePom()
 *  \brief Kreiranje pomocne tabele za izvjestaj realizacije kase
 */

static function TblCrePom()
*{
local aDbf := {}
local cPomDbf

AADD(aDbf,{"IdPos"    ,"C",  2, 0})
AADD(aDbf,{"IdRadnik" ,"C",  4, 0})
AADD(aDbf,{"IdVrsteP" ,"C",  2, 0})
AADD(aDbf,{"IdOdj"    ,"C",  2, 0})
AADD(aDbf,{"IdRoba"   ,"C", 10, 0})
AADD(aDbf,{"IdCijena" ,"C",  1, 0})
AADD(aDbf,{"Kolicina" ,"N", 12, 3})
AADD(aDbf,{"Iznos"    ,"N", 20, 5})
AADD(aDbf,{"Iznos2"   ,"N", 20, 5})
AADD(aDbf,{"Iznos3"   ,"N", 20, 5})
AADD(aDbf,{"K1"       ,"C",  4, 0})
AADD(aDbf,{"K2"       ,"C",  4, 0})

NaprPom(aDbf)

cPomDbf:=ToUnix(PRIVPATH+"pom.dbf")
CREATE_INDEX("1" ,"IdPos+IdRadnik+IdVrsteP+IdOdj+IdRoba+IdCijena",cPomDbf,.t.)
CREATE_INDEX("2" ,"IdPos+IdOdj+IdRoba+IdCijena"                  ,cPomDbf,.f.)
CREATE_INDEX("3" ,"IdPos+IdRoba+IdCijena"                        ,cPomDbf,.f.)
CREATE_INDEX("4" ,"IdPos+IdVrsteP"                               ,cPomDbf,.f.)
CREATE_INDEX("K1","IdPos+K1+idroba"                              ,cPomDbf,.f.)

use (cPomDbf) new
set order to 1

return
*}

