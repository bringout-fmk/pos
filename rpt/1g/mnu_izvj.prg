#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/mnu_izvj.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.9 $
 * $Log: mnu_izvj.prg,v $
 * Revision 1.9  2003/08/08 16:25:36  sasa
 * dodani brojaci partnera i stavki
 *
 * Revision 1.8  2003/06/16 17:30:47  sasa
 * generacija zbirnog racuna
 *
 * Revision 1.7  2003/02/13 21:43:56  ernad
 * tigra - PartnSt
 *
 * Revision 1.6  2003/01/04 14:34:19  ernad
 * PartnSt - ispravke izvjestaja (umjesto I_RnGostiju staviti StanjePartnera)
 *
 * Revision 1.5  2002/12/22 20:42:02  sasa
 * dorade
 *
 * Revision 1.4  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 *
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
	AADD(opcexe,{|| PorPoTar()})
	AADD(opc,"6. najprometniji artikli")
	AADD(opcexe,{|| TopN()})
	AADD(opc,"7. stanje partnera")
	AADD(opcexe,{|| StanjePartnera()})
  	
	if IsTigra()
		AADD(opc, "8. stanje partnera - otvorene stavke")
		AADD(opcexe, {|| MnuStanjePartnera()})
	endif
	AADD(opc,"K. stanje artikala po K1 ")
  	AADD(opcexe,{|| StanjeK1()})
	AADD(opc,"A. stampa azuriranog dokumenta")
	AADD(opcexe,{|| PrepisDok()})
endif

if IzFMKIni("Tigra","Partner01","N")=="D"
	AADD(opc,"M. marsrute" )
  	AADD(opcexe,{|| Marsrute()})
else
  	AADD(opc,"-------------------")
  	AADD(opcexe,nil)
endif

if gPVrsteP
  AADD(opc,"N. pregled prometa po v.placanja")
  AADD(opcexe,{|| PrometVPl()})
endif

if IsTigra()
	AADD(opc,"X. pregled prometa partnera")
  	AADD(opcexe,{|| RptPrPa()})
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
	AADD(opcexe,{|| PorPoTar()})
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

