#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_por.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.13 $
 * $Log: rpt_por.prg,v $
 * Revision 1.13  2003/12/24 09:54:36  sasavranic
 * Nova varijanta poreza, uvrstene standardne funkcije za poreze iz FMK
 *
 * Revision 1.12  2003/08/20 13:37:30  mirsad
 * omogucio ispis poreza na svakoj stavci i na prepisu racuna, kao i na realizaciji kase po robama
 *
 * Revision 1.11  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.10  2003/06/24 13:15:09  sasa
 * no message
 *
 * Revision 1.9  2002/07/06 11:14:51  ernad
 *
 *
 * debug porez po tarifama za gVrstaRs="S"
 *
 * Revision 1.8  2002/06/17 13:18:22  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.7  2002/06/17 12:44:20  sasa
 * no message
 *
 * Revision 1.6  2002/06/17 11:45:25  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.5  2002/06/17 08:57:34  mirsad
 * no message
 *
 * Revision 1.4  2002/06/14 14:02:43  mirsad
 * prirpeme za doxy dokumenter
 *
 *
 */


/*! \file fmk/pos/rpt/1g/rpt_por.prg
 *  \brief Rekapitulacija poreza po tarifama
 */

/*! \var *string FmkIni_ExePath_POREZI_PPUgostKaoPPU
 *  \brief Nacin racunanja poreza u maloprodaji/ugostiteljstvu
 *  \param N - default vrijednost, standardno raèunanje PPP i PPU ako su > 0%
 *  \param D - samo za ugostiteljstvo
 *  \param R - samo za ugostiteljstvo
 *  \param M - samo za ugostiteljstvo: racunanje poreza na RUC po osnovu donjeg limita
 */


//   cDat0 - pocetni datum,
//   cDat1 - krajni datum
//   cIdPos - sifra odjeljenja - prodajnog mjesta
//   cNaplaceno := 1 - bez obzira na naplaceno
//                 3 - samo naplaceno
// - pravi izvjestaj "Porezi po tarifama" za zadani vremenski period


/*! \fn PorPoTar(cDat0,cDat1,cIdPos,cNaplaceno,cIdOdj)
 *  \param cDat0
 *  \param cDat1
 *  \param cIdPos
 *  \param cNaplaceno
 *  \param cIdOdj
 *  \brief Izvjestaj: rekapitulacija poreza po tarifama
 */

*function PorPoTar(cDat0,cDat1,cIdPos,cNaplaceno,cIdOdj)
*{

function PorPoTar
parameters cDat0, cDat1, cIdPos, cNaplaceno, cIdOdj

local aNiz := {}
local fSolo
local aTarife := {}

private cTarife := SPACE (30)
private aUsl := ".t."

if cNaplaceno==nil
	cNaplaceno:="1"
endif

if (pcount()==0)
	fSolo := .t.
else
	fSolo := .f.
endif

if fSolo
	private cDat0:=gDatum
	private cDat1:=gDatum
	private cIdPos:=SPACE(2)
	private cNaplaceno:="1"
endif

if (cIdOdj==nil)
	cIdOdj:=space(2)
endif

// otvaranje potrebnih baza
///////////////////////////
O_TARIFA

if fSolo
	if gSifK=="D"
		O_SIFK
		O_SIFV
	endif
	O_KASE
	O_ROBA
	O_ODJ
	O_DOKS
	O_POS
endif

// maska za postavljanje uslova
///////////////////////////////
if gVrstaRS<>"S"
	cIdPos:=gIdPos
endif

if fSolo
	if gVrstaRS<>"K"
		AADD (aNiz, {"Prod.mjesto (prazno-svi)    ","cIdPos","cIdPos='X' .or. empty(cIdPos).or.P_Kase(cIdPos)","@!",} )
	endif
	
	if gVodiOdj=="D"
		AADD (aNiz, {"Odjeljenje (prazno-sva)", "cIdOdj", ".t.","@!",})
	endif
	
	AADD (aNiz, {"Tarife (prazno sve)", "cTarife",,"@S10",} )
	AADD (aNiz, {"Izvjestaj se pravi od datuma","cDat0",,,} )
	AADD (aNiz, {"                   do datuma","cDat1",,,} )

	do while .t.
	      if !VarEdit(aNiz, 10,5,17,74,'USLOVI ZA IZVJESTAJ "POREZI PO TARIFAMA"',"B1")
		CLOSERET
	      endif
	      aUsl := Parsiraj(cTarife,"IdTarifa")
	      if aUsl<>nil.and.cDat0<=cDat1
		exit
	      elseif aUsl==nil
	      	MsgBeep ("Kriterij za tarife nije korektno postavljen!")
	      else
	      	Msg("'Datum do' ne smije biti stariji nego 'datum od'!")
	      endif
	enddo

	// pravljenje izvjestaja
	////////////////////////
	START PRINT CRET
	ZagFirma()

endif // fsolo


do while .t.

	// petlja radi popusta
	aTarife:={}  // inicijalizuj matricu tarifa

	if fSolo
		?? gP12cpi
		
		if cNaplaceno=="3"
			? PADC("**** OBRACUN ZA NAPLACENI IZNOS ****",40)
		endif
		
		? PADC("POREZI PO TARIFAMA NA DAN "+FormDat1(gDatum),40)
		? PADC("-------------------------------------",40)
		?
		? "PROD.MJESTO: "
		
		if gVrstaRS<>"K"
			?? cIdPos+"-"
			if (empty(cIdPos))
				?? "SVA" 
			else
				?? cIdPos+"-"+Alltrim (Ocitaj (F_KASE, cIdPos, "Naz"))
			endif
		else
			?? gPosNaz
		endif
		
		if !empty(cIdOdj)
			? "  Odjeljenje:", cIdOdj
		endif
		
		? "      Tarife:", Iif (Empty (cTarife), "SVE", cTarife)
		? "PERIOD: "+FormDat1(cDat0)+" - "+FormDat1(cDat1)
		?
		
	else // fsolo
		?
		if cNaplaceno=="3"
			? PADC("**** OBRACUN ZA NAPLACENI IZNOS ****",40)
		endif
		? PADC ("REKAPITULACIJA POREZA PO TARIFAMA", 40)
		? PADC ("---------------------------------", 40)
		?
	endif // fsolo

	SELECT POS
	SET ORDER TO 1
	
	private cFilter:=".t."
	
	if !(aUsl==".t.")
		cFilter+=".and."+ aUsl
	endif
	
	if !empty(cIdOdj)
		cFilter+=".and. IdOdj="+cm2str(cIdOdj)
	endif
	
	if !(cFilter==".t.")
		set filter to &cFilter
	endif

	SELECT DOKS
	set order to 2

	nTotOsn:=0
	nTotPPP:=0
	nTotPPU:=0
	nTotPP:=0

	m:=REPLICATE("-",6)+" "+REPLICATE("-",10)+" "+REPLICATE("-",8)+" "+REPLICATE("-",8)

	nTotOsn:=0
	nTotPPP:=0
	nTotPPU:=0

	// matrica je lok var : aTarife:={}
	// filuj za poreze, VD_PRR - realizacija iz predhodnih sezona
	aTarife:=Porezi(VD_RN, cDat0, aTarife, cNaplaceno)
	aTarife:=Porezi(VD_PRR, cDat0, aTarife, cNaplaceno)

	ASORT (aTarife,,, {|x, y| x[1] < y[1]})
	fPP:=.f.
	
	for nCnt:=1 to LEN(aTarife)
		if round(aTarife[nCnt][5],4)<>0
			fPP:=.t.
		endif
	next
	
	? m
	? "Tarifa", PADC ("MPV B.P.", 10), PADC ("P P P", 8), PADC ("P P U", 8)
	? "      ", padC ("- MPV -",10)  , padc("",9)
	
	if fPP
		?? padc (" P P  ",8)
	endif
	
	? m
	altd()	
	for nCnt := 1 to LEN(aTarife)
		select tarifa
		hseek aTarife[nCnt][1]
		nPPP:=tarifa->opp
		nPPU:=tarifa->ppp
		select doks

		// ispisi opis i na realizaciji kao na racunu
		? aTarife[nCnt][1], "(PPP:" + STR(nPPP) + "%, ", "PPU:" + STR(nPPU) + "%)"
		
		? aTarife[nCnt][1], STR(aTarife[nCnt][2],10,2), STR(aTarife[nCnt][3],8,2), STR(aTarife[nCnt][4],8,2)
		
		//? space(6), STR( round(aTarife[nCnt][2],2)+;
		//                 round(aTarife[nCnt][3],2)+;
		//                 round(aTarife[nCnt][4],2)+;
		//                 round(aTarife[nCnt][5],2), 10,2),;
		//                 space(9)
		
		? space(6), STR( round(aTarife[nCnt][6],2), 10,2),space(9)

		if fPP
			?? str(aTarife [nCnt][5], 8, 2)
		endif

		//nTotOsn += round(aTarife [nCnt][2],2)
		nTotOsn+=round(aTarife[nCnt][6],2)-round(aTarife[nCnt][3],2)-round(aTarife[nCnt][4],2)-round(aTarife[nCnt][5],2)
		nTotPPP+=round(aTarife[nCnt][3],2)
		nTotPPU+=round(aTarife[nCnt][4],2)
		nTotPP+=round(aTarife[nCnt][5],2)
	next
	
	? m
	? "UKUPNO", STR (nTotOsn, 10, 2), STR (nTotPPP, 8, 2), STR (nTotPPU, 8, 2)
	? SPACE(6),str(nTotOsn+nTotPPP+nTotPPU+nTotPP,10,2),space(9)

	if fPP
		?? str(nTotPP,8,2)
	endif

	? m
	?
	?

	if !fsolo
		exit
	endif

	if cNaplaceno=="1"  // prvi krug u dowhile petlji
		cNaplaceno:="3"
	else
		// vec odradjen drugi krug
		exit
	endif

enddo // petlja radi popusta


if gVrstaRS<>"S"
	PaperFeed ()
endif

if fSolo
	END PRINT
endif

set filter to
CLOSERET
*}


// cIdvd - tip dokumenta za koji se obracun poreza vrsi
// cDat0 - pocetni datum
// aTarife - puni se matrica aTarife
//
// private: cDat1 - krajnji datum
//

/*! \fn Porezi(cIdVd,cDat0,aTarife,cNaplaceno)
 *  \brief Pravi matricu sa izracunatim porezima za zadani period
 *  \return aTarife - matrica izracunatih poreza po tarifama
 */

function Porezi(cIdVd,cDat0,aTarife,cNaplaceno)
*{
if cNaplaceno==nil
	cNaplaceno:="1"
endif

SELECT DOKS
seek cIdVd+DTOS(cDat0)              // realizaciju skidam sa racuna

do while !EOF().and.DOKS->IdVd==cIdVd.and.DOKS->Datum<=cDat1

	if (Klevel>"0".and.doks->idpos="X").or.(DOKS->IdPos="X".and.AllTrim(cIdPos)<>"X").or.(!empty(cIdPos).and.cIdPos<>DOKS->IdPos)
		skip
		loop
	endif
	
	SELECT POS
	seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
	
	do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
	
		SELECT TARIFA
		HSEEK POS->IdTarifa
		
		if cNaplaceno=="1"
		
			nIzn:=pos->(Cijena*Kolicina)
			
		else  // cnaplaceno="3"
		
			select roba
			hseek pos->idroba
			select odj
			hseek roba->idodj
			nNeplaca:=0
			
			if right(odj->naz,5)=="#1#0#"  // proba!!!
				nNeplaca:=pos->(Kolicina*Cijena)
			elseif right(odj->naz,6)=="#1#50#"
				nNeplaca:=pos->(Kolicina*Cijena)/2
			endif
			
			if gPopVar="P"
				nNeplaca+=pos->(kolicina*NCijena)
			endif
			
			if gPopVar=="A"
				nIzn:=pos->(Cijena*kolicina)-nNeplaca+pos->ncijena
			else
				nIzn:=pos->(Cijena*kolicina)-nNeplaca
			endif
			
		endif
		
		SELECT POS
		//nPPU := nIzn * (1 - 100 / (100+TARIFA->PPP))
		//nPPP := (nIzn - nPPU) * (1 - 100 / (100+TARIFA->OPP))
		//nOsn := nIzn - nPPU - nPPP
		if IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
		 	nOsn:=nIzn/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
			nPPP:=nOsn*tarifa->opp/100
			nPP :=(nOsn+nPPP)*tarifa->zpp/100
		else
			nOsn:=nIzn/(tarifa->zpp/100+(1+tarifa->opp/100)*(1+tarifa->ppp/100))
			nPPP:=nOsn*tarifa->opp/100
			nPP :=nOsn*tarifa->zpp/100
		endif
		nPPU:=(nOsn+nPPP)*tarifa->ppp/100
		
		if gStariObrPor
			nPoz:=ASCAN(aTarife,{|x| x[1]==POS->IdTarifa})
			if nPoz==0
				AADD(aTarife,{POS->IdTarifa,nOsn,nPPP,nPPU,nPP,nIzn})
			else
				aTarife[nPoz][2] += nOsn
				aTarife[nPoz][3] += nPPP
				aTarife[nPoz][4] += nPPU
				aTarife[nPoz][5] += nPP
				aTarife[nPoz][6] += nIzn
			endif
		
		else //stari obr poreza
			aPorezi:={}
			SetAPorezi(@aPorezi)	
			aIPor:=RacPorezeMP(aPorezi, nOsn, nIzn, 0)
			nPoz:=ASCAN(aTarife,{|x| x[1]==POS->IdTarifa})
  			if nPoz==0
				AADD(aTarife,{POS->IdTarifa,nOsn,aIPor[1],aIPor[2],aIPor[3],nIzn})
			else
				aTarife[nPoz][2] += nOsn
				aTarife[nPoz][3] += aIPor[1]
				aTarife[nPoz][4] += aIPor[2]
				aTarife[nPoz][5] += aIPor[3]
				aTarife[nPoz][6] += nIzn
			endif
		endif
	
		skip
	enddo
	
	SELECT DOKS
	skip
enddo
return aTarife
*}



function POSRekapTar(aRekPor)
*{
local lPP
local nPPP
local nPPU
local nPP
local nCnt
local nArr

nArr:=SELECT()

O_TARIFA

ASORT(aRekPor,,, {|x, y| x[1] < y[1]})
lPP:=.f. // ima posebnog poreza

for i:=1 to len(aRekPor)
	if round(aRekPor[i,4],4)<>0
		lPP:=.t.
		exit
	endif
next

? " U iznos uracunati porezi "
? " T.br.    PPP     PPU     PP     Iznos"

nPPP:=0
nPPU:=0
nPP:=0

for nCnt:=1 to len(aRekPor)
        ? " T" + PADR(aRekPor[nCnt][1],4)
        select tarifa
	seek2(aRekPor[nCnt,1]) 
        ?? " (PPP "+STR(tarifa->opp,2,0)+"%,PPU "+STR(tarifa->ppp,2,0) + "%,PP "+ STR(tarifa->zpp,2,0)+"%)"
	select (nArr)
	? SPACE(6)
      	?? " " + STR(aRekPor[nCnt][2],7,N_ROUNDTO) + " " + STR(aRekPor[nCnt][3],7,N_ROUNDTO) + " " + STR(aRekPor[nCnt][4],7,N_ROUNDTO)+ " " 
	?? STR( round(aRekPor[nCnt][2],N_ROUNDTO) + round(aRekPor[nCnt][3],N_ROUNDTO) + round(aRekPor[nCnt][4],N_ROUNDTO), 7, N_ROUNDTO)
      	nPPP+=round(aRekPor[nCnt][2],N_ROUNDTO)
      	nPPU+=round(aRekPor[nCnt][3],N_ROUNDTO)
      	nPP+=round(aRekPor[nCnt][4],N_ROUNDTO)
next

// stampaj ukupno
? " " + REPLICATE ("-", 38)
? " UKUPNO" + STR(nPPP,7,N_ROUNDTO) + " " +STR(nPPU,7,N_ROUNDTO) + " " + STR(nPP,7,N_ROUNDTO) + " " +STR(nPPP+nPPU+nPP,7,N_ROUNDTO)

return
*}

