#include "\cl\sigma\fmk\pos\pos.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/main/2g/app.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.43 $
 * $Log: app.prg,v $
 * Revision 1.43  2004/05/21 11:25:02  sasavranic
 * Uvedena opcija popusta preko odredjenog iznosa
 *
 * Revision 1.42  2004/05/19 12:16:44  sasavranic
 * no message
 *
 * Revision 1.41  2004/05/11 07:39:33  sasavranic
 * Parametar za clanove/popust prebacen iz KUMPATH-a u PRIVPATH
 *
 * Revision 1.40  2004/04/27 11:01:39  sasavranic
 * Rad sa sezonama - bugfix
 *
 * Revision 1.39  2004/04/26 14:32:30  sasavranic
 * Dorade na opciji prenosa stanja partnera
 *
 * Revision 1.38  2004/04/19 14:50:28  sasavranic
 * Importovanje poruka sa druge lokacije:
 * APPSERVER: tops 11 11 /APPSRV /IMPMSG /P=I: /L=50
 * P= path
 * L= site
 *
 * Revision 1.37  2004/04/05 09:40:59  sasavranic
 * Uvedeno ispitivanje da li se TOPS treba registrovati ili ne
 *
 * Revision 1.36  2004/03/18 13:38:30  sasavranic
 * Popust za partnere
 *
 * Revision 1.35  2003/12/24 09:54:36  sasavranic
 * Nova varijanta poreza, uvrstene standardne funkcije za poreze iz FMK
 *
 * Revision 1.34  2003/11/28 11:38:13  sasavranic
 * Prilikom prenosa realizacije u KALK da generise i barkodove iz TOPS-a
 *
 * Revision 1.33  2003/10/27 13:01:24  sasavranic
 * Dorade
 *
 * Revision 1.32  2003/10/08 15:07:52  sasavranic
 * Uvedena mogucnost debug-a
 *
 * Revision 1.31  2003/09/08 11:49:41  mirsad
 * sada je PorezNaSvakuStavku=D po default-u
 *
 * Revision 1.30  2003/08/20 13:37:30  mirsad
 * omogucio ispis poreza na svakoj stavci i na prepisu racuna, kao i na realizaciji kase po robama
 *
 * Revision 1.29  2003/07/08 15:54:34  mirsad
 * uveo fmk.ini/kumpath/[POS]/Retroaktivno=D za mogucnost ispisa azur.racuna bez teksta "PREPIS" i za ispis "datuma do" na realizaciji umjesto tekuceg datuma
 *
 * Revision 1.28  2003/07/08 10:58:29  mirsad
 * uveo fmk.ini/kumpath/[POS]/Retroaktivno=D za mogucnost ispisa azur.racuna bez teksta "PREPIS" i za ispis "datuma do" na realizaciji umjesto tekuceg datuma
 *
 * Revision 1.27  2003/07/01 06:02:54  mirsad
 * 1) uveo public gCijDec za format prikaza decimala cijene na racunu
 * 2) prosirio format za kolicinu za jos jedan znak
 * 3) uveo puni ispis naziva robe na racunu (lomljenje u dva reda)
 *
 * Revision 1.26  2003/06/30 08:08:48  mirsad
 * 1) prosirio format prikaza kolicine na racunu sa 6 na 8 znakova i uveo public gKolDec za definisanje broja decimala
 *
 * Revision 1.25  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.24  2003/01/21 16:18:22  ernad
 * planika gSQL=D bug tops
 *
 * Revision 1.23  2003/01/14 17:48:39  ernad
 * tigra primpak
 *
 * Revision 1.22  2002/11/21 10:12:33  mirsad
 * promjena ::super:setGVars -> ::super:setTGVars
 *
 * Revision 1.21  2002/08/19 10:01:12  ernad
 *
 *
 * sql synchro cijena1, idtarifa za tabelu roba
 *
 * Revision 1.20  2002/07/01 11:24:11  ernad
 *
 *
 * gateway treba onemoguciti kada smo u meniju za odabir Db-a
 *
 * Revision 1.19  2002/07/01 10:46:40  ernad
 *
 *
 * oApp:lTerminate - kada je true, napusta se run metod oApp objekta
 *
 * Revision 1.18  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.17  2002/06/30 11:08:53  ernad
 *
 *
 * razrada: kalk/specif/planika/rpt_ppp.prg; pos/prikaz privatnog direktorija na vrhu; doxy
 *
 * Revision 1.16  2002/06/28 23:25:14  ernad
 *
 *
 * TOPS/HOPS naslovni ekran na osnovu FmkIni/KumPath [POS]/Modul=HOPS ili TOPS
 *
 * Revision 1.15  2002/06/26 10:45:35  ernad
 *
 *
 * ciscenja POS, planika - uvodjenje u funkciju IsPlanika funkcije (dodana inicijalizacija
 * varijabli iz FmkSvi u main/2g/app.prg/metod setGvars
 *
 * Revision 1.14  2002/06/26 00:15:45  ernad
 *
 *
 * Pos applikacioni server ...
 * poziv je: tops 11 11 /APPSRV /ISQLLOG /L=50
 *           tops 21 21 /APPSRV /ISQLLOG /L=51 itd.
 *
 * Revision 1.13  2002/06/25 10:15:08  ernad
 *
 *
 * krenuo dodati parametar "Planika" ... pa se sjetio da je to fmk/svi/specif.prg ... fja IsPlanika()
 *
 * Revision 1.12  2002/06/24 17:04:15  ernad
 *
 *
 * omoguceno da se "restartuje" program .... nakon podesenja sistemskog sata -> oApp:run() ....
 *
 * Revision 1.11  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.10  2002/06/23 11:57:23  ernad
 * ciscenja sql - planika
 *
 * Revision 1.9  2002/06/21 14:18:11  ernad
 *
 *
 * pos - planika, import sql
 *
 * Revision 1.8  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.7  2002/06/19 17:40:29  ernad
 * ciscenje ...
 *
 * Revision 1.6  2002/06/18 07:01:21  ernad
 * Gparams -> oAppMod:gParams()
 *
 * Revision 1.5  2002/06/17 07:31:39  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/pos/main/2g/app.prg
 *  \brief TPosMod objekat - glavni objekat POS modula
 * 
 */
 
/*! \fn TPosModNew()
 *  \brief funkcija koja kreira TPosMod objekat
 */

function PosTest()
*{
? "Pos test (pos/main/2g/app.prg)"
return
*}

function TPosModNew()
*{
local oObj

oObj:=TPosMod():new()

oObj:self:=oObj

return oObj
*}



#ifdef CPP

/*! \class TPosMod
 *  \brief POS aplikacijski modul
 */

class TPosMod: public TAppMod 
{
	public:
	*void dummy();
	*void setScreen();
	*void setGVars();
	*void mMenu();
	*void gProc(char Ch);
	*void sRegg();
	*void initdb();
	*void srv();
}
#endif


#ifndef CPP
#ifndef CLIP

#include "class(y).ch"
CREATE CLASS TPosMod INHERIT TAppMod
	
	EXPORTED: 
	method dummy
	method setScreen
	method setGVars
	method mMenu
	method gProc
	method sRegg
	method initdb
	method srv
	
END CLASS

#endif
#endif

/*! \fn TPosMod::dummy()
 *  \brief dummy
 */

*void TPosMod::dummy()
*{
method dummy()
return
*}


*void TPosMod::initdb()
*{
method initdb()
#ifdef CLIP
	? "TPosMod:initdb"
#endif
::oDatabase:=TDBPosNew()
return
*}

/*! \fn *void TPosMod::gProc(char Ch)
 * \brief opste funkcije POS modula
 */

*void TPosMod::gProc(char Ch)
*{
method gProc(Ch)
do case
      CASE Ch==K_SH_F2
        PPrint()
      CASE Ch==K_SH_F10
        self:gParams()
      CASE Ch==K_SH_F1
        Calc()
      CASE Ch==K_SH_F5
        self:oDatabase:vratiSez()
      CASE Ch==K_SH_F6
        IF kLevel <= L_UPRAVN
          altd()
	  self:oDatabase:logAgain(Godina_2(gDatum)+padl(month(gDatum),2,"0"),.f.,.t.)
	EndIF
      CASE Ch==K_SH_F7
        KorLoz()
end case
clear typeahead
return nil
*}

*void TPosMod::mMenu()
*{
method mMenu()
local Fx
local Fy

gPrevPos:=gIdPos

Fx:=4
Fy:=8

if gSql=="D"
	O_Log()
endif

self:oDatabase:scan()
close all

SETKEY(K_SH_F1,{|| Calc()})
O_DOKS
select DOKS

if !gNoReg
	TrebaRegistrovati(20)
endif

use

if gnDebug>0
	MsgBeep("!!! DEBUG Verzija !!!##Debug nivo -> " + AllTrim(STR(gnDebug)))
endif

MsgBeep("Ukoliko je predhodni put u toku rada#bilo problema  (nestanak struje, blokirao racunar...),## kucajte lozinku IB, pa <ENTER> !")

if (gVrstaRS<>"S")
	do while (.t.)
      		m_x:=Fx
      		m_y:=Fy
      		KLevel:=PosPrijava(Fx, Fy)
      		if (self:lTerminate)
			return
		endif
		SETPOS (Fx, Fy)
      		if (KLevel > L_UPRAVN  .and. gVSmjene=="D")
      			Msg("NIJE ODREDJENA SMJENA!!#"+"POTREBNO JE DA SE PRIJAVI SEF OBJEKTA#ILI NEKO VISEG RANGA!!!", 20)
        		loop
      		endif
      		if gVsmjene=="N"
        		gSmjena:="1"
        		OdrediSmjenu(.f.)
      		else
        		OdrediSmjenu(.t.) 
      		endif
      		exit
    	enddo
  	PrikStatus()
  	SETPOS(Fx, Fy)
  	fPrviPut:=.t.
else
	fPrviPut:=.f.
endif

PPrenosPos()

do while (.t.)

	m_x:=Fx
	m_y:=Fy
  	
	// unesi prijavu korisnika
  	if fPRviPut .and. gVSmjene=="N" // ne vodi vise smjena
    		fPrviPut:=.f.
  	else
    		KLevel:=PosPrijava(Fx, Fy)
    		PrikStatus()
  	endif
  	SETPOS (Fx, Fy)
  	MMenuLevel(KLevel,Fx,Fy)

	if self:lTerminate
		// zavrsi run!
		exit
	endif
enddo

CLOSE ALL

return
*}


/*! \fn MMenuLevel(KLevel,Fx,Fy)
 *  \brief
 *  \param KLevel
 *  \param Fx
 *  \param Fy
 */
 
function MMenuLevel(KLevel,Fx,Fy)
*{

do case
	case ((KLevel==L_ADMIN).or.(KLevel==L_SYSTEM))
        	MMenuAdmin()
        case (KLevel==L_UPRAVN)
        	if !CRinitDone
          		Msg("NIJE UNIJETO POCETNO STANJE SMJENE!!!", 10)
       		endif
       		SETPOS(Fx, Fy)
       		MMenuUpravn()
        case (KLevel==L_PRODAVAC)
              	if gVrstaRS<>"S"
          		SETPOS(Fx,Fy)
          		MMenuProdavac()
       		else
          		MsgBeep("Na serveru ne mozete izdavati racune")
       		endif
end case
return
*}

*void TPosMod::sRegg()
*{
method sRegg()

if (gModul=="HOPS")
	SReg("HOPS.EXE","HOPS")
else
	SReg("TOPS.EXE","TOPS")
endif

return
*}


/*! \fn *void TPosMod::srv()
 *  \brief Applikacijski server pos modula - batch komande
 *  \note prije je to bila procedura RunAppSrv()
 */
*void TPosMod::srv()
*{
method srv()
? "Pokrecem POS: Applikacion server"
if (mpar37("/ISQLLOG",goModul))
	if LEFT(self:cP5,3)=="/L="
		cLog:=SUBSTR(self:cP5,4)
		AS_ISQLLog(cLog)
	endif
endif

if (mpar37("/IALLMSG",goModul))
	InsertIntoAMessage()
	goModul:quit()
endif
altd()
if (mpar37("/IMPMSG",goModul))
	if LEFT(self:cP5,3)=="/P="
		if LEFT(self:cP6,3)=="/L="
			ImportMsgFrom(SUBSTR(self:cP5,4), SUBSTR(self:cP6,4))
			goModul:quit()
		endif
	endif
endif

return
*}


/*! \fn *void TPosMod::setScreen()
 *  \brief screen funkcije POS modula
 */

*void TPosMod::setScreen()
*{

method setScreen()

SetNaslov(self)
NaslEkran(.t.)

return
*}


/*! \fn *void TPosMod::setGVars()
 *  \brief opste funkcije POS modula
 */

*void TPosMod::setGVars()
*{

method setGVars()

::setTGVars()

SetFmkRGVars()
SetFmkSGVars()

// gPrevIdPos - predhodna vrijednost gIdPos
public gPrevIdPos:="  "

public gOcitBarcod:=.f.
public gSmijemRaditi:='D'
public gSamoProdaja:='N'
public gZauzetSam:='N'

// sifra radnika
public gIdRadnik        
// prezime i ime korisnika (iz OSOB)
public gKorIme          

// status radnika
public gSTRAD           

// identifikator seta cijena koji se
public gIdCijena:="1"   

public gPopust:=0
public gPopDec:=1
public gPopZcj:="N"
public gPopVar:="P"
public gPopProc:="N"
public gPopIzn:=0
public gPopIznP:=0
public SC_Opisi[5]      // nazivi (opisi) setova cijena
public gSmjena := " "   // identifikator smjene
public gDatum           // datum

public gVodiTreb        // da li se vode trebovanja (ako se vode, onda se i
                        // stampaju)
public gVodiOdj
public gRadniRac        // da li se koristi princip radnih racuna ili se
                        // racuni furaju kao u trgovini
public gDupliArt        // da li dopusta unos duplih artikala na racunu
public gDupliUpoz       // ako se dopusta, da li se radnik upozorava na duple

public gDirZaklj        // ako se ne koristi princip radnih racuna, da li se
                        // racuni zakljucuju odmah po unosu stavki
public gBrojSto         // da li je broj stola obavezan
                        // D-da, N-ne, 0-uopce se ne vodi
public gPoreziRaster    // da li se porezi stampaju pojedinacno ili
                        // zbirno
public gPratiStanje     // da li se prati stanje zaliha robe na
                        // prodajnim mjestima
public gPocStaSmjene    // da li se uvodi pocetno stanje smjene
                        // (da li se radnicima dodjeljuju pocetna sredstva)
public gIdPos           // id prodajnog mjesta

public gIdDio           // id dijela objekta u kome je kasa locirana
                        // (ima smisla samo za HOPS)

public nFeedLines       // broj linija potrebnih da se racun otcijepi
public CRinitDone       // da li je uradjen init kase (na pocetku smjene)

public gDomValuta    
public gGotPlac         // sifra za gotovinsko (default) placanje
public gDugPlac

public gVrstaRS         // vrsta radne stanice
                        // ( K-kasa S-server A-samostalna kasa)

public gLocPort:="LPT1" // lokalni port za stampanje racuna

public gStamPazSmj      // da li se automatski stampa pazar smjene
                        // na kasi
public gStamStaPun      // da li se automatski stampa stanje
                        // nedijeljenih punktova koje kasa pokriva
public gSjeciStr:=""
public gOtvorStr:=""
public gVSmjene:="N"
public gSezonaTip:="M"
public gSifUpravn:="D"
public gEntBarCod:="D"

public gPosNaz
public gDioNaz
public gRnHeder:="RacHeder.TXT"
public gRnFuter:="RacPodn.TXT "
public gZagIz:="1;2;"
public gColleg:="N"
public gDuplo:="N"
public gDuploKum:=""
public gDuploSif:=""
public gFmkSif:=""
// postavljanje globalnih varijabli
public gLocPort:="LPT1"
public gIdCijena:="1"

#ifdef CLIP
	return
#endif

self:cName:=IzFmkIni("POS","MODUL","TOPS",KUMPATH)
gModul:=self:cName

gKorIme:=""
gIdRadnik:=""
gStRad:=""

//SetNaslov(self)
//NaslEkran(.t.)
ToggleIns()
ToggleIns()
SayPrivDir(self:oDatabase:cDirPriv)

SC_Opisi [1] := "1"
SC_Opisi [2] := "2"
SC_Opisi [3] := "3"
SC_Opisi [4] := "4"
SC_Opisi [5] := "5"

gDatum:=DATE()

public gIdCijena:= "1"
public gPopust:= 0
public gPopDec:= 1
public gPopVar:= "P"
public gPopZcj:= "N"
public gZadCij:= "N"
public gPopProc:= "N"
public gIsPopust:=.f.

public gKolDec
gKolDec:=INT(VAL(IzFmkIni("TOPS","KolicinaDecimala","2",KUMPATH)))
public gCijDec
gCijDec:=INT(VAL(IzFmkIni("TOPS","CijenaDecimala","2",KUMPATH)))

public gStariObrPor
if IzFmkIni("POS","StariObrPor","N",EXEPATH)=="D"
	gStariObrPor:=.t.
else
	gStariObrPor:=.f.
endif

public gClanPopust
if IzFmkIni("TOPS","Clanovi","N",PRIVPATH)=="D"
	gClanPopust:=.t.
else
	gClanPopust:=.f.
endif

if (gModul=="HOPS")
	gVodiTreb:="D"
	gVodiOdj:="D"
	gBrojSto:="0"
	gRadniRac:="D"
	gDirZaklj:="N"
	gDupliArt:="N"
	gDupliUpoz:="D"
else
	gVodiTreb:="N"
	gVodiOdj:="N"
	gBrojSto:="0"
	gRadniRac:="N"
	gDirZaklj:="D"
	gDupliArt:="D"
	gDupliUpoz:="N"
endif

public gPoreziRaster:="D"
public gPratiStanje:="N"
public gIdPos:="1 "
public gPostDO:="N"
public gIdDio:="  "
// PUBLIC gNazKase      := PADR ("Kasa 1", 15)
public nFeedLines:=6
public gPocStaSmjene:="N"
public gStamPazSmj:="D"
public gStamStaPun:="D"
public CRinitDone:=.t.
public gVrstaRS:="A"

public gGotPlac:="01"
public gDugPlac:="DP"

public gSifPath:=SIFPATH
public LocSIFPATH:=SIFPATH
public gServerPath

gServerPath:=PADR(ToUnix("i:\sigma",40))

public gKalkDEST
gKalkDEST:=PADR(ToUnix("a:\",20))

public gModemVeza:="N"
public gStrValuta:=space(4)
public gUpitNp := "N"  // upit o nacinu placanja

O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

// podaci kase
Rpar("n8",@gVrstaRS)
Rpar("na",@gIdPos)
Rpar("PD",@gPostDO)
Rpar("DO",@gIdDio)
Rpar("n9",@gServerPath)
Rpar("kT",@gKalkDest)
Rpar("Mv",@gModemVeza)
Rpar("sV",@gStrValuta)
Rpar("n0",@gLocPort)
Rpar("n7",@gGotPlac)
Rpar("nX",@gDugPlac)

gServerPath := AllTrim(gServerPath)
if (RIGHT(gServerPath,1) <> SLASH)
	gServerPath+=SLASH
endif

// principi rada kase
cPrevPSS := gPocStaSmjene
//

Rpar("n2",@gVodiTreb)
Rpar("zc",@gZadCij)
Rpar("vO",@gVodiOdj)
Rpar("RR",@gRadniRac)
Rpar("Dz",@gDirZaklj)
Rpar("BS",@gBrojSto)
Rpar("n5",@gDupliArt)
Rpar("Nu",@gDupliUpoz)
Rpar("Ns",@gPratiStanje)
Rpar("nh",@gPocStaSmjene)
Rpar("nj",@gStamPazSmj)
Rpar("nk",@gStamStaPun)
Rpar("vs",@gVsmjene)
Rpar("ST",@gSezonaTip)
Rpar("Si",@gSifUpravn)
Rpar("Bc",@gEntBarCod)
// izgled racuna
gSjecistr:=padr(GETPStr(gSjeciStr),20)
gOtvorstr:=padr(GETPStr(gOtvorStr),20)
Rpar("n4",@gPoreziRaster)
Rpar("n6",@nFeedLines)
Rpar("sS",@gSjeciStr)
Rpar("oS",@gOtvorStr)
gSjeciStr:=Odsj(@gSjeciStr)
gOtvorStr:=Odsj(@gOtvorStr)

Rpar("zI",@gZagIz)
Rpar("RH",@gRnHeder)
Rpar("RF",@gRnFuter)
// cijene
Rpar("nb",@gIdCijena)
Rpar("pP",@gPopust)
Rpar("pd",@gPopDec)
Rpar("pV",@gPopVar)
Rpar("pC",@gPopZCj)
Rpar("pO",@gPopProc)
Rpar("pR",@gPopIzn)
Rpar("pS",@gPopIznP)

Rpar("Co",@gColleg)
Rpar("Du",@gDuplo)
Rpar("D7",@gDuploKum)
Rpar("D8",@gDuploSif)
Rpar("D9",@gFmkSif)

cPom:=SC_Opisi[1]
Rpar("nc",@cPom)
SC_Opisi[1]:=cPom

cPom:=SC_Opisi[2]
Rpar("nd",@cPom)
SC_Opisi[2]:=cPom

cPom:=SC_Opisi[3]
Rpar("ne",@cPom)
SC_Opisi[3]:=cPom

cPom:=SC_Opisi[4]
Rpar("nf",@cPom)
SC_Opisi[4]:=cPom

cPom:=SC_Opisi[5]
Rpar("ng",@cPom)
SC_Opisi[5]:=cPom

Rpar("np",@gUpitNp)

SELECT params
USE

RELEASE cSection,cHistory,aHistory

public gStela
gStela:=CryptSC(IzFmkIni("KL","PregledRacuna",CryptSC("STELA"),KUMPATH))
public gPVrsteP
gVrsteP:=IzFMKIni("TOPS","AzuriranjePrometaPoVP","N",KUMPATH)=="D"


if (gVrstaRS=="S")
	gIdPos:=Space(LEN(gIdPos))
endif

public gSQLKom
if (IzFmkIni('CROBA','GledajTops','N',KUMPATH)=="D")
	gSQLKom:= IzFmkIni("SQL","cSQLKom","mysql -f -h 192.168.0.1 -B -N ",KUMPATH)
	gSQLKom+=" "
endif
gSQL:=IzFmkIni("Svi","SQLLog","N",KUMPATH)
gSamoProdaja:=IzFmkIni("TOPS","SamoProdaja","N",PRIVPATH)
gSQLLogBase:=IzFmkIni("SQL","SQLLogBase","c:\sigma",EXEPATH)


public gPosSirovine
public gPosKalk
public gPosPrimPak

public gSQLSynchro
public gPosModem

public glRetroakt

glRetroakt:=(IzFmkIni("POS","Retroaktivno","N",KUMPATH)=="D")

gPosSirovine:="D"
gPosKalk:="D"
gPosPrimPak="D"

gSQLSynchro:="D"
gPosModem:="D"

public glPorezNaSvakuStavku

glPorezNaSvakuStavku:=(IzFmkIni("POS","PorezNaSvakuStavku","D",PRIVPATH)=="D")

public glPorNaSvStRKas
glPorNaSvStRKas:=(IzFmkIni("POS","PorezNaSvStRealKase","N",PRIVPATH)=="D")

if (!self:oDatabase:lAdmin .and. gVrstaRS<>"S")
	O_KASE
  	set order to tag "ID"
  	HSEEK gIdPos
  	if FOUND()
		gPosNaz:=AllTrim(KASE->Naz)
  	else
   		gPosNaz:="SERVER"
  	endif
  	O_DIO
  	set order to tag "ID"
  	HSEEK gIdDio
  	if FOUND()
  		gDioNaz := AllTrim (DIO->Naz)
  	else
  		gDioNaz:=""
  	endif
  	close all
endif

//  odredi naziv domace valute
if (!self:oDatabase:lAdmin) 
	SetNazDVal()
	if IsPlanika()	
		chkTblPromVp()
	endif
endif

SetBoje(gVrstaRS)


return
*}
