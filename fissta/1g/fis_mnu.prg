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
	AADD(opc, "3. servisne funkcije              ")
	AADD(opcexe, {|| FisServ_Mnu() })
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
AADD(opc, "3. fiskalni izvjestaj presjek stanja ")
AADD(opcexe, {|| FormRptPresjek() })

Menu_Sc("frt")

return
*}


/*! \fn FisServ_Mnu()
 *  \brief Menij sa servisnim funkcijama
 */
function FisServ_Mnu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. ponistavanje racuna - nestalo papira    ")
AADD(opcexe, {|| FormRnErase() })

Menu_Sc("fsv")

return
*}



