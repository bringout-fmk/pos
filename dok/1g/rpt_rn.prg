#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/rpt_rn.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.28 $
 * $Log: rpt_rn.prg,v $
 * Revision 1.28  2004/06/08 07:32:34  sasavranic
 * Unificirane funkcije rabata
 *
 * Revision 1.27  2004/06/03 14:16:58  sasavranic
 * no message
 *
 * Revision 1.26  2004/06/03 08:09:29  sasavranic
 * Popust preko odredjenog iznosa se odnosi samo na gotovinsko placanje
 *
 * Revision 1.25  2004/05/21 11:25:02  sasavranic
 * Uvedena opcija popusta preko odredjenog iznosa
 *
 * Revision 1.24  2004/05/19 12:16:44  sasavranic
 * no message
 *
 * Revision 1.23  2004/05/15 12:15:28  sasavranic
 * U varijanti ugostiteljstva za prepis racuna iskoristena funkcija StampaRac()
 *
 * Revision 1.22  2004/03/18 13:38:09  sasavranic
 * Popust za partnere
 *
 * Revision 1.21  2003/12/24 09:54:35  sasavranic
 * Nova varijanta poreza, uvrstene standardne funkcije za poreze iz FMK
 *
 * Revision 1.20  2003/11/10 09:51:13  sasavranic
 * planika->messaging
 *
 * Revision 1.19  2003/08/20 13:37:30  mirsad
 * omogucio ispis poreza na svakoj stavci i na prepisu racuna, kao i na realizaciji kase po robama
 *
 * Revision 1.18  2003/08/07 15:35:20  sasa
 * bug kada je kolicina 0 na racunu
 *
 * Revision 1.17  2003/07/26 08:29:11  sasa
 * ispis poreskih stopa na svaku stavku
 *
 * Revision 1.16  2003/07/08 18:35:14  mirsad
 * uveo mogucnost stampe svih racuna jednog dana odjednom za parametar Retroaktivno=D
 *
 * Revision 1.15  2003/07/08 10:58:29  mirsad
 * uveo fmk.ini/kumpath/[POS]/Retroaktivno=D za mogucnost ispisa azur.racuna bez teksta "PREPIS" i za ispis "datuma do" na realizaciji umjesto tekuceg datuma
 *
 * Revision 1.14  2003/07/07 11:16:26  sasa
 * no message
 *
 * Revision 1.13  2003/07/04 12:59:44  sasa
 * ispis poreza ispod svake stavke na racunu
 *
 * Revision 1.12  2003/07/04 12:43:00  sasa
 * ispis poreza ispod svake stavke na racunu
 *
 * Revision 1.11  2003/07/01 06:02:54  mirsad
 * 1) uveo public gCijDec za format prikaza decimala cijene na racunu
 * 2) prosirio format za kolicinu za jos jedan znak
 * 3) uveo puni ispis naziva robe na racunu (lomljenje u dva reda)
 *
 * Revision 1.10  2003/06/30 08:08:48  mirsad
 * 1) prosirio format prikaza kolicine na racunu sa 6 na 8 znakova i uveo public gKolDec za definisanje broja decimala
 *
 * Revision 1.9  2003/06/24 13:15:09  sasa
 * no message
 *
 * Revision 1.8  2003/06/23 09:03:38  sasa
 * nver - zakljucivanje nezakljucenih racuna
 *
 * Revision 1.7  2003/06/21 12:23:38  sasa
 * nver - zakljucivanje nezakljucenih racuna
 *
 * Revision 1.6  2003/06/16 17:30:26  sasa
 * generacija zbirnog racuna
 *
 * Revision 1.5  2003/06/14 03:03:50  mirsad
 * debug-hops
 *
 * Revision 1.4  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.3  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 

/*! \fn StampaRac(cIdPos, cBrDok, lPrepis, cIdVrsteP, dDatum)
 *  \brief Stampa racuna koji tek treba da se azurira
 *  \param cIdPos  - Prodajno mjesto
 *  \param cBrDok  - Broj dokumenta u _POS.DBF
 */
 
function StampaRac(cIdPos, cBrDok, lPrepis, cIdVrsteP, dDatumRn)
*{

local cDbf
local cIdRadnik
local aPom:={}
local cPom
private nIznos
private nSumaPor:=0

if lPrepis==NIL
	lPrepis:=.f.
endif

if cIdVrsteP==NIL
	cIdVrsteP:=""
endif

if dDatumRn==NIL
	dDatumRn:=gDatum
endif

SELECT (F_ODJ)

if !used()
	O_ODJ  
	// otvori odjeljenje radi APOTEKA....
endif

altd()

if lPrepis
	cPosDB:="POS"
else
	cPosDB:="_POS"
endif

SELECT &cPosDB

Seek2(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)

if !lPrepis
	cSto:=&cPosDB->Sto
	cIdRadnik:=&cPosDB->IdRadnik
	cSmjena:=&cPosDB->Smjena
else
	altd()
	SELECT DOKS
	Seek2 (cIdPos+VD_RN+DToS(dDatumRn)+cBrDok)
	cSto      := DOKS->Sto
	cIdRadnik := DOKS->IdRadnik
	cSmjena   := DOKS->Smjena
endif

SELECT &cPosDB

altd()

nIznos:=0
nNeplaca:=0

if VarPopPrekoOdrIzn()
	gIsPopust:=.f.
endif

do while !eof().and. &cPosDB->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)
	if (gRadniRac="D" .and. gVodiTreb=="D" .and. GT=OBR_NIJE)
      		// vodi se po trebovanjima, a za ovu stavku trebovanje 
		// nije izgenerisano
      		// s obzirom da se nalazimo u procesu zakljucenja, 
		//nuliramo kolicinu
      		replace kolicina with 0 // nuliraj kolicinu
  	endif
	
	nIznos+=Kolicina*Cijena
	
	select odj
	seek &cPosDB->idodj
	select &cPosDB
  	
	if right(odj->naz,5)=="#1#0#"
     		nNeplaca+=Kolicina*Cijena - ncijena*Kolicina
  	elseif right(odj->naz,6)=="#1#50#"
     		nNeplaca+=Kolicina*Cijena/2 - ncijena
  	endif
	
  	if (gPopVar="P" .and. gClanPopust) 
		if !EMPTY(cPartner)
			nNeplaca+=kolicina*NCijena
		endif
	endif
	
	if (gPopVar="P" .and. !gClanPopust)
		nNeplaca+=kolicina*NCijena
	endif
	
  	SKIP
enddo

/*
if VarPopPrekoOdrIzn() 
	if cIdVrsteP=="01" .and. !IsPopPrekoOdrIznosa(nIznos)
		// izracunaj ponovo vrijednost rabata ali bez popprekoodrizn
		nNeplaca:=CalcArrRabat(aRabat, .t., .t., .t., .f., .t., .t.)
		gIsPopust:=.f.
	elseif cIdVrsteP=="01" .and. IsPopPrekoOdrIznosa(nIznos)
		gIsPopust:=.t.
	endif
endif
*/

// Ispisi iznos racuna velikim slovima
PisiIznRac(nIznos-nNeplaca)

START PRINT2 CRET gLocPort,SPACE(5)

if lPrepis
	cTime:=RacHeder(cIdPos,DToS(dDatumRn)+cBrDok,cSto,.t.)
else
	cTime:=RacHeder(cIdPos,DTOS(dDatumRn)+cStalRac,cSto,.f.)
endif

SELECT &cPosDB

seek cIdPos+"42"+dtos(dDatumRn)+cBrDok

aPorezi:={}
aRekPor:={}

do while !eof().and.(IdPos+IdVd+DTOS(datum)+BrDok)==(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)
	cPom:=" * "
  	Scatter()
  	_Kolicina := 0
  	do while !eof().and.&cPosDB->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+"42"+dtos(dDatumRn)+cBrDok).and.&cPosDB->(IdRoba+IdCijena)==(_IdRoba+IdCijena).and.&cPosDB->Cijena==_Cijena
    		_Kolicina += &cPosDB->Kolicina
    		SKIP
  	enddo
  	nIznosST:=0
  	if round(_kolicina,4)<>0
		if !lPrepis
			cPom+=TRIM(_IdRoba)+" - "+TRIM(_RobaNaz)
		else
			select roba
			seek TRIM(_idRoba)
			cPom+=TRIM(_idRoba)+" - "+TRIM(roba->naz)
			select pos
		endif
		aPom:=SjeciStr(cPom,38)
		for i:=1 to len(aPom)
			? aPom[i]
		next
   		SELECT &cPosDB
		
   		//**** sasa, 18.05.04
		// ovo sam izbacio jer je skroz nelogicno, cijena stavke mora biti prava cijena i na nju se obracunava porez, a odobravanjem popusta firma gubi na marzi!!!
		//****
		// uzmi u obzir popust !!!!!
   		//nIznosSt:=_Kolicina*(_Cijena-_NCijena)
   		
		nIznosSt:=_Kolicina*(_Cijena)
		if gKolDec==N_ROUNDTO
	   		? SPACE(1)+PADR("(T" + ALLTRIM(_IdTarifa)+")",6)+STR(_Kolicina,9,N_ROUNDTO),if(!lPrepis,_Jmj,roba->jmj),"x "
		else
	   		? SPACE(1)+PADR("(T" + ALLTRIM(_IdTarifa)+")",6)+STR(_Kolicina,9,gKolDec),if(!lPrepis,_Jmj,roba->jmj),"x "
		endif
		if gCijDec==N_ROUNDTO
	   		?? PADR(ALLTRIM(STR(_Cijena,8,N_ROUNDTO)),8)+STR(nIznosSt,8,N_ROUNDTO)
		else
	   		?? PADR(ALLTRIM(STR(_Cijena,8,gCijDec)),8)+STR(nIznosSt,8,N_ROUNDTO)
		endif
  	endif
  	
	// obracun poreza
	SELECT TARIFA
  	Seek2(_IdTarifa)
		
	if glPorezNaSvakuStavku
		nPPP:=tarifa->opp
		nPPU:=tarifa->ppp
		nPP:=tarifa->zpp
	endif
	// Izracunaj MPC bez poreza
    	nMPVBP:=nIznosSt/(1+zpp/100+ppp/100)/(1+opp/100)
        
	// varijanta starog obracuna poreza
        if gStariObrPor
  		if IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
    			nMpVBP:=nIznosSt/(1+zpp/100+ppp/100)/(1+opp/100)
    			nPPPIznos:=nMPVBP*opp/100
    			nPPIznos:=(nMPVBP+nPPPIznos)*zpp/100
  		else
    			nMpVBP:=nIznosSt/(zpp/100+(1+opp/100)*(1+ppp/100))
    			nPPPIznos:=nMPVBP*opp/100
    			nPPIznos:=nMPVBP*zpp/100
  		endif

		if glPorezNaSvakuStavku  	
			? SPACE(1) + "PPP(" + ALLTRIM(STR(nPPP)) + "%) " + ALLTRIM(STR(nPPPIznos))	
		endif

		nPPUIznos:=(nMPVBP+nPPPIznos)*ppp/100

		if glPorezNaSvakuStavku
			?? " PPU(" + ALLTRIM(STR(nPPU)) + "%) " + ALLTRIM(STR(nPPUIznos))
		endif

		nSumaPor+=nPPPiznos+nPPUiznos+nPPIznos
		nPoz:=ASCAN(aPorezi,{|x| x[1]==_IdTarifa})
  		if nPoz==0
     			AADD(aPorezi,{_IdTarifa,nPPPiznos,nPPUiznos,nPPIznos,{opp,ppp,zpp}})
  		else
     			aPorezi[nPoz][2]+=nPPPiznos
     			aPorezi[nPoz][3]+=nPPUiznos
     			aPorezi[nPoz][4]+=nPPiznos
  		endif
    	else // stara varijanta
   		SetAPorezi(@aPorezi)
		aIPor:=RacPorezeMP(aPorezi, nMPVBP, nIznosSt, 0)
		? " PPP(" + STR(nPPP,2,0) + "%)" + ALLTRIM(STR(ROUND(aIPor[1],2)))
		?? " PPU(" + STR(nPPU,2,0) + "%)" + ALLTRIM(STR(ROUND(aIPor[2],2)))
		?? " PP(" + STR(nPP,2,0) + "%)" + ALLTRIM(STR(ROUND(aIPor[3],2)))
		nSumaPor+=aIPor[1]+aIPor[2]+aIPor[3]
		nPoz:=ASCAN(aRekPor,{|x| x[1]==_IdTarifa})
  		if nPoz==0
    			AADD(aRekPor, {_idtarifa, aIPor[1], aIPor[2], aIPor[3], aIPor[1]+aIPor[2]+aIPor[3]})
  		else
     			aRekPor[nPoz][2]+=aIPor[1]
     			aRekPor[nPoz][3]+=aIPor[2]
     			aRekPor[nPoz][4]+=aIPor[3]
  		endif
	
    	endif
   	SELECT &cPosDB
enddo

SEEK cIdPos+"42"+dtos(dDatumRn)+cBrDok
do while !eof().and.&cPosDB->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)
	replace m1 with "S" // odstampano
  	skip
enddo
// iznos racuna
? " " + REPLICATE("=", 38)
? PADL("UKUPNO (" + gDomValuta + ")", 30),IIF(nIznos >= 0, TRANSFORM(nIznos, "****9.99"),TRANSFORM(nIznos,"99999.99"))

if nNeplaca<>0 // postoji oslobadjanje
	?
 	? " " + REPLICATE ("-", 38)
 	? PADL ("  POPUST: (" + gDomValuta + ")", 30), TRANSFORM (nNeplaca, "99999.99")
 	? " " + REPLICATE ("=", 38)
 	? PADL ("NAPLATITI (" + gDomValuta + ")", 30),IIF(nIznos-nNePlaca >= 0,TRANSFORM (nIznos-nNeplaca, "****9.99"),TRANSFORM(nIznos-nNePlaca, "99999.99"))
endif
? " " + REPLICATE ("=", 38)
if !empty(gStrValuta)
	?
  	? PADL ("UKUPNO (" + gStrValuta + ")", 30),IIF (nIznos >= 0, TRANSFORM (StrValuta(gStrValuta,doks->datum)*nIznos, "****9.99"),TRANSFORM(StrValuta(gStrValuta,doks->datum)*nIznos, "99999.99"))
  	? " " + REPLICATE ("=", 38)
endif

// porezi
// stari obracun poreza

if gStariObrPor
	? " U iznos uracunati porezi "
	if gPoreziRaster=="D"
		ASORT(aPorezi,,, {|x, y| x[1] < y[1]})
   		fPP:=.f. // ima posebnog poreza
   		for i:=1 to len(aPorezi)
     			if round(aPorezi[i,4],4)<>0
        			fPP:=.t.
        			exit
     			endif
   		next
   		? " T.br.        PPP       PPU      Iznos"
   		if fPP
      			? "               PP"
   		endif
   		nPPP:=nPPU:=0
   		nPP:=0
   		for nCnt:=1 to len(aPorezi)
      			if IzFMKIni("TOPS","NaRacunuPrikazatiProcentePoreza","D",KUMPATH)=="D"
        			? " T" + PADR(aPorezi[nCnt][1],4)
        			?? " (PPP "+STR(aPorezi[nCnt][5][1],2,0)+"%, PPU "+STR(aPorezi[nCnt][5][2],2,0)+IF(!fPP,"%)   ","%, PP "+STR(aPorezi[nCnt][5][3],2,0)+"%)")
				? SPACE(10)
      			else
        			? " T" + PADR (aPorezi[nCnt][1], 4) + "    "
      			endif
      			?? STR ( aPorezi[nCnt][2], 7, N_ROUNDTO) + "   " +STR(aPorezi[nCnt][3], 7, N_ROUNDTO) + "    " + STR(round(aPorezi[nCnt][2],N_ROUNDTO)+round(aPorezi[nCnt][3],N_ROUNDTO)+round(aPorezi[nCnt][4],N_ROUNDTO), 7, N_ROUNDTO)
      			if round(aPorezi[nCnt][4],4)<>0
        			? space(10)+STR ( aPorezi[nCnt][4], 7, N_ROUNDTO)
      			endif

      			nPPP+=round(aPorezi[nCnt][2],N_ROUNDTO)
      			nPPU+=round(aPorezi[nCnt][3],N_ROUNDTO)
      			nPP+=round(aPorezi[nCnt][4],N_ROUNDTO)
   		next
   		? " " + REPLICATE ("-", 38)
   		? " UKUPNO   " + STR(nPPP,7,N_ROUNDTO) + "   " +STR(nPPU,7,N_ROUNDTO) + "    " + STR(nPPP+nPPU+nPP,7,N_ROUNDTO)
   		if fPP
      			? "          " +STR(nPP,7,N_ROUNDTO)
   		endif
	else
		?? LTRIM (STR (nSumaPor, 8, N_ROUNDTO)), gDomValuta
	endif

else // stari obracun poreza
	POSRekapTar(aRekPor)
endif

RacFuter(cIdRadnik, cSmjena)
END PRN2 13
SkloniIznRac()
return (cTime)
*}


/*! \fn RacHeder(cIdPos,cDatBrDok,cSto,fPrepis)
 */
 
function RacHeder(cIdPos,cDatBrDok,cSto,fPrepis)
//
//                    1            2               3              4
//  aVezani : {DOKS->IdPos, DOKS->(BrDok), DOKS->IdVrsteP, DOKS->Datum})
//  fprepis - .t. - vrsi se prepis racuna

local cStr
local cTime
local nCnt
local cJedan
local dDat

cStr:=MEMOREAD(PRIVPATH+AllTrim(gRnHeder))

IF ! EMPTY (cStr)
	QQOUT (cStr)
  	?
ENDIF

?? PADC ("RACUN br. "+ALLTRIM (cIdPos)+"-"+ALLTRIM (substr(cDatBrDok,9)), 40)

IF fPrepis
  	if !glRetroakt
  		? PADC ("PREPIS", 40)
  	endif
  	cStr := Space(16)
  	FOR nCnt := 2 TO LEN (aVezani)
    		cJedan := ALLTRIM (aVezani [nCnt][1])+"-"+ALLTRIM (aVezani [nCnt][2])
    		IF LEN (cStr) + LEN (cJedan) < 38
      			cStr += cJedan + ", "
    		ELSE
      			cStr += CHR (13)+CHR(10)+SPACE (16)+cJedan
    		ENDIF
  	NEXT
  	IF !Empty (cStr)
    		? " Vezani racuni: " + LTrim (cStr)
  	ENDIF
  	nPrev := SELECT ()
  	SELECT DOKS
  	// HSEEK (cIdPos+VD_RN+cDatBrDok)
  	cTime := DOKS->Vrijeme
  	cDat  := DTOC (DOKS->Datum)
  	SELECT (nPrev)
ELSE
	cTime := LEFT (TIME(), 5)
  	cDat := DTOC (gDatum)
ENDIF

if gModul=="HOPS"
	cStoStr := "Sto: " + cSto
else
  	cStoStr := SPACE (8)
endif

? " " + cDat + "." + SPACE (8) + cStoStr + SPACE (8) + cTime
? " " + REPLICATE ("-", 38)

RETURN (cTime)
*}

/*! \fn RacFuter(cIdRadnik,cSmjena)
 */
 
function RacFuter(cIdRadnik,cSmjena)
*{
LOCAL cStr

? " " + REPLICATE ("-", 38)
SELECT OSOB
set order to tag "NAZ"
HSEEK cIdRadnik
? " " + PADR (ALLTRIM (OSOB->Naz), 29), "Smjena " + cSmjena
cStr := MEMOREAD (PRIVPATH+AllTrim (gRnFuter))
IF !EMPTY(cStr)
	QOUT(cStr)
ENDIF
PaperFeed ()
gOtvorStr()
RETURN
*}


/*! \fn StampaPrep(cIdPos,cDatBrDok,aVezani,fEkran)
 */
 
function StampaPrep(cIdPos,cDatBrDok,aVezani,fEkran,lViseOdjednom)
*{
local cDbf
local cIdRadnik
local nCnt
local aPom:={}
local cPom

//
//                    1            2               3              4
//  aVezani : {DOKS->IdPos, DOKS->(BrDok), DOKS->IdVrsteP, DOKS->Datum})
//
// Napomena: cDatBrDok sadrzi DTOS(DATUM)+BRDOK  !!

private nIznos:=0
private nSumaPor:=0
private aPorezi:={}

if fEkran==NIL
	fEkran:=.f.
else
	fEkran:=.t.
endif

if lViseOdjednom==nil
	lViseOdjednom:=.f.
endif

CreateTmpTblForDocReview()

select doks

Seek2(cIdPos + VD_RN + cDatBrDok)

cSto:=DOKS->Sto
cIdRadnik:=DOKS->IdRadnik
cSmjena:=DOKS->Smjena

select pos

altd()

nIznos := 0
nNeplaca:=0

for nCnt:=1 to LEN(aVezani)
	seek (aVezani[nCnt][1]+VD_RN+dtos(aVezani[nCnt][4])+aVezani[nCnt][2])
  	do while !EOF() .and. pos->(IdPos+IdVd+dtos(datum)+BrDok)==(aVezani[nCnt][1]+VD_RN+dtos(aVezani[nCnt][4])+aVezani[nCnt][2])
    		select pom
    		seek POS->IdRoba+POS->IdCijena+STR (POS->Cijena, 10, 3)
    		if Found()
      			replace Kolicina WITH Kolicina+POS->Kolicina
    		else
      			Append Blank  
      			replace IdRoba WITH POS->IdRoba
			replace IdCijena WITH POS->IdCijena
			replace Cijena WITH POS->Cijena
			replace Kolicina WITH POS->Kolicina
              		replace NCijena WITH pos->ncijena
              		replace datum WITH pos->datum
    		endif
   		select pos
    		nIznos+=pos->(kolicina*cijena)
    		select odj
		seek pos->idodj
		select POS
    		if right(odj->naz,5)=="#1#0#"
       			nNeplaca+=pos->(Kolicina*Cijena - ncijena*Kolicina)
    		elseif right(odj->naz,6)=="#1#50#"
       			nNeplaca+=pos->(Kolicina*Cijena/2 - ncijena)
    		endif
    		if gPopVar="P"
			nNeplaca+=pos->(kolicina*ncijena)
		endif
    		skip
  	enddo
next

// Varijanta ugostiteljstvo
// Iskoristena funkcija StampaRac()
// Mislim da ovo i jeste najbolja varijanta, razlika je samo u _POS i POS

if !gStariObrPor
	StampaRac(cIdPos, doks->brdok, .t., doks->idvrstep, doks->datum)
	return
endif

// TODO: ovu funkciju izbaciti
// napraviti sve kroz StampaRac() kao sto je slucaj sa novim obracunom poreza
// Ostavljeno trenutno samo u ovoj varijanti (Ugostiteljstvo)

if fEkran
	if !lViseOdjednom
  		START PRINT CRET
  	endif
else
  	PisiIznRac(nIznos-nNeplaca)
  	START PRINT2 CRET gLocPort, SPACE (5)
endif

RacHeder (cIdPos, cDatBrDok, cSto, .T., aVezani)

SELECT POM
GO TOP
DO WHILE ! EOF()
  cPom:=" * "
  SELECT ROBA
  HSEEK POM->IdRoba

  cPom+=trim(POM->IdRoba)+" - "+TRIM(roba->Naz)
  aPom:=SjeciStr(cPom,38)
  for i:=1 to len(aPom)
  	? aPom[i]
  next

  _idTarifa := roba->IdTarifa
  cJmj := roba->JMJ

  SELECT POM
  nIznosSt := POM->(Kolicina * (Cijena-NCijena))
  // uzeti u obzir popust !!!!

  if gKolDec==N_ROUNDTO
  	? SPACE (1)+PADR ("(T" + ALLTRIM (_IdTarifa) + ")", 6)+STR (POM->Kolicina, 9, N_ROUNDTO), cJmj, "x "
  else
  	? SPACE (1)+PADR ("(T" + ALLTRIM (_IdTarifa) + ")", 6)+STR (POM->Kolicina, 9, gKolDec), cJmj, "x "
  endif

  if gCijDec==N_ROUNDTO
  	?? PADR (ALLTRIM (STR (POM->Cijena, 8, N_ROUNDTO)), 8) + STR (nIznosSt, 8, N_ROUNDTO)
  else
  	?? PADR (ALLTRIM (STR (POM->Cijena, 8, gCijDec)), 8) + STR (nIznosSt, 8, N_ROUNDTO)
  endif

  // obracun poreza
  SELECT TARIFA
  Seek2 (_IdTarifa)

  if glPorezNaSvakuStavku
  	nPPP:=tarifa->opp
  	nPPU:=tarifa->ppp
  endif

  IF IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
    nMpVBP:=nIznosSt/(1+zpp/100+ppp/100)/(1+opp/100)
    nPPPIznos:=nMPVBP*opp/100
    nPPIznos:=(nMPVBP+nPPPIznos)*zpp/100
  ELSE
    nMpVBP:=nIznosSt/(zpp/100+(1+opp/100)*(1+ppp/100))
    nPPPIznos:=nMPVBP*opp/100
    nPPIznos:=nMPVBP*zpp/100
  ENDIF

  if glPorezNaSvakuStavku  	
  	? SPACE(1) + "PPP(" + ALLTRIM(STR(nPPP)) + "%) " + ALLTRIM(STR(nPPPIznos))	
  endif

  nPPUIznos:=(nMPVBP+nPPPIznos)*ppp/100

  if glPorezNaSvakuStavku
  	?? " PPU(" + ALLTRIM(STR(nPPU)) + "%) " + ALLTRIM(STR(nPPUIznos))
  endif

  nSumaPor += nPPPiznos + nPPUiznos + nPPIznos

  nPoz := ASCAN (aPorezi, {|x| x[1] == _IdTarifa})
  	if nPoz==0
     		AADD(aPorezi,{_IdTarifa,nPPPiznos,nPPUiznos,nPPIznos,{opp,ppp,zpp}})
  	else
     		aPorezi[nPoz][2]+=nPPPiznos
     		aPorezi[nPoz][3]+=nPPUiznos
     		aPorezi[nPoz][4]+=nPPiznos
  	endif

  SELECT POM
  SKIP
ENDDO
// iznos racuna
? " " + REPLICATE ("=", 38)
? PADL ("UKUPNO (" + gDomValuta + ")", 30), ;
  IIF (nIznos >= 0, TRANSFORM (nIznos, "****9.99"), ;
                    TRANSFORM (nIznos, "99999.99"))


if nNeplaca<>0 // postoji oslobadjanje
 ?
 ? " " + REPLICATE ("-", 38)
 ? PADL ("  POPUST: (" + gDomValuta + ")", 30), TRANSFORM (nNeplaca, "99999.99")
 ? " " + REPLICATE ("=", 38)
 ? PADL ("NAPLATITI (" + gDomValuta + ")", 30), ;
  IIF (nIznos-nNePlaca >= 0, TRANSFORM (nIznos-nNeplaca, "****9.99"), ;
                    TRANSFORM (nIznos-nNePlaca, "99999.99"))
endif

? " " + REPLICATE ("=", 38)
if !empty(gStrValuta)
  ?
  ? PADL ("UKUPNO (" + gStrValuta + ")", 30), ;
   IIF (nIznos >= 0, TRANSFORM (StrValuta(gStrValuta,doks->datum)*nIznos, "****9.99"), ;
                     TRANSFORM (StrValuta(gStrValuta,doks->datum)*nIznos, "99999.99"))
  ? " " + REPLICATE ("=", 38)
endif

// porezi
? " U iznos uracunati porezi "
IF gPoreziRaster == "D"
   ASORT (aPorezi,,, {|x, y| x[1] < y[1]})
   fPP:=.f. // ima posebnog poreza
   for i:=1 to len (aPorezi)
     if round(aPorezi[i,4],4)<>0
        fPP:=.t.
        exit
     endif
   next
   ? " T.br.        PPP       PPU      Iznos"
   if fPP
      ? "               PP"
   endif
   nPPP:=nPPU:=0
   nPP:=0
   FOR nCnt := 1 TO LEN (aPorezi)
      		if IzFMKIni("TOPS","NaRacunuPrikazatiProcentePoreza","D",KUMPATH)=="D"
        		? " T" + PADR(aPorezi[nCnt][1],4)
        		?? " (PPP "+STR(aPorezi[nCnt][5][1],2,0)+"%, PPU "+STR(aPorezi[nCnt][5][2],2,0)+IF(!fPP,"%)   ","%, PP "+STR(aPorezi[nCnt][5][3],2,0)+"%)")
        		? SPACE(10)
      		else
		        ? " T" + PADR (aPorezi[nCnt][1], 4) + "    "
		endif	
      ?? STR ( aPorezi[nCnt][2], 7, N_ROUNDTO) + "   " + ;
        STR ( aPorezi[nCnt][3], 7, N_ROUNDTO) + "    " + ;
        STR ( round(aPorezi[nCnt][2],N_ROUNDTO)+;
              round(aPorezi[nCnt][3],N_ROUNDTO)+;
              round(aPorezi[nCnt][4],N_ROUNDTO), 7, N_ROUNDTO)
      if round(aPorezi[nCnt][4],4)<>0
        ? space(10)+STR ( aPorezi[nCnt][4], 7, N_ROUNDTO)
      endif
      nPPP+=round(aPorezi[nCnt][2],N_ROUNDTO)
      nPPU+=round(aPorezi[nCnt][3],N_ROUNDTO)
      nPP +=round(aPorezi[nCnt][4],N_ROUNDTO)
   NEXT
   ? " " + REPLICATE ("-", 38)
   ? " UKUPNO   " + ;
     STR ( nPPP            , 7, N_ROUNDTO) + "   " + ;
     STR ( nPPU            , 7, N_ROUNDTO) + "    " + ;
     STR ( nPPP+nPPU+nPP   , 7, N_ROUNDTO)
   if fPP
      ? "          " + ;
       STR ( nPP             , 7, N_ROUNDTO)
   endif
ELSE
   ?? LTRIM (STR (nSumaPor, 8, N_ROUNDTO)), gDomValuta
ENDIF


RacFuter(cIdRadnik,cSmjena)

if fEkran
	if !lViseOdjednom
		END PRINT
	endif
else
  	END PRN2 13
  	SkloniIznRac()
endif

SELECT DOKS

return
*}


/*! \fn StampaRekap(cIdRadnik, cBrojStola)
 *  \brief Stampa rekapitulacije racuna
 */
 
function StampaRekap(cIdRadnik, cBrojStola, dDatumOd, dDatumDo, lStampati)
*{
local nRecNoTrenutni
local nRecNoNext

select pos
set order to tag 1

cZakljucen:="N"
lSiriPrikaz:=.f.

if Pitanje(,"Prikazati rasclanjeno po stavkama? (D/N)","N")=="D"
	lSiriPrikaz:=.t.
endif

if lStampati
	nUkupnoIznos:=0

	START PRINT2 CRET gLocPort, SPACE(5)
	? SPACE(2), Date()
	? SPACE(2) + "Rekapitulacija racuna:"
	? SPACE(2) + "---------------------------"
	? SPACE(2) + "stol br. " + ALLTRIM(cBrojStola)
	?
	? SPACE(2) + "Rn.Br.    Artikal    Iznos"
	? SPACE(2) + "---------------------------"
endif

select doks
set order to tag 8

hseek gIdPos+cIdRadnik+cZakljucen
altd()
do while !EOF() .and. field->idpos==gIdPos .and. field->idradnik==cIdRadnik .and. field->datum<=dDatumDo .and. field->datum>=dDatumOd .and. field->zakljucen=="N"
	if (field->sto<>cBrojStola)
		skip
	else
		// markiraj ga kao zakljucen sa Z
		if (field->zakljucen=="N")
			nRecNoTrenutni:=RecNo()
			skip
			nRecNoNext:=RecNo()
			skip -1
			replace field->zakljucen with "Z"
			set order to tag 8
			go nRecNoTrenutni
	
			if lStampati
			cIdPos:=field->idpos
			cIdVD:=field->idvd
			cDatum:=DToS(field->datum)
			cBrDok:=field->brdok
			nIznos:=0
			select pos
			seek cIdPos+cIdVD+cDatum+cBrDok
			do while !EOF() .and. field->idpos==cIdPos .and. field->idvd==cIdVD .and. DToS(field->datum)==cDatum .and. field->brdok==cBrDok
				nIznos += field->kolicina * field->cijena
				if lSiriPrikaz
					? SPACE(8) + ALLTRIM(field->idroba) + "  " + ALLTRIM(STR(field->kolicina * field->cijena, 10, 2))
				endif
				skip
			enddo			
			? SPACE(2) + ALLTRIM(cIdPos) + "-" + ALLTRIM(cBrDok) + "  -> " + ALLTRIM(STR(nIznos,10,2)) 	
			nUkupnoIznos+=nIznos
			select doks
			go nRecNoNext
			endif
		endif
	endif
enddo

if lStampati
	? SPACE(2) + "---------------------"
	? SPACE(2) + "UKUPNO:  " + ALLTRIM(STR(nUkupnoIznos,10,2)) 
	FF
	END PRN2
endif

return
*}


function StampaNezakljRN(cIdRadnik, dDatumOd, dDatumDo)
*{

START PRINT CRET

cZaklj:="N"

select doks
set order to tag 8
go top

hseek gIdPos+cIdRadnik+cZaklj

? SPACE(2),  Date()
? SPACE(2) + "Nezakljuceni racuni:"
? SPACE(2) + "----------------------"
?
? SPACE(2) + "Rn.Br.       Sto"
? SPACE(2) + "----------------"


do while !EOF() .and. field->idpos==gIdPos .and. field->idradnik==cIdRadnik .and. field->datum<=dDatumDo .and. field->datum>=dDatumOd .and. field->zakljucen=="N"
	cBrDok:=doks->brdok
	cIdPos:=doks->idpos
	cBrojStola:=doks->sto

	? SPACE(2) + ALLTRIM(cIdPos) + "-" + ALLTRIM(cBrDok) + "  -> " + ALLTRIM(cBrojStola) 	
	skip
enddo

FF
END PRINT

return
*}


function SetujZakljuceno()
*{
local nCounter

if Pitanje(,"Setovati sve racune na zakljuceno (D/N) ?","N")=="N"
	return
endif

MsgBeep("!!! Ovo je neophodno samo prvi put !!!")

if Pitanje(,"Sto posto sigurni da zelite (D/N) ?","N")=="N"
	return
endif

select doks
set order to tag 0
go top

nCounter:=0

do while !EOF()
	replace field->zakljucen with "Z"
	++ nCounter
	skip
enddo

MsgBeep("Setovano ukupno " + ALLTRIM(STR(nCounter)) + " racuna!!!")

return
*}

