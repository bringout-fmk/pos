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
? "TOPS: TESTCASE-S", DTOS(DATE())
? "------------------------------------"
// TC-1: Vrati tekuci oid
TGetCurrOid( @nTOidTek, @nTSite )

// TC-2: Vrati najmanji oid za tabele ROBA, TARIFA, DOKS, POS
TGetMinOid()

// TC-3: Vrati najveci oid za tabele ROBA, TARIFA, DOKS, POS
TGetMaxOid()

// TC-4: Vrati broj zapisa tabela ROBA, TARIFA, DOKS, POS
TGetTblRecNo()

// TC-5: Da li postoji u tabelama duplih oid-a
TChkDblOid()

// TC-6: Koliko ima oida sa prodavnickim prefixom a koliko sa knj.prefixom
TChkOidPrefix( nTSite )

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
function TGetMinOid()
*{
MsgO("TC-2: Provjeri najmanji broj OID-a u tabelama...")

// kreiram indexe po polju _oid_
O_DOKS
CREATE_INDEX("OID","_oid_",KUMPATH+"DOKS")

O_POS
CREATE_INDEX("OID","_oid_",KUMPATH+"POS")

O_ROBA
CREATE_INDEX("OID","_oid_",SIFPATH+"ROBA")

O_TARIFA
CREATE_INDEX("OID","_oid_",SIFPATH+"TARIFA")

// definisi pom varijable

nPosOid := 0
nDoksOid := 0
nRobaOid := 0
nTarOid := 0

// POS
O_POS
select pos
set order to tag "OID"
go top
do while !EOF() 
	if (STR(field->_oid_) == "" )
		skip
		loop
	endif
	nPosOid := field->_oid_ 
	exit
enddo
set order to

// DOKS
O_DOKS
select doks
set order to tag "OID"
go top
do while !EOF() 
	if (STR(field->_oid_) == "" )
		skip
		loop
	endif
	nDoksOid := field->_oid_
	exit
enddo
set order to

// ROBA
O_ROBA
select roba
set order to tag "OID"
go top
do while !EOF()
	if ( STR(field->_oid_) == "" )
		skip
		loop
	endif
	nRobaOid := field->_oid_
	exit
enddo
set order to

// TARIFA
O_TARIFA
select tarifa
set order to tag "OID"
go top
do while !EOF() 
	if ( STR(field->_oid_) == "" )
		skip
		loop
	endif
	nTarOid := field->_oid_
	exit
enddo
set order to

// istampaj rezultat
?
? "TC-2 rezultat:"
? "---------------------------------"
? "Najmanji broj OID-a u tabelama:"
? "---------------------------------"
? "POS     : ", nPosOid
? "DOKS    : ", nDoksOid
? "ROBA    : ", nRobaOid
? "TARIFA  : ", nTarOid
?

MsgC()

return
*}

/*! \fn TGetMaxOid()
 *  \brief Vraca najveci broj oida
 */
function TGetMaxOid()
*{
MsgO("TC-3: Provjeri najveci broj OID-a u tabelama...")

O_DOKS
O_POS
O_ROBA
O_TARIFA

// definisi pom varijable
nPosOid := 0
nDoksOid := 0
nRobaOid := 0
nTarOid := 0

// POS
select pos
set order to tag "OID"
go bottom
do while !BOF() 
	if ( STR(field->_oid_) == "" )
		skip -1
		loop
	endif
	nPosOid := field->_oid_ 
	exit
enddo
set order to

// DOKS
select doks
set order to tag "OID"
go bottom
do while !BOF()
	if ( STR(field->_oid_) == "" )
		skip -1
		loop
	endif
	nDoksOid := field->_oid_
	exit
enddo
set order to

// ROBA
select roba
set order to tag "OID"
go bottom
do while !BOF()
	if ( STR(field->_oid_) == "" )
		skip -1
		loop
	endif
	nRobaOid := field->_oid_
	exit
enddo
set order to

// TARIFA
select tarifa
set order to tag "OID"
go bottom
do while !BOF() 
	if ( STR(field->_oid_) == "" )
		skip -1
		loop
	endif
	nTarOid := field->_oid_
	exit
enddo
set order to

// istampaj rezultat
?
? "TC-3 rezultat:"
? "---------------------------------"
? "Najveci broj OID-a u tabelama:   "
? "---------------------------------"
? "POS     : ", nPosOid
? "DOKS    : ", nDoksOid
? "ROBA    : ", nRobaOid
? "TARIFA  : ", nTarOid
?

MsgC()

return
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
MsgO("TC-5: Provjeravam duple OID-e...")
O_DOKS
O_POS
O_ROBA
O_TARIFA

? "TC-5 rezultat:"
? "----------------------------------------"
? "Provjeravam postojanje duplih OID-a"
? "----------------------------------------"

? "POS    :", TDblOid( "POS" )
? "DOKS   :", TDblOid( "DOKS" )
? "ROBA   :", TDblOid( "ROBA" )
? "TARIFA :", TDblOid( "TARIFA" )
?

MsgC()
return
*}

/*! \fn TChkOidPrefix()
 *  \brief Provjera prefixa oid-a koliko ima prefixa prodavnice, koliko ima prefixa knjigovodstva
 */
function TChkOidPrefix( nTSite )
*{
MsgO("TC-6: Provjeravam prefix-e OID-a...")

O_POS
O_DOKS
O_ROBA
O_TARIFA

nPfx1 := 0
nPfx2 := 0

? "TC-6 rezultati:"
? "-------------------------------------"
? "Broj oid-a glavni, pomocni"
? "-------------------------------------"

TOidPrefix( "POS", nTSite, @nPfx1, @nPfx2 )
? "POS   : glavni->", nPfx1, "pomocni->", nPfx2
TOidPrefix( "DOKS", nTSite, @nPfx1, @nPfx2 )
? "DOKS  : glavni->", nPfx1, "pomocni->", nPfx2
TOidPrefix( "ROBA", nTSite, @nPfx1, @nPfx2 )
? "ROBA  : glavni->", nPfx1, "pomocni->", nPfx2
TOidPrefix( "TARIFA", nTSite, @nPfx1, @nPfx2 )
? "TARIFA: glavni->", nPfx1, "pomocni->", nPfx2
?
MsgC()
return
*}


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



static function TDblOid( cTbl )
*{
select &cTbl
set order to tag "OID"
go top

nCurrOid:=0
nTmpCnt:=0
nPomCnt:=0

do while !EOF()
	nCurrOid := field->_oid_
	nCurrRec := RecNo()

	COUNT TO nTmpCnt FOR field->_oid_ = nCurrOid
	
	/*
	cFilter:="_oid_="+STR(nCurrOid)
	set filter to &cFilter
	go top
	nCurrTot := RecCount()
	if (nCurrTot > 1)
		++ nPomCnt
		? SPACE(10), field->_oid_	
	endif
	set filter to
	set order to tag "OID"
	*/
	
	if (nTmpCnt > 1)	
		++ nPomCnt
		? SPACE(10), field->_oid_
	endif
	
	go (nCurrRec)
	skip
enddo

if (nPomCnt == 0)
	?? "Nema duplih OID-a!"
endif

return
*}
