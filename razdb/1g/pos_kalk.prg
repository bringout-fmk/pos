#include "\cl\sigma\fmk\pos\pos.ch"

*string 
static cIdPos
*;

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/razdb/1g/pos_kalk.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.23 $
 * $Log: pos_kalk.prg,v $
 * Revision 1.23  2004/05/28 14:52:19  sasavranic
 * no message
 *
 * Revision 1.22  2004/05/04 09:00:42  sasavranic
 * Pri preuzimanju realizacije ispravljen bug sa barkod-om
 *
 * Revision 1.21  2004/05/03 15:29:52  sasavranic
 * Uveo odabir prodajnog mjesta pri prenosu realizacije u KALK
 *
 * Revision 1.20  2004/05/03 15:06:15  sasavranic
 * Uveo odabir prodajnog mjesta pri prenosu realizacije u KALK
 *
 * Revision 1.19  2004/02/18 08:15:13  sasavranic
 * no message
 *
 * Revision 1.18  2004/02/09 15:18:55  sasavranic
 * Apend sql loga i za sif osoblja
 *
 * Revision 1.17  2003/11/28 11:37:52  sasavranic
 * Prilikom prenosa realizacije u KALK da generise i barkodove iz TOPS-a
 *
 * Revision 1.16  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.15  2002/08/19 10:01:12  ernad
 *
 *
 * sql synchro cijena1, idtarifa za tabelu roba
 *
 * Revision 1.14  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.13  2002/07/13 20:50:04  ernad
 *
 *
 * DEBUG prenos nivelacije (kada se unutar nje nalaze stavke sa nepostojecim siframa artikala)
 *
 * Revision 1.12  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.11  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 * Revision 1.10  2002/06/27 08:13:10  sasa
 * no message
 *
 * Revision 1.9  2002/06/24 10:08:22  ernad
 *
 *
 * ciscenje ...
 *
 * Revision 1.8  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.7  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.6  2002/06/17 13:00:21  sasa
 * no message
 *
 * Revision 1.5  2002/06/15 14:06:02  sasa
 * no message
 *
 *
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

if priprz->(RecCount2())==0 .and. Pitanje(,"Preuzeti dokumente iz KALK-a","N")=="D"
	
	if gModemVeza=="D"
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
		aFiles:=DIRECTORY(cKalkDestinacija+"KT*.dbf")

         	ASORT(aFiles,,,{|x,y| x[3]>y[3] })   // datum
         	BrisiSFajlove(cKalkDestinacija)
         	BrisiSFajlove(strtran(cKalkDestinacija,":"+SLASH,":"+SLASH+"chk"+SLASH))

         	//  KT0512.DBF = elem[1]
         	AEVAL(aFiles,{|elem|AADD(OpcF,PADR(elem[1],15)+iif(UChkPostoji(trim(cKalkDestinacija)+trim(elem[1])),"R","X")+" "+dtos(elem[3]))},1)
         	ASORT(OpcF,,,{|x,y| RIGHT(x,10)>RIGHT(y,10)})  // datumi

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
        		Izb3:=Menu("k2p",opcF,Izb3,.f.)
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
          		return .f.
       		endif
	endif

	USEX (cKALKDBF) NEW alias KATOPS

    	if katops->idvd $ "11#80#81"  
		// radi se o zaduzenju koje se ovdje biljezi sa 16
      		cIdVD:="16"
    	elseif katops->idvd=="19"
      		cIdVD:="NI"
    	elseif katops->idvd=="IP"
      		cIdVD:="16"
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

    	if (gModemVeza=="N")
     		select katops
		use
    	endif

endif // prenos sa disketa

if gModemVeza=="D" .and. fPrenesi
	select katops
	use
    	DirMak2(strtran(trim(cKalkDestinacija),":"+SLASH,":"+SLASH+"chk"+SLASH))
    	copy file (cKalkDbf) TO (strtran(cKalkDbf,":"+SLASH,":"+SLASH+"chk"+SLASH))
    	// odradjeno-postavi kopiraj u chk direktorij
    	// npr c:\tops\prenos\2\x.dbf  -> npr c:\CHK\tops\prenos\2\x.dbf
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


if FILE(strtran(cFullFileName,":"+SLASH,":"+SLASH+"chk"+SLASH))
	return .t.
else
	return .f.
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
	if DATE()-FileDate() > 45  // 45 dana
       		FileDelete(cdir+cfile)
    	endif
    	cFile:=FileSeek()
enddo
return nil
*}

/*! \fn Real2Kalk()
 *  \brief
 */
 
function Real2Kalk()
*{

// prenos realizacija POS - KALK
O_ROBA
O_KASE
O_POS
O_DOKS

cIdPos:=gIdPos
dDatOd:=DATE()
dDatDo:=DATE()

SET CURSOR ON
Box(,4,60,.f.,"PRENOS REALIZACIJE POS->KALK")
@ m_x+1,m_y+2 SAY "Prodajno mjesto " GET cIdPos pict "@!" Valid !EMPTY(cIdPos).or.P_Kase(@cIdPos,5,20)
@ m_x+2,m_y+2 SAY "Prenos za period" GET dDatOd
@ m_x+2,col()+2 SAY "-" GET dDatDo
read
ESC_BCR
BOXC()

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
SEEK VD_RN+DTOS(dDatOd)
EOF CRET

aDbf:={}
AADD(aDBF,{"IdPos","C",2,0})
AADD(aDBF,{"IDROBA","C",10,0})
AADD(aDBF,{"kolicina","N",13,4})
AADD(aDBF,{"MPC","N",13,4})
AADD(aDBF,{"STMPC","N",13,4})
// stmpc - kod dokumenta tipa 42 koristi se za iznos popusta !!
AADD(aDBF,{"IDTARIFA","C",6,0})
AADD(aDBF,{"IDCIJENA","C",1,0})
AADD(aDBF,{"IDPARTNER","C",10,0})
AADD(aDBF,{"DATUM","D",8,0})
AADD(aDBF,{"IdVd","C",2,0})
AADD(aDBF,{"M1","C",1,0})
select roba
if roba->(FieldPos("barkod"))<>0
	AADD(aDBF,{"BARKOD","C",13,0})
endif
select doks
NaprPom(aDbf)

USEX (PRIVPATH+"POM") NEW
INDEX ON IdPos+IdRoba+STR(mpc,13,4)+STR(stmpc,13,4) TAG ("1") TO (PRIVPATH+"POM")
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
do while !eof() .and. doks->IdVd==VD_RN .and. doks->Datum<=dDatDo
	if !EMPTY(cIdPos) .and. doks->IdPos<>cIdPos
    		SKIP
		LOOP
  	endif
  	SELECT pos
  	SEEK doks->(IdPos+IdVd+DTOS(datum)+BrDok)
  		do while !eof().and.pos->(IdPos+IdVd+DTOS(datum)+BrDok)==doks->(IdPos+IdVd+DTOS(datum)+BrDok)
    			
			Scatter()
    			if roba->(fieldpos("barkod"))<>0
				select roba
				set order to tag "ID"
				hseek pos->idroba
			endif
			select POM
    			HSEEK POS->(IdPos+IdRoba+STR(cijena,13,4)+STR(nCijena,13,4))
    			// seekuj i cijenu i popust (koji je pohranjen u ncijena)
    				if !FOUND().or.IdTarifa<>POS->IdTarifa.OR.MPC<>POS->Cijena
     					append blank
      					
					replace IdPos WITH POS->IdPos
					replace IdRoba WITH POS->IdRoba
					replace Kolicina WITH POS->Kolicina
					replace IdTarifa WITH POS->IdTarifa
					replace mpc With POS->Cijena
					replace IdCijena WITH POS->IdCijena
					replace Datum WITH dDatDo
					
					if gModul=="HOPS"	
						replace IdVd With "47"
					else
						if IsTehnoprom() .and. doks->idvrstep$"03"
						
							replace IdVd With "41"
						else
							replace IdVd With POS->IdVd
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
			
			cPm:=GetPm()
			if !EMPTY(cPm)
				cPrefix:=(TRIM(cPm))+SLASH
			else
				cPrefix:=""
			endif
           	
  			RealKase(.f.,dDatOd,dDatDo,"1")  // formirace outf.txt
  			cDestMod:=StrTran(cKalkDbf,"TOPSKA.",cPrefix+cDestMod)
  			FileCopy(cKalkDBF,cDestMod)
  			cDestMod:=StrTran(cDestMod,".DBF",".TXT")
  			FileCopy(PRIVPATH+"outf.txt",cDestMod)
  			cDestMod:=StrTran(cDestMod,".TXT",".DBF")
  			MsgBeep("Datoteka "+cDestMod+"je izgenerisana#Broj stavki "+str(nRbr,4))
		else
			close all
  			aPom:=IntegDbf(cKalkDBF)
  			NapraviCRC( trim(gKalkDEST)+"CRCTK.CRC" , aPom[1] , aPom[2] )
  			MsgBeep("Datoteka TOPSKA je izgenerisana#Broj stavki "+str(nRbr,4))
		endif
		CLOSERET
*}


/*! \fn SifKalkTops()
 *  \brief
 */
 
function SifKalkTops()
*{
private cDirZip:=ToUnix("C:"+SLASH+"TOPS"+SLASH)

if !SigmaSif("SIGMAXXX")
	return
endif

cIdPos:=gIdPos

gFmkSif:=Trim(gFmkSif)
ADDBS(gFmkSif)
if !empty(gFMKSif) 
  if !FILE(gFmkSif+"ROBA.DBF")
      MsgBeep("Na lokaciji "+trim(gFmkSif)+"ROBA.DBF nema tabele")
      return
  endif
  AzurSifIzFmk()
  return
endif

// stara varijanta preuzimanja iz ZIP-a
if gSQL=="D"
  MsgBeep("Ne koristiti ovu opciju za SQL=D")
  return
endif

 O_PARAMS
 Private cSection:="T",cHistory:=" ",aHistory:={}
 RPar("Dz",@cDirZip)
 Params1()
 
 
 cDirZip:=Padr(cDirZip,30)
 Box(,5,70) 
   @ m_x+1,m_y+2 SAY "Lokacija arhive sifrarnika:"
   @ m_x+2,m_y+2 GET cDirZip
   read
 BoxC()

 cDirzip:=trim(cDirZip)
 
 if Params2()
  WPar("Dz",cDirZip)
 endif
 select params
 use
 

 select (F_ROBA)
 use
 save screen to cScr
 cls

 cKomlin:="dir /p "+cDirzip+"robknj.zip"
 run &ckomlin

 private ckomlin:="unzip -o "+cDirZip+"ROBKNJ.ZIP "+cDirZip
 run &ckomlin

 private ckomlin:="pause"
 run &ckomlin

 restore screen from cScr
 if gSifK=="D"
  O_SIFK
  O_SIFV
 endif

 if pitanje(,"Osvjeziti sifrarnik iz arhive "+cDirZip+"ROBKNJ.ZIP"," ")=="D"

     fDodaj:=(pitanje(,"Dodati nepostojece sifre D/N ?"," ")=="D" )
     O_ROBA
     usex (cDirZip+"ROBA") alias ROBKNJ NEW
     go top

     MsgO("Osvjezavam sifranik.....")

     do while !eof()
       select roba
       seek robknj->id
       if !found() .and. fDodaj
          append blank
          replace id with robknj->id
       endif
       if found() .or. fDodaj
        replace naz with robknj->naz ,;
              jmj with robknj->jmj,;
              cijena1 with robknj->mpc,;     // ?! sta ako je inventura sa promjenom cijena
              idtarifa with robknj->idtarifa
        if roba->(fieldpos("K1"))<>0  .and. robknj->(fieldpos("K1"))<>0
           replace K1 with robknj->k1, K2 with robknj->k2
        endif
        if roba->(fieldpos("K7"))<>0  .and. robknj->(fieldpos("K7"))<>0
           replace K7 with robknj->k7, K8 with robknj->k8, k9 with robknj->k9
        endif

        if roba->(fieldpos("BARKOD"))<>0 .and. robknj->(fieldpos("BARKOD"))<>0
          replace BARKOD with robknj->BARKOD
        endif

        if roba->(fieldpos("N1"))<>0 .and. robknj->(fieldpos("N1"))<>0
         replace N1 with robknj->N1, N2 with robknj->N2
        endif
       endif // found()

       select robknj
       skip
     enddo

     MsgC()
     select robknj; use

     select roba; use
     O_ROBA
     P_RobaPos()
 endif

closeret
*}
	
static function AzurRow(cIdVd, cBrDok, cRsDbf)
*{
local lNovi

// u jednom dbf-u moze biti vise IdPos
// ROBA ili SIROV
select (cRSDbf)     
hseek katops->idroba  // pozicioniran sam na robi
lNovi:=.f.
if (!FOUND())
	if (cIdVd=="NI")
		Beep(1)
		if (katops->kolicina==0)
			// nema se sta nivelisati
			SELECT katops
			return 1
		endif
		
		MsgBeep("Artikal "+ALLTRIM(katops->IdRoba)+" nije postojao!!!#On se preskace, jer nivelacija nije moguca!!!#")
		SELECT katops
		//ipak nastavi dalje
		return 1
	
	endif
	append blank
	sql_append()
	//sasa, 09.02.04
	sql_azur(.t.)
	replace id with katops->idROBA , idOdj WITH cIdOdj
	//sasa, 09.02.04
	replsql id with katops->idRoba , idOdj WITH cIdOdj
	//SmReplace("ID", katops->idRoba)
	//SmReplace("IDODJ", cIdOdj)
	lNovi:=.t.
endif
if !lNovi
	if naz<>katops->naziv .or. jmj<>katops->jmj .or. cijena1<>katops->mpc .or. idtarifa<>katops->idtarifa
		//MsgBeep("Sifra artikla:"+id+"#Doslo je do njegove promjene!#Promjena je izvrsena !")
	endif
endif

// azuriraj sifrarnik robe
SmReplace("naz", katops->naziv)
SmReplace("jmj", katops->jmj)
SmReplace("cijena1", katops->mpc)
SmReplace("idtarifa", katops->idtarifa)

if roba->(FIELDPOS("K1"))<>0  .and. katops->(FIELDPOS("K1"))<>0
	SmReplace("k1", katops->k1)
	SmReplace("k2", katops->k2)
endif
if roba->(fieldpos("K7"))<>0  .and. katops->(FIELDPOS("K9"))<>0
	SmReplace("k7",katops->k7)
	SmReplace("k8",katops->k8)
	SmReplace("k9",katops->k9)
endif

if roba->(FIELDPOS("N1"))<>0  .and. katops->(FIELDPOS("N2"))<>0
	SmReplace("n1",katops->n1)
	SmReplace("n2",katops->n2)
endif
if (katops->(FIELDPOS("BARKOD"))<>0 .and. roba->(FIELDPOS("BARKOD"))<>0)
	SmReplace("barkod",katops->barkod)
endif
sql_azur(.t.)

// priprema zaduzenja
select priprz
APPEND BLANK

replace  idroba with katops->idroba,CIJENA with katops->mpc,idtarifa with katops->idtarifa,KOLICINA with katops->kolicina,JMJ with katops->jmj,RobaNaz with katops->naziv,PREBACEN with OBR_NIJE,IDRADNIK with gIdRadnik,IdPos with KATOPS->IdPos,IdOdj WITH cIdOdj,IdVd WITH cIdVD, Smjena WITH gSmjena ,BrDok with cBrdok,DATUM with gDatum

//priprz
if cIdVd=="NI"
	REPLACE cijena WITH katops->mpc, nCijena with katops->mpc2
endif

return 1
*}


