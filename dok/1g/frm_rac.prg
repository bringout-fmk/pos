#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/frm_rac.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.12 $
 * $Log: frm_rac.prg,v $
 * Revision 1.12  2003/07/09 06:21:40  mirsad
 * ispravka bug-a na pregledu racuna nakon uvodjenja uslova za PM- filter mora uvijek obuhvatati i "X "
 *
 * Revision 1.11  2003/07/05 11:27:43  mirsad
 * uveo uslov za prodajno mjesto pri pozivu pregleda racuna
 *
 * Revision 1.10  2003/04/24 20:45:02  mirsad
 * prenos TOPS->FAKT
 *
 * Revision 1.9  2002/07/08 23:03:55  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.8  2002/07/06 08:13:34  ernad
 *
 *
 * - uveden parametar PrivPath/POS/Slave koji se stavi D za kasu kod koje ne zelimo ScanDb
 * Takodje je za gVrstaRs="S" ukinuto scaniranje baza
 *
 * - debug ispravke racuna (ukinute funkcije PostaviSpec, SiniSpec, zamjenjene sa SetSpec*, UnSetSpec*)
 *
 * Revision 1.7  2002/06/25 10:56:10  sasa
 * no message
 *
 * Revision 1.6  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.5  2002/06/17 13:11:43  sasa
 * no message
 *
 * Revision 1.4  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */

/*! \file fmk/pos/dok/1g/frm_rac.prg
 *  \brief Izdavanje racuna
 */

/*! \fn PRacuni(dDat, cBroj, fPrep, fScope, cPrefixFilter, qIdRoba)
 *  \brief Pregled racuna 
 *  \param dDat
 *  \param cBroj
 *  \param fPrep
 *  \param fScope
 *  \param cPrefixFilter - filter (iskaz ispred " IdVd=='42'")
 *  \param qIdRoba
 *  \return
 */

function PRacuni(dDat, cBroj, fPrep, fScope, cPrefixFilter, qIdRoba)
*{
private fMark:=.f.
private cFilter

if cPrefixFilter==NIL
	cPrefixFilter:=""
endif
cFilter:=cPrefixFilter+" IdVd=='42'"
if fPrep==nil
	fPrep:=.f.
else
	fPrep:=fPrep
endif

if cBroj==nil
	cRacun:=SPACE(LEN(POS->BrDok))
else
	cRacun:=ALLTRIM(cBroj)
endif

cIdPos:=LEFT(cRacun,AT("-",cRacun)-1)
cIdPos:=PADR(cIdPOS,LEN(gIdPos))

if gVrstaRS<>"S".and.!EMPTY(cIdPos).and.cIdPOS<>gIdPos
	MsgBeep("Racun nije napravljen na ovoj kasi!#"+"Ne mozete napraviti promjenu!",20)
  	return (.f.)
endif

cBroj:=RIGHT(cRacun,LEN(cRacun)-AT("-",cRacun))
cBroj:=PADL(cBroj,6)

ImeKol:={{ "Broj racuna",{|| padr(trim(IdPos)+"-"+alltrim(BrDok),9)}},{ "Iznos",{|| STR (SR_Iznos(), 13, 2)}},{ "Smj",{|| smjena}      },{ "Datum",{|| datum}},{ "Vr.Pl",      {|| idvrstep} },{ "Partner",    {|| idgost} },{ "Vrijeme",    {|| vrijeme} }}

if IsTigra()
	AADD(ImeKol,{ "Placanje", {|| IIF(Placen<>"Z","GOTOVINA","ziralno ")} })
else
	AADD(ImeKol,{ "Placen",     {|| IIF (Placen==PLAC_NIJE,"  NE","  DA")} })
endif

if kLevel<=L_UPRAVN
	Kol:={1,2,3,4,5,6,7,8}
else
	Kol:={1,2,3,4,5,6,7}
endif

SELECT DOKS

if fScope=nil
	fScope:=.t.
endif


if fScope
	SET SCOPEBOTTOM TO "W"
endif

altd()
if gVrstaRS=="S".or.KLevel<L_UPRAVN
	AADD(ImeKol,{"Radnik",{|| IdRadnik}})
	AADD(Kol, LEN(ImeKol))
	cFilter+=".and. (Idpos="+cm2str(gIdPos)+" .or. IdPos='X ')"
else
	cFilter+=".and. IdRadnik="+cm2str(gIdRadnik)+".and. Idpos="+cm2str(gIdPos)
endif

if kLevel==L_PRODAVAC
	cFilter+='.and. Datum='+cm2str(dDat)
endif

if qIdRoba<>nil.and.!EMPTY(qIdRoba)
	cFilter+=".and. SR_ImaRobu(IdPos+IdVd+dtos(datum)+BrDok,"+cm2str(qIdRoba)+")"
endif

SET FILTER TO &cFilter

if !EMPTY(cBroj)
	SEEK2(cIdPos+"42"+dtos(dDat)+cBroj)
  	if FOUND()
    		cBroj:=ALLTRIM(doks->IdPos)+"-"+ALLTRIM(doks->BrDok)
    		dDat:=doks->datum
    		return(.t.)
  	endif
else
	GO BOTTOM
endif

if fPrep
	cFnc:="<Enter>-Odabir   <+>-Markiraj/Demarkiraj   <P>-Pregled"
  	fMark:=.t.
  	// ako je prepis, aVezani je privatna varijabla funkcije <PrepisRacuna>
  	bMarkF:={|| RacObilj ()}
else
  	cFnc:="<Enter>-Odabir          <P>-Pregled"
  	bMarkF:=NIL
endif

if IsTigra()
	ObjDBedit( , 20, 77, {|| EdPRacuni(fMark) },IIF(gRadniRac=="D", "  STALNI ","  ")+"RACUNI    G-gotovina/Z-ziralno ", "", .F.,cFnc,,bMarkF)
else
	ObjDBedit( , 20, 65, {|| EdPRacuni(fMark) },IIF(gRadniRac=="D", "  STALNI ","  ")+"RACUNI  ", "", .F.,cFnc,,bMarkF)
endif

SET FILTER TO

cBroj:=ALLTRIM(DOKS->IdPos)+"-"+AllTrim (DOKS->BrDok)

if cBroj='-'  // nema racuna
	cBroj:=SPACE(9)
endif

dDat:=doks->datum

if LASTKEY()==K_ESC
	return(.f.)
endif

return(.t.)
*}


/*! \fn EdPRacuni()
 *  \brief Ispravka 
 */

function EdPRacuni()
*{

//                   1            2               3              4
// aVezani : {DOKS->IdPos, DOKS->(BrDok), DOKS->IdVrsteP, DOKS->Datum})

local cLevel
local ii
local nTrec
local nTrec2

// M->Ch je iz OBJDB, fMark je iz PRacuni
if M->Ch==0
	return (DE_CONT)
endif
if (LASTKEY()==K_ESC).or.(LASTKEY()==K_ENTER )
	return (DE_ABORT)

endif

O_STRAD
select strad
hseek gStrad
cLevel:=prioritet
use
select doks

if fMark .and. (LastKey()==Asc("+"))
	nPos := ASCAN (aVezani, {|x| (x[1]+dtos(x[4])+x[2])==DOKS->(IdPos+dtos(datum)+BrDok)})
  	if nPos == 0
    		if LEN(aVezani)==0 .or.(aVezani[1][3]==DOKS->IdVrsteP .and. aVezani[1][4]==DOKS->Datum)
      			AADD (aVezani, {DOKS->IdPos, DOKS->(BrDok), DOKS->IdVrsteP, DOKS->Datum})
    		elseif aVezani[1][3]<>DOKS->IdVrsteP
      			MsgBeep ("Nemoguce spajanje!#Nacin placanja nije isti!")
    		elseif aVezani[1][4]<>DOKS->Datum
      			MsgBeep ("Nemoguce spajanje!#Datum racuna nije isti!")
   		endif
  	else
    		ADEL(aVezani, nPos)
    		ASIZE(aVezani, LEN (aVezani)-1)
  	endif
  	
	return DE_REFRESH
endif

if IsTigra()
	if UPPER(CHR(LASTKEY()))=="Z"
		replace placen with "Z"
		return DE_REFRESH
	elseif UPPER(CHR(LASTKEY()))=="G"
		replace placen with "G"
		return DE_REFRESH
	endif
endif

if UPPER(CHR(LASTKEY()))=="P"
	PreglSRacun(DOKS->IdPos,doks->datum,DOKS->BrDok)
  	return DE_REFRESH
endif

cLast:=UPPER(CHR(LASTKEY()))
if KLevel="0".and.(cLast=="D".or.cLast == "S" .or. cLast=="V" )
	if Pitanje(,"Ispraviti vrijeme racuna ?","N")=="D"
       		dOrigD:=Datum
       		dDatum:=Datum
       		cVrijeme:=Vrijeme
		cIBroj:="N"
		nNBrDok:=0
		set cursor on
       		Box(,5,60)
        	if cLast $ "SV"
          		@ m_x+1,m_y+2 say "     Vrijeme" get cVrijeme
        	endif
        	if cLast $ "DV"
          		@ m_x+2,m_y+2 say "Datum racuna" get dDatum
        	endif
        	
          	@ m_x+3, m_y+2 say "Ispravka broja D/N" get cIBroj PICT "@!"
		READ

		if cIBroj=="D"
			@ m_x+5, m_y+2 SAY "Novi broj" GET nNBrDok PICT "999999"
			READ
			cNBrDok:=PADL(ALLTRIM(STR(nNBrDok)),6)
		else
			cNBrDok:=nil
		endif
       		BoxC()
		if (LASTKEY()==K_ESC)
			return DE_CONT
		endif
       		if dOrigD<>dDatum .and. lastkey()!=K_ESC
		        IspraviDV(cLast, dOrigD, dDatum, cVrijeme, cNBrDok)
       		endif 
    	endif 

    	return DE_REFRESH
endif


if cLevel<="0"   
	// samo sistem administrator
	if ch==K_F1
    		MSgBeep("F5 - promjeni id racuna na X#"+"F2 - promjena broja za X pmjesto#"+"Ctrl-F9  - brisi fizicki#"+"Shift-F9 - brisi fizicki period")
    		return DE_CONT
  	endif
  	if ch==K_CTRL_F9
    		return BrisiRacun()
  	endif
	if ch==K_F2
      		return PromBrRN()
  	endif
  	if ch==K_SH_F9
      		return  BrisiRNVP()
  	endif
  	if ch==K_F5
       		return PromIdPM()
  	endif
  	if ch==K_CTRL_F5
    		return PromIdPMVP()
  	endif
endif // KLEVEL - vlasnik
return (DE_CONT)
*}



/*! \fn SR_Iznos()
 *  \brief Daje iznos racuna
 */
 
function SR_Iznos()
*{

nIznos:=0
SELECT POS
Seek2(DOKS->(IdPos+IdVd+dtos(datum)+BrDok))
while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
	nIznos+=POS->(Kolicina * Cijena)
  	SKIP
end
SELECT DOKS
return (nIznos)
*}


/*! \fn BrisiRacun()
 *  \brief Brisanje racuna
 */
function BrisiRacun()
*{

if Pitanje(,"Potpuno - fizicki izbrisati racun?","N")=="N"
	return DE_CONT
endif

SELECT DOKS
cBrojR:=DOKS->BrDok
cIdPos:=DOKS->IdPos
cDatum:=dtos(doks->datum)

if empty(dMinDatProm)
	dMinDatProm:=DOKS->datum
else
        dMinDatProm:=min(dMinDatProm,DOKS->datum)
endif

SELECT POS
set order to 1
Seek cIdPos+VD_RN+cDatum+cBrojR

// DOKS
do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+VD_RN+cDatum+cBrojR)
	skip
	nTTR:=recno()
	skip -1
        delete       
        sql_azur(.t.)
        sql_delete()
        go nTTR
enddo

SELECT DOKS
// DOKS
delete      
sql_azur(.t.)
sql_delete()

return (DE_REFRESH)
*}


