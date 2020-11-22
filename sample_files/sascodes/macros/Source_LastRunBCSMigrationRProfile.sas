%Macro LastCustProfile(LastCustProfile_InDs
                      ,Update=NIL
                      ,DeleteLast=NIL
                      ,MonYear=%Sysfunc(Today(),MONYY7.)
					  ,LoadRun=NIL
                      )/Store Secure;

%DsExist(&LastCustProfile_InDs.)

%If &LoadRun. Eq NIL %Then %Do ;
Proc SQL NoPrint;

Select Coalesce(Max(LastRun),0) into :Max From BCSMIG.BCS_Migration_Tracking_Feb2012 ;

Quit ;
%End ;
%Else %If &LoadRun. GT 9 %Then %Do ;
    %Put ERROR: The value for LoadRun Cannot exceed 9 as the table can hold only last 9 runs of BCS migration !!!;
    %Goto Exit;
%End ;
%Else %Do ;
%Let Max=&LoadRun ;
%Let Update=NIL;
%Let DeleteLast=NIL;
%End ;

%If &DeleteLast. Ne NIL %Then %Do ;
    Data
	   BCSMIG.BCS_Migration_Tracking_Feb2012
	   ;
	   Set
	      BCSMIG.BCS_Migration_Tracking_Feb2012
		  ;
	Where LastRun Ne &Max. ;
	Run ;
	%Let Max=%Eval(&Max.-1) ;
%End ;

%If &Update. Eq NIL %Then %Do ;
%Global RP1 RP1X1 RPSD1 RP2 RP1X2 RPSD2 ;
Data
    BCS_Migration_Tracking1
	BCS_Migration_Tracking2
	;
	Set
	   BCSMIG.BCS_Migration_Tracking_Feb2012
	   ;
	By
	  Amid
	  ;
Where LastRun In(&Max.,%Eval(&Max.-1)) ;

Length VarRP         $32 
       VarLabelRP    $512
       NewRP         $32
	   RenVarNmRp    $100
	   VarRP1X       $32
	   VarLabel1X    $512
	   New1X         $32
	   RenVarNm1X    $100
	   VarRPSD       $32
	   NewSD         $32
	   VarLabelSD    $512
	   RenVarNmSD    $100
	   ;

VarRP=Strip(Vname(RiskProfile)) ;
VarLabelRP=Cat(Strip(VarRP),"='Risk Profile - ALPHA/VAX/HP9K/Integrity/Blades (Excluding Superdome and BCS X86) - ",Strip(RYear),Strip(RMonth),"'") ;
NewRP=Cats(VarRP,"_",RYear,RMonth) ;
RenVarNmRp=Cats(VarRP,"=",NewRP) ;

VarRP1X=Strip(Vname(RiskProfile_1X)) ;
VarLabel1X=Cat(Strip(VarRP1X),"='Risk Profile - Integrity / Integrity2(Tukwila) - ",Strip(RYear),Strip(RMonth),"'") ;
New1X=Cats(VarRP1X,"_",Strip(RYear),Strip(RMonth)) ;
RenVarNm1X=Cats(VarRP1X,"=",Strip(New1X)) ;

VarRPSD=Strip(Vname(RiskProfile_SD)) ;
NewSD=Cats(VarRPSD,"_",Strip(RYear),Strip(RMonth)) ;
VarLabelSD=Cat(Strip(VarRPSD),"='Risk Profile - Superdome / Superdome2(Blades) - ",Strip(RYear),Strip(RMonth),"'") ;
RenVarNmSD=Cats(VarRPSD,"=",NewSD) ;

If      LastRun Eq &Max. Then Output BCS_Migration_Tracking1 ;
Else If LastRun Eq %Eval(&Max.-1) Then Output BCS_Migration_Tracking2 ;

Run ;

Proc SQL NoPrint ;
Select Distinct VarLabelRP,RenVarNmRp,VarLabel1X,RenVarNm1X,VarLabelSD,RenVarNmSD,NewRP,New1X,NewSD 
                                                                                  into :VLabel1, :Rename1,
                                                                                       :VLabel2, :Rename2,
                                                                                       :VLabel3, :Rename3, 
												   :Keep4, :Keep5, :Keep6
  from BCS_Migration_Tracking1 ;

Quit ;

%Let RP1=&Keep4.;
%Let RP1X1=&Keep5.;
%Let RPSD1=&Keep6.;

Proc Datasets Lib=Work Nolist Nodetails ;
Modify BCS_Migration_Tracking1 ;
Label &VLabel1. &VLabel2. &VLabel3. ;
Rename &Rename1. &Rename2. &Rename3. ;
Run ;
Quit ;

%Let VLabel1=;
%Let Rename1=; 
%Let VLabel2=;
%Let Rename2=;
%Let VLabel3=;
%Let Rename3=;

Proc SQL Noprint ;

Select Distinct VarLabelRP,RenVarNmRp,VarLabel1X,RenVarNm1X,VarLabelSD,RenVarNmSD,NewRP,New1X,NewSD 
                                                                                  into :VLabel1, :Rename1,
                                                                                       :VLabel2, :Rename2,
                                                                                       :VLabel3, :Rename3, 
												   :Keep1, :Keep2, :Keep3
  from BCS_Migration_Tracking2 ;

Quit ;

%Let RP2=&Keep1.;
%Let RP1X2=&Keep2.;
%Let RPSD2=&Keep3.;

Proc Datasets Lib=Work Nolist Nodetails ;
Modify BCS_Migration_Tracking2 ;
Label &VLabel1. &VLabel2. &VLabel3. ;
Rename &Rename1. &Rename2. &Rename3. ;
Run ;
Quit ;

Data
   &LastCustProfile_InDs
   ;
   Merge
      &LastCustProfile_InDs.   (In=A)
      BCS_Migration_Tracking1  (Keep=Amid &Keep4. &Keep5. &Keep6.)
	  BCS_Migration_Tracking2  (Keep=Amid &Keep1. &Keep2. &Keep3.)
	  ;
   By
     Amid
	 ;
If A ;
Run ;
%DeleteDs(BCS_Migration_Tracking1)
%DeleteDs(BCS_Migration_Tracking2)
%End ;
%Else %Do ;
    %If &Max GE 9 %Then %Do ;
	    Proc SQL ;
		Update BCSMIG.BCS_Migration_Tracking_Feb2012
		   Set LastRun=(LastRun-1)
		   ;
		Quit ;
		Data
		   BCSMIG.BCS_Migration_Tracking_Feb2012
		   ;
		   Set
		      BCSMIG.BCS_Migration_Tracking_Feb2012
			  ;
		Where LastRun GT 0 And LastRun LE 9;
		Run ;
		%Let Max=%Eval(&Max.-1);
	%End ;
    %Put Max=&Max ;
    Data
        BCS_Migration_Tracking
	    ;
	   Set
	      &LastCustProfile_InDs. (Keep=Amid RiskProfile RiskProfile_1X RiskProfile_SD)
	      ; 
	   By
	     Amid
	     ;
	LastRun=%Eval(&Max.+1) ;
	RYear=Substr("&MonYear.",4,4);
	RMonth=Substr("&MonYear.",1,3);
	Run ;
Proc Append Base=BCSMIG.BCS_Migration_Tracking_Feb2012 Data=BCS_Migration_Tracking Force ;
Run ;
%DeleteDs(BCS_Migration_Tracking)
%End ;

%EXIT:
%Mend LastCustProfile;

/*Libname BCSMIG '/sas/data2004/tsgwwcia/Hari/Data/BCSMIG' ;*/

/*Data*/
/*    BCSMIG.BCS_Migration_Tracking_Feb2012*/
/*    ;*/
/*Length Amid           $15 */
/*       LastRun         8 */
/*	   RiskProfile     3*/
/*	   RiskProfile_1X  3*/
/*	   RiskProfile_SD  3*/
/*	   RYear          $4*/
/*	   RMonth         $3*/
/*	   ;*/
/*If _N_ Gt 1 Then Output ;*/
/*Run ;*/

/*%LastCustProfile(BCSMIG.WW_BCS_MIG*/
/*,Update=YES*/
/*,DeleteLast=NIL*/
/*,MonYear=FEB2012*/
/*)*/

/*%LastCustProfile(Harintrm.WW_BCS_MIG*/
/*,Update=YES*/
/*,DeleteLast=NIL*/
/*,MonYear=MAR2012*/
/*)*/
