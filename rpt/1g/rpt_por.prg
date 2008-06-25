#include "pos.ch"

static LEN_TRAKA := 40

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
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


/*! \fn PDVPorPoTar(cDat0,cDat1,cIdPos,cNaplaceno,cIdOdj)
 *  \param cDat0
 *  \param cDat1
 *  \param cIdPos
 *  \param cNaplaceno
 *  \param cIdOdj
 *  \brief Izvjestaj: rekapitulacija poreza po tarifama
 */

*function PorPoTar(cDat0,cDat1,cIdPos,cNaplaceno,cIdOdj)
*{

function PDVPorPoTar
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

O_TARIFA

if fSolo
	O_SIFK
	O_SIFV
	O_KASE
	O_ROBA
	O_ODJ
	O_DOKS
	O_POS
endif

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

	START PRINT CRET
	ZagFirma()

endif // fsolo


do while .t.

	// petlja radi popusta
	aTarife:={}  // inicijalizuj matricu tarifa

	if fSolo
		?? gP12cpi
		
		if cNaplaceno=="3"
			? PADC("**** OBRACUN ZA NAPLACENI IZNOS ****", LEN_TRAKA)
		endif
		
		? PADC("POREZI PO TARIFAMA NA DAN "+FormDat1(gDatum), LEN_TRAKA)
		? PADC("-------------------------------------", LEN_TRAKA)
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
		
		? "     Tarife:", Iif (Empty (cTarife), "SVE", cTarife)
		? "PERIOD: "+FormDat1(cDat0)+" - "+FormDat1(cDat1)
		?
		
	else // fsolo
		if ( grbReduk < 1 )
			?
		endif
		if cNaplaceno=="3"
			? PADC("**** OBRACUN ZA NAPLACENI IZNOS ****", LEN_TRAKA)
		endif
		? PADC ("REKAPITULACIJA POREZA PO TARIFAMA", LEN_TRAKA)
		if ( grbReduk < 1 )
			? PADC ("---------------------------------", LEN_TRAKA)
		endif
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

	m:=REPLICATE("-",12)+" "+REPLICATE("-",12)+" "+REPLICATE("-",12)

	nTotOsn:=0
	nTotPDV:=0

	// matrica je lok var : aTarife:={}
	// filuj za poreze, VD_PRR - realizacija iz predhodnih sezona
	aTarife:=Porezi(VD_RN, cDat0, aTarife, cNaplaceno)
	aTarife:=Porezi(VD_PRR, cDat0, aTarife, cNaplaceno)

	ASORT (aTarife,,, {|x, y| x[1] < y[1]})
	
	? m
	
	? "Tarifa (Stopa %)"
	? PADL ("MPV bez PDV", 12), PADL ("PDV", 12), PADL("MPV sa PDV",12)
	
	? m

	for nCnt := 1 to LEN(aTarife)
		
		select tarifa
		hseek aTarife[nCnt][1]
		nPDV:=tarifa->opp
		select doks

		// ispisi opis i na realizaciji kao na racunu
		? aTarife[nCnt][1], "(" + STR(nPDV) + "%)"
		
		? STR(aTarife[nCnt][2],12,2), STR(aTarife[nCnt][3],12,2),STR( round(aTarife[nCnt][6],2), 12,2)

		nTotOsn+=round(aTarife[nCnt][6],2)-round(aTarife[nCnt][3],2)
		nTotPDV+=round(aTarife[nCnt][3],2)
	next
	
	? m
	? "UKUPNO:"
	? STR (nTotOsn, 12, 2), STR (nTotPDV, 12, 2),STR(nTotOsn+nTotPDV, 12, 2)
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


