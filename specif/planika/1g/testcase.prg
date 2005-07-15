#include "\dev\fmk\pos\pos.ch"


/*! \fn PlFlexTCases()
 *  \brief Centralna funkcija za poziv test case-ova planikaflex
 */
function PlFlexTCases()
*{

MsgBeep("Vrsim stampu testova...")

nTOidTek := 0
nTSite := 0

START PRINT CRET

? "------------------------------------"
? "TOPS: TESTCASE-S", DTOC(DATE())
? "------------------------------------"
// TC-1: Vrati tekuci oid
TGetCurrOid( @nTOidTek, @nTSite )

// TC-2: Vrati najmanji oid za tabele ROBA, TARIFA, DOKS, POS
TGetMinOid( nTSite )

// TC-3: Vrati najveci oid za tabele ROBA, TARIFA, DOKS, POS
TGetMaxOid( nTSite )

// TC-4: Vrati broj zapisa tabela ROBA, TARIFA, DOKS, POS
TGetTblRecNo()

// TC-5: Da li postoji u tabelama duplih oid-a
TChkDblOid()

// TC-6: Koliko ima oida sa prodavnickim prefixom a koliko sa knj.prefixom
TChkOidPrefix( nTSite )

// TC-7: Broj praznih zapisa u tabelama
TGetEmptyRecords()

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
MsgO("TC-1: Izvlacim tekuci OID iz baze...")
SELECT (240)
USE (KUMPATH + SLASH + "SQL" + SLASH + "SQLPAR")
nTOidTek := sqlpar->_oid_tek
nTSite := sqlpar->_site_
? "TC-1 rezultat:"
? "-----------------------------------------"
? "Site                      :", nTSite
? "Tekuci oid u tabeli sqlpar:", nTOidTek
?
MsgC()
return 
*}

/*! \fn TGetMinOid()
 *  \brief Vraca najmanji broj oida
 */
function TGetMinOid( nTSite )
*{
MsgO("TC-2: Provjeri najmanji broj OID-a u tabelama...")

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

MsgC()

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
? "TC-2 rezultat:"
? "---------------------------------"
? "Najmanji broj OID-a u tabelama:"
? "---------------------------------"
O_POS
? "POS   : " + cOpis1, TMinOid("POS", nTSite), cOpis2, TMinOid("POS", nTS2)
O_DOKS
? "DOKS  : " + cOpis1, TMinOid("DOKS", nTSite), cOpis2, TMinOid("DOKS", nTS2)
O_ROBA
? "ROBA  : " + cOpis1, TMinOid("ROBA", nTSite), cOpis2, TMinOid("ROBA", nTS2)
O_TARIFA
? "TARIFA: " + cOpis1, TMinOid("TARIFA", nTSite), cOpis2, TMinOid("TARIFA", nTS2)
?

MsgC()

return
*}

/*! \fn TGetMaxOid()
 *  \brief Vraca najveci broj oida
 */
function TGetMaxOid( nTSite )
*{
MsgO("TC-3: Provjeri najveci broj OID-a u tabelama...")

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
? "TC-3 rezultat:"
? "---------------------------------"
? "Najveci broj OID-a u tabelama:   "
? "---------------------------------"
O_POS
? "POS   : " + cOpis1, TMaxOid("POS", nTSite), cOpis2, TMaxOid("POS", nTS2)
O_DOKS
? "DOKS  : " + cOpis1, TMaxOid("DOKS", nTSite), cOpis2, TMaxOid("DOKS", nTS2)
O_ROBA
? "ROBA  : " + cOpis1, TMaxOid("ROBA", nTSite), cOpis2, TMaxOid("ROBA", nTS2)
O_TARIFA
? "TARIFA: " + cOpis1, TMaxOid("TARIFA", nTSite), cOpis2, TMaxOid("TARIFA", nTS2)
?

MsgC()

return
*}

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

// definisem pom varijable

nPosRc:=0
nDoksRc:=0
nRobaRc:=0
nTarRc:=0

// napuni varijable

select pos
nPosRc := RecCount()
select doks
nDoksRc := RecCount()
select roba
nRobaRc := RecCount()
select tarifa
nTarRc := RecCount()

? "TC-4 rezultati:"
? "-------------------------------"
? "Broj zapisa u tabelama: "
? "-------------------------------"
? "POS      : ", nPosRc
? "DOKS     : ", nDoksRc
? "ROBA     : ", nRobaRc
? "TARIFA   : ", nTarRc
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

? "TC-5 rezultat:"
? "----------------------------------------"
? "Provjeravam postojanje duplih OID-a"
? "----------------------------------------"

MsgO("TC-5: Provjeravam duple OID-e: POS")
? "POS    :"
TDblOid( "POS" )

MsgO("TC-5: Provjeravam duple OID-e: DOKS")
? "DOKS   :"
TDblOid( "DOKS" )

MsgO("TC-5: Provjeravam duple OID-e: ROBA")
? "ROBA   :"
TDblOid( "ROBA" )

MsgO("TC-5: Provjeravam duple OID-e: TARIFA")
? "TARIFA :"
TDblOid( "TARIFA" )
?

MsgC()
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

cOpis1:="PROD."
cOpis2:="KNJIG."
// ako je site < 50 onda je rijec o knjigovodstvu
if (nTSite < 50 )
	cOpis1:="KNJIG."
	cOpis2:="PROD."
endif
nPfx1 := 0
nPfx2 := 0

? "TC-6 rezultati:"
? "-------------------------------------"
? "Broj oid-a " + cOpis1 + " , " + cOpis2
? "-------------------------------------"

MsgO("TC-6: Provjeravam prefix-e OID-a: POS")
TOidPrefix( "POS", nTSite, @nPfx1, @nPfx2 )
? "POS   : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgO("TC-6: Provjeravam prefix-e OID-a: DOKS")
TOidPrefix( "DOKS", nTSite, @nPfx1, @nPfx2 )
? "DOKS  : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgO("TC-6: Provjeravam prefix-e OID-a: ROBA")
TOidPrefix( "ROBA", nTSite, @nPfx1, @nPfx2 )
? "ROBA  : " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

MsgO("TC-6: Provjeravam prefix-e OID-a: TARIFA")
TOidPrefix( "TARIFA", nTSite, @nPfx1, @nPfx2 )
? "TARIFA: " + cOpis1 + "->", nPfx1, cOpis2 + "->", nPfx2

?

MsgC()
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
cSite := STR(nTSite)

do while !EOF()
	if ( SUBSTR(STR(field->_oid_), 1, 2 ) == cSite )
		++ nCnt1 
	else
		++ nCnt2
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
select &cTbl
set order to tag "OID"
go top

nCurrOid:=0
nPomCnt:=0

nPrevOid := field->_oid_
nCurrOid := 0

do while !EOF()
	skip
	nCurrOid := field->_oid_
	if ( nCurrOid == nPrevOid )	
		++ nPomCnt
		? SPACE(10), field->_oid_
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

? "TC-7 rezultat:"
? "--------------------------------------------"
? "Broj praznih zapisa u tabelama"
? "--------------------------------------------"
? "POS   : "
?? TEmptyR("POS", "idpos")
? "DOKS  : "
?? TEmptyR("DOKS", "idpos")
? "ROBA  : "
?? TEmptyR("ROBA", "id")
? "TARIFA: "
?? TEmptyR("TARIFA", "id")
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
		++ nRet
	endif
	skip
enddo

MsgC()

return nRet
*}

