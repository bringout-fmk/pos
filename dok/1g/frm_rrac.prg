#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/frm_rrac.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: frm_rrac.prg,v $
 * Revision 1.5  2003/06/13 14:05:58  mirsad
 * debug: pritisak na programiranu tipku
 *
 * Revision 1.4  2002/07/06 08:13:34  ernad
 *
 *
 * - uveden parametar PrivPath/POS/Slave koji se stavi D za kasu kod koje ne zelimo ScanDb
 * Takodje je za gVrstaRs="S" ukinuto scaniranje baza
 *
 * - debug ispravke racuna (ukinute funkcije PostaviSpec, SiniSpec, zamjenjene sa SetSpec*, UnSetSpec*)
 *
 * Revision 1.3  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
/*! \fn P_RadniRac(cBroj)
 *  \brief Pregled svih otvorenih radnih racuna za radnika
 *  \param cBroj
 */
 
function P_RadniRac(cBroj)
*{

if cBroj==nil
	cBroj:=SPACE(LEN(_POS->BrDok))
else
	cBroj:=cBroj
endif

cBroj:=PADL(ALLTRIM(cBroj),LEN(cBroj))

SELECT _POS
Seek2 (gIdPos+VD_RN+dtos(gDatum)+cBroj)
// prvo provjeri da ne pokusa uzeti tudji
if FOUND().and.M1<>"Z".and.IdRadnik!=gIdRadnik
	return (.t.)
endif
ImeKol:={ { "Datum",       {|| Datum }, },;
          { "Broj",        {|| BrDok }, },;
          { "Sto",         {|| Sto   }, },;
          { "Roba",        {|| Left (RobaNaz, 30) }, },;
          { "Kolicina",    {|| STR (Kolicina, 8, 2) }, },;
          { "Cijena",      {|| STR (Cijena, 8, 2) }, },;
          { "Iznos stavke",{|| STR (Kolicina*Cijena, 12, 2) }, },;
          { "G.T.",        {|| IIF (GT=="1"," NE "," DA ")},};
        }
if gModul=="HOPS"
	Kol:={1, 2, 3, 4, 5, 6, 7,8}
else
  	Kol:={1, 3, 4, 5, 6, 7 }
endif

cFilt1:="IDRADNIK=="+cm2str(gIdRadnik)+".and.IdVd=='42'.and.(M1<>'Z')"

SET FILTER TO &cFilt1
GO TOP
Skip 0
ObjDBedit( , 20, 77, {|| P_RRproc () }, ;
            "  OTVORENI RADNI RACUNI  ", "", .F., ;
            "<Enter> - Odabir         </> - Tekuci iznos")
SET FILTER TO

if LASTKEY()==K_ESC
	return (.f.)
endif
if EMPTY(_POS->BrDok)
	return (.f.)
endif

cBroj:=_POS->BrDok
return (.t.)
*}



/*! \fn P_RRproc()
 *  \brief Radni racuni - handler
 */
 
function P_RRproc()
*{

if M->Ch==0
	return (DE_CONT)
endif
if LASTKEY()==K_ESC.or.LASTKEY()==K_ENTER
	return (DE_ABORT)
endif
if CHR(LASTKEY())=="/"
	Msg("Tekuci iznos racuna je: " +STR(RR_iznos(_POS->IdPos, _POS->BrDok), 10,2),20)
endif
return (DE_CONT)
*}


/*! \fn RR_Iznos(cIdPos,cBrDok)
 *  \brief
 *  \param cIdPos
 *  \param cBrDok
 */
 
function RR_Iznos(cIdPos,cBrDok)
*{

// - koristi gDatum

SELECT _POS
nTekRec:=RECNO()
nIznos:=0
Seek2 (cIdPos+VD_RN+dtos(gdatum)+cBrDok)
do while !eof().and._POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+VD_RN+dtos(gDatum)+cBrDok)
	nIznos += _POS->(Kolicina * Cijena)
  	SKIP
enddo
GO nTekRec
return (nIznos)
*}


/*! \fn AutoKeys()
 *  \brief Reaguje na programibilne tipke tako sto u polje za unos sifre artiklaunese sifru koja je vezana s tom tipkom!
 */
 
function AutoKeys()
*{

local nPrev

if !((GETLIST[1]:hasFocus).and.(GETLIST[1]:name="_idroba"))
	return	
endif

nPrev:=SELECT()

SELECT K2C
Seek2(STR(LASTKEY(),4))

if !FOUND()
	return
endif

GETLIST[1]:buffer:=K2C->IdRoba
GETLIST[1]:display()
GETLIST[1]:assign()
keyboard CHR(K_ENTER)
select (nprev)
return
*}


