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

if gnDebug==5
	AADD(opc, "3. testovi    ")
	AADD(opcexe, {|| FisTests() })
endif

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
AADD(opcexe, {|| FormRptDnevni() })
AADD(opc, "2. fiskalni izvjestaj za period      ")
AADD(opcexe, {|| FormRptPeriod() })

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

AADD(opc, "1. racun                          ")
AADD(opcexe, {|| TestFisRn3() })

AADD(opc, "2. fiskalni dnevni izvjestaj      ")
AADD(opcexe, {|| TestRptDn1() })

AADD(opc, "3. fiskalni izvjestaj za period   ")
AADD(opcexe, {|| TestRptPer1() })

AADD(opc, "4. fiskalni dnevni izvjestaj EVID ")
AADD(opcexe, {|| TestRptDn2() })

Menu_Sc("fts")

return
*}

