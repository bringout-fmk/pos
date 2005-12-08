#include "\dev\fmk\pos\pos.ch"


/*! \fn UpdInt1(lForce, lReindex)
 *  \brief Pokrecu se testovi INTEG-1
 */
function UpdInt1(lForce, lReindex)
*{
if lForce == nil
	lForce := .f.
endif

// provjeri da li treba pokretati INTEG-1
dChDate := DATE() - 1
if !lForce .and. !RunInt1Upd()
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
nNextID := 0

// prvo uzmi sljedeci ID za DINTEG1
nNextID := GetNextID()

// upisi zapis u DINTEG1
AddDInteg1(nNextID, dChDate)

// prodji kroz POS
select pos
set order to tag "2"
go top

cIdOdj:="  "
cTestRoba:="CTRLCTRL"
nUkCijena:=0
nUkKartCnt:=0
nUkRobaCnt:=0
nUkFStanje:=0
nUkKStanje:=0
nPcStanje:=0

Box(,3,65)

@ 1+m_x, 2+m_y SAY "Vrsim obradu stanja artikla, na dan " + DToC(dChDate) + " br." + ALLTRIM(STR(nNextID))

do while !eof() .and. field->idodj == cIdOdj
	
	
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	cIdRoba:=field->IdRoba
	nRCjen:=0
	nKartCnt:=0 // broj stavki kartice
	nRobaCnt:=0 // broj sifara artikla
  	
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
    		
		if ( field->datum > dChDate )
			skip
			loop
		endif

		// ako je dokument 96 - preskoci
		if field->idvd=="96"
    			skip
			loop
    		endif
		
      		if field->idvd $ DOK_ULAZA
        		nKStanje += field->Kolicina
			//nFStanje += field->kolicina * field->cijena
      		elseif field->idvd $ "IN"
        		nKStanje -= (field->Kolicina - field->Kol2 )
			//nFStanje -= (field->kolicina - field->kol2) * field->cijena
      		elseif field->idvd $ DOK_IZLAZA
        		nKStanje -= field->Kolicina
			//nFStanje -= field->kolicina * field->cijena
      		elseif field->IdVd == "NI"
        		// ne mjenja se kolicina
			//nFStanje -= nKStanje * (field->cijena - field->ncijena)
		endif
		
		if ( field->datum > IntegTekDat() )
			++ nKartCnt
		else
			nPcStanje := 1
		endif
		
		nUkKartCnt += nKartCnt
		nUkKStanje += nKStanje
		
		skip
	enddo
	
	nUkCijena += nRCjen
	nUkRobaCnt += nRobaCnt
	nFStanje := nKStanje * nRCjen
	nUkFStanje += nFStanje
	
	nUkKartCnt += nPcStanje // dodaj i pocetno stanje
	
	// upisi zapis u INTEG1.DBF
	AddInteg1(nNextID, cIdRoba, nOidRoba, cIdTarifa, nKStanje, nFStanje, nKartCnt + nPcStanje, nRobaCnt, nRCjen)	
	
	select pos
enddo

// dodaj kontrolni artikal sa sumarnim vrijednostima
AddInteg1(nNextID, cTestRoba, 0, "", nUkKStanje, nUkFStanje, nUkKartCnt, nUkRobaCnt, nUkCijena)	

// Ubaci checksum podatak u DINTEG1
UpdCSum1(nNextID)

BoxC()
MsgC()

return
*}


/*! \fn UpdCSum1(nId)
 *  \brief Dodaj checksum zapis u DINTEG1
 *  \param nId - id testa
 */
function UpdCSum1(nId)
*{
local nCSum1:=0
local nCSum2:=0
local nCnt:=0

O_DINTEG1
O_INTEG1

select dinteg1
set order to tag "2"
hseek nId
// prodanadji id testa
if Found()
	select integ1
	set order to tag "2"
	hseek nId
	do while !EOF() .and. field->id == nId
		nCSum1 -= integ1->stanjef 
		nCSum2 += integ1->stanjek
		++nCnt
		skip
	enddo
	select dinteg1	
	SmReplace("chkok", "U")
	SmReplace("csum1", nCSum1)
	SmReplace("csum2", nCSum2)
	SmReplace("csum3", nCnt)
endif

return
*}


/*! \fn GetCSum1(nIntID)
 *  \brief Vrati ispravnost checksum-a za integ1
 *  \param nIntID - integ1 id test
 */
function GetCSum1(nIntID)
*{
local nCSum1:=0
local nCSum2:=0
local nCnt:=0

O_INTEG1
select integ1
set order to tag "2"
hseek nIntId

do while !EOF() .and. integ1->id == nIntId
	nCSum1 -= integ1->stanjef 
	nCSum2 += integ1->stanjek
	++nCnt
	skip
enddo
	
// provjeri sada sa DINTEG-om
if (dinteg1->csum3 <> nCnt)
	MsgBeep("INTEG1 TOPS-P/K, ne odgovara broj zapisa!")
	return .f.
endif
if (dinteg1->csum1 <> nCSum1)
	return .f.
endif
if (dinteg1->csum2 <> nCSum2)
	return .f.
endif

return .t.
*}


/*! \fn Int1ChkOK(nId)
 *  \brief Upisuje da je check procedura zavrsena
 */
function Int1ChkOK(nId)
*{
O_DINTEG1
select dinteg1
set order to tag "2"
hseek nId
// prodanadji id testa
if Found()
	replace field->chkok with "Z"
endif

return
*}

/*! \fn ChkInt1(lForce, lReindex)
 *  \brief Provjeri test INTEG-1
 *  \param lForce - forsirano
 *  \param lReindex - reindexirati tabele
 */
function ChkInt1(lForce, lReindex)
*{
local lOidChk := .f.
// privatne varijable
private nTest:=0 // id test integ1
private dChkDate := DATE() - 1 // datum provjere
private lChkOk // da li je update u DINTEG1 - OK

private cKFirma:="" // kalk id firma
private cKPKonto:="" // kalk konto prodavnice
private cKKPath:="" // kalk putanja do kalk.dbf

if ( lForce == nil )
	lForce := .f.
endif

// ova operacija se vrsi samo u knjigovodstvu
if gSamoProdaja == "D"
	return 0
endif

// da li treba provjeravati integritet i koji je test u pitanju
if !RunInt1Chk(@nTest, @dChkDate, @lChkOk, @lForce)
	if lForce == .f. 
		return 0
	elseif lChkOk == .f.
		// nije update dobar - prekini
		return 0
	endif
endif

// ako treba reindexiraj tabele
if !lReindex
	Reindex(.t.)
	lReindex := .t.
endif

// uzmi kalk varijable
GetKalkVars(@cKFirma, @cKPKonto, @cKKPath)

O_ROBA
O_DOKS
O_POS
O_ERRORS
O_INTEG1
// otvori i kalk
OpenKalkDB(cKKPath)

BrisiError()

// prodji kroz POS
select pos
set order to tag "2"
go top

cIdOdj:="  "
cTestRoba:="CTRLCTRL"
nUkKStanje:=0
nUkFStanje:=0
nUkKartCnt:=0
nUkRobaCnt:=0
nUkCijena:=0
nPcStanje:=0

Box(,2,65)

@ 1+m_x, 2+m_y SAY "Vrsim provjeru integriteta stanja, na dan " + DToC(dChkDate) + " br." + ALLTRIM(STR(nTest)) + " K" + ALLTRIM(cKPKonto) 

do while !eof() .and. field->idodj == cIdOdj
	
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	nRCjen:=0
	nKartCnt:=0 // broj stavki kartice
	nRobaCnt:=0 // broj sifara artikla
  
  	cIdRoba:=field->IdRoba
	
	altd()
	
	select integ1
	set order to tag "1"
	hseek STR(nTest) + cIdRoba
	
	if (integ1->idroba <> cIdRoba)
		lOidChk := .t.
	endif
	
	// pronadji robu	
	select roba
	nRobaCnt := GetRobaCnt(cIdRoba)
	
	hseek cIdRoba
	nRCjen := field->cijena1
	nOidRoba := field->_oid_
	cIdTarifa := field->idtarifa
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY "Artikal: " + ALLTRIM(cIdRoba) + ", " + ALLTRIM(field->naz)
	
	select pos
	
	do while !EOF() .and. pos->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    		// datumska provjera
		if ( field->datum > dChkDate )
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

		// ako je dokument 96 - preskoci
		if field->idvd=="96"
    			skip
			loop
    		endif
		
      		if field->idvd $ DOK_ULAZA
        		nKStanje += field->Kolicina
        		//nFStanje += field->Kolicina * field->cijena
			
      		elseif field->idvd $ "IN"
        		nKStanje -= (field->Kolicina - field->Kol2 )
        		//nFStanje -= (field->Kolicina - field->Kol2 ) * field->cijena
			
      		elseif field->idvd $ DOK_IZLAZA
        		nKStanje -= field->Kolicina
			//nFStanje -= field->kolicina * field->cijena
			
      		elseif field->IdVd == "NI"
        		// ne mjenja se kolicina
			//nFStanje -= nKStanje * (field->cijena - field->ncijena)
		endif
		
		if ( field->datum > IntegTekDat() )
			++ nKartCnt
		else
			nPcStanje := 1
		endif
		
		nUkKartCnt += nKartCnt
		nUkKStanje += nKStanje
		
		skip
	enddo
	
	nUkCijena += nRCjen
	nUkRobaCnt += nRobaCnt
	nUkKartCnt += nPcStanje // dodaj i dok.pocetnog stanja
	nFStanje := nKStanje * nRCjen
	nUkFStanje += nFStanje

	select kalk	
	hseek cKFirma + cKPKonto + cIdRoba
	
	cKRoba:=kalk->idroba
	nKKStanje:=0
	nKFStanje:=0
	nKKartCnt:=0
	
	do while !EOF() .and. kalk->(idfirma+pkonto+idroba) == cKFirma + cKPKonto + cKRoba
		if ( kalk->datdok > dChkDate )
			skip
			loop
		endif
		// ulazni dokumenti
		if kalk->pu_i == "1"
			nKKStanje += kalk->kolicina - kalk->gkolicina - kalk->gkolicin2
			nKFStanje += kalk->mpcsapp * kalk->kolicina
		endif
		// izlazni dokumenti
		if kalk->pu_i == "5"
			nKKStanje -= kalk->kolicina
			nKFStanje -= kalk->kolicina * kalk->mpcsapp
		endif
		// ovo ne znam sta je ???
		if kalk->pu_i == "I"
			nKKStanje -= kalk->gkolicin2
			nKFStanje -= kalk->mpcsapp * kalk->gkolicin2
		endif
		// nivelacija
		if kalk->pu_i == "3"
			nKFStanje += kalk->mpcsapp * kalk->kolicina
		endif
			
		++ nKKartCnt
		skip
	enddo
	
	
	// provjera prema INTEG1
	do case
		// provjeri OID
		case integ1->oidroba <> nOidRoba
			AddToErrors("C", cIdRoba, "", "Greska u OID-u: (TOPSP)=" + ALLTRIM(STR(integ1->oidroba)) + ", (TOPSK)=" + ALLTRIM(STR(nOidRoba)))
			// pokreni update sifre iz TOPS-K
			GenSifProd(cIdRoba)
			// dodaj obavjestenje da si generisao log
			AddToErrors("W", cIdRoba, "", "Generisan sql log za TOPS-P, OK")
			select pos
			
		// provjeri TARIFA
		case integ1->idtarifa <> cIdTarifa
			AddToErrors("C", cIdRoba, "", "Greska u tarifi: (TOPSP)=" + integ1->idtarifa + ", (TOPSK)=" + cIdTarifa )
		
		// provjeri STANJE artikla kolicinski
		case ROUND(integ1->stanjek,3) <> ROUND(nKStanje,3)
			AddToErrors("C", cIdRoba, "", "Greska u stanju artikla kolicinski: (TOPSP)=" + ALLTRIM(STR(integ1->stanjek)) + ", (TOPSK)=" + ALLTRIM(STR(nKStanje)) )

		// provjeri stanje artikla finansijski
		case ROUND(integ1->stanjef,3) <> ROUND(nFStanje,2)
			AddToErrors("C", cIdRoba, "", "Greska u stanju artikla finansijski: (TOPSP)=" + ALLTRIM(STR(integ1->stanjef)) + ", (TOPSK)=" + ALLTRIM(STR(nFStanje)) )
		
		// provjeri broj stavki kartice
		case integ1->kartcnt <> nKartCnt + nPcStanje
			AddToErrors("C", cIdRoba, "", "Greska u broju stavki kartice: (TOPSP)=" + ALLTRIM(STR(integ1->kartcnt)) + ", (TOPSK)=" + ALLTRIM(STR(nKartCnt)) )
	
		// provjeri broj istih artikala u sifrarniku artikala
		case integ1->sifrobacnt > 1 .or. nRobaCnt > 1
			AddToErrors("W", cIdRoba, "", "Postoje duple sifre: (TOPSP)=" + ALLTRIM(STR(integ1->sifrobacnt)) + ", (TOPSK)=" + ALLTRIM(STR(nRobaCnt)) )
			// generisi i sifru za prodavnicu
			GenSifProd(cIdRoba)
			AddToErrors("W", cIdRoba, "", "Generisan sql log za TOPS-P, OK")
			select pos	
		// provjeri cijenu artikla
		case integ1->robacijena <> nRCjen
			AddToErrors("C", cIdRoba, "", "Greska u cijeni artikla: (TOPSP)=" + ALLTRIM(STR(integ1->robacijena)) + ", (TOPSK)=" + ALLTRIM(STR(nRCjen)) )
	
		// provjera kartica kalk
		case (nKStanje > 0) .and. nKKartCnt <> (nKartCnt + nPcStanje)
			AddToErrors("W", cIdRoba, "", "Greska u broju stavki kartice: (TOPSK)=" + ALLTRIM(STR(nKartCnt + nPcStanje)) + ", (KALK)=" + ALLTRIM(STR(nKKartCnt)) )
		
		// provjera stanja artikla kalk-tops
		case ROUND(nKKStanje,3) <> ROUND(nKStanje,3)
			AddToErrors("C", cIdRoba, "", "Greska u kolicinskom stanju: (TOPSK)=" + ALLTRIM(STR(nKStanje)) + ", (KALK)=" + ALLTRIM(STR(nKKStanje)))
	
		// provjera stanja artikla kalk-tops
		case ROUND(nKFStanje,3) <> ROUND(nFStanje,3)
			AddToErrors("C", cIdRoba, "", "Greska u prodajnom stanju: (TOPSK)=" + ALLTRIM(STR(nFStanje)) + ", (KALK)=" + ALLTRIM(STR(nKFStanje)) )
			
	endcase
	
	select pos
enddo

// upisi da sam zavrsio provjeru
if !lForce
	Int1ChkOK(nTest)
endif

if lForce
	// ako je forsirano pokretanje opcije pokreni i test KALK->TOPS
	Int1KalkTops(nTest, dChkDate)
endif

BoxC()
MsgC()

return 1
*}


/*! \fn Int1KalkTops(nTest, dChkDate)
 *  \brief Testiranje podataka od strane KALK-a prema TOPS-u
 *  \param nTest - id testa iz integ1
 *  \param dChkDate - datum do kojeg se provjerava stanje
 */
function Int1KalkTops(nTest, dChkDate)
*{
local cFirma
local cKonto
local cRoba
local nKStK
local nKStF
local cPath

GetKalkVars(@cFirma, @cKonto, @cPath)

select kalk
set order to tag "4"
hseek cFirma + cKonto

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Provjera integriteta na osnovu KALK-a..."
	
do while !EOF() .and. kalk->(idfirma+pkonto)==cFirma+cKonto
	cRoba := kalk->idroba
	nKStK := 0
	nKStF := 0

	select integ1
	set order to tag "1"
	hseek STR(nTest) + cRoba

	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY cRoba
		
	if !Found()
		AddToErrors("W", cRoba, kalk->idfirma+"-"+kalk->idvd+"-"+ALLTRIM(kalk->brdok), "Roba ne postoji u sifrarniku kase!")
	endif
		
	select kalk	
		
	do while !EOF() .and. kalk->(idfirma+pkonto+idroba)==cFirma+cKonto+cRoba
		if ( kalk->datdok > dChkDate )
			skip
			loop
		endif
		// ulazni dokumenti
		if kalk->pu_i == "1"
			nKStK += kalk->kolicina - kalk->gkolicina - kalk->gkolicin2
			nKStF += kalk->mpcsapp * kalk->kolicina
		endif
		// izlazni dokumenti
		if kalk->pu_i == "5"
			nKStK -= kalk->kolicina
			nKStF -= kalk->kolicina * kalk->mpcsapp
		endif
		// ovo ne znam sta je ???
		if kalk->pu_i == "I"
			nKStK -= kalk->gkolicin2
			nKStF -= kalk->mpcsapp * kalk->gkolicin2
		endif
		// nivelacija
		if kalk->pu_i == "3"
			nKStF += kalk->mpcsapp * kalk->kolicina
		endif
			
		skip
	enddo

	// provjeri integritet sa INTEG1
	do case
		// stanje kalk -> kasa
		case ROUND(integ1->stanjek,3) <> ROUND(nKStK,3)
			AddToErrors("C", cRoba, "","KALK->TOPS: neispravno kolicinsko stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStK,3))) + " (TOPSP)=" + ALLTRIM(STR(ROUND(integ1->stanjek,3))))
		case ROUND(integ1->stanjef,3) <> ROUND(nKStF,3)
			AddToErrors("C", cRoba, "", "KALK->TOPS: neispravno finansijsko stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStF,3))) + " (TOPSP)=" + ALLTRIM(STR(ROUND(integ1->stanjef,3))))
	endcase
enddo

return
*}



/*! \fn RunInt1Upd()
 *  \brief Provjerava da li treba pokrenuti INTEG-1
 */
function RunInt1Upd()
*{
local dChkDate

O_DINTEG1
set order to tag "2"
go bottom

// koliko dana unazad treba cekati
nDays:=20

// ako je proslo nDays od proteklog testiranja pokreni test
dChkDate := DATE()-nDays

if ( field->datum < dChkDate )
	return .t.
endif

return .f.
*}


/*! \fn RunInt1Chk(nTest, lChkOk, lForce)
 *  \brief Provjerava da li treba pokrenuti provjeru integriteta u knjigovodstvu
 *  \param nTest - id integ1
 *  \param dDate - datum provjere
 *  \param lChkOk - da li je odradjen update 
 */
function RunInt1Chk(nTest, dDate, lChkOk, lForce)
*{
local dChkDate

O_DINTEG1
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
if !GetCSum1(nTest)
	MsgBeep("Checksum nije OK!!!")	
	lChkOk := .f.
	return .f.
endif

lChkOk := .t.
return .t.
*}



/*! \fn GetNextID()
 *  \brief Vraca sljedeci broj DINTEG1.ID
 */
static function GetNextId()
*{
O_DINTEG1
nID:=DInt1NextID()
return nID
*}


/*! \fn AddDInteg1(nIntegID, dCDate)
 *  \brief Dodaj zapis u tabelu DINTEG1.DBF
 *  \param nIntegID - id u tabeli DINTEG1
 *  \param dCDate - datum do kojeg treba vrsiti provjeru
 */
function AddDInteg1(nIntegID, dCDate)
*{
O_DINTEG1
select dinteg1
append blank
Sql_Append()

SmReplace("datum", DATE())
SmReplace("vrijeme", TIME())
SmReplace("id", nIntegId)
SmReplace("chkdat", DATE()-1)

return
*}

/*! \fn AddInteg1(nIntegID)
 *  \brief Upisi zapis u tabelu INTEG1.DBF
 *  \param nIntegID - ID - veza sa tabelom DINTEG1
 */
function AddInteg1(nIntegID, cRoba, nOidRoba, cIdTarifa, nStanjeK, nStanjeF, nKartCnt, nRobaCnt, nCijena)	
*{
O_INTEG1
select integ1
append blank
Sql_Append()

SmReplace("id", nIntegId)
SmReplace("idroba", cRoba)
SmReplace("oidroba", nOidRoba)
SmReplace("idtarifa", cIdTarifa)
SmReplace("stanjek", nStanjeK)
SmReplace("stanjef", nStanjeF)
SmReplace("kartcnt", nKartCnt)
SmReplace("sifrobacnt", nRobaCnt)
SmReplace("robacijena", nCijena)

return
*}
