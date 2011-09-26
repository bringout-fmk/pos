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


// provjeri da li broj odgovara artiklu
function c_br_obuce(nBroj, cIdObuca)
*{
local nObType
nObType := g_ob_type(cIdObuca)

if nObType == 0
	return .f.
endif

do case
	case nObType == 1 .and. ob_rang_muska(nBroj)
		return .t.
	case nObType == 2 .and. ob_rang_zenska(nBroj)
		return .t.
	case nObType == 3 .and. ob_rang_djecija(nBroj)
		return .t.
endcase

// set error
cStr:="Artikal pripada rangu velicina "

if nObType == 1
	cStr += "od 39 - 50"
endif
if nObType == 2
	cStr += "od 36 - 42"
endif
if nObType == 3
	cStr += "od 12 - 35"
endif

MsgBeep(cStr + " !#Ponovite unos.")

return .f.
*}


// provjeri tip obuce na osnovu sifre obuce
function g_ob_type(id_obuca)
*{
local nType
local cPom

cPom := RIGHT(id_obuca, 1)

do case
	case cPom == "1"
		nType := 1
	case cPom == "2"
	 	nType := 2
	case cPom == "3" .or. cPom == "4"
		nType := 3
	otherwise
		nType := 0
endcase

return nType
*}

// ispituje da li je nSelRang u rangu muske cipele
function ob_rang_muska(nSelRang)
local aPom := {}
set_rang(39, 50, 0.5, @aPom)
return get_rang(nSelRang, aPom)

// ispituje da li je nSelRang u rangu zenske cipele
function ob_rang_zenska(nSelRang)
local aPom := {}
set_rang(34, 42, 0.5, @aPom)
return get_rang(nSelRang, aPom)


// ispituje da li je nSelRang u rangu djecije cipele
function ob_rang_djecija(nSelRang)
local aPom := {}
set_rang(12, 35, 0.5, @aPom)
return get_rang(nSelRang, aPom)


// dodaje u matricu aRang velicine od nMin do nMax po koraku nStep
static function set_rang(nMin, nMax, nStep, aRang)
for i:=nMin to nMax step nStep
	AADD(aRang, {i})
next
return

// provjerava vrijednost nRang u matrici
static function get_rang(nRang, aRang)
if ASCAN(aRang, {|xVal| xVal[1] == nRang}) > 0
	return .t.
else
	return .f.
endif
return


// ispravka velicine
function ed_velicina()
private GetList:={}
Scatter()
Box(,5,40)
	@ 1+m_x, 2+m_y SAY "Ispravka velicine artikla:"
	@ 4+m_x, 2+m_y SAY "Nova velicina:" GET _velicina VALID {|| _velicina==0 .or. c_br_obuce(_velicina, _idroba)}
	read
BoxC()
Gather()
oBrowse:refreshCurrent()
do while !oBrowse:stable 
	oBrowse:Stabilize()
enddo

return (DE_CONT)


