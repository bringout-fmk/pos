#include "\cl\sigma\fmk\pos\pos.ch"

*string 
static cIdPos
*;

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/razdb/1g/pos_fakt.prg,v $
 *
 *
 */
 

//
// TOPSFAKT - datoteka koja se formira prilikom generacije iz TOPS-a
//            realizacije TOPS -> FAKT


/*! \ingroup ini
 *  \var FmkIni_ExePath_POS_PrenosGetPm
 *  \param 0 - default ne uzimaj oznaku i ne pitaj nista
 *  \param N - ne uzimaj i postavi pitanje
 *  \param D - uzmi bez pitanja
 */
 
/*! \fn GetPm()
 *  \brief Uzmi oznaku prodajnog mjesta
 */
 
static function GetPm()
*{
local cPm
local cPitanje

cPm:=cIdPos

cPitanje:=IzFmkIni("POS","PrenosGetPm","0")
if ((gVrstaRs<>"S") .and. (cPitanje=="0"))
	return ""
endif


if (gVrstaRs=="S") .or. ((cPitanje=="D") .or. Pitanje(,"Postaviti oznaku prodajnog mjesta? (D/N)","N")=="D")
	Box(,1,30)
		SET CURSOR ON
		@ m_x+1,m_Y+2 SAY "Oznaka prodajnog mjesta:" GET cPm
		read
	BoxC()
endif
return cPm
*}




/*! \fn Real2Fakt()
 *  \brief Prenos realizacije u FAKT
 */
 
function Real2Fakt()
*{

O_ROBA
O_SIFK
O_SIFV
O_RNGOST
O_KASE
O_POS
O_DOKS

cIdPos:=gIdPos
dDatOd:=DATE()
dDatDo:=DATE()
cIdPartnG:=SPACE(LEN(rngost->id))
cBezCijena:="D"

SET CURSOR ON

Box("#PRENOS REALIZACIJE POS->FAKT",6,70)
	@ m_x+2,m_y+2 SAY "Prodajno mjesto " get cIdPos pict "@!" Valid !EMPTY(cIdPos).or.P_Kase(@cIdPos,2,25)
	@ m_x+3,m_y+2 SAY "Partner gotovinski " get cIdPartnG pict "@!" Valid EMPTY(cIdPartnG).or.P_Gosti(@cIdPartnG,3,28)
	@ m_x+4,m_y+2 SAY "Prenos bez cijene i rabata? (D/N)" GET cBezCijena VALID cBezCijena$"DN" PICT "@!"
	@ m_x+5,m_y+2 SAY "Prenos za period" GET dDatOd
	@ m_x+5,col()+2 SAY "-" GET dDatDo
	read
	ESC_BCR
BoxC()

if gVrstaRS<>"S"
	cIdPos:=gIdPos
else
	// ako je server
	gIdPos:=cIdPos
endif

SELECT doks
SET ORDER TO 2  // IdVd+DTOS (Datum)+Smjena
SEEK VD_RN+DTOS(dDatOd)

if eof()
	MsgBeep("Nema nista za prenos!")
	CLOSERET
else
	if !empty(cIdPartnG)
		select rngost
		hseek cIdPartnG
		cIdPartnG:=rngost->idfmk
	else
		cIdPartnG:=SPACE(LEN(rngost->idfmk))
	endif
endif

PripTOPSFAKT(cIdPartnG)

select DOKS
nRbr:=0

do while !eof() .and. doks->IdVd==VD_RN .and. doks->Datum<=dDatDo

	if !EMPTY(cIdPos) .and. doks->IdPos<>cIdPos
    		SKIP
		LOOP
  	endif

  	SELECT pos
  	SEEK doks->(IdPos+IdVd+DTOS(datum)+BrDok)

	do while !eof().and.pos->(IdPos+IdVd+DTOS(datum)+BrDok)==doks->(IdPos+IdVd+DTOS(datum)+BrDok)
		Scatter()
		select topsfakt
		aSastav:=GetSastav("ROBA",pos->idRoba)
		if len(aSastav)>0
			cIdRoba:=aSastav[1,1]
			nKolicina:=aSastav[1,2]*pos->kolicina
			nPCijena:=pos->cijena/aSastav[1,2]
			nPopustCij:=pos->nCijena/aSastav[1,2]
		else
			cIdRoba:=pos->idRoba
			nKolicina:=pos->kolicina
			nPCijena:=pos->cijena
			nPopustCij:=pos->nCijena
		endif
		if cBezCijena=="D"
			nPCijena:=nPopustCij:=0
		endif
		cIdRoba:=PADR(cIdRoba,LEN(topsfakt->idRoba))
		if doks->placen<>"Z" // sve sto nije "Z" gotovina je
			cIdPartner:=cIdPartnG
			cIdVd:="12"
		else
			cIdPartner:=Ocitaj(F_RNGOST,doks->idGost,"idfmk")
			cIdVd:="10"
		endif
		
		if TRIM(cIdRoba)$"001F"
			altd()
		endif
		
		HSEEK POS->idPos+cIdVd+cIdPartner+cIdRoba+STR(nPCijena,13,4)+STR(nPopustCij,13,4)
		// seekuj i cijenu i popust (koji je pohranjen u ncijena)
		if !FOUND() //.or.idTarifa<>POS->idTarifa
			append blank
			replace idPos WITH POS->idPos
			replace idRoba WITH cIdRoba
			replace kolicina WITH nKolicina
			replace idTarifa WITH POS->idTarifa
			replace mpc With nPCijena
			replace datum WITH dDatDo
			replace idVd With cIdVd
			replace idPartner with cIdPartner
			replace stMPC With nPopustCij
			++nRbr
		else
			replace kolicina WITH Kolicina + nKolicina
		endif
		select pos
		skip 1
	enddo
	select doks
	skip 1
enddo

close all

cLokacija:=PADR("A:\",40)
Box("#DEFINISANJE LOKACIJE ZA PRENOS DATOTEKE TOPSFAKT",5,70)
	@ m_x+2, m_y+2 SAY "Datoteka TOPSFAKT je izgenerisana. Broj stavki:"+str(nRbr,4)
	@ m_x+4, m_y+2 SAY "Lokacija za prenos je:" GET cLokacija
	read
	if LASTKEY()<>K_ESC
		SAVE SCREEN TO cS
		cPom:="copy "+PRIVPATH+"TOPSFAKT.DBF "+TRIM(cLokacija)+"TOPSFAKT.DBF"
		run &cPom
		cPom:="copy "+PRIVPATH+"TOPSFAKT.CDX "+TRIM(cLokacija)+"TOPSFAKT.CDX"
		run &cPom
		RESTORE SCREEN FROM cS
	endif
BoxC()

CLOSERET
return
*}


function PripTOPSFAKT(cIdPartnG)
*{
aDbf:={}
AADD(aDBF,{"IdPos","C",2,0})
AADD(aDBF,{"IDROBA","C",10,0})
AADD(aDBF,{"IDPARTNER","C",LEN(cIdPartnG),0})
AADD(aDBF,{"kolicina","N",13,4})
AADD(aDBF,{"MPC","N",13,4})
AADD(aDBF,{"STMPC","N",13,4})
// stmpc - kod dokumenta tipa 42 koristi se za iznos popusta !!
AADD(aDBF,{"IDTARIFA","C",6,0})
AADD(aDBF,{"DATUM","D",8,0})
AADD(aDBF,{"IdVd","C",2,0})
AADD(aDBF,{"M1","C",1,0})

NaprPom(aDbf,"TOPSFAKT")

USEX (PRIVPATH+"TOPSFAKT") NEW
INDEX ON IdPos+idVd+idPartner+IdRoba+STR(mpc,13,4)+STR(stmpc,13,4) TAG ("1") TO (PRIVPATH+"TOPSFAKT")
INDEX ON brisano+"10" TAG "BRISAN"    //TO (PRIVPATH+"ZAKSM")
SET ORDER TO TAG "1"

return
*}




/*! \fn Stanje2Fakt()
 *  \brief Prenos stanja robe u FAKT
 */
 
function Stanje2Fakt()
*{

O_ROBA
O_SIFK
O_SIFV
O_RNGOST
O_KASE
O_POS
O_DOKS

cIdPos:=gIdPos
dDatOd:=CTOD("")
dDatDo:=DATE()
cIdPartnG:=SPACE(LEN(rngost->id))

SET CURSOR ON

Box("#PRENOS STANJA ROBE POS->FAKT",5,70)
	@ m_x+2,m_y+2 SAY "Prodajno mjesto " get cIdPos pict "@!" Valid !EMPTY(cIdPos).or.P_Kase(@cIdPos,2,25)
	@ m_x+3,m_y+2 SAY "Partner/dost.vozilo " get cIdPartnG pict "@!" Valid EMPTY(cIdPartnG).or.P_Gosti(@cIdPartnG,3,28)
	@ m_x+4,m_y+2 SAY "Stanje robe na dan" GET dDatDo
	read
	ESC_BCR
BoxC()

if gVrstaRS<>"S"
	cIdPos:=gIdPos
else
	// ako je server
	gIdPos:=cIdPos
endif

if !empty(cIdPartnG)
	select rngost
	hseek cIdPartnG
	cIdPartnG:=rngost->idfmk
else
	cIdPartnG:=SPACE(LEN(rngost->idfmk))
endif

PripTOPSFAKT(cIdPartnG)


// ------------------------------------------------------------------

SELECT POS

// ("2", "IdOdj+idroba+DTOS(Datum)", KUMPATH+"POS")
set order to 2   

go top

cIdOdj:=SPACE(2)
cZaduzuje:="R"
nRBr:=0
SEEK cIdOdj
//do while !eof()
//cIdOdj:=IdOdj
do while !eof() .and. POS->IdOdj==cIdOdj
	nStanje := 0
	nVrijednost := 0
	nUlaz := nIzlaz := 0
	cIdRoba := POS->IdRoba
	nUlaz:=nIzlaz:=nVrijednost:=0
	select pos
	do while !eof() .and. POS->IdOdj==cIdOdj .and. POS->IdRoba==cIdRoba
		if (KLevel>"0" .and. pos->idpos="X") .or.(!empty(cIdPos) .and. IdPos <> cIdPos)
      			skip
			loop
		endif
      
		if cZaduzuje=="S" .and. pos->idvd $ "42#01"
			// racuni za sirovine - zdravo
			skip
			loop  
		endif
		if cZaduzuje=="R" .and. pos->idvd=="96"
			// otpremnice za robu - zdravo
			skip
			loop 
		endif
			
		if POS->idvd $ "16#00"
       			nUlaz += POS->Kolicina
       			nVrijednost += POS->Kolicina * POS->Cijena
		elseif POS->idvd $ "42#01#IN#NI#96"
       			do case
       				case POS->IdVd == "IN"
       					nIzlaz += (POS->Kolicina-POS->Kol2)
       					nVrijednost -= (POS->Kol2-POS->Kolicina) * POS->Cijena
       				case POS->IdVd == VD_NIV
       					// ne mijenja kolicinu
       					nVrijednost := POS->Kolicina * POS->Cijena
       				otherwise  
					// 42#01
       					nIzlaz += POS->Kolicina
       					nVrijednost -= POS->Kolicina * POS->Cijena
       			endcase
		endif
		SKIP
	enddo


	select roba
	seek cIdRoba
	select topsfakt
	nKolicina:=nUlaz-nIzlaz
	cIdRoba:=PADR(cIdRoba,LEN(topsfakt->idRoba))
	cIdPartner:=cIdPartnG
	cIdVd:="12"
	if round(nKolicina,4)<>0
		append blank
		replace idPos WITH cIdPos
		replace idRoba WITH cIdRoba
		replace kolicina WITH nKolicina
		replace idTarifa WITH roba->idTarifa
		replace mpc With roba->cijena1
		replace datum WITH dDatDo
		replace idVd With cIdVd
		replace idPartner with cIdPartner
		replace stMpc With 0
		++nRbr
	endif
	select pos

enddo 

// ------------------------------------------------------------------

close all

cLokacija:=PADR("A:\",40)
Box("#DEFINISANJE LOKACIJE ZA PRENOS DATOTEKE TOPSFAKT",5,70)
	@ m_x+2, m_y+2 SAY "Datoteka TOPSFAKT je izgenerisana. Broj stavki:"+str(nRbr,4)
	@ m_x+4, m_y+2 SAY "Lokacija za prenos je:" GET cLokacija
	read
	if LASTKEY()<>K_ESC
		SAVE SCREEN TO cS
		cPom:="copy "+PRIVPATH+"TOPSFAKT.DBF "+TRIM(cLokacija)+"TOPSFAKT.DBF"
		run &cPom
		cPom:="copy "+PRIVPATH+"TOPSFAKT.CDX "+TRIM(cLokacija)+"TOPSFAKT.CDX"
		run &cPom
		RESTORE SCREEN FROM cS
	endif
BoxC()

CLOSERET
return
*}

