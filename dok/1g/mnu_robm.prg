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


