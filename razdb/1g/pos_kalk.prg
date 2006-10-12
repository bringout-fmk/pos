#include "\dev\fmk\pos\pos.ch"

*string 
static cIdPos
*;

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

//
// TOPSKA - datoteka koja se formira prilikom generacije iz (H)TOPS-a
//          realizacije POS -> KALK

// KATOPS - datoteka koja se formira prilikom prenosa iz KALKA u
//          (H)TOPS
//

/*! \fn Kalk2Pos(cIdVd, cBrDok, cRSDbf)
 *  \brief Prenos realizacije iz KALK-a u POS
 *  \param cIdVd   - tip dokumenta, f-ja ga mjenja ako prodje kroz prenos sa diskete
 *  \param cBrDok  - f-ja ga mjenja tako sto ga puni izgenerisanim dokumentom
 *  \param cRSDbf  - ROBA ili SIROV zavisno od nacina zaduzenja odjeljenja
 */
 
function Kalk2Pos(cIdVd, cBrDok, cRSDbf)
*{
local cPrefix
local Izb3
local OpcF
local cTxt 
local cZadValid 
local cInvValid 
local cNivValid
local cOtpValid
local cKalkDestinacija
local fRet:=.f.
local cPM
local cKalkDBF:=""
private H

cIdPos:=gIdPos
cPm:=SPACE(2)

cBrDok:=SPACE(LEN(field->brDok))

fPrenesi:=.f.
cOtpValid:="95"

if gModul=="HOPS"
	cZadValid:="10#16#11#12#13#80#81"
	cOtpValid:="95"
	cInvValid:="IM#IP"
	cNivValid:="18#19"
else
	cZadValid:="11#12#13#80#81"
	cInvValid:="IP"
	cNivValid:="19"
endif

cKalkDestinacija:=gKalkDest

SET CURSOR ON
O_PRIPRZ

cBrDok:=SPACE(LEN(field->brdok))

if priprz->(RecCount2())==0 .and. Pitanje( ,"Preuzeti dokumente iz KALK-a","N")=="D"
	
	if !SelectKalkDbf(cBrDok, @cKalkDestinacija, @cKalkDbf)
		return .f.
	endif

	USEX (cKalkDbf) NEW alias KATOPS

    	if katops->idvd $ "11#80#81"  
		// radi se o zaduzenju koje se ovdje biljezi sa 16
      		cIdVd:="16"
		
    	elseif katops->idvd=="19"
      		cIdVd:="NI"
		
    	elseif katops->idvd=="IP"
      		cIdVd:="16"
    	endif
	
    	SELECT doks
    	set order to 1
	
        cBrDok:=NarBrDok(cIdPos, cIdVd)
	
	select katops
    	MsgO("kalk -> priprema, update roba")

	do while !eof()
     		if (katops->idPos==cIdPos)
			if (AzurRow(cIdVd, cBrDok, cRsDbf)==0)
				exit
			endif
      		endif
      		select katops
      		skip
    	enddo
	MsgC()

    	// azuriraj i DOKSRC....
	select katops
	go top
	
	add_p_doksrc(gIdPos, cIdVd, cBrDok, gDatum, "KALK", ;
		katops->idfirma, katops->idvd, katops->brdok, ;
		katops->datdok, katops->idkonto, katops->idkonto2, ;
		katops->idpartner, "Zaduzenje")
	
	if (gModemVeza=="N")
     		select katops
		use
    	endif

endif // prenos sa disketa

// kopiraj u chk
if ( gModemVeza=="D" .and. fPrenesi )
	if ( gUseChkDir == "D" )
		select katops
		use
    		DirMak2(strtran(trim(cKalkDestinacija),":"+SLASH,":"+SLASH+"chk"+SLASH))
    		copy file (cKalkDbf) TO (strtran(cKalkDbf,":"+SLASH,":"+SLASH+"chk"+SLASH))
    		// odradjeno-postavi kopiraj u chk direktorij
    		// npr c:\tops\prenos\2\x.dbf  -> npr c:\CHK\tops\prenos\2\x.dbf
	else
		// samo pobrisi fajl prenosa
		FileDelete(cKalkDbf)
		// i txt fajl
		FileDelete(strtran(cKalkDbf, ".DBF", ".TXT"))
	endif
endif

return .t.
*}


/*! \ingroup ini
 *  \var FmkIni_ExePath_POS_PrenosGetPm
 *  \param 0 - default ne uzimaj oznaku i ne pitaj nista
 *  \param N - ne uzimaj i postavi pitanje
 *  \param D - uzmi bez pitanja
 */
 
/*! \fn GetPm()
 *  \brief Uzmi oznaku prodajnog mjesta
 */
 
static function GetPm()
*{
local cPm
local cPitanje

cPm:=cIdPos

cPitanje:=IzFmkIni("POS","PrenosGetPm","0")
if ((gVrstaRs<>"S") .and. (cPitanje=="0"))
	return ""
endif


if (gVrstaRs=="S") .or. ((cPitanje=="D") .or. Pitanje(,"Postaviti oznaku prodajnog mjesta? (D/N)","N")=="D")
	Box(,1,30)
		SET CURSOR ON
		@ m_x+1,m_Y+2 SAY "Oznaka prodajnog mjesta:" GET cPm
		read
	BoxC()
endif
return cPm
*}

/*! \fn Pos2Pos(cIdVd, cBrDok, cRSDbf) 
 *  \brief Prenos realizacije iz POS u POS
 *  \param cIdVd
 *  \param cBrDok
 *  \param cRSDbf
 */

function Pos2Pos(cIdVd, cBrDok, cRSDbf)
*{

cIdPos:=gIdPos

//  Prenos dokumenta iz POS u POS
//  pos2 - datoteka prenosa

dDatum:=date()

cTops2:=padr("C:\TOPS\KUM2",25)
cCijene:="D"
Box(,3,60)
@ m_x+1,m_Y+2 SAY "Datum:" GET dDatum
@ m_x+2,m_Y+2 SAY "TOPS 2:" GET cTops2
@ m_x+3,m_y+2 SAY "Cijene iz tops 2 (D/N):" GET cCijene
read
BoxC()
select pos
//"1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena", KUMPATH+"POS")
seek gIdPos+"16"+dtos(dDatum)

do while !eof() .and. idpos+idvd+dtos(datum)==gIdPos+"16"+dtos(dDatum)
	cPrenijeti:="N"
     	cBrdok:=brdok
    	beep(1)
     	@ m_x+3,m_y+2 SAY "Prenijeti ulaz broj:"+cbrdok  GET cPrenijeti pict "@!" valid cprenijeti$"DN"
     	do while !eof() .and. idpos+idvd+dtos(datum)==gIdPos+"16"+dtos(dDatum)
        	if cprenijeti=="D"
           		scatter()
           		select pos2
			append blank
           		gather()
         	endif
         	skip
     	enddo
enddo

BoxC()

return .t.
*}


/*! \fn UChkPostoji(cFullFileName)
 *  \brief
 *  \param cFullFileName
 */
 
function UChkPostoji(cFullFileName)
*{
// u chk direktoriju postoji fajl
// npr: UChkPostoji(gKalkDest+"KT1105.DBF")

// ako se ne koristi chk direktorij svi su X
if gUseChkDir == "N"
	return "X"
endif

if FILE(strtran(cFullFileName, ":" + SLASH, ":" + SLASH + "chk" + SLASH))
	// ako postoji fajl R - realizovan
	return "R"
else
	// ako ne postoji fajl X - nije realizovano
	return "X"
endif
*}


/*! \fn BrisiSFajlove(cDir)
 *  \brief
 *  \param cDir
 */
 
function BrisiSFajlove(cDir)
*{

// npr:  cDir ->  c:\tops\prenos\
//
// brisi sve fajlove u direktoriju
// starije od 45 dana

local cFile

cDir:=TRIM(cDir)
cFile:=fileseek(trim(cDir)+"*.*")

do while !EMPTY(cFile)
	// svakih 7 dana brisi pomocne fajlove
	if DATE()-FileDate() > 7  
       		FileDelete(cDir+cFile)
    	endif
    	cFile:=FileSeek()
enddo
return nil
*}


/*! \fn AutoRek2Kalk(cDate1, cDate2)
 *  \brief APPSRV prenos rek2kalk 
 *  \param cDate1 - datum od
 *  \param cDate2 - datum do
 */
function AutoRek2Kalk(cDate1, cDate2)
*{
local dD1
local dD2
local nD1
local nD2

// inicijalizuj port za stampu i sekvence stampaca (EPSON)
// radi globalnih varijabli
private gPPort:="8"
InigEpson()

nD1 := LEN(cDate1)
nD2 := LEN(cDate2)

if ((nD1 < 10) .or. (nD2 < 10))
	? "FORMAT DATUMA NEISPRAVAN...."
	? "ISPRAVAN FORMAT, PRIMJER: 01.01.2005"
	Sleep(5)
	return
endif

if (!Empty(cDate1) .and. !Empty(cDate2))
	dD1 := CToD(cDate1)
	dD2 := CToD(cDate2)
	? "Vrsim prenos reklamacija za datum od: " + DToC(dD1) + " do " + DToC(dD2)
	// pozovi f-ju Real2Kalk() sa argumentima
	Rek2Kalk(dD1, dD2)
	? "Izvrsen prenos ..."
	Sleep(1)
endif

return
*}



/*! \fn AutoReal2Kalk(cDate1, cDate2)
 *  \brief APPSRV prenos real2kalk 
 *  \param cDate1 - datum od
 *  \param cDate2 - datum do
 */
function AutoReal2Kalk(cDate1, cDate2)
*{
local dD1
local dD2
local nD1
local nD2

// inicijalizuj port za stampu i sekvence stampaca (EPSON)
// radi globalnih varijabli
private gPPort:="8"
InigEpson()

nD1 := LEN(cDate1)
nD2 := LEN(cDate2)

if ((nD1 < 10) .or. (nD2 < 10))
	? "FORMAT DATUMA NEISPRAVAN...."
	? "ISPRAVAN FORMAT, PRIMJER: 01.01.2005"
	Sleep(5)
	return
endif

if (!Empty(cDate1) .and. !Empty(cDate2))
	dD1 := CToD(cDate1)
	dD2 := CToD(cDate2)
	? "Vrsim prenos realizacija za datum od: " + DToC(dD1) + " do " + DToC(dD2)
	// pozovi f-ju Real2Kalk() sa argumentima
	Real2Kalk(dD1, dD2)
	? "Izvrsen prenos ..."
	Sleep(1)
endif

return
*}


/*! \fn Rek2Kalk()
 *  \brief Prenos reklamacija u modul kalk
 */
function Rek2Kalk(dD1, dD2)
*{
// pozovi prenos reklamacija
Real2Kalk(dD1, dD2, VD_REK)

return
*}



/*! \fn Real2Kalk(dDatOd, dDatDo)
 *  \brief Generisanje datoteke prenosa realizacije u modul KALK
 *  \param dDatOd - datum od
 *  \param dDatDo - datum do
 */
 
function Real2Kalk(dDateOd, dDateDo, cIdVd)
*{

// ako je nil onda se radi o realizaciji
if (cIdVd == nil)
	cIdVd := "42"
endif

// prenos realizacija POS - KALK
O_ROBA
O_KASE
O_POS
O_DOKS

cIdPos:=gIdPos


if ((dDateOd == nil) .and. (dDateDo == nil))
	dDatOd:=DATE()
	dDatDo:=DATE()
else
	dDatOd:=dDateOd
	dDatDo:=dDateDo
endif

// ako nije APPSRV prikazi box za prenos
if !gAppSrv
	SET CURSOR ON
	Box(,4,60,.f.,"PRENOS REALIZACIJE POS->KALK")
		@ m_x+1,m_y+2 SAY "Prodajno mjesto " GET cIdPos pict "@!" Valid !EMPTY(cIdPos).or.P_Kase(@cIdPos,5,20)
		@ m_x+2,m_y+2 SAY "Prenos za period" GET dDatOd
		@ m_x+2,col()+2 SAY "-" GET dDatDo
	read
	ESC_BCR
	BoxC()
endif

if gVrstaRS<>"S"
	//sasa, ne znam sta je ovo znacilo
	//cIdPos:=gIdPos
	gIdPos:=cIdPos
else
	// ako je server
	gIdPos:=cIdPos
endif

SELECT doks
SET ORDER TO 2  // IdVd+DTOS (Datum)+Smjena
go top
SEEK cIdVd + DTOS(dDatOd)
EOF CRET

aDbf:={}
AADD(aDBF,{"IdPos",    "C",  2, 0})
AADD(aDBF,{"IDROBA",   "C", 10, 0})
AADD(aDBF,{"kolicina", "N", 13, 4})
AADD(aDBF,{"MPC",      "N", 13, 4})
AADD(aDBF,{"STMPC",    "N", 13, 4})
// stmpc - kod dokumenta tipa 42 koristi se za iznos popusta !!
AADD(aDBF,{"IDTARIFA", "C",  6, 0})
AADD(aDBF,{"IDCIJENA", "C",  1, 0})
AADD(aDBF,{"IDPARTNER","C", 10, 0})
AADD(aDBF,{"DATUM",    "D",  8, 0})
AADD(aDBF,{"DATPOS",   "D",  8, 0})
AADD(aDBF,{"IdVd",     "C",  2, 0})
AADD(aDBF,{"BRDOK",    "C", 10, 0})
AADD(aDBF,{"M1",       "C",  1, 0})

select roba
if roba->(FieldPos("barkod"))<>0
	AADD(aDBF,{"BARKOD","C",13,0})
endif

select doks
NaprPom(aDbf)

USEX (PRIVPATH+"POM") NEW
INDEX ON IdPos + IdRoba + STR(mpc,13,4) + STR(stmpc,13,4) TAG ("1") TO (PRIVPATH+"POM")
INDEX ON brisano+"10" TAG "BRISAN"    //TO (PRIVPATH+"ZAKSM")
SET ORDER TO 1

cKalkDbf:=ALLTRIM(gKalkDest)
cKalkDbf+="TOPSKA.DBF"

IF gVrstaRS=="S"
	DirMak2(ALLTRIM(gKalkDest)+ALLTRIM(cIdPos))
	cKalkDbf:=ToUnix(ALLTRIM(gKalkDest)+ALLTRIM(cIdPos)+SLASH+"TOPSKA.DBF")
endif
DbCreate2(cKALKDBF,aDbf)
USEX (cKALKDBF) NEW
ZAPP()
__dbPack()

select DOKS
nRbr:=0

do while !eof() .and. doks->IdVd==cIdVd .and. doks->Datum<=dDatDo
	
	if !EMPTY(cIdPos) .and. doks->IdPos<>cIdPos
    		SKIP
		LOOP
  	endif
	
	// ako su reklamacije prekoci sve sto je sto="P"
	if IsPlanika() .and. cIdVd==VD_REK
		if PADR(field->sto, 1) == "P"
			skip
			loop
		endif
	endif
  	
	SELECT pos
  	SEEK doks->(IdPos+IdVd+DTOS(datum)+BrDok)
  	
	do while !eof().and.pos->(IdPos+IdVd+DTOS(datum)+BrDok)==doks->(IdPos+IdVd+DTOS(datum)+BrDok)
    			
		Scatter()
    		// uzmi i barkod
		if roba->(fieldpos("barkod"))<>0
			select roba
			set order to tag "ID"
			hseek pos->idroba
		endif
		
		select POM
    		HSEEK POS->(IdPos+IdRoba+STR(cijena,13,4)+STR(nCijena,13,4))
    			// seekuj i cijenu i popust (koji je pohranjen u ncijena)
    		if !FOUND() .or. IdTarifa<>POS->IdTarifa .or. MPC<>POS->Cijena
     			append blank
      			
			replace IdPos WITH POS->IdPos
			replace IdRoba WITH POS->IdRoba
			replace Kolicina WITH POS->Kolicina
			replace IdTarifa WITH POS->IdTarifa
			replace mpc With POS->Cijena
			replace IdCijena WITH POS->IdCijena
			replace Datum WITH dDatDo
			replace DatPos with pos->datum
			replace brdok with pos->brdok
			
			if gModul=="HOPS"	
				replace IdVd With "47"
			else
				if IsTehnoprom() .and. doks->idvrstep $ "03"
					replace idvd with "41"
				elseif (IsPlanika() .and. doks->idvd == VD_REK)
					// reklamacija je "12"
					replace idvd with "12"
				else	
					replace idvd with POS->IdVd
				endif
			endif
					
			replace StMPC WITH pos->ncijena
					
			if roba->(FieldPos("barkod"))<>0
				replace barkod with roba->barkod
			endif
						
			if !EMPTY(doks->idgost)
				replace idpartner with doks->idgost
			endif
      					
			++nRbr
    		else
       			replace Kolicina WITH Kolicina + _Kolicina
    		endif
				
    		select pos
    		SKIP
  	END
  	SELECT doks
  	SKIP
enddo

SELECT POM 
GO TOP
while !eof()
	Scatter()
	SELECT TOPSKA
	append blank
	Gather()
	SELECT POM
	SKIP
enddo

if gModemVeza=="D"
	close all
	cDestMod:=RIGHT(DTOS(dDatDo),4)  // 1998 1105  - 11 mjesec, 05 dan
	cDestMod:="TK"+cDestMod+"."
	
	if !gAppSrv	
		cPm:=GetPm()
	endif
	
	if (!gAppSrv .and. !EMPTY(cPm))
		cPrefix:=(TRIM(cPm))+SLASH
	else
		cPrefix:=""
	endif
           	
	if (cIdVd <> VD_REK)
		RealKase(.f.,dDatOd,dDatDo,"1")  // formirace outf.txt
	else
		ReklKase(dDatOd, dDatDo) // pregled reklamacija
	endif
	
	cDestMod:=StrTran(cKalkDbf,"TOPSKA.",cPrefix+cDestMod)
  	FileCopy(cKalkDBF,cDestMod)
  	cDestMod:=StrTran(cDestMod,".DBF",".TXT")
  	FileCopy(PRIVPATH+"outf.txt",cDestMod)
  	cDestMod:=StrTran(cDestMod,".TXT",".DBF")
	if !gAppSrv  	
		MsgBeep("Datoteka "+cDestMod+"je izgenerisana#Broj stavki "+str(nRbr,4))
	else
		? "Datoteka " + cDestMod + "je izgenerisana. Broj stavki: "+STR(nRbr,4)
	endif
else
	close all
	aPom:=IntegDbf(cKalkDBF)
	NapraviCRC(trim(gKalkDEST)+"CRCTK.CRC" , aPom[1] , aPom[2] )
	if !gAppSrv	
		MsgBeep("Datoteka TOPSKA je izgenerisana#Broj stavki "+str(nRbr,4))
	endif
endif

CLOSERET
return
*}


/*! \fn SifKalkTops()
 *  \brief
 */
 
function SifKalkTops()
*{
private cDirZip:=ToUnix("C:" + SLASH + "TOPS" + SLASH)

if !SigmaSif("SIGMAXXX")
	return
endif

cIdPos:=gIdPos

gFmkSif:=Trim(gFmkSif)
AddBS(@gFmkSif)

if !EMPTY(gFMKSif) 
	if !FILE(gFmkSif + "ROBA.DBF")
      		MsgBeep("Na lokaciji " + TRIM(gFmkSif) + "ROBA.DBF nema tabele")
      		return
  	endif
	lAddNew:=(Pitanje(,"Dodati nepostojece sifre D/N ?"," ")=="D")
  	AzurSifIzFmk("", lAddNew)
  	return
endif

O_PARAMS
Private cSection:="T"
private cHistory:=" "
private aHistory:={}

RPar("Dz",@cDirZip)
Params1()

cDirZip:=Padr(cDirZip,30)

Box(,5,70) 
	@ m_x+1,m_y+2 SAY "Lokacija arhive sifrarnika:"
   	@ m_x+2,m_y+2 GET cDirZip
   	read
BoxC()

cDirZip:=TRIM(cDirZip)
AddBS(@cDirZip) 
 
if Params2()
	WPar("Dz",cDirZip)
endif

select params
use

select (F_ROBA)
use
save screen to cScr
cls

cKomlin:="dir /p " + cDirZip + "robknj.zip"
run &cKomLin

private cKomLin:="unzip -o " + cDirZip + "ROBKNJ.ZIP " + cDirZip
run &cKomLin

private cKomLin:="pause"
run &cKomLin

restore screen from cScr

O_SIFK
O_SIFV

if Pitanje(,"Osvjeziti sifrarnik iz arhive " + cDirZip + "ROBKNJ.ZIP"," ")=="D"
	lAddNew:=(Pitanje(,"Dodati nepostojece sifre D/N ?"," ")=="D")
	AzurSifIzFmk(cDirZip, lAddNew)	
     	O_ROBA
     	P_RobaPos()
endif

closeret
return
*}
	
	
// -----------------------------------------------
// katops -> priprz
// ----------------------------------------------	
static function AzurRow(cIdVd, cBrDok, cRsDbf)

// tabela PRIPRZ = "priprema zaduzenja"
select priprz
APPEND BLANK

replace idroba with katops->idroba
replace cijena with katops->mpc
if cIdVd=="NI"
	// nova cijena
	replace ncijena with katops->mpc2
endif

if IsPlanika()
	// setuj da nije na stanju samo zaduzenje kojem je
	// idkonto2 = "XXX"
	// to je prodavnica koja prima robu
	if katops->idvd == "80" .and. ALLTRIM(katops->idkonto2) == "XXX"
		replace sto with "N"
	endif
endif

replace idtarifa with katops->idtarifa
replace kolicina with katops->kolicina
replace jmj with katops->jmj
replace RobaNaz with katops->naziv

if katops->(FIELDPOS("K1"))<>0  .and. priprz->(FIELDPOS("K2"))<>0
	replace k1 with katops->k1
	replace k2 with katops->k2
endif
if katops->(fieldpos("K7"))<>0  .and. priprz->(FIELDPOS("K9"))<>0
	replace k7 with katops->k7
	replace k8 with katops->k8
	replace k9 with katops->k9
endif

if katops->(FIELDPOS("N1"))<>0  .and. priprz->(FIELDPOS("N1"))<>0
	replace n1 with katops->n1
	replace n2 with katops->n2
endif

if (katops->(FIELDPOS("BARKOD"))<>0 .and. priprz->(FIELDPOS("BARKOD"))<>0)
	replace barkod with katops->barkod
endif


replace PREBACEN with OBR_NIJE
replace IDRADNIK with gIdRadnik

replace IdPos with KATOPS->IdPos
replace IdOdj WITH cIdOdj
replace IdVd WITH cIdVD

replace Smjena WITH gSmjena 
replace BrDok with cBrdok
replace DATUM with gDatum

return 1


// -----------------------------------------------
// odaberi - setuj ime kalk dbf-a
// -----------------------------------------------
static function SelectKalkDbf(cBrDok, cKalkDestinacija, cKalkDbf)

local nFilter

if gModemVeza=="D"
	nFilter := 2
	if ( gUseChkDir == "D" )
		Box(,4,40)
		@ 1+m_x, 2+m_y SAY "Listu sortirati po:"
		@ 2+m_x, 2+m_y SAY "1. neprocitane/procitane"
		@ 3+m_x, 2+m_y SAY "2. datum kreiranja fajla"
		@ 4+m_x, 2+m_y SAY "sort ->" GET nFilter PICT "9" VALID nFilter >= 1 .and. nFilter <= 2
		read
		BoxC()
	endif
       	// modemska veza ide u odabir dokumenta
       	OpcF:={}
		
	cPm:=GetPm()
	if !EMPTY(cPm)
		cIdPos:=cPm
		cPrefix:=(TRIM(cPm))+SLASH
	else
		cPrefix:=""
	endif
	
        cKalkDestinacija:=TRIM(gKalkDest)+cPrefix
	
	// pobrisi fajlove starije od 7 dana
	BrisiSFajlove(cKalkDestinacija)
        BrisiSFajlove(STRTRAN(cKalkDestinacija, ":" + SLASH, ":" + SLASH + "chk" + SLASH))

	aFiles:=DIRECTORY(cKalkDestinacija+"KT*.dbf")

        ASORT(aFiles,,,{|x,y| DTOS(x[3]) + x[4] > DTOS(y[3]) + y[4] })   // datum + vrijeme
        //  KT0512.DBF = elem[1]
        
	AEVAL(aFiles,{|elem| AADD(OpcF, PADR(elem[1], 15) + UChkPostoji(trim(cKalkDestinacija) + trim(elem[1])) + " "+ dtoc(elem[3]) + " " + elem[4])},1)
	
	// sortiraj po X, R
	if nFilter == 1
		ASORT(OpcF,,,{|x,y| RIGHT(x,19) > RIGHT(y,19)})  // R,X + datum + vrijeme
	endif
	
	if nFilter == 2
		ASORT(OpcF,,,{|x,y| RIGHT(x,17) > RIGHT(y,17)})  // datum + vrijeme
	endif
	
       	h:=ARRAY(LEN(OpcF))
       	for i:=1 to len(h)
           		h[i]:=""
       	next
       	// elem 3 - datum
       	// elem 4 - time
       	if len(OpcF)==0
           		MsgBeep("U direktoriju za prenos nema podataka")
           		close all
           		return .f.
       	endif
	
else
   	MsgBeep ("Pripremi disketu za prenos ....#te pritisni neku tipku za nastavak!!!")
	
endif


if gModemVeza=="D"
	// CITANJE
 	Izb3:=1
       	fPrenesi:=.f.
       	do while .t.
        	Izb3:=Menu("k2p", opcF, Izb3, .f.)
		if Izb3==0
          		exit
        	else
          		cKalkDBF:=trim(cKalkDestinacija)+trim(left(opcf[izb3],15))
          		save screen to cS
          		Vidifajl(strtran(cKalkDBF,".DBF",".TXT"))  // vidi TK1109.TXT
          		restore screen from cS
          		if Pitanje(,"Zelite li izvrsiti prenos ?","D")=="D"
				fPrenesi:=.t.
              			Izb3:=0
          		endif
        	endif
       	enddo
	
       	if !fPrenesi
        	return .f.
       	endif
	
else  	
	// nije modemska veza
	// ako nije modemska veza
       	cKalkDBF:=trim(cKalkDestinacija)+"KATOPS.DBF"
       	aPom1 := IscitajCRC( trim(cKalkDestinacija)+"CRCKT.CRC" )
       	aPom2 := IntegDbf(cKalkDBF)
       	if !(aPom1[1]==aPom2[1].and.aPom1[2]==aPom2[2])
        	MsgBeep("CRC se ne slaze")
        	if Pitanje(, "Ipak zelite prenos (D/N)?", "N") == "N"
			return .f.
		endif
       	endif
endif

return .t.

