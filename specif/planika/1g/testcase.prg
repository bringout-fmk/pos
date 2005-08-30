#include "\dev\fmk\pos\pos.ch"
#include "\dev\fmk\af\cl-af\message\msg.ch"


/*! \fn PlFlexTCases()
 *  \brief Centralna funkcija za poziv test case-ova planikaflex
 */
function PlFlexTCases()
*{

cTc1:="D"
cTc2:="D"
cTc3:="D"
cTc4:="D"
cTc5:="D"
cTc6:="D"
cTc7:="D"
cTc8:="D"
cTc9:="D"
cTc10:="D"
private cPatch  // varijabla koja odredjuje da li ce se automatski vrsiti fix procedure
// po def.je N
cPatch:="N"

private nSParTOid

Box(,12, 70)
	@ 1+m_x, 2+m_y SAY "TC-1: osnovni podaci" GET cTc1 VALID cTc1$"DN" PICT "@!"
	@ 2+m_x, 2+m_y SAY "TC-2: broj zapisa u tabelama" GET cTc2 VALID cTc2$"DN" PICT "@!"
	@ 3+m_x, 2+m_y SAY "TC-3: najmanji OID u tabelama" GET cTc3 VALID cTc3$"DN" PICT "@!"
	@ 4+m_x, 2+m_y SAY "TC-4: najveci OID u tabelama" GET cTc4 VALID cTc4$"DN" PICT "@!"
	@ 5+m_x, 2+m_y SAY "TC-5: dupli OID-i u tabelama" GET cTc5 VALID cTc5$"DN" PICT "@!"
	@ 6+m_x, 2+m_y SAY "TC-6: broj OID-a sa prefixima" GET cTc6 VALID cTc6$"DN" PICT "@!"
	@ 7+m_x, 2+m_y SAY "TC-7: prazni zapisi u tabelama" GET cTc7 VALID cTc7$"DN" PICT "@!"
	@ 8+m_x, 2+m_y SAY "TC-8: nedefinisani OID-i u tabelama" GET cTc8 VALID cTc8$"DN" PICT "@!"
	@ 9+m_x, 2+m_y SAY "TC-9: suma OID-a u tabelama" GET cTc9 VALID cTc9$"DN" PICT "@!"
	@ 10+m_x, 2+m_y SAY "TC-10: dupli zapisi tabela prema trazenom polju" GET cTc10 VALID cTc10$"DN" PICT "@!"
	@ 11+m_x, 2+m_y SAY "-------------------------------------------------"
	@ 12+m_x, 2+m_y SAY "Nakon testa pokrenuti FIX proceduru ?(D/N)" GET cPatch VALID cPatch$"DN" PICT "@!"
	read
BoxC()

if LastKey()==K_ESC
	return
endif

MsgBeep("Vrsim stampu testova...")

MsgO("Kreiram indexe po polju OID...")

// kreiram indexe po polju _oid_
O_DOKS
CREATE_INDEX("OID","_oid_",KUMPATH+"DOKS")
O_POS
CREATE_INDEX("OID","_oid_",KUMPATH+"POS")
O_ROBA
CREATE_INDEX("OID","_oid_",SIFPATH+"ROBA")
O_TARIFA
CREATE_INDEX("OID","_oid_",SIFPATH+"TARIFA")
O_PROMVP
CREATE_INDEX("OID","_oid_",KUMPATH+"PROMVP")
O_MESSAGE
CREATE_INDEX("OID","_oid_",KUMPATH+"MESSAGE")

MsgC()

nTOidTek := 0
nTSite := 0

START PRINT CRET

? "------------------------------------"
? "TOPS: TESTCASE-S", DTOC(DATE())
? "------------------------------------"
if (cTc1=="D")
	// TC-1: Vrati tekuci oid
	TGetCurrOid( @nTOidTek, @nTSite )
endif
if (cTc2=="D")
	// TC-2: Vrati broj zapisa tabela ROBA, TARIFA, DOKS, POS
	TGetTblRecNo()
endif
if (cTc3=="D")
	// TC-3: Vrati najmanji oid za tabele ROBA, TARIFA, DOKS, POS
	TGetMinOid( nTSite )
endif
if (cTc4=="D")
	// TC-4: Vrati najveci oid za tabele ROBA, TARIFA, DOKS, POS
	TGetMaxOid( nTSite )
endif
if (cTc5=="D")
	// TC-5: Da li postoji u tabelama duplih oid-a
	TChkDblOid()
endif
if (cTc6=="D")
	// TC-6: Koliko ima oida sa prodavnickim prefixom a koliko sa knj.prefixom
	TChkOidPrefix( nTSite )
endif
if (cTc7=="D")
	// TC-7: Broj praznih zapisa u tabelama
	TGetEmptyRecords()
endif
if (cTc8=="D")
	// TC-8: Provjeri koliko postoji oid-a uljeza u tabelama
	TGetOtherOid( nTSite )
endif
if (cTc9=="D")
	// TC-9: Provjeri sumu oid-a u tabelama
	TGetSumOid( nTSite )
endif
if (cTc10=="D")
	// TC-10: Provjeri duple sifre roba
	TChkFldDbl()
endif

?
?
?

END PRINT
FF

return
*}


/*! \fn TGetCurrOid()
 *  \brief Vraca broj tekuceg oid-a
 */
function TGetCurrOid( nTOidTek, nTSite )
*{
MsgO("TC-1: Izvlacim osnovne podatke iz baze...")
SELECT (240)
USE (KUMPATH + SLASH + "SQL" + SLASH + "SQLPAR")

nTOidTek := sqlpar->_oid_tek
nTSite := sqlpar->_site_
nTPOid := sqlpar->_oid_poc
nTKOid := sqlpar->_oid_kraj

? "---------------------------------"
? "TC-1 : OID opci podaci"
? "---------------------------------"
? "Site        :", nTSite
? "Tekuci oid  :", nTOidTek
? "Pocetni oid :", nTPOid
? "Krajnji oid :", nTKOid
?

nSParTOid:=nTOidTek

MsgC()

return 
*}

/*! \fn TGetMinOid()
 *  \brief Vraca najmanji broj oida
 */
function TGetMinOid( nTSite )
*{
MsgO("TC-3: Provjeri najmanji broj OID-a u tabelama...")

cOpis1:="PROD->"
cOpis2:="KNJIG->"
nTS2:=0
if (nTSite < 50)
	cOpis1:="KNJIG->"
	cOpis2:="PROD->"
	nTS2:=nTSite + 40
else
	nTS2:=nTSite - 40
endif

// istampaj rezultat
?
? "---------------------------------"
? "TC-3: najmanji OID"
? "---------------------------------"
O_POS
? "POS    : " + cOpis1, TMinOid("POS", nTSite), cOpis2, TMinOid("POS", nTS2)
O_DOKS
? "DOKS   : " + cOpis1, TMinOid("DOKS", nTSite), cOpis2, TMinOid("DOKS", nTS2)
O_ROBA
? "ROBA   : " + cOpis1, TMinOid("ROBA", nTSite), cOpis2, TMinOid("ROBA", nTS2)
O_TARIFA
? "TARIFA : " + cOpis1, TMinOid("TARIFA", nTSite), cOpis2, TMinOid("TARIFA", nTS2)
O_PROMVP
? "PROMVP : " + cOpis1, TMinOid("PROMVP", nTSite), cOpis2, TMinOid("PROMVP", nTS2)
O_MESSAGE
? "MESSAGE: " + cOpis1, TMinOid("MESSAGE", nTSite), cOpis2, TMinOid("MESSAGE", nTS2)

?

MsgC()

return
*}

/*! \fn TGetMaxOid()
 *  \brief Vraca najveci broj oida
 */
function TGetMaxOid( nTSite )
*{
MsgO("TC-4: Provjeri najveci broj OID-a u tabelama...")

cOpis1:="PROD->"
cOpis2:="KNJIG->"
nTS2:=0
if (nTSite < 50)
	cOpis1:="KNJIG->"
	cOpis2:="PROD->"
	nTS2:=nTSite + 40
else
	nTS2:=nTSite - 40
endif

// istampaj rezultat
?
? "---------------------------------"
? "TC-4: najveci OID"
? "---------------------------------"
O_POS
? "POS    : " + cOpis1, TMaxOid("POS", nTSite), cOpis2, TMaxOid("POS", nTS2)
O_DOKS
? "DOKS   : " + cOpis1, TMaxOid("DOKS", nTSite), cOpis2, TMaxOid("DOKS", nTS2)
O_ROBA
? "ROBA   : " + cOpis1, TMaxOid("ROBA", nTSite), cOpis2, TMaxOid("ROBA", nTS2)
O_TARIFA
? "TARIFA : " + cOpis1, TMaxOid("TARIFA", nTSite), cOpis2, TMaxOid("TARIFA", nTS2)
O_PROMVP
? "PROMVP : " + cOpis1, TMaxOid("PROMVP", nTSite), cOpis2, TMaxOid("PROMVP", nTS2)
O_MESSAGE
? "MESSAGE: " + cOpis1, TMaxOid("MESSAGE", nTSite), cOpis2, TMaxOid("MESSAGE", nTS2)

?

MsgC()

return
*}

/*! \fn TMinOid( cTbl, nSte )
 *  \brief Vraca broj minimalnog oid-a u tabeli
 *  \param cTbl - tabela, npr. "POS"
 *  \param nSte - site, npr 50
 */
static function TMinOid( cTbl, nSte )
*{
nMinOid := 0
cSte:=ALLTRIM(STR(nSte))
select &cTbl
set order to tag "OID"
go top
do while !EOF() 
	if SUBSTR(STR(field->_oid_), 1, 2) <> cSte
		skip
		loop
	endif
	nMinOid := field->_oid_
	exit
enddo
set order to

return nMinOid
*}


/*! \fn TMaxOid(cTbl, nSte)
 *  \brief Vraca maximalni broj oid-a
 *  \param cTbl - tabela
 *  \param nSte - site
 */
static function TMaxOid( cTbl, nSte )
*{
nMaxOid := 0
cSte:=ALLTRIM(STR(nSte))
select &cTbl
set order to tag "OID"
go bottom
do while !BOF() 
	if SUBSTR(STR(field->_oid_), 1, 2) <> cSte
		skip -1
		loop
	endif
	nMaxOid := field->_oid_
	exit
enddo
set order to

return nMaxOid
*}


/*! \fn TGetTblRecNo()
 *  \brief Vraca broj zapisa tabela
 */
function TGetTblRecno()
*{
MsgO("Provjeravam broj zapisa u tabelama...")

O_DOKS
O_POS
O_ROBA
O_TARIFA
O_MESSAGE
O_PROMVP

// definisem pom varijable

nPosRc:=0
nDoksRc:=0
nRobaRc:=0
nTarRc:=0
nPVpRc:=0
nMsgRc:=0

// napuni varijable

select pos
nPosRc := RecCount()
select doks
nDoksRc := RecCount()
select roba
nRobaRc := RecCount()
select tarifa
nTarRc := RecCount()
select promvp
nPVpRc := RecCount()
select message
nMsgRc := RecCount()

? "-------------------------------"
? "TC-2: broj zapisa tabela"
? "-------------------------------"
? "POS     :", nPosRc
? "DOKS    :", nDoksRc
? "ROBA    :", nRobaRc
? "TARIFA  :", nTarRc
? "PROMVP  :", nPVpRc
? "MESSAGE :", nMsgRc
?

MsgC()
return
*}

/*! \fn TChkDblOid()
 *  \brief Provjera postojanja duplih oid-a
 */
function TChkDblOid()
*{
O_DOKS
O_POS
O_ROBA
O_TARIFA
O_PROMVP
O_MESSAGE

? "----------------------------------------"
? "TC-5: dupli OID-i"
? "----------------------------------------"

MsgO("TC-5: Provjeravam duple OID-e: POS")
? "POS    :"
TDblOid( "POS" )
MsgC()
MsgO("TC-5: Provjeravam duple OID-e: DOKS")
? "DOKS   :"
TDblOid( "DOKS" )

MsgC()
MsgO("TC-5: Provjeravam duple OID-e: ROBA")
? "ROBA   :"
TDblOid( "ROBA" )

MsgC()
MsgO("TC-5: Provjeravam duple OID-e: TARIFA")
? "TARIFA :"
TDblOid( "TARIFA" )

MsgC()
MsgO("TC-5: Provjeravam duple OID-e: PROMVP")
? "PROMVP :"
TDblOid( "PROMVP" )

MsgC()
MsgO("TC-5: Provjeravam duple OID-e: MESSAGE")
? "MESSAGE:"
TDblOid( "MESSAGE" )

MsgC()
?

return
*}

/*! \fn TChkOidPrefix()
 *  \brief Provjera prefixa oid-a koliko ima prefixa prodavnice, koliko ima prefixa knjigovodstva
 */
function TChkOidPrefix( nTSite )
*{
O_POS
O_DOKS
O_ROBA
O_TARIFA
O_PROMVP
O_MESSAGE

cOpis1:="PROD."
cOpis2:="KNJIG."
// ako je site < 50 onda je rijec o knjigovodstvu
if (nTSite < 50 )
	cOpis1:="KNJIG."
	cOpis2:="PROD."
endif
nPfx1 := 0
nPfx2 := 0

? "-------------------------------------"
? "TC-6: broj OID-a " + cOpis1 + ", " + cOpis2
? "-------------------------------------"

MsgO("TC-6: Provjeravam prefix-e OID-a: POS")
TOidPrefix( "POS", nTSite, @nPfx1, @nPfx2 )
? "POS    : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2
MsgC()

MsgO("TC-6: Provjeravam prefix-e OID-a: DOKS")
TOidPrefix( "DOKS", nTSite, @nPfx1, @nPfx2 )
? "DOKS   : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgC()
MsgO("TC-6: Provjeravam prefix-e OID-a: ROBA")
TOidPrefix( "ROBA", nTSite, @nPfx1, @nPfx2 )
? "ROBA   : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgC()
MsgO("TC-6: Provjeravam prefix-e OID-a: TARIFA")
TOidPrefix( "TARIFA", nTSite, @nPfx1, @nPfx2 )
? "TARIFA : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgC()
MsgO("TC-6: Provjeravam prefix-e OID-a: PROMVP")
TOidPrefix( "PROMVP", nTSite, @nPfx1, @nPfx2 )
? "PROMVP : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgC()
MsgO("TC-6: Provjeravam prefix-e OID-a: MESSAGE")
TOidPrefix( "MESSAGE", nTSite, @nPfx1, @nPfx2 )
? "MESSAGE: " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgC()

?

return
*}

/*! \fn TOidPrefix( cTbl, nTSite, nPfx1, nPfx2 )
 *  \brief Provjerava koliko ima prefixa OID-a, npr 10 a koliko 50
 *  \param cTbl - tabela, npr "POS"
 *  \param nTSite - site kase
 *  \param nPfx1 - prefix prema site-u, npr 50
 *  \param nPfx2 - prefix druge strane, npr 10
 */
static function TOidPrefix( cTbl, nTSite, nPfx1, nPfx2 )
*{
select &cTbl
set order to tag "OID"
go top

nPfx1:=0
nPfx2:=0
nCnt1:=0
nCnt2:=0

cSite := ALLTRIM(STR(nTSite))
cS2 := ""
// cS2 = vraca vrijednost oid-a druge strane
if (nTSite < 50 )
	cS2 := ALLTRIM(STR( nTSite + 40 ))
else
	cS2 := ALLTRIM(STR( nTSite - 40 ))
endif

do while !EOF()
	// provjeri prvo bazni oid
	if ( SUBSTR(STR(field->_oid_), 1, 2 ) == cSite )
		++ nCnt1 
	// provjeri zatim pomocni oid
	elseif ( SUBSTR(STR(field->_oid_), 1, 2 ) == cS2 )
		++ nCnt2
	else
		//
	endif
	skip
enddo

nPfx1 := nCnt1
nPfx2 := nCnt2

return
*}


/*! \fn TDblOid( cTbl )
 *  \brief Provjerava da li postoji dupli oid u tabeli cTbl
 *  \param cTbl - tabela, npr "POS"
 */
static function TDblOid( cTbl )
*{
local lFix:=.f.
select &cTbl
set order to tag "OID"
go top

nCurrOid:=0
nPomCnt:=0

nPrevOid := field->_oid_
nCurrOid := 0

if (cPatch=="D")
	lFix:=.t.
endif

do while !EOF()
	skip
	nCurrOid := field->_oid_
	if ( nCurrOid == nPrevOid )	
		++ nPomCnt
		? SPACE(10), field->_oid_
		if lFix .and. Pitanje(,"Izbrisati dupli zapis " + ALLTRIM(STR(field->_oid_)), "D") == "D" 
			delete
		endif
	endif
	nPrevOid := nCurrOid
enddo

if (nPomCnt == 0)
	?? "Nema duplih OID-a!"
endif

return
*}

/*! \fn TGetEmptyRecords()
 *  \brief Centralni poziv provjere praznih zapisa
 */
function TGetEmptyRecords()
*{

? "--------------------------------------------"
? "TC-7: broj praznih zapisa "
? "--------------------------------------------"
? "POS    : "
?? TEmptyR("POS", "idpos")
? "DOKS   : "
?? TEmptyR("DOKS", "idpos")
? "ROBA   : "
?? TEmptyR("ROBA", "id")
? "TARIFA : "
?? TEmptyR("TARIFA", "id")
? "PROMVP : "
?? TEmptyR("PROMVP", "pm")
? "MESSAGE: "
?? TEmptyR("MESSAGE", "fromhost")
?
?
return 
*}


/*! \fn TEmptyR( cTbl, cSrcField )
 *  \brief Provjerava koliko ima praznih zapisa u tabeli prema pretrazi cSrcField
 *  \param cTbl - tabela, npr: "POS"
 *  \param cSrcField - search field, npr "idpos"
 */
static function TEmptyR( cTbl, cSrcField )
*{
MsgO("TC-7: Trazim prazne zapise u tabeli " + cTbl)
select &cTbl
go top
nRet:=0
do while !EOF()
	if field->&cSrcField == SPACE( LEN(field->&cSrcField) )
		if (cPatch=="D" .and. Pitanje(,"Izbrisati prazni zapis iz tabele", "D") == "D" )
			delete
		endif
		++ nRet
	endif
	skip
enddo

MsgC()

return nRet
*}



/*! \fn TGetOthOids()
 *  \brief Centralni poziv provjere uljeza medju oid-ima
 */
function TGetOtherOid( nTSite )
*{


? "--------------------------------------------"
? "TC-8: nedefinisani OID-i"
? "--------------------------------------------"

MsgO("TC-8: provjeravam koenz.OID-a, tabela POS")
? "POS    : "
TOthOid("POS", nTSite )
MsgC()
MsgO("TC-8: provjeravam koenz.OID-a, tabela DOKS")
? "DOKS   : "
TOthOid("DOKS", nTSite )
MsgC()
MsgO("TC-8: provjeravam koenz.OID-a, tabela ROBA")
? "ROBA   : "
TOthOid("ROBA", nTSite )
MsgC()
MsgO("TC-8: provjeravam koenz.OID-a, tabela TARIFA")
? "TARIFA : "
TOthOid("TARIFA", nTSite )
MsgC()
MsgO("TC-8: provjeravam koenz.OID-a, tabela PROMVP")
? "PROMVP : "
TOthOid("PROMVP", nTSite )
MsgC()
MsgO("TC-8: provjeravam koenz.OID-a, tabela MESSAGE")
? "MESSAGE: "
TOthOid("MESSAGE", nTSite )

?
?

MsgC()

return 
*}


/*! \fn TOthOid( cTbl, nTSite )
 *  \brief Provjerava koliko ima uljeza medju oidima 
 *  \param cTbl - tabela, npr "POS"
 *  \param nTSite - site kase
 */
static function TOthOid( cTbl, nTSite )
*{
local lFix:=.f.
select &cTbl
set order to tag "OID"
go top

nCnt1:=0

if (cPatch=="D")
	lFix:=.t.
endif

cSite := ALLTRIM(STR(nTSite))
cS2 := ""
// cS2 = vraca vrijednost oid-a druge strane
if (nTSite < 50 )
	cS2 := ALLTRIM(STR( nTSite + 40 ))
else
	cS2 := ALLTRIM(STR( nTSite - 40 ))
endif

do while !EOF()
	// provjeri prvo bazni oid
	if ( SUBSTR(STR(field->_oid_), 1, 2 ) == cSite )
		// 
	// provjeri zatim pomocni oid
	elseif ( SUBSTR(STR(field->_oid_), 1, 2 ) == cS2 )
		//
	else
		++ nCnt1
		? SPACE(10), field->_oid_
		if (lFix .and. Pitanje(,"Izbrisati zapis " + ALLTRIM(STR(field->_oid_)), "D") == "D" )
			delete
		endif
	endif
	skip
enddo

if ( nCnt1 == 0 )
	?? " Nema drugih OID-a!"
endif

return
*}


/*! \fn TGetSumOid( nTSite )
 *  \brief Vrati zbir OID-a u tabelama
 *  \param nTSite - site, npr "50"
 */
function TGetSumOid( nTSite )
*{

MsgO("TC-9: provjeravam sumu OID-a...")

? "--------------------------------------------"
? "TC-9: suma OID-a"
? "--------------------------------------------"
? "POS    : "
?? TSumOid("POS", nTSite )
? "DOKS   : "
?? TSumOid("DOKS", nTSite )
? "ROBA   : "
?? TSumOid("ROBA", nTSite )
? "TARIFA : "
?? TSumOid("TARIFA", nTSite )
? "PROMVP : "
?? TSumOid("PROMVP", nTSite )
? "MESSAGE: "
?? TSumOid("MESSAGE", nTSite )
?
?

MsgC()

return
*}

/*! \fn TSumOid( cTbl, nTSite )
 *  \brief Provjerava sumu svih OID-a u tabelama 
 *  \param cTbl - tabela, npr "POS"
 *  \param nTSite - site kase
 */
static function TSumOid( cTbl, nTSite )
*{
select &cTbl
set order to tag "OID"
go top

nSum:=0

cSite := ALLTRIM(STR(nTSite))
cS2 := ""
// cS2 = vraca vrijednost oid-a druge strane
if (nTSite < 50 )
	cS2 := ALLTRIM(STR( nTSite + 40 ))
else
	cS2 := ALLTRIM(STR( nTSite - 40 ))
endif

do while !EOF()
	nSum += field->_oid_
	skip
enddo

return nSum
*}


/*! \fn TFldDbl( cTbl, cField )
 *  \brief Provjerava da li postoji dupli zapisi u tabeli cTbl po polju cField
 *  \param cTbl - tabela, npr "POS"
 *  \param cField - polje tabele
 */
static function TFldDbl( cTbl, cField )
*{
local lFix:=.f.
select &cTbl
set order to tag &cField
go top

nCurrOid:=0
nPomCnt:=0

nPrevOid := field->&cField
nCurrOid := 0

if (cPatch=="D")
	lFix:=.t.
endif

do while !EOF()
	skip
	nCurrOid := field->&cField
	if ( nCurrOid == nPrevOid )	
		++ nPomCnt
		? SPACE(10), field->&cField
		if lFix .and. Pitanje(,"Izbrisati dupli zapis " + ALLTRIM(STR(field->&cField)), "D") == "D" 
			delete
		endif
	endif
	nPrevOid := nCurrOid
enddo

if (nPomCnt == 0)
	?? "Nema duplih stavki"
endif

return
*}

/*! \fn TChkRobaDbl()
 *  \brief Provjera postojanja duplih stavki u tabelama
 */
function TChkFldDbl()
*{
O_ROBA
O_TARIFA
? "----------------------------------------"
? "TC-10: duple stavke tabela po polju"
? "----------------------------------------"

MsgO("TC-10: Provjeravam duple OID-e: ROBA")
? "ROBA    :"
TFldDbl( "ROBA", "ID" )
MsgC()

MsgO("TC-10: Provjeravam duple OID-e: TARIFA")
? "TARIFA  :"
TFldDbl( "TARIFA", "ID" )
MsgC()

?

return
*}


