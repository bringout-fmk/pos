#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/rpt_inni.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: rpt_inni.prg,v $
 * Revision 1.2  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
/*! \fn StampaInv(fLista,fAzurirana)
 */
 
function StampaInv(fLista,fAzurirana)
*{

// koristi privatne vars:
// Ako je  cIdvD = NI - nivelacija
//         cIdVD = IN - inventura
//
// stampa invenure / nivelacije

LOCAL cPom, cNule := "D", cNiv := "N", nSir := 80, nRobSir := 29
local aTarife:={}

PRIVATE fInvent := .T.

if flista==NIL; flista:=.f.; endif
if fAzurirana==NIL; fAzurirana:=.f.; endif

IF gVrstaRS <> "S"
  nSir := 40
EndIF

select PRIPRZ
IF cIdVd == "IN"
  IF ! fLista
    cNule:=Pitanje(,"Stampati stavke sa popisanom kolicinom 0  (D/N)?","D")
  EndIF
  fInvent:=.t.
Else
  cNiv:=Pitanje(,"Stampati samo stavke sa promijenjenom cijenom (D/N)?","N")
  fInvent := .F.
EndIF

if !fazurirana; GO TOP; endif

START PRINT CRET

IF gVrstaRS=="S"
  INI
EndIF

cPom := IIF (fInvent, ;
             IIF (fLista, "Inventurna/popisna lista ", "INVENTURA "),;
             "NIVELACIJA ")
IF gVrstaRS <> "S"
  cPom += AllTrim (PRIPRZ->IdPos)+"-"
Endif

? PADC (cPom+ALLTRIM (PRIPRZ->BrDok), nSir)
?
SELECT ODJ
HSEEK PRIPRZ->IdOdj
if gvodiodj=="D"
  ? PADC ("Odjeljenje: "+AllTrim (ODJ->Naz), nSir)
endif
SELECT PRIPRZ
IF gPostDO=="D" .and. ! Empty (PRIPRZ->IdDio)
  SELECT DIO
  HSEEK PRIPRZ->IdDio
  ? PADC ("Dio objekta: "+AllTrim (DIO->Naz), nSir)
  SELECT PRIPRZ
EndIF
?
IF gVrstaRS == "S"
  P_10CPI
EndIF

if gVrstaRS<>"S"
  ?    " ------------- ---------------------- ---"
  ?    "  Sifra           Artikal             jmj"
  ?    " ------------- ---------------------- ---"
  IF fInvent
    ? " Knj. Kol  Pop.kol.   Cijena     +/-"
  Else
    ? "  Stanje          Cijena           Nova c."
  EndIF
  IF fInvent
    m:= "--------- --------- -------- ------------"
  Else
    m:= "  ------------ ------------ ------------"
  EndIF
else  // server
  ? " Sifra    Artikal"
  ?? SPACE (22)
  ?
  ?? "   Stanje   "                 // ima jedan space ispred Stanje
  IF fInvent
      ?? "Popis.kol. Cijena    +/-"
  Else
      ?? "Cijena  Nova c."
  EndIF
  IF fInvent
    m := " -------- ----------------------------- ---------- ---------- ------- --------"
  Else
    m := " -------- ----------------------------- ---------- ------- -------"
  EndIF
endif

? m

/*
 inventura ...
 Sifra    Artikal                         Stanje   Popis.kol. Cijena    +/-
 -------- ----------------------------- ---------- ---------- ------- --------
 01234567 01234567890123456789012345678 999999.999 999999.999 9999.99 99999.99

 nivelacija ...
 Sifra    Artikal                         Stanje   Cijena  Nova c.
 -------- ----------------------------- ---------- ------- -------
 01234567 01234567890123456789012345678 999999.999 9999.99 9999.99
*/

nCij:=0
nKVr:=nPopVr:=0
nStVr:=nNVR:=0

cBroj:=dtos(datum)+brdok   // stampaj broj

DO WHILE !EOF() .and. idvd==cidvd .and.  cBroj==dtos(datum)+brdok
  if fLista .or. ;
     (cNiv=="N" .or. (cNiv=="D" .and. PRIPRZ->cijena<>PRIPRZ->ncijena)) .and. ;
     (cNule=="D" .or. (cNule=="N" .and. Kol2<>0)) ;
     .and.  (Kolicina<>0 .or. Kol2<>0)

   IF gVrstaRS == "S"
     IF Prow() > 63-gPstranica-IIF (fLista, 2, 1);  FF; EndIF
   EndIF

   if fazurirana
     select (cRSdbf); hseek priprz->idroba
     RobaNaz:=naz  ; select priprz
     jmj:= &cRsDbf.->jmj
   endif
   ? " " + IdRoba, PADR (RobaNaz, 23), PADR ("("+jmj+")", 5)

   nCij:= PRIPRZ->CIJENA
   IF gVrstaRS <> "S"
    ?
    IF fLista
      ?? " " + "________.___", "_________.___", STR (PRIPRZ->cijena, 8, 2)
    Else
      if finvent
       ? str(kolicina,9,1), str(kol2,9,1), ;
       STR (PRIPRZ->cijena, 8, 1), STR (kolicina-kol2, 12, 2)
       ? m
      else
       ? str(kolicina,14,3), STR (PRIPRZ->cijena, 12, 2), STR (PRIPRZ->ncijena, 12, 2)
       ? m
      endif
     endif // flista
   else  // idemo na server
    IF fLista
      ?? " " + "______.___", "______.___", STR (PRIPRZ->cijena, 7, 2)
    Else
     ?? " " + STR (Kolicina, 10, 3), ""
     IF fInvent
       ?? STR (Kol2, 10, 3), ;
          STR (PRIPRZ->cijena, 7, 2), TRANS (Kolicina-Kol2, "9999.99")
     Else
       ?? STR (PRIPRZ->cijena, 9, 2), STR (PRIPRZ->ncijena, 9, 2)
     EndIF
    endif // flista
   EndIF // server

   nIzn:=0
   IF fInvent
     nKVr+=ncij * Kolicina
     nPopVr+=nCij* Kol2        // po starim cijenama
     nIzn:=nCij* Kol2
   Else
     nStVr += cijena*Kolicina
     nNVr  += ncijena*Kolicina
     nIzn:= (ncijena-cijena)*Kolicina
   EndIF

   if gModul=="TOPS"
     WhileaTarifa(PRIPRZ->IdRoba,nIzn,@aTarife )
   endif


 endif // fLista .or. cnule=="N"
 SKIP
ENDDO // !eof()

IF !fLista .and. fInvent
  IF gVrstaRS == "S"
    IF Prow() > 63-gPStranica-5
      FF
    EndIF
  EndIF
  ?
  ? "Ukupno knjizna  vrijednost:",str(nKVr,10,2 )
  ? "Ukupno popisana vrijednost:",str(nPopVr,10,2 )
  ?
  if round(nKVr-nPopVr,3)<>0
   if nKvr-nPopVr>0
      ? " Razlika MANJAK ...........",str(nKVr-nPopVr,10,2 )
   else
      ? " Razlika VISAK ............",str(nKVr-nPopVr,10,2 )
   endif
  endif
EndIF

if !fLista .and. round(nStVr-nNVR,3)<>0
  nStVr += nPopVr
  nNVr  += nPopVr
  IF gVrstaRS == "S"
    IF Prow() > 63-gPStranica-7
      FF
    EndIF
  EndIF
  ?
  ? "PROMJENA CIJENA :"
  ?
  ? "Stara vrijednost zaliha ",str(nStVr,10,2 )
  ? "Nova  vrijednost zaliha ",str(nNVr,10,2 )
  ?
  ? "Razlika vrijednosti    :",str(nNVr-nStVr,10,2 )
endif


if gModul="TOPS"
  RekTarife(aTarife)
endif

IF gVrstaRS == "S"
  FF
Else
  PaperFeed ()
EndIF

END PRINT
RETURN
*}

/*! \fn StampaPLI(cBrDok)
 */

function StampaPLI(cBrDok)
*{
LOCAL cPom
  select PRIPRZ                // invent
  GO TOP
  START PRINT RET
  cPom := "INVENTURNA-POPISNA LISTA BR. "
  IF gVrstaRS<>"S"
    cPom += ALLTRIM (PRIPRZ->IdPos) + "-"
  EndIF
  ? PADC (cPom + ALLTRIM (cBrDok), 40)
  ?
if gvodiodj=="D"
  ? "Odjeljenje: "+PRIPRZ->IdOdj+"-"+Ocitaj(F_ODJ,IdOdj,"naz")
endif
  ?
  ? "Sifra    Naziv robe"
  ? "            Stanje    Popisana kolicina"
  ? "----------------------------------------"
//               999999.999  ____________,_____

  DO WHILE ! EOF ()
    ? IdRoba + " "+ RobaNaz
    ? SPACE (10) + STR (Kolicina, 10, 3) + "  " + "____________,_____"
    ? "----------------------------------------"
    SKIP
  ENDDO
  PaperFeed ()
  END PRINT
RETURN
*}

/*! \fn PrepisInvNiv(fInvent)
 */
function PrepisInvNiv(fInvent)
*{
// prepisace azuriranu fakturu

private cIdOdj, cRsDBF, cRsBlok
if finvent
 private cidvd:="IN"
else
 private cidvd:="NI"
endif

select pos; PushWa(); use

select doks
// otvori pos sa aliasom PRIPRZ, te je pozicioniraj na pravo mjesto
select (F_POS); use pos alias priprz;  set order to 1
HSEEK DOKS->(IdPos+IdVd+dtos(datum)+BrDok)


cidodj:=priprz->idodj
SELECT ODJ; hseek cidodj
IF ODJ->Zaduzuje == "S"
  cRSdbf := "SIROV"
  cRSblok := "P_Sirov2 (@_IdRoba)"
  cUI_U   := S_U; cUI_I   := S_I
ELSE
  cRSdbf := "ROBA"
  cRSblok := "P_Roba2 (@_IdRoba)"
  cUI_U   := R_U ; cUI_I   := R_I
ENDIF

StampaInv(.f. , .t.)  // drugi parametar kaze da se radi o azuriranom dok

select priprz; use  // zatvori alias

O_POS; PopWa()  // vrati pos gdje je bio

return
*}

