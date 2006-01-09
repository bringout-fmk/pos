#include "\dev\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
function Izvj()
*{

if gModul=="HOPS"
	IzvjH()
else
	IzvjT()
endif
return .f.
*}


function IzvjT()
*{

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. realizacija                      ")
AADD(opcexe,{|| RealMenu()})

if gVrstaRS=="K"
	AADD(opc,"----------------------------")
	AADD(opcexe,nil)
  	AADD(opc,"3. najprometniji artikli")
	AADD(opcexe,{|| TopN() })
	AADD(opc,"4. stampa azuriranog dokumenta")
	AADD(opcexe,{|| PrepisDok() })
else
  	// server, samostalna kasa TOPS
	
	AADD(opc,"2. stanje artikala ukupno")
	AADD(opcexe,{|| StanjePM() })
	
  	if gVodiOdj=="D"
    		AADD(opc,"3. stanje artikala po odjeljenjima")
		AADD(opcexe,{|| Stanje()})
  	else
    		AADD(opc,"--------------------")
		AADD(opcexe,nil)
  	endif
  	
	AADD(opc,"4. kartice artikala")
	AADD(opcexe,{|| Kartica()})
	AADD(opc,"5. porezi po tarifama")
	AADD(opcexe,{|| IF(IsPDV(), PDVPorPoTar(),PorPoTar())})
	AADD(opc,"6. najprometniji artikli")
	AADD(opcexe,{|| TopN()})
	AADD(opc,"7. stanje partnera")
	AADD(opcexe,{|| StanjePartnera()})
	AADD(opc,"K. stanje artikala po K1 ")
  	AADD(opcexe,{|| StanjeK1()})
	AADD(opc,"A. stampa azuriranog dokumenta")
	AADD(opcexe,{|| PrepisDok()})
endif

  	AADD(opc,"-------------------")
  	AADD(opcexe,nil)

if gPVrsteP
  AADD(opc,"N. pregled prometa po v.placanja")
  AADD(opcexe,{|| PrometVPl()})
endif

Menu_SC("izvt")
return .f.
*}


function IzvjH()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

// Provjeravam usaglasenost podataka
UPodataka() 

AADD(opc,"1. realizacija                         ")
AADD(opcexe,{|| RealMenu()})
AADD(opc,"2. stanje racuna gostiju")
//HOPS - Stanje racuna gostiju ... ovo niko ne koristi ...
AADD(opcexe,{|| I_RNGostiju() })
if gVrstaRS=="K"
	AADD(opc,"----------------------------")
	AADD(opcexe,nil)
  	AADD(opc,"4. najprometniji artikli")
	AADD(opcexe,{|| TopN() })
else
  	// server, samostalna kasa
  	AADD(opc,"3. stanje artikala ukupno")
	AADD(opcexe,{|| StanjePM() })
  	if gVodiOdj=="D"
    		AADD(opc,"4. stanje artikala po odjeljenjima")
		AADD(opcexe,{|| Stanje()})
  	else
    		AADD(opc,"--------------------")
		AADD(opcexe,nil)
  	endif
  	AADD(opc,"5. kartice artikala")
	AADD(opcexe,{|| Kartica()})
	AADD(opc,"6. porezi po tarifama")
	AADD(opcexe,{|| IF(IsPDV(), PDVPorPoTar(), PorPoTar())})
	AADD(opc,"7. najprometniji artikli")
	AADD(opcexe,{|| TopN()})
endif

AADD(opc,"8. stanje partnera")
AADD(opcexe,{|| StanjePartnera()})
AADD(opc,"K. stanje artikala po K1 ")
AADD(opcexe,{|| StanjeK1()})
AADD(opc,"A. stampa azuriranog dokumenta")
AADD(opcexe,{|| PrepisDok()})

Menu_SC("izvh")
return
*}



function UPodataka()
*{

if gModul=="HOPS"
	xx:=m_x 
	yy:=m_y
  	MsgO("Da provjerimo usaglasenost podataka...")
    	O_POS 
	O_DOKS
    	SET ORDER TO 4
    	SEEK "42"+OBR_NIJE
  	MsgC()
  	if doks->(FOUND())
    		// ima neobradjenih racuna ili su racuni mijenjani!!!
    		close all
    		GenUtrSir(gDatum,gDatum,gSmjena)
  	endif
  	close all
  	m_x:=xx
	m_y:=yy
  	@ m_x+1,m_y+1 SAY ""
endif
return
*}

