#include "\dev\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
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
AADD(opcexe,{|| RealRadnik(.t., "P", .f.) })
AADD(opc,"R. trenutna realizacija po robama")
AADD(opcexe,{|| RealRadnik(.t.,"R",.f.) })

if IsPlanika()
	AADD(opc,"M. poruke")
	AADD(opcexe,{|| Mnu_Poruke() })
endif
if IsPlNS()
	if gFissta=="D"
		AADD(opc,"F. fiskalni stampac ")
		AADD(opcexe,{|| Fissta_mnu() })
	endif
endif

if gnDebug==5
	AADD(opc,"X. TEST COM PORT")
	//AADD(opcexe,{|| ProdTestCP() })
	AADD(opcexe,{|| NotImp() })
endif

Menu_SC("prod")

if gRadniRac=="N" .and. gVodiTreb=="D"
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
AADD(opcexe,{|| SetujZakljuceno() })

Menu_SC("zrn")

return
*}

