#include "\dev\fmk\pos\pos.ch"


/*! \fn Fis_test_main()
 *  \brief glavna testna funkcija koja poziva sve test caseove
 */
function Fis_test_main()
*{

// test kreiranja fajla ARTIKLI.XML te provjera njegovog sadrzaja
TestRWArtikliXml()


// test kreiranja fajla ARTRACUN.XML te provjera njegovog sadrzaja
//TestRWArtRacunXml()

// test kreiranja fajla PLACANJA.XML te provjera njegovog sadrzaja
//TestRWPlacanjaXml()

// test upisivanja i citanja kodova iz fajlova mainin.dat i mainout.dat
TestRWMainInOut()


// test izdavanja racuna
//TestFisRn1()

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
cFilePath:="h:\dev\fmk\pos\fissta\1g\testxml\"

// aInput: id artikla (oid), naziv, cijena, por.stopa, odjeljenje, jmj
AADD(aInput, {"100000000010", "EFFEGI 2340", 1000.00, "3", "1", "6"})
AADD(aInput, {"100000000251", "KLOMPE Z.BIJELE", 890.50, "3", "1", "6"})
AADD(aInput, {"100000003120", "ILLUMINATI 22/33", 2780.00, "3", "1", "6"})
AADD(aInput, {"100000006129", "PLACENTE 2350/80", 3020.40, "3", "1", "6"})

WriteArtikliXML(aInput, cFilePath)
// iscitaj iz kreiranog artikli.xml podatke u aOutPut
aOutPut:=ReadArtikliXml(cFilePath)

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
cFilePath:="h:\dev\fmk\pos\fissta\1g\testxml\"

// aInput: kolicina, id artikla (oid)
AADD(aInput, {"1.00", "100000000010"})
AADD(aInput, {"2.00", "100000000251"})
AADD(aInput, {"10.00", "100000003120"})
AADD(aInput, {"1.00", "100000006129"})

WriteArtRacunXML(aInput, cFilePath)
// iscitaj iz kreiranog artracun.xml podatke u aOutPut
aOutPut:=ReadArtRacunXml(cFilePath)

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
		if aInput[nCnt, nCnt2] <> aOutPut[nCnt, nCnt2]
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

return 
*}



/*! \fn TestRWPlacanjaXml()
 *  \brief testiranje ispravnosti kreiranog fajla PLACANJA.XML
 */
function TestRWPlacanjaXml()
*{

aOutPut:={}
cFilePath:="h:\dev\fmk\pos\fissta\1g\testxml\"

nIznos:=100.50

// prodji 3 kruga i upisi i provjeri podatke
// 1. iznos = 100.50 * 1, tip = 1
// 2. iznos = 100.50 * 2, tip = 2
// 3. iznos = 100.50 * 3, tip = 3

for i:=1 to 3
	WritePlacanjaXML(nIznos * i, STR(i), cFilePath)
	// iscitaj iz kreiranog placanja.xml podatke u aOutPut
	aOutPut:=ReadPlacanjaXml(cFilePath)

	// provjeri ima li podataka u PLACANJA.XML
	if LEN(aOutPut) == 0
		? "Fajl PLACANJA.XML je prazan"
	endif

	if LEN(aOutPut) > 0
		// provjeri ispravnost podataka
		// iznos
		if nIznos * i <> aOutPut[1, 1]
			? "Neispravan parametar 1"
		endif
		// oznaku vrste placanja
		if STR(i) <> aOutPut[1, 2]
			? "Neispravan parametar 2"
		endif
	endif
next

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
cFilePath:="h:\dev\fmk\pos\fissta\1g\testdat\"

// test1: upisivanja i citanja kod-a iz fajla mainin.dat
// upisi kodove od -10 do 10

?
? "MAININ.DAT: Test WR kodova od 0 do 9 "

nCnt:=0

for i:=0 to 9
	cCode:=ALLTRIM(STR(i))
	WriteMainInCode(cCode, cFilePath)
	cReadCode:=ReadMainInCode(cFilePath)
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
	WriteMainOutCode(cFilePath, cCode)
	cReadCode:=ReadMainOutCode(cFilePath)
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
 */
function TestFisRn1()
*{

? REPLICATE("-", 70)
? "Test: izdavanje racuna"
? REPLICATE("-", 70)

cFilePath:="h:\dev\fmk\pos\fissta\1g\"

aArtikli:={}
AADD(aArtikli, {"100000000010", "EFFEGI 2340", 1000.00, "3", "1", "6"})
AADD(aArtikli, {"100000000251", "KLOMPE Z.BIJELE", 890.50, "3", "1", "6"})
AADD(aArtikli, {"100000003120", "ILLUMINATI 22/33", 2780.00, "3", "1", "6"})
AADD(aArtikli, {"100000006129", "PLACENTE 2350/80", 3020.40, "3", "1", "6"})
WriteArtikliXml(aArtikli, cFilePath)
aOutPut:=ReadArtikliXml(cFilePath)
if LEN(aArtikli) <> LEN(aOutPut)
	? "ARTIKLI.XML: nije dobro izgenerisan fajl"
endif

aArtRacun:={}
AADD(aArtRacun, {"1.00", "100000000010"})
AADD(aArtRacun, {"2.00", "100000006129"})
WriteArtRacunXml(aArtRacun, cFilePath)
aOutPut:=ReadArtRacunXml(cFilePath)
if LEN(aArtRacun) <> LEN(aOutPut)
	? "ARTRACUN.XML: nije dobro izgenerisan fajl"
endif

// izdajem gotovinski racun
nIznos:=7040.80
cTipPl:="1"
WritePlacanjaXml(nIznos, cTipPl, cFilePath)
aOutPut:=ReadPlacanjaXml(cFilePath)
if (aOutPut[1, 1] <> nIznos .or. aOutPut[1, 2] <> cTipPl)
	? "PLACANJA.XML: nije dobro izgenerisan fajl"
endif

?
? "Test zadavanja komandi..."
?

bErr:=.f.

// komanda: ucitaj iz ARTIKLI.XML stavke u memoriju racunara
cCode:="1"
WriteMainInCode(cCode, cFilePath)
cReadCode:=ReadMainInCode(cFilePath)

if (cReadCode <> cCode)
	? "Nije dobro upisana komanda 1"
else
	? "Upisao komandu 1"
endif

? "Cekam mogucu gresku ..."
WriteMainOutCode(cFileName)
cOutCode:=ReadMainOutCode(cFileName)
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
WriteMainInCode(cCode, cFilePath)
cReadCode:=ReadMainInCode(cFilePath)

if (cReadCode <> cCode)
	? "Nije dobro upisana komanda 8"
else
	? "Upisao komandu 8"
endif

? "Cekam mogucu gresku ..."
WriteMainOutCode(cFileName)
cOutCode:=ReadMainOutCode(cFileName)
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
WriteMainInCode(cCode, cFilePath)
cReadCode:=ReadMainInCode(cFilePath)

if (cReadCode <> cCode)
	? "Nije dobro upisana komanda 2"
else
	? "Upisao komandu 2"
endif

? "Cekam mogucu gresku ..."
WriteMainOutCode(cFileName)
cOutCode:=ReadMainOutCode(cFileName)
if cOutCode <> "999" .or. cOutCode <> "0" 
	? "Postoji greska : " + cOutCode
else
	? "Greske nema ..."
endif


? "Test izdavanja racuna zavrsen ..."

return
*}


/*! \fn TestFisNn2()
 *  \brief Test racuna na FISSTA - bez programskog kreiranja artikla
 */
function TestFisRn2()
*{

Box(,4, 50)
	
	cRd:=""
	
	WriteMainOutCode(gFisCTTPath)
	@ 1+m_x, 2+m_y SAY "mainout: Upisao kod 999"
	
	WriteMainInCode("1", gFisCTTPath)
	@ 2+m_x, 2+m_y SAY "mainin: upisao 1"
	inkey(gFisTimeOut)
	
	cRd:=ReadMainOutCode(gFisCTTPath)
	@ 3+m_x, 2+m_y SAY "greska: " + cRd
	
	if cRd <> "0"
		return
	endif
		
	WriteMainOutCode(gFisCTTPath)
	
	WriteMainInCode("8", gFisCTTPath)
	@ 2+m_x, 2+m_y SAY "mainin: upisao 8"
	inkey(gFisTimeOut)
	
	cRd:=ReadMainOutCode(gFisCTTPath)
	@ 3+m_x, 2+m_y SAY "greska: " + cRd
	
	if cRd <> "0"
		return
	endif
	
	WriteMainOutCode(gFisCTTPath)
	
	WriteMainInCode("2", gFisCTTPath)
	@ 2+m_x, 2+m_y SAY "mainin: upisao 2"
	inkey(gFisTimeOut)
	
	cRd:=ReadMainOutCode(gFisCTTPath)
	@ 3+m_x, 2+m_y SAY "greska: " + cRd

BoxC()

return

*}
