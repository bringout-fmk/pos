#include "\dev\fmk\pos\pos.ch"


/*! \fn UpdInt1()
 *  \brief Pokrecu se testovi INTEG-1
 */
function UpdInt1(lForce)
*{
if lForce == nil
	lForce := .f.
endif

// provjeri da li treba pokretati INTEG-1
dChDate := DATE() - 1
if !lForce .and. !RunInt1()
	return
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

@ 1+m_x, 2+m_y SAY "Vrsim obradu stanja artikla, na dan" + DToC(dChDate)

do while !eof() .and. field->idodj == cIdOdj
	
	
	altd()
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
		//nUkFStanje += nFStanje
		
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

BoxC()

MsgC()

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


/*! \fn IntegTekGod() 
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



/*! \fn ChkInt1(lForce)
 *  \brief Provjeri test INTEG-1
 *  \param lForce - forsirano
 */
function ChkInt1(lForce)
*{
if ( lForce == nil )
	lForce := .f.
endif
// ova operacija se vrsi samo u knjigovodstvu
if gSamoProdaja == "D"
	return
endif

private nTest:=0
private dChkDate := DATE() - 1

// da li treba provjeravati integritet i koji je test u pitanju
if !RunChk1(@nTest, @dChkDate)
	if !lForce
		return
	endif
endif

if !lForce .and. Pitanje(,"Provjeriti integritet podataka","N")=="N"
	return
endif

O_ROBA
O_DOKS
O_POS
O_ERRORS
O_INTEG1
// zakaci se na kalk
SELECT (F_KALK)
cKKPath:=IzFmkIni("TOPS","KalkKumPath","i:\sigma\kalk\kum1",PRIVPATH)
USE (cKKPath + SLASH + "kalk")
set order to tag "4"

select errors
zap

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
cKFirma:="50"
cKPKonto := IzFmkIni("TOPS","TopsKalkKonto","13270",PRIVPATH)
cKPKonto := PADR(cKPKonto, 7)

Box(,2,65)

@ 1+m_x, 2+m_y SAY "Vrsim provjeru integriteta podataka, na dan" + DToC(dChkDate)

do while !eof() .and. field->idodj == cIdOdj
	
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	nRCjen:=0
	nKartCnt:=0 // broj stavki kartice
	nRobaCnt:=0 // broj sifara artikla
  
  	cIdRoba:=field->IdRoba
	
	select integ1
	set order to tag "1"
	hseek STR(nTest) + cIdRoba
	
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
			AddToErrors("C", cIdRoba, pos->idvd + "-" + ALLTRIM(pos->brdok) + ", datuma:" + DTOC(pos->datum), "Za ovaj dokument ne postoji DOKS master zapis!" )
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
		nUkFStanje += nFStanje
		//nUkKStanje += nKStanje
		
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
			AddToErrors("C", cIdRoba, "", "Greska u OID-u: (TOPSP)=" + ALLTRIM(STR(integ1->oidroba)) + ", (TOPSK)=" + ALLTRIM(STR(nOidRoba)) )
		
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

// ako je forsirano pokretanje opcije
if lForce
	select kalk
	set order to tag "4"
	hseek cKFirma + cKPKonto

	@ 1+m_x, 2+m_y SAY SPACE(65)
	@ 1+m_x, 2+m_y SAY "Provjera integriteta na osnovu KALK-a..."
	
	do while !EOF() .and. kalk->(idfirma+pkonto)==cKFirma+cKPKonto
		
		cKRoba := kalk->idroba
		nKStK := 0
		nKStF := 0
	
		select integ1
		set order to tag "1"
		hseek STR(nTest) + cKRoba

		@ 2+m_x, 2+m_y SAY SPACE(65)
		@ 2+m_x, 2+m_y SAY cKRoba
		
		if !Found()
			AddToErrors("C", cKRoba, kalk->idfirma+"-"+kalk->idvd+"-"+ALLTRIM(kalk->brdok), "Roba ne postoji u sifrarniku kase!")
		endif
		
		select kalk	
		
		do while !EOF() .and. kalk->(idfirma+pkonto+idroba)==cKFirma+cKPKonto+cKRoba
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
				AddToErrors("C", cKRoba, "","KALK->TOPS: neispravno kolicinsko stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStK,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(integ1->stanjek,3))))

			case ROUND(integ1->stanjef,3) <> ROUND(nKStF,3)
				AddToErrors("C", cKRoba, "", "KALK->TOPS: neispravno finansijsko stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStF,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(integ1->stanjef,3))))

		endcase
	
	enddo
endif

BoxC()
MsgC()

select errors
set order to tag "1"
if RecCount() == 0
	MsgBeep("Integritet podataka ok")
	return
endif

lOnlyCrit:=.f.
if Pitanje(,"Prikazati samo critical errors (D/N)?","N")=="D"
	lOnlyCrit:=.t.
endif

START PRINT CRET

? "Rezultati analize integriteta podataka"
? "===================================================="
?

nCrit:=0
nNorm:=0
nWarr:=0
nCnt:=0

go top
do while !EOF()
	cErRoba := field->idroba
	++nCnt
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
		skip
	enddo
enddo

?
? "-----------------------------------------"
? "Critical errors:", ALLTRIM(STR(nCrit))
? "Normal errors:", ALLTRIM(STR(nNorm))
? "Warrnings:", ALLTRIM(STR(nWarr))
?
?

FF
END PRINT


return
*}

function GetErrorDesc(cType)
*{
cRet := ""
do case
	case cType == "C"
		cRet := "Critical"
	case cType == "N"
		cRet := "Normal"
	case cType == "W"
		cRet := "Warrning"
endcase

return cRet
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


/*! \fn RunInt1()
 *  \brief Provjerava da li treba pokrenuti INTEG-1
 */
function RunInt1()
*{
local dChkDate

O_DINTEG1
set order to tag "1"
go bottom

// ako je proslo 10 dana od proteklog testiranja pokreni test
dChkDate := DATE()-10

if ( field->datum < dChkDate )
	return .t.
endif

return .f.
*}


/*! \fn RunChk1(nTest)
 *  \brief Provjerava da li treba pokrenuti provjeru integriteta u knjigovodstvu
 */
function RunChk1(nTest, dCkDate)
*{
local dChkDate

O_DINTEG1
set order to tag "1"
go bottom

// ako je proslo 10 dana od proteklog testiranja pokreni test
dChkDate := DATE()

if ( field->datum == dChkDate )
	nTest := field->id
	dDate := field->chkdat
	return .t.
endif

return .f.
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
