#include "\dev\fmk\pos\pos.ch"


/*! \fn Fis_test_main()
 *  \brief glavna testna funkcija koja poziva sve test caseove
 */
 
function Fis_test_main()
*{

FisTestWriteArtikliXml()




return
*}


/*! \fn FisTestWriteArtikliXml()
 *  \brief testiranje ispravnosti kreiranog fajla ARTIKLI.XML
 */
function FisTestWriteArtikliXml()
*{

aInput:={}
// aInput: id artikla (oid), naziv, cijena, por.stopa, odjeljenje, jmj
AADD(aInput, {"100000000010", "EFFEGI 2340", 1000.00, "3", "1", "6"})
AADD(aInput, {"100000000251", "KLOMPE Z.BIJELE", 890.50, "3", "1", "6"})
AADD(aInput, {"100000003120", "ILLUMINATI 22/33", 2780.00, "3", "1", "6"})
AADD(aInput, {"100000006129", "PLACENTE 2350/80", 3020.40, "3", "1", "6"})

cOriginalFile:="h:\dev\fmk\pos\fissta\1g\testxml\art01.xml"
cOutPutFile:="h:\dev\fmk\pos\fissta\1g\testxml\art01g.xml"

WriteArtikliXML(aInput, cOutPutFile)

// uporedi kreirani fajl sa cOutPutFile
lReturn:=ReadXmlError(cOriginalFile, cOutPutFile)

if lReturn
	? "Rezultat testa: OK"
else
	? "Rezultat testa: nepravilna struktura fajla"
endif


return 
*}


