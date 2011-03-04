#include "pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
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
AADD(opc,"6. podaci firme")
AADD(opcexe,{|| ParFirma()})
AADD(opc,"7. fiskalni parametri")
AADD(opcexe,{|| FiscalPar()})

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
Rpar("Mc",@gUseChkDir)
Rpar("sV",@gStrValuta)
Rpar("n0",@gLocPort)
Rpar("n7",@gGotPlac)
Rpar("nX",@gDugPlac)
Rpar("gS",@gRNALSif)
Rpar("gK",@gRNALKum)
Rpar("gB",@gDuzSifre)
Rpar("gX",@gOperSys)

gServerPath:=padr(gServerPath,40)
gKalkDest:=padr(gKalkDest,40)
gDuploKum:=padr(gDuploKum,30)
gDuploSif:=padr(gDuploSif,30)
gFMKSif:=padr(gFmkSif,30)
gRNALSif:=padr(gRNALSif,100)
gRNALKum:=padr(gRNALKum,100)

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
AADD(aNiz,{"Razmjena podataka, koristi se modemska veza D/N", "gModemVeza","gModemVeza$'DN'", "@!", })
AADD(aNiz,{"Razmjena podataka, koristiti 'chk' direktorij D/N", "gUseChkDir","gUseChkDir$'DN'", "@!", })
AADD(aNiz,{"Lokalni port za stampu racuna" , "gLocPort", , , })
AADD(aNiz,{"Oznaka/ID gotovinskog placanja" , "gGotPlac",, "@!", })
AADD(aNiz,{"Oznaka/ID placanja duga       " , "gDugPlac",, "@!", })
AADD(aNiz,{"Oznaka strane valute" , "gStrValuta",, "@!", })
AADD(aNiz,{"Podesenja nonsens D/N" , "gColleg",, "@!", })
AADD(aNiz,{"Azuriraj u pomocnu bazu" , "gDuplo",, "@!", "gDuplo$'DN'"})
AADD(aNiz,{"Direktorij kumulativa za pom bazu","gDuploKum",, "@!",})
AADD(aNiz,{"Direktorij sifrarnika za pom bazu","gDuplosif",, "@!",})
AADD(aNiz, {"Direktorij sifrarnika FMK        ","gFMKSif",, "@!",})
AADD(aNiz, {"Duzina sifre artikla u unosu","gDuzSifre",, "99",})
AADD(aNiz, {"Operativni sistem","gOperSys",, "@!",})

VarEdit(aNiz,2,2,24,78,"PARAMETRI RADA PROGRAMA - PODACI KASE","B1")

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
    	Wpar("Mc",gUseChkDir, .t.,"D") // koristi chk direktorij
    	Wpar("n0",gLocPort, .t.,"D")
    	Wpar("n7",gGotPlac, .t.,"D")
    	Wpar("nX",gDugPlac, .t.,"D")
    	Wpar("sV",gStrValuta, .t.,"D")
    	Wpar("Co",gColleg, .t.,"D")
    	Wpar("Du",gDuplo, .t.,"Z")
    	Wpar("D7",trim(gDuploKum),.f.) // pathove ne diraj
    	Wpar("D8",trim(gDuploSif),.f.) // pathove ne diraj
    	Wpar("D9",trim(gFmkSif),.f.)   // pathove ne diraj
    	Wpar("gS",trim(gRNALSif),.f.)   // pathove ne diraj
    	Wpar("gK",trim(gRNALKum),.f.)   // pathove ne diraj
    	Wpar("gB",gDuzSifre, .t.,"D")
    	Wpar("gX",gOperSys, .t.,"D")
    	MsgC()
endif

gServerPath:=ALLTRIM(gServerPath)

if (RIGHT(gServerPath,1)<>SLASH)
	gServerPath+=SLASH
endif

return
*}

// parametri fiskalizacije
function FiscalPar()
local aNiz:={}
local cPom:=""

O_PARAMS
private cHistory:=" "
private aHistory:={}
private cSection:="1"

Rpar("f1",@gFc_type)
Rpar("f2",@gFc_path)
Rpar("f3",@gFc_name)
Rpar("f4",@gFc_use)
Rpar("f5",@gFc_cmd)
Rpar("f6",@gFc_cp1)
Rpar("f7",@gFc_cp2)
Rpar("f8",@gFc_cp3)
Rpar("f9",@gFc_cp4)
Rpar("f0",@gFc_cp5)
Rpar("fE",@gFc_error)
Rpar("fI",@gIOSA)
Rpar("fK",@gFC_konv)
Rpar("fT",@gFC_tout)
Rpar("fX",@gFC_txrn)
Rpar("fC",@gFC_acd)

UsTipke()
set cursor on

AADD(aNiz,{"Tip fiskalne kase", "gFc_type", , "@S20", })

AADD(aNiz,{"Putanja izl.fajla", "gFc_path", , "@S50", })
AADD(aNiz,{"Naziv izl.fajla", "gFc_name", , "@S20", })

AADD(aNiz,{"Provjera greske kod prodaje", "gFc_error", , "@!", })
AADD(aNiz,{"Timeout fiskalnih operacija", "gFc_tout", , "9999", })

AADD(aNiz,{"IOSA broj", "gIOSA", , "@S16", })
AADD(aNiz,{"'kod' artikla je (I)d, (P)lu, (B)arkod", "gFc_acd", , "@!", })

AADD(aNiz,{"param ($1)", "gFc_cp1", , "@S50", })
AADD(aNiz,{"param ($2)", "gFc_cp2", , "@S50", })
AADD(aNiz,{"param ($3)", "gFc_cp3", , "@S50", })
AADD(aNiz,{"param ($4)", "gFc_cp4", , "@S50", })
AADD(aNiz,{"param ($5)", "gFc_cp5", , "@S50", })
AADD(aNiz,{"Komandna linija", "gFc_cmd", , "@S50", })

AADD(aNiz,{"Konverzija znakova", "gFc_konv", , "@!", })

AADD(aNiz,{"Stampati i pos racun ?", "gFc_txrn", ,"@!", })

AADD(aNiz,{"Koristiti fiskalne funkcije", "gFc_use", ,"@!", })

VarEdit(aNiz,5,2,24,78,"Fiskalni parametri","B1")

BosTipke()

// Upisujem nove parametre
if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre PZ")
    	Wpar("f1",gFc_type, .t.,"D")
    	Wpar("f2",gFc_path, .t.,"D")
    	Wpar("f3",gFc_name, .t.,"D")
    	Wpar("f4",gFc_use, .t.,"D")
    	Wpar("f5",gFc_cmd, .t.,"D")
    	Wpar("f6",gFc_cp1, .t.,"D")
    	Wpar("f7",gFc_cp2, .t.,"D")
    	Wpar("f8",gFc_cp3, .t.,"D")
    	Wpar("f9",gFc_cp4, .t.,"D")
    	Wpar("f0",gFc_cp5, .t.,"D")
    	Wpar("fE",gFc_error, .t.,"D")
    	Wpar("fI",gIOSA, .t.,"D")
    	Wpar("fK",gFc_konv, .t.,"D")
    	Wpar("fT",gFc_tout, .t.,"D")
    	Wpar("fX",gFc_txrn, .t.,"D")
    	Wpar("fC",gFc_acd, .t.,"D")
    	MsgC()
endif

return


// parametri - podaci firme
function ParFirma()
*{
local aNiz:={}
local cPom:=""

O_PARAMS
private cHistory:=" "
private aHistory:={}
private cSection:="1"

// Citam postojece/default podatke o kasi
Rpar("F1",@gFirNaziv)
Rpar("F2",@gFirAdres)
Rpar("F3",@gFirIdBroj)
Rpar("F4",@gFirPM)
Rpar("F5",@gRnMjesto)
Rpar("F6",@gFirTel)
Rpar("F7",@gRnPTxt1)
Rpar("F8",@gRnPTxt2)
Rpar("F9",@gRnPTxt3)

gFirIdBroj := PADR(gFirIdBroj, 13)

UsTipke()
set cursor on

AADD(aNiz,{"Puni naziv firme", "gFirNaziv", , , })
AADD(aNiz,{"Adresa firme", "gFirAdres", , , })
AADD(aNiz,{"Telefoni", "gFirTel", , , })
AADD(aNiz,{"ID broj", "gFirIdBroj", , , })
AADD(aNiz,{"Prodajno mjesto" , "gFirPM", , , })
AADD(aNiz,{"Mjesto nastanka racuna", "gRnMjesto" , , , })
AADD(aNiz,{"Pomocni tekst racuna - linija 1:", "gRnPTxt1", , , })
AADD(aNiz,{"Pomocni tekst racuna - linija 2:", "gRnPTxt2", , , })
AADD(aNiz,{"Pomocni tekst racuna - linija 3:", "gRnPTxt3", , , })
VarEdit(aNiz,7,2,24,78,"PODACI FIRME I RACUNA","B1")

BosTipke()

// Upisujem nove parametre
if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre PZ")
    	Wpar("F1",gFirNaziv, .t.,"D")
    	Wpar("F2",gFirAdres, .t.,"D")
    	Wpar("F3",gFirIdBroj, .t.,"D")
    	Wpar("F4",gFirPM, .t.,"D")
    	Wpar("F5",gRnMjesto, .t.,"D")
    	Wpar("F6",gFirTel, .t.,"D")
    	Wpar("F7",gRnPTxt1, .t.,"D")
    	Wpar("F8",gRnPTxt2, .t.,"D")
    	Wpar("F9",gRnPTxt3, .t.,"D")
    	MsgC()
endif

return
*}


// principi rada kase
function ParPrRada()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. osnovna podesenja              ")
AADD(opcexe,{|| ParPrBase()})

if gModul=="HOPS"
	AADD(opc,"2. podesenja - ugostiteljstvo   ")
	AADD(opcexe,{|| ParPrUgost()})
endif

Menu_SC("prr")

return .f.
*}


/*! \fn ParPrBase()
 *  \brief Podesavanje parametara principa rada kase
 */

function ParPrUgost()
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
Rpar("RR",@gRadniRac)
Rpar("sO",@gRnSpecOpc)
Rpar("BS",@gBrojSto)
Rpar("nk",@gStamStaPun)
Rpar("Dz",@gDirZaklj)

UsTipke()
set cursor on

aNiz:={{"Da li se vode trebovanja (D/N)" , "gVodiTreb", "gVodiTreb$'DN'", "@!", }}
AADD (aNiz, {"Da li se koriste radni racuni(D/N)" , "gRadniRac", "gRadniRac$'DN'", "@!", })
AADD (aNiz, {"Ako se ne koriste, da li se racun zakljucuje direktno (D/N)" , "gDirZaklj", "gDirZaklj$'DN'", "@!", })
AADD (aNiz, {"Da li je broj stola obavezan (D/N/0)", "gBrojSto", "gBrojSto$'DN0'", "@!", })
AADD (aNiz, {"Dijeljenje racuna, spec.opcije nad racunom (D/N)", "gRnSpecOpc", "gRnSpecOpc$'DN'", "@!", })
AADD (aNiz, {"Da li se po zakljucenju smjene stampa stanje puktova (D/N)" , "gStamStaPun", "gStamStaPun$'DN'", "@!", })

VarEdit(aNiz,2,2,24,79,"PARAMETRI RADA PROGRAMA - UGOSTITELJSTVO","B1")
BosTipke()

if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre")
    	Wpar("n2",gVodiTreb, .t., "P")
    	Wpar("Dz",@gDirZaklj, .t., "D")
    	Wpar("sO",@gRnSpecOpc, .t., "D")
	Wpar("RR",@gRadniRac, .t., "D")
    	Wpar("BS",@gBrojSto, .t., "D")
    	Wpar("nk",@gStamStaPun, .t., "D")
    	MsgC()
endif
return



// --------------------------------------------
// osnovni prinicipi rada kase
// --------------------------------------------
function ParPrBase()
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
Rpar("vS",@gStolovi)
Rpar("RR",@gRadniRac)
Rpar("Dz",@gDirZaklj)
Rpar("sO",@gRnSpecOpc)
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
Rpar("Sx",@gDisplay)
Rpar("Bc",@gEntBarCod)
Rpar("Ep",@gEvidPl)
Rpar("dF",@gDiskFree)
Rpar("UN",@gSifUvPoNaz)
Rpar("rI",@gRnInfo)

if IsPlanika()
	// ako je planika prati stanje je uvijek "D"
	gPratiStanje := "D"
	Rpar("Mi",@gRobaVelicina)
endif

if IsPDV()
	Rpar("pF",@gPorFakt)
endif

UsTipke()
set cursor on

aNiz:={}
AADD (aNiz, {"Da li se racun zakljucuje direktno (D/N)" , "gDirZaklj", "gDirZaklj$'DN'", "@!", })
AADD (aNiz, {"Dopustiti dupli unos artikala na racunu (D/N)" , "gDupliArt", "gDupliArt$'DN'", "@!", })
AADD (aNiz, {"Ako se dopusta dupli unos, da li se radnik upozorava(D/N)" , "gDupliUpoz", "gDupliUpoz$'DN'", "@!", })
AADD (aNiz, {"Da li u u objektu postoje odjeljenja (D/N)" , "gVodiodj", "gVodiOdj(@gVodiOdj)", "@!",})
AADD (aNiz, {"Da li se prati pocetno stanje smjene (D/N)" , "gPocStaSmjene", "gPocStaSmjene$'DN!'", "@!", })
AADD (aNiz, {"Da li se po zakljucenju smjene stampa ukupni pazar (D/N)" , "gStamPazSmj", "gStamPazSmj$'DN'", "@!", })
AADD (aNiz, {"Da li se prati stanje zaliha robe na prodajnim mjestima (D/N/!)" , "gPratiStanje", "gPratiStanje$'DN!'", "@!", })
AADD (aNiz, {"Da li se po zakljucenju smjene stampa stanje odjeljenja (D/N)" , "gStamStaPun", "gStamStaPun$'DN'", "@!", })
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
AADD (aNiz, {"Stampa na POS displej (D/N)? " , "gDisplay", "gDisplay$'DN'", "@!", })
AADD (aNiz, {"Evidentiranje podataka o vrstama placanja (D/N)? " , "gEvidPl", "gEvidPl$'DN'", "@!", })
AADD (aNiz, {"Provjera prostora na disku (D/N)? " , "gDiskFree", "gDiskFree$'DN'", "@!", })
if IsPDV()
	AADD (aNiz, {"Stampati poreske fakture (D/N)? " , "gPorFakt", "gPorFakt$'DN'", "@!", })

endif

AADD (aNiz, {"Voditi po stolovima (D/N)? " , "gStolovi", "gStolovi$'DN'", "@!", })
AADD (aNiz, {"Kod unosa racuna uvijek pretraga art.po nazivu (D/N)? " , "gSifUvPoNaz", "gSifUvPoNaz$'DN'", "@!", })
if IsPlanika()
	AADD (aNiz, {"Unos velicine robe (D/N)? " , "gRobaVelicina", "gRobaVelicina$'DN'", "@!", })
endif
AADD (aNiz, {"Nakon stampe ispis informacija o racunu (D/N)? " , "gRnInfo", "gRnInfo$'DN'", "@!", })

VarEdit(aNiz,2,2,24,79,"PARAMETRI RADA PROGRAMA - PRINCIPI RADA","B1")
BosTipke()

if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre")
    	Wpar("n2",gVodiTreb, .t., "P")
    	if (!IsPlanika())
		Wpar("zc",gZadCij, .t., "D")
    	endif
	Wpar("vO",gVodiOdj, .t., "D")
	Wpar("vS",@gStolovi, .t., "D")
	Wpar("Dz",@gDirZaklj, .t., "D")
    	Wpar("sO",@gRnSpecOpc, .t., "D")
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
    	Wpar("Sx",@gDisplay, .t., "D")
    	Wpar("Bc",@gEntBarCod, .t., "D")
    	if IsPlanika()
		Wpar("Mi",@gRobaVelicina, .t., "D")
    	endif
	Wpar("np",@gUpitNP, .t., "Z")
    	Wpar("Ep",@gEvidPl, .t., "Z")
    	Wpar("dF",@gDiskFree, .t., "Z")
    	Wpar("UN",@gSifUvPoNaz, .t., "Z")
    	Wpar("rI",@gRnInfo, .t., "Z")
	if IsPDV()
    		Wpar("pF",@gPorFakt, .t., "Z")
	endif
    	MsgC()
endif

return



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
Rpar("Ra",@grbCjen) // cijena sa pdv ili cijena bez pdv
Rpar("Rb",@grbStId) // prikaz id robe na racunu
Rpar("Rc",@grbReduk) // redukcija papira pri izdavanju racuna

UsTipke()
set cursor on

gSjeciStr:=PADR(gSjeciStr,30)
gOtvorStr:=PADR(gOtvorStr,30)
gZagIz:=PADR(gZagIz,20)

AADD(aNiz, {"Stampa poreza pojedinacno (D-pojedinacno,N-zbirno)" , "gPoreziRaster", "gPoreziRaster$'DN'", "@!", })
AADD(aNiz, {"Broj redova potrebnih da se racun otcijepi" , "nFeedLines", "nFeedLines>=0", "99", })
AADD(aNiz, {"Sekvenca za cijepanje trake" , "gSjeciStr", , "@S20", })
AADD(aNiz, {"Sekvenca za otvaranje kase " , "gOtvorStr", , "@S20", })
//AADD(aNiz, {"Redovi zaglavlja racuna za prikaz u zagl.izvjestaja (npr.1;2;5)" , "gZagIz", ,"@S10", })
//AADD(aNiz, {"Naziv fajla zaglavlja racuna" , "gRnHeder", "V_File(@gRnHeder,'zaglavlja')","@!", })
//AADD(aNiz, {"Naziv fajla podnozja racuna" , "gRnFuter", "V_File(@gRnFuter,'podnozja')","@!", })
AADD(aNiz, {"Racun, prikaz cijene bez PDV (1) ili sa PDV (2) ?" , "grbCjen", , "9", })
AADD(aNiz, {"Racun, prikaz id artikla na racunu (D/N)" , "grbStId", "grbStId$'DN'", "@!", })
AADD(aNiz, {"Redukcija potrosnje trake kod stampe racuna i izvjestaja (0/1/2)" , "grbReduk", "grbReduk>=0 .and. grbReduk<=2", "9", })

VarEdit(aNiz,9,1,19,78,"PARAMETRI RADA PROGRAMA - IZGLED RACUNA","B1")

BosTipke()

if LASTKEY()<>K_ESC
	MsgO("Azuriram parametre")
  	Wpar("n4",gPoreziRaster, .t., "P")
  	Wpar("n6",nFeedLines, .t., "D")
  	// pohrani u formi 07\32\ ...
  	Wpar("sS",gSjeciStr, .t., "D")
  	Wpar("oS",gOtvorStr, .t., "D")
  	Wpar("Ra",grbCjen, .t., "D")
	Wpar("Rb",grbStId, .t., "D")
	Wpar("Rc",grbReduk, .t., "D")
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
	// setuj i gDatum
	gDatum := dSDat
	return .t.
endif

return .f.
*}


