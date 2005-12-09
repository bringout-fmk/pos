#include "\dev\fmk\pos\pos.ch"

/*! \fn GetKalkVars(cFirma, cKonto, cPath)
 *  \brief Vraca osnovne var.za rad sa kalk-om
 *  \param cFirma - id firma kalk
 *  \param cKonto - konto prodavnice u kalk-u
 *  \param cPath - putanja do kalk.dbf
 */
function GetKalkVars(cFirma, cKonto, cPath)
*{
// firma je uvijek 50
cFirma:="50"
// konto prodavnicki
cKonto := IzFmkIni("TOPS", "TopsKalkKonto", "13270", KUMPATH)
cKonto := PADR(cKonto, 7)
// putanja
cPath := IzFmkIni("TOPS", "KalkKumPath", "i:\sigma", KUMPATH)
return
*}


/*! \fn OpenKalkDBF(cPath)
 *  \brief otvara tabelu kalk
 *  \param cPath - putanja do kalk.dbf
 */
function OpenKalkDB(cPath)
*{
// zakaci se na kalk
SELECT (F_KALK)
USE (cPath + SLASH + "kalk")
// postavi order "4"
set order to tag "4"

return
*}


/*! \fn IntegTekGod()
 *  \brief Vraca tekucu godinu, ako je tek.datum veci od 10.01.TG onda je godina = TG, ako je tek.datum <= 10.01.TG onda je godina (TG - 1)
 *  \return string cYear
 */
function IntegTekGod()
*{
local dTDate
local dPDate
local dTYear
local cYear

dTYear := YEAR(DATE()) // tekuca godina
dPDate := SToD(ALLTRIM(STR(dTYear))+"0110") // preracunati datum
dTDate := DATE() // tekuci datum

if dTDate > dPDate
	cYear := ALLTRIM( STR( YEAR( DATE() ) ))	
else
	cYear := ALLTRIM( STR( YEAR( DATE() ) - 1 ))
endif

return cYear
*}

/*! \fn IntegTekDat() 
 *  \brief Vraca datum od kada pocinje tekuca godina TOPS, 01.01.TG
 */
function IntegTekDat()
*{
local dYear
local cDate

dYear := YEAR(DATE())
cDate := ALLTRIM( IntegTekGod() ) + "0101"

return SToD(cDate)
*}

/*! \fn AddToErrors(cType, cIdRoba, cDoks, cOpis)
 *  \brief dodaj zapis u tabelu errors
 */
function AddToErrors(cType, cIDroba, cDoks, cOpis)
*{
O_ERRORS
append blank
replace field->type with cType
replace field->idroba with cIdRoba
replace field->doks with cDoks
replace field->opis with cOpis

return
*}


/*! \fn GetRobaCnt(cIdRoba)
 *  \brief Vraca broj sifara robe u sifrarniku robe
 *  \param cIdRoba - trazeni artikal
 */
function GetRobaCnt(cIdRoba)
*{
select roba
hseek cIdRoba
nRet:=0
do while !EOF() .and. field->id == cIdRoba
	++ nRet
	skip
enddo

return nRet
*}

/*! \fn GetErrorDesc(cType)
 *  \brief Vrati naziv greske po cType
 *  \param cType - tip greske, C, W, N ...
 */
function GetErrorDesc(cType)
*{
cRet := ""
do case
	case cType == "C"
		cRet := "Critical:"
	case cType == "N"
		cRet := "Normal:  "
	case cType == "W"
		cRet := "Warrning:"
	case cType == "P"
		cRet := "Probably OK:"
endcase

return cRet
*}

/*! \fn RptInteg()
 *  \brief report nakon testa integ1
 *  \param lFilter - filter za kriticne greske
 *  \param lAutoSent - automatsko slanje email-a
 */
function RptInteg(lFilter, lAutoSent)
*{
if (lFilter == nil)
	lFilter := .f.
endif
if (lAutoSent == nil)
	lAutoSent := .f.
endif

O_ERRORS
select errors
set order to tag "1"
if RecCount() == 0
	MsgBeep("Integritet podataka ok")
	//return
endif

lOnlyCrit:=.f.
if lFilter .and. Pitanje(,"Prikazati samo critical errors (D/N)?","N")=="D"
	lOnlyCrit:=.t.
endif

START PRINT CRET

? "Rezultati analize integriteta podataka"
? "===================================================="
?

nCrit:=0
nNorm:=0
nWarr:=0
nPrOk:=0
nCnt:=1
cTmpDoks:="XXXX"


go top
do while !EOF()
	cErRoba := field->idroba
	if lOnlyCrit .and. ALLTRIM(field->type) == "C"
		? STR(nCnt, 4) + ". " + ALLTRIM(field->idroba)
	endif
	if !lOnlyCrit
		? STR(nCnt, 4) + ". " + ALLTRIM(field->idroba)
	endif
	
	do while !EOF() .and. field->idroba == cErRoba
		
		if lOnlyCrit .and. ALLTRIM(field->type) <> "C"
			skip
			loop
		endif
		
		// ako je prazno DOKSERR onda fali doks
		if cErRoba = "DOKSERR"
			if ALLTRIM(field->doks) == cTmpDoks
				skip
				loop
			endif
		endif
		
		cTmpDoks := ALLTRIM(field->doks)
		
		++nCnt
		
		? SPACE(5) + GetErrorDesc(ALLTRIM(field->type)), ALLTRIM(field->doks), ALLTRIM(field->opis)	
	
		if ALLTRIM(field->type) == "C"
			++ nCrit 
		endif
		if ALLTRIM(field->type) == "N"
			++ nNorm 
		endif
		if ALLTRIM(field->type) == "W"
			++ nWarr 
		endif
		if ALLTRIM(field->type) == "P"
			++ nPrOk
		endif
	
		skip
	enddo
enddo

?
? "-----------------------------------------"
? "Critical errors:", ALLTRIM(STR(nCrit))
? "Normal errors:", ALLTRIM(STR(nNorm))
? "Warrnings:", ALLTRIM(STR(nWarr))
? "Probably OK:", ALLTRIM(STR(nPrOK))
?
?

FF
END PRINT

RptSendEmail(lAutoSent)

return
*}

/*! \fn RptSendEmail()
 *  \brief Slanje reporta na email
 */
function RptSendEmail(lAuto)
*{
local cScript
local cPSite
local cRptFile

if (lAuto == nil)
	lAuto := .f.
endif
// postavi pitanje ako nije lAuto
if !lAuto .and. Pitanje(,"Proslijediti report email-om (D/N)?", "D") == "N"
	return
endif

// setuj varijable
GetSendVars(@cScript, @cPSite, @cRptFile)
// komanda je sljedeca
cKom := cScript + " " + cPSite + " " + cRptFile 

// snimi sliku i ocisti ekran
save screen to cRbScr
clear screen

? "TOPS::err2mail send..."
// pokreni komandu
run &cKom

Sleep(3)
// vrati staro stanje ekrana
restore screen from cRbScr

return
*}


/*! \fn GetSendVars(cScript)
 *  \param cScript - ruby skripta
 *  \param cPSite - prodavnicki site
 *  \param cRptFile - report fajl
 */
function GetSendVars(cScript, cPSite, cRptFile)
*{
cScript := IzFmkIni("Ruby","Err2Mail","c:\sigma\err2mail.rb", EXEPATH)
cPSite := ALLTRIM(STR(gSqlSite))
cRptFile := PRIVPATH + "outf.txt"
return
*}


/*! \fn OidChk(dDatOd, dDatDo, lSve)
 *  \brief Provjera duplih OID-a
 *  \param dDatOd - datum od provjera
 *  \param dDatDo - datum do provjera
 *  \param lSve - kompletna tabela
 */
function OidChk(dDatOd, dDatDo, lSve)
*{
MsgO("Provjeravam integritet OID-a ...")

// otvori box
Box(,2,65)

// provjeri pos
O_POS
select pos
set order to tag "OID"
PosOidChk(dDatOd, dDatDo, lSve)

// provjeri doks
O_DOKS
select doks
set order to tag "OID"
DoksOidChk(dDatOd, dDatDo, lSve)

// provjeri roba
O_ROBA
select roba
set order to tag "OID"
RobaOidChk()

BoxC()
MsgC()

return
*}


/*! \fn PosOidChk()
 *  \brief Provjera duplih oid-a u tabeli POS
 *  \param dDatOd - datum od kojeg se vrsi provjera
 *  \param dDatDo - datum do kojeg se vrsi provjera
 *  \param lSve - kompletna tabela
 */
function PosOidChk(dDatOd, dDatDo, lSve)
*{
local nOid
local cFirma
local cBrDok
local dDatum
local cIdRoba
local nKolicina
local nCijena
local nCnt
local cIdVd
local lReindex

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Vrsim provjeru tabele POS..."

go top
do while !EOF()
	// uzmi glavne vrijednosti tekuceg zapisa
	nOid := field->_oid_
	cFirma := field->idpos
	cBrDok := field->brdok
	cIdVd := field->idvd
	dDatum := field->datum
	cRoba := field->idroba
	nKolicina := field->kolicina
	nCijena := field->cijena
	nCnt := 0
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY ALLTRIM(STR(nOid))
	
	do while !EOF() .and. field->_oid_ == nOid
		// vrsi se provjera datumskog perioda
		altd()
		if !lSve
			if (field->datum < dDatOd) .or. (field->datum > dDatDo)
				skip
				loop
			endif
		endif
		++ nCnt
		// ako je prvi zapis njega smo uzeli pa cemo ga preskociti
		if (nCnt > 1)
			if field->_oid_ == nOid
				// uporedi zapise
				if pos->(idpos + brdok + idvd + DToS(datum) + idroba + STR(kolicina) + STR(cijena)) == cFirma + cBrDok + cIdVd + DToS(dDatum) + cRoba + STR(nKolicina) + STR(nCijena)
					// dupli oid isti zapisi
					
					// dodaj u pom.tabelu sta si izbrisao
					AddToErrors("W", "OIDDEL", pos->idvd + "-" + pos->brdok + " od " + DToC(pos->datum), "POS.DBF: pobrisan OID " + ALLTRIM(STR(field->_oid_)) + "!")
					// brisi ga
					select pos
					delete
				else
					// dupli oid razliciti zapisi
					AddToErrors("C", "OIDERR", pos->idvd + "-" + pos->brdok + " od " + DToC(pos->datum), "POS.DBF: Postoji dupli OID, podaci polja nisu identicni!")
					select pos
				endif
			endif
		endif
		
		select pos		
		skip
	enddo
enddo

return 1
*}


/*! \fn DoksOidChk(dDatOd, dDatDo, lSve)
 *  \brief Provjera duplih oida u tabeli DOKS
 *  \param dDatOd - datum od provjera
 *  \param dDatDo - datum do provjera
 *  \param lAll - kompletna tabela
 */
function DoksOidChk(dDatOd, dDatDo, lSve)
*{
local nOid
local cFirma
local cBrDok
local dDatum
local cIdVd
local nCnt

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Vrsim provjeru tabele DOKS ..."

go top
do while !EOF()
	// uzmi glavne vrijednosti tekuceg zapisa
	nOid := field->_oid_
	cFirma := field->idpos
	cBrDok := field->brdok
	dDatum := field->datum
	cIdVd := field->idvd
	nCnt := 0
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY ALLTRIM(STR(nOid))

	do while !EOF() .and. field->_oid_ == nOid
		// vrsi se provjera datumskog perioda
		if !lSve
			if (field->datum < dDatOd) .or. (field->datum > dDatDo)
				skip
				loop
			endif
		endif
		
		++ nCnt
		// ako je prvi zapis njega smo uzeli pa cemo ga preskociti
		if (nCnt > 1)
			if field->_oid_ == nOid
				// uporedi zapise
				if doks->(idpos + brdok + DToS(datum) + idvd) == cFirma + cBrDok + DToS(dDatum) + cIdVd
					// dupli oid isti zapisi
				
					// dodaj u pom.tabelu sta si izbrisao
					AddToErrors("W", "OIDDEL", doks->idvd + "-" + doks->brdok + " od " + DToC(doks->datum), "DOKS.DBF: pobrisan OID " + ALLTRIM(STR(field->_oid_)) + "!")
					// brisi ga
					select doks
					delete
				else
					// dupli oid razliciti zapisi
					AddToErrors("C", "OIDERR", doks->idvd + "-" + doks->brdok + " od " + DToC(doks->datum), "DOKS.DBF: Postoji dupli OID, podaci polja nisu identicni!")
					select doks
				endif
			endif
		endif
		
		select doks
		skip
	enddo
enddo

return 1
*}


/*! \fn RobaOidChk()
 *  \brief Provjera duplih oid-a u tabeli ROBA
 */
function RobaOidChk()
*{
local nOid
local cIdRoba
local cRobaNaz
local nCijena1
local cTarifa
local nCnt

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Vrsim provjeru tabele ROBA ..."

go top
do while !EOF()
	// uzmi glavne vrijednosti tekuceg zapisa
	nOid := field->_oid_
	cIdRoba := field->id
	cRobaNaz := field->naz
	nCijena1 := field->cijena1
	cTarifa := field->idtarifa
	nCnt := 0
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY ALLTRIM(STR(nOid))

	do while !EOF() .and. field->_oid_ == nOid
		++ nCnt
		// ako je prvi zapis njega smo uzeli pa cemo ga preskociti
		if (nCnt > 1)
			if field->_oid_ == nOid
				// uporedi zapise
				if roba->(id + naz + idtarifa + STR(cijena1)) == cIdRoba + cRobaNaz + cTarifa + STR(nCijena1)
					// dupli oid isti zapisi
					// dodaj u pom.tabelu sta si izbrisao
					AddToErrors("W", "OIDDEL", roba->id + "-" + roba->naz, "ROBA.DBF: Pobrisan oid " + ALLTRIM(STR(field->_oid_))+ "!")
					// brisi ga
					select roba
					delete
				else
					// dupli oid razliciti zapisi
					AddToErrors("C", "OIDERR", roba->id + "-" + roba->naz, "ROBA.DBF: Postoji dupli OID, podaci polja nisu identicni!")
					select roba
				endif
			endif
		endif
		
		select roba
		skip
	enddo
enddo

return 1
*}

/*! \fn BrisiError()
 *  \brief Brisanje tabele Errors.dbf
 */
function BrisiError()
*{
O_ERRORS
select errors
zap
return
*}


/*! \fn GenSifProd(cIdRoba)
 *  \brief generisi log za sifre artikala u prodavnici
 */
function GenSifProd(cIdRoba)
*{
LogRecRoba(cIdRoba)
return
*}

/*! \fn NewSifProd(cIdRoba)
 *  \brief generisi log za sifre artikala u prodavnici
 */
function NewSifProd(cIdRoba)
*{
NewRecRoba(cIdRoba)
return
*}


/*! \fn EmptDInt(nInteg)
 *  \brief Da li je prazna tabela dinteg
 */
function EmptDInt(nInteg)
*{
local cInteg := ALLTRIM(STR(nInteg))
local cTbl := "DINTEG" + cInteg
O_DINTEG1
O_DINTEG2
select &cTbl

if RecCount() == 0
	MsgBeep("Tabela " + cTbl + " je prazna !!!")
	return .t.
else
	return .f.
endif

return
*}

