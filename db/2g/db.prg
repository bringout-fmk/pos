
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/db/2g/db.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.29 $
 * $Log: db.prg,v $
 * Revision 1.29  2003/12/24 09:54:35  sasavranic
 * Nova varijanta poreza, uvrstene standardne funkcije za poreze iz FMK
 *
 * Revision 1.28  2003/11/28 11:38:01  sasavranic
 * Prilikom prenosa realizacije u KALK da generise i barkodove iz TOPS-a
 *
 * Revision 1.27  2003/11/21 14:53:22  sasavranic
 * radi sa promvp samo ako je planika u pitanju
 *
 * Revision 1.26  2003/10/29 10:25:29  sasavranic
 * funkcija kreiranja message.dbf prebacena u pos/db
 *
 * Revision 1.25  2003/10/27 13:01:23  sasavranic
 * Dorade
 *
 * Revision 1.24  2003/07/26 15:06:34  sasa
 * novi index na rngost
 *
 * Revision 1.23  2003/07/22 15:07:48  sasa
 * prenos pos<->pos
 *
 * Revision 1.22  2003/06/24 13:15:09  sasa
 * no message
 *
 * Revision 1.21  2003/06/16 17:30:15  sasa
 * generacija zbirnog racuna
 *
 * Revision 1.20  2003/06/14 03:03:49  mirsad
 * debug-hops
 *
 * Revision 1.19  2003/05/23 13:07:46  ernad
 * tigra: spajanje sezona, PartnSt generacija otvorenih stavki
 *
 * Revision 1.18  2002/12/22 20:41:10  sasa
 * dorade
 *
 * Revision 1.17  2002/08/19 10:01:12  ernad
 *
 *
 * sql synchro cijena1, idtarifa za tabelu roba
 *
 * Revision 1.16  2002/07/06 08:13:34  ernad
 *
 *
 * - uveden parametar PrivPath/POS/Slave koji se stavi D za kasu kod koje ne zelimo ScanDb
 * Takodje je za gVrstaRs="S" ukinuto scaniranje baza
 *
 * - debug ispravke racuna (ukinute funkcije PostaviSpec, SiniSpec, zamjenjene sa SetSpec*, UnSetSpec*)
 *
 * Revision 1.15  2002/07/04 19:03:22  ernad
 *
 *
 * PROMVP nije bila uvrstena u metod oDbPos:obaza(i)
 *
 * Revision 1.14  2002/07/04 18:42:57  ernad
 *
 *
 * novi sclib, uklonjene debug poruke
 *
 * Revision 1.13  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.12  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.11  2002/06/28 06:45:01  sasa
 * no message
 *
 * Revision 1.10  2002/06/25 23:46:15  ernad
 *
 *
 * pos, prenos pocetnog stanja
 *
 * Revision 1.9  2002/06/25 12:04:07  ernad
 *
 *
 * ubaceno kreiranje SECUR-a (posto je prebacen u kumpath)
 *
 * Revision 1.8  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.7  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.6  2002/06/21 14:18:11  ernad
 *
 *
 * pos - planika, import sql
 *
 * Revision 1.5  2002/06/14 12:43:46  ernad
 * header
 *
 *
 */
 
#include "\cl\sigma\fmk\pos\pos.ch"

function TDBPosNew()
*{
local oObj

#ifdef CLIP
	
oObj:=TDbNew()
oObj:skloniSezonu:=@skloniSezonu()
oObj:install:=@install()
oObj:setgaDbfs:=@setgaDbfs()
oObj:ostalef:=@ostalef()	
oObj:obaza:=@obaza()
oObj:kreiraj:=@kreiraj()
oObj:konvZn:=@konvZn()
oObj:open:=@open()
oObj:reindex:=@reindex()
oObj:scan:=@scan()

#else
oObj:=TDBPos():new()
#endif

oObj:self:=oObj
oObj:cName:="POS"
oObj:lAdmin:=.f.

return oObj
*}


/*! \file fmk/pos/db/2g/db.prg
 *  \brief POS Database
 *
 * TDBPos Database objekat 
 */


/*! \class TDBPos
 *  \brief POS Database objekat
 */



#ifdef CPP
#translate class { (<x>) } => 

class TDBPos: public TDB
{

     public:
     	  *TObject self;
          *void dummy();
	  *void skloniSez(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS);
	  *void install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7);
	  *void setgaDBFs();
	  *void obaza(int i);
	  *void ostalef();
	  *void konvZn();
	  *void kreiraj(int nArea);
	  *bool open();
	  *bool reindex();
	  *bool scan();
}

#endif

#ifndef CLIP
#ifndef CPP
#include "class(y).ch"
CREATE CLASS TDBPos INHERIT TDB 
	EXPORTED:
	var self
	method skloniSezonu	
	method install	
	method setgaDBFs	
	method ostalef	
	method obaza	
	method kreiraj	
	method konvZn
	method open
	method reindex
	method scan
END CLASS
#endif
#endif


/*! \fn *void TDBPos::dummy()
 */
*void TDBPos::dummy()
*{
method dummy
return
*}


/*! \fn *void TDBPos::skloniSez(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS)
 *  \brief formiraj sezonsku bazu podataka
 */
 
*void TDBPos::skloniSez(string cSezona, bool finverse, bool fda, bool fnulirati, bool fRS)
*{
method skloniSezonu(cSezona, finverse, fda, fnulirati, fRS)
local cScr
save screen to cScr

  if fda==NIL
    fDA:=.f.
  endif
  if finverse==NIL
    finverse:=.f.
  endif
  if fNulirati==NIL
    fnulirati:=.f.
  endif
  if fRS==NIL
   // mrezna radna stanica , sezona je otvorena
   fRS:=.f.
  endif
if fRS // radna stanica
  if file(ToUnix(PRIVPATH+cSezona+"\_PRIPR.DBF"))
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
      return
  endif
  aFilesK:={}
  aFilesS:={}
  aFilesP:={}
endif

  cls

  ?
  if finverse
   ? "Prenos iz  sezonskih direktorija u radne podatke"
  else
   ? "Prenos radnih podataka u sezonske direktorije"
  endif
  ?
  // privatne datoteke
  fnul:=.f.
  Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
  Skloni(PRIVPATH,"K2C.DBF",cSezona,finverse,fda,fnul)
  Skloni(PRIVPATH,"MJTRUR.DBF",cSezona,finverse,fda,fnul)

  // radne (pomocne) datoteke
  Skloni(PRIVPATH,"_POS.DBF",cSezona,finverse,fda,fnul)
  Skloni(PRIVPATH,"_PRIPR.DBF", cSezona,finverse,fda,fnul)
  Skloni(PRIVPATH,"PRIPRZ.DBF", cSezona,finverse,fda,fnul)
  Skloni(PRIVPATH,"PRIPRG.DBF", cSezona,finverse,fda,fnul)
  Skloni(PRIVPATH,"FMK.INI", cSezona,finverse,fda,fnul)


  if fRS
   // mrezna radna stanica!!! , baci samo privatne direktorije
   ?
   ?
   ?
   Beep(4)
   ? "pritisni nesto za nastavak.."

   restore screen from cScr
   return
  endif

  // datoteke prometa
  //
  if fnulirati; fnul:=.t.; else; fnul:=.f.; endif  // kumulativ datoteke
  Skloni(KUMPATH,"DOKS.DBF",cSezona,finverse,fda,fnul)
  Skloni(KUMPATH,"POS.DBF",cSezona,finverse,fda,fnul)
  Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)

  //sifrarnici
  fnul:=.f.
  Skloni(SIFPATH,"roba.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"roba.ftp",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"SIROV.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"SAST.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"STRAD.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"OSOB.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"TARIFA.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"VALUTE.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"VRSTEP.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"KASE.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"ODJ.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"DIO.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"RNGOST.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"UREDJ.dbf",cSezona,finverse,fda,fnul)
  Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

  ?
  ?
  ?
  Beep(4)
  ? "pritisni nesto za nastavak.."

  restore screen from cScr
return
*}

/*! \fn *void TDBPos::setgaDBFs()
 *  \brief Setuje matricu gaDBFs 
 */
*void TDBPos::setgaDBFs()
*{
method setgaDBFs()
PUBLIC gaDBFs:={ ;
{  F_DOKS      , "DOKS", P_KUMPATH },;
{  F_POS       , "POS", P_KUMPATH },;
{  F_RNGPLA    , "RNGPLA", P_KUMPATH },;
{  F__POS      , "_POS", P_PRIVPATH },;
{  F__PRIPR    , "_PRIPR", P_PRIVPATH },;
{  F__POSP     , "_POSP",  P_PRIVPATH },;
{  F_PRIPRZ    , "PRIPRZ", P_PRIVPATH },;
{  F_PRIPRG    , "PRIPRG", P_PRIVPATH },;
{  F_K2C       , "K2C", P_PRIVPATH},;
{  F_MJTRUR    , "MJTRUR", P_PRIVPATH },;
{  F_ROBAIZ    , "ROBAIZ", P_PRIVPATH },;
{  F_RAZDR     , "RAZDR",  P_SIFPATH },;
{  F_ROBA      , "ROBA",   P_SIFPATH },;
{  F_SIROV     , "SIROV",  P_SIFPATH },;
{  F_SAST      , "SAST",   P_SIFPATH },;
{  F_STRAD     , "STRAD",  P_SIFPATH },;
{  F_OSOB      , "OSOB",   P_SIFPATH },;
{  F_TARIFA    , "TARIFA", P_SIFPATH },;
{  F_VALUTE    , "VALUTE", P_SIFPATH },;
{  F_VRSTEP    , "VRSTEP", P_SIFPATH },;
{  F_KASE      , "KASE",   P_SIFPATH },;
{  F_ODJ       , "ODJ",    P_SIFPATH },;
{  F_UREDJ     , "UREDJ",  P_SIFPATH },;
{  F_RNGOST    , "RNGOST", P_SIFPATH },;
{  F_DIO       , "DIO",    P_SIFPATH },;
{  F_MARS      , "MARS",   P_SIFPATH },;
{  F_MESSAGE   , "MESSAGE",P_KUMPATH },;
{  F_TMPMSG    , "TMPMSG" ,P_EXEPATH },;
{  F_PROMVP    , "PROMVP", P_KUMPATH };
}

// sta raditi sa ovim tabelama
/*
{  F_DOKS_S    , "DOKS_S", 0 , "DOKS" },;
{  F_POS_S     , "POS_S",  0 , "POS" },;
{  F_DOKS_K    , "DOKS_K", 0 , "DOKS" },;
{  F_POS_K     , "POS_K",  0 , "POS" },;
{  F_DOKS_SEZ  , "DOKS_SEZ", 0 , "DOKS" },;
{  F_POS_SEZ   , "POS_SEZ" , 0 , "POS"  };
*/

return
*}


/*! \fn *void TDBPos::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *  \brief osnovni meni za instalacijske procedure
 *  \todo  prosljedjuje se goModul, ovo ce biti eliminsano eliminisanjem ISC_START-a procedure (tj zamjenom odgovarajucim klasama)
 */

*void TDBPos::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
*{
method install()
ISC_START(goModul,.f.)
return
*}

/*! *void TDBPos::kreiraj(int nArea)
 *  \brief kreirane baze podataka POS
 */
 
*void TDBPos::kreiraj(int nArea)
*{
method kreiraj(nArea)
local aDbf

if (nArea==nil)
	nArea:=-1
endif
Beep(1)

if (nArea<>-1)
	CreSystemDb(nArea)
endif
if (nArea==-1 .or. nArea==(F_DOKS))

	// DOKS.DBF
	aDbf := {}
	AADD ( aDbf, { "BRDOK",     "C",  6, 0} )
	AADD ( aDbf, { "DATUM",     "D",  8, 0} )
	AADD ( aDbf, { "IDGOST",    "C",  8, 0} )
	AADD ( aDbf, { "IDPOS",     "C",  2, 0} )
	AADD ( aDbf, { "IDRADNIK",  "C",  4, 0} )
	AADD ( aDbf, { "IDVD",      "C",  2, 0} )
	AADD ( aDbf, { "IDVRSTEP",  "C",  2, 0} )
	AADD ( aDbf, { "M1",        "C",  1, 0} )
	AADD ( aDbf, { "PLACEN",    "C",  1, 0} )
	AADD ( aDbf, { "PREBACEN",  "C",  1, 0} )
	AADD ( aDbf, { "SMJENA",    "C",  1, 0} )
	AADD ( aDbf, { "STO",       "C",  3, 0} )
	AADD ( aDbf, { "VRIJEME",   "C",  5, 0} )
	if gBrojSto=="D"
		AADD ( aDbf, { "ZAKLJUCEN", "C",  1, 0} )
	endif
	// M1 ? cemu sluzi Z - zakljucen, S-odstampan
	IF !FILE(KUMPATH+"DOKS.DBF")
	  DBcreate2(KUMPATH+"DOKS.DBF", aDbf)
	ENDIF


	// brojac dokumenata
	CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok", KUMPATH+"DOKS")
	// realizacija (kase, radnika, odjeljenja, dijela objekta, poreza)
	// prenos realizacije u KALK
	CREATE_INDEX ("2", "IdVd+DTOS(Datum)+Smjena", KUMPATH+"DOKS")
	// za gosta
	CREATE_INDEX ("3", "IdGost+Placen+DTOS(Datum)", KUMPATH+"DOKS")
	CREATE_INDEX ("4", "IdVd+M1", KUMPATH+"DOKS" )
	CREATE_INDEX ("5", "Prebacen", KUMPATH+"DOKS" )
	CREATE_INDEX ("6", "dtos(datum)", KUMPATH+"DOKS" )
	CREATE_INDEX ("7", "IdPos+IdVD+BrDok", KUMPATH+"DOKS" )
	CREATE_INDEX ("GOSTDAT", "IdPos+IdGost+DTOS(Datum)+IdVd+Brdok", KUMPATH+"DOKS")
	if gBrojSto=="D"
		CREATE_INDEX ("8", "IdPos+IdRadnik+Zakljucen+BrDok", KUMPATH+"DOKS" )
	endif
endif

if (nArea==-1 .or. nArea==(F_POS))
	// POS.DBF
	aDbf := {}
	AADD ( aDbf, { "BRDOK",     "C",  6, 0} )
	AADD ( aDbf, { "CIJENA",    "N", 10, 3} )
	AADD ( aDbf, { "DATUM",     "D",  8, 0} )
	AADD ( aDbf, { "IDCIJENA",  "C",  1, 0} )
	AADD ( aDbf, { "IDDIO",     "C",  2, 0} ) // gdje se roba izuzima
	AADD ( aDbf, { "IDODJ",     "C",  2, 0} ) // sa IdDio daje tacno mjesto
	AADD ( aDbf, { "IDPOS",     "C",  2, 0} )
	AADD ( aDbf, { "IDRADNIK",  "C",  4, 0} )
	AADD ( aDbf, { "IDROBA",    "C", 10, 0} )
	AADD ( aDbf, { "IDTARIFA",  "C",  6, 0} )
	AADD ( aDbf, { "IDVD",      "C",  2, 0} )
	AADD ( aDbf, { "KOL2",      "N", 18, 3} )       // za inventuru, nivelaciju
	AADD ( aDbf, { "KOLICINA",  "N", 18, 3} )
	AADD ( aDbf, { "M1",        "C",  1, 0} )
	AADD ( aDbf, { "MU_I",      "C",  1, 0} )
	AADD ( aDbf, { "NCIJENA",   "N", 10, 3} )
	AADD ( aDbf, { "PREBACEN",  "C",  1, 0} )
	AADD ( aDbf, { "SMJENA",    "C",  1, 0} )
	// M1 ? cemu sluzi Z - zakljucen, S-odstampan
	IF !FILE ( KUMPATH + "POS.DBF" )
	  DBcreate2 ( KUMPATH + "POS.DBF", aDbf )
	ENDIF

	// veza prema DOKS
	CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena", KUMPATH+"POS")
	// robno-materijalno pracenje odjeljenja
	CREATE_INDEX ("2", "IdOdj+idroba+DTOS(Datum)", KUMPATH+"POS")
	CREATE_INDEX ("3", "Prebacen", KUMPATH+"POS")
	CREATE_INDEX ("4", "dtos(datum)", KUMPATH+"POS")
	CREATE_INDEX ("5", "IdPos+idroba+DTOS(Datum)", KUMPATH+"POS")
	CREATE_INDEX ("6", "IdRoba", KUMPATH+"POS")

endif



if (nArea==-1 .or. nArea==(F_RNGPLA))
	// RNGPLA - izmirenje dugovanja po racunima gostiju
	//          (radi se samo na samostalnoj kasi, odnosno serveru)
	//          - vidjeti sta sa kred. karticama i slicno
	IF !FILE (KUMPATH + "RNGPLA.DBF")
	   aDbf := { {"IDGOST",   "C",  8, 0}, ;
		     {"DATUM",    "D",  8, 0}, ;
		     {"IZNOS",    "N", 20, 3}, ;
		     {"IDVALUTA", "C",  4, 0}, ;
		     {"DAT_OD",   "D",  8, 0}, ;
		     {"DAT_DO",   "D",  8, 0}, ;
		     {"IDRADNIK", "C",  4, 0}  ;
		   }
	   DBcreate2 (KUMPATH + "RNGPLA.DBF", aDbf)
	ENDIF
	CREATE_INDEX ("1", "IdGost", KUMPATH+"RNGPLA")
endif


if (nArea==-1 .or. nArea==(F_PROMVP))

	
	altd()
	cImeDbf:=KUMPATH+"PROMVP.DBF"
	cImeCdx:=KUMPATH+"PROMVP.CDX"
	if FILE(cImeDbf)
		SELECT(F_PROMVP)
		USE(cImeDbf)
		if (FIELDPOS("polog01")==0 .or. FIELDPOS("_SITE_")==0)
			USE
			//stara struktura tabele
			FERASE(cImeDbf)
			FERASE(cImeCdx)
		endif
	endif
	if !FILE(cImeDbf)
	   aDbf := { {"pm",        "C",  2, 0}, ;
		     {"datum",     "D",  8, 0}, ;
		     {"polog01",   "N", 10, 2}, ;
		     {"polog02",   "N", 10, 2}, ;
		     {"polog03",   "N", 10, 2}, ;
		     {"polog04",   "N", 10, 2}, ;
		     {"polog05",   "N", 10, 2}, ;
		     {"polog06",   "N", 10, 2}, ;
		     {"polog07",   "N", 10, 2}, ;
		     {"polog08",   "N", 10, 2}, ;
		     {"polog09",   "N", 10, 2}, ;
		     {"polog10",   "N", 10, 2}, ;
		     {"polog11",   "N", 10, 2}, ;
		     {"polog12",   "N", 10, 2}, ;
		     {"ukupno",   "N", 10, 3}  ;
		   }
	   if gSql=="D"
		AddOidFields(@aDbf)
	   endif
	   DBcreate2 (cImeDbf, aDbf)
	endif
	CREATE_INDEX ("1", "DATUM", cImeDbf)
endif


// _POS, _PRIPR, PRIPRZ, PRIPRG, _POSP

aDbf := {}
AADD ( aDbf, { "BRDOK",     "C",  6, 0} )
AADD ( aDbf, { "CIJENA",    "N", 10, 3} )
AADD ( aDbf, { "DATUM",     "D",  8, 0} )
AADD ( aDbf, { "GT",        "C",  1, 0} )
AADD ( aDbf, { "IDCIJENA",  "C",  1, 0} )
AADD ( aDbf, { "IDDIO",     "C",  2, 0} )
AADD ( aDbf, { "IDGOST",    "C",  8, 0} )
AADD ( aDbf, { "IDODJ",     "C",  2, 0} )
AADD ( aDbf, { "IDPOS",     "C",  2, 0} )
AADD ( aDbf, { "IDRADNIK",  "C",  4, 0} )
AADD ( aDbf, { "IDROBA",    "C", 10, 0} )
AADD ( aDbf, { "IDTARIFA",  "C",  6, 0} )
AADD ( aDbf, { "IDVD",      "C",  2, 0} )
AADD ( aDbf, { "IDVRSTEP",  "C",  2, 0} )
AADD ( aDbf, { "JMJ",       "C",  3, 0} )
// za inventuru, nivelaciju
AADD ( aDbf, { "KOL2",      "N", 18, 3} )       
AADD ( aDbf, { "KOLICINA",  "N", 18, 3} )
AADD ( aDbf, { "M1",        "C",  1, 0} )
AADD ( aDbf, { "MU_I",      "C",  1, 0} )
AADD ( aDbf, { "NCIJENA",   "N", 10, 3} )
AADD ( aDbf, { "PLACEN",    "C",  1, 0} )
AADD ( aDbf, { "PREBACEN",  "C",  1, 0} )
AADD ( aDbf, { "ROBANAZ",   "C", 40, 0} )
AADD ( aDbf, { "SMJENA",    "C",  1, 0} )
AADD ( aDbf, { "STO",       "C",  3, 0} )
AADD ( aDbf, { "VRIJEME",   "C",  5, 0} )


if (nArea==-1 .or. nArea==(F__POS))
	IF !FILE (PRIVPATH+"_POS.DBF")
	   DBcreate2 (PRIVPATH+"_POS", aDbf)
	ENDIF

	// dodavanje roba na racun; inventura, nivelacija; prebacivanje u DOKS/POS
	CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena+STR(Cijena,10,3)", ;
		      PRIVPATH+"_POS")
	// povrat pripreme zaduzenja, inventure, nivelacije
	CREATE_INDEX ("2", "IdVd+IdOdj+IdDio", PRIVPATH+"_POS")
	// generisanje trebovanja
	CREATE_INDEX ("3", "IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba", PRIVPATH+"_POS")
endif

if (nArea==-1 .or. nArea==(F__POSP))
	IF !FILE( PRIVPATH + "_POSP.DBF" )
	   DBcreate2 (PRIVPATH + "_POSP", aDbf )
	ENDIF
endif

if (nArea==-1 .or. nArea==(F__PRIPR))
	// narudzba na jedan radni rac
	IF !FILE( PRIVPATH + "_PRIPR.DBF" )
	   DBcreate2 (PRIVPATH + "_PRIPR", aDbf )
	ENDIF
	CREATE_INDEX ("1", "IdRoba", PRIVPATH+"_PRIPR")
endif

if (nArea==-1 .or. nArea==(F_PRIPRZ))
	// priprema inventure, nivelacije, zaduzenja
	IF ! FILE ( PRIVPATH + "PRIPRZ.DBF" )
	   DBcreate2 (PRIVPATH + "PRIPRZ", aDbf )
	ENDIF
	CREATE_INDEX ("1", "IdRoba", PRIVPATH+"PRIPRZ")
endif

if (nArea==-1 .or. nArea==(F_PRIPRG))
	// generisanje utroska sirovina za jednu smjenu
	IF !FILE(PRIVPATH+"PRIPRG.DBF")
	   DBcreate2 (PRIVPATH + "PRIPRG", aDbf )
	ENDIF

	// generisanje utroska sirovina
	CREATE_INDEX ("1", ;
		      "IdPos+IdOdj+IdDio+IdRoba+DTOS(Datum)+Smjena", PRIVPATH+"PRIPRG")
	// prebacivanje u DOKS/POS
	CREATE_INDEX ("2", ;
		      "IdPos+DTOS (Datum)+Smjena", PRIVPATH+"PRIPRG")
	// generisanje pocetnog stanja
	//CREATE_INDEX ("3", ;
		 //     "IdVd+IdPos+IdVrsteP+IdGost+Placen+IdDio+IdOdj+" +;
		 //     "IdRoba+IdCijena+Str (Cijena, 10, 3)+IdTarifa",;
		 //     PRIVPATH+"PRIPRG")

	if (IsTigra() .or. IzFmkIni('TOPS','SpajanjeRazdCijene','N', KUMPATH)=='D')
		CREATE_INDEX ("3", "IdVd+IdPos+IdVrsteP+IdGost+Placen+IdDio+IdOdj+IdRoba+STR(Cijena,10,2)", PRIVPATH+"PRIPRG")
	else
		CREATE_INDEX ("3", "IdVd+IdPos+IdVrsteP+IdGost+Placen+IdDio+IdOdj+IdRoba", PRIVPATH+"PRIPRG")
	endif

	if IsPlanika()
		CreDB_Message()
	endif

endif


*tbl tbl_K2C;

/*! \var tbl_K2C
 *  \brief Tabela u koju se smjestaju definicije programiranih tipki
 *  \inigroup db_pos
 *  \code
 *  Create Table "K2C" (
 *        KEYCODE numeric(4,0),
 *        IDROBA char(10));
 *
 *  Create Index "1" on K2C(STR(KeyCode,4));
 *  Create Index "2" on K2C(IDROBA);
 *  \endcode
 */

if (nArea==-1 .or. nArea==(F_K2C))
	// K2C
	IF !FILE ( PRIVPATH + "K2C.DBF" )
	   aDbf := {}
	   AADD ( aDbf, {"KEYCODE", "N",  4, 0} )
	   AADD ( aDbf, {"IDROBA",  "C", 10, 0} )
	   DBcreate2 (PRIVPATH+"K2C.DBF", aDbf)
	ENDIF
	CREATE_INDEX ("1", "STR (KeyCode, 4)", PRIVPATH+"K2C")
	CREATE_INDEX ("2", "IdRoba", PRIVPATH+"K2C")
endif

if (nArea==-1 .or. nArea==(F_MJTRUR))
	// MJTRUR - parovi (mjesto trebovanja,uredjaj)
	IF !FILE(PRIVPATH + "MJTRUR.DBF")
	   aDbf := {}
	   AADD ( aDbf, {"IDDIO",      "C",  2, 0} )
	   AADD ( aDbf, {"IDODJ",      "C",  2, 0} )
	   AADD ( aDbf, {"IDUREDJAJ" , "C",  2, 0} )
	   DBcreate2 (PRIVPATH+'MJTRUR.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("1", "IdDio+IdOdj", PRIVPATH+"MJTRUR")
endif

if (nArea==-1 .or. nArea==(F_ROBAIZ))
	// ROBAIZ (ako se roba ne izuzima na punktu kojeg pokriva kasa)
	IF ! FILE (PRIVPATH+"ROBAIZ.DBF")
	  aDbf := {}
	  AADD ( aDbf, {"IDROBA",     "C", 10, 0} )
	  AADD ( aDbf, {"IDDIO",      "C",  2, 0} )
	  DBcreate2 (PRIVPATH+'ROBAIZ.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("1", "IdRoba", PRIVPATH+"ROBAIZ")
endif

if gModul=="HOPS"
	// RAZDR.DBF
	if (nArea==-1 .or. nArea==(F_RAZDR))
		IF ! FILE (PRIVPATH + "RAZDR.DBF")
		   aDbf := { { "IDROBA",    "C", 10, 0}, ;
			     { "ROBANAZ",   "C", 40, 0}, ;
			     { "CIJENA",    "N", 10, 3}, ;
			     { "ORIGKOL",   "N", 10, 2}, ;
			     { "KOL2",      "N", 10, 2}, ;
			     { "KOL3",      "N", 10, 2}, ;
			     { "KOL4",      "N", 10, 2}, ;
			     { "KOL5",      "N", 10, 2}, ;
			     { "KOL6",      "N", 10, 2}, ;
			     { "KOL7",      "N", 10, 2}, ;
			     { "KOL8",      "N", 10, 2}, ;
			     { "KOL9",      "N", 10, 2}, ;
			     { "KOL10",     "N", 10, 2}  ;
			   }
		   DBcreate2 ( PRIVPATH + "RAZDR", aDbf )
		ENDIF
		CREATE_INDEX ( "1", "IDROBA", PRIVPATH+"RAZDR")
	endif
endif

if (nArea==-1 .or. nArea==(F_ROBA))
	IF !FILE(SIFPATH+"ROBA.DBF")
	   aDbf := {}
	   AADD ( aDbf, { "ID",        "C", 10, 0} )
	   AADD ( aDbf, { "NAZ",       "C", 40, 0} )
	   AADD ( aDbf, { "JMJ",       "C",  3, 0} )
	   AADD ( aDbf, { "GRUPA",     "C",  2, 0} )
	   AADD ( aDbf, { "IDTARIFA",  "C",  6, 0} )
	   AADD ( aDbf, { "IDODJ",     "C",  2, 0} )
	   AADD ( aDbf, { "CIJENA1",   "N", 10, 3} )
	   AADD ( aDbf, { "CIJENA2",   "N", 10, 3} )
	   AADD ( aDbf, { "TIP",       "C",  1, 0} )
	   AADD ( aDbf, { "DJELJIV",   "C",  1, 0} )
	   AADD ( aDbf, { "K1",   "C",  4, 0} )
	   AADD ( aDbf, { "K2",   "C",  4, 0} )
	   AADD ( aDBf,{  'N1'   , 'N' ,  12 ,  2 })
	   AADD ( aDBf,{  'N2'   , 'N' ,  12 ,  2 })
	   AADD ( aDBf,{ 'MINK'   , 'N' ,  12 ,  2 })
	   DBcreate2 ( SIFPATH + "ROBA.DBF", aDbf )
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"ROBA")
	CREATE_INDEX ("NAZ", "Naz", SIFPATH+"ROBA")


	select (F_ROBA)
	use (SIFPATH+"roba")

	if fieldpos("BARKOD")<>0
	  use
	  CREATE_INDEX ("BARKOD", "BARKOD", SIFPATH+"ROBA")
	endif
endif

if (nArea==-1 .or. nArea==(F_SIROV))
	// SIROV.DBF
	IF ! FILE ( SIFPATH + "SIROV.DBF" )
	   aDbf := {}
	   AADD ( aDbf, { "ID",        "C", 10, 0} )
	   AADD ( aDbf, { "NAZ",       "C", 40, 0} )
	   AADD ( aDbf, { "JMJ",       "C",  3, 0} )
	   // AADD ( aDbf, { "GRUPA",     "C",  2, 0} )
	   AADD ( aDbf, { "IDTARIFA",  "C",  6, 0} )
	   AADD ( aDbf, { "IDODJ",     "C",  2, 0} )
	   AADD ( aDbf, { "CIJENA1",   "N", 10, 3} )
	   AADD ( aDbf, { "CIJENA2",   "N", 10, 3} )
	   AADD ( aDbf, { "TIP",       "C",  1, 0} )
	   AADD ( aDbf, { "DJELJIV",   "C",  1, 0} )
	   AADD ( aDbf, { "K1",   "C",  4, 0} )
	   AADD ( aDbf, { "K2",   "C",  4, 0} )
	   AADD ( aDBf, {  'N1'   , 'N' ,  12 ,  2 })
	   AADD ( aDBf, {  'N2'   , 'N' ,  12 ,  2 })
	   AADD(aDBf,{ 'MINK' , 'N' ,  12 ,  2 })
	   DBcreate2 ( SIFPATH + "SIROV.DBF", aDbf )
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"SIROV")
	CREATE_INDEX ("NAZ", "Naz", SIFPATH+"SIROV")
endif

if (nArea==-1 .or. nArea==(F_SAST))
	IF !FILE(SIFPATH+"SAST.DBF")
	   aDBf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
	   AADD(aDBf,{ 'ID2'                 , 'C' ,   10 ,  0 })
	   AADD(aDBf,{ 'KOLICINA'            , 'N' ,   12 ,  5 })
	   AADD(aDBf,{ 'K1'                  , 'C' ,    1 ,  0 })
	   AADD(aDBf,{ 'K2'                  , 'C' ,    1 ,  0 })
	   AADD(aDBf,{ 'N1'                  , 'N' ,   20 ,  5 })
	   AADD(aDBf,{ 'N2'                  , 'N' ,   20 ,  5 })
	   DBcreate2(SIFPATH+'SAST.DBF',aDbf)
	ENDIF
	CREATE_INDEX ("ID", "id+ID2", SIFPATH+"SAST")
	CREATE_INDEX ("NAZ", "id2+ID", SIFPATH+"SAST")
endif

if (nArea==-1 .or. nArea==(F_STRAD))
	// STRAD.DBF
	IF ! FILE ( SIFPATH + "STRAD.DBF" )
	   aDbf := {}
	   AADD ( aDbf, { "ID",        "C",  2, 0} )
	   AADD ( aDbf, { "NAZ",       "C", 15, 0} )
	   AADD ( aDbf, { "PRIORITET", "C",  1, 0} )
	   DBcreate2 ( SIFPATH + "STRAD.DBF", aDbf )
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"STRAD.DBF")
	CREATE_INDEX ("NAZ", "NAZ", SIFPATH+"STRAD.DBF")
endif

if (nArea==-1 .or. nArea==(F_OSOB))
	// OSOB.DBF
	IF ! FILE ( SIFPATH + "OSOB.DBF" )
	   aDbf := {}
	   AADD ( aDbf, { "ID",        "C",  4, 0} )
	   AADD ( aDbf, { "KORSIF",    "C",  6, 0} )     // KORISN.SIF
	   AADD ( aDbf, { "NAZ",       "C", 40, 0} )
	   AADD ( aDbf, { "STATUS",    "C",  2, 0} )
	   DBcreate2 ( SIFPATH + "OSOB.DBF", aDbf )
	ENDIF
	CREATE_INDEX ("ID", "KorSif", SIFPATH+"OSOB")
	CREATE_INDEX ("NAZ", "ID", SIFPATH+"OSOB")
endif

if (nArea==-1 .or. nArea==(F_TARIFA))
	// TARIFA.DBF
	IF ! FILE (SIFPATH+"TARIFA.dbf")
	   aDbf:={}
	   AADD(aDBf,{ 'ID'          , 'C' ,   6 ,  0 })
	   AADD(aDBf,{ 'NAZ'         , 'C' ,  50 ,  0 })
	   AADD(aDBf,{ 'OPP'         , 'N' ,   6 ,  2 })  // ppp
	   AADD(aDBf,{ 'PPP'         , 'N' ,   6 ,  2 })  // ppu
	   AADD(aDBf,{ 'ZPP'         , 'N' ,   6 ,  2 })  // poseban porez
	   AADD(aDBf,{ 'VPP'         , 'N' ,   6 ,  2 })  // pnamar
	   AADD(aDBf,{ 'MPP'         , 'N' ,   6 ,  2 })  
	   AADD(aDBf,{ 'DLRUC'       , 'N' ,   6 ,  2 })  
	   DBcreate2 ( SIFPATH+'TARIFA.DBF', aDbf )
	ENDIF
	CREATE_INDEX ("ID","Id", SIFPATH+"TARIFA")
	CREATE_INDEX ("NAZ","Naz", SIFPATH+"TARIFA")
endif


if (nArea==-1 .or. nArea==(F_VALUTE))
	// VALUTE.DBF
	if !FILE(SIFPATH+"VALUTE.DBF")
	   aDbf := { {"ID",    "C",  4, 0}, ;
		     {"NAZ",   "C", 30, 0}, ;
		     {"NAZ2",  "C",  4, 0}, ;
		     {"DATUM", "D",  8, 0}, ;
		     {"KURS1", "N", 10, 3}, ;
		     {"KURS2", "N", 10, 3}, ;
		     {"KURS3", "N", 10, 3}, ;
		     {"TIP",   "C",  1, 0}  ;
		   }
	   DBcreate2 ( SIFPATH + "VALUTE.DBF", aDbf )
	endif
	CREATE_INDEX ( "ID", "Id", SIFPATH+"VALUTE")
	CREATE_INDEX ( "NAZ", "Tip + Id + DTOS (Datum)", SIFPATH+"VALUTE")
	CREATE_INDEX ( "ID2", "id+dtos(datum)", SIFPATH+"VALUTE")
	CREATE_INDEX ( "NAZ2", "naz2 + DTOS (Datum)", SIFPATH+"VALUTE")
endif

if (nArea==-1 .or. nArea==(F_VRSTEP))
	// VRSTEP.DBF
	IF ! FILE (SIFPATH + "VRSTEP.DBF")
	   aDbf := { {"ID",  "C",  2, 0}, ;
		     {"NAZ", "C", 20, 0}  ;
		   }
	   DBcreate2 ( SIFPATH + "VRSTEP.DBF", aDbf )
	ENDIF
	CREATE_INDEX ("ID", "Id", SIFPATH+"VRSTEP.DBF")
endif

if (nArea==-1 .or. nArea==(F_KASE))
	//KASE
	IF !FILE(SIFPATH+"KASE.DBF")
	   aDbf := {}
	   AADD ( aDbf, {"ID" ,     "C",  2, 0} )
	   AADD ( aDbf, {"NAZ",     "C", 15, 0} )
	   AADD ( aDbf, {"PPATH",   "C", 50, 0} )
	   DBcreate2 (SIFPATH+'KASE.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"KASE")
endif

if (nArea==-1 .or. nArea==(F_ODJ))
	// ODJ - odjeljenja
	IF ! FILE ( SIFPATH + "ODJ.DBF")
	   aDbf := {}
	   AADD ( aDbf, {"ID" ,      "C",  2, 0} )
	   AADD ( aDbf, {"NAZ",      "C", 25, 0} )
	   AADD ( aDbf, {"ZADUZUJE", "C",  1, 0} )
	   AADD ( aDbf, {"IDKONTO",  "C",  7, 0} )
	   DBcreate2 (SIFPATH+'ODJ.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"ODJ")
endif

if (nArea==-1 .or. nArea==(F_DIO))
	// DIO - dijelovi objekta - HOPS
	IF ! FILE ( SIFPATH + "DIO.DBF")
	   aDbf := {}
	   AADD ( aDbf, {"ID" ,      "C",  2, 0} )
	   AADD ( aDbf, {"NAZ",      "C", 25, 0} )
	   DBcreate2 (SIFPATH+'DIO.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"DIO")
endif

if (nArea==-1 .or. nArea==(F_UREDJ))
	// UREDJAJ - parovi (mjesto trebovanja,uredjaj)
	IF ! FILE ( SIFPATH + "UREDJ.DBF")
	   aDbf := {}
	   AADD ( aDbf, {"ID"        , "C",  2, 0} )
	   AADD ( aDbf, {"NAZ"       , "C", 30, 0} )
	   AADD ( aDbf, {"PORT"      , "C", 10, 0} )
	   DBcreate2 (SIFPATH+'UREDJ.DBF', aDbf)
	ENDIF
	CREATE_INDEX ("ID", "ID", SIFPATH+"UREDJ")
	CREATE_INDEX ("NAZ", "NAZ", SIFPATH+"UREDJ")
endif

if (nArea==-1 .or. nArea==(F_RNGOST))
	// RNGOST.DBF
	if !FILE(SIFPATH+"RNGOST.DBF")
		aDbf := {}
	  	AADD (aDbf, {"ID",       "C",  8, 0})
	  	AADD (aDbf, {"NAZ",      "C", 40, 0})
	  	AADD (aDbf, {"IDVRSTEP", "C",  2, 0})
	  	AADD (aDbf, {"STATUS",   "C",  1, 0})
	  	AADD (aDbf, {"TIP",      "C",  1, 0}) // P-partner, S-soba
	  	DBcreate2(SIFPATH+"RNGOST", aDbf)
	endif
	CREATE_INDEX("ID", "ID", SIFPATH+"RNGOST")
	CREATE_INDEX("NAZ", "NAZ", SIFPATH+"RNGOST")
	if IsTigra()
		CREATE_INDEX("IDN","idn",SIFPATH+"RNGOST",.t.)
		CREATE_INDEX("IDFMK","idfmk",SIFPATH+"RNGOST",.t.)
	endif
endif

if (nArea==-1 .or. nArea==(F_SIFK))
	if !file(SIFPATH+"SIFK.dbf")
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
	   AADD(aDBf,{ 'SORT'                , 'C' ,   2 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
	   AADD(aDBf,{ 'OZNAKA'              , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'VEZA'                , 'C' ,   1 ,  0 })
	   AADD(aDBf,{ 'UNIQUE'              , 'C' ,   1 ,  0 })
	   AADD(aDBf,{ 'IZVOR'               , 'C' ,  15 ,  0 })
	   AADD(aDBf,{ 'USLOV'               , 'C' , 100 ,  0 })
	   AADD(aDBf,{ 'DUZINA'              , 'N' ,   2 ,  0 })
	   AADD(aDBf,{ 'DECIMAL'             , 'N' ,   1 ,  0 })
	   AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
	   AADD(aDBf,{ 'KVALID'              , 'C' , 100 ,  0 })
	   AADD(aDBf,{ 'KWHEN'               , 'C' , 100 ,  0 })
	   AADD(aDBf,{ 'UBROWSU'             , 'C' ,   1 ,  0 })
	   AADD(aDBf,{ 'EDKOLONA'            , 'N' ,   2 ,  0 })
	   AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
	   AADD(aDBf,{ 'K2'                  , 'C' ,   2 ,  0 })
	   AADD(aDBf,{ 'K3'                  , 'C' ,   3 ,  0 })
	   AADD(aDBf,{ 'K4'                  , 'C' ,   4 ,  0 })

	   dbcreate2(SIFPATH+'SIFK.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id+SORT+naz",SIFPATH+"SIFK")
	CREATE_INDEX("ID2","id+oznaka",SIFPATH+"SIFK")
	CREATE_INDEX("NAZ","naz",SIFPATH+"SIFK")

endif

if (nArea==-1 .or. nArea==(F_SIFV))
	if !file(SIFPATH+"SIFV.dbf")  // sifrarnici - vrijednosti karakteristika
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
	   AADD(aDBf,{ 'OZNAKA'              , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'IDSIF'               , 'C' ,  15 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  50 ,  0 })
	   // Primjer:
	   // ID  = ROBA
	   // OZNAKA = BARK
	   // IDSIF  = 2MON0005
	   // NAZ = 02030303030303

	   dbcreate2(SIFPATH+'SIFV.DBF',aDbf)
	endif
	CREATE_INDEX("ID","id+oznaka+IdSif+Naz",SIFPATH+"SIFV")
	CREATE_INDEX("IDIDSIF","id+IdSif",SIFPATH+"SIFV")
	//  ROBA + BARK + 2MON0001
	CREATE_INDEX("NAZ","id+oznaka+naz",SIFPATH+"SIFV")
endif

if (nArea==-1 .or. nArea==(F_MARS))
	// MARS.DBF
	IF ! FILE ( SIFPATH + "MARS.DBF" )
	   aDbf := {}
	   AADD ( aDbf, { "ID",        "C",  8, 0} )
	   AADD ( aDbf, { "ID2",       "C",  8, 0} )
	   AADD ( aDbf, { "KM",        "N",  6, 1} )
	   DBcreate2 ( SIFPATH + "MARS.DBF", aDbf )
	ENDIF
	CREATE_INDEX ("ID", "ID"     , SIFPATH+"MARS")
	CREATE_INDEX ("2" , "ID+ID2" , SIFPATH+"MARS")
endif

if (nArea==-1 .or. nArea==(F_MESSAGE))
	if IsPlanika()
		CreDB_Message()
	endif
endif

return
*}

/*! \fn *void TDBPos::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *  S obzirom da se koristi prvenstveno za instalacijske funkcije
 *  otvara tabele u exclusive rezimu
 */

*void TDBPos::obaza(int i)
*{
method obaza(i)
local lIdIDalje
local cDbfName

PUBLIC gSifPath := SIFPATH


lIdiDalje:=.f.

if ( i==F_DOKS .or. i==F_POS .or. i==F_RNGPLA .or. i==F__POS .or. i==F__PRIPR .or. i==F_PRIPRZ .or. i==F__POSP) 
	lIdiDalje:=.t.
endif

if (i==F_PRIPRG .or. i==F_K2C .or. i==F_MJTRUR .or. i==F_ROBAIZ .or. i==F_ROBA) 
	lIdiDalje:=.t.
endif

if i==F_SIROV .or. i==F_SAST .or. i==F_OSOB .or. i==F_STRAD 
	lIdiDalje:=.t.
endif

if i==F_TARIFA .or. i==F_VALUTE .or. i==F_VRSTEP .or. i==F_KASE .or. i==F_ODJ 
	lIdiDalje:=.t.
endif

if i==F_DIO .or. i==F_UREDJ .or. i==F_RNGOST .or. i==F_MARS .or. i==F_PARAMS .or. i==F_GPARAMS .or. i==F_KORISN .or. i==F_MPARAMS .or. i==F_GPARAMSP
	lIdiDalje:=.t.
endif

if (IsPlanika() .and. i==F_PROMVP)
	lIdiDalje:=.t.
endif

if (IsPlanika() .and. i==F_MESSAGE .and. i==F_TMPMSG)
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	select(i)
	usex(cDbfName)
else
	use
	return
endif

/*
#include "O_S_BAZE.CH"

// PROMETNE DATOTEKE

SET EXCLUSIVE ON

IF i==F_DOKS;	    O_DOKS	   ;ENDIF
IF i==F_POS;	    O_POS	   ;ENDIF
IF i==F_RNGPLA;     O_RNGPLA	   ;ENDIF

// RADNE PROMETNE DATOTEKE
IF i==F__POS;       O__POS         ;ENDIF
IF i==F__PRIPR;     O__PRIPR	   ;ENDIF
IF i==F_PRIPRZ;     O_PRIPRZ       ;ENDIF
IF i==F_PRIPRG;     O_PRIPRG       ;ENDIF

// PRIVATNE DATOTEKE
IF i==F_K2C;        O_K2C          ;ENDIF
IF i==F_MJTRUR;     O_MJTRUR	   ;ENDIF
IF i==F_ROBAIZ;     O_ROBAIZ	   ;ENDIF

// SIFARNICI
IF i==F_ROBA;       O_ROBA         ;ENDIF
IF i==F_SIROV;	    O_SIROV	   ;ENDIF
IF i==F_SAST;	    O_SAST	   ;ENDIF
IF i==F_OSOB;       O_OSOB         ;ENDIF
IF i==F_STRAD;	    O_STRAD	   ;ENDIF
IF i==F_TARIFA;     O_TARIFA	   ;ENDIF
IF i==F_VALUTE;     O_VALUTE	   ;ENDIF
IF i==F_VRSTEP;     O_VRSTEP	   ;ENDIF
IF i==F_KASE;	    O_KASE	   ;ENDIF
IF i==F_ODJ;	    O_ODJ	   ;ENDIF
IF i==F_DIO;        O_DIO          ;ENDIF
IF i==F_UREDJ;	    O_UREDJ	   ;ENDIF
IF i==F_RNGOST;     O_RNGOST       ;ENDIF
IF i==F_MARS;       O_MARS         ;ENDIF

SET EXCLUSIVE OFF
*/

return
*}

/*! \fn *void TDBPos::ostalef()
 *  \brief Ostalef funkcije (bivsi install modul)
 *  \note  sifra: SIGMAXXX
*/

*void TDBPos::ostalef()
*{

method ostalef()
if !SigmaSif("SIGMAXXX")
 return
endif

PUBLIC gSifPath := SIFPATH
PUBLIC gKumPath := KUMPATH

if pitanje(,"Izvrsiti prenos k7 iz c:\tops\robknj.dbf","N")=="D"
   close all
   usex (gSifpath+"ROBA") NEW
   set order to tag "ID"

   usex ("C:\tops\robknj") NEW
   go top
   do while !eof()
      select roba; seek robknj->id
      if found()
         replace k7 with robknj->k7
      endif

      select robknj
      skip
   enddo
   MsgC()

endif

if pitanje(,"Izvrsiti promjenu sifre artikla u sifrarniku i prometu? (D/N)","N")=="D"
  close all
  cStara := cNova := SPACE(10)
  cDN    := " "
  Box(,5,70)
    @ m_x+2, m_y+2 SAY "Zamijeniti sifru artikla:" GET cStara
    @ m_x+3, m_y+2 SAY "Nova sifra artikla      :" GET cNova
    @ m_x+4, m_y+2 SAY "Da li ste 100 % sigurni da ovo zelite ? (D/N)" GET cDN VALID cDN$"DN" PICT "@!"
    READ
  BoxC()
  if cDN=="D"

    nPR:=0
    usex (gSifpath+"ROBA") NEW
    set order to tag "ID"
    seek cStara
    do while !eof() .and. id==cStara
      skip 1; nRec:=RECNO(); skip -1
      ++nPR
      Scatter()
       _id := cNova
      Gather()
      go (nRec)
    enddo

    nPP:=0
    usex (gKumPath+"POS") NEW
    set order to tag "6"
    seek cStara
    do while !eof() .and. idroba==cStara
      skip 1; nRec:=RECNO(); skip -1
      ++nPP
      Scatter()
       _idroba := cNova
      Gather()
      go (nRec)
    enddo

    MsgBeep( "Broj promjena stavki u ROBA.DBF="+ALLTRIM(STR(nPR))+;
             ", u POS.DBF="+ALLTRIM(STR(nPP)) )

  endif
endif

closeret
return
*}

/*! \fn *void TDBPos::konvZn()
 *  \brief Koverzija znakova
 */
 
*void TDBPos::konvZn()
*{
method konvZn()

 LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
 LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"

 IF !SigmaSif("KZ      ")
   RETURN
 ENDIF

 Box(,8,50)
  @ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  @ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  @ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  @ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  @ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  READ
  IF LASTKEY()==K_ESC; BoxC(); RETURN; ENDIF
  IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    BoxC(); RETURN
  ENDIF
 BoxC()

 aPriv := { F__POS, F__PRIPR, F_PRIPRZ, F_PRIPRG, F_K2C, F_MJTRUR, F_ROBAIZ,;
            F_RAZDR }

 aKum  := { F_DOKS, F_POS, F_RNGPLA }

 aSif  := { F_ROBA, F_SIROV, F_SAST, F_STRAD, F_TARIFA, F_VALUTE,;
            F_VRSTEP, F_ODJ, F_DIO, F_UREDJ, F_RNGOST, F_MARS }


 IF cSif  == "N"; aSif  := {}; ENDIF
 IF cKum  == "N"; aKum  := {}; ENDIF
 IF cPriv == "N"; aPriv := {}; ENDIF

 KZNbaza(aPriv,aKum,aSif,cIz,cU)
RETURN
*}

//function sklonisezonu()
//return

/*
function O_Log()

local cPom, cLogF

cPom:=KUMPATH+"\SQL"
DirMak2(cPom)
cLogF:=cPom+SLASH+replicate("0",8)

OKreSQLPar(cPom)

public gSQLSite:=field->_SITE_
public gSQLUser:=1
use

//postavi site
Gw("SET SITE "+Str(gSQLSite))
Gw("SET TODATABASE OFF")
Gw("SET MODUL "+gModul)
return

*/

//function reindex_all()
//return

//function o_nar()
//return

/*! \fn *bool TDBPos::open()
 */
*bool TDBPos::open()
*{
method open

if gPratiStanje $ "D!"
  O_POS
endif

if gModul=="HOPS"
  O_DIO
  O_ROBAIZ
endif

O_MJTRUR
O_UREDJ
O_ODJ
O_K2C
O_ROBA
if  gSifK=="D"
   O_SIFK
   O_SIFV
endif
O__PRIPR
O__POS

return .t.
*}


/*! \fn *bool TDBPos::reindex()
 */
*bool TDBPos::reindex()
*{
method reindex
Reindex_All()
return
*}

*string FmkIni_PrivPath_POS_Slave
/*! \var FmkIni_PrivPath_POS_Slave
 *  \brief Kasa je slave, sto znaci da ne vrsi scandb funkciju
 *  \param N - Kasa je master (tekuca vrijednost), znaci da vrsi scaniranje Db-a
 *  \param D - Kasa je slave te ne vrsi ScanDb
 */

/*! \fn *void TDBPos::scan()
 */
*void TDBPos::scan()
*{
method scan
local nFree
local i
local cSlaveKasa

cSlaveKasa:=IzFmkIni("POS","Slave","N",PRIVPATH)

if ((gVrstaRs=="S") .or. (cSlaveKasa=="D"))
	return
endif

ScanDb()

if (gSql=="D")
	
	nFree:=GwDiskFree()
	//odredi kolicinu u MB
	nFree:=ROUND(((nFree)/1024)/1024,1)
	for i:=1 to 2
		if (nFree<50)
			MsgBeep("Na disku C: je ostalo samo "+ALLTRIM(STR(nFree,10,1))+" MB#oslobodite prostor na disku # ... ili prijavite u servis SC-a !!") 
		endif
	next
endif
return

if (gVrstaRs=="S")
	PrebSaKase()	
endif

*}

