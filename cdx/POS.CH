*
***** Prometne datoteke
#xcommand O_DOKS      => SELECT (F_DOKS); USE (KUMPATH+"DOKS"); set order to 1
#xcommand O_POS       => SELECT (F_POS); USE (KUMPATH+"POS"); set order to 1
#xcommand O_RNGPLA    => SELECT (F_RNGPLA); USE (KUMPATH+"RNGPLA"); set order to 1
*#xcommand O_CROBA     => SELECT (F_CROBA); USE (gCENTPATH+"CROBA"); set order to tag "IDROBA"
#xcommand O_PROMVP    => SELECT (F_PROMVP); USE (KUMPATH+"PROMVP"); set order to 1

// exclusive use
#xcommand OX_DOKS     => SELECT (F_DOKS); USEX (KUMPATH+"DOKS"); set order to 1
#xcommand OX_POS      => SELECT (F_POS); USEX (KUMPATH+"POS"); set order to 1
#xcommand OX_RNGPLA   => SELECT (F_RNGPLA); USEX (KUMPATH+"RNGPLA"); set order to 1
#xcommand OX_PROMVP    => SELECT (F_PROMVP); USEX (KUMPATH+"PROMVP"); set order to 1

*
*
***** Pomocne prometne datoteke
#xcommand O__POS      => SELECT (F__POS)  ; USEX (PRIVPATH+"_POS")  ; set order to 1
#xcommand O__PRIPR    => SELECT (F__PRIPR); USEX (PRIVPATH+"_PRIPR"); set order to 1
#xcommand O_PRIPRZ    => SELECT (F_PRIPRZ); USEX (PRIVPATH+"PRIPRZ"); set order to 1
#xcommand O_PRIPRG    => SELECT (F_PRIPRG); USEX (PRIVPATH+"PRIPRG"); set order to 1
#xcommand O__POSP     => select(F__POSP)  ; cmxAutoOpen(.f.);  usex (PRIVPATH+"_POSP") ; cmxAutoOpen(.t.)
#xcommand O__DOKSP     => select(F__DOKSP)  ; cmxAutoOpen(.f.);  usex (PRIVPATH+"_DOKSP") ; cmxAutoOpen(.t.)
*
*
***** Privatne datoteke
#xcommand O_K2C       => SELECT (F_K2C)   ; USE (PRIVPATH+"K2C")   ; set order to 1
#xcommand O_MJTRUR    => SELECT (F_MJTRUR); USE (PRIVPATH+"MJTRUR"); set order to 1
#xcommand O_ROBAIZ    => SELECT (F_ROBAIZ); USE (PRIVPATH+"ROBAIZ"); set order to 1
#xcommand O_RAZDR     => SELECT (F_RAZDR) ; USE (PRIVPATH+"RAZDR")
// exclusive use
#xcommand OX_K2C      => SELECT (F_K2C); USEX (PRIVPATH+"K2C"); set order to 1
#xcommand OX_MJTRUR   => SELECT (F_MJTRUR); USEX (PRIVPATH+"MJTRUR"); set order to 1
#xcommand OX_ROBAIZ   => SELECT (F_ROBAIZ); USEX (PRIVPATH+"ROBAIZ"); set order to 1
#xcommand OX_RAZDR    => SELECT (F_RAZDR); USEX (PRIVPATH+"RAZDR")

*
*
***** SIFARNICI
#xcommand O_ROBA   => SELECT (F_ROBA); USE (gSIFPATH+"ROBA"); set order to tag "ID"
#xcommand O_SIROV  => SELECT (F_SIROV); USE (gSIFPATH+"SIROV"); set order to tag "ID"
#xcommand O_SAST   => SELECT (F_SAST); USE (gSIFPATH+"SAST"); set order to tag "ID"
#xcommand O_STRAD  => SELECT (F_STRAD); USE (gSIFPATH+"STRAD"); set order to tag "ID"
#xcommand O_OSOB   => SELECT (F_OSOB); USE (gSIFPATH+"OSOB"); set order to tag "ID"
#xcommand O_TARIFA => SELECT (F_TARIFA); USE (gSIFPATH+"TARIFA" ); set order to tag "ID"
#xcommand O_VALUTE => SELECT (F_VALUTE); USE (gSIFPATH+"VALUTE"); set order to tag "ID"
#xcommand O_VRSTEP => SELECT (F_VRSTEP); USE (gSIFPATH+"VRSTEP"); set order to tag "ID"
#xcommand O_KASE   => SELECT (F_KASE); USE (gSIFPATH+"KASE"); set order to tag "ID"
#xcommand O_ODJ    => SELECT (F_ODJ); USE (gSIFPATH+"ODJ"); set order to tag "ID"
#xcommand O_DIO    => SELECT (F_DIO); USE (gSIFPATH+"DIO"); set order to tag "ID"
#xcommand O_UREDJ  => SELECT (F_UREDJ); USE (gSIFPATH+"UREDJ"); set order to tag "ID"
#xcommand O_RNGOST => SELECT (F_RNGOST); USE (gSIFPATH+"RNGOST"); set order to tag "ID"
#xcommand O_MARS   => SELECT (F_MARS); USE (gSIFPATH+"MARS"); set order to tag "ID"

#xcommand OX_ROBA   => SELECT (F_ROBA); USEX (gSIFPATH+"ROBA"); set order to tag "ID"
#xcommand OX_SIROV  => SELECT (F_SIROV); USEX (gSIFPATH+"SIROV"); set order to tag "ID"
#xcommand OX_SAST   => SELECT (F_SAST); USEX (gSIFPATH+"SAST"); set order to tag "ID"
#xcommand OX_STRAD  => SELECT (F_STRAD); USEX (gSIFPATH+"STRAD")
#xcommand OX_OSOB   => SELECT (F_OSOB); USEX (gSIFPATH+"OSOB")
#xcommand OX_TARIFA => SELECT (F_TARIFA); USEX (gSIFPATH+"TARIFA" )
#xcommand OX_VALUTE => SELECT (F_VALUTE); USEx (gSIFPATH+"VALUTE")
#xcommand OX_VRSTEP => SELECT (F_VRSTEP); USEx (gSIFPATH+"VRSTEP")
#xcommand OX_KASE   => SELECT (F_KASE); USEX (gSIFPATH+"KASE")
#xcommand OX_ODJ    => SELECT (F_ODJ); USEX (gSIFPATH+"ODJ"); set order to tag "ID"
#xcommand OX_DIO    => SELECT (F_DIO); USEX (gSIFPATH+"DIO"); set order to tag "ID"
#xcommand OX_UREDJ  => SELECT (F_UREDJ); USEX (gSIFPATH+"UREDJ"); set order to tag "ID"
#xcommand OX_RNGOST => SELECT (F_RNGOST); USEX (gSIFPATH+"RNGOST"); set order to tag "ID"
#xcommand OX_MARS   => SELECT (F_MARS); USEX (gSIFPATH+"MARS"); set order to tag "ID"
*
*
**** Prometne datoteke na SERVERU
#xcommand O_DOKS_S    => SELECT (F_DOKS_S);
			    ;IF FILE (gServKumPath + "DOKS.DBF")     ;
			    ;	USE (gServKumPath + "DOKS") ALIAS DOKS_S ;
                            ;   set order to 1                    ;
                            ;   lProso := .T.                     ;
                            ;ELSE                                 ;
                            ;   lProso := .F.                     ;
                            ;ENDIF
#xcommand O_POS_S     => SELECT (F_POS_S);
                            ;IF FILE (gServKumPath + "POS.DBF") ;
                            ;   USE (gServKumPath + "POS") ALIAS POS_S;
                            ;   set order to 1                    ;
                            ;   lProso := .T.                     ;
                            ;ELSE                                 ;
                            ;   lProso := .F.                     ;
                            ;ENDIF

*
*
**** Prometne datoteke u PRETHODNOJ SEZONI
#xcommand O_DOKS_SEZ  => SELECT (F_DOKS_SEZ);
                            ;IF FILE (cSezRad + "DOKS.DBF")     ;
                            ;   USE (cSezRad + "DOKS") ALIAS DOKS_SEZ ;
                            ;   set order to 1                ;
                            ;   lProso := .T.                 ;
                            ;ELSE                             ;
                            ;   lProso := .F.                 ;
                            ;ENDIF
#xcommand O_POS_SEZ   => SELECT (F_POS_SEZ);
                            ;IF FILE (cSezRad + "POS.DBF") ;
                            ;   USE (cSezRad + "POS") ALIAS POS_SEZ;
                            ;   set order to 1               ;
                            ;   lProso := .T.                ;
                            ;ELSE                            ;
                            ;   lProso := .F.                ;
                            ;ENDIF

*
*
**** Prometne datoteke na KASI
#xcommand O_DOKS_K    => SELECT (F_DOKS_K);
                            ;USE (gKasaPath + "DOKS") ALIAS DOKS_K ;
                            ;   set order to 1
#xcommand O_POS_K     => SELECT (F_POS_K);
                            ;USE (gKasaPath + "POS") ALIAS POS_K;
                            ;   set order to 1


