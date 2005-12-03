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

Box(,3,65)

@ 1+m_x, 2+m_y SAY "Vrsim obradu stanja artikla"

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
		
		++ nKartCnt
		
		nUkKartCnt += nKartCnt
		nUkKStanje += nKStanje
		//nUkFStanje += nFStanje
		
		skip
	enddo
	
	nUkCijena += nRCjen
	nUkRobaCnt += nRobaCnt
	nFStanje := nKStanje * nRCjen
	nUkFStanje += nFStanje
	
	// upisi zapis u INTEG1.DBF
	AddInteg1(nNextID, cIdRoba, nOidRoba, cIdTarifa, nKStanje, nFStanje, nKartCnt, nRobaCnt, nRCjen)	
	
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
O_DOKS
O_POS
O_ERRORS
O_INTEG1

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

Box(,2,65)

@ 1+m_x, 2+m_y SAY "Vrsim provjeru integriteta podataka..."

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
		
		++ nKartCnt
		
		nUkKartCnt += nKartCnt
		nUkFStanje += nFStanje
		//nUkKStanje += nKStanje
		
		skip
	enddo

	nUkCijena += nRCjen
	nUkRobaCnt += nRobaCnt
	
	nFStanje := nKStanje * nRCjen
	nUkFStanje += nFStanje
	
	// zakaci se na kalk
	SELECT (F_KALK)
	USE ("k:\plflex\kalk\kum1\KALK")
	set order to tag "4"
	
	altd()
	hseek "50" + "13270  " + cIdRoba
	
	cKRoba:=kalk->idroba
	nKKStanje:=0
	nKFStanje:=0
	nKKartCnt:=0
	
	altd()	

	do while !EOF() .and. kalk->(idfirma+pkonto+idroba) == "50"+"13270  "+cKRoba
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
		case integ1->stanjek <> nKStanje
			AddToErrors("C", cIdRoba, "", "Greska u stanju artikla kolicinski: (TOPSP)=" + ALLTRIM(STR(integ1->stanjek)) + ", (TOPSK)=" + ALLTRIM(STR(nKStanje)) )

		// provjeri stanje artikla finansijski
		case integ1->stanjef <> nFStanje
			AddToErrors("C", cIdRoba, "", "Greska u stanju artikla finansijski: (TOPSP)=" + ALLTRIM(STR(integ1->stanjef)) + ", (TOPSK)=" + ALLTRIM(STR(nFStanje)) )
		
		// provjeri broj stavki kartice
		case integ1->kartcnt <> nKartCnt
			AddToErrors("C", cIdRoba, "", "Greska u broju stavki kartice: (TOPSP)=" + ALLTRIM(STR(integ1->kartcnt)) + ", (TOPSK)=" + ALLTRIM(STR(nKartCnt)) )
	
		// provjeri broj istih artikala u sifrarniku artikala
		case integ1->sifrobacnt > 1 .or. nRobaCnt > 1
			AddToErrors("W", cIdRoba, "", "Postoje duple sifre: (TOPSP)=" + ALLTRIM(STR(integ1->sifrobacnt)) + ", (TOPSK)=" + ALLTRIM(STR(nRobaCnt)) )
		// provjeri cijenu artikla
		case integ1->robacijena <> nRCjen
			AddToErrors("C", cIdRoba, "", "Greska u cijeni artikla: (TOPSP)=" + ALLTRIM(STR(integ1->robacijena)) + ", (TOPSK)=" + ALLTRIM(STR(nRCjen)) )
	
		// provjera kartica kalk
		case nKKartCnt <> nKartCnt
			AddToErrors("C", cIdRoba, "", "Greska u broju stavki kartice: (TOPSK)=" + ALLTRIM(STR(nKartCnt)) + ", (KALK)=" + ALLTRIM(STR(nKKartCnt)) )
		
		// provjera stanja artikla kalk-tops
		case nKKStanje <> nKStanje
			AddToErrors("C", cIdRoba, "", "Greska u kolicinskom stanju: (TOPSK)=" + ALLTRIM(STR(nKStanje)) + ", (KALK)=" + ALLTRIM(STR(nKKStanje)))
	
		// provjera stanja artikla kalk-tops
		case nKFStanje <> nFStanje
			AddToErrors("C", cIdRoba, "", "Greska u prodajnom stanju: (TOPSK)=" + ALLTRIM(STR(nFStanje)) + ", (KALK)=" + ALLTRIM(STR(nKFStanje)) )
			
	endcase
	
	select pos
enddo

BoxC()
MsgC()

select errors
set order to tag "1"
if RecCount() == 0
	MsgBeep("Integritet podataka ok")
	return
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
	++nCnt
	? STR(nCnt, 4) + " " + ALLTRIM(field->type), ALLTRIM(field->idroba), ALLTRIM(field->doks)
	? SPACE(5) + "Opis: " + ALLTRIM(field->opis)
	skip
enddo

?
?

FF
END PRINT


return
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
