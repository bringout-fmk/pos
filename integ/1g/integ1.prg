#include "\dev\fmk\pos\pos.ch"


/*! \fn UpdInt1()
 *  \brief Pokrecu se testovi INTEG-1
 */
function UpdInt1()
*{
// provjeri da li treba pokretati INTEG-1
if !RunInt1()
	return
endif

MsgO("Vrsim analizu integriteta...molimo sacekajte!")

O_ROBA
O_POS
nNextID := 0

// prvo uzmi sljedeci ID za DINTEG1
nNextID := GetNextID()

// upisi zapis u DINTEG1
AddDInteg1(nNextID)

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

Box(,2,65)

@ 1+m_x, 2+m_y SAY "Vrsim obradu stanja artikla"

do while !eof() .and. field->idodj == cIdOdj
	
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	cIdRoba:=field->IdRoba
	nCijena:=0
	nKartCnt:=0 // broj stavki kartice
	nRobaCnt:=0 // broj sifara artikla
  	
	// pronadji robu	
	select roba
	nRobaCnt := GetRobaCnt(cIdRoba)
	
	hseek cIdRoba
	nCijena := field->cijena1
	nOidRoba := field->_oid_
	cIdTarifa := field->idtarifa
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY "Artikal: " + ALLTRIM(cIdRoba) + ", " + ALLTRIM(field->naz)
	
	select pos
	
	do while !EOF() .and. pos->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    		
		// ako je dokument 96 - preskoci
		if field->idvd=="96"
    			skip
			loop
    		endif
		
      		if field->idvd $ DOK_ULAZA
        		nKStanje += field->Kolicina
      		elseif field->idvd $ "IN"
        		nKStanje -= (field->Kolicina - field->Kol2 )
      		elseif field->idvd $ DOK_IZLAZA
        		nKStanje -= POS->Kolicina
      		elseif field->IdVd == "NI"
        		// ne mjenja se kolicina

		endif
		
		++ nKartCnt
		
		nUkKartCnt += nKartCnt
		nUkKStanje += nKStanje
		nUkFStanje += nFStanje
		
		skip
	enddo
	
	nUkCijena += nCijena
	nUkRobaCnt += nRobaCnt
	
	// upisi zapis u INTEG1.DBF
	AddInteg1(nNextID, cIdRoba, nOidRoba, cIdTarifa, nKStanje, nFStanje, nKartCnt, nRobaCnt, nCijena)	
	
	select pos
enddo

// dodaj kontrolni artikal sa sumarnim vrijednostima
AddInteg1(nNextID, cTestRoba, 0, "", nUkKStanje, nUkFStanje, nUkKartCnt, nUkRobaCnt, nUkCijena)	

BoxC()

MsgC()

return
*}


/*! \fn ChkInt1()
 *  \brief Provjeri test INTEG-1
 */
function ChkInt1()
*{

// ova operacija se vrsi samo u knjigovodstvu
if gSamoProdaja == "D"
	return
endif

private nTest:=0

// da li treba provjeravati integritet i koji je test u pitanju
if !RunChk1(@nTest)
	return
endif

if Pitanje(,"Provjeriti integritet podataka","N")=="N"
	return
endif

O_ROBA
O_POS
O_INTEG1

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

aErrCritical := {}
aErrNormal := {}
aErrWarrning := {}

Box(,2,65)

@ 1+m_x, 2+m_y SAY "Vrsim provjeru integriteta podataka..."

do while !eof() .and. field->idodj == cIdOdj
	
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	nCijena:=0
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
	nCijena := field->cijena1
	nOidRoba := field->_oid_
	cIdTarifa := field->idtarifa
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY "Artikal: " + ALLTRIM(cIdRoba) + ", " + ALLTRIM(field->naz)
	
	select pos
	
	do while !EOF() .and. pos->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    		
		// ako je dokument 96 - preskoci
		if field->idvd=="96"
    			skip
			loop
    		endif
		
      		if field->idvd $ DOK_ULAZA
        		nKStanje += field->Kolicina
			
      		elseif field->idvd $ "IN"
        		nKStanje -= (field->Kolicina - field->Kol2 )
			
      		elseif field->idvd $ DOK_IZLAZA
        		nKStanje -= field->Kolicina
			
      		elseif field->IdVd == "NI"
        		// ne mjenja se kolicina

		endif
		
		++ nKartCnt
		
		nUkKartCnt += nKartCnt
		nUkFStanje += nFStanje
		nUkKStanje += nKStanje
		
		skip
	enddo
	
	nUkCijena += nCijena
	nUkRobaCnt += nRobaCnt
	
	// provjera prema INTEG1
	do case
		// provjeri OID
		case integ1->oidroba <> nOidRoba
			AADD(aErrCritical, {cIdRoba, "Greska u OID-u: (TOPSP)=" + ALLTRIM(STR(integ1->oidroba)) + ", (TOPSK)=" + ALLTRIM(STR(nOidRoba)) })
		
		// provjeri TARIFA
		case integ1->idtarifa <> cIdTarifa
			AADD(aErrCritical, {cIdRoba, "Greska u tarifi: (TOPSP)=" + integ1->idtarifa + ", (TOPSK)=" + cIdTarifa })
		
		
		// provjeri STANJE artikla kolicinski
		case integ1->stanjek <> nKStanje
			AADD(aErrCritical, {cIdRoba, "Greska u stanju artikla kolicinski: (TOPSP)=" + ALLTRIM(STR(integ1->stanjek)) + ", (TOPSK)=" + ALLTRIM(STR(nKStanje)) })

		// provjeri stanje artikla finansijski
		case integ1->stanjef <> nFStanje
			AADD(aErrCritical, {cIdRoba, "Greska u stanju artikla finansijski: (TOPSP)=" + ALLTRIM(STR(integ1->stanjef)) + ", (TOPSK)=" + ALLTRIM(STR(nFStanje)) })
		
		// provjeri broj stavki kartice
		case integ1->kartcnt <> nKartCnt
			AADD(aErrCritical, {cIdRoba, "Greska u broju stavki kartice: (TOPSP)=" + ALLTRIM(STR(integ1->kartcnt)) + ", (TOPSK)=" + ALLTRIM(STR(nKartCnt)) })
	
		// provjeri broj istih artikala u sifrarniku artikala
		case integ1->sifrobacnt <> nRobaCnt
			AADD(aErrWarrning, {cIdRoba, "Postoje duple sifre: (TOPSP)=" + ALLTRIM(STR(integ1->sifrobacnt)) + ", (TOPSK)=" + ALLTRIM(STR(nRobaCnt)) })
		// provjeri cijenu artikla
		case integ1->robacijena <> nCijena
			AADD(aErrCritical, {cIdRoba, "Greska u cijeni artikla: (TOPSP)=" + ALLTRIM(STR(integ1->robacijena)) + ", (TOPSK)=" + ALLTRIM(STR(nCijena)) })
	
	endcase
	
	select pos
enddo

BoxC()
MsgC()

if (LEN(aErrCritical) + LEN(aErrNormal) + LEN(aErrWarrning)) == 0
	MsgBeep("Integritet podataka ok")
	return
endif

START PRINT CRET

// provjeri kriticne greske
nLen := LEN(aErrCritical)
if nLen > 0
	? ALLTRIM(STR(nLen)) + " critical errors:"
	? "---------------------------------------------------"
	? "Id artikal  * Opis greske "
	? "---------------------------------------------------"
	for i:=1 to nLen
		? aErrCritical[i, 1] + " " + aErrCritical[i, 2]
	next
	?
endif

nLen := LEN(aErrNormal)
if nLen > 0
	? ALLTRIM(STR(nLen)) + " normal errors:"
	? "---------------------------------------------------"
	? "Id artikal  * Opis greske "
	? "---------------------------------------------------"
	for i:=1 to nLen
		? aErrNormal[i, 1] + " " + aErrNormal[i, 2]
	next
	?
endif

nLen := LEN(aErrWarrning)
if nLen > 0
	? ALLTRIM(STR(nLen)) + " warrnings:"
	? "---------------------------------------------------"
	? "Id artikal  * Opis greske "
	? "---------------------------------------------------"
	for i:=1 to nLen
		? aErrWarrning[i, 1] + " " + aErrWarrning[i, 2]
	next
	?
endif

FF
END PRINT


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
function RunChk1(nTest)
*{
O_DINTEG1
set order to tag "1"
go bottom

// ako je proslo 10 dana od proteklog testiranja pokreni test
dChkDate := DATE()

if ( field->datum == dChkDate )
	nTest := field->id
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


/*! \fn AddDInteg1(nIntegID)
 *  \brief Dodaj zapis u tabelu DINTEG1.DBF
 *  \param nIntegID - id u tabeli DINTEG1
 */
function AddDInteg1(nIntegID)
*{
O_DINTEG1
select dinteg1
append blank
Sql_Append()

SmReplace("datum", DATE())
SmReplace("vrijeme", TIME())
SmReplace("id", nIntegId)

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
