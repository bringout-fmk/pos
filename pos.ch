
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/pos.ch,v $
 * $Author: sasavranic $ 
 * $Revision: 1.123 $
 * $Log: pos.ch,v $
 * Revision 1.123  2004/06/10 13:06:18  sasavranic
 * no message
 *
 * Revision 1.122  2004/06/08 07:32:33  sasavranic
 * Unificirane funkcije rabata
 *
 * Revision 1.121  2004/06/03 14:16:58  sasavranic
 * no message
 *
 * Revision 1.120  2004/06/03 08:09:29  sasavranic
 * Popust preko odredjenog iznosa se odnosi samo na gotovinsko placanje
 *
 * Revision 1.119  2004/06/03 07:10:45  sasavranic
 * Rijesen bug: prenos realizacije POS->FAKT
 *
 * Revision 1.118  2004/05/21 11:25:01  sasavranic
 * Uvedena opcija popusta preko odredjenog iznosa
 *
 * Revision 1.117  2004/05/19 12:16:44  sasavranic
 * no message
 *
 * Revision 1.116  2004/05/15 12:15:28  sasavranic
 * U varijanti ugostiteljstva za prepis racuna iskoristena funkcija StampaRac()
 *
 * Revision 1.115  2004/05/13 10:28:54  sasavranic
 * Uvedena varijanta racunanja PRUCMP bez izbijanja PPP (sl.novine)
 *
 * Revision 1.114  2004/05/11 07:39:33  sasavranic
 * Parametar za clanove/popust prebacen iz KUMPATH-a u PRIVPATH
 *
 * Revision 1.113  2004/05/04 09:00:42  sasavranic
 * Pri preuzimanju realizacije ispravljen bug sa barkod-om
 *
 * Revision 1.112  2004/05/03 15:06:15  sasavranic
 * Uveo odabir prodajnog mjesta pri prenosu realizacije u KALK
 *
 * Revision 1.111  2004/04/27 11:01:39  sasavranic
 * Rad sa sezonama - bugfix
 *
 * Revision 1.110  2004/04/26 14:32:30  sasavranic
 * Dorade na opciji prenosa stanja partnera
 *
 * Revision 1.109  2004/04/19 14:50:28  sasavranic
 * Importovanje poruka sa druge lokacije:
 * APPSERVER: tops 11 11 /APPSRV /IMPMSG /P=I: /L=50
 * P= path
 * L= site
 *
 * Revision 1.108  2004/04/15 10:29:01  sasavranic
 * no message
 *
 * Revision 1.107  2004/04/09 14:43:43  sasavranic
 * Problem _pos otklonjen
 *
 * Revision 1.106  2004/03/18 13:37:56  sasavranic
 * Popust za partnere
 *
 * Revision 1.105  2004/02/18 08:15:13  sasavranic
 * no message
 *
 * Revision 1.104  2004/02/09 14:08:59  sasavranic
 * Apend sql loga i za sif osoblja
 *
 * Revision 1.103  2004/01/06 13:28:33  sasavranic
 * Menij poruke samo za varijantu planika=D
 *
 * Revision 1.102  2004/01/05 14:19:47  sasavranic
 * Brisane duplih sifara
 *
 * Revision 1.101  2003/12/27 09:00:24  sasavranic
 * Korekcije ispisa trebovanja
 *
 * Revision 1.100  2003/12/24 09:54:35  sasavranic
 * Nova varijanta poreza, uvrstene standardne funkcije za poreze iz FMK
 *
 * Revision 1.99  2003/12/04 15:44:01  sasavranic
 * Uvedno pitanje za popust ako se koristi generalni popust (ali ne "99" - gledaj sifrarnik)?
 *
 * Revision 1.98  2003/12/04 14:54:11  sasavranic
 * Uveden uslov za artikle sa JMJ='PAR'
 *
 * Revision 1.97  2003/12/03 14:32:43  sasavranic
 * Najprometniji artikli, prikaz kolone ID Roba
 *
 * Revision 1.96  2003/11/28 11:37:45  sasavranic
 * Prilikom prenosa realizacije u KALK da generise i barkodove iz TOPS-a
 *
 * Revision 1.95  2003/11/21 15:08:20  sasavranic
 * ispravljena opcija sortiranja racuna
 *
 * Revision 1.94  2003/11/11 12:12:30  sasavranic
 * Stampa poruka
 *
 * Revision 1.93  2003/11/10 09:51:13  sasavranic
 * planika->messaging
 *
 * Revision 1.92  2003/11/03 15:45:21  sasavranic
 * Ispis i dom.i str.valute na racunu
 *
 * Revision 1.91  2003/10/29 10:25:29  sasavranic
 * funkcija kreiranja message.dbf prebacena u pos/db
 *
 * Revision 1.90  2003/10/27 13:01:22  sasavranic
 * Dorade
 *
 * Revision 1.89  2003/10/08 15:07:50  sasavranic
 * Uvedena mogucnost debug-a
 *
 * Revision 1.88  2003/09/16 08:48:30  mirsad
 * ponovo promijenio algoritam za presortiranje racuna: uveo pomocne baze precno i drecno
 *
 * Revision 1.87  2003/09/08 11:49:41  mirsad
 * sada je PorezNaSvakuStavku=D po default-u
 *
 * Revision 1.86  2003/09/01 09:02:00  sasa
 * uvedeno polje ugovor u rngost (tigra-aura)
 *
 * Revision 1.85  2003/08/27 14:49:28  mirsad
 * 1) debug:presortiranje racuna  2) uveo setovanje gDatum i datuma racuna na sistemski pri ulasku u pripremu racuna
 *
 * Revision 1.84  2003/08/20 13:37:30  mirsad
 * omogucio ispis poreza na svakoj stavci i na prepisu racuna, kao i na realizaciji kase po robama
 *
 * Revision 1.83  2003/08/08 16:25:11  sasa
 * korekcije za tigru
 *
 * Revision 1.82  2003/08/07 15:37:50  sasa
 * bug kada je kolicina 0 na racunu
 *
 * Revision 1.81  2003/07/26 08:28:58  sasa
 * ispis poreskih stopa na svaku stavku
 *
 * Revision 1.80  2003/07/25 16:01:42  sasa
 * ispadanje programa, nisu bile otvorene tabele ROBA i TARIFA
 *
 * Revision 1.79  2003/07/23 13:34:46  sasa
 * pos <-> pos
 *
 * Revision 1.78  2003/07/09 09:56:51  mirsad
 * umjesto stampe svih racuna jednog dana odjednom za parametar Retroaktivno=D uveo stampu svih racuna u zadanom periodu
 *
 * Revision 1.77  2003/07/08 18:33:15  mirsad
 * 1) uveo brisanje zaklj.RN iz _pos.dbf nakon presortiranja da bih postigao prihvatljiv broj radnog RN na maski za unos racuna
 * 2) debug presortiranja: dodjeljivao brojeve obrnutim redoslijedom
 * 3) uveo mogucnost stampe svih racuna jednog dana odjednom za parametar Retroaktivno=D
 *
 * Revision 1.76  2003/07/08 10:58:29  mirsad
 * uveo fmk.ini/kumpath/[POS]/Retroaktivno=D za mogucnost ispisa azur.racuna bez teksta "PREPIS" i za ispis "datuma do" na realizaciji umjesto tekuceg datuma
 *
 * Revision 1.75  2003/07/05 11:27:43  mirsad
 * uveo uslov za prodajno mjesto pri pozivu pregleda racuna
 *
 * Revision 1.74  2003/07/04 18:14:32  mirsad
 * promjena funkcije za presortiranje brojeva racuna
 *
 * Revision 1.73  2003/07/04 12:49:58  sasa
 * ispis poreza ispod svake stavke na racunu
 *
 * Revision 1.72  2003/07/01 06:02:54  mirsad
 * 1) uveo public gCijDec za format prikaza decimala cijene na racunu
 * 2) prosirio format za kolicinu za jos jedan znak
 * 3) uveo puni ispis naziva robe na racunu (lomljenje u dva reda)
 *
 * Revision 1.71  2003/06/30 08:08:48  mirsad
 * 1) prosirio format prikaza kolicine na racunu sa 6 na 8 znakova i uveo public gKolDec za definisanje broja decimala
 *
 * Revision 1.70  2003/06/28 15:04:46  mirsad
 * 1) omogucen ispis naziva firme na izvjestajima
 * 2) ispravljen bug na generisanju knjizne kolicine za inventuru
 *
 * Revision 1.69  2003/06/24 13:15:09  sasa
 * no message
 *
 * Revision 1.68  2003/06/23 09:03:27  sasa
 * nver - zakljucivanje nezakljucenih racuna
 *
 * Revision 1.67  2003/06/21 12:23:17  sasa
 * nver - zakljucivanje nezakljucenih racuna
 *
 * Revision 1.66  2003/06/13 14:05:58  mirsad
 * debug: pritisak na programiranu tipku
 *
 * Revision 1.65  2003/06/10 17:34:05  sasa
 * stavljena u funkciju opcija definisanja seta cijena
 *
 * Revision 1.64  2003/06/09 06:57:16  sasa
 * nova verzija
 *
 * Revision 1.63  2003/05/23 13:07:41  ernad
 * tigra: spajanje sezona, PartnSt generacija otvorenih stavki
 *
 * Revision 1.62  2003/05/20 07:29:50  mirsad
 * Pri nivelaciji i inventuri generisao utrosak sirovina i za TOPS umjesto samo za HOPS
 *
 * Revision 1.61  2003/05/05 10:33:23  mirsad
 * TOPS->FAKT: sada ne formira stavke za prenos ako je kolicina=0; uvedena i stavljena kao default varijanta prenosa bez cijena
 *
 * Revision 1.60  2003/04/24 06:59:58  mirsad
 * prenos TOPS->FAKT
 *
 * Revision 1.59  2003/04/12 23:01:18  ernad
 * O_Edit (O_S_PRIREMA)
 *
 * Revision 1.58  2003/02/13 21:43:56  ernad
 * tigra - PartnSt
 *
 * Revision 1.57  2003/01/29 15:35:03  ernad
 * tigra - PartnSt
 *
 * Revision 1.56  2003/01/29 06:00:36  ernad
 * citanje ini fajlova
 *
 * Revision 1.55  2003/01/21 16:18:22  ernad
 * planika gSQL=D bug tops
 *
 * Revision 1.54  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.53  2003/01/14 15:24:41  ernad
 * debug .. tigra ... razdvajanje sezona ... mora gSQLDirekno biti "N" !!!
 *
 * Revision 1.52  2003/01/14 10:32:18  ernad
 * pripreme za tigru ...
 *
 * Revision 1.51  2003/01/13 14:08:32  ernad
 * tip promjene 0
 *
 * Revision 1.50  2003/01/11 17:23:30  ernad
 * POS Tigra - PartnSt, Makefile sistem
 *
 * Revision 1.49  2003/01/04 14:34:19  ernad
 * PartnSt - ispravke izvjestaja (umjesto I_RnGostiju staviti StanjePartnera)
 *
 * Revision 1.48  2002/12/27 12:41:16  sasa
 * nova verzija
 *
 * Revision 1.47  2002/12/25 15:11:23  mirsad
 * ispravke tops->hh
 *
 * Revision 1.46  2002/11/21 13:22:11  mirsad
 * promjena verzije usljed ispravke bugova
 *
 * Revision 1.45  2002/11/21 10:07:41  mirsad
 * promjena verzije nakon debugiranja
 *
 * Revision 1.44  2002/08/19 10:01:12  ernad
 *
 *
 * sql synchro cijena1, idtarifa za tabelu roba
 *
 * Revision 1.43  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.42  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.41  2002/07/23 08:08:51  ernad
 *
 *
 * debug: Nakon dogadjaja "Nema in/out komande" ostane crni ekran - program zaglavi
 *
 * Revision 1.40  2002/07/22 16:01:58  ernad
 *
 *
 * ciscenja, doxy
 *
 * Revision 1.39  2002/07/15 07:06:56  ernad
 *
 *
 * debug izvjestaj planika/specif "stanje artikala po k1" - variable not found "NIZLAZA"
 *
 * Revision 1.38  2002/07/13 20:50:04  ernad
 *
 *
 * DEBUG prenos nivelacije (kada se unutar nje nalaze stavke sa nepostojecim siframa artikala)
 *
 * Revision 1.37  2002/07/09 13:05:41  ernad
 *
 *
 * debug planika - sitnice
 *
 * Revision 1.36  2002/07/09 08:46:02  ernad
 *
 *
 * evidencija prometa po vrstama placanja: debug, nadogradnja (sada pokaze poruku o ukupnom pologu nakon unosa)
 * bug je bio sto nije mogao unijeti promet danas za juce
 *
 * Revision 1.35  2002/07/08 23:03:55  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.34  2002/07/06 11:14:51  ernad
 *
 *
 * debug porez po tarifama za gVrstaRs="S"
 *
 * Revision 1.33  2002/07/06 08:13:34  ernad
 *
 *
 * - uveden parametar PrivPath/POS/Slave koji se stavi D za kasu kod koje ne zelimo ScanDb
 * Takodje je za gVrstaRs="S" ukinuto scaniranje baza
 *
 * - debug ispravke racuna (ukinute funkcije PostaviSpec, SiniSpec, zamjenjene sa SetSpec*, UnSetSpec*)
 *
 * Revision 1.32  2002/07/04 19:03:22  ernad
 *
 *
 * PROMVP nije bila uvrstena u metod oDbPos:obaza(i)
 *
 * Revision 1.31  2002/07/04 18:42:57  ernad
 *
 *
 * novi sclib, uklonjene debug poruke
 *
 * Revision 1.30  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.29  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.28  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 * Revision 1.27  2002/07/01 10:46:40  ernad
 *
 *
 * oApp:lTerminate - kada je true, napusta se run metod oApp objekta
 *
 * Revision 1.26  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.25  2002/06/30 11:08:52  ernad
 *
 *
 * razrada: kalk/specif/planika/rpt_ppp.prg; pos/prikaz privatnog direktorija na vrhu; doxy
 *
 * Revision 1.24  2002/06/28 23:25:14  ernad
 *
 *
 * TOPS/HOPS naslovni ekran na osnovu FmkIni/KumPath [POS]/Modul=HOPS ili TOPS
 *
 * Revision 1.23  2002/06/26 10:45:35  ernad
 *
 *
 * ciscenja POS, planika - uvodjenje u funkciju IsPlanika funkcije (dodana inicijalizacija
 * varijabli iz FmkSvi u main/2g/app.prg/metod setGvars
 *
 * Revision 1.22  2002/06/26 08:14:40  ernad
 *
 *
 * debug DELETE FROM PROMVP ... <<WHERE>> falilo
 *
 * Revision 1.21  2002/06/25 23:46:15  ernad
 *
 *
 * pos, prenos pocetnog stanja
 *
 * Revision 1.20  2002/06/25 12:04:07  ernad
 *
 *
 * ubaceno kreiranje SECUR-a (posto je prebacen u kumpath)
 *
 * Revision 1.19  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.18  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.17  2002/06/23 11:57:23  ernad
 * ciscenja sql - planika
 *
 * Revision 1.16  2002/06/22 19:07:55  ernad
 *
 *
 * mostru debug ... ciscenja planika
 *
 * Revision 1.15  2002/06/21 14:18:11  ernad
 *
 *
 * pos - planika, import sql
 *
 * Revision 1.14  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.13  2002/06/19 05:53:14  ernad
 *
 *
 * ciscenja, debug
 *
 * Revision 1.12  2002/06/17 13:23:46  sasa
 * no message
 *
 * Revision 1.11  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 
#ifndef SC_DEFINED
	#include "\cl\sigma\sclib\sc.ch"
#endif


#define D_PO_VERZIJA '1.w.1.2.02'
#define D_PO_PERIOD  '09.97-10.06.04'

#define SC_HEADER

#ifdef HOPS
  #define G_MODUL 'HOPS' 
#else
  #define G_MODUL 'TOPS' 
#endif

#ifndef FMK_DEFINED
	#include "\cl\sigma\fmk\fmk.ch"
#endif

// definicija korisnickih nivoa
#define L_SYSTEM           "0"
#define L_ADMIN            "0"
#define L_UPRAVN           "1"
#define L_UPRAVN_2         "2"
#define L_PRODAVAC         "3"

// ulaz / izlaz roba /sirovina
#define R_U       "1"           // roba - ulaz
#define R_I       "2"           //      - izlaz
#define S_U       "3"           // sirovina - ulaz
#define S_I       "4"           //          - izlaz
#define SP_I      "I"           // inventura - stanje
#define SP_N      "N"           // nivelacija

// vrste dokumenata
#define VD_RN        "42"       // racuni
#define VD_ZAD       "16"       // zaduzenje
#define VD_OTP       "95"       // otpis
#define VD_REK       "98"       // reklamacija
#define VD_INV       "IN"       // inventura
#define VD_NIV       "NI"       // nivelacija
#define VD_RZS       "96"       // razduzenje sirovina-otprema pr. magacina
#define VD_PCS       "00"       // pocetno stanje
#define VD_PRR       "01"       // prenos realizacije iz prethodnih sezona

#define DOK_ULAZA "00#16"
#define DOK_IZLAZA "42#01#96#98"

// vrste zaduzenja
#define ZAD_NORMAL   "0"
#define ZAD_OTPIS    "1"

// flagovi da li je slog sa kase prebacen na server
#define OBR_NIJE     "1"
#define OBR_JEST     "0"

// flagovi da li je racun placen
#define PLAC_NIJE    "1"
#define PLAC_JEST    "0"

// ako ima potrebe, brojeve zaokruzujemo na
#define N_ROUNDTO    2
#define I_ID         1
#define I_ID2        2


#IFDEF C52
#include "\cl\sigma\fmk\pos\cdx\pos.ch"
#ENDIF

