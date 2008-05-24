#include "\dev\fmk\pos\pos.ch"


/*! \fn Fis_test_main()
 *  \brief glavna testna funkcija koja poziva sve test caseove
 */
function Fis_test_main()
*{

// test kreiranja fajla ARTIKLI.XML te provjera njegovog sadrzaja
TestRWArtikliXml()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

// test kreiranja fajla ARTRACUN.XML te provjera njegovog sadrzaja
TestRWArtRacunXml()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

// test kreiranja fajla PLACANJA.XML te provjera njegovog sadrzaja
TestRWPlacanjaXml()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

// test upisivanja i citanja kodova iz fajlova mainin.dat i mainout.dat
TestRWMainInOut()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

// test izdavanja racuna
TestFisRn1()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

TestFisRn2()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

TestFisRn3()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

TestFisRn4()
//Sleep(5)
?
? 'Press any key to continue...'
inkey(0)
clear screen

TestFisSviNaJedan()
?
? 'Press any key to continue...'
inkey(0)
clear screen

return
*}


/*! \fn TestRWArtikliXml()
 *  \brief testiranje ispravnosti kreiranog fajla ARTIKLI.XML
 */
function TestRWArtikliXml()
*{

? REPLICATE("-", 70)
? "Test: read/write ARTIKLI.XML "
? REPLICATE("-", 70)

aInput:={}
aOutPut:={}
cFilePath:=gFisCTTPath

// aInput: id artikla (oid), naziv, cijena, por.stopa, odjeljenje, jmj
AADD(aInput, {"100000000010", "EFFEGI 2340", 1000.00, "3", "1", "6"})
AADD(aInput, {"100000000251", "KLOMPE Z.BIJELE", 890.50, "3", "1", "6"})
AADD(aInput, {"100000003120", "ILLUMINATI 22/33", 2780.00, "3", "1", "6"})
AADD(aInput, {"100000006129", "PLACENTE 2350/80", 3020.40, "3", "1", "6"})

WrArtikliXML(aInput, cFilePath)
// iscitaj iz kreiranog artikli.xml podatke u aOutPut
aOutPut:=RdArtikliXml(cFilePath)

?
? "ARTIKLI.XML: uporedjujem duzinu matrice "


if LEN(aInput) <> LEN(aOutPut) 
	? "ARTIKLI.XML: Razlika u duzini matrice "
else
	?? " [OK] "
endif

?
? "ARTIKLI.XML: uporedjujem elemente matrice "

// pogledaj ima li gresaka u elementima matrice
nErr:=0
for nCnt:=1 to LEN(aInput)
	for nCnt2:=1 to 6
		if aInput[nCnt, nCnt2] <> aOutPut[nCnt, nCnt2]
			nErr ++ 
			? "ARTIKLI.XML: Razlika u elementu: " + ALLTRIM(STR(nCnt)) + "-" + ALLTRIM(STR(nCnt2))
		endif
	next
next
if (nErr == 0)
	?? " [OK] "
endif

?
? "ARTIKLI.XML: Test zavrsen ..."
?

return 
*}



/*! \fn TestRWArtRacunXml()
 *  \brief testiranje ispravnosti kreiranog fajla ARTRACUN.XML
 */
function TestRWArtRacunXml()
*{

? REPLICATE("-", 70)
? "Test: read/write ARTRACUN.XML"
? REPLICATE("-", 70)

aInput:={}
aOutPut:={}
cFilePath:=gFisCTTPath

// aInput: kolicina, id artikla (oid)
AADD(aInput, {1.00, "100000000010"})
AADD(aInput, {2.00, "100000000251"})
AADD(aInput, {10.00, "100000003120"})
AADD(aInput, {1.00, "100000006129"})

WrArtRacunXML(aInput, cFilePath)
// iscitaj iz kreiranog artracun.xml podatke u aOutPut
aOutPut:=RdArtRacunXml(cFilePath)

?
? "ARTRACUN.XML: uporedjujem duzine matrice "

if LEN(aInput) <> LEN(aOutPut) 
	? "ARTRACUN.XML: Razlika u duzini matrice"
else
	?? " [OK] "
endif

?
? "ARTRACUN.XML: uporedjujem elemente matrice ..."
nErr:=0
for nCnt:=1 to LEN(aInput)
	for nCnt2:=1 to 2
		if (aInput[nCnt, nCnt2] <> aOutPut[nCnt, nCnt2])
			nErr ++
			? "Razlika u elementu: " + STR(nCnt) + "-" + STR(nCnt2)
		endif
	next
next

if (nErr == 0)
	?? " [OK] "
endif

?
? "ARTRACUN.XML: test zavrsen ..."
?
?

return 
*}



/*! \fn TestRWPlacanjaXml()
 *  \brief testiranje ispravnosti kreiranog fajla PLACANJA.XML
 */
function TestRWPlacanjaXml()
*{

? REPLICATE("-", 70)
? "Test: read/write PLACANJA.XML"
? REPLICATE("-", 70)


aOutPut:={}
cFilePath:=gFisCTTPath

nIznos:=100.50

// prodji 3 kruga i upisi i provjeri podatke
// 1. iznos = 100.50 * 1, tip = 1
// 2. iznos = 100.50 * 2, tip = 2
// 3. iznos = 100.50 * 3, tip = 3

nErr:=0
for i:=1 to 3
	WrPlacanjaXML(nIznos * i, STR(i), cFilePath)
	// iscitaj iz kreiranog placanja.xml podatke u aOutPut
	aOutPut:=RdPlacanjaXml(cFilePath)

	// provjeri ima li podataka u PLACANJA.XML
	if LEN(aOutPut) == 0
		nErr ++
		? "Fajl PLACANJA.XML je prazan"
	endif

	if LEN(aOutPut) > 0
		// provjeri ispravnost podataka
		// iznos
		if nIznos * i <> aOutPut[1, 1]
   		nErr ++
			? "Neispravan parametar 1"
		endif
		// oznaku vrste placanja
		if alltrim(STR(i)) <> alltrim(aOutPut[1, 2])
   		nErr ++
			? "Neispravan parametar 2"
		endif
	endif
next

?
? "PLACANJA.XML: test zavrsen ..."
if (nErr == 0)
	?? " [OK] "
endif
?
?

return 
*}


/*! \fn TestRWMainInOut()
 *  \brief test upisivanja i iscitavanja komandi iz fajlova mainin.dat i mainout.dat 
 */
 
function TestRWMainInOut()
*{
? REPLICATE("-", 70)
? "Test RW mainin/out "
? REPLICATE("-", 70)

cCode:=""
cReadCode:=""
cFilePath:=gFisCTTPath

// test1: upisivanja i citanja kod-a iz fajla mainin.dat
// upisi kodove od -10 do 10

?
? "MAININ.DAT: Test WR kodova od 0 do 9 "

nCnt:=0

for i:=0 to 9
	cCode:=ALLTRIM(STR(i))
	WrMainInCode(cCode, cFilePath)
	cReadCode:=RdMainInCode(cFilePath)
	if alltrim(cReadCode) <> alltrim(cCode)
		nCnt ++
		? " Nepravilno upisan kod: " + ALLTRIM(STR(i))
	endif
next

if (nCnt == 0)
	?? " [OK]"
endif

// test2: upisivanja i citanja kod-a iz fajla mainout.dat
// upisi kodove od -10 do 10

?
? "MAINOUT.DAT: Test WR kodova od -5 do 5"

nCnt:=0

for i:=-5 to 5 
	cCode:=ALLTRIM(STR(i))
	WrMainOutCode(cFilePath, cCode)
	cReadCode:=RdMainOutCode(cFilePath)
	if alltrim(cReadCode) <> alltrim(cCode)
		nCnt ++
		?? " Nepravilno upisan kod: " + ALLTRIM(STR(i))
	endif
next

if (nCnt == 0)
	?? " [OK]"
endif

? 
? "Test zavrsen ..."

*}


/*! \fn TestFisRn1()
 *  \brief testira izdavanje racuna: dva artikla - gotovinsko placanje
 *  \todo Ovaj test ne valja ... ponovo razraditi ... sta mi uopste zelimo
 */
function TestFisRn1()
*{

? REPLICATE("-", 70)
? "Test: izdavanje racuna"
? REPLICATE("-", 70)

cFilePath:=gFisCTTPath

aArtikli:={}
AADD(aArtikli, {"100000000010", "EFFEGI 2340", 1000.00, "3", "1", "6"})
AADD(aArtikli, {"100000000251", "KLOMPE Z.BIJELE", 890.50, "3", "1", "6"})
AADD(aArtikli, {"100000003120", "ILLUMINATI 22/33", 2780.00, "3", "1", "6"})
AADD(aArtikli, {"100000006129", "PLACENTE 2350/80", 3020.40, "3", "1", "6"})
WrArtikliXml(aArtikli, cFilePath)
aOutPut:=RdArtikliXml(cFilePath)
if LEN(aArtikli) <> LEN(aOutPut)
	? "ARTIKLI.XML: nije dobro izgenerisan fajl"
endif

aArtRacun:={}
AADD(aArtRacun, {1.00, "100000000010"})
AADD(aArtRacun, {2.00, "100000006129"})
WrArtRacunXml(aArtRacun, cFilePath)
aOutPut:=RdArtRacunXml(cFilePath)
if LEN(aArtRacun) <> LEN(aOutPut)
	? "ARTRACUN.XML: nije dobro izgenerisan fajl"
endif

// izdajem gotovinski racun
nIznos:=7040.80
cTipPl:="1"
WrPlacanjaXml(nIznos, cTipPl, cFilePath)
aOutPut:=RdPlacanjaXml(cFilePath)
if (aOutPut[1, 1] <> nIznos .or. aOutPut[1, 2] <> cTipPl)
	? "PLACANJA.XML: nije dobro izgenerisan fajl"
endif

?
? "Test zadavanja komandi..."
?

bErr:=.f.

// komanda: ucitaj iz ARTIKLI.XML stavke u memoriju racunara
cCode:="1"
WrMainInCode(cCode, cFilePath)
cReadCode:=RdMainInCode(cFilePath)

if (cReadCode <> cCode)
	? "Nije dobro upisana komanda 1"
else
	? "Upisao komandu 1"
endif

? "Cekam mogucu gresku ..."
WrMainOutCode(cFilePath)
cOutCode:=RdMainOutCode(cFilePath)
if cOutCode <> "999" .or. cOutCode <> "0" 
	? "Postoji greska : " + cOutCode
	bErr:=.t.
else
	? "Greske nema ..."
endif

if bErr
	return
endif

// komanda: ucitaja iz ARTIKLI.XML stavke u FISSTA memoriju
cCode:="8"
WrMainInCode(cCode, cFilePath)
cReadCode:=RdMainInCode(cFilePath)

if (cReadCode <> cCode)
	? "Nije dobro upisana komanda 8"
else
	? "Upisao komandu 8"
endif

? "Cekam mogucu gresku ..."
WrMainOutCode(cFilePath)
cOutCode:=RdMainOutCode(cFilePath)
if cOutCode <> "999" .or. cOutCode <> "0" 
	? "Postoji greska : " + cOutCode
	bErr:=.t.
else
	? "Greske nema ..."
endif

if bErr
	return
endif


// komanda: ispisi racun i memorisi ga u FISSTA
cCode:="2"
WrMainInCode(cCode, cFilePath)
cReadCode:=RdMainInCode(cFilePath)

if (cReadCode <> cCode)
	? "Nije dobro upisana komanda 2"
else
	? "Upisao komandu 2"
endif

? "Cekam mogucu gresku ..."
WrMainOutCode(cFilePath)
cOutCode:=RdMainOutCode(cFilePath)
if cOutCode <> "999" .or. cOutCode <> "0" 
	? "Postoji greska : " + cOutCode
else
	? "Greske nema ..."
endif


? "Test izdavanja racuna zavrsen ..."

return
*}


/*! \fn TestFisRn2()
 *  \brief Test racuna na FISSTA - bez programskog kreiranja artikla
 *  \todo Ovaj test ne valja...
 */
function TestFisRn2()
*{
? REPLICATE("-", 70)
? "Test izdavanja racuna sa unaprijed definisanim XML fajlovima"
? REPLICATE("-", 70)
	
cRd:=""
	
WrMainOutCode(gFisCTTPath)
? "mainout: Upisao kod 999"
	
WrMainInCode("1", gFisCTTPath)
? "mainin: upisao 1"
Sleep(gFisTimeOut)
	
cRd:=RdMainOutCode(gFisCTTPath)
? "citam mainout: " + cRd
	
if cRd <> "0"
	return
endif
		
WrMainOutCode(gFisCTTPath)
	
WrMainInCode("8", gFisCTTPath)
? "mainin: upisao 8"
Sleep(gFisTimeOut)
	
cRd:=RdMainOutCode(gFisCTTPath)
? "citam mainout: " + cRd
	
if cRd <> "0"
	return
endif
	
WrMainOutCode(gFisCTTPath)
	
WrMainInCode("2", gFisCTTPath)
? "mainin: upisao 2"
Sleep(gFisTimeOut)
	
cRd:=RdMainOutCode(gFisCTTPath)
? "citam mainout: " + cRd


return

*}


/*! \fn TestFisRn3()
 *  \brief Test stampe FISSTA racuna
 */
 
function TestFisRn3()
*{

? REPLICATE("-", 70)
? "Test izdavanja racuna sa definisanim matricama"
? REPLICATE("-", 70)


aArtikli:={}
AADD(aArtikli, {"100000000010", "EFFEGI 2340", 1000.00, "3", "1", "6"})
AADD(aArtikli, {"100000000251", "KLOMPE Z.BIJELE", 890.50, "3", "1", "6"})
AADD(aArtikli, {"100000003120", "ILLUMINATI 22/33", 2780.00, "3", "1", "6"})
AADD(aArtikli, {"100000006129", "PLACENTE 2350/80", 3020.40, "3", "1", "6"})

aArtRacun:={}
AADD(aArtRacun, {1.00, "100000000010"})
AADD(aArtRacun, {2.00, "100000006129"})

nIznos:=7040.80
cTipPl:="1"

? "Stampaj racun na FISSTA"
if !FisRacun(aArtikli, aArtRacun, nIznos, cTipPl)
	? "Greska pri izdavanju racuna"
endif

return
*}


/*! \fn TestRptDn1()
 *  \brief Test fisklanog dnevnog izvjestaja
 */
function TestRptDn1()
*{

CheckFisCTTStarted(.t.)

FisRptDnevni()

return
*}


/*! \fn TestRptDn2()
 *  \brief Test fisklanog dnevnog izvjestaja sa evidentiranjem posljednjeg formiranja
 */
function TestRptDn2()
*{

CheckFisCTTStarted(.t.)

if !ReadLastFisRpt("1", DATE())
	if FisRptDnevni()
		WriteLastFisRpt("1", DATE(), TIME())
	else
		MsgBeep("Greska pri formiranju izvjestaja...")
	endif
else
	MsgBeep("Dnevni izvjestaj vec formiran...")
endif

return
*}


/*! \fn TestRptPer1()
 *  \brief Test stampe fisk.izvjestaja za period
 */
function TestRptPer1()
*{

CheckFisCTTStarted(.t.)

FisRptPeriod()

return
*}



function TestFisRn5()
*{






return
*}



/*! \fn FisTest_mnu()
 *  \brief Menij sa test case-ovima
 */
function FisTest_mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. racun                          ")
AADD(opcexe, {|| TestFisRn3() })

AADD(opc, "2. fiskalni dnevni izvjestaj      ")
AADD(opcexe, {|| TestRptDn1() })

AADD(opc, "3. fiskalni izvjestaj za period   ")
AADD(opcexe, {|| TestRptPer1() })


Menu_Sc("fts")

return
*}

/*! \fn TestFisRn4()
 *  \brief Test uzimanja podataka iz baze
 */
 
function TestFisRn4()
*{

? REPLICATE("-", 70)
? "Test FisRacun4: Test uzimanja podataka iz baze"
? REPLICATE("-", 70)

aArtikli:={}
aArtRacun:={}
aArtikli1:={}
aArtRacun1:={}
nUkupno:=0 
nUkupno1:=0 

if (select('_pripr')=0)
   O__PRIPR
endif

if (select('_pripr')!=0)
   zap
endif
append blank
replace cijena with 3899, ;
        idroba with '01MCJ00011', ;
        idtarifa with '1', ;
        jmj with 'PAR', ;
        kolicina with 3, ;
        robanaz with 'THEMA'
append blank
replace cijena with 2619, ;
        idroba with '01MCJ00001', ;
        idtarifa with '1', ;
        jmj with 'PAR', ;
        kolicina with 2, ;
        robanaz with 'DRINA'

AADD(aArtikli1, {"100000000062", "DRINA", 2619.00, "3", "1", "6"})
AADD(aArtikli1, {"100000000064", "THEMA", 3899.00, "3", "1", "6"})

AADD(aArtRacun1, {2.00, "100000000062"})
AADD(aArtRacun1, {3.00, "100000000064"})

nUkupno1:=16935.00
        
FillFisMatrice(@aArtikli, @aArtRacun, @nUkupno)

? "aArtikli: uporedjujem duzine matrice ..."
if LEN(aArtikli) = LEN(aArtikli1) 
	?? " [OK] "
else
	?? "False "+alltrim(str(LEN(aArtikli)))+':'+alltrim(str(LEN(aArtikli1)))
endif
? "aArtikli: uporedjujem elemente matrice ..."
nErr:=0
for nCnt:=1 to LEN(aArtikli)
	for nCnt2:=1 to 6
		if (aArtikli[nCnt, nCnt2] <> aArtikli1[nCnt, nCnt2])
			nErr ++
			? "    Razlika u elementu: " + alltrim(STR(nCnt)) + "-" + alltrim(STR(nCnt2))
		endif
	next
next
if (nErr == 0)
	?? " [OK] "
else
	?? " False "
endif
	
? "aArtRacun: uporedjujem duzine matrice ..."
if LEN(aArtRacun) = LEN(aArtRacun1) 
	?? " [OK] "
else
	?? "False "+alltrim(str(LEN(aArtRacun)))+':'+alltrim(str(LEN(aArtRacun1)))
endif
? "aArtRacun: uporedjujem elemente matrice ..."
nErr:=0
for nCnt:=1 to LEN(aArtRacun)
	for nCnt2:=1 to 2
		if (aArtRacun[nCnt, nCnt2] <> aArtRacun1[nCnt, nCnt2])
			nErr ++
			? "   Razlika u elementu: " + alltrim(STR(nCnt)) + "-" + alltrim(STR(nCnt2))
		endif
	next
next
if (nErr == 0)
	?? " [OK] "
else
	?? " False "
endif

? "Poredim ukupan iznos ..."
if nUkupno <> nUkupno1 
	?? "False " + str(nUkupno) + ' : '+ str(nUkupno1)
else
	?? " [OK] "
endif
?
? 'Test zavrsen'

return
*}

/*! \fn TestFisSviNaJedan()
 *  \brief Test-case procedure izdavanja racuna na FISSTA kao da ju je pozvao korisnik regularnim putem
 */
 
function TestFisSviNaJedan()
*{

aArtikli:={}
aArtRacun:={}
nUkupno:=0 


gClanPopust:=.f.
gUpitNP:="N"

? REPLICATE("-", 70)
? "Test procedure izdavanja racuna na FISSTA kao da ju je pozvao korisnik"
? REPLICATE("-", 70)

if gFissta == "D"
	if (select('_pripr')=0)
		O__PRIPR
	endif

	if (select('_pripr')!=0)
		zap
	endif
	append blank
	replace cijena with 3992, ;
		idroba with '01MCJ02321', ;
		idtarifa with '1', ;
		jmj with 'PAR', ;
		kolicina with 3, ;
		robanaz with 'EFFEGI 243620304'
	append blank
	replace cijena with 1269, ;
		idroba with '01MTR02553', ;
		idtarifa with '1', ;
		jmj with 'PAR', ;
		kolicina with 1, ;
		robanaz with 'INTERALP WT998'
	append blank
	replace cijena with 1000, ;
		idroba with '01MTR01443', ;
		idtarifa with '1', ;
		jmj with 'PAR', ;
		kolicina with 2, ;
		robanaz with 'KOPITARNA 593'
	append blank
	replace cijena with 1990, ;
		idroba with '01ZCJ01012', ;
		idtarifa with '1', ;
		jmj with 'PAR', ;
		kolicina with 2, ;
		robanaz with 'SIBILA'
	replace cijena with 1190, ;
		idroba with '01ZCJ02331', ;
		idtarifa with '1', ;
		jmj with 'PAR', ;
		kolicina with 5, ;
		robanaz with 'ELEGANT Z.PAPUCA'
	replace cijena with 1070, ;
		idroba with '02MSP01231', ;
		idtarifa with '1', ;
		jmj with 'PAR', ;
		kolicina with 4, ;
		robanaz with 'FILANTO'

	SveNaJedan()
	FillFisMatrice(@aArtikli, @aArtRacun, @nUkupno)
	if LEN(aArtikli) != 0 .or. LEN(aArtRacun) != 0
		? "Test - [ FAILED ]"
	else
		? "Test - [ OK ]"
	endif
else
? "Opcija FMK.INI/EXEPATH/FISSTA Fissta ne postoji ili je = N"
? "Postavite Fissta=D"
endif

*}

