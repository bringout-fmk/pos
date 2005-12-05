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

/*! \fn IntegTekGod() 
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




