#include "\dev\fmk\pos\pos.ch"



/*! \fn WriteArtikliXml(aArtikli, cFilePath)
 *  \brief Kreira fajl ARTIKLI.XML i upisuje sadrzaj iz matrice aArtikli
 *  \param aArtikli  - matrica sa podacima o artiklima; struktura: {"idartikal","naziv","cijena","poreska stopa", "odjeljenje", "jmj"}
 *  \param cFilePath - lokacija fajla ARTIKLI.XML, mora biti lokacija interfejsa FisCTT
 */
function WriteArtikliXML(aArtikli, cFilePath)
*{

local nH, cFileName

cFileName := cFilePath+'artikli.xml'
// Kreiraj file
if (nH:=fcreate(cFileName))==-1
   Beep(4)
   Msg("Greska pri kreiranju fajla: "+cFileName+" !",6)
   return
endif

fclose(nH)

// Otvori file za upis
set printer to (cFileName)
set printer on
set console off

   // Upiši zaglavlje XML file
   XMLWriteHeader()
   // Upiši body
   lResult := XMLWriteArticles(aArtikli)
   // Upiši footer
   XMLWriteFooter()
   
// Zatvori file
set printer to
set printer off
set console on

// ako je nastupila greska izbrisi artikli.xml
if !lResult
   FERASE(cFileName)
endif

return
*}

/*! \fn XMLWriteHeader()
 *  \brief Ispisuje Header XML fajla ARTIKLI.XML, prereqiust set printer to (cFileName)
 */
function XMLWriteHeader()
*{
   ?? '<?xml version="1.0" standalone="no"?>'
   ? '<!DOCTYPE Artikli SYSTEM "Artikli.dtd">'

return
*}


/*! \fn XMLWriteArticles(aArticles)
 *  \brief upisuje body ARTIKLI.XML 
 *  \param aArtikli - matrica napunjena podacima o artiklima iz ARTIKLI.XML
 *  \return .t. ako nema greske, inace .f.
 */
function XMLWriteArticles(aArticles)
*{
local nRowCount, nRow, sXMLLine

   ? '<Artikli>'
   nRowCount = LEN(aArticles)
   FOR nRow = 1 TO nRowCount
      sXMLLine := '<Plu ' 
      
      if (CheckLength(aArticles[nRow, 2], 18))
         sXMLLine += 'Des="'+aArticles[nRow, 2]+'" '
      else
         return .f.
      endif
      
      if (CheckLength(alltrim(str(aArticles[nRow, 3])), 9))
         // provjerava broj decimala
         if (right(alltrim(str(aArticles[nRow, 3])), 3) = '.')
            sXMLLine += 'Price="'+alltrim(str(aArticles[nRow, 3]))+'" '
         else
            Beep(4)
            Msg("Neispravan broj decimala "+alltrim(str(aArticles[nRow, 3]))+", potrebno dvije decimale !",6)
            return .f.
         endif
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 4], 1))
         sXMLLine += 'Vat="'+aArticles[nRow, 4]+'" '
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 5], 9))
         sXMLLine += 'Dep="'+aArticles[nRow, 5]+'" '
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 6], 2))
         sXMLLine += 'Mes="'+aArticles[nRow, 6]+'">'
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 1], 12))
         sXMLLine += aArticles[nRow, 1]
      else
         return .f.
      endif
      sXMLLine += '</Plu>'
      ? sXMLLine
   NEXT
   ? '</Artikli>'

return .t.
*}

/*! \fn CheckLength(cString, nLength)
 *  \brief ispituje duzinu stringa cString 
 *  \param cString - string koji se ispituje
 *  \param nLength - maksimalna dužina stringa
 *  \return .t. ako je string manji ili jednak nLength, inace .f.
 */
function CheckLength(cString, nLength)
local lResult

   if (len(cString)>nLength)
      Beep(4)
      Msg("Neispravna duzina "+cString+", max("+alltrim(str(nLength))+") !",6)
      lResult := .f.
   else
      lResult := .t.
   endif
   
return lResult


/*! \fn XMLWriteFooter()
 *  \brief Ispisuje Footer XML fajla ARTIKLI.XML, fajl ARTIKLI.XML nema footera pa je zato prazno
 */
function XMLWriteFooter()
*{

return
*}


/*! \fn WriteArtRacunXml(aArtRacun, cFileName)
 *  \brief Kreira fajl ARTRACUN.XML i upisuje sadrzaj iz matrice aArtRacun
 *  \param aArtRacun  - matrica sa stavkama racuna; struktura:	{"kolicina","id artikal"}
 *  \param cFileName - putanja i ime izlaznog fajla
 */
function WriteArtRacunXML(aArtRacun, cFileName)
*{



return
*}


/*! \fn WritePlacanjaXml(nIznos, cTipPlacanja, cFileName)
 *  \brief Kreira fajl PLACANJA.XML i popunjava ga sa stavkama nIznos i cTipPlacanja
 *  \param nIznos  - ukupan iznos racuna
 *  \param cTipPlacanja - tip placanja (1, 2 ili 3)
 *  \param cFileName - putanja i ime izlaznog fajla
 */
function WritePlacanjaXML(nIznos, cTipPlacanja, cFileName)
*{



return
*}


/*! \fn ReadArtikliXml(cFilePath)
 *  \brief Vrsi iscitavanje podataka cFilePath + "ARTIKLI.XML" u matricu
 *  \param cFilePath - lokacija fajla ARTIKLI.XML
 *  \return aArtikli - matrica napunjena podacima o artiklima iz ARTIKLI.XML 
 */
function ReadArtikliXml(cFilePath)
*{
// aArtikli = {"id artikla", "naziv", "cijena", "poreska stopa", "odjeljenje", "jmj"}

local cFileName, cXML

aArtikli = {}
cFileName := cFilePath+'artikli.xml'
cXML := FILESTR(cFileName)

nStart := at('<Plu', cXML)
while (nStart>0)
   nEnd     := at('</Plu>', cXML)+6
   cXMLLine := substr(cXML, nStart, (nEnd-nStart))

   nStartField := at('">', cXMLLine)+2
   nEndField   := at('</Plu>', cXMLLine)
   cID         := substr(cXMLLine, nStartField, nEndField-nStartField)
   
   nStartField := at('Des="', cXMLLine)+5
   nEndField   := at('" Price="', cXMLLine)
   cName       := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Price="', cXMLLine)+7
   nEndField   := at('" Vat="', cXMLLine)
   cPrice      := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Vat="', cXMLLine)+5
   nEndField   := at('" Dep="', cXMLLine)
   cVat        := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Dep="', cXMLLine)+5
   nEndField   := at('" Mes="', cXMLLine)
   cDep        := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Mes="', cXMLLine)+5
   nEndField   := at('">', cXMLLine)
   cMes        := substr(cXMLLine, nStartField, nEndField-nStartField)

   AADD(aArtikli, {cID, cName, val(cPrice), cVat, cDep, cMes})

   cXML   := substr(cXML, nEnd)
   nStart := at('<Plu', cXML)

end

return aArtikli
*}


/*! \fn ReadArtRacunXml(cFilePath)
 *  \brief Vrsi iscitavanje podataka cFilePath + "ARTRACUN.XML" u matricu
 *  \param cFilePath - lokacija fajla ARTRACUN.XML
 *  \return aArtikli - matrica napunjena podacima iz ARTRACUN.XML 
 */
function ReadArtRacunXml(cFilePath)
*{
// aArtRacun = {"kolicina", "id artikla"}
aArtRacun:={}
return aArtRacun
*}


/*! \fn ReadPlacanjaXml(cFilePath)
 *  \brief Vrsi iscitavanje podataka cFilePath + "PLACANJA.XML" u matricu
 *  \param cFilePath - lokacija fajla PLACANJA.XML
 *  \return aArtikli - matrica napunjena podacima iz PLACANJA.XML 
 */ 
function ReadPlacanjaXml(cFilePath)
*{
// aPlacanja = {"iznos", "tip placanja"}

return aPlacanja
*}



/*! \fn WriteMainInCode(cCode, cFilePath)
 *  \brief Upisuje u fajl mainin.dat kod - cCode, 
     Napomena:
      - ako fajl mainin.dat ne postoji kreira ga i upisuje cCode
      - ako fajl mainin.dat postoji, brise sve iz njega i upisuje cCode
 *  \param cCode - kod
 *  \param cFilePath - lokacija fajla mainin.dat, mora biti lokacija interfejsa FisCTT
 */
function WriteMainInCode(cCode, cFilePath)
*{
   local nH, cFileName
   cFileName := cFilePath + 'mainin.dat'
   
   WriteMainFileCode(cCode, cFileName)

return
*}


/*! \fn ReadMainInCode(cFilePath)
 *  \brief Cita kod iz fajl-a mainin.dat
 *  \param cFilePath - lokacija fajla "mainin.dat"
 */
function ReadMainInCode(cFilePath)
*{
   local cFileName, cCode
   cFileName := cFilePath + 'mainin.dat'

   cCode:= ReadMainFileCode(cFileName)

return cCode
*}


/*! \fn WriteMainOutCode(cFilePath, cTestCode)
 *  \brief Upisuje u mainout.dat uvijek kod "999"
     Napomena:
      - ako fajl mainout.dat ne postoji, kreira se i upisuje se kod "999"
      - ako fajl mainout.dat postoji, brise njegov sadrzaj i upisuje kod "999"
 *  \param cFilePath - lokacija fajla mainout.dat, mora biti lokacija interfejsa FisCTT
 *  \param cTestCode - koristi se kao testni kod, po def.ovog parametra nema
 */
function WriteMainOutCode(cFilePath, cTestCode)
*{
   // uvijek u mainout.dat upisi kod "999"
   local nH, cFileName
   cFileName := cFilePath + 'mainout.dat'

   cCode:="999"
   
   if cTestCode <> nil
   	cCode:=cTestCode
   endif
   
   WriteMainFileCode(cCode, cFileName)

return
*}

/*! \fn ReadMainOutCode(cFilePath)
 *  \brief Cita iz fajla mainout.dat posljednju gresku - ako postoji, ako je kod "0" onda nema greske.
 *  \param cFilePath - lokacija fajla mainout.dat
 */
function ReadMainOutCode(cFilePath)
*{
   local cFileName, cCode
   cFileName := cFilePath + 'mainout.dat'

   cCode:= ReadMainFileCode(cFileName)

return cCode
*}

/*! \fn WriteMainFileCode(cCode, cFileName)
 *  \brief Upisuje u fajl cFileName - cCode, 
     Napomena:
      - ako fajl cFileName ne postoji kreira ga i upisuje cCode
 *  \param cCode - kod
 *  \param cFileName - naziv fajla sa kompletnim path-om
 */
function WriteMainFileCode(cCode, cFileName)
*{
local nH
   
// kreiraj fajl ponovo, tako da smo sigurni da je prazan
if file(cFileName)
	ferase(cFileName)
endif
   
if (nH:=fcreate(cFileName))==-1
	Beep(4)
      	Msg("Greska pri kreiranju fajla: "+cFileName+" !",6)
      	return
endif
fclose(nH)

// Otvori file za upis
set printer to (cFileName)
set printer on
set console off

// Upisi cCode
// kada probam upisati sa ? - doda jednu praznu liniju viska

?? ALLTRIM(cCode)
      
// Zatvori file
set printer to
set printer off
set console on


return
*}


/*! \fn ReadMainFileCode(cFileName)
 *  \brief Cita kod iz fajl-a cFileName
 *  \param cFileName - naziv fajla sa kompletnim path-om
 *  \return - sadržaj iz cFileName
 */
function ReadMainFileCode(cFileName)
*{
   local cCode
   cCode:=''

   cCode := alltrim(FILESTR(cFileName))

return cCode
*}



/*! \fn StartFisCTTInterface(cPath, bSilent)
 *  \brief Starta FisCTT interfejs
 *  \param cPath - lokacija interfejsa
 *  \param bSilent - .t. - startaj FisCTT bez pitanja, .f. - postavi pitanje
 */
function StartFisCTTInterface(cPath, bSilent)
*{

if bSilent == nil
	bSilent:=.t.
endif

if !bSilent .and. Pitanje(,"Startati FisCTT interfejs (D/N)?", "D")=="N"
	return
endif

cPath:=ALLTRIM(cPath)

if RIGHT(cPath, 1) <> SLASH
	cPath += SLASH
endif

if !DirExists(cPath)
	MsgBeep("Ne postoji direktorij: " + cPath + "# Prekidam operaciju!")
	return
endif

// Prije pokretanja interfejsa postavi kod za inicijalizaciju
WriteMainInCode("0", cPath)

cKomLin:="start " + cPath + "fiscal28.jar"

// pokreni komandu
run &cKomLin


return
*}


/*! \fn IsFisCTTStarted(cPath)
 *  \brief Provjerava da li je FisCTT started
 *  \param cPath - lokacija interfejsa
 */
function IsFisCTTStarted()
*{

cCode:=ReadMainInCode(gFisCTTPath)

if cCode=="9"
	MsgBeep("OK")
else
	MsgBeep("NOT OK")
endif

return
*}




function FisRacun()
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


