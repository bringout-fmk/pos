/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "pos.ch"


// -------------------------------------------
// Stampa azuriranog dokumenta
// -------------------------------------------
function PrepisDok()
local aOpc
private cFilter:=".t."
private ImeKol := {}
private Kol := {}

O_RNGOST
O_VRSTEP
O_DIO
O_ODJ
O_KASE
O_OSOB

set order to tag "NAZ"

O_TARIFA 
O_VALUTE
O_SIFK
O_SIFV
O_SIROV  
O_ROBA
O_DOKS   
O_POS

if !EMPTY(gRNALKum)
	o_doksrc( KUMPATH )
endif

AADD(ImeKol, {"Vrsta", {|| IdVd}})
AADD(ImeKol, {"Broj ",{||PADR(IF(!Empty(IdPos),trim(IdPos)+"-","")+alltrim(BrDok),9)}} )

if doks->(FIELDPOS("FISC_RN")) <> 0
	AADD(ImeKol, {"Fisk.rn", {|| fisc_rn}})
endif

if IzFMKIni("TOPS","StAzurDok_PrikazKolonePartnera","N",EXEPATH)=="D"
	select DOKS
  	SET RELATION TO idgost INTO rngost
  	AADD(ImeKol,{PADR("Partner",25),{||PADR(TRIM(idgost)+"-"+TRIM(rngost->naz),25)}})
endif

AADD(ImeKol,{"VP",{||IdVrsteP}})
AADD(ImeKol,{"Datum",{||datum}})

if gStolovi == "D"
	AADD(ImeKol,{"Sto",{||sto_br}})
else
	AADD(ImeKol,{"Smj",{||smjena}})
endif

AADD(ImeKol,{PADC("Iznos",10),{|| DokIznos(NIL)}})

if IsPlanika()
  // reklamacije (R)ealizovane, (P)riprema
  AADD(ImeKol,{"Rekl",{||if(idvd == VD_REK, sto, "   ")}})
  AADD(ImeKol,{"Na stanju",{||if(idvd == VD_ZAD, if(EMPTY(sto), "da ", "NE "), "   ")}})
endif

if !EMPTY(gRNALKum)
	// pregled radnih naloga - veza
	AADD(ImeKol,{"RNAL",{|| sh_rnal(idpos, datum, idvd, brdok) }})
endif

AADD(ImeKol,{"Radnik",{||IdRadnik}})

if gStolovi == "D"
	AADD(ImeKol,{"Zaklj",{||zak_br}})
endif

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

ObjDBedit( , 19, 77, {|| PrepDokProc (dDatOd, dDatDo) },"  STAMPA AZURIRANOG DOKUMENTA  ", "", .f., aOpc )

CLOSERET
return
*}


/*! \fn PrepDokProc()
 *  \brief Stampa azuriranog dokumenta u edit modu
 */
function PrepDokProc(dDat0, dDat1)
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
	case Ch==K_F6 // ispravka reklamacije
		if (IsPlanika() .and. idvd==VD_REK .and. Pitanje(,"Zelite promjeniti status reklamacije (D/N)?", "D")=="D")
			cRekInfo:=PADR(sto, 1)
			if !VarEdit({{"Novi status: (R)ealizovana (P)riprema","cRekInfo","!Empty (cRekInfo)","@!",}},10,5,14,74,'PROMJENA STATUSA REKLAMACIJE, DOKUMENT:'+idvd+"/"+idpos+"-"+brdok+" OD "+DTOC(datum),"B1")
             			return DE_CONT
           		endif
           		Scatter()
            		_sto:=cRekInfo
           		Gather()
			Sql_Azur(.t.)
			GathSql()
           		return DE_REFRESH
		endif
		return DE_CONT
	case Ch==K_CTRL_F9
		//if !SigmaSif("BRISRN")
		//	return DE_CONT
		//endif
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
           		
			// izbrisi i iz DOKSRC
			if gSamoProdaja=="N"
				if is_doksrc()
					d_doksrc(doks->idpos, doks->idvd, doks->brdok, doks->datum)
				endif
			endif
					
			select DOKS
           		delete
           		sql_delete()
           		return DE_REFRESH
        	endif

        	return DE_CONT

    	case Ch==K_ENTER
      		do case
        		case DOKS->IdVd==VD_RN
				
				cOdg:="D"
				
				if glRetroakt
					cOdg:=Pitanje(,"Stampati tekuci racun? (D-da,N-ne,S-sve racune u izabranom periodu)","D","DNS")
				endif
				
				if cOdg=="S"
					
					nRecNo:=RECNO()
					
					ctIdPos:=gIdPos
					seek ctIdPos + VD_RN
					
					START PRINT CRET
					
					do while !eof() .and. IdPos+IdVd==ctIdPos+VD_RN
		          			aVezani := {}
						
						if ( datum <= dDat1 )
							
							AADD( aVezani, { IdPos, BrDok, IdVd, datum} )
		          			
		          				StampaPrep(IdPos, dtos(datum)+BrDok, aVezani, .f., .t. )
						endif
						
						select doks
						skip 
					enddo
					
					END PRINT

					select doks
					go (nRecNo)

				elseif cOdg=="D"
	          			aVezani:={{IdPos, BrDok, IdVd, datum}}
	          			StampaPrep(IdPos, dtos(datum)+BrDok, aVezani, .t.)
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
				RETURN (DE_REFRESH)
        		case DOKS->IdVd==VD_PRR
          			PrepisKumPr()
        		case DOKS->IdVd==VD_PCS
          			PrepisPCS()
			case DOKS->IdVd==VD_CK
				StDokCK()
			case DOKS->IdVd==VD_SK
				StDokSK()
			case DOKS->IdVd==VD_GP
				StDokGP()
			case DOKS->IdVd==VD_PP
				StDokPP()
			case DOKS->IdVd==VD_ROP // reklamacija ostali podaci
				StDokROP(.t.)
      		endcase
	case (Ch==ASC("F") .or. Ch==ASC("f"))
		// stampa poreske fakture
		aVezani:={{IdPos, BrDok, IdVd, datum}}
	        StampaPrep(IdPos, dtos(datum)+BrDok, aVezani, .t., nil, .t.)
		select DOKS
		f7_pf_traka(.t.)
		select DOKS
		return (DE_REFRESH)
	case gStolovi == "D" .and. (Ch==Asc("Z").or.Ch==Asc("z"))
		if doks->idvd == "42"
			PushWa()
			print_zak_br(doks->zak_br)
			o_pregled()
			PopWa()
			select DOKS
			return (DE_REFRESH)		
		endif
		return (DE_CONT)
	
	case Ch==ASC("I") .or. Ch==ASC("i")
		// ispravka veze fiskalnog racuna
		nFisc_rn := field->fisc_rn
		nT_frn := nFisc_rn
		Box(,1,40)
			
			@ m_x+1,m_y+2 SAY "veza fisk.racun broj:" GET nFisc_rn
			
			read

		BoxC()

		if LastKey() <> K_ESC
			if nT_frn <> nFisc_rn
				replace field->fisc_rn with nFisc_rn
				return (DE_REFRESH)
			endif
		endif

		return (DE_CONT)

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
		
	case UPPER(CHR(Ch)) == "S"
		// setovanje da li je roba na stanju...
		if IsPlanika() .and. doks->idvd == VD_ZAD
			// setuj stanje ....
			Scatter()
			cRobaNaStanju := PADR(ALLTRIM(_sto), 1)
			if EMPTY(cRobaNaStanju)
				MsgBeep("Ovo zaduzenje je na stanju u prodavnici#Promjena ce se automatski odraziti na stanje artikala!")
			endif
			box_roba_stanje(@cRobaNaStanju)
			if cRobaNaStanju == "D"
				_sto := ""
			else
				_sto := cRobaNaStanju
			endif
			Gather() 
			sql_azur(.t.)
      			GathSQL()
			return DE_REFRESH
		endif
		
		return DE_CONT
	
	case UPPER(CHR(Ch)) == "I"
		// info o dokumentu...
		
		return DE_CONT
		
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
SELECT F__PRIPR
if !used()
	O__PRIPR
endif
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

oBrowse:=FormBrowse(m_x+2,m_y+1,m_x+15,m_y+73,ImeKol,Kol,{"�","�","�"},0)
ShowBrowse(oBrowse,{},{})

SELECT _PRIPR
Zapp()
BoxC()
SETCOLOR (cPrevCol)
SELECT DOKS
return
*}


