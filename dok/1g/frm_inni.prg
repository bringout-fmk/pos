#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/frm_inni.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.12 $
 * $Log: frm_inni.prg,v $
 * Revision 1.12  2003/06/28 15:05:16  mirsad
 * ispravljen bug na generisanju knjizne kolicine za inventuru
 *
 * Revision 1.11  2003/05/20 07:29:50  mirsad
 * Pri nivelaciji i inventuri generisao utrosak sirovina i za TOPS umjesto samo za HOPS
 *
 * Revision 1.10  2002/06/25 10:56:11  sasa
 * no message
 *
 * Revision 1.9  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.8  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.7  2002/06/17 07:32:24  sasa
 * ispravka greske inicijalizovanja fInvent varijable
 *
 * Revision 1.6  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
/*! \file fmk/pos/dok/1g/frm_inni.prg
 *  \brief Inventura/Nivelacija
 */
 

/*! \fn InvertNivel()
 *  \brief Inventura ili nivelacija
 *  \param lInvent:=.t. -> radi se o inventuri
 *  \param lInvent:=.f. -> radi se o nivelaciji
 *  \param fIzZad -> poziva se iz funkcije zaduzenja
 *  \param fSadAz -> azuriraj odmah
 */

function InventNivel()

*{
parameters fInvent, fIzZad, fSadAz, dDatRada

local i:=0
local j:=0
local fPocInv:=.f.
local fPreuzeo:=.f.
local cNazDok

private cRSdbf
private cRSblok
private cUI_U
private cUI_I
private cIdVd
private cZaduzuje:="R"

if gSamoProdaja=="D"
	MsgBeep("Ne mozete vrsiti zaduzenja !")
   	return
endif

if dDatRada==nil
	dDatRada:=gDatum
endif

if fInvent==nil
	fInvent:=.t.
else
	fInvent:=fInvent
endif

if fInvent
	cIdVd:=VD_INV
else
	cIdVd:=VD_NIV
endif

if fInvent
	cNazDok:="INVENTUR"
else
	cNazDok:="NIVELACIJ"
endif

if fIzZad==nil
	fIzZad:=.f.  // fja pozvana iz zaduzenja
endif
if fSadAz==nil
	fSadAz:=.f.  // fja pozvana iz zaduzenja
endif

if fIzZad
  // ne diraj ove varijable
else
	private cIdOdj:=SPACE(2)
	private cIdDio:=SPACE(2)
endif

O_InvNiv()

set cursor on
if !fIzZad
// 0) izbor mjesta trebovanja za koje se radi inventura/nivelacija
///////////////////////////////////////////////////////////
	aNiz:={}
	if gVodiOdj=="D"
		AADD(aNiz,{"Sifra odjeljenja","cIdOdj","P_Odj(@cIdOdj)",,})
	endif
	if gPostDO=="D".and.fInvent
		AADD(aNiz,{"Sifra dijela objekta","cIdDio","P_Dio(@cIdDio)",,})
	endif

	AADD(aNiz,{"Datum rada", "dDatRada","dDatRada<=DATE()",,})

	if !VarEdit(aNiz,9,15,15,64,cNazDok+"A","B1")
		CLOSERET
	endif
endif

SELECT ODJ

if ODJ->Zaduzuje=="S"
	cZaduzuje:="S"
  	cRSdbf:="SIROV"
  	cRSblok:="P_Sirov2 (@_IdRoba)"
  	cUI_U:=S_U
	cUI_I:=S_I
else
  	cZaduzuje:="R"
  	cRSdbf:="ROBA"
  	cRSblok:="P_Roba2 (@_IdRoba)"
  	cUI_U:=R_U
	cUI_I:=R_I
endif

if !VratiPripr(cIdVd,gIdRadnik,cIdOdj,cIdDio)
	CLOSERET
endif

SELECT PRIPRZ
// pocetak inventure
if RecCount2()==0
	fPocInv:=.t.
else
	fPocInv:=.f.
endif

// 1) formiranje pomocne baze sa knjiznim stanjima artikala

if fPocInv    
	cBrDok:=DOKS->(NarBrDok(gIdPos,cIdVd))
	fPreuzeo:=.f.
	if !fPreuzeo
		if gModul=="HOPS"
			GenUtrSir(gDatum,gDatum,gSmjena)
		endif
		O_InvNiv()
  	endif
	if fPocInv.and.!fPreuzeo.and.cIdVd==VD_INV
    		// generisi stavke SAMO ZA INVENTURU (nemoj za NIVELACIJU)
    		MsgO("GENERISEM DATOTEKU "+cNazDok+"E")
    		SELECT PRIPRZ 
		Scatter()
    		SELECT POS
		set order to 2
    		// CREATE_INDEX ("2", "IdOdj+idroba+DTOS(Datum)", KUMPATH+"POS")
    		SEEK cIdOdj
    		do while !eof().and.IdOdj==cIdOdj
      			if POS->Datum>dDatRada
				SKIP
				LOOP
			endif
      			_Kolicina:=0
      			_IdRoba:=POS->IdRoba
      			do while !eof().and.POS->(IdOdj+IdRoba)==(cIdOdj+_IdRoba) .and.POS->Datum <= dDatRada
        			if ALLTRIM(gIdPos)=="X"
          				if !(ALLTRIM(POS->IdPos)=="X")
            					SKIP
						LOOP
          				endif
        			else
          				if ALLTRIM(POS->IdPos)=="X".and.!gColleg=="D"
          					// ako je kolegium, u inventuru ulazi i razduzenja X-a
            					SKIP
						LOOP
          				endif
        			endif
        			if !Empty(cIdDio).and.POS->IdDio<>cIdDio
          				SKIP
					LOOP
        			endif
        			if cZaduzuje=="S".and.pos->idvd$"42#01"
           				SKIP
					LOOP  // racuni za sirovine - zdravo
        			endif
        			if cZaduzuje=="R".and.pos->idvd=="96"
           				SKIP
					LOOP   // otpremnice za robu - zdravo
        			endif
        			if POS->idvd$"16#00"
          				// na ulazu imam samo VD_ZAD i VD_PCS
          				_Kolicina += POS->Kolicina
        			elseif POS->idvd $ "42#96#01#IN#NI"
          				// na izlazu imam i VD_INV i VD_NIV
          				do case
            					case POS->IdVd == VD_INV
              						_Kolicina -= POS->Kolicina - POS->Kol2
            					case POS->IdVd == VD_NIV
              						// ne mijenja kolicinu
            					otherwise
              						_Kolicina -= POS->Kolicina
          				endcase
        			endif
        			SKIP
      			enddo
      			if Round(_Kolicina,3)<>0
        			SELECT (cRSdbf)
        			HSEEK _IdRoba
        			_Cijena:=_field->Cijena1     
				// postavi tekucu cijenu
        			_NCijena:=_field->Cijena1
        			_RobaNaz:=_field->Naz 
				_Jmj:=_field->Jmj
        			_idtarifa:=_field->idtarifa
               			SELECT PRIPRZ
        			_IdOdj:=cIdOdj 
				_IdDio:=cIdDio
        			_BrDok:=cBrDok 
				_IdVd:=cIdVd
        			_Prebacen:=OBR_NIJE
        			_IdCijena:="1"
        			_IdRadnik:=gIdRadnik 
				_IdPos:=gIdPos
        			_datum:=dDatRada 
				_Smjena:=gSmjena
        			_Kol2:=_Kolicina
        			_MU_I:=cUI_I
				// INVENTURU smatram izlazom za kolicinu
                              	// "viska"
        			APPEND BLANK  // priprz
        			Gather()
        			SELECT pos
      			endif
    		enddo  // !eof() .and. IdOdj == cIdOdj
    		MsgC()
  	else
    		SELECT PRIPRZ
    		Zapp() 
		__dbPack()
	endif
else
	SELECT PRIPRZ
	GO TOP
  	cBrDok:=PRIPRZ->BrDok
endif

// 2) prikaz formirane baze u browse-sistemu sa mogucnoscu:
//    - unosa stvarnog stanja (ispravka stavke)
//    - unosa novih stavki
//    - brisanja stavki
//    - stampanja dokumenta inventure
//    - stampanja popisne liste

if !fSadAz  // azuriraj odmah
	ImeKol := {}
	AADD(ImeKol,{ "Sifra i naziv", {|| IdRoba+"-"+LEFT (RobaNaz, 25)}})
	if cIdVd==VD_INV
  		AADD(ImeKol, { "Knj.kol." , {|| str(Kolicina,9,3)          }})
  		AADD(ImeKol, { "Pop.kol." , {|| str(Kol2,9,3)          },"kol2"})
	else
  		AADD(ImeKol, { "Kolicina" , {|| str(Kolicina,9,3)          }})
	endif
	AADD(ImeKol, { "Cijena "    , {|| str(cijena,7,2)            }})
	if cIdVd==VD_NIV
  		AADD(ImeKol, { "Nova C.",     {|| str(ncijena,7,2)           }})
	endif
	Kol:={}
	for nCnt:=1 TO LEN(ImeKol)
		AADD(Kol,nCnt)
	next

	SELECT PRIPRZ 
	set order to 1
	do while .t.
  		SELECT PRIPRZ
		GO TOP
		@ 12,0 SAY ""
  		SET CURSOR ON
  		ObjDBedit("PripInv",15,77,{|| EditInvNiv()},"Odjeljenje: "+cIdOdj+"-"+ALLTRIM(Ocitaj(F_ODJ,cIdOdj,"naz"))+""+IIF(Empty(cIdDio),"","Dio objekta: "+cIdDio+"-"+ALLTRIM(Ocitaj(F_DIO,cIdDio,"naz"))+""),"PRIPREMA "+cNazDok+"E",.f.,{"<c-N>   Dodaj stavku", "<Enter> Ispravi stavku","<a-P>   Popisna lista", "<c-P>   Stampanje", "<c-A> cirk ispravka"},2,,,)

  		// 3) nakon prekida rada na inventuri (<Esc>) utvrdjuje se da li je inventura zavrsena
 
		i:=KudaDalje( "ZAVRSAVATE SA PRIPREMOM "+cNazDok+"E. STA RADITI S NJOM?",{ "NASTAVICU S NJOM KASNIJE","AZURIRATI (ZAVRSENA JE)","TREBA JE IZBRISATI","VRATI PRIPREMU "+cNazDok+"E" })

		if i==1     // ostavi je za kasnije
      			SELECT _POS
      			AppFrom("PRIPRZ", .f.)
      			SELECT PRIPRZ
      			Zapp()
			__dbPack()
      			close all
			return
  		elseif i==3 // obrisati pripremu
      			SELECT PRIPRZ
      			Zapp()
      			close all
			return
  		elseif i==4     // vracamo se na pripremu
      			SELECT PRIPRZ
			GO TOP
			LOOP
  		endif

  		if i==2 // izvsiti azuriranje
    			exit // izadji iz petlje, izvrsi azuriranje
  		endif

	enddo  // browse while petlja
endif // fsadaz

//  DONJE LINIJE DEFINISU PROCES AZURIRANJA

Priprz2Pos()
CLOSERET

return
*}


/*! \fn EditInvNiv()
 *  \brief Ispravka nivelacije ili inventure
 */
function EditInvNiv()
*{

local nRec:=RECNO()
local i:=0
local lVrati:=DE_CONT

do case
	case Ch==K_CTRL_P
     		StampaInv()
     		GO nRec
     		lVrati:=DE_REFRESH
   	case Ch==K_ALT_P
     		if cIdVd==VD_INV
       			StampaInv(.t.)
       			GO nRec
       			lVrati:=DE_REFRESH
     		endif
   	case Ch==K_ENTER
     		if !(EdPrInv(1)==0)
       			lVrati:=DE_REFRESH
     		endif
   	case Ch==K_CTRL_A
     		do while !eof()
       			if EdPrInv(1)==0
				exit
			endif
        		skip
     		enddo
     		if eof()
			skip -1
		endif
     		lVrati:=DE_REFRESH
   	case Ch==K_CTRL_N  // nove stavke
     		EdPrInv(0)
     		lVrati:=DE_REFRESH
endcase
return lVrati
*}



/*! \fn EdPrInv(nInd)
 *  \brief 
 */
function EdPrInv(nInd)
*{

local nVrati:=0
local aNiz:={}
local nRec:=RECNO()
// slijedi ispravka stavke (nInd==1) ili petlja unosa stavki (nInd==0)
SET CURSOR ON
Box(,5,60,.t.)
@ m_x+0,m_y+1 SAY " "+IF(nInd==0,"NOVA STAVKA","ISPRAVKA STAVKE")+" "
SELECT priprz
do while .t.
	Scatter()
  	select (cRSdbf)
	hseek _idroba
  	@ m_x+0,m_y+1 SAY _idroba+" : "+naz
  	select priprz
  	if nInd==0  // unosenje novih stavki
    		_IdOdj:=cIdOdj
		_IdDio:=cIdDio
    		_idroba:=SPACE(len(idroba))
    		_Kolicina:=0  
    		_Kol2:=0
    		_BrDok:=cBrDok
    		_IdVd:=cIdVd
   		_Prebacen:=OBR_NIJE
    		_IdCijena:="1"
    		_IdRadnik:=gIdRadnik 
		_IdPos:=gIdPos
    		_datum:=gDatum
		_Smjena:=gSmjena
    		_MU_I:=cUI_I
		// i inventuru i nivelaciju cu smatrati izlazom
  	endif
	nLX := m_x+1
  	if nInd==0
    		@ nLX,m_y+3 SAY "      Artikal:" GET _IdRoba VALID &cRSblok .and. RacKol (_IdOdj, _IdRoba, @_Kolicina)
    		nLX++
    		if cIdVd==VD_INV
      			@ nLX,m_y+3 SAY "Knj. kolicina:" GET _Kolicina
    		else
      			@ nLX,m_y+3 SAY "     Kolicina:" GET _Kolicina
    		endif
    		nLX++
  	endif
  	if cIdVd==VD_INV
    		@ nLX,m_y+3 SAY "Pop. kolicina:" GET _Kol2
    		nLX++
  	endif
  	@ nLX,m_y+3 SAY "       Cijena:" GET _Cijena
  	if cIdVd==VD_NIV
    		nLX++
    		@ nLX,m_y+3 SAY "  Nova cijena:" GET _Ncijena
  	endif
  	READ
  	if LastKey()==K_ESC
    		exit
  	endif
    	// priprz
  	if nInd==0
		Append Blank 
	endif
  	Gather()
  	if nInd==1
		nVrati:=1
		EXIT
	endif
enddo
BoxC()
GO nRec
return nVrati
*}


/*! \fn RacKol(cIdOdj,cIdRoba,nKol)
 *  \brief Racuna kolicinu robe
 *  \param cIdOdj
 *  \param cIdRoba
 *  \param nKol
 *  \return
 */
 
function RacKol(cIdOdj,cIdRoba,nKol)
*{

if cIdVd==VD_INV
	nKol:=0 
	// jer se generise priprema inventure, pa ako dodam novi
    	return .t.  
	// sigurno nije bilo ovog artikla
endif

MsgO("Racunam kolicinu ...")

SELECT POS
set order to 2
nKol:=0
Seek cIdOdj+cIdRoba
while !eof().and.POS->(IdOdj+IdRoba)==(cIdOdj+cIdRoba).and.POS->Datum <= dDatRada
	if ALLTRIM(POS->IdPos)=="X"
      		SKIP
		LOOP
    	endif
    	// ovdje ne gledam DIO objekta, jer nivelaciju uvijek radim za
    	// cijeli objekat
    	if POS->idvd $ "16#00"   // cUI_x su privatne varijable funkcije
      		nKol+=POS->Kolicina     // INVENTNIVEL
    	elseif POS->idvd $ "42#01#IN#NI"
      		do case
        		case POS->IdVd==VD_INV
          			nKol:=POS->Kol2
        		case POS->IdVd==VD_NIV
         			// ne utice na kolicinu
        		otherwise
          			nKol-=POS->Kolicina
      		endcase
    	endif
    	SKIP
enddo

MsgC ()
SELECT PRIPRZ
return (.t.)
*}

