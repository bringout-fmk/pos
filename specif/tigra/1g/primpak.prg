#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/specif/tigra/1g/primpak.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.4 $
 * $Log: primpak.prg,v $
 * Revision 1.4  2003/04/23 15:26:32  mirsad
 * prenos tops->fakt
 *
 * Revision 1.3  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.2  2002/06/17 11:44:50  sasa
 * no message
 *
 *
 */
 

/*! \fn SvediNaPrP()
 *  \brief generise se dokument koji svodi na primarno pakovanje
 */
 
function SvediNaPrP()
*{
O_ODJ
O_KASE
O_TARIFA
O_PRIPRZ
O_DOKS
O_POS
O_SIFK
O_SIFV
O_ROBA
if gModul=="HOPS"
	O_SIROV
end


// maska za postavljanje uslova

cRoba:=SPACE(30)
aUsl1:=nil
cIdPos:=gIdPos
aNiz:={}
cIdOdj:=SPACE(2)

if gVrstaRS <> "K"
	AADD (aNiz, {"Prodajno mjesto (prazno-svi)","cIdPos","cidpos='X'.or.empty(cIdPos).or. P_Kase(@cIdPos)","@!",})
endif
if gVodiOdj=="D"
  	AADD(aNiz,{"Odjeljenje (prazno-sva)","cIdOdj", "Empty (cIdOdj) .or. P_Odj(@cIdOdj)","@!",})
endif
	AADD (aNiz, {"Artikli  (prazno-svi)","cRoba",,"@!S30",})
while .t.
  	if !VarEdit( aNiz, 10,5,21,74,'Generacija dokumenta : svedi na primarno pakovanje',"B1")
    		CLOSERET
  	endif
  	aUsl1:=Parsiraj(cRoba,"IdRoba","C")
  	if aUsl1<>nil
    		exit
  	else
    		Msg("Kriterij za artikal nije korektno postavljen!")
  	endif
enddo

cZaduzuje:="R"
SELECT ODJ 
HSEEK cIdOdj
if Zaduzuje == "S"
  	cZaduzuje:="S"
  	cU:=S_U 
	cI:=S_I
  	cRSdbf:="SIROV"
else
  	cZaduzuje:="R"
  	cU:=R_U
	cI:=R_I
  	cRSdbf:="ROBA"
endif

SELECT POS

// ("2", "IdOdj+idroba+DTOS(Datum)", KUMPATH+"POS")
set order to 2   
if !(aUsl1==".t.")
	SET FILTER TO &aUsl1
endif

go top

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

		aSastav:=GetSastav(cRSDBF,cIdRoba)

    		if (LEN(aSastav) != 0)
       			select doks
       			cBrDok := NarBrDok (gIdPos, "16")
       			select (cRsDBF)
			hseek cidroba
       			select PRIPRZ
			// priprema zaduzenja
       			if ( (nUlaz-nIzlaz)  <> 0 )
        			// priprz
        			append blank
                		// zaduzi sekundarno pakovanje, uobicajeno je nulaz-nizlaz = -50 pak
				replace idroba with cidroba
				replace CIJENA with &(cRsdbf)->cijena1
				replace idtarifa with &(cRsdbf)->idtarifa
				replace KOLICINA with -(nUlaz-nIzlaz)
				replace JMJ with &(cRsdbf)->jmj
				replace RobaNaz with &(cRsdbf)->naz
				replace PREBACEN with OBR_NIJE
				replace IDRADNIK with gIdRadnik
				replace IdPos with gIdPos
				replace idOdj WITH cIdOdj
				replace IdVd  WITH "16"
				replace BrDok with cBrdok
				replace Smjena WITH gSmjena 
				replace DATUM with gDatum 
				replace idvrstep  with "PR"
      			endif
    		endif
		
    		select priprz
    		for i:=1 to len(aSastav)
      			cIdPrim:=aSastav[i,1]
      			select (cRsDBF)
			seek cIdPrim
      			nKolicina:=aSastav[i,2]
      			select priprz
      			if ((nulaz-nizlaz)*nkolicina<>0)
       				// priprz
       				append blank
       				replace idroba with cidPrim
				replace CIJENA with &(cRsdbf)->cijena1
				replace idtarifa with &(cRsdbf)->idtarifa
				replace KOLICINA with (nUlaz-nIzlaz) * nKolicina,JMJ with &(cRsdbf)->jmj
				replace RobaNaz with &(cRsdbf)->naz
				replace PREBACEN with OBR_NIJE
				replace IDRADNIK with gIdRadnik
				replace IdPos with gIdPos
				replace IdVd WITH "16"
				replace idodj WITH cIdOdj
				replace BrDok with cBrdok
				replace Smjena WITH gSmjena
				replace DATUM with gDatum,IDVRSTEP with "PR"
     			endif

    		next // len(aSastav)
    		select pos
enddo 
// idodj
//enddo // eof()

SELECT priprz
if RecCount2()<>0
	MsgBeep("Dokument je izgenerisan ... stavki:"+STR(RecCount2(),4)+"#Predjite u pripremu zaduzenja!")
else
	MsgBeep("Nisam nista napravio ...")
endif
closeret
*}


function GetSastav(cRSDBF,cIdRoba)
*{
local aSastav:={}
local nArr:=select()
//radi prema "sastavnici"
// "ID","id+oznaka+IdSif+Naz"
select sifv   
set order to tag "ID"
seek padr(cRSDBF,8)+"PAKO"+padr(cIdRoba,15)
// napuni matricu aSastav sa parovima "SIFRA" , KOLICINA
do while !eof() .and. (id+oznaka+idsif=PADR(cRSDBF,8)+"PAKO" + padr(cIdRoba,15) )
	cPom:=trim(naz)
	if numtoken(cPom,"_")=2
		AADD (aSastav, { token(cPom,"_",1) , val(token(cPom,"_",2))  } )
	endif
	skip
enddo
select (nArr)
return aSastav
*}


