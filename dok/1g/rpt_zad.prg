#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/rpt_zad.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.6 $
 * $Log: rpt_zad.prg,v $
 * Revision 1.6  2002/11/21 10:10:45  mirsad
 * debugiranje - pri štampi ruèno unešenog zaduženja ispadao zbog nedefinisane var. nPPP
 *
 * Revision 1.5  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.4  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.3  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.2  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
/*! \fn StampZaduz(cIdVd,cBrDok)
 *  \brief Stampa dokumenta zaduzenja
 *  \param cIdVd   - vrsta dokumenta
 *  \param cBrDok  - broj dokumenta
 */ 
 
function StampZaduz(cIdVd,cBrDok)
*{

local nPrevRec
local cKoje
local nFinZad
local fPred:=.f.
local aTarife := {}
local nPPP
local nPPU
local nOsn
local nPP
nPPP:=0
nPPU:=0
nOsn:=0
nPP:=0

SELECT PRIPRZ   

IF RecCount2()>0
  nPrevRec := RECNO()
  Go Top
  if !SPrint2 (gLocPort)
     MsgBeep ("Dokument nije odstampan!#Pokusajte ponovo kasnije!", 20)
     RETURN (.F.)
  endif

  cPom:=""

  NaslovDok(cIdVd)
  if cIdVD=="16"
    if !empty(IdDio)
       cPom+="PREDISPOZICIJA "
       fPred:=.t.
    else
       cPom+="ZADUZENJE "
    endif
  endif
  if cIdvd=="PD"
    cPom+="PREDISPOZICIJA "
    fpred:=.t.
  endif
  if cIdVd=="98"
  	cPom+="REKLAMACIJA "
  endif

  if gVrstaRS<>"S"
    cPom+= ALLTRIM(PRIPRZ->IdPos)+"-"+ALLTRIM (cBrDok)
  endif
  if fpred
     ? PADC("PRENOS IZ ODJ: "+idodj+"  U ODJ:"+idvrstep,38)
  endif

  ? PADC(cPom,40)
  ? PADL (FormDat1 (PRIPRZ->Datum), 39)
  ?
  if gZadCij=="D"
    ? " Sifra      Naziv            JMJ Kolicina"
    ? "---------- ----------------- --- --------"
    ? "           Nabav.vr.*   PPP   *    MPC   "
    ? "           --------- --------- ----------"
    ? "           MPV-porez*   PPU   *    MPV   "
    ? "-----------------------------------------"
  else
    ? " Sifra      Naziv            JMJ Kolicina"
    ? "---------- ----------------- --- --------"
  endif

  nFinZad := 0
  SELECT PRIPRZ
  GoTop2()
  DO WHILE ! EOF()

    nIzn:=cijena*kolicina
    WhileaTarife(IdRoba, nIzn, @aTarife, @nPPP, @nPPU, @nOsn, @nPP)

    if fpred .and. !empty(IdDio)
     // ne stampaj nista
    else
     ? idroba, PADR (RobaNaz, 17), JMJ, ;
       TRANSFORM (Kolicina, "99999.99")
     IF gZadCij=="D"
       ? SPACE(10), TRANSFORM(ncijena*kolicina,"999999.99"), TRANSFORM (nPPP,"999999.99"), TRANSFORM (cijena,"9999999.99")
       ? SPACE(10), TRANSFORM(nOsn,"999999.99"),             TRANSFORM (nPPU,"999999.99"), TRANSFORM (cijena*kolicina,"9999999.99")
       ? "-----------------------------------------"
     ENDIF
    endif
    nFinZad += PRIPRZ->(Kolicina * Cijena)

    SKIP 1

  ENDDO
  ? "-------- ----------------- --- --------"
  ? PADL ("UKUPNO ZADUZENJE (" + TRIM (gDomValuta) + ")", 29), ;
    TRANS (nFinZad, "999,999.99")
  ? "-------- ----------------- --- --------"

  RekTarife(aTarife)

  ? " Primio " + PADL ("Predao", 31)
  ?
  ? PADL (ALLTRIM (gKorIme), 39)
  PaperFeed()

  END PRN2

  GO nPrevRec
ELSE
  MsgBeep ("Zaduzenje nema nijedne stavke!", 20)
ENDIF
return
*}


/*! \fn PrepisZad(cNazDok)
 *  \brief Prepis zaduzenja
 *  \param cNazDok  - naziv dokumenta
 */
 
function PrepisZad(cNazDok)
*{

local fPred:=.f.
LOCAL nSir := 80, nRobaSir := 40, cLm := SPACE (5), cPicKol := "999999.999"
local aTarife:={}


START PRINT CRET
IF gVrstaRS == "S"
  P_INI
  P_10CPI
Else
  nSir := 40
  nRobaSir := 18
  cLM := ""
  cPicKol := "9999.999"
EndIF


SELECT POS
HSEEK DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
if !empty(doks->idvrstep)  // predispozicija
 fPred:=.t.
 cNazDok:="PREDISPOZICIJA "
endif

cNazDok:=cNazDok+" "
? PADC (cNazDok + IIF (Empty (DOKS->IdPos), "", ALLTRIM (DOKS->IdPos)+"-")+;
        ALLTRIM (DOKS->BrDok), nSir)

SELECT ODJ
HSEEK POS->IdOdj

IF !Empty (POS->IdDio)
  SELECT DIO
  HSEEK POS->IdDio
EndIF

SELECT POS
if fpred
 ? PADC("PRENOS IZ ODJ: "+pos->idodj+"  U ODJ:"+doks->idvrstep,nSir)
else
 ? PADC (ALLTRIM (ODJ->Naz)+IIF (!Empty (POS->IdDio),"-"+AllTrim (DIO->Naz),"");
        , nSir)
endif
? PADC (FormDat1 (DOKS->Datum), nSir)
?
? cLM
IF gVrstaRS == "S"
  ?? "Sifra    Naziv                                    JMJ Cijena   Kolicina"
  m := cLM+"-------- ---------------------------------------- --- ------- ----------"
Else
  ?? "Sifra    Naziv              JMJ Kolicina"
  m := cLM+"-------- ------------------ --- --------"
EndIF
? m

 nFinZad := 0
 SELECT POS
 DO While ! Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
   IF gVrstaRS == "S" .and. Prow() > 63-gPstranica
     FF
   EndIF
   if fPred  // predispozicija
      if !empty(IdDio)
          SKIP
	  loop
      endif
   endif

   ? cLM
   if len(trim(idroba))>8
     ?? IdRoba, ""
   else
     ?? padr(IdRoba,8), ""
   endif
   if POS->MU_I $ S_I+S_U  // odaberi je li sifrarnik roba ili sirovina
     SELECT SIROV          // sirovina ulaz ili sirovina izlaz
   else
     SELECT ROBA
   endif
   HSEEK POS->IdRoba
   ?? PADR (_field->Naz, nRobaSir), _field->Jmj, ""
   SELECT POS
   IF gVrstaRS == "S"
    ?? TRANS (POS->Cijena, "9999.99"), ""
   EndIF
   ?? TRANS (POS->Kolicina, cPicKol)
   nFinZad += POS->(Kolicina * Cijena)
   if gModul="TOPS"
    WhileaTarife(pos->IdRoba, POS->(Kolicina * Cijena) , @aTarife )
   endif
   SKIP
 ENDDO

 IF gVrstaRS == "S" .and. Prow() > 63-gPstranica - 7
   FF
 EndIF
 ? m
 ? cLM


 ?? PADL ("IZNOS DOKUMENTA ("+TRIM (gDomValuta)+")", ;
          IIF (gVrstaRS=="S", 13,10)+nRobaSir), ;
    TRANS (nFinZad, IIF (gVrstaRS=="S", "999,999,999,999.99", "9,999,999.99"))
 ? m
 ?
 ?
 ? cLM

 if gModul=="TOPS"
   RekTarife(aTarife)
 endif


 ?? " Primio", PADL ("Predao", nSir-9)
 SELECT OSOB
 HSEEK DOKS->IdRadnik
 ? PADL (ALLTRIM (OSOB->Naz), nSir-9)
 IF gVrstaRS == "S"
   FF
 Else
   PaperFeed()
 EndIF
 END PRINT
 SELECT DOKS
return
*}

