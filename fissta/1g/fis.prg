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
   XMLWriteHeader('Artikli')
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
 *  \param cFile - naziv XML fajla
 */
function XMLWriteHeader(cFile)
*{
   ?? '<?xml version="1.0" standalone="no"?>'
   ? '<!DOCTYPE '+cFile+' SYSTEM "'+cFile+'.dtd">'

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
 *  \brief Ispisuje Footer XML fajlova, XML fajlovi nemaju footera pa je zato prazno
 *  \param cFile - naziv XML fajla
 */
function XMLWriteFooter(cFile)
*{

return
*}


/*! \fn WriteArtRacunXml(aArtRacun, cFileName)
 *  \brief Kreira fajl ARTRACUN.XML i upisuje sadrzaj iz matrice aArtRacun
 *  \param aArtRacun  - matrica sa stavkama racuna; struktura:	{"kolicina","id artikal"}
 *  \param cFilePath - lokacija fajla ARTRACUN.XML, mora biti lokacija interfejsa FisCTT
 */
function WriteArtRacunXML(aArtRacun, cFilePath)
*{
local nH, cFileName

cFileName := cFilePath+'artracun.xml'
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
   XMLWriteHeader('ArtRacun')
   // Upiši body
   lResult := XMLWriteCheck(aArtRacun)
   // Upiši footer
   XMLWriteFooter('ArtRacun')
   
// Zatvori file
set printer to
set printer off
set console on

// ako je nastupila greska izbrisi artracun.xml
if !lResult
   FERASE(cFileName)
endif

return
*}

/*! \fn XMLWriteCheck(aArtCheck)
 *  \brief upisuje body ARTRACUN.XML 
 *  \param aArtCheck - matrica napunjena podacima o racunima iz ARTRACUN.XML
 *  \return .t. ako nema greske, inace .f.
 */
function XMLWriteCheck(aArtCheck)
*{
local nRowCount, nRow, sXMLLine

   ? '<ArtRacun>'
   nRowCount = LEN(aArtCheck)
   FOR nRow = 1 TO nRowCount
      sXMLLine := '<Plu ' 

      if (CheckLength(alltrim(str(aArtCheck[nRow, 1])), 8))
         // provjerava broj decimala
         if (right(alltrim(str(aArtCheck[nRow, 1])), 3) = '.')
            sXMLLine += 'kol="'+alltrim(str(aArtCheck[nRow, 1]))+'">'
         else
            Beep(4)
            Msg("Neispravan broj decimala "+alltrim(str(aArtCheck[nRow, 1]))+", potrebno dvije decimale !",6)
            return .f.
         endif
      else
         return .f.
      endif

      if (CheckLength(aArtCheck[nRow, 2], 12))
         sXMLLine += aArtCheck[nRow, 2]
      else
         return .f.
      endif
      sXMLLine += '</Plu>'
      ? sXMLLine
   NEXT
   ? '</ArtRacun>'

return .t.
*}

/*! \fn WritePlacanjaXml(nIznos, cTipPlacanja, cFileName)
 *  \brief Kreira fajl PLACANJA.XML i popunjava ga sa stavkama nIznos i cTipPlacanja
 *  \param nIznos  - ukupan iznos racuna
 *  \param cTipPlacanja - tip placanja (1, 2 ili 3)
 *  \param cFilePath - lokacija fajla PLACANJA.XML, mora biti lokacija interfejsa FisCTT
 */
function WritePlacanjaXML(nIznos, cTipPlacanja, cFilePath)
*{
local nH, cFileName, lResult

lResult := .t.
cFileName := cFilePath+'placanja.xml'
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
   XMLWriteHeader('Placanja')
   // Upiši body
   ? '<Placanja>'
   if ((nIznos <> nil) .and. (cTipPlacanja <> nil))
      sXMLLine := '<Vrsta '
      if (CheckLength(alltrim(str(nIznos)), 9))
         // provjerava broj decimala
         if (right(alltrim(str(nIznos)), 3) = '.')
            sXMLLine += 'kol="'+alltrim(str(nIznos))+'">'
         else
            Beep(4)
            Msg("Neispravan broj decimala "+alltrim(str(nIznos))+", potrebno dvije decimale !",6)
            lResult := .f.
         endif
      else
         lResult := .f.
      endif

      if (CheckLength(alltrim(cTipPlacanja), 1))
         sXMLLine += alltrim(cTipPlacanja)
      else
         lResult := .f.
      endif
      sXMLLine += '</Vrsta>'
      ? sXMLLine
   endif
   ? '</Placanja>'
   
   // Upiši footer
   XMLWriteFooter('Placanja')
   
// Zatvori file
set printer to
set printer off
set console on

// ako je nastupila greska izbrisi artracun.xml
if !lResult
   FERASE(cFileName)
endif

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
local cFileName, cXML

   aArtRacun:={}
   cFileName := cFilePath+'artracun.xml'

   cXML := FILESTR(cFileName)

   nStart := at('<Plu', cXML)
   while (nStart>0)
      nEnd     := at('</Plu>', cXML)+6
      cXMLLine := substr(cXML, nStart, (nEnd-nStart))

      nStartField := at('">', cXMLLine)+2
      nEndField   := at('</Plu>', cXMLLine)
      cID         := substr(cXMLLine, nStartField, nEndField-nStartField)
   
      nStartField := at('kol="', cXMLLine)+5
      nEndField   := at('">', cXMLLine)
      cKol        := substr(cXMLLine, nStartField, nEndField-nStartField)

      AADD(aArtRacun, {val(cKol), cID})

      cXML   := substr(cXML, nEnd)
      nStart := at('<Plu', cXML)
   end
   
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
local cFileName, cXML

   aPlacanja:={}
   cFileName := cFilePath+'placanja.xml'
   
   cXML := FILESTR(cFileName)
   
   nStart := at('<Vrsta', cXML)
   while (nStart>0)
      nEnd     := at('</Vrsta>', cXML)+8
      cXMLLine := substr(cXML, nStart, (nEnd-nStart))
   
      nStartField := at('">', cXMLLine)+2
      nEndField   := at('</Vrsta>', cXMLLine)
      cID         := substr(cXMLLine, nStartField, nEndField-nStartField)
      
      nStartField := at('kol="', cXMLLine)+5
      nEndField   := at('">', cXMLLine)
      cKol        := substr(cXMLLine, nStartField, nEndField-nStartField)
   
      AADD(aPlacanja, {val(cKol), cID})
   
      cXML   := substr(cXML, nEnd)
      nStart := at('<Plu', cXML)
   end
   
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
 *  \return cCode - proèitani kod
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



/*! \fn StartFisCTTInterface(bSilent)
 *  \brief Starta FisCTT interfejs
 *  \param bSilent - .t. - startaj FisCTT bez pitanja, .f. - postavi pitanje
 */
function StartFisCTTInterface(bSilent)
*{

cPath:=gFisCTTPath

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

// sacekaj da se interfejs pokrene
sleep(gFisTimeOut + 5)

if ReadMainInCode(cPath)=="9"
	if !bSilent
		MsgBeep("Interfejs pokrenut ...")
	endif
endif

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



/*! \fn GetCodeForArticleUnit(cUnit)
 *  \brief Vraca FISSTA "kod" JMJ na osnovu opisa roba->jmj
 *  \param cUnit - jedinica mjere (roba->jmj), npr "PAR"
 */
function GetCodeForArticleUnit(cUnit)
*{
cCode:=""

do case
	case cUnit=="KOM"
		cCode:="1"
	case cUnit=="KG"
		cCode:="2"
	case cUnit=="M"
		cCode:="3"
	case cUnit=="L"
		cCode:="4"
	case cUnit=="G"
		cCode:="5"
	case cUnit=="PAR"
		cCode:="6"
endcase

return cCode
*}


/*! \fn GetErrFromCode(cCode)
 *  \brief Vraca opis greske na osnovu koda cCode
 *  \param cCode - "kod" greske
 */
function GetErrFromCode(cCode)
*{

cErr:=""

do case
	case cCode == "-37"
		cErr:="U stampacu nema racuna"	
	case cCode == "-36"
		cErr:="Nedostaje baza artikala - komanda 1"
	case cCode == "-35"
		cErr:="Nepravilna vrijednost COM porta"
	case cCode == "-34"
		cErr:="Nepravilan format vrijednosti placanja"
	case cCode == "-33"
		cErr:="Nepravilan format vrste placanja"
	case cCode == "-32"
		cErr:="Niste definisali ni jedno placanje"
	case cCode == "-31"
		cErr:="Prevelik broj stavki placanja za jedan artikal"
	case cCode == "-30"
		cErr:="Prevelik broj artikala za jedan racun"
	case cCode == "-29"
		cErr:="Nepravilno formiran racun"
	case cCode == "-28"
		cErr:="Ne postoji definicija artikla"
	case cCode == "-27"
		cErr:="Nepravilan format XML fajla"
	case cCode == "-26"
		cErr:="Ne postoji fajl, izbrisan ili koruptovan"
	case cCode == "-25"
		cErr:="Nepravilno formirani podaci"
	case cCode == "-23"
		cErr:="Ne moze se stornirati racun, mora se ponistiti"
	case cCode == "-22"
		cErr:="Postoji zapocet racun, operacija odbijena"
	case cCode == "-21"
		cErr:="Greska u uredjaju"
	case cCode == "-6"
		cErr:="Ne podrzavanje javax.comm paketa"
	case cCode == "-5"
		cErr:="Nemogucnost komunikacije sa portom"
	case cCode == "-4"
		cErr:="Zauzet port"
	case cCode == "-3"
		cErr:="Ne postoji port"
	case cCode == "-2"
		cErr:="Ne inicijalizovan port"
	case cCode == "-1"
		cErr:="No connection"
	case cCode == "1"
		cErr:="Nemogucnost izvrsenja operacije"
	case cCode == "2"
		cErr:="Nije definisan artikal"
	case cCode == "3"
		cErr:="Vrijednost KOLICINA * CIJENA je prevelika za racun"
	case cCode == "8"
		cErr:="Nepravilno unjeta vrijednost"
	case cCode == "20"
		cErr:="Podignuta glava stampaca"
	case cCode == "22"
		cErr:="Nema papira"
	case cCode == "47"
		cErr:="Nedostaje poreska stopa"
	case cCode == "50"
		cErr:="Nedovoljno na lageru"
	case cCode == "99"
		cErr:="Neobradjena greska: pozovite nas"
	case cCode == "100"
		cErr:="Nepravilan BARKOD"
	case cCode == "101"
		cErr:="Nepravilno formiran naziv artikla"
	case cCode == "102"
		cErr:="Nepravilno formirana cijena"
	case cCode == "103"
		cErr:="Nepravilno formirana poreska stopa"
	case cCode == "104"
		cErr:="Nepravilno formirano odjeljenje"
	case cCode == "105"
		cErr:="Nepravilno formirana jedinica mjere"
	case cCode == "106"
		cErr:="Nepravilan format kolicine"
	case cCode == "108"
		cErr:="Dosegnut max.broj programiranih artikala"
	case cCode == "109"
		cErr:="Greska pri brisanju"
	case cCode == "110"
		cErr:="Za izvrsenje operacije mora se uraditi dnevni izvjestaj"
	case cCode == "112"
		cErr:="Greska na stampacu, podignuta glava, nema papira..."
endcase


return cErr
*}



/*! \fn CheckFisCTTStarted()
 *  \brief Centralna funkcija za provjeru FisCTT, da li je vec pokrenut
 */

function CheckFisCTTStarted()
*{

bFisStarted:=.t.

bFisStarted:=IsFisCTTStarted()
if !bFisStarted
	StartFisCTTInterface(gFisCTTPath)
endif

return
*}



/*! \fn IsFisCTTStarted()
 *  \brief Provjerava da li je FisCTT startovan
 */
function IsFisCTTStarted()
*{

cPath:=gFisCTTPath
bRet:=.t.

WriteMainInCode("0", cPath)
Sleep(gFisTimeOut)

cReadCode:=ReadMainInCode(cPath)

if cReadCode != "9"
	bRet:=.f.
endif

return bRet
*}


/*! \fn IsFisError()
 *  \brief Provjerava da li postoji greska poslije zadavanja komande i obradjuje je 
 */
function IsFisError()
*{
bRet:=.f.
cLastErr:=ReadMainOutCode(gFisCTTPath)

if (cLastErr <> "0")
	
	// ako postoji greska, obradi gresku
	cErrDescr:=GetErrFromCode(cLastErr)
	MsgBeep(cErrDescr)
	
	if cLastErr == "2"
		// put some code here
		// CorrectErr2()
	elseif cLastErr == "3"
		// put some code here
		// CorrectErr3()
	else
		// zavrsi funkciju
		bErr:=.t.
		return bErr
	endif
endif

return bRet
*}



/*! \fn RunFisCommand(cCode)
 *  \brief Zadaje komandu interfejsu
 *  \cCode - "kod" komande
 */

function RunFisCommand(cCode)
*{

cCode:=ALLTRIM(cCode)

// upisuju se kodovi od "0" do "9"

if (LEN(cCode) > 1)
	MsgBeep("Greska: neispravna duzina kod-a!")
	return
endif

// setuj uvijek OUT na "999"
WriteMainOutCode(gFisCTTPath)

// upisi u IN kod cCode 
WriteMainInCode(cCode, gFisCTTPath)

// zaustavi izvrsenje aplikacije.
// interfejsu treba par sec. da sazvace komandu
sleep(gFisTimeOut)

return
*}



/*! \fn FisRacun(aArtikli, aArtRacun, nIznos, cTipPlacanja)
 *  \brief Glavna funkcija za stampu FISSTA racuna
 *  \param aArtikli - matrica sa artiklima
 *  \param aArtRacun - matrica sa stavkama racuna
 *  \param nIznos - ukupan iznos racuna
 *  \param cTipPlacanja - tip placanja (1, 2 ili 3)
 */

function FisRacun(aArtikli, aArtRacun, nIznos, cTipPlacanja)
*{

bErr:=.f.

// provjeri prvo da li je interfejs startan
CheckFisCTTStarted()

// upisi stavke u ARTIKLI.XML
WriteArtikliXml(aArtikli, gFisCTTPath)

// upisi stavke u ARTRACUN.XML
WriteArtRacunXml(aArtRacun, gFisCTTPath)

// upisi stavke u PLACANJA.XML
WritePlacanjaXml(nIznos, cTipPlacanja, gFisCTTPath)

// sada smo spremni za izdavanje racuna

// pokreni komandu 1: artikli.xml => CPU
RunFisCommand("1")

if IsFisError()
	bErr:=.t.
	return bErr
endif

// pokreni komandu 8: artikli.xml => FISSTA
RunFisCommand("8")

if IsFisError()
	bErr:=.t.
	return bErr
endif

// pokreni komandu 2: izdaj racun
RunFisCommand("2")

if IsFisError()
	bErr:=.t.
	return bErr
endif

return bErr
*}



/*! \fn FisNivelacija(aArtikli)
 *  \brief Glavna funkcija za nivelaciju cijena
 *  \param aArtikli - matrica sa artiklima
 */

function FisNivelacija(aArtikli)
*{

bErr:=.f.

// provjeri prvo da li je interfejs startan
CheckFisCTTStarted()

// upisi stavke u ARTIKLI.XML
WriteArtikliXml(aArtikli, gFisCTTPath)

// sada smo spremni za nivelaciju

// pokreni komandu 1: artikli.xml => CPU
RunFisCommand("1")

if IsFisError()
	bErr:=.t.
	return bErr
endif

// pokreni komandu 8: artikli.xml => FISSTA
RunFisCommand("8")

if IsFisError()
	bErr:=.t.
	return bErr
endif

return bErr
*}



/*! \fn FisRptDnevni()
 *  \brief Fiskalni dnevni izvjestaj
 */

function FisRptDnevni()
*{

bErr:=.f.

// provjeri prvo da li je interfejs startan
CheckFisCTTStarted()

// pokreni komandu 3: dnevni izvjestaj 
RunFisCommand("3")

if IsFisError()
	bErr:=.t.
	return bErr
endif

return bErr
*}



/*! \fn FisRptPeriod()
 *  \brief Fiskalni izvjestaj za period - presjek stanja
 */

function FisRptPeriod()
*{

bErr:=.f.

// provjeri prvo da li je interfejs startan
CheckFisCTTStarted()

// pokreni komandu 4: izvjestaj za period 
RunFisCommand("4")

if IsFisError()
	bErr:=.t.
	return bErr
endif

return bErr
*}



