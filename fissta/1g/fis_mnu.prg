#include "\dev\fmk\pos\pos.ch"


/*! \fn Fissta_mnu()
 *  \brief Menij za rad sa FISSTA
 */
function Fissta_mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fiskalni izvjestaji               ")
AADD(opcexe, {|| FisRpt_Mnu() })
AADD(opc, "2. startanje interfejsa FisCTT    ")
AADD(opcexe, {|| CheckFisCTTStarted() })
AADD(opc, "3. testovi    ")
AADD(opcexe, {|| FisTests() })

Menu_Sc("fst")

return
*}



/*! \fn FisRpt_Mnu()
 *  \brief Menij sa fiskalnim izvjestajima
 */
function FisRpt_Mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fiskalni dnevni izvjestaj         ")
AADD(opcexe, {|| FisRptDnevni() })
AADD(opc, "2. fiskalni izvjestaj za period      ")
AADD(opcexe, {|| FisRptPeriod() })

Menu_Sc("frt")

return
*}



/*! \fn FisTests()
 *  \brief Menij sa testovima
 */
function FisTests()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. racun         ")
AADD(opcexe, {|| TestFisRn3() })

Menu_Sc("fts")

return
*}

