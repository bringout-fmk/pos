#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/specif/tigra/1g/mars.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: mars.prg,v $
 * Revision 1.2  2002/06/17 12:02:55  sasa
 * no message
 *
 *
 */
 

/*! \fn P_Mars(cId,dx,dy)
 *  \brief Sifrarnik marsruta
 */

function P_Mars(cId,dx,dy)
*{
private ImeKol
private Kol

O_RNGOST
O_MARS

ImeKol:={ { "Partner 1"    , {|| id  } , "id"  , {|| .t.} , {|| P_Gosti(@wid) } },;
            { "Partner 2"    , {|| id2 } , "id2" , {|| .t.} , {|| P_Gosti(@wid2)} },;
            { "Kilometara"   , {|| km  } , "km"  };
          }

Kol:={1,2,3}
PostojiSifra(F_MARS,"ID",10,77,"Marsrute",@cid,dx,dy)
CLOSERET
*}


/*! \fn Marsute()
 *  \brief
 */
 
function Marsrute()
*{
local aOpc:={}
local h:={}
local Izb

AADD (aOpc, "1. tabela marsruta     ")
AADD (aOpc, "2. izvjestaj")

for Izb := 1 to Len (aOpc)
	AADD (h, "")
next

Izb := 1
while .t.
	Izb:=Menu("mars",aOpc,Izb,.f.)
    	do case
      		case Izb == 0
        		EXIT
      		case Izb == 1
        		P_Mars()
      		case Izb == 2
        		I_PKDV()
    	endcase
end
return
*}



/*! \fn I_PKDV()
 *  \brief Pregled Kretanja Dostavnog Vozila
 */
 
function I_PKDV()
*{
private cSPOd:=SPACE(8)
private cSPDo:=SPACE(8)
private dDatOd:=DATE()
private dDatDo:=DATE()

O_RNGOST
O_MARS
O_POS
O_DOKS

cPicIz := "9,999,999.99"
cPicKm := "99999"

m:=REPL("-",25)+" "+REPL("-",25)+" ------------ -----"

set cursor on
Box(,7,70)
@ m_x+0, m_y+2 SAY "PREGLED KRETANJA DOSTAVNOG VOZILA"
@ m_x+2, m_y+2 SAY "Odakle je krenulo (sifra partnera)" GET cSPod VALID P_Gosti(@cSPod)
@ m_x+3, m_y+2 SAY "Gdje je zavrsilo  (sifra partnera)" GET cSPdo VALID P_Gosti(@cSPdo)
@ m_x+5, m_y+2 SAY "Za period od" GET dDatOd
@ m_x+5, col()+2 SAY "do" GET dDatDo
READ
ESC_BCR
BoxC()

SELECT DOKS
SET FILTER TO datum>=dDatOd .and. datum<=dDatDo .and. idvd=="42"
GO TOP

START PRINT CRET

? "TOPS,", DATE()
?
? PADC("PREGLED KRETANJA DOSTAVNOG VOZILA",70)
? PADC("za period od "+DTOC(dDatOd)+" do "+DTOC(dDatDo),70)
?
? m
? PADC("R E L A C I J A",51)+"³   IZNOS    ³ km  "
? m
cSPP := cSPOd           // polaziste
nUKM := nUIznos := 0
do while !eof()
	cSP:=IdGost       // dolaziste
    	nIznos := 0
    	nKM    := 0
    	do while !eof() .and. cSP==idgost
      		SELECT POS
      		Seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
      		do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok) == DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
        		nIznos += POS->Kolicina*POS->Cijena
        		SKIP 1
      		enddo
      		SELECT DOKS
      		SKIP 1
    	enddo
    	// gotova relacija cSPP - cSP
        ? Ocitaj(F_RNGOST,cSPP,"left(naz,25)"), Ocitaj(F_RNGOST,cSP,"left(naz,25)")
    	?? " "
    	?? TRANSFORM( nIznos            , cPicIz )
    	?? " "
    	nKM := KM_MARS(cSPP,cSP)
    	?? TRANSFORM( nKM , cPicKm )
    	nUIznos += nIznos
    	nUKM    += nKM
    	cSPP := cSP
enddo

// kraj puta tj. posljednja relacija cSPP - cSPDo
? Ocitaj(F_RNGOST,cSPP,"left(naz,25)"), Ocitaj(F_RNGOST,cSPDo,"left(naz,25)")
?? " "
?? SPACE(12)
?? " "
nKM := KM_MARS(cSPP,cSPDo)
?? TRANSFORM( nKM , cPicKm )
nUKM    += nKM

// ukupno
// ------
? m
? PADR("UKUPNO:",52)
?? TRANSFORM( nUIznos            , cPicIz )
?? " "
?? TRANSFORM( nUKM , cPicKm )
? m
FF

END PRINT

CLOSERET
*}



/*! \fn KM_MARS(cId,cId2)
 *  \brief
 *  \param cId
 *  \param cId2
 */
 
function KM_MARS(cId,cId2)
*{
local nVrati:=0
local nArr:=SELECT()

SELECT MARS
SET ORDER TO TAG "2"
HSEEK cId+cId2
if FOUND()
	nVrati := km
else
     	HSEEK cId2+cId
      	if FOUND()
        	nVrati := km
      	else
        	nVrati := 0
      	endif
endif

SELECT (nArr)
return nVrati
*}



/*! \fn CRobaNDan(cIdRoba)
 *  \brief
 *  \param cIdRoba
 */
 
function CRobaNDan(cIdRoba)
*{
local cSQL
local aRez
cSQL:="select  stanjem,stanjev,ulazm,ulazv,realm,realv,datumm,datumv from croba "+;
     "  where idrobafmk="+sqlvalue(cIdroba)
aRez:=sqlselect("c:\sigma\sql","sc",cSQL, {"N","N","N","N","N","N","D","D"} )

if aRez[1,1]="ERR" .or. aRez[1,2]=0
 _Stanjem := 0
 _Stanjev := 0
 _Ulazm   := 0
 _Ulazv   := 0
 _realm   := 0
 _realv   := 0
 _datumm  := CTOD("")
 _datumv  := CTOD("")
else
 _Stanjem := aRez[2,1]
 _Stanjev := aRez[2,2]
 _Ulazm   := aRez[2,3]
 _Ulazv   := aRez[2,4]
 _realm   := aRez[2,5]
 _realv   := aRez[2,6]
 _datumm  := aRez[2,7]
 _datumv  := aRez[2,8]
endif

if DATE()<>_datumm
  cSQL:="update croba set stanjem=stanjem+ulazm-realm, ulazm=0, realm=0, datumm=CURDATE()"+;
        "  where idrobafmk="+sqlvalue(cIdroba)+" and "+;
        "  CURDATE()<>datumm"
  aRez:=sqlexec(-999,"c:\sigma\sql","sc",cSQL)
endif

if DATE()<>_datumv
  cSQL:="update croba set stanjev=(stanjev+ulazv-realv), "+;
        "  ulazv=0.0, realv=0.0, datumv=CURDATE() "+;
        "  where idrobafmk="+sqlvalue(cIdroba)+" and "+;
        "  CURDATE()<>datumv"
  aRez:=sqlexec(-999,"c:\sigma\sql","sc",cSQL)
endif

return
*}



