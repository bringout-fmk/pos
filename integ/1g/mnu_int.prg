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


/*! \fn Mnu_Integ()
 *  \brief Osnovni menij opcija provjere integriteta
 */
function Mnu_Integ()
*{
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "1. INTEG-1: stanje artikala                   ")
AADD(opcexe, {|| CaseInt1()})
AADD(opc, "2. INTEG-2: stanje prodaje ")
AADD(opcexe, {|| CaseInt2()})
AADD(opc, "O. OIDERR: provjera duplih oid-a u tabelama ")
AADD(opcexe, {|| CaseIntOid()})

Menu_SC("int")

return
*}

/*! \fn CaseInt1()
 *  \brief pokretanje integ1 testa sa menija
 */
function CaseInt1()
*{
if gSamoProdaja=="D"
	if Pitanje(,"Pokrenuti forsirani integ1 (D/N)","N") == "D"
		UpdInt1(.t., .f.)
	endif
else
	if !EmptDInt(1)
		BrisiError()
		ChkInt1(.t., .f.)
		RptInteg(.t., .f.)
	endif
endif
return
*}

/*! \fn CaseInt2()
 *  \brief pokretanje integ2 testa sa menija
 */
function CaseInt2()
*{
if gSamoProdaja=="D"
	if Pitanje(,"Pokrenuti forsirani integ2 (D/N)","N") == "D"
		UpdInt2(.t., .f.)
	endif
else
	if !EmptDInt(2)
		BrisiError()
		ChkInt2(.t., .f.)
		RptInteg(.t., .f.)
	endif
endif
return
*}


/*! \fn CaseIntOid()
 *  \brief pokretanje provjere oid-a
 */
function CaseIntOid()
*{
if gSamoProdaja=="N"
	// prvo reindexiraj
	Reindex(.t.)
	BrisiError()
	OidChk(DATE(), DATE(), .t.)
	RptInteg(.t., .f.)
endif
return
*}



