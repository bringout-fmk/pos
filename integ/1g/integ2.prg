#include "\dev\fmk\pos\pos.ch"


/*! \fn UpdInt2(lForce, lReindex)
 *  \brief Update podataka INTEG-2
 *  \param lForce - pokreni forsirano
 *  \param lReindex - reindexirati tabele
 */
function UpdInt2(lForce, lReindex)
*{
local dChDate
local nNextID
local cIdOdj
local nUkCijena
local nUkFStanje
local nUkKStanje
local nRobaCnt
local nFStanje
local nKStanje
local cIdRoba
local nRCjen
local cIdTarifa
local nOidRoba
local dDateOd

if lForce == nil
	lForce := .f.
endif

// provjeri da li treba pokretati INTEG-2
dChDate := DATE() - 1
// gledat ce se promet do unazad 10 dana
dDateOd := dChDate - 10

if !lForce .and. !RunInt2Upd()
	return
endif

// ako treba reindexiraj tabele
if !lReindex
	Reindex(.t.)
	lReindex := .t.
endif

MsgO("Vrsim analizu integriteta...molimo sacekajte!")

O_ROBA
O_POS

// prvo uzmi sljedeci ID za DINTEG2
nNextID := 0
nNextID := GetNextID()

// upisi zapis u DINTEG2
AddDInteg2(nNextID, dChDate)

// prodji kroz POS
select pos
set order to tag "2"
go top

cIdOdj:="  "
nUkCijena:=0
nUkFStanje:=0
nUkKStanje:=0

Box(,3,65)

@ 1+m_x, 2+m_y SAY "Vrsim obradu prodaje, na dan " + DToC(dChDate) + " br." + ALLTRIM(STR(nNextID))

do while !eof() .and. field->idodj == cIdOdj
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	cIdRoba:=field->IdRoba
	nRCjen:=0
  	
	// pronadji robu	
	select roba
	nRobaCnt := GetRobaCnt(cIdRoba)
	select roba
	go top
	hseek cIdRoba
	nRCjen := roba->cijena1
	nOidRoba := roba->_oid_
	cIdTarifa := roba->idtarifa
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 3+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY "Artikal: " + ALLTRIM(cIdRoba) + ", " + ALLTRIM(field->naz)
	@ 3+m_x, 2+m_y SAY "Cijena: " + ALLTRIM(STR(nRCjen))
	
	select pos
	
	do while !EOF() .and. pos->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    		// provjeri datumski
		if (field->datum < dDateOd) .or. ( field->datum > dChDate )
			skip
			loop
		endif

		// ako je dokument 96 - preskoci
		if field->idvd=="96"
    			skip
			loop
    		endif
	
		if field->idvd $ DOK_IZLAZA
			nKStanje += field->kolicina
		else 
			skip
			loop
		endif
      		
		skip
	enddo

	if nKStanje == 0
		skip
		loop
	endif
	
	nFStanje := nKStanje * nRCjen
	
	// upisi zapis u INTEG2.DBF
	AddInteg2(nNextID, cIdRoba, nOidRoba, cIdTarifa, nKStanje, nFStanje, nRobaCnt, nRCjen)	
	
	select pos
enddo

// Ubaci checksum podatak u DINTEG1
UpdCSum2(nNextID)

BoxC()
MsgC()
return
*}


/*! \fn GetNextID()
 *  \brief Vraca sljedeci broj DINTEG2.ID
 */
static function GetNextId()
*{
O_DINTEG2
nID:=DInt2NextID()
return nID
*}


/*! \fn RunInt2Upd()
 *  \brief Treba li pokretati UpdInt2()
 */
function RunInt2Upd()
*{
local dChkDate

O_DINTEG2
set order to tag "2"
go bottom

// koliko dana unazad treba cekati (def.5)
nDays:=5

// ako je proslo nDays od proteklog testiranja pokreni test
dChkDate := DATE()-nDays

if ( field->datum < dChkDate )
	return .t.
endif

return .f.
*}


/*! \fn ChkInt2(lForce, lReindex)
 *  \brief Provjera integriteta INTEG-2
 *  \param lForce - forsirano pokretanje
 *  \param lReindex - reindexiraj tabele
 */
function ChkInt2(lForce, lReindex)
*{
local nTest:=0 // id test integ1
local dChkDate := DATE() - 1 // datum provjere
local dDateOd
local lChkOk // da li je update u DINTEG1 - OK
local cIdOdj
local cIdRoba
local cIdTarifa
local cRCjen
local nOidRoba
local lRunOidChk:=.f.

//local cKFirma:="" // kalk id firma
//local cKPKonto:="" // kalk konto prodavnice
//local cKKPath:="" // kalk putanja do kalk.dbf

if ( lForce == nil )
	lForce := .f.
endif

// ova operacija se vrsi samo u knjigovodstvu
if gSamoProdaja == "D"
	return 0
endif

// da li treba provjeravati integritet i koji je test u pitanju
if !RunInt2Chk(@nTest, @dChkDate, @lChkOk, @lForce)
	if lForce == .f.
		return 0
	elseif lChkOk == .f.
		// nije update dobar - prekini
		return 0
	endif
endif

// ako je potrebno reindexiraj tabele
if !lReindex
	Reindex(.t.)
	lReindex := .t.
endif

dDateOd := dChkDate - 10

// uzmi kalk varijable
//GetKalkVars(@cKFirma, @cKPKonto, @cKKPath)

O_ROBA
O_DOKS
O_POS
O_ERRORS
O_INTEG2

// probrisi tabelu errors
BrisiError()

// prodji kroz POS
select pos
set order to tag "2"
go top

cIdOdj:="  "

Box(,2,65)

@ 1+m_x, 2+m_y SAY "Vrsim provjeru integriteta prodaje, na dan " + DToC(dChkDate) + " br." + ALLTRIM(STR(nTest)) 

do while !eof() .and. field->idodj == cIdOdj
	
	nFStanje:=0
	nKStanje:=0
  	nRCjen:=0
	nRobaCnt:=0 // broj sifara artikla
	lOidChk:=.f.
  
  	cIdRoba:=field->IdRoba
	
	select integ2
	set order to tag "1"
	hseek STR(nTest) + cIdRoba
	
	if (integ2->idroba <> cIdRoba)
		lOidChk := .t.
	endif
	
	// pronadji robu	
	select roba
	nRobaCnt := GetRobaCnt(cIdRoba)
	
	select roba
	hseek cIdRoba
	nRCjen := field->cijena1
	nOidRoba := field->_oid_
	cIdTarifa := field->idtarifa
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY "Artikal: " + ALLTRIM(cIdRoba) + ", " + ALLTRIM(field->naz)
	
	select pos
	
	do while !EOF() .and. pos->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    		// datumska provjera
		if (field->datum < dDateOd) .or. (field->datum >dChkDate)
			skip
			loop
		endif
		// ako je dokument 96 preskoci
		if field->idvd=="96"
    			skip
			loop
    		endif
		if field->idvd $ DOK_IZLAZA
			nKStanje += field->kolicina
		else
			skip
			loop
		endif

		// ispitaj da li postoji doks master record za ovaj dokument
		select doks
		set order to tag "1"
		hseek pos->idpos + pos->idvd + DTOS(pos->datum) + pos->brdok
		
		if !Found()
			AddToErrors("C", "DOKSERR", pos->idvd + "-" + ALLTRIM(pos->brdok) + "-" + DToC(pos->datum), "Za ovaj dokument ne postoji DOKS master zapis!" )
		endif
		
		select pos
		skip
	enddo

	if (nKStanje == 0)
		skip
		loop
	endif
	
	nFStanje := nKStanje * nRCjen
	
	// provjera prema INTEG2
	do case
		// provjeri OID
		case integ2->oidroba <> nOidRoba
			if lOidChk
				AddToErrors("N", cIdRoba, "", "Provjerite OID: (TOPSP)=" + ALLTRIM(STR(integ2->oidroba)) + ", (TOPSK)=" + ALLTRIM(STR(nOidRoba)) )
			else
				AddToErrors("C", cIdRoba, "", "Greska u OID-u: (TOPSP)=" + ALLTRIM(STR(integ2->oidroba)) + ", (TOPSK)=" + ALLTRIM(STR(nOidRoba)) )
				// generisi novu sifru za prodavnicu
				GenSifProd(cIdRoba)
				// dodaj obavjestenje da si generisao log za prodavnicu
				AddToErrors("W", cIdRoba, "", "Generisan sql log za TOPS-P, OK")
			endif
			
			// ako je doslo do ovoga provjeri i oid-e
			lRunOidChk := .t.
			
		// provjeri TARIFA
		case integ2->idtarifa <> cIdTarifa
			AddToErrors("C", cIdRoba, "", "Greska u tarifi: (TOPSP)=" + integ2->idtarifa + ", (TOPSK)=" + cIdTarifa )
		
		// provjeri STANJE artikla kolicinski
		case ROUND(integ2->stanjek,3) <> ROUND(nKStanje,3)
			AddToErrors("C", cIdRoba, "", "Greska u prodaji kolicinski: (TOPSP)=" + ALLTRIM(STR(integ2->stanjek)) + ", (TOPSK)=" + ALLTRIM(STR(nKStanje)) )
			// i ovo moze biti indikator dupliranog stanja
			lRunOidChk := .t.
		// provjeri stanje artikla finansijski
		case ROUND(integ2->stanjef,3) <> ROUND(nFStanje,2)
			AddToErrors("C", cIdRoba, "", "Greska u prodaji finansijski: (TOPSP)=" + ALLTRIM(STR(integ2->stanjef)) + ", (TOPSK)=" + ALLTRIM(STR(nFStanje)) )
		
		// provjeri broj istih artikala u sifrarniku artikala
		case integ2->sifrobacnt > 1 .or. nRobaCnt > 1
			AddToErrors("W", cIdRoba, "", "Postoje duple sifre: (TOPSP)=" + ALLTRIM(STR(integ2->sifrobacnt)) + ", (TOPSK)=" + ALLTRIM(STR(nRobaCnt)) )
			// generisi novu sifru za prodavnicu
			GenSifProd(cIdRoba)
			// dodaj obavjestenje da si generisao log za prodavnicu	
			AddToErrors("W", cIdRoba, "", "Generisan sql log za TOPS-P, OK")
		// provjeri cijenu artikla
		case integ2->robacijena <> nRCjen
			AddToErrors("C", cIdRoba, "", "Greska u cijeni artikla: (TOPSP)=" + ALLTRIM(STR(integ2->robacijena)) + ", (TOPSK)=" + ALLTRIM(STR(nRCjen)) )
	endcase
	
	select pos
enddo

// upisi da sam zavrsio provjeru
if !lForce
	Int2ChkOK(nTest)
endif

BoxC()
MsgC()

// ako je .t. pokreni i ovaj test
if lRunOidChk
	//     datum od, datum do, ne kompletne tabele (samo datumski period)
	OidChk(dDateOd, dChkDate, .f.)
endif

return 1
*}


/*! \fn RunInt2Chk(nTest, dDate, lChkOk)
 *  \brief Treba li pokretati ChkInt2()
 */
function RunInt2Chk(nTest, dDate, lChkOk, lForce)
*{
local dChkDate

O_DINTEG2
set order to tag "2"
go bottom

dChkDate := DATE()

// ako nije forsirano provjeri datum
if !lForce
	if ( field->datum == dChkDate )
		if (field->chkok == "Z")
			lChkOk := .f.
			return .f.
		endif
		if (field->chkok <> "U")
			lChkOk := .f.
			return .f.
		endif
	else
		lChkOk := .f.
		return .f.
	endif
endif

// dodijeli parametre
nTest := field->id
dDate := field->chkdat
// provjeri checksum
if !GetCSum2(nTest)
	MsgBeep("Checksum nije OK!!!")	
	lChkOk := .f.
	return .f.
endif

lChkOk := .t.
return .t.
*}


/*! \fn UpdCSum2(nId)
 *  \brief Dodaj checksum zapis u DINTEG2
 *  \param nId - id testa
 */
function UpdCSum2(nId)
*{
local nCSum1:=0
local nCSum2:=0
local nCnt:=0

O_DINTEG2
O_INTEG2

select dinteg2
set order to tag "2"
hseek nId
// prodanadji id testa
if Found()
	select integ2
	set order to tag "2"
	hseek nId
	do while !EOF() .and. field->id == nId
		nCSum1 -= integ2->stanjef 
		nCSum2 += integ2->stanjek
		++nCnt
		skip
	enddo
	select dinteg2
	SmReplace("chkok", "U")
	SmReplace("csum1", nCSum1)
	SmReplace("csum2", nCSum2)
	SmReplace("csum3", nCnt)
endif

return
*}


/*! \fn GetCSum2(nIntID)
 *  \brief Vrati ispravnost checksum-a za integ2
 *  \param nIntID - integ2 id test
 */
function GetCSum2(nIntID)
*{
local nCSum1:=0
local nCSum2:=0
local nCnt:=0

O_INTEG2
select integ2
set order to tag "2"
hseek nIntId

do while !EOF() .and. integ2->id == nIntId
	nCSum1 -= integ2->stanjef 
	nCSum2 += integ2->stanjek
	++nCnt
	skip
enddo
	
// provjeri sada sa DINTEG-om
if (dinteg2->csum3 <> nCnt)
	MsgBeep("INTEG1 TOPS-P/K, ne odgovara broj zapisa!")
	return .f.
endif
if (dinteg2->csum1 <> nCSum1)
	return .f.
endif
if (dinteg2->csum2 <> nCSum2)
	return .f.
endif

return .t.
*}


/*! \fn Int2ChkOK(nId)
 *  \brief Upisuje da je check procedura zavrsena
 */
function Int2ChkOK(nId)
*{
O_DINTEG2
select dinteg2
set order to tag "2"
hseek nId
// prodanadji id testa
if Found()
	replace field->chkok with "Z"
endif
return
*}




/*! \fn AddDInteg2(nIntegID, dCDate)
 *  \brief Dodaj zapis u tabelu DINTEG2.DBF
 *  \param nIntegID - id u tabeli DINTEG2
 *  \param dCDate - datum do kojeg treba vrsiti provjeru
 */
function AddDInteg2(nIntegID, dCDate)
*{
O_DINTEG2
select dinteg2
append blank
Sql_Append()

SmReplace("datum", DATE())
SmReplace("vrijeme", TIME())
SmReplace("id", nIntegId)
SmReplace("chkdat", DATE()-1)

return
*}

/*! \fn AddInteg2(nIntegID)
 *  \brief Upisi zapis u tabelu INTEG2.DBF
 *  \param nIntegID - ID - veza sa tabelom DINTEG2
 */
function AddInteg2(nIntegID, cRoba, nOidRoba, cIdTarifa, nStanjeK, nStanjeF, nRobaCnt, nCijena)
*{
O_INTEG2
select integ2
append blank
Sql_Append()

SmReplace("id", nIntegId)
SmReplace("idroba", cRoba)
SmReplace("oidroba", nOidRoba)
SmReplace("idtarifa", cIdTarifa)
SmReplace("stanjek", nStanjeK)
SmReplace("stanjef", nStanjeF)
SmReplace("sifrobacnt", nRobaCnt)
SmReplace("robacijena", nCijena)

return
*}


