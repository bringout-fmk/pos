#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/specif/excl/1g/croba.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: croba.prg,v $
 * Revision 1.2  2002/06/17 11:44:37  sasa
 * no message
 *
 *
 */
 

/*! \fn ASqlCRoba(nH,cFile,cIdRoba,cVM,cUI,nKolicina)
 *  \brief Azurira SQL upite u fajl cFajl
 *  \param nH          - kreiraj fajl za sql komande
 *  \param cFile       - ime fajla
 *  \param cIdRoba     - id robe
 *  \param cVM         - veleprodaja/maloprodaja
 *  \param cUI         - ulaz/izlaz (0 - setuj stanje na nKolicina, 1 - ulaz kolicina, 2 - izlaz kolicina)
 *  \param nKolicina   - kolicina robe
 */
 
function ASqlCroba(nH,cFile,cIdRoba,cVM,cUI,nKolicina)
*{
local cSQL
local aRez

if nH=0 
	// zapocni
  	aRez:=sqlexec(@nH,cFile,"sc","commit")
  	return "OK"
elseif left(cFile,5)="#END#"
  	//cidroba sadrzi u sebi ime fajla
  	aRez:=sqlexec(@nH,cFile,"sc","commit")
  	return "OK"  
else  
	// za svaki slucaj insertuj, pa ako vec ima nece se nista desiti
  	cSQL:="insert into croba (idrobafmk,stanjem,stanjev,ulazm,ulazv,realm,realv,datumm,datumv) values("+sqlvalue(cIdRoba)+", 0,0,0,0,0,0,CURDATE(),CURDATE())"
  	aRez:=sqlexec(@nH,cFile,"sc",cSQL)
endif

if cUI=="0" .and. cVM=="M"
	cSQL:="update  croba set stanjem=0, ulazm=0, realm=0, datumm=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
   	aRez:=sqlexec(@nH,cFile,"sc",cSQL)
elseif cUI=="0" .and. cVM=="V"
   	cSQL:="update croba set stanjev=0, ulazv=0, realv=0, datumv=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
   	aRez:=sqlexec(@nH,cFile,"sc",cSQL)
endif


if cUI<>"0" // nije pocetno stanje
	cSQL:="update croba set stanjem=stanjem+ulazm-realm, ulazm=0, realm=0, datumm=CURDATE() where idrobafmk="+sqlvalue(cIdroba)+" and CURDATE()<>datumm"
  	aRez:=sqlexec(@nH,cFile,"sc",cSQL)

  	cSQL:="update croba set stanjev=(stanjev+ulazv-realv), ulazv=0.0, realv=0.0, datumv=CURDATE() where idrobafmk="+sqlvalue(cIdroba)+" and CURDATE()<>datumv"
  	aRez:=sqlexec(@nH,cFile,"sc",cSQL)
endif

if cVM=="M"
	if cUI='0'
    		cSQL:="update croba set stanjem="+sqlvalue(nKolicina)+", datumm=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
    		aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 	elseif cUI=="1"
    		cSQL:="update  croba set ulazm=ulazm+"+sqlvalue(nKolicina)+", datumm=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
    		aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 	elseif cUI=="2"
    		cSQL:="update  croba set realm=realm+"+sqlvalue(nKolicina)+", datumm=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
    		aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 	endif
endif
if cVM=="V"
	if cUI='0'
    		//REPLACE StanjeV WITH nKolicina
    		cSQL:="update  croba set stanjev="+sqlvalue(nKolicina)+", datumv=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
    		aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 	elseif cUI=="1"
    		//REPLACE UlazV WITH UlazV+nKolicina
    		cSQL:="update  croba set ulazv=ulazv+"+sqlvalue(nKolicina)+", datumv=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
    		aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 	elseif cUI=="2"
    		//REPLACE RealV WITH RealV+nKolicina
    		cSQL:="update  croba set realv=realv+"+sqlvalue(nKolicina)+", datumv=CURDATE() where idrobafmk="+sqlvalue(cIdroba)
    		aRez:=sqlexec(@nH,cFile,"sc",cSQL)
 	endif
endif

return
*}


