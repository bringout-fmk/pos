#include "\dev\fmk\pos\pos.ch"


/*! \fn Fissta_mnu()
 *  \brief Menij za rad sa FISSTA
 */
function Fissta_mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. startanje interfejsa FisCTT    ")
AADD(opcexe, {|| CheckFisCTTStarted() })

if kLevel<>L_PRODAVAC
	AADD(opc, "2. fiskalni izvjestaji               ")
	AADD(opcexe, {|| FisRpt_Mnu() })
endif

if gnDebug==5
	AADD(opc, "3. test case    ")
	AADD(opcexe, {|| FisTest_mnu() })
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




