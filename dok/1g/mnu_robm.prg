#include "\cl\sigma\fmk\pos\pos.ch"
#include "setcurs.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/mnu_robm.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.6 $
 * $Log: mnu_robm.prg,v $
 * Revision 1.6  2003/06/16 17:30:26  sasa
 * generacija zbirnog racuna
 *
 * Revision 1.5  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.4  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 

/*! \fn MenuRobMat()
 *  \brief Menij robno materijalnog poslovanja
 */
 
function MenuRobMat()
*{
private Opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. unos dokumenata        ")
AADD(opcexe, {|| MnuDok() })
AADD(opc, "2. generacija dokumenata")
AADD(opcexe, {|| MnuGenDok() })

Menu_SC("mrbm")
return
*}

function MnuGenDok()
*{

private Opc:={}
private opcexe:={}
private Izbor:=1

if gModul=="HOPS" .and. gPosSirovine=="D"
	AADD(Opc,"6. generisi utrosak sirovina           ")
	AADD(opcexe,{|| GenUtrSir()})
endif

if gPosPrimPak="D"
	AADD(Opc, "P. gendok: svedi na primarno pakovanje")
	AADD(opcexe, {|| SvediNaPrP() })
endif

if gPosKalk=="D"
	AADD(Opc, "K. prenos sifrarnika iz KALK->TOPS")
	AADD(opcexe, {|| SifKalkTops() })
endif

Izbor:=1
Menu_SC("gdok")
*}




