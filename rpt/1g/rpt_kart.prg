#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_kart.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.11 $
 * $Log: rpt_kart.prg,v $
 * Revision 1.11  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.10  2003/01/21 15:01:18  ernad
 * probelm excl stanje artikala - nema problema
 *
 * Revision 1.9  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.8  2002/06/17 13:18:22  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.7  2002/06/14 14:02:43  mirsad
 * prirpeme za doxy dokumenter
 *
 *
 */
 

/*! \file fmk/pos/rpt/1g/rpt_kart.prg
 *  \brief Kartica artikla
 */

/*! \var *integer FmkIni_KumPath_KARTICA_MaxDuzinaBrDok
  * \brief Broj znakova u koloni predviðenih za prikaz broja dokumenta
  * \param 4 - default vrijednost
  */
*integer FmkIni_KumPath_KARTICA_MaxDuzinaBrDok;


/*! \var *string FmkIni_KumPath_KARTICA_SirokiPapir
  * \brief
  * \param D - siri prikaz (za papir formata A4)
  * \param N - prikaz prilagoðen sirini trake POS-stampaèa, default vrijednost
  */
*string FmkIni_KumPath_KARTICA_SirokiPapir;


/*! \var *string FmkIni_PrivPath_TOPS_PrepakPotraz
  * \brief D - prikazati prepakivanje na potraznoj strani
  * \param N - prikazati prepakivanje na dugovnoj strani, default vrijednost
  */
*string FmkIni_PrivPath_TOPS_PrepakPotraz;


/*! \var *string FmkIni_PrivPath_TOPS_KarticaBezPrepakivanja
  * \brief D - omoguæava upit za prikaz dokumenata prepakivanja
  * \param N - uvijek prikazuje dokumente prepakivanja, default vrijednost
  */
*string FmkIni_PrivPath_TOPS_KarticaBezPrepakivanja;


/*! \fn Kartica()
  * \brief Izvjestaj: kartica artikla
  */

function Kartica()
*{
local nStanje
local nSign:=1
local cSt
local nVrijednost
local nCijena:=0
local cRSdbf
local cLM:=""
local nSir:=40

private cIdDio:=SPACE(2)
private cIdOdj:=SPACE(2)
private cDat0:=gDatum
private cDat1:=gDatum
private cPocSt:="D"

nMDBrDok:=VAL(IzFMKINI("KARTICA","MaxDuzinaBrDok","4",KUMPATH))
cSiroki:=IzFMKINI("KARTICA","SirokiPapir","N",KUMPATH)

O_KASE
O_ODJ
O_DIO
O_SIFK
O_SIFV
O_ROBA
O_SIROV
O_POS

cRoba:=SPACE(len(idroba))
cIdPos:=gIdPos
cPPar:="N"     // prikaz partnera

// maska za postavljanje uslova
///////////////////////////////
O_PARAMS
private cSection:="I"
private cHistory:="K"
private aHistory:={}
RPar("d1",@cDat0)
RPar("d2",@cDat1)
RPar("ro",@cRoba)
RPar("sp",@cPPar)

set cursor on
Box(,11,60)
aNiz:={}
if gVrstaRS <> "K"
	@ m_x+1,m_y+2 SAY "Prod.mjesto (prazno-svi) "  GET  cIdPos  valid empty(cIdPos).or.P_Kase(cIdPos) pict "@!"
endif

if gModul=="HOPS"

	if gVodiOdj<>"D"
		cIdOdj:="10"
	endif
	
	@ m_x+2,m_y+2 SAY  "Odjeljenje               " GET cidodj valid P_Odj(@cIdOdj) picture "@!"
	
	if gPostDO=="D"
		@ m_X+3,m_y+2 SAY  "Dio objekta              " GET  cIdDio valid Empty(cIdDio).or.P_Dio(@cIdDio) pict "@!"
	endif

else 

	if gVodiOdj=="D"
		@ m_x+2,m_y+2 SAY  "Odjeljenje               " GET cidodj valid P_Odj(@cIdOdj) picture "@!"
	endif
	
endif  

read

if odj->zaduzuje="S"

	@ m_x+5,m_y+6 SAY "Sifra artikla (prazno-svi)" GET cRoba valid empty(cRoba) .or. P_Sirov(@cRoba) pict "@!"
	
else

	@ m_x+5,m_y+6 SAY "Sifra artikla (prazno-svi)" GET cRoba valid empty(cRoba) .or. P_RobaPos(@cRoba) pict "@!"
	
endif

@ m_x+7,m_y+2 SAY "za period " GET cDat0
@ m_x+7,col()+2 SAY "do " GET cDat1
@ m_x+9,m_y+2 SAY "sa pocetnim stanjem D/N ?" GET cPocSt valid cpocst $ "DN" pict "@!"
@ m_x+10,m_y+2 SAY "Prikaz partnera D/N ?" GET cPPar valid cPPar $ "DN" pict "@!"
@ m_x+11,m_y+2 SAY "Siroki papir    D/N ?" GET cSiroki valid cSiroki $ "DN" pict "@!"
read
ESC_BCR
SELECT params
WPar("d1",cDat0)
WPar("d2",cDat1)
WPar("ro",cRoba)
WPar("sp",cPPar)
SELECT params
use

BoxC()

SELECT ODJ
HSEEK cIdOdj

if gModul=="TOPS"
	cZaduzuje:="R"
	cU:=R_U
	cI:=R_I
	cRSdbf:="ROBA"
else
	if Zaduzuje == "S"
		cZaduzuje:="S"
		cU:=S_U
		cI:=S_I
		cRSdbf:="SIROV"
	else
		cZaduzuje:="R"
		cU:=R_U
		cI:=R_I
		cRSdbf:="ROBA"
	endif
endif

//   1
if gVrstaRS=="S"
	cLM:=SPACE(5)
	nSir:=80
endif

lPrepakPot:=(IzFMKINI("TOPS","PrepakPotraz","N",PRIVPATH)=="D")

if IzFMKIni("TOPS","KarticaBezPrepakivanja","N",PRIVPATH)=="D"
	lBezPrepak := Pitanje(,"Ignorisati dokumente prepakivanja?","D")=="D"
else
	lBezPrepak := .f.
endif

if cPPar=="D"  .or. lPrepakPot
	O_DOKS
	SELECT (F_DOKS)
	// "IdPos+IdVd+dtos(datum)+BrDok"
	SET ORDER TO TAG "1"
endif


SELECT POS
set order to 2      
// "2", "IdOdj+idroba+DTOS(Datum)", ;

if empty(cRoba)
	Seek2(cIdOdj)
else
	Seek2(cIdOdj+cRoba)
endif

EOF CRET


// pravljenje izvjestaja
////////////////////////

START PRINT CRET

if gVrstaRS=="S"
	P_INI
	P_10CPI
endif

ZagFirma()

? PADC("KARTICE ARTIKALA NA DAN "+FormDat1(gDatum),nSir)
? PADC("-----------------------------------",nSir)

if gVrstaRS<>"K"
	if empty(cIdPos)
		? cLM+"PROD.MJESTO: "+cidpos+"-"+"SVE"
	else
		? cLM+"PROD.MJESTO: "+cidpos+"-"+Ocitaj(F_KASE,cIdPos,"Naz")
	endif
endif

if gVodiOdj=="D"
	? cLM+"Odjeljenje : "+cIdOdj+"-"+RTRIM(Ocitaj(F_ODJ,cIdOdj,"naz"))
endif
  
if gModul=="HOPS".and.gPostDO=="D"
	if empty(cIdDio)
		? cLM+"Dio objekta: "+"SVI"
	else
		? cLM+"Dio objekta: "+cIdDio+"-"+RTRIM(Ocitaj(F_DIO, cIdDio,"naz"))
	endif
endif

? cLM+"ARTIKAL    : "+IF(EMPTY(cRoba),"SVI",RTRIM(cRoba))
? cLM+"PERIOD     : "+FormDat1(cDat0)+" - "+FormDat1(cDat1)
?

/*****
Artikal
Dokum.     Ulaz       Izlaz     Stanje    Vrijednost
------- ---------- ---------- ---------- ------------
xx-xxxx 999999.999 999999.999 999999.999 99999999.999
*****/

if gVrstaRS=="S"
	cLM:=SPACE(5)
	? cLM
else
	cLM:=""
	?
endif

?? "Artikal"

if cSiroki=="D"
	? cLM+" Datum   Dokum."+SPACE(nMDBrDok-4)+"     Ulaz       Izlaz     Stanje"
else
	? cLM+"Dokum."+SPACE(nMDBrDok-4)+"     Ulaz       Izlaz     Stanje"
endif

if gVrstaRS=="S"
	?? "    Vrijednost"
endif

if cPPar=="D"
	?? "   Partner"
endif

if gVrstaRS=="S"
	m:=cLM
	if cSiroki=="D"
		m:=m+replicate("-",8)+" "  // datum
	endif
	m:=m+"---"+REPL("-",nMDBrDok)+" ---------- ---------- ---------- ------------"
else
	m:=""
	if cSiroki=="D"
		m:=m+replicate("-",8)+" "  // datum
	endif
	m:=m+"---"+REPL("-",nMDBrDok)+" ---------- ---------- ----------"
endif

if cPPar=="D"
	m+=" --------"
endif


do while !eof() .and. POS->IdOdj==cIdOdj
  nStanje:=0
  nVrijednost:=0
  fSt:=.t.
  cIdRoba:=POS->IdRoba
  nUlaz:=nIzlaz:=0
  SELECT POS

  do while !eof() .and. POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    if (cZaduzuje=="R" .and. pos->idvd=="96") .or. (cZaduzuje=="S".and.pos->idvd$"42#01")
    	skip
	loop
    endif

    if cPocSt=="N"
	SELECT (cRSdbf)
	HSEEK cIdRoba
	nCijena1:=cijena1
	SELECT POS
    	nStanje:=0
    	nVrijednost:=0
    	seek cIdOdj+cIdRoba+DTOS(cDat0)
    else
      // stanje do
      do while !eof() .and. POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba) .and. POS->Datum<cDat0
      	if !empty(cIdDio) .and. POS->IdDio<>cIdDio
		skip
		loop
      	endif
      	if (Klevel>"0" .and. pos->idpos="X") .or. (!empty(cIdPos) .and. IdPos<>cIdPos)
        	// (POS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or. ;  // ?MS
        	skip
		loop
      	endif
      	if (cZaduzuje=="R" .and. pos->idvd=="96") .or. (cZaduzuje=="S".and.pos->idvd$"42#01")
        	skip
		loop
      	endif
      	if POS->idvd $ DOK_ULAZA
        	nStanje += POS->Kolicina
        	//nVrijednost += POS->Kolicina * POS->Cijena
      	elseif Pos->idvd $ "IN"
        	nStanje -= (POS->Kolicina - POS->Kol2 )
        	nVrijednost += (POS->Kol2-POS->Kolicina) * POS->Cijena
      	elseif POS->idvd $ DOK_IZLAZA
        	nStanje -= POS->Kolicina
        	//nVrijednost -= POS->Kolicina * POS->Cijena
      	elseif POS->IdVd == "NI"
        	// ne mijenja kolicinu
        	//nVrijednost := POS->Kolicina * POS->Ncijena
      	endif
      	skip
      enddo
      
      SELECT (cRSdbf)
      HSEEK cIdRoba
      nCijena1:=cijena1
      
      if fSt
        if gVrstaRS=="S" .and. Prow()>63-gPstranica-3
		FF
        endif
        ? m
        ? cLM
        if cSiroki=="D"
		?? space(8)+" "
        endif
        ?? cIdRoba, PADR (AllTrim (Naz)+" ("+AllTrim (Jmj)+")", 32)
        ? m
        nVrijednost:=nStanje * nCijena1
        if gVrstaRS=="S"
		? cLM
	else
		?
	endif
        ?? PADL ("Stanje do "+FormDat1 (cDat0), 29), ""
        ?? STR (nStanje, 10, 3)
        if gVrstaRS == "S"
		?? " " + STR (nCijena1*nStanje, 12, 3)
        endif
        fSt := .F.
      endif
      SELECT POS
    endif // cPocSt

    do while !eof().and.POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba).and.POS->Datum<=cDat1
      if !empty(cIdDio).and.POS->IdDio<>cIdDio
      	skip
	loop
      endif
      
      if (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos).and.IdPos<>cIdPos)
	//    (POS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or. ;  // ?MS
        skip
	loop
      endif
      
      if (cZaduzuje=="R".and.pos->idvd=="96") .or. (cZaduzuje=="S".and.pos->idvd$"42#01")
      	skip
      	loop
      endif

      if gVrstaRS=="S".and.prow()>63-gPStranica
      	FF
      endif
      //
      if fSt
        SELECT (cRSdbf)
	HSEEK cIdRoba
        if gVrstaRS=="S".and.prow()>63-gPstranica-3
        	FF
        endif
        ? m
        ? cLM+cIdRoba,PADR(ALLTRIM(Naz)+" ("+ALLTRIM(Jmj)+")",32)
        ? m
        SELECT POS
        fSt:=.F.
      endif
      //
      
      if POS->idvd $ DOK_ULAZA
      
        if gVrstaRS=="S".and.prow()>63-gPstranica-3
          FF
        endif

        lPrepak:=.f.
	
        if lPrepakPot .and. POS->idvd=="16".and.Ocitaj(F_DOKS,POS->(IdPos+IdVd+dtos(datum)+BrDok),"idvrstep")=="PR"
	
          lPrepak:=.t.
	  
          if lBezPrepak
            skip 1
	    loop
          endif
	  
        endif

        ? cLM
	
        if cSiroki=="D"
          ?? dtoc(pos->datum)+" "
        endif
	
        ?? POS->IdVd+"-"+PADR(AllTrim(POS->BrDok),nMDBrDok),""
	
        if lPrepakPot.and.POS->kolicina<0.and.lPrepak
          ?? SPACE(10), STR(ABS(POS->Kolicina), 10, 3), ""
          nIzlaz += ABS(POS->Kolicina)
        else
          ?? STR (POS->Kolicina, 10, 3), SPACE (10), ""
          nUlaz += POS->Kolicina
        endif
	
        nStanje += POS->Kolicina
        //nVrijednost += POS->Kolicina*POS->Cijena
        ?? STR (nStanje, 10, 3)
	
        if gVrstaRS == "S"
          ?? "", STR (nCijena1*nStanje, 12, 3)
        endif
	
      elseif POS->IdVd == "NI"
      
          // nivelacija
          if gVrstaRS=="S" .and. Prow() > 63-gPstranica-3
            FF
          endif
	  
          //nVrijednost := POS->Kolicina * POS->Ncijena
          ? cLM
	  
          if cSiroki=="D"
            ?? dtoc(pos->datum)+" "
          endif
	  
          ?? POS->IdVd+"-"+PADR (AllTrim(POS->BrDok), nMDBrDok), ""
          ?? "S:", STR (POS->Cijena, 7, 2), "N:", Str (POS->Ncijena, 7, 2),;
             STR (nStanje, 10, 3)
	     
          if gVrstaRS == "S"
            ?? "", Str (nCijena1*nStanje, 12, 3)
          endif
	  
          skip
	  loop  
	  
      elseif POS->idvd $ "IN"+DOK_IZLAZA
      
        if pos->idvd $ DOK_IZLAZA
          nKol := POS->Kolicina
        elseif POS->IdVd == "IN"
          nKol := (POS->Kolicina - POS->Kol2)
        endif
	
        nIzlaz += nKol
	nStanje -= nKol
        //nVrijednost -= nKol * POS->Cijena
        //
	
        if gVrstaRS=="S" .and. Prow() > 63-gPstranica-3
          FF
        endif
	
        //
        ? cLM
	
        if cSiroki=="D"
            ?? dtoc(pos->datum)+" "
        endif
	
        ?? POS->IdVd+"-"+PADR (AllTrim(POS->BrDok), nMDBrDok), ""
        ?? SPACE (10), STR (nKol, 10, 3), STR (nStanje, 10, 3)
	
        if gVrstaRS == "S"
          ?? "", STR (nCijena1*nStanje, 12, 3)
        endif
	
      endif // izlaz, in

      if cPPar=="D"
        ?? " "
        ?? Ocitaj(F_DOKS,POS->(IdPos+IdVd+dtos(datum)+BrDok),"idgost")
      endif

      skip
    enddo
    //
    
    if gVrstaRS=="S" .and. Prow() > 63-gPstranica-3
      FF
    endif
    
    ? m
    ? cLM
    
    if cSiroki=="D"
       ?? space(8)+" "
    endif
    
    ?? " UKUPNO",STR(nUlaz,10,3),STR(nIzlaz,10,3),STR(nStanje,10,3)
      
    if gVrstaRS == "S"
	?? "", STR (nCijena1*nStanje, 12, 3)
    else
    	if cSiroki=="D"
		?  space(9)+"  Cij:",str(nCijena1,8,2),"Ukupno:",STR (nCijena1*nStanje, 12, 3)
	else
		?  "  Cij:",str(nCijena1,8,2),"Ukupno:",STR (nCijena1*nStanje, 12, 3)
	endif
    endif
    
    ? m
    ?
    
    // odvrti viska slogove
    do while !eof().and.POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba).and.POS->Datum>cDat1
      skip
    enddo
    
  enddo
  
  if !empty(cRoba)  // izleti ako je zadata konkretna roba
    exit
  endif
  
enddo // cidodj

PaperFeed ()
END PRINT
CLOSERET
*}


function ZagFirma()
*{
local cStr, nLines, cFajl, i, nOfset:=0

if (!EMPTY(gZagIz))
	cFajl:=PRIVPATH+AllTrim(gRnHeder)
	nLines:=BrLinFajla(cFajl)
	for i:=1 to nLines
		aPom:=SljedLin(cFajl,nOfset)
		cRed:=aPom[1]
		nOfset:=aPom[2]
		if (ALLTRIM(STR(i))$gZagIz)
			? cRed
		endif
	next
endif

return
*}
