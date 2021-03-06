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
 */
 
 
function MenuSifre()
*{
if gModul=="HOPS"
	HSifreIzbor()
else
	SifreT()
endif
return
*}


/*! \fn HSifreIzbor()
 *  \brief Izbor sifrarnika modula HOPS
 */

function HSifreIzbor()
*{
private opc:={}
private opcexe:={}
private Izbor:={}

OSif()

AADD(opc, "1. opci sifrarnik                ")
AADD(opcexe, {|| SifreHOpc() })
AADD(opc, "2. pos specificni sifrarnici")
AADD(opcexe, {|| SifreHSpec() })

Izbor:=1
Menu_SC("sifi")
return
*}



/*! \fn SifreHOpc()
 *  \brief specificni pos sifrarnici
 */

function SifreHOpc()
*{
private opc:={}
private opcexe:={}
private Izbor:={}

AADD(opc, "1. vrste placanja                   ")
AADD(opcexe, {|| P_VrsteP() })
AADD(opc, "2. valute")
AADD(opcexe, {|| P_Valuta(), SetNazDVal() })
AADD(opc, "3. partneri")
AADD(opcexe, {|| P_Gosti() })
AADD(opc, "4. sifk")
AADD(opcexe, {|| P_SifK() })
AADD(opc, "5. uredjaji za stampu")
AADD(opcexe, {|| P_Uredj() })

if gVrstaRS == "K"
      	// metalurg ...
      	AADD (opc, "6. uredjaji-odjeljenja")
	AADD(opcexe, {|| NotImp() })
      	AADD (opc, "7. robe-iznimci")
	AADD(opcexe, {|| NotImp() })
endif

Izbor:=1
Menu_SC("sifo")

return
*}


/*! \fn SifreHSpec()
 *  \brief Pregled sifrarnika za HOPS
 */
function SifreHSpec()
*{
private opc:={}
private opcexe:={}
private Izbor:={}

AADD(opc, "1. robe/artikli                     ")
AADD(opcexe, {|| P_RobaPOS() })
AADD(opc, "2. sirovine")
AADD(opcexe, {|| P_Sirov() })
AADD(opc, "3. tarife")
AADD(opcexe, {|| P_Tarifa() })
AADD(opc, "4. odjeljenja")
AADD(opcexe, {|| P_Odj() })
AADD(opc, "5. dijelovi objekta")
AADD(opcexe, {|| P_Dio() })
AADD(opc, "6. kase (prodajna mjesta)")
AADD(opcexe, {|| P_Kase()})
AADD(opc,"7. normativi")
AADD(opcexe, {|| P_Sast() })
AADD(opc,"8. stampa normativa")
AADD(opcexe, {|| ISast() })

if kLevel < L_UPRAVN
    	AADD (opc,"9. statusi radnika")
	AADD(opcexe, {|| P_StRad() })
    	AADD (opc,"10. osoblje")
	AADD(opcexe, {|| P_Osob() })
endif

Izbor:=1
Menu_SC("sifs")
return
*}



/*! \fn SifreT()
 *  \brief Pregled sifrarnika TOPS-a
 */
 
function SifreT()
*{
private opc:={}
private opcexe:={}
private Izbor:={}

AADD(opc, "1. robe/artikli                ")
AADD(opcexe, {|| P_RobaPOS() })
AADD(opc, "2. tarife")
AADD(opcexe, {|| P_Tarifa() })
AADD(opc, "3. vrste placanja")
AADD(opcexe, {|| P_VrsteP() })
AADD(opc, "4. valute")
AADD(opcexe, {|| P_Valuta(), SetNazDVal() })
AADD(opc, "5. partneri")
AADD(opcexe, {|| P_Gosti() })
AADD(opc, "6. odjeljenja")
AADD(opcexe, {|| P_Odj() })
AADD(opc, "7. kase (prodajna mjesta)")
AADD(opcexe, {|| P_Kase()})
AADD(opc, "8. sifk")
AADD(opcexe, {|| P_SifK() })
AADD(opc, "9. uredjaji za stampu")
AADD(opcexe, {|| P_Uredj() })

if klevel < L_UPRAVN
	AADD(opc,"A. statusi radnika")
	AADD(opcexe, {|| P_StRad() })
	AADD(opc,"B. osoblje")
	AADD(opcexe, {|| P_Osob() })
endif

AADD(opc,"Z. promjena sifre PR")
AADD(opcexe, {|| KL_PRacuna() })

OSif()

Izbor:=1
Menu_SC("sift")
*}


