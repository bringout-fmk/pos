#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_pvpl.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: rpt_pvpl.prg,v $
 * Revision 1.5  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
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

/*! \file fmk/pos/rpt/1g/rpt_pvpl.prg
 *  \brief Izvjestaj: pregled prometa po vrstama placanja
 */

/*! \fn PrometVPl()
 *  \brief Izvjestaj: pregled prometa po vrstama placanja
 */

function PrometVPl()
*{
O_KASE
O_PROMVP

cIdPos:=gIdPos
dDatOd:=dDatDo:=gDatum

set cursor on
Box(,3,60)
  set cursor on
  @ m_x+1,m_y+2 SAY "Prod.mjesto    :  "  GET  cIdPos  valid empty(cIdPos).or.P_Kase(@cIdPos) pict "@!"
  @ m_x+2,m_y+2 SAY "Datumski period:" GET dDatOd
  @ m_x+2,col()+2 SAY "-" GET dDatDo
  read
BoxC()

SELECT PROMVP; go top

nIznPKM:=nIznPEURO:=nIznKred:=nIznVirm:=nIznU:=nIznU2:=nIznTrosk:=0

DO WHILE !EOF()
  if PM==cIdPos .and. Datum>=dDatOd .and. Datum<=dDatDo
     nIznPKM+=PROMVP->PologKM
     nIznPEURO+=PROMVP->PologEU
     nIznKred+=PROMVP->Krediti
     nIznVirm+=PROMVP->Virmani
     nIznTrosk+=PROMVP->Trosk
     nIznU2+=PROMVP->Ukupno2
     skip
  else
    skip
  endif
ENDDO

cLm:=SPACE(5)

// -- stampaj izvjestaj
START PRINT CRET

ZagFirma()

IF gVrstaRS == "S"
  P_INI  ; P_10CPI
EndIF

? "PREGLED PROMETA PO VRSTI PLACANJA NA DAN "+DTOC(gDatum)
? "-------------------------------------------------"
?
if empty(cIdPos)
? "Prodajno mjesto: SVI"
else
? "Prodajno mjesto: " + cIdPos
endif
? "PERIOD         : "+DTOC(dDatOd)+" - "+DTOC(dDatDo)
? "-------------------------------------------"
?
? cLm+"Polog KM    : "+STR(nIznPKM)
? cLm+"Polog EURO  : "+STR(nIznPEURO)
? cLm+"Krediti     : "+STR(nIznKred)
? cLm+"Virmani     : "+STR(nIznVirm)
? cLm+"Troskovi    : "+STR(nIznTrosk)
? cLm+"------------------------------------"
? cLm+"UKUPNO      : "+STR(nIznU2)
? cLm+"------------------------------------"

END PRINT
CLOSERET
*}

