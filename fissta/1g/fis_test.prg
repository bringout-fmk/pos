#include "\dev\fmk\pos\pos.ch"


/*! \fn Fis_test_main()
 *  \brief glavna testna funkcija koja poziva sve test caseove
 */
 
function Fis_test_main()
*{

// test kreiranja fajla ARTIKLI.XML te provjera njegovog sadrzaja
TestRWArtikliXml()

// test kreiranja fajla ARTRACUN.XML te provjera njegovog sadrzaja
TestRWArtRacunXml()

// test kreiranja fajla PLACANJA.XML te provjera njegovog sadrzaja
TestRWPlacanjaXml()


// test upisivanja i citanja kodova iz fajlova mainin.dat i mainout.dat
TestRWMainInOut()



return
*}


/*! \fn TestRWArtikliXml()
 *  \brief testiranje ispravnosti kreiranog fajla ARTIKLI.XML
 */
function TestRWArtikliXml()
*{

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

// uporedi matrice 
if LEN(aInput) <> LEN(aOutPut) 
	? "Razlika u duzini matrice"
endif

// pogledaj ima li gresaka u elementima matrice
for nCnt:=1 to LEN(aInput)
	for nCnt2:=1 to 6
		if aInput[nCnt, nCnt2] <> aOutPut[nCnt, nCnt2]
			? "Razlika u elementu: " + STR(nCnt) + "-" + STR(nCnt2)
		endif
	next
next

return 
*}



/*! \fn TestRWArtRacunXml()
 *  \brief testiranje ispravnosti kreiranog fajla ARTRACUN.XML
 */
function TestRWArtRacunXml()
*{

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

// uporedi matrice 
if LEN(aInput) <> LEN(aOutPut) 
	? "Razlika u duzini matrice"
endif

// pogledaj ima li gresaka u elementima matrice
for nCnt:=1 to LEN(aInput)
	for nCnt2:=1 to 2
		if aInput[nCnt, nCnt2] <> aOutPut[nCnt, nCnt2]
			? "Razlika u elementu: " + STR(nCnt) + "-" + STR(nCnt2)
		endif
	next
next

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
cCode:=""
cReadCode:=""
cFilePath:="h:\dev\fmk\pos\fissta\1g\testdat\"

// test1: upisivanja i citanja kod-a iz fajla mainin.dat
// upisi kodove od -10 do 10

for i:=0 to 9
	cCode:=STR(i)
	WriteMainInCode(cCode, cFilePath)
	cReadCode:=ReadMainInCode(cFilePath)
	? "Test RW mainin/out krug: " + STR(i)
	if cReadCode <> cCode
		?? " Nepravilno upisan kod u mainin.dat"
	else
		?? " - OK"
	endif
next

// test2: upisivanja i citanja kod-a iz fajla mainout.dat
// upisi kodove od -10 do 10

for i:=-10 to 10 
	cCode:=STR(i)
	WriteMainOutCode(cCode, cFilePath)
	cReadCode:=ReadMainOutCode(cFilePath)
	? "Test RW mainin/out krug: " + STR(i)
	if cReadCode <> cCode
		?? " Nepravilno upisan kod u mainout.dat"
	else
		?? " - OK"
	endif
next

*}

