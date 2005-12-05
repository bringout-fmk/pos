#include "\dev\fmk\pos\pos.ch"

/*! \fn GetKalkVars(cFirma, cKonto, cPath)
 *  \brief Vraca osnovne var.za rad sa kalk-om
 *  \param cFirma - id firma kalk
 *  \param cKonto - konto prodavnice u kalk-u
 *  \param cPath - putanja do kalk.dbf
 */
function GetKalkVars(cFirma, cKonto, cPath)
*{
// firma je uvijek 50
cFirma:="50"
// konto prodavnicki
cKonto := IzFmkIni("TOPS", "TopsKalkKonto", "13270", PRIVPATH)
cKonto := PADR(cKPKonto, 7)
// putanja
cPath := IzFmkIni("TOPS", "KalkKumPath", "i:\sigma", PRIVPATH)
return
*}


/*! \fn OpenKalkDBF(cPath)
 *  \brief otvara tabelu kalk
 *  \param cPath - putanja do kalk.dbf
 */
function OpenKalkDB(cPath)
*{
// zakaci se na kalk
SELECT (F_KALK)
USE (cPath + SLASH + "kalk")
// postavi order "4"
set order to tag "4"

return
*}


/*! \fn IntegTekGod()
 *  \brief Vraca tekucu godinu, ako je tek.datum veci od 10.01.TG onda je godina = TG, ako je tek.datum <= 10.01.TG onda je godina (TG - 1)
 *  \return string cYear
 */
function IntegTekGod()
*{
local dTDate
local dPDate
local dTYear
local cYear

dTYear := YEAR(DATE()) // tekuca godina
dPDate := SToD(ALLTRIM(STR(dTYear))+"0110") // preracunati datum
dTDate := DATE() // tekuci datum

if dTDate > dPDate
	cYear := ALLTRIM( STR( YEAR( DATE() ) ))	
else
	cYear := ALLTRIM( STR( YEAR( DATE() ) - 1 ))
endif

return cYear
*}

/*! \fn IntegTekDat() 
 *  \brief Vraca datum od kada pocinje tekuca godina TOPS, 01.01.TG
 */
function IntegTekDat()
*{
local dYear
local cDate

dYear := YEAR(DATE())
cDate := ALLTRIM( IntegTekGod() ) + "0101"

return SToD(cDate)
*}

/*! \fn AddToErrors(cType, cIdRoba, cDoks, cOpis)
 *  \brief dodaj zapis u tabelu errors
 */
function AddToErrors(cType, cIDroba, cDoks, cOpis)
*{
O_ERRORS
append blank
replace field->type with cType
replace field->idroba with cIdRoba
replace field->doks with cDoks
replace field->opis with cOpis

return
*}


/*! \fn GetRobaCnt(cIdRoba)
 *  \brief Vraca broj sifara robe u sifrarniku robe
 *  \param cIdRoba - trazeni artikal
 */
function GetRobaCnt(cIdRoba)
*{
select roba
hseek cIdRoba
nRet:=0
do while !EOF() .and. field->id == cIdRoba
	++ nRet
	skip
enddo

return nRet
*}

/*! \fn GetErrorDesc(cType)
 *  \brief Vrati naziv greske po cType
 *  \param cType - tip greske, C, W, N ...
 */
function GetErrorDesc(cType)
*{
cRet := ""
do case
	case cType == "C"
		cRet := "Critical"
	case cType == "N"
		cRet := "Normal"
	case cType == "W"
		cRet := "Warrning"
endcase

return cRet
*}

/*! \fn RptInteg()
 *  \brief report nakon testa integ1
 */
function RptInteg()
*{
O_ERRORS
select errors
set order to tag "1"
if RecCount() == 0
	MsgBeep("Integritet podataka ok")
	return
endif

lOnlyCrit:=.f.
if Pitanje(,"Prikazati samo critical errors (D/N)?","N")=="D"
	lOnlyCrit:=.t.
endif

START PRINT CRET

? "Rezultati analize integriteta podataka"
? "===================================================="
?

nCrit:=0
nNorm:=0
nWarr:=0
nCnt:=1

go top
do while !EOF()
	cErRoba := field->idroba
	if lOnlyCrit .and. ALLTRIM(field->type) == "C"
		? STR(nCnt, 4) + ". " + ALLTRIM(field->idroba)
	endif
	if !lOnlyCrit
		? STR(nCnt, 4) + ". " + ALLTRIM(field->idroba)
	endif
	
	do while !EOF() .and. field->idroba == cErRoba
		
		if lOnlyCrit .and. ALLTRIM(field->type) <> "C"
			skip
			loop
		endif
		
		++nCnt
		
		? SPACE(5) + GetErrorDesc(ALLTRIM(field->type)), ALLTRIM(field->doks), ALLTRIM(field->opis)	
	
		if ALLTRIM(field->type) == "C"
			++ nCrit 
		endif
		if ALLTRIM(field->type) == "N"
			++ nNorm 
		endif
		if ALLTRIM(field->type) == "W"
			++ nWarr 
		endif
		skip
	enddo
enddo

?
? "-----------------------------------------"
? "Critical errors:", ALLTRIM(STR(nCrit))
? "Normal errors:", ALLTRIM(STR(nNorm))
? "Warrnings:", ALLTRIM(STR(nWarr))
?
?

FF
END PRINT

return
*}


