#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/frm_dok.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.12 $
 * $Log: frm_dok.prg,v $
 * Revision 1.12  2004/06/08 07:32:33  sasavranic
 * Unificirane funkcije rabata
 *
 * Revision 1.11  2004/06/03 14:16:58  sasavranic
 * no message
 *
 * Revision 1.10  2003/07/09 09:56:51  mirsad
 * umjesto stampe svih racuna jednog dana odjednom za parametar Retroaktivno=D uveo stampu svih racuna u zadanom periodu
 *
 * Revision 1.9  2003/07/08 18:35:36  mirsad
 * uveo mogucnost stampe svih racuna jednog dana odjednom za parametar Retroaktivno=D
 *
 * Revision 1.8  2003/01/04 14:34:19  ernad
 * PartnSt - ispravke izvjestaja (umjesto I_RnGostiju staviti StanjePartnera)
 *
 * Revision 1.7  2002/12/27 12:43:02  sasa
 * promjenjen redosljed pregleda azuriranih dokumenata
 *
 * Revision 1.6  2002/06/25 10:52:09  sasa
 * no message
 *
 * Revision 1.5  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.4  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */

/*! \file fmk/pos/dok/1g/frm_dok.prg
 *  \brief Stampa azuriranog dokumenta
 */

/*! \fn PrepisDok()
 *  \brief Stampa azuriranog dokumenta
 */
function PrepisDok()
*{

local aOpc
private cFilter:=".t."

O_RNGOST
O_VRSTEP
O_DIO
O_ODJ
O_KASE
O_OSOB

set order to tag "NAZ"

O_TARIFA 
O_VALUTE
if IzFMKIni("Svi","Sifk")=="D"
	O_SIFK
	O_SIFV
endif
O_SIROV  
O_ROBA
O_DOKS   
O_POS

ImeKol:={{"Vrsta",{|| IdVd}},{"Broj ",{||PADR(IF(!Empty(IdPos),trim(IdPos)+"-","")+alltrim(BrDok),9)}}}

if IzFMKIni("TOPS","StAzurDok_PrikazKolonePartnera","N",EXEPATH)=="D"
	select DOKS
  	SET RELATION TO idgost INTO rngost
  	AADD(ImeKol,{PADR("Partner",25),{||PADR(TRIM(idgost)+"-"+TRIM(rngost->naz),25)}})
endif

if IsTigra()
	AADD(ImeKol,{"VP",{||IdVrsteP}})
	AADD(ImeKol,{"Sati",{||vrijeme}})
	AADD(ImeKol,{"Datum",{||datum}})
	AADD(ImeKol,{PADC("Iznos",10),{|| DokIznos(NIL)}})
	AADD(ImeKol,{"Radnik",{||IdRadnik}})
else
	AADD(ImeKol,{"VP",{||IdVrsteP}})
	AADD(ImeKol,{"Datum",{||datum}})
	AADD(ImeKol,{"Smj",{||smjena}})
	AADD(ImeKol,{PADC("Iznos",10),{|| DokIznos(NIL)}})
	AADD(ImeKol,{"Radnik",{||IdRadnik}})
endif

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

select DOKS

set cursor on

cVrste:="  "
dDatOd:=DATE()-1
dDatDo:=DATE()

Box(,3,60)
@ m_x+1,m_y+2 SAY "Datumski period:" GET dDatOd
@ m_x+1,col()+2 SAY "-" GET dDatDo
@ m_x+3,m_y+2 SAY "Vrste (prazno svi)" GET cVrste pict "@!"
read
BoxC()

if !empty(dDatOd).or.!empty(dDatDo)
	cFilter+=".and. Datum>="+cm2str(dDatOD)+".and. Datum<="+cm2str(dDatDo)
endif
if !empty(cVrste)
	cFilter+=".and. IdVd="+cm2str(cVrste)
endif
if !(cFilter==".t.")
	set filter to &cFilter
endif


// "1", "IdPos+IdVd+dtos(datum)+BrDok"
if klevel<="0".and.SigmaSif(gSTELA)
	set scope to
else
	set scopebottom to "W"
endif
GO TOP

aOpc:={"<Enter> - Odabir", "<T> - trazi", "<c-F> - trazi po koloni","<c-P>   - Stampaj listu"}

if klevel<="1"
	AADD( aOpc, "<F2> - promjena vrste placanja" )
endif

ObjDBedit( , 19, 77, {|| PrepDokProc () },"  STAMPA AZURIRANOG DOKUMENTA  ", "", .f., aOpc )

CLOSERET
return
*}


/*! \fn PrepDokProc()
 *  \brief Stampa azuriranog dokumenta u edit modu
 */
function PrepDokProc()
*{
local cLevel
local cOdg
local nRecNo
local ctIdPos
local dtDatum
static cIdPos
static cIdVd
static cBrDok
static dDatum
static cIdRadnik

// M->Ch je iz OBJDB
if M->Ch==0
	return (DE_CONT)
endif

if LASTKEY()==K_ESC
	return (DE_ABORT)
endif

do case
	case Ch==K_F2.and.kLevel<="1"
		if pitanje(,"Zelite li promijeniti vrstu placanja?","N")=="D"
           		cVrPl:=idvrstep
           		if !VarEdit({{"Nova vrsta placanja","cVrPl","Empty (cVrPl).or.P_VrsteP(@cVrPl)","@!",}},10,5,14,74,'PROMJENA VRSTE PLACANJA, DOKUMENT:'+idvd+"/"+idpos+"-"+brdok+" OD "+DTOC(datum),"B1")
             			return DE_CONT
           		endif
           		Scatter()
            		_idvrstep:=cVrPl
           		Gather()
           		return DE_REFRESH
        	endif
		return DE_CONT
	case Ch==K_CTRL_F9
		O_STRAD
        	select strad
		hseek gStrad
        	cLevel:=prioritet
        	use
		select doks
        	if clevel<>"0"
         		MsgBeep("Nedozvoljena operacija !")
         		return DE_CONT
        	endif
		if pitanje(,"Zelite li zaista izbrisati dokument","N")=="D"
           		select POS
           		set order to 1
           		Seek doks->(IdPos+idvd+dtos(Datum)+BrDok)
           		while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==doks->(IdPos+idvd+dtos(Datum)+BrDok)
             			skip
				nTTR:=recno()
				skip -1
             			delete
             			sql_delete()
             			go nTTR
           		enddo
           		select DOKS
           		delete
           		sql_delete()
           		return DE_REFRESH
        	endif

        	return DE_CONT

    	case Ch==K_ENTER
		altd()
      		do case
        		case DOKS->IdVd==VD_RN
				cOdg:="D"
				if glRetroakt
					cOdg:=Pitanje(,"Stampati tekuci racun? (D-da,N-ne,S-sve racune u izabranom periodu)","D","DNS")
				endif
				if cOdg=="S"
					nRecNo:=RECNO()
					ctIdPos:=gIdPos
					seek ctIdPos+VD_RN
					START PRINT CRET
					do while !eof() .and. IdPos+IdVd==ctIdPos+VD_RN
		          			aVezani:={{IdPos, BrDok, IdVd, datum}}
		          			StampaPrep(IdPos, dtos(datum)+BrDok, aVezani,.t.,.t.)
		          			select POM
						USE
		          			select DOKS
						skip 1
					enddo
					END PRINT
					go (nRecNo)
				elseif cOdg=="D"
	          			aVezani:={{IdPos, BrDok, IdVd, datum}}
	          			StampaPrep(IdPos, dtos(datum)+BrDok, aVezani,.t.)
					select POM
					USE
	          			select DOKS
				endif
        		case DOKS->IdVd=="16"
          			PrepisZad("ZADUZENJE ")
        		case DOKS->IdVd==VD_OTP
          			PrepisZad("OTPIS ")
        		case DOKS->IdVd==VD_REK
				PrepisZad("REKLAMACIJA")
			case DOKS->IdVd==VD_RZS
          			PrepisRazd()
        		case DOKS->IdVd=="IN"
          			PrepisInvNiv(.t.)
        		case DOKS->IdVd==VD_NIV
          			PrepisInvNiv(.f.)
        		case DOKS->IdVd==VD_PRR
          			PrepisKumPr()
        		case DOKS->IdVd==VD_PCS
          			PrepisPCS()
      		endcase
    	Case Ch==Asc("T").or.Ch==Asc("t")
      		select doks
		set cursor on
      		Box(,6,40,.f.)
      		if cIdPos==nil
        		cIdPos:=gIdPos
        		cIdVd:=SPACE(LEN(DOKS->IdVd))
        		cBrDok:=SPACE(LEN(DOKS->(BrDok)))
        		dDatum:=gDatum
        		cIdRadnik:=SPACE(LEN(gIdRadnik))
      		endif
      		cSmjer := "+"
      		@ m_x+1,m_y+2 SAY "   Prod. mjesto" GET cIdPos
      		@ m_x+2,m_y+2 Say "Vrsta dokumenta" GET cIdVd
      		@ m_x+3,m_y+2 Say " Broj dokumenta" GET cBrDok
      		@ m_x+4,m_y+2 SAY "          Datum" GET dDatum
      		@ m_x+5,m_y+2 SAY "         Radnik" GET cIdRadnik VALID Empty (cIdRadnik) .or. P_Osob (@cIdRadnik)
      		@ m_x+6,m_y+2 Say " Smjer trazenja" GET cSmjer VALID cSmjer $ "+-"
      		READ
      		BoxC()
      		if cSmjer=="+"
        		TB:down()
      		else
        		TB:up()
      		endif
      		tb:stabilize()
      		TB:hitTop:=TB:hitBottom:=.f.
      		while !(TB:hitTop.or.TB:hitBottom)
        		if (Empty(cIdPos).or.ALLTRIM(DOKS->IdPos)==AllTrim(cIdPos)).and.(Empty(cIdVd).or.DOKS->IdVd==cIdVd).and.(Empty(cBrDok).or.LTRIM(DOKS->BrDok)==ALLTRIM(cBrDok)).and.(Empty(dDatum).or.DOKS->Datum==dDatum).and.(Empty(cIdRadnik).or.DOKS->IdRadnik==cIdRadnik)
          			EXIT
        		endif
        		if cSmjer=="+"
          			TB:down()
        		else
          			TB:up()
        		endif
        		TB:stabilize()
      		end
      		RETURN (DE_REFRESH)
    	case Ch==K_CTRL_P
      		StDoks()
  	endcase

return (DE_CONT)
*}


/*! \fn PreglSRacun()
 *  \brief Pregled stalnog racuna
 */
function PreglSRacun()
*{

local oBrowse
local cPrevCol
private ImeKol
private Kol

cPrevCol:=SETCOLOR(INVERT)
SELECT _PRIPR
Zapp()
Scatter()
SELECT POS
seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
do while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
	Scatter ()
  	SELECT ROBA
  	HSEEK _IdRoba
  	_RobaNaz:=ROBA->Naz
  	_Jmj:=ROBA->Jmj
  	SELECT _PRIPR
  	Append Blank // _PRIPR
  	Gather()
  	SELECT POS
  	SKIP
enddo
SELECT _PRIPR
GO TOP
ImeKol:={{"Sifra",{|| idroba}},{"Naziv",{|| LEFT(RobaNaz,30)}},{"Kolicina",{|| STR(Kolicina,7,2)}},{"Cijena",{|| STR(Cijena,7,2)}},{"Iznos",{|| STR(Kolicina*Cijena,11,2)}}}

Kol:={1,2,3,4,5}
Box(,15,73)
@ m_x+1,m_y+19 SAY PADC ("Pregled "+IIF(gRadniRac=="D","stalnog ","")+"racuna "+TRIM(DOKS->IdPos)+"-"+ LTRIM (DOKS->BrDok),30) COLOR INVERT

oBrowse:=FormBrowse(m_x+2,m_y+1,m_x+15,m_y+73,ImeKol,Kol,{"Í","Ä","³"},0)
ShowBrowse(oBrowse,{},{})

SELECT _PRIPR
Zapp()
BoxC()
SETCOLOR (cPrevCol)
SELECT DOKS
return
*}


