#include "\dev\fmk\pos\pos.ch"


/*! \fn GetTKParams()
 *  \brief Parametri izvjestaja
 */
function GetTKParams()
*{
cIdPos:=gIdPos
O_PARAMS
private cSection:="I"
private cHistory:="K"
private aHistory:={}
RPar("d1",@cDat0)
RPar("d2",@cDat1)

set cursor on
Box(,2,60)
	@ m_x+1,m_y+2 SAY "Prod.mjesto (prazno-svi) "  GET  cIdPos  valid empty(cIdPos).or.P_Kase(cIdPos) pict "@!"
	@ m_x+2,m_y+2 SAY "za period " GET cDat0
	@ m_x+2,col()+2 SAY "do " GET cDat1
	read
	if LastKey()==K_ESC
		BoxC()
		return .f.
	endif
	ESC_BCR
	SELECT params
	WPar("d1",cDat0)
	WPar("d2",cDat1)
	SELECT params
	use
BoxC()

return .t.
*}



/*! \fn RptTK()
  * \brief Izvjestaj: trgovacka knjiga
  */
function RptTK()
*{
private cDat0:=gDatum
private cDat1:=gDatum
private cIdPos

// open TK db
O_TK_DB()
// Get params 
if !GetTKParams()
	return
endif

START PRINT CRET

ZagFirma()

? PADC("-----------------------------------",30)
? PADC("TRGOVACKA KNJIGA NA DAN "+FormDat1(gDatum),30)
? PADC("-----------------------------------",30)

if empty(cIdPos)
	? "PROD.MJESTO: "+cIdPos+"-"+"SVE"
else
	? "PROD.MJESTO: "+cIdPos+"-"+Ocitaj(F_KASE,cIdPos,"Naz")
endif

? "PERIOD     : "+FormDat1(cDat0)+" - "+FormDat1(cDat1)
?
? "-------- -------------------- ------------------------- ---------------------"
? "* Datum *  Opis knjizenja    *         Iznos           *   Upl.na ziro rn.  *"
? "*       *                    *   Zaduz.   *   Razduz.  * Datum  *   Iznos   *"
? "-------- -------------------- ------------ ------------ -------- ------------"
GetTKRows()

PaperFeed()

END PRINT
CLOSERET
return
*}



/*! \fn GetTkRows()
 *  \brief Daje podatke za Trgovacku Knjigu
 */
function GetTkRows()
*{
O_DOKS
select doks
set order to tag "TK" // idpos+DTOS(datum)+idvd

nIznZad:=0
nIznRGot:=0
nIznRCek:=0
dTekDate:=CToD("")
nUkZad:=nUUkZad:=0
nUkRaz:=nUUkRaz:=0
nUkPol:=nUUkPol:=0

altd()
do while !eof() .and. idpos==cIdPos
	dDatum:=doks->datum
	if (dDatum == cDat0)
		altd()
	endif
	// ako se datum ne slaze, idi dalje
	if ((dDatum < cDat0) .or. (dDatum > cDat1))
		skip
		loop
	endif
	// ako je rijec o poc.stanju idi dalje
	if (field->idvd $ "00#01")
		skip
		loop
	endif
	
	if (field->idvd $ "16#42") .and. (dTekDate <> dDatum)
		PrintDateRow(dDatum)
		dTekDate:=dDatum
		nUkRaz:=nUkZad:=nUkPol:=0
		
		// daj podatke o pologu
		private nPlgGot:=0
		private nPlgCek:=0
		private dPlg:=CToD("")
		GetPlgData(@nPlgGot, @nPlgCek, @dPlg, dDatum)
	endif
	
	if (field->idvd=="16") // zaduzenja
		do while !EOF() .and. field->datum=dDatum .and. field->idvd="16"
			nIznZad:=VAL(DokIznos())
			cZadNaz:="KALK: 16-" + ALLTRIM(doks->brdok)
			nUkZad+=nIznZad
			PrintTkRow(dDatum, cZadNaz, nIznZad, 0, 0)
			skip
		enddo
		dTekDate:=dDatum
		
	elseif (field->idvd=="42") // racuni
		nIznRGot:=0
		nIznRCek:=0
		do while !EOF() .and. field->datum=dDatum .and. field->idvd="42"
			if field->idvrstep=="01"
				nIznRGot+=VAL(DokIznos())
			elseif field->idvrstep=="CK"
				nIznRCek+=VAL(DokIznos())
			endif
			skip
		enddo
		if (nIznRGot > 0)
			PrintTkRow(dDatum, "Dnev.pazar gotovina", 0, nIznRGot, nPlgGot, dPlg)
		endif
		if (nIznRCek > 0)
			PrintTkRow(dDatum, "Dnev.pazar cekovi", 0, nIznRCek, nPlgCek, dPlg)
		endif
		nUkRaz+=nIznRGot+nIznRCek
		nUkPol:=nPlgCek+nPlgGot
		dTekDate:=dDatum
		
	else // sve ostalo preskaci
		skip
		loop
	endif

	nUUkZad+=nUkZad
	nUUkRaz+=nUkRaz
	nUUkPol+=nUkPol
enddo

PrintUkupno(nUUkZad, nUUkRaz, nUUkPol)

return
*}


/*! \fn PrintDateRow(dDate)
 *  \brief Printa zaglavlje sa datumom
 *  \param dDate - datum
 */
function PrintDateRow(dDate)
*{
?
? "Lista za datum: " + DToC(dDate)
return
*}



/*! \fn PrintUkupno(nZad, nRaz, nPolog)
 *  \brief Stampa ukupno
 *  \param nZad - iznos zaduzuje
 *  \param nRaz - iznos razduzuje
 *  \param nPolog - iznos polog
 */
function PrintUkupno(nZad, nRaz, nPolog)
*{
if (nZad+nRaz+nPolog == 0)
	return
endif
? REPLICATE("-", 77)

? PADR("UKUPNO:", 30) 
?? STR(nZad, 12, 2)
?? SPACE(1)
?? STR(nRaz, 12, 2)
?? SPACE(10)
?? STR(nPolog, 12, 2)

? REPLICATE("-", 77)
return
*}



/*! \fn PrintTkRow(dDate, cText, nZad, nRaz, nUpl, dUpl)
 *  \brief Printanje reda trgovacke knjige
 *  \param dDate - datum transakcije
 *  \param cText - opis transakcije
 *  \param nZad - iznos zaduzenja
 *  \param nRaz - iznos razduzenja
 *  \param nUpl - iznos pologa
 *  \param dUpl - datum pologa
 */
function PrintTkRow(dDate, cText, nZad, nRaz, nUpl, dUpl)
*{

? DToC(dDate)
?? SPACE(1)
?? PADR(cText, 20)
?? SPACE(1)
?? STR(nZad, 12, 2)
?? SPACE(1)
?? STR(nRaz, 12, 2)
if dUpl <> nil
	?? SPACE(1)
	?? DToC(dUpl)
else
	?? SPACE(9)
endif
if (nUpl>0)
	?? SPACE(1)
	?? STR(nUpl, 12, 2)
endif

return
*}


