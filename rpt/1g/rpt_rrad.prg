#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_rrad.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.7 $
 * $Log: rpt_rrad.prg,v $
 * Revision 1.7  2003/07/08 10:58:29  mirsad
 * uveo fmk.ini/kumpath/[POS]/Retroaktivno=D za mogucnost ispisa azur.racuna bez teksta "PREPIS" i za ispis "datuma do" na realizaciji umjesto tekuceg datuma
 *
 * Revision 1.6  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.5  2003/04/24 20:45:02  mirsad
 * prenos TOPS->FAKT
 *
 * Revision 1.4  2002/06/17 13:18:22  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.3  2002/06/17 11:45:25  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.2  2002/06/14 14:02:43  mirsad
 * prirpeme za doxy dokumenter
 *
 *
 */

/*! \file fmk/pos/rpt/1g/rpt_rrad.prg
 *  \brief Izvjestaj: realizacija radnika
 */

/*! \fn RealRadnik(fTekuci,fPrik,fZaklj)
 *  \param fTekuci
 *  \param fPrik
 *  \param fZaklj
 *  \brief Izvjestaj: realizacija radnika
 *  \return .t. 
 */

*function RealRadnik(fTekuci,fPrik,fZaklj)
*{
function RealRadnik
PARAMETERS fTekuci, fPrik, fZaklj

PRIVATE cIdRadnik:=SPACE(4)
PRIVATE cVrsteP:=SPACE(60)
PRIVATE aUsl1 := ".t."
PRIVATE cSmjena:=SPACE(1)
PRIVATE cIdPos:=gIdPos
PRIVATE cIdDio := gIdDio
PRIVATE dDatOd:=gDatum
PRIVATE dDatDo:=gDatum
PRIVATE aNiz
private cGotZir:=" "

//? "SC:", gDatum, dDatOd, dDatDo
//sleep(10)

fPrik := IIF (fPrik==NIL, "P", fPrik)
fZaklj := IIF (fZaklj==NIL, .F., fZaklj)

if gSifK=="D"
	O_SIFK
	O_SIFV
endif

O_DIO
O_KASE
O_ODJ
O_ROBA

IF !fZaklj
	O_OSOB
	set order to tag ("NAZ")
EndIF

O_VRSTEP
O_POS
O_DOKS

private fPrikPrem:="N"

if roba->(fieldpos("K7"))<>0
	fPrikPrem:="D"
endif


IF fTekuci
  cIdRadnik := gIdRadnik
  IF gRadniRac == "D"
    cSmjena   := ""             // ako radnik prelazi u narednu smjenu
  Else
    cSmjena := gSmjena
  EndIF
  dDatOd := dDatDo := gDatum
ELSE
  aNiz := {}
  cIdPos := gIdPos
  IF gVrstaRS <> "K"
    if gModul=="HOPS"
      cIdDio := SPACE (LEN (gIdDio))
      AADD(aNiz,{"Dio objekta (prazno-svi)","cIdDio","empty(cIdDio). or. P_Dio(@cIdDio)","@!",})
    endif
    AADD(aNiz,{"Prodajno mjesto (prazno-sve)","cIdPos","cidpos='X' .or. empty(cIdPos) .or. P_Kase(@cIdPos)","@!",})
  ENDIF
  AADD(aNiz,{"Sifra radnika  (prazno-svi)","cIdRadnik","IF(!EMPTY(cIdRadnik),P_OSOB(@cIdRadnik),.t.)",,})
  AADD(aNiz,{"Vrsta placanja (prazno-sve)","cVrsteP",,"@!S30",})
  if IsTigra()
  	AADD(aNiz,{"Placanje (G-gotovinsko,Z-ziralno,prazno-sva)","cGotZir","cGotZir$'GZ '","@!",})
  endif
  AADD(aNiz,{"Smjena (prazno-sve)","cSmjena",,,})
  AADD(aNiz,{"Izvjestaj se pravi od datuma","dDatOd",,,})
  AADD(aNiz,{"                   do datuma","dDatDo",,,})
  if fPrikPrem=="D"
     AADD(aNiz,{"Prikaz kolicina za premirane artikle ","fPrikPrem","fprikPrem$'DN'","@!",})
  endif


  fPrik:="O"
  AADD(aNiz,{"Prikazi Pazar/Robe/Oboje (P/R/O)","fPrik","fPrik$'PRO'","@!",})
  DO WHILE .t.
    IF !VarEdit(aNiz,10,5,13+LEN(aNiz),74,'USLOVI ZA IZVJESTAJ "REALIZACIJA"',"B1")
      CLOSERET
    ENDIF
    aUsl1:=Parsiraj(cVrsteP,"IdVrsteP")
    if aUsl1<>NIL.and.dDatOd<=dDatDo
      exit
    elseif aUsl1==NIL
      Msg("Kriterij za vrstu placanja nije korektno postavljen!")
    else
      Msg("'Datum do' ne smije biti stariji nego 'datum od'!")
    endif
  EndDO
ENDIF

aDbf := {}
AADD (aDbf, {"IdRadnik", "C",  4, 0})
AADD (aDbf, {"IdVrsteP", "C",  2, 0})
AADD (aDbf, {"IdRoba"  , "C", 10, 0})
AADD (aDbf, {"IdCijena", "C",  1, 0})
AADD (aDbf, {"Kolicina", "N", 15, 3})
AADD (aDbf, {"Iznos",    "N", 20, 5})
AADD (aDbf, {"Iznos2",   "N", 20, 5})
AADD (aDbf, {"Iznos3",   "N", 20, 5})
NaprPom (aDbf)
USEX (PRIVPATH+"POM") NEW
INDEX ON IdRadnik+IdVrsteP+IdRoba+IdCijena TAG ("1") TO (PRIVPATH+"POM")
INDEX ON IdRoba+IdCijena TAG ("2") TO (PRIVPATH+"POM")
index ON BRISANO TAG "BRISAN"
set order to 1

if ftekuci
  IF fZaklj
    START PRINT2 CRET gLocPort, .F.
  Else
    START PRINT CRET
  EndIF

  ZagFirma()

  ?
  IF fPrik $ "PO"
    ?? PADC (IIF (fZaklj, "ZAKLJUCENJE", "PAZAR")+" RADNIKA", 40)
  Else
    ?? PADC ("REALIZACIJA RADNIKA PO ROBAMA", 40)
  EndIF
  ? PADC (gPosNaz)
  IF !Empty (gIdDio)       // ???
    ? PADC (gDioNaz, 40)
  EndIF
  ?
  SELECT OSOB
  HSEEK gIdRadnik
  ? PADC (AllTrim (OSOB->Naz), 40)
  cTxt := "Na dan: "+FormDat1 (gDatum)
  IF gRadniRac == "N"
    cTxt += " u smjeni " + gSmjena
  EndIF
  ? PADC (cTxt, 40)
  ?
else
  START PRINT CRET
  ZagFirma()
  ?? gP12cpi
  ?
  if glRetroakt
  	? PADC("REALIZACIJA NA DAN "+FormDat1(dDatDo),40)
  else
  	? PADC("REALIZACIJA NA DAN "+FormDat1(gDatum),40)
  endif
  ? PADC("-------------------------------------",40)
  ? "PROD.MJESTO: "+cidpos+"-"+IF(EMPTY(cIdPos),"SVA",Ocitaj (F_KASE, cIdPos,"Naz"))
  ? "RADNIK     : "+IF(EMPTY(cIdRadnik),"svi",cIdRadnik+"-"+RTRIM(Ocitaj(F_OSOB,cIdRadnik,"naz")))
  ? "VR.PLACANJA: "+IF(EMPTY(cVrsteP),"sve",RTRIM(cVrsteP))
  if IsTigra()
  	if empty(cGotZir)
	  ? "PLACANJE   : gotovinsko i ziralno"
	else
	  ? "PLACANJE   : "+if(cGotZir<>"Z","gotovinsko","ziralno")
	  aUsl1+=".and. placen"+if(cGotZir<>"Z","<>'Z'","=='Z'")
	endif	
  endif
  IF ! EMPTY (cSmjena)
    ? "SMJENA     : "+RTRIM(cSmjena)
  ENDIF
  IF ! Empty (gIdDio)
    ? "DIO OBJEKTA: "+IF(EMPTY(cIdDio),"SVI",Ocitaj (F_DIO, cIdDio,"Naz"))
  ENDIF
  ? "PERIOD     : "+FormDat1(dDatOd)+" - "+FormDat1(dDatDo)
  ?
  ? "SIFRA PREZIME I IME RADNIKA"
  ? "-----", REPLICATE ("-", 30)
endif // fTekuci

SELECT DOKS
set order to 2       // "DOKSi2", "IdVd+DTOS (Datum)+Smjena"
IF !(aUsl1==".t.")
  SET FILTER TO &aUsl1
ENDIF

// formiram pomocnu datoteku sa podacima o realizaciji
IF !fTekuci
  RadnIzvuci (VD_PRR)
EndIF
RadnIzvuci (VD_RN)

// ispis izvjestaja
IF fPrik $ "PO"
  nTotal := 0
  nTotal2 := 0
  nTotal3 := 0
  SELECT POM
  set order to 1
  GO TOP
  do While !Eof()
    _IdRadnik := POM->IdRadnik
    nTotRadn := 0
    nTotRadn2:=0
    nTotRadn3:=0
    IF ! fTekuci
      SELECT OSOB
      HSEEK _IdRadnik
      ? OSOB->ID + "  " + PADR (OSOB->Naz, 30)
      ? REPLICATE ("-", 40)
      SELECT POM
    Else
      ? Space (5)+PADR ("Vrsta placanja", 24), PADC("Iznos", 10)
      ? Space (5)+REPL ("-", 24), REPL ("-", 10)
    EndIF

    nKolicO:=0    // kolicina za ostale
    nKolicPr:=0  // kolicina za premirane
    do While !Eof() .and. POM->IdRadnik == _IdRadnik
      _IdVrsteP := POM->IdVrsteP
      nTotVP := 0
      nTotVP2:=0
      nTotVP3:=0
      do while !Eof() .and. POM->(IdRadnik+IdVrsteP)==(_IdRadnik+_IdVrsteP)
        nTotVP += POM->Iznos
        nTotVP2 += pom->iznos2
        nTotVP3 += pom->iznos3

        if fPrikPrem=="D"
         select roba
	 hseek pom->idroba
	 select pom
         if !(roba->k2='X')
            if roba->k7='*'
                nKolicPr+=pom->kolicina
            else
                nKolicO+=pom->kolicina
            endif
         endif
        endif // fPrikPrem=="D"
        SKIP
      EndDO
      SELECT VRSTEP
      HSEEK _IdVrsteP
      ? SPACE (5) + PADR (VRSTEP->Naz, 24), STR (nTotVP, 10, 2)
      
      nTotRadn += nTotVP
      nTotRadn2+= nTotVP2
      nTotRadn3+= nTotVP3

      SELECT POM
    EndDO

    ? REPLICATE ("-", 40)
    if fPrikPrem=="D"
       ?
       ?  padl("Kolicina - premirani - k7='*' ",29,"."), str(nKolicPr,10,2)
       ?  padl("Kolicina - ostali artikli",29,), str(nKolicO,10,2)
       ?
    endif

    ? PADL ("UKUPNO RADNIK ("+_idradnik+"):", 29), STR (nTotRadn, 10, 2)
    if nTotRadn2<>0
      ? PADL ("PARTICIPACIJA:", 29), STR (nTotRadn2, 10, 2)
    endif
    if nTotRadn3<>0
      ? PADL (NenapPop() , 29), STR (nTotRadn3, 10, 2)
      ? PADL ("UKUPNO NAPLATA:", 29), STR (nTotRadn-nTotRadn3+nTotRadn2, 10, 2)
    endif
    ? REPLICATE ("-", 40)

    nTotal += nTotRadn
    nTotal2+=nTotRadn2
    nTotal3+=nTotRadn3
  EndDO

  IF EMPTY (cIdRadnik)
    ?
    ? REPLICATE ("=", 40)
    ? PADC ("SVI RADNICI UKUPNO:", 25), STR (nTotal, 14, 2)
    if nTotal2<>0
      ? PADL ("PARTICIPACIJA:", 29), STR (nTotal2, 10, 2)
    endif
    if nTotal3<>0
      ? PADL (NenapPop(), 29), STR (nTotal3, 10, 2)
      ? PADL ("UKUPNO NAPLATA:", 29), STR (nTotal-nTotal3+nTotal2, 10, 2)
    endif
    ? REPLICATE ("=", 40)
  ENDIF
EndIF

IF fPrik $ "RO"
  IF ! fTekuci
    ?
    ?
    ? PADC ("REALIZACIJA PO ROBAMA", 40)
  EndIF
  ?
  ? PADR ("Sifra", 10), PADR ("Naziv robe", 21)
  ? PADL ("Set c.", 11), PADC ("Kolicina", 12), PADC ("Iznos", 15)
  ? REPL ("-", 11), REPL ("-", 12), REPL ("-", 15)
  SELECT POM
  set order to 2
  GO TOP
  nTotal := 0
  nTotal2 := 0
  nTotal3 := 0
  do While !EOF()
    SELECT ROBA
    HSEEK POM->IdRoba
    SELECT POM
    ? POM->IdRoba+" "
    if roba->(fieldpos("K7"))<>0
      ?? PADR (ROBA->Naz, 23)+roba->k7
    else
      ?? PADR (ROBA->Naz, 21)
    endif
    _IdRoba := POM->IdRoba
    nRobaIzn := 0
    nRobaIzn2 := 0
    nRobaIzn3 := 0
    do while !Eof() .and. POM->IdRoba==_IdRoba
      _IdCijena := POM->IdCijena
      nIzn := 0
      nIzn2 := 0
      nIzn3 := 0
      nKol := 0
      do While !Eof() .and. POM->(IdRoba+IdCijena)==(_IdRoba+_IdCijena)
        nKol += POM->Kolicina
        nIzn += POM->Iznos
        nIzn2 += POM->Iznos2
        nIzn3 += POM->Iznos3
        SELECT POM
        SKIP
      EndDO
      ? PADL (_IdCijena, 11), STR (nKol, 12, 3), STR (nIzn, 15, 2)
      nTotal += nIzn
      nTotal2 += nIzn2
     nTotal3 += nIzn3
    EndDO
  EndDO
  ? REPL ("=", 40)
  ? PADL ("U K U P N O", 24), STR (nTotal, 15, 2)
  if nTotal2<>0
      ? PADL ("PARTICIPACIJA:", 24), STR (nTotal2, 15, 2)
  endif
  if nTotal3<>0
      ? PADL (NenapPop(), 24), STR (nTotal3, 15, 2)
      ? PADL ("UKUPNO NAPLATA:", 24), STR (nTotal-nTotal3+nTotal2, 15, 2)
  endif
  ? REPL ("=", 40)
ENDIF
IF fTekuci
  PaperFeed()
  IF fZaklj
    END PRN2
  Else
    END PRINT
  EndIF
ELSE
  END PRINT
ENDIF
IF fZaklj
  C_RealRadn()
Else
  CLOSE ALL
Endif
return .t.
*}


/*! \fn C_RealRadn()
 *  \brief Zatvaranje baza koristenih u izvjestaju realizacije po radnicima
 */

function C_RealRadn()
*{
SELECT DIO
	USE
SELECT KASE
	USE
SELECT ROBA
	USE
SELECT VRSTEP
	USE
SELECT DOKS
	USE
SELECT POS
	USE
SELECT POM
	USE
return
*}


/*! \fn RadnIzvuci(cIdVd)
 *  \brief Punjenje pomocne baze realizacijom po radnicima
 */

function RadnIzvuci(cIdVd)
*{
Seek cIdVd+DTOS (dDatOd)
do While ! Eof() .and. IdVd==cIdVd .and. DOKS->Datum <= dDatDo

  IF (Klevel>"0" .and. doks->idpos="X").or.(DOKS->IdPos="X" .and. AllTrim (cIdPos) <> "X").or.(!Empty(cIdPos) .and. DOKS->IdPos <> cIdPos).or.(!Empty(cSmjena) .and. DOKS->Smjena <> cSmjena).or.(!Empty(cIdRadnik) .and. DOKS->IdRadnik <> cIdRadnik)
    skip
    loop
  EndIF
  _IdVrsteP := DOKS->IdVrsteP
  _IdRadnik := DOKS->IdRadnik
  SELECT POS
  Seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
  do while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    IF (!empty(cIdDio).and.POS->IdDio<>cIdDio)
      skip
      loop
    EndIF
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
    	nNeplaca+=pos->(NCijena*kolicina)
    endif

    SELECT POM
    HSEEK _IdRadnik+_IdVrsteP+POS->IdRoba+POS->IdCijena
    IF !FOUND()
      APPEND BLANK
      REPLACE IdRadnik WITH _IdRadnik, IdVrsteP WITH _IdVrsteP, IdRoba WITH POS->IdRoba, IdCijena WITH POS->IdCijena, Kolicina WITH POS->KOlicina, Iznos WITH POS->Kolicina*POS->Cijena, iznos3 with nNeplaca
       if gPopVar="A"
              replace Iznos2   with pos->(ncijena)
       endif
    Else
      REPLACE Kolicina WITH Kolicina+POS->Kolicina, Iznos WITH Iznos+POS->Kolicina*POS->Cijena, iznos3 with iznos3+nNeplaca
      if gPopVar="A"
              replace Iznos2   with Iznos2+pos->(ncijena)
      endif
    EndIF
    SELECT POS
    SKIP
  EndDO
  SELECT DOKS
  SKIP
EndDO
return
*}

