#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/main/1g/params.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.14 $
 * $Log: params.prg,v $
 * Revision 1.14  2004/05/21 11:25:02  sasavranic
 * Uvedena opcija popusta preko odredjenog iznosa
 *
 * Revision 1.13  2004/05/19 12:16:44  sasavranic
 * no message
 *
 * Revision 1.12  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.11  2002/07/09 13:05:41  ernad
 *
 *
 * debug planika - sitnice
 *
 * Revision 1.10  2002/06/27 08:13:00  sasa
 * no message
 *
 * Revision 1.8  2002/06/27 07:35:33  sasa
 * no message
 *
 * Revision 1.7  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.6  2002/06/15 08:35:10  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/pos/main/1g/params.prg
 *  \brief Podesavanje parametara
 */
 

/*! \fn Parametri()
 *  \brief Glavni menij za izbor podesavanja parametara rada programa		
 */

function Parametri()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. podaci kase                    ")
AADD(opcexe,{|| ParPodKase()})
AADD(opc,"2. principi rada")
AADD(opcexe,{|| ParPrRada()})
AADD(opc,"3. izgled racuna")
AADD(opcexe,{|| ParIzglRac()})
AADD(opc,"4. cijene")
AADD(opcexe,{|| ParCijene()})
AADD(opc,"5. postavi vrijeme i datum kase")
AADD(opcexe,{|| PostaviDat()})

Menu_SC("par")
return .f.
*}


/*! \fn ParPodKase()
 *  \brief Podesavanje osnovnih podataka o kasi
 */

function ParPodKase()
*{

local aNiz:={}
local cPom:=""

private cIdPosOld:=gIdPos
private cHistory:=" "
private aHistory:={}
private cSection:="1"

O_PARAMS

// Citam postojece/default podatke o kasi
Rpar("n8",@gVrstaRS)
Rpar("na",@gIdPos)
Rpar("PD",@gPostDO)
Rpar("DO",@gIdDio)
Rpar("n9",@gServerPath)
Rpar("kT",@gKalkDest)
Rpar("Mv",@gModemVeza)
Rpar("sV",@gStrValuta)
Rpar("n0",@gLocPort)
Rpar("n7",@gGotPlac)
Rpar("nX",@gDugPlac)

gServerPath:=padr(gServerPath,40)
gKalkDest:=padr(gKalkDest,40)
gDuploKum:=padr(gDuploKum,30)
gDuploSif:=padr(gDuploSif,30)
gFMKSif:=padr(gFmkSif,30)

UsTipke()
set cursor on

AADD(aNiz,{"Vrsta radne stanice (K-kasa, A-samostalna kasa, S-server)" , "gVrstaRS", "gVrstaRS$'KSA'", "@!", })
AADD(aNiz,{"Oznaka/ID prodajnog mjesta" , "gIdPos", "NemaPrometa(cIdPosOld,gIdPos)", "@!", })

if gModul=="HOPS"
	AADD(aNiz,{"Ima li objekat zasebne cjeline (dijelove) D/N", "gPostDO","gPostDO$'DN'", "@!", })
  	AADD(aNiz,{"Oznaka/ID dijela objekta", "gIdDio",, "@!", })
endif

AADD(aNiz,{"Putanja korijenskog direktorija modula na serveru" , "gServerPath", , , })
AADD(aNiz,{"Destinacija datoteke TOPSKA" , "gKALKDEST", , , })
AADD(aNiz,{"Koristi se modemska veza D/N", "gModemVeza","gModemVeza$'DN'", "@!", })
AADD(aNiz,{"Lokalni port za stampu racuna" , "gLocPort", , , })
AADD(aNiz,{"Oznaka/ID gotovinskog placanja" , "gGotPlac",, "@!", })
AADD(aNiz,{"Oznaka/ID placanja duga       " , "gDugPlac",, "@!", })
AADD(aNiz,{"Oznaka strane valute" , "gStrValuta",, "@!", })
AADD(aNiz,{"Podesenja nonsens D/N" , "gColleg",, "@!", })
AADD(aNiz,{"Azuriraj u pomocnu bazu" , "gDuplo",, "@!", "gDuplo$'DN'"})
AADD(aNiz,{"Direktorij kumulativa za pom bazu","gDuploKum",, "@!",})
AADD(aNiz,{"Direktorij sifrarnika za pom bazu","gDuplosif",, "@!",})
AADD(aNiz, {"Direktorij sifrarnika FMK        ","gFMKSif",, "@!",})
VarEdit(aNiz,7,2,24,78,"PARAMETRI RADA PROGRAMA - PODACI KASE","B1")

BosTipke()

// Upisujem nove parametre
if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre PZ")
    	Wpar("n8",gVrstaRS, .t.,"P")
    	Wpar("na",gIdPos, .t.,"D")
    	Wpar("PD",gPostDO, .t.,"D")
    	Wpar("DO",gIdDio, .t.,"D")
    	Wpar("n9",gServerPath,.f.)     // pathove ne diraj
    	Wpar("kT",gKalkDest,.f.)       // pathove ne diraj
    	Wpar("Mv",gModemVeza, .t.,"D")
    	Wpar("n0",gLocPort, .t.,"D")
    	Wpar("n7",gGotPlac, .t.,"D")
    	Wpar("nX",gDugPlac, .t.,"D")
    	Wpar("sV",gStrValuta, .t.,"D")
    	Wpar("Co",gColleg, .t.,"D")
    	Wpar("Du",gDuplo, .t.,"Z")
    	Wpar("D7",trim(gDuploKum),.f.) // pathove ne diraj
    	Wpar("D8",trim(gDuploSif),.f.) // pathove ne diraj
    	Wpar("D9",trim(gFmkSif),.f.)   // pathove ne diraj
    	MsgC()
endif

gServerPath:=ALLTRIM(gServerPath)

if (RIGHT(gServerPath,1)<>SLASH)
	gServerPath+=SLASH
endif

return
*}


/*! \fn ParPrRada()
 *  \brief Podesavanje parametara principa rada kase
 */

function ParPrRada()
*{
local aNiz:={}
local cPrevPSS
local cPom:=""
private cSection:="1"
private cIdPosOld:=gIdPos
private cHistory:=" "
private aHistory:={}

cPrevPSS:=gPocStaSmjene

O_PARAMS

Rpar("n2",@gVodiTreb)

if (!IsPlanika())
	Rpar("zc",@gZadCij)
endif

Rpar("vO",@gVodiOdj)
Rpar("RR",@gRadniRac)
Rpar("Dz",@gDirZaklj)
Rpar("BS",@gBrojSto)
Rpar("n5",@gDupliArt)
Rpar("Nu",@gDupliUpoz)
Rpar("Ns",@gPratiStanje)
Rpar("nh",@gPocStaSmjene)
Rpar("nj",@gStamPazSmj)
Rpar("nk",@gStamStaPun)
Rpar("vs",@gVsmjene)
Rpar("ST",@gSezonaTip)
Rpar("Si",@gSifUpravn)
Rpar("Bc",@gEntBarCod)

UsTipke()
set cursor on

if gModul=="HOPS"
	aNiz:={{"Da li se vode trebovanja (D/N)" , "gVodiTreb", "gVodiTreb$'DN'", "@!", }}
  	AADD (aNiz, {"Da li se koriste radni racuni(D/N)" , "gRadniRac", "gRadniRac$'DN'", "@!", })
  	AADD (aNiz, {"Ako se ne koriste, da li se racun zakljucuje direktno (D/N)" , "gDirZaklj", "gDirZaklj$'DN'", "@!", })
  	AADD (aNiz, {"Da li je broj stola obavezan (D/N/0)", "gBrojSto", "gBrojSto$'DN0'", "@!", })
else
  	aNiz:={}
  	AADD (aNiz, {"Da li se racun zakljucuje direktno (D/N)" , "gDirZaklj", "gDirZaklj$'DN'", "@!", })
  	AADD (aNiz, {"Da li u u objektu postoje odjeljenja (D/N)" , "gVodiodj", "gVodiOdj(@gVodiOdj)", "@!",})
endif

AADD (aNiz, {"Dopustiti dupli unos artikala na racunu (D/N)" , "gDupliArt", "gDupliArt$'DN'", "@!", })
AADD (aNiz, {"Ako se dopusta dupli unos, da li se radnik upozorava(D/N)" , "gDupliUpoz", "gDupliUpoz$'DN'", "@!", })
AADD (aNiz, {"Da li se prati pocetno stanje smjene (D/N)" , "gPocStaSmjene", "gPocStaSmjene$'DN!'", "@!", })
AADD (aNiz, {"Da li se po zakljucenju smjene stampa ukupni pazar (D/N)" , "gStamPazSmj", "gStamPazSmj$'DN'", "@!", })
AADD (aNiz, {"Da li se prati stanje zaliha robe na prodajnim mjestima (D/N/!)" , "gPratiStanje", "gPratiStanje$'DN!'", "@!", })

if gModul=="HOPS"
	AADD (aNiz, {"Da li se po zakljucenju smjene stampa stanje puktova (D/N)" , "gStamStaPun", "gStamStaPun$'DN'", "@!", })
else
  	AADD (aNiz, {"Da li se po zakljucenju smjene stampa stanje odjeljenja (D/N)" , "gStamStaPun", "gStamStaPun$'DN'", "@!", })
endif

AADD (aNiz, {"Voditi po smjenama (D/N)" , "gVSmjene", "gVsmjene$'DN'", "@!", })
AADD (aNiz, {"Tip sezona M-mjesec G-godina" , "gSezonaTip", "gSezonaTip$'MG'", "@!", })

if KLevel=="0"
	AADD (aNiz, {"Upravnik moze ispravljati cijene" , "gSifUpravn", "gSifUpravn$'DN'", "@!", })
endif

AADD (aNiz, {"Ako je Bar Cod generisi <ENTER> " , "gEntBarCod", "gEntBarCod$'DN'", "@!", })

If (!IsPlanika())
	// generisao bug pri unosu reklamacije
	AADD (aNiz, {"Pri unosu zaduzenja azurirati i cijene (D/N)? " , "gZadCij", "gZadCij$'DN'", "@!", })
else
	gZadCij:="N"
endif

AADD (aNiz, {"Pri azuriranju pitati za nacin placanja (D/N)? " , "gUpitNP", "gUpitNP$'DN'", "@!", })

VarEdit(aNiz,6,2,24,79,"PARAMETRI RADA PROGRAMA - PRINCIPI RADA","B1")
BosTipke()

if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre")
    	Wpar("n2",gVodiTreb, .t., "P")
    	if (!IsPlanika())
		Wpar("zc",gZadCij, .t., "D")
    	endif
	Wpar("vO",gVodiOdj, .t., "D")
    	Wpar("Dz",@gDirZaklj, .t., "D")
    	Wpar("RR",@gRadniRac, .t., "D")
    	Wpar("BS",@gBrojSto, .t., "D")
    	Wpar("n5",@gDupliArt, .t., "D")
    	Wpar("Nu",@gDupliUpoz, .t., "Z")
    	// dva chunka
    	Wpar("Ns",@gPratiStanje, .t., "P")
   	Wpar("nh",@gPocStaSmjene, .t., "D")
    	Wpar("nj",@gStamPazSmj, .t., "D")
    	Wpar("nk",@gStamStaPun, .t., "D")
    	Wpar("vs",@gVsmjene, .t., "D")
    	Wpar("ST",@gSezonaTip, .t., "D")
    	Wpar("Si",@gSifUpravn, .t., "D")
    	Wpar("Bc",@gEntBarCod, .t., "D")
    	Wpar("np",@gUpitNP, .t., "Z")
    	MsgC()
endif
return
*}



/*! \fn gVodiOdj(gVodiOdj)
 *  \brief 
 *  \param gVodiOdj$"DN0"
 *  \return Ako je gVodiOdj$"DN" vraca .t., ako je "0" nulira odjeljenja
 */

function gVodiOdj(gVodiOdj)
*{
if gVodiOdj=="0"
	if Pitanje(,"Nulirati sifre odjeljenja ","N")=="D"
    		Pushwa()
    		O_POS
		set order to 0
		go top
    		do while !eof()
      			replace idodj with "", iddio with "0"
      			skip
    		enddo
    		use
    		O_ROBA
		set order to 0
		go top
    		do while !eof()
      			replace idodj with ""
      			skip
    		enddo
    		use
    		PopWa()
	endif
  	gVodiOdj:="N"
endif
if gVodiOdj$"DN"
	return .t.
endif
return
*}


/*! \fn ParIzglRac()
 *  \brief Podesavanje parametara izgleda racuna
 */

function ParIzglRac()
*{
local aNiz:={}
local cPom:=""

private cIdPosOld:=gIdPos
private cHistory:=" "
private aHistory:={}
private cSection:="1"

gSjecistr:=PADR(GETPStr(gSjeciStr),20)
gOtvorstr:=PADR(GETPStr(gOtvorStr),20)

O_PARAMS

Rpar("n4",@gPoreziRaster)
Rpar("n6",@nFeedLines)
Rpar("sS",@gSjeciStr)
Rpar("oS",@gOtvorStr)
Rpar("zI",@gZagIz)
Rpar("RH",@gRnHeder)
Rpar("RF",@gRnFuter)

UsTipke()
set cursor on

gSjeciStr:=PADR(gSjeciStr,30)
gOtvorStr:=PADR(gOtvorStr,30)
gZagIz:=PADR(gZagIz,20)

AADD(aNiz, {"Stampa poreza pojedinacno (D-pojedinacno,N-zbirno)" , "gPoreziRaster", "gPoreziRaster$'DN'", "@!", })
AADD(aNiz, {"Broj redova potrebnih da se racun otcijepi" , "nFeedLines", "nFeedLines>=0", "99", })
AADD(aNiz, {"Sekvenca za cijepanje trake" , "gSjeciStr", , "@S20", })
AADD(aNiz, {"Sekvenca za otvaranje kase " , "gOtvorStr", , "@S20", })
AADD(aNiz, {"Redovi zaglavlja racuna za prikaz u zagl.izvjestaja (npr.1;2;5)" , "gZagIz", ,"@S10", })
AADD(aNiz, {"Naziv fajla zaglavlja racuna" , "gRnHeder", "V_File(@gRnHeder,'zaglavlja')","@!", })
AADD(aNiz, {"Naziv fajla podnozja racuna" , "gRnFuter", "V_File(@gRnFuter,'podnozja')","@!", })
VarEdit(aNiz,9,1,19,78,"PARAMETRI RADA PROGRAMA - IZGLED RACUNA","B1")

BosTipke()

if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre")
  	Wpar("n4",gPoreziRaster, .t., "P")
  	Wpar("n6",nFeedLines, .t., "D")
  	// pohrani u formi 07\32\ ...
  	Wpar("sS",gSjeciStr, .t., "D")
  	Wpar("oS",gOtvorStr, .t., "D")
  	Wpar("RH",gRnHeder, .t., "D")
  	Wpar("zI",gZagIz, .t., "D")
  	Wpar("RF",gRnFuter, .t., "Z")
  	MsgC()
endif

gSjeciStr:=Odsj(gSjeciStr)
gOtvorStr:=Odsj(gOtvorStr)
gZagIz:=TRIM(gZagIz)

return
*}


/*! \fn V_File(cFile,cSta)
 *  \brief Otvara fajl cFile\cSta (npr. c:\pos\11\rac.txt)
 *  \param cFile
 *  \param cSta
 *  \return Funkcija otvara fajl ako se zada parametar cSta 
 */

function V_File(cFile,cSta)
*{
private cKom:="q "+PRIVPATH+cFile

if !EMPTY(cFile).and.Pitanje(,"Zelite li izvrsiti ispravku "+cSta+"?","N")=="D"
	Box(,25,80)
  	run &ckom
  	BoxC()
endif
return .t.
*}


/*! \fn ParCijene()
 *  \brief Podesavanje parametara vezanih za cijene (prikaz, popust...)
 */
function ParCijene()
*{
local aNiz:={}
private cIdPosOld:=gIdPos
private cHistory:=" "
private aHistory:={}
private cSection:="1"

UsTipke()
set cursor on

AADD (aNiz, {"Generalni popust % (99-gledaj sifranik)" , "gPopust" , , "99", })
AADD (aNiz, {"Zakruziti cijenu na (broj decimala)    " , "gPopDec" , ,  "9", })
AADD (aNiz, {"Varijanta Planika/Apoteka decimala)    " , "gPopVar" ,"gPopVar$' PA'" , , })
AADD (aNiz, {"Popust zadavanjem nove cijene          " , "gPopZCj" ,"gPopZCj$'DN'" , , })
AADD (aNiz, {"Popust zadavanjem procenta             " , "gPopProc","gPopProc$'DN'" , , })
AADD (aNiz, {"Popust preko odredjenog iznosa (iznos):" , "gPopIzn",,"999999.99" , })
AADD (aNiz, {"                  procenat popusta (%):" , "gPopIznP",,"999.99" , })
VarEdit(aNiz,9,2,18,78,"PARAMETRI RADA PROGRAMA - CIJENE","B1")

BosTipke()

O_PARAMS

if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre")
    	Wpar("pP",gPopust, .t., "P")
    	Wpar("pC",gPopZCj, .t., "D")
    	Wpar("pd",gPopDec, .t., "D")
    	Wpar("pV",gPopVar, .t., "Z")
    	Wpar("pO",gPopProc,.t., "N")
    	Wpar("pR",gPopIzn, .t., "0")
    	Wpar("pS",gPopIznP,.t., "0")
    	MsgC()
endif

return
*}


/*! \fn PostaviDat()
 *  \brief Postavljenje datuma i vremena kase
 */

function PostaviDat()
*{
local dSDat:=DATE()
local cVrij:=TIME()

Box(,3,60)
set cursor on
set date format to "DD.MM.YYYY"
@ m_x+1, m_y+2 SAY  "Datum:  " GET dSDat
@ m_x+2, m_y+2 SAY  "Vrijeme:" GET cVrij
read
set date format to "DD.MM.YY"
BoxC()

if Pitanje(,"Postaviti vrijeme i datum racunara ??","N")=="D"
	SetDate(dSDat)
	SetTime(cVrij)
	return .t.
endif

return .f.
*}


