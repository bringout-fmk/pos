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
#include "setcurs.ch"

// --------------------------------------------
// menij robno-materijalno poslovanje
// --------------------------------------------
function MenuRobMat()
private Opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. unos dokumenata        ")
AADD(opcexe, {|| MnuDok() })
AADD(opc, "2. generacija dokumenata")
AADD(opcexe, {|| MnuGenDok() })

Menu_SC("mrbm")
return

// --------------------------------------------
// menij generacije dokumenata
// --------------------------------------------
function MnuGenDok()
private Opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. generacija dokumenta pocetnog stanja     ")
AADD(opcexe, {|| p_poc_stanje() })

if gModul=="HOPS" .and. gPosSirovine=="D"
	AADD(Opc,"6. generisi utrosak sirovina")
	AADD(opcexe,{|| GenUtrSir()})
endif

if gPosKalk=="D"
	AADD(Opc, "K. prenos sifrarnika iz KALK->TOPS")
	AADD(opcexe, {|| SifKalkTops() })
endif

Izbor:=1
Menu_SC("gdok")
return


