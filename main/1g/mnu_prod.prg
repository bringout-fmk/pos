#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/main/1g/mnu_prod.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.12 $
 * $Log: mnu_prod.prg,v $
 * Revision 1.12  2004/06/08 07:32:34  sasavranic
 * Unificirane funkcije rabata
 *
 * Revision 1.11  2004/05/28 14:52:18  sasavranic
 * no message
 *
 * Revision 1.10  2003/10/21 14:54:06  sasavranic
 * uvodjenje messaging-a
 *
 * Revision 1.9  2003/06/23 09:03:45  sasa
 * nver - zakljucivanje nezakljucenih racuna
 *
 * Revision 1.8  2003/06/21 12:23:48  sasa
 * nver - zakljucivanje nezakljucenih racuna
 *
 * Revision 1.7  2003/06/16 17:30:36  sasa
 * generacija zbirnog racuna
 *
 * Revision 1.6  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.5  2002/06/15 08:35:10  sasa
 * no message
 *
 *
 */
 

/*! \fn MMenuProdavac()
*   \brief Glavni menij nivo prodavac
*   \param gVodiTreb=="D"
*   \param gRadniRac=="D"
*/
function MMenuProdavac()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

// obezbijedimo da se prodavac nalazi u radnom podrucju ! 
if gRadnoPodr<>"RADP"
	goModul:oDatabase:logAgain(STR(YEAR(DATE()),4),.t.,STR(YEAR(DATE()),4))
endif

if gRadniRac=="D"
	AADD(opc,"1. narudzba                        ")
    	AADD(opcexe,{|| Narudzba() })
    	AADD(opc,"2. zakljuci racun")
    	AADD(opcexe,{|| ZakljuciRacun() })
else
	private aRabat:={}
    	AADD(opc,"1. priprema racuna                 ")
    	AADD(opcexe,{|| Narudzba(), ZakljuciRacun() })
endif

AADD(opc,"3. promijeni nacin placanja")
AADD(opcexe,{|| PromNacPlac() })
AADD(opc,"4. prepis racuna           ")
AADD(opcexe,{|| PrepisRacuna() })
if gBrojSto=="D"
	AADD(opc,"5. zakljucivanje racuna    ")
	AADD(opcexe,{|| MnuZakljRacuna() })
endif
AADD(opc,"T. trenutni pazar smjene")
AADD(opcexe,{|| RealRadnik(.t.,"P",.f.) })
AADD(opc,"R. trenutna realizacija po robama")
AADD(opcexe,{|| RealRadnik(.t.,"R",.f.) })
AADD(opc,"P. prikaz stanja partnera")
AADD(opcexe,{|| StanjePartnera() })
if IsPlanika()
	AADD(opc,"M. poruke")
	AADD(opcexe,{|| Mnu_Poruke() })
endif
if gnDebug==5
	AADD(opc,"X. TEST COM PORT")
	AADD(opcexe,{|| ProdTestCP() })
endif

Menu_SC("prod")

if gRadniRac=="N".and.gVodiTreb=="D"
	O_DIO
    	O_ODJ
    	O__POS
    	Trebovanja()
endif
CLOSERET
return
*}



function MnuZakljRacuna()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. napravi zbirni racun            ")
AADD(opcexe,{|| RekapViseRacuna() })
AADD(opc,"2. pregled nezakljucenih racuna    ")
AADD(opcexe,{|| PreglNezakljRN() })
AADD(opc,"3. setuj sve RN na zakljuceno      ")
//AADD(opcexe,{|| SetujZakljuceno() })
AADD(opcexe,{|| NotImp() })

Menu_SC("zrn")

return
*}

