#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_stpm.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.11 $
 * $Log: rpt_stpm.prg,v $
 * Revision 1.11  2003/11/14 08:46:39  sasavranic
 * Uslov po K9
 *
 * Revision 1.10  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.9  2003/01/21 15:01:18  ernad
 * probelm excl stanje artikala - nema problema
 *
 * Revision 1.8  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.7  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 * Revision 1.6  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.5  2002/06/17 13:18:22  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.4  2002/06/17 11:45:25  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.3  2002/06/14 14:02:43  mirsad
 * prirpeme za doxy dokumenter
 *
 *
 */

/*! \file fmk/pos/rpt/1g/rpt_stpm.prg
 *  \brief Izvjestaj: stanje prodajnog mjesta
 */


/*! \var *string FmkIni_KumPath_CROBA_GledajTops
 *  \param D - gledaj i kumulativ TOPS-a
 *  \param N - ne gledaj, default vrijednost
 *  \brief Ovaj parametar odredjuje da li da se za utvrdjivanje ukupnog stanja robe gleda i kumulativ TOPS-a
 */
*string FmkIni_KumPath_CROBA_GledajTops;
 

/*! \fn StanjePM(cDat,cSmjena)
 *  \param cDat
 *  \param cSmjena
 *  \brief Izvjestaj: stanje prodajnog mjesta
 */


*string
static cKontrolnaTabela:=""
*;

*bool
static lCekaj:=.t.
*;

*function StanjePM(cDat,cSmjena)
*{
function StanjePM
parameters cDat, cSmjena
local nStanje
local nSign:=1
local cSt
local nVrijednost
local nCijena:=0
local cRSdbf
local cVrstaRs

private cIdDio:=SPACE(2)
private cIdOdj:=SPACE(2)
private cRoba:=SPACE(60)
private cLM:=""
private nSir:=40
private nRob:=29
private cNule:="N"
private cKontrolisi

cKontrolisi:="N"
cK9:=SPACE(3)

cVrstaRs:=gVrstaRs

// zakrpa, izvjestaj za "S" ne ne daje sto zelim
if (gModul=="TOPS" .and. gVrstaRs=="S")
	cVrstaRs:="A"
endif

if (PCOUNT()==0)
	fZaklj:=.f.
else
	fZaklj:=.t.
endif

if !fZaklj
	private cDat:=gDatum
	private cSmjena:=" "
endif

private fCROBA:=.f.

O_KASE
O_ODJ
O_DIO
O_SIFK
O_SIFV
O_ROBA
O_SIROV
O_POS

cIdPos:=gIdPos

private cUkupno:="N"
private cMink:="N"

if fZaklj
	// kod zakljucenja smjene
	aUsl1:={}
	if gModul=="HOPS"
		cIdDio:=gIdDio
	endif 
else

	if gModul=="HOPS"
		cIdodj:="S "
	else 
		cIdodj:="R "
	endif 

	cIdPos:=gIdPos
	aNiz:={}
	
	if cVrstaRs<>"K"
		AADD (aNiz, {"Prodajno mjesto (prazno-svi)","cIdPos","cidpos='X'.or.empty(cIdPos).or. P_Kase(@cIdPos)","@!",})
	endif
	if gVodiOdj=="D"
		AADD(aNiz,{"Roba/Sirovine","cIdOdj", "cidodj $ 'R S '","@!",})
	endif
	if gModul=="HOPS"
		if gPostDO=="D"
			AADD (aNiz, {"Dio objekta","cIdDio", "Empty (cIdDio).or.P_Dio(@cIdDio)","@!",})
		endif
	endif 
	AADD (aNiz, {"Artikli  (prazno-svi)","cRoba",,"@!S30",})
	AADD (aNiz, {"Izvjestaj se pravi za datum","cDat",,,})
	if gVSmjene=="D"
		AADD (aNiz, {"Smjena","cSmjena",,,})
	endif
	AADD (aNiz, {"Stampati artikle sa stanjem 0", "cNule","cNule$'DN'","@!",})
	AADD (aNiz, {"Prikaz kolone ukupno D/N ", "cUkupno","cUkupno$'DN'","@!",})
	AADD (aNiz, {"Prikaz samo kriticnih zaliha (D/N/O) ?", "cMinK","cMinK$'DNO'","@!",})
	AADD (aNiz, {"Analiza - kontrolna tabela ?", "cKontrolisi","cKontrolisi$'DN'","@!",})
	AADD (aNiz, {"Uslov po K9", "cK9",,,})
	do while .t.
		if !VarEdit( aNiz, 10,5,13+LEN(aNiz),74,'USLOVI ZA IZVJESTAJ "STANJE ODJELJENJA"',"B1")
			CLOSERET
		endif
		if IzFmkIni('CROBA','GledajTops','N',KUMPATH)=='D'
			if cRoba='CROBA1284#'
				if pitanje(,'Azurirati u CROBA (D/N)?','N')=='D'
					fCROBA:=.t.
				endif
				cRoba:=""
			endif
		endif
		altd()
		aUsl1:=Parsiraj(cRoba,"IdRoba","C")
		if aUsl1<>NIL
			exit
		else
			Msg("Kriterij za artikal nije korektno postavljen!")
		endif
	enddo
endif

if cMink=="O"
	cNule:="D"
endif

cU:=R_U
cI:=R_I
cRSdbf:="ROBA"

private cZaduzuje:="R"

if cIdOdj="S "
	cZaduzuje:="S"
	cU:=S_U
	cI:=S_I
	cRSdbf:="SIROV"
endif

if cVrstaRs=="S"
	cLM:=SPACE(5)
	nSir:=80
	nRob:=40
endif


SELECT POS
if ORDNUMBER("5")==0
	use
	CREATE_INDEX("5","IdPos+idroba+DTOS(Datum)", KUMPATH+"POS")
	select (F_POS)
	use
	O_POS
endif

cFilt:=""

if EMPTY(cIdPos)
	if gModul=="HOPS"
		SET ORDER TO 5
	else 
		
		//"2": "IdOdj+idroba+DTOS(Datum)"
		SET ORDER TO 2  
		// 1 artikal, 1 stavka u izvjestaju (samo TOPS)
	endif 
else
	SET ORDER TO 5
	cFilt:="IDPOS=='"+cIdPos+"'"
endif

if LEN(aUsl1)>0
	if EMPTY(cFilt)
		cFilt:=aUsl1
	else
		cFilt+=".and."+aUsl1
	endif
endif


if !EMPTY(cFilt)
	SET FILTER TO &cFilt
endif

go top

nH:=0

if fCRoba
	cSQLFile:="c:\sigma\sql"
	ASQLCRoba(@nH,cSQLFile)
endif

if ! fZaklj
	Zagl(cIdOdj,cDat, cVrstaRs)
endif

Podvuci(cVrstaRs)
nVrijednost:=0

do while !eof()
	nStanje:=0
	nPstanje:=0
	nUlaz:=nIzlaz:=0
	cIdRoba:=POS->IdRoba
	//
	//pocetno stanje - stanje do
	//
	nSlogova:=0
	do while !eof() .and. POS->IdRoba==cIdRoba .and. (POS->Datum<cDat .or. (!Empty(cSmjena) .and. POS->Datum==cDat .and. POS->Smjena<cSmjena))
		
		SELECT (cRSdbf)
		HSEEK cIdRoba
		if (FIELDPOS("K9"))<>0 .and. !Empty(cK9)
			if (field->k9 <> cK9)
				select pos
				skip
				loop
			endif
		endif
		SELECT POS
		
		if !Empty (cIdDio) .and. POS->IdDio <> cIdDio
			skip
			loop
		endif
		if (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos).and.pos->IdPos<>cIdPos)
			// (POS->IdPos="X".and.AllTrim(cIdPos)<>"X").or.;// ?MS
			skip
			loop
		endif
		//
		if cZaduzuje=="S".and.pos->idvd$"42#01"
			skip
			loop  // racuni za sirovine - zdravo
		endif

		if cZaduzuje=="R".and.pos->idvd=="96"
			skip
			loop   // otpremnice za robu - zdravo
		endif
		
		++nSlogova
		
		if POS->idvd$"16#00"
			nPstanje+=POS->Kolicina
			//nVrijednost += POS->Kolicina * POS->Cijena
		elseif POS->idvd $ "IN#NI#"+DOK_IZLAZA
			do case
				case POS->IdVd=="IN"
					nPstanje-=(POS->Kolicina-POS->Kol2)
				case POS->IdVd=="NI"
				
				otherwise // 42#01
					nPstanje-=POS->Kolicina
			endcase
		endif
		skip
	enddo

	//
	//realizacija specificiranog datuma/smjene
	//
	do while !eof() .and. POS->IdRoba==cIdRoba .and. (POS->Datum==cDat .or. (!Empty(cSmjena) .and. POS->Datum==cDat .and. POS->Smjena<cSmjena))
		
		SELECT (cRSdbf)
		HSEEK cIdRoba
		if (FIELDPOS("K9"))<>0 .and. !Empty(cK9)
			if (field->k9 <> cK9)
				select pos
				skip
				loop
			endif
		endif
		SELECT POS
		
		if !Empty(cIdDio) .and. POS->IdDio<>cIdDio
			skip
			loop
		endif
		if cZaduzuje=="S" .and. pos->idvd$"42#01"
			skip
			loop  
			// racuni za sirovine - zdravo
		endif
		if cZaduzuje=="R" .and. pos->idvd=="96"
			skip
			loop   
			// otpremnice za robu - zdravo
		endif
		if (Klevel>"0" .and. pos->idpos="X") .or. (!empty(cIdPos) .and. pos->IdPos<>cIdPos)
			// (POS->IdPos="X".and.AllTrim(cIdPos)<>"X").or.;//?MS
			skip
			loop
		endif
		//
		++nSlogova
		if POS->idvd $ DOK_ULAZA
			nUlaz+=POS->Kolicina
			//nVrijednost += POS->Kolicina * POS->Cijena
		elseif POS->idvd $ "IN#NI#"+DOK_IZLAZA
			do case
				case POS->IdVd=="IN"
					nIzlaz+=(POS->Kolicina-POS->Kol2)
				case POS->IdVd=="NI"
					nIzlaz+=0
				otherwise  
					nIzlaz+=POS->Kolicina
			endcase
		endif
		skip
	enddo
	//
	//stampaj
	//
	nStanje:=nPstanje+nUlaz-nIzlaz
	IF Round(nStanje,4)<>0 .or. cNule=="D" .and. !(nPstanje==0.and.nUlaz==0.and.nIzlaz==0)
		SELECT (cRSdbf)
		HSEEK cIdRoba
		if (FIELDPOS("K9"))<>0 .and. !Empty(cK9)
			if (field->k9 <> cK9)
				select pos
				skip
				loop
			endif
		endif
		
		if (FIELDPOS("MINK"))<>0
			nMink:=roba->mink
		else
			nMink:=0
		endif
		
			
		if ((cMink<>"D" .and. (cNule=="D".or.round(nStanje,4)<>0)) .or. (cMink=="D" .and. nMink<>0 .and. (nStanje-nMink)<0)) .and. !(cMink=="O" .and. nMink==0 .and. round(nStanje,4)==0)
			nCijena1:=cijena1
			? cLM+cIdRoba, PADR(Naz,nRob)+" "
			//
			// VRIJEDNOST = CIJENA U SIFRARNIKU * STANJE KOMADA
			nVrijednost+=nStanje*nCijena1
			SELECT POS
			if cVrstaRs<>"S"
				?
			endif
			?? STR(nPstanje,9,3)
			if round(nUlaz,4)<>0
				?? " "+STR(nUlaz,9,3)
			else
				?? SPACE(10)
			endif
			if Round(nIzlaz,4)<>0
				?? " "+STR(nIzlaz,9,3)
			else
				?? SPACE(10)
			endif
			?? " "+STR(nStanje,10,3)
			if cVrstaRs=="S".or.cUkupno=="D"
				?? " "+STR(nStanje*nCijena1,15,3)
			endif
			if cMink<>"N".and.nMink>0
				? PADR(IF(cMink=="O".and.nMink<>0.and.(nStanje-nMink)<0,"*KRITICNO STANJE !*",""),19)
				?? "  min.kolic:"+STR(nMink,9,3)
			endif

			if (cKontrolisi=="D")
				AnalizirajKontrolnuTabelu(cIdRoba, nStanje, nStanje*nCijena1)
			endif
		endif
	endif

	if fCROBA
		ASQLCRoba(@nH,"#CONT",cIdroba, 'M', '0',nStanje)
	endif

	SELECT POS
	// preko zadanog datuma
	do while !eof() .and. POS->IdRoba==cIdRoba
		skip
	enddo
enddo

if cVrstaRs<>"S"
	Podvuci(cVrstaRs)
	? "Ukupno stanje zaduzenja:", STR(nVrijednost,15,3)
	Podvuci(cVrstaRs)
endif

if fZaklj
	END PRINT
endif

if cVrstaRs<>"S"
	PaperFeed()
endif
//
if !fZaklj
	END PRINT
endif

if fCRoba
	MsgO("Azuriram SQL-CROBA")
	ASQLCRoba(@nH,"#END#"+cSQLFile)
	MsgC()
endif

CLOSERET
*}


/*! \fn Podvuci(cVrstaRs)
 *  \brief Podvlaci red u izvjestaju stanje odjeljenja/dijela objekta
 */
 
function Podvuci(cVrstaRs)
*{
IF cVrstaRs=="S"
  ? cLM+REPL ("-", 10), REPL ("-", nRob) + " "
Else
  ?
EndIF
?? REPL ("-",9), REPL ("-",9), REPL ("-",9), REPL ("-",10)
IF cVrstaRs == "S"
  ?? " "+REPLICATE ("-", 15)
ENDIF
return
*}


/*! \fn Zagl(cIdOdj,dDat, cVrstaRs)
 *  \brief Ispis zaglavlja izvjestaja stanje odjeljenja/dijela objekta
 */

static function Zagl(cIdOdj,dDat, cVrstaRs)
*{
if dDat==NIL
  dDat:=gDatum
endif

START PRINT CRET

ZagFirma()

P_10CPI
? PADC("STANJE ODJELJENJA NA DAN "+FormDat1(dDat),nSir)
? PADC("-----------------------------------",nSir)

IF cVrstaRs <> "K"
  ? cLM+"Prod. mjesto:"+IIF (Empty(cIdPos),"SVE",Ocitaj(F_KASE,cIdPos,"Naz"))
ENDIF
if gvodiodj=="D"
  ? cLM+"Odjeljenje : "+ cIdOdj+"-"+RTRIM(Ocitaj(F_ODJ, cIdOdj,"naz"))
endif
if gModul=="HOPS"
  IF gPostDO == "D"
    ? cLM+"Dio objekta: "+ IIF (Empty(cIdDio), "SVI", cIdDio+"-"+RTRIM(Ocitaj(F_DIO, cIdDio,"naz")))
  EndIF
endif 
? cLM+"Artikal    : "+IF(EMPTY(cRoba),"SVI",RTRIM(cRoba))
?
IF cVrstaRs=="S"
  P_COND
EndIF
? cLM+PADR ("Sifra", 10), PADR ("Naziv artikla", nRob) + " "
IF cVrstaRs<>"S"
  ? cLM
EndIF
?? "P.stanje ", PADC ("Ulaz", 9), PADC ("Izlaz", 9), PADC ("Stanje", 10)
IF cVrstaRs == "S"
   ?? " " + PADC ("Vrijednost", 15)
Else
   ? cLM
ENDIF
return
*}


static function AnalizirajKontrolnuTabelu(cIdRoba, nStanje, nMpv)
*{
local nArea

SELECT (F_KONTROLA)

cKontrolnaTabela:="c:/sigma/kontrola.dbf"

if !USED()
	USE (cKontrolnaTabela)
	SET ORDER TO TAG "ID"
endif

nArea:=SELECT()
SEEK cIdRoba

if FOUND()
	if lCekaj
		if (nMpv<>kontrola->mpv) .or. (nStanje<>kontrola->kolicina)
			MsgBeep(cIdRoba+"#kontrola (stanje, mpv):"+STR(kontrola->kolicina,10,2)+"/"+STR(kontrola->mpv,10,2)+"#pos (stanje, mpv):"+STR(nStanje,10,2)+"/"+STR(nMpv,10,2))
			if (LASTKEY()==K_ESC)
				lCekaj:=.f.
			endif
		endif
	endif
endif

SELECT(nArea)
return
*}
