#include "\dev\fmk\pos\pos.ch"


/*! \fn Mnu_TK()
 *  \brief meni trgovacka knjiga
 */
function Mnu_TK()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. unos pologa pazara           ")
AADD(opcexe,{|| FrmPolPaz() })
AADD(opc,"2. stampa trgovacke knjige")
AADD(opcexe,{|| RptTK() })

Menu_SC("tk")

return
*}


/*! \fn FrmPolPaz()
 *  \brief Forma za unos pologa pazara
 */
function FrmPolPaz()
*{
local dDatPol:=DATE()-1
local nIznGot:=0
local nIznCek:=0
local cBrDok //broj dokumenta pologa
local cValid:="N"
local cTimeDok //vrijeme dokumenta

Box(, 9, 60)
SET CURSOR ON
do while .t.
	@ 1+m_x, 2+m_y SAY "Unos podataka o pologu pazara:          " COLOR "I"
	@ 2+m_x, 2+m_y SAY "----------------------------------------"
	@ 3+m_x, 2+m_y SAY "Datum pologa  :" GET dDatPol VALID !EMPTY(dDatPol)
	@ 4+m_x, 2+m_y SAY "Polozi "
	@ 5+m_x, 2+m_y SAY "      gotovina:" GET nIznGot VALID !EMPTY(nIznGot) PICT "999999.99"
	@ 6+m_x, 2+m_y SAY "        cekovi:" GET nIznCek VALID !EMPTY(nIznCek) PICT "999999.99"
	read
	@ 7+m_x, 2+m_y SAY "Zbir pologa:" + STR(nIznGot+nIznCek, 12, 2)
	@ 9+m_x, 2+m_y SAY "Ispravno (D/N)?" GET cValid PICT "@!" VALID cValid$"DN"
	read
	if cValid=="D"
		exit
	endif
	if LastKey()==K_ESC
		BoxC()
		return
	endif
	
enddo
BoxC()

if PostojiDokument("88", dDatPol)
	MsgBeep("Postoji vec dokument na dan " + DToC(dDatPol)) 
	return	
endif
if LastKey()==K_ESC
	MsgBeep("Polog nece biti evidentiran!")
	return
endif

if (nIznGot < 0) .or. (nIznCek < 0)
	MsgBeep("Polog ne moze biti u negativnom iznosu!")
	return
endif

O_DOKS
O_POS

MsgO("Azuriram dokument pologa...")
cBrDok:=NarBrDok(gIdPos, VD_PP)
cTimeDok:=TIME()

// Azuriraj stavku u DOKS
AzurDoksDokument(VD_PP, gIdPos, cBrDok, cTimeDok, dDatPol)
// Azuriraj stavke u POS
AzurPosDokument(VD_PP, 1, 1, cBrDok, gIdPos, "", nIznGot, nIznCek, 0, dDatPol)
MsgC()

return
*}


/*! \fn StDokPP()
 *  \brief Stampa dokumenta Polog pazara
 */
function StDokPP()
*{
local nArr
nArr:=SELECT()

// Selektuj stavke dokumenta
select pos
// idpos+idvd+brdok+iddio+idodj
set order to tag "1"
hseek doks->(IdPos+IdVd+DToS(datum)+BrDok)

START PRINT CRET

? REPLICATE("-", 25)
? "Polog pazara na dan,", DATE()
? REPLICATE("-", 25)
?
? "Dokument broj: ", VD_PP + "-" + ALLTRIM(doks->brdok)
?
? "Datum pologa:", doks->datum
?
? "Polozi:"
? "---------------------------"
? "GOTOVINA   :", pos->cijena
? "CEK        :", pos->ncijena
? "---------------------------"
? "UKUPNO     :", pos->cijena + pos->ncijena + pos->kolicina
?
?
FF
END PRINT

SELECT (nArr)

return
*}


/*! \fn GetPlgData(nPlgGot, nPlgCek, dPlg, dTekDate)
 *  \brief Daje podatke o pologu pazara za datum
 *  \param nPlgGot
 *  \param nPlgCek
 *  \param dPlg
 *  \param dTekDate - datum za koji se pretrazuje
 */
function GetPlgData(nPlgGot, nPlgCek, dPlg, dTekDate)
*{
local nTRec
altd()
nTRec:=RecNO()
seek gIdPos+DToS(dTekDate)+VD_PP

select pos
set order to tag "1"
hseek doks->(IdPos+IdVd+DToS(Datum)+BrDok)

if (pos->idvd==VD_PP)
	nPlgGot:=pos->cijena
	nPlgCek:=pos->ncijena
	dPlg:=datum
endif

select doks
go nTRec

return
*}



/*! \fn GetCkData(n1, n2)
 *  \brief Daje podatke o cekovima
 *  \param n1
 *  \param n2
 */
function GetCkData(n1, n2)
*{
local nTRec
altd()
nTRec:=RecNO()

select pos
set order to tag "7"
hseek doks->(IdPos+VD_CK+BrDok+" 2")

do while !EOF() .and. pos->idodj=" 2"
	if pos->iddio == " 2"
		n1:=pos->ncijena
	else
		n2+=pos->ncijena
	endif
	skip
enddo
// vrati index
set order to tag "1"

select doks
go nTRec

return
*}

