#include "\cl\sigma\fmk\pos\pos.ch"
#include "\cl\sigma\fmk\pos\specif\tigra\1g\tigra.ch"


/*! \fn MnuPrenosHH()
 *  \brief Glavni menij prenosa podataka na HH
 */
function MnuPrenosHH()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. prenos stanja partnera na HH ")
AADD(opcexe, {|| PrenosStPartnHH()})

AADD(opc, "2. prepakivanje ")
AADD(opcexe, {|| SvediNaPrP()})

Menu_SC("pnh")

return
*}


/*! \fn PrenosStPartnHH()
 *  \brief Glavna funkcija prenosa podataka na HH
 */
function PrenosStPartnHH()
*{
private dDatOd:=Date()-400
private dDatDo:=Date()
private cNula:="D"

SET CURSOR ON
Box(,3,40)
	//@ m_x+1, m_y+2 SAY "Od datuma:" GET dDatOd
	@ m_x+2, m_y+2 SAY "Do datuma:" GET dDatDo
	@ m_x+3, m_y+2 SAY "Partneri sa stanjem 0 (D/N)?" GET cNula
	read
BoxC()

if LastKey()==K_ESC
	return
endif

CLOSE ALL

MsgO("Kreiram tabele za prenos na HH !")
CrePrenosHHDB()
MsgC()

CLOSE ALL

OPrenosHH()

SpremiZaHH()

return
*}


/*! \fn CrePrenosHHDB()
 *  \brief Kreiranje tabela za prenos (OSTAV, PARTN, PARAMS)
 */
function CrePrenosHHDB()
*{

ferase(KUMPATH+"ostav_p.dbf")
ferase(KUMPATH+"ostav_p.cdx")

ferase(KUMPATH+"ostav.dbf")
ferase(KUMPATH+"ostav.cdx")

ferase(KUMPATH+"params_p.dbf")
ferase(KUMPATH+"params_p.cdx")

ferase(KUMPATH+"params.dbf")
ferase(KUMPATH+"params.cdx")

ferase(KUMPATH+"partn_p.dbf")
ferase(KUMPATH+"partn_p.cdx")

ferase(KUMPATH+"partn.dbf")
ferase(KUMPATH+"partn.cdx")

//if !File(KUMPATH+"ostav_p.dbf")
	aDbf:={}
	AADD(aDbf, { "ID",        "N",  6, 0})
	AADD(aDbf, { "DATUM",     "C",  8, 0})
	AADD(aDbf, { "BRDOK",     "C", 10, 0})
	AADD(aDbf, { "VRSTA",     "C",  1, 0})
	AADD(aDbf, { "IZNOS",     "N",  12, 2})
	AADD(aDbf, { "DATVAL",    "D",  8, 0})
	AADD(aDbf, { "VEZA",      "C",  10, 0})
	DBcreate2(KUMPATH+"OSTAV_P.DBF",aDbf)
	CREATE_INDEX("ID", "id", KUMPATH+"OSTAV_p")
//endif

//if !File(KUMPATH+"partn_p.dbf")
	aDbf:={}
	AADD(aDbf, { "ID",        "N",  6, 0})
	AADD(aDbf, { "OZNAKA",    "C",  8, 0})
	AADD(aDbf, { "NAZ",       "C", 30, 0})
	AADD(aDbf, { "STANJE",    "N",  15, 2})
	DBcreate2(KUMPATH+"PARTN_P.DBF", aDbf)
	CREATE_INDEX("ID", "ID", KUMPATH+"PARTN_p")
//endif

//if !File(KUMPATH+"params_p.dbf")
	aDbf:={}
	AADD(aDbf, { "ID",   "C",  3, 0} )
	AADD(aDbf, { "NAZ",  "C", 20, 0} )
	AADD(aDbf, { "OPIS", "C", 40, 0} )
	DBcreate2(KUMPATH+"PARAMS_P.DBF",aDbf)
	CREATE_INDEX("ID", "ID", KUMPATH+"PARAMS_p")
//endif


return
*}


/*! \fn OPrenosHH()
 *  \brief Otvara tabele potrebne za prenos
 */
function OPrenosHH()
*{
O_PARTN_P
O_OSTAV_P
O_PARAMS_P
O_RNGOST
O_POS
O_DOKS

return
*}

/*! \fn SpremiZaHH()
 *  \brief Petlja za proracunavanje stanja partnera i otvorenih stavki
 */
function SpremiZaHH()
*{
LOCAL nDug, nPot
LOCAL nStanje
LOCAL nPstDug, nPstPot
local nIznosStavka
local lProsaoPst
local lVratiSe
local lDodajPartnera

private cGost:=SPACE(8)

nBrPartnera:=0
nOStav:=0

//prikazi sve promjene u ovom intervalu
#define OBUHVATI_DANA 20

// prvo izbrisi postojece podatke iz tabela!!!	
select partn_p
zap
select ostav_p
zap
select params_p
zap

select doks
set order to tag "GOSTDAT"        
* "idPos + IdGost+DTOS(Datum)+ idvd + brdok"
seek gIdPos + cGost

cIdPos = doks->idPos

Box(,3,50)
do while  doks->idPos==gIdPos .and. !eof()
	
	if datum > dDatDo
		skip
		loop
	endif
	
	// ako nema partnera preskoci jer nas to ne zanima!!!
	if empty(doks->idGost)
		skip
		loop
	ENDIF
	

	lProsaoPst:=.f.
	cIdGost:=doks->idGost
	select rnGost
	hseek cIdGost
	SELECT doks
			
	cDugPotr:=" "
	a42:={}


	lDodajPartnera:=.f.
	nStanje:=0
	do while !eof() .and.  doks->idPos==gIdPos .and.  doks->idGost==cIdGost
		if datum > dDatDo
			skip
			loop
		endif
	
		cIdVD:=doks->idvd
		cBrDok:=doks->brdok
		dDatDok:=doks->datum
	
		
		nPstDug=0
		nPstPot=0
		
	
		* preskoci nepotrebne partnere
		if !(rngost->hh=="D")
			SKIP
			LOOP
		endif	


		if Empty(rngost->oznaka)
			cIdGost:=cIdGost
		else
			cIdGost:=rngost->oznaka
		endif
		lDodajPartnera:=.t.


		* stare transakcije su pocetno stanje
		lVratiSe:=.f.
		DO WHILE (!lProsaoPst  .and. !eof() .and. doks->idPos==gIdPos .and. doks->idGost==cIdGost) .and. (dDatDo-doks->datum > OBUHVATI_DANA) 
			if datum > dDatDo
				skip
				loop
			endif
		 
				
			cIdVD:=doks->idvd
			cBrDok:=doks->brdok
			dDatDok:=doks->datum
			
		
			nDug=0
			nPot=0
			cIdVrsteP:=""
			Iznos1Rac(@nDug, @nPot, @cIdVrsteP, "PS")
			nPstDug = nPstDug + nDug
			nPstPot = nPstPot + nPot 
	
			SELECT DOKS
			SKIP
		
		ENDDO
	
		
		IF !lProsaoPst .and. (ROUND(nPstDug-nPstPot,4)<>0)
			
			IF nPstDug > nPstPot
				*duguje
				nStanje = nPstDug - nPstPot
				++nOStav
				AddToOStav(rngost->idn, dDatDok, "PS-"+ALLTRIM(cBrDok), "D" , nStanje)
			ELSE
				*potrazuje
				nStanje = nPstPot - nPstDug
				++nOStav
				AddToOStav(rngost->idn, dDatDok, "PS-"+ALLTRIM(cBrDok), "P" , nStanje)
			ENDIF
		
		
		ENDIF
		* odradio sam pocetno stanje
		lProsaoPst=.t.	
	
		SELECT DOKS

		
		* ako nema nista iza pocetnog stanja, idi na pocetak petlje
		if (eof() .or. (doks->idPos != gIdPos) .or. (doks->idGost != cIdGost))
			// izadji iz do while
			//MsgBeep("idpos="+idpos+" idgost="+cIdGost)
			loop
		endif
		

		if (doks->datum > dDatDo)
			skip
			loop
		endif
	
		* sada idu novije transakcije
		nDug=0
		nPot=0
		cIdVrsteP = ""
		Iznos1Rac(@nDug, @nPot, @cIdVrsteP, "TP")
		SELECT doks

		nStanje = nStanje + nDug - nPot
		
		nOStav = nOstav + 1
		
		
		DO CASE
		case (cIdVrsteP=="01")
			// gotovina D=P, saldo 0
			if round(nDug,4)<>0
				AddToOStav(rngost->idn, doks->datum, "GO-"+ALLTRIM(doks->brDok), "0", nDug)
			endif
		
		CASE (cIdVrsteP == "09")
			// placanje duga
			if round(nPot,4)<>0	
				AddToOStav(rngost->idn, doks->datum,"4V-"+ALLTRIM(doks->brDok), "P", nPot)
			endif
	
		otherwise
			//CASE (doks->IdVrsteP $ "02#03#04#05")
			if round(nDug,4)<>0
				AddToOStav(rngost->idn, doks->datum,"4V-"+ALLTRIM(doks->brDok), "D", nDug)
			endif
		ENDCASE
		
		
		SELECT DOKS
		SKIP
		
	enddo
	if lDodajPartnera
		nBrPartnera=nBrPartnera + 1
		AddToPartn(rngost->idn, cIdGost, rnGost->naz, nStanje)
	endif
	SELECT doks
	
enddo
BoxC()

* Upisi stanje u tablelu params
AddToParams("PAZ",DToS(Date()),"Posljednje azuriranje")
AddToParams("PCN",STR(nBrPartnera),"Broj prenesenih partnera")
AddToParams("SCN",STR(nOStav),"Broj prenesenih otvorenih stavki")
// Izvjesti o broju prenesenih stavki


MsgO("prebacujem *_P -> *")
	CLOSE ALL
	Prebaci("ostav_p", "ostav", "STR(ID,8)+DATUM")
 	Prebaci("partn_p", "partn")	
 	Prebaci("params_p", "params")	
	
MsgC()
MsgBeep("Broj prenesenih partnera: " + ALLTRIM(STR(nBrPartnera)) + "##" + "Broj prenesenih otvorenih stavki: " + ALLTRIM(STR(nOStav)))

return
*}


* iznos za jedan racun, dokument na trenutnoj poziciji doks-a
* 
FUNCTION Iznos1Rac(nDug, nPot, cIdVrsteP, cTag)
LOCAL nIznosStavka
LOCAL nPredznak
local nDugRac
local nPotRac

SELECT pos
seek doks->(idPos+idVd+DToS(datum)+brDok)

nDugRac = 0
nPotRac = 0

do while !eof() .and. pos->(idPos+idVd+DToS(datum)+brDok)==doks->(idPos+idVd+DToS(datum)+brDok)

	nIznosStavka:=pos->kolicina*pos->cijena

	DO CASE
		
	case  LEFT(pos->idRoba,5) = "PLDUG"
	
		*placanje duga
		
		cIdVrsteP = "09"
		nPotRac = nPotRac + nIznosStavka
		
	case doks->idVrsteP=="01"
		*gotovina

		// empty treba zato sto u dokumentu tipa "00" nema
		// vrste placanja
		
		nDugRac = nDugRac + nIznosStavka
		nPotRac = nPotRac + nIznosStavka
		
		cIdVrsteP = "01"

	otherwise 
		*vereseija
		nDugRac = nDugRac + nIznosStavka
		cIdVrsteP = doks->idVrsteP 
		
	ENDCASE
	skip

	
enddo


// pocetno stanje uzmi kao negativno dugovanje
if doks->idVD == "00"
	cIdVrsteP = "02"
	nDugRac = (-nPotRac + nDugRac) * -1
	nPotRac = 0
endif


@ m_x+2, m_y+2 SAY "Dokument:" + doks->(idPos+"-"+idVd+"-"+brDok+" od "+DTOC(datum))
//if doks->IdGost = "ZE2"
//	@ m_x+3, m_y+2 SAY " dug:"+STR(nDugRac, 10,2)+" pot:"+STR(nPotRac, 10,2)+ " " + cTag
//	inkey(0)
//endif

nDug = nDug + nDugRac
nPot = nPot + nPotRac

RETURN

/*! \fn AddToPartn(nIdN,cIdPartn,cNazPartn,nIznos)
 *  \brief Dodaje zapis u tabelu partn
 *  \param nIdN - polje IDN iz rngost
 *  \param cIdPartn - polje ID iz rngost
 *  \param cNazPartn - polje naz iz rngost
 *  \param nIznos - stanje za partnera
 */
function AddToPartn(nIdN, cIdPartn, cNazPartn, nIznos)
*{
local nArr
nArr:=SELECT()

select partn_p
append blank
replace id with nIdN
replace oznaka with cIdPartn
replace naz with cNazPartn
replace stanje with nIznos
select (nArr)
return
*}


/*! \fn AddToOStav(nIdN,dDatum,cBrojDok,cStatus,nIznos)
 *  \brief Dodaje zapis u tabelu OStav
 *  \param nIdN - polje IDN iz rngost (veza sa partn->id)
 *  \param dDatum - datum otvorene stavke
 *  \param cBrojDok - broj dokumenta
 *  \param cStatus - status D/P (duguje/potrazuje)
 *  \param nIznos - iznos racuna (D/P)
 */
function AddToOStav(nIdN, dDatum, cBrojDok, cStatus, nIznos)
*{
local nArr
nArr:=SELECT()

select ostav_p

append blank
replace id with nIdN
replace datum with DTOS(dDatum)
replace brdok with cBrojDok
replace vrsta with cStatus
replace iznos with nIznos

select (nArr)

return
*}

/*! \fn AddToParams(cID,cNaziv,cOpis)
 *  \brief Dodaje zapis u tabelu params - ovo je kontrolna tabela iz koje mozemo vidjeti koliko je preneseno partnera a koliko otvorenih stavki te kada je zadnji put prenos radjen.
 *  \param cID - 1. PAZ - Posljednje azuriranje 2. PCN - Broj prenesenih partnera 3. SCN - Broj prenesenih otvorenih stavki.
 *  \param cNaziv - Naziv promjene
 *  \param cOpis - Opis promjene
 */
function AddToParams(cID,cNaziv,cOpis)
*{
local nArr
nArr:=SELECT()

select params_p
append blank
replace id with cId
replace naz with cNaziv
replace opis with cOpis

select (nArr)
return
*}


/*! \fn Prebaci(cFrom, cTo)
 *  \brief prebaci tabelu iz cFrom u cTo, drzeci se ID sort-a cFrom tabele
 *  \param cFrom  - izvorna tabela
 *  \param cNaziv - odredisna tabela
 *  \param cIndex - index po kome se vrsi prebacivanje
 */

static function Prebaci(cFrom, cTo, cIndex)
*{

CLOSE ALL
SELECT 100
USE (KUMPATH+cFrom)
SET ORDER TO TAG "ID"


COPY STRUCTURE TO (KUMPATH+"struct")
CREATE  (KUMPATH+cTo) FROM (KUMPATH+"struct")
CLOSE ALL


SELECT 101
USE (KUMPATH+cFrom)
SET ORDER TO TAG "ID"
if (cIndex <> NIL)
	INDEX ON &cIndex TAG "IDX1"
	SET ORDER TO TAG "IDX1"
endif


SELECT 102
USE (KUMPATH+cTo)

SELECT (cFrom)
GO TOP
do while !eof()
	Scatter()
	
	SELECT (cTo)
	dbappend(.t.)
	Gather()
	
	SELECT (cFrom)
	skip
enddo
CLOSE ALL

*}
