#include "\dev\fmk\pos\pos.ch"


/*! \fn Fis_test_main()
 *  \brief glavna testna funkcija koja poziva sve test caseove
 */
 
function Fis_test_main()
*{
// test kreiranja fajla ARTIKLI.XML
FisTestWriteArtikliXml()

// test upisivanja i citanja kodova iz fajlova mainin.dat i mainout.dat
TestRWMainInOut()



return
*}


/*! \fn FisTestWriteArtikliXml()
 *  \brief testiranje ispravnosti kreiranog fajla ARTIKLI.XML
 */
function FisTestWriteArtikliXml()
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
for i:=1 to LEN(aInput)
	if aInput[1, i] <> aOutPut[1, i]
		? "Razlika u elementu 1"
	endif
	// TO DO: jos razraditi
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

