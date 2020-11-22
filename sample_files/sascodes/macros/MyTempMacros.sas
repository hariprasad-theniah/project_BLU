%Macro QTRDiff(QTR1,QTR2,Out=QTRDiff)/Store Secure;

If &QTR1. GT &QTR2. Then Do ;
&QTR1.=&QTR1.+&QTR2. ;
&QTR2.=&QTR1.-&QTR2. ;
&QTR1.=&QTR1.-&QTR2. ;
End ;

&Out.=IfN(Int(&QTR1./10) eq Int(&QTR2./10)
           ,Sum(Mod(&QTR2.,10),-1*Mod(&QTR1.,10),-1)
           ,Sum(Sum(Int(&QTR2./10),-1*Int(&QTR1./10),-1)*4,Mod(&QTR2.,10),3,-1*Mod(&QTR1.,10))
           ) ;

%Mend ;

%Macro Quantile5(QDS,QVar,Prefix=&Qvar.,RoundOff=NIL)/Store Secure ;
%Let QOut=Quantile ;

PROC UNIVARIATE DATA = &QDS. NoPrint OUTTABLE=&QOut.;
Where &Qvar. GT 0 ;
VAR &QVar.;
RUN;

Proc Transpose data=&QOut. Out=&QOut._Tran ;
Var _Numeric_ ;
Run ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
WHere _Label_ ? 'Percentile' And _Name_ NE '_P1_' And _Name_ NE '_P99_' ;
Run ;

Proc Sort Data=&QOut._Tran Nodupkey ;
By
  Descending Col1
  ;
Run ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
Last_Q=Lag(Col1) ;
Last_Q_Name=Lag(_Name_) ;
Curr_Q=Col1 ;
QDiff=Sum(Last_Q,-1*Curr_Q) ;
Percent=(Curr_Q/Last_Q) ;
Format Percent Percent10. ;
Drop Col1 ;
Run ;

Proc Sort Data=&QOut._Tran ;
By
  Percent
  ;
Run ;

%Let Dsn=%Sysfunc(open(&QOut._Tran));
%Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;
%Let Dsn=%Sysfunc(Close(&Dsn)) ;

%If &Nobs LT 4 %Then %Do ;
    %PUT ERROR: Not Enough Values to Process Quantile 5 Macro !!! ;
	%Goto Exit ;
%End ;

Data
   &QOut._Tran
   ;
   Retain j %Sysevalf(&Nobs./4,ceil) Cnt 0;
   i=Min(j,&Nobs.) ;
   Set
      &QOut._Tran Point=i
	  ;
   If Cnt Le 4 Then Do ;
   Cnt=Cnt+1 ;
   Output ;
   End ;
   Else STOP ;
   J=I + 1 ;
   If I GE &Nobs. then STOP ;
Run ;
%If &RoundOff. Eq NIL %Then %Do ;
Proc Sort Data=&QOut._Tran ;
By
  Descending
  Curr_Q
  ;
Run ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
Z=1;
LCurr_Q=Lag(Curr_Q) ;
L2=(Length(Strip(Put(LCurr_Q,15.)))) ;
L1=(Length(Strip(Put(Curr_Q,15.))))  ;
Diff=(L2-L1) ;

Do i = 1 to (L1-1) ;
   Z=Z*10;
End ;

If Diff Eq 0 Or _N_ Eq 1 Then Do ;
   Curr_Q=Round(Curr_Q) ;
End ;
Else If Diff Eq 1 Then Do ;
   Curr_Q=Ceil(Curr_Q/Z)*Z ;
End ;
Else If Diff GT 1 Then Do ;
   Curr_Q=Ceil(Curr_Q/(Z*10))*Z*10 ;
End ;

Run ;
%End ;

Proc Sort Data=&QOut._Tran ;
By
  Curr_Q
  ;
Run ;

Data
   _Null_
   ;
Prefix=Substr("_&Prefix.",1,Min(25,Length(Strip("_&Prefix.")))) ;
Call Symputx('Prefix',Prefix) ;
Run ;

%Global Low&Prefix. HLow&Prefix. LHigh&Prefix. High&Prefix. ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
Select(_N_) ;
When(1) Do ; Call SymputX(Cats('Low'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('Low_Q_Name'),_Name_) ; End ;
When(2) Do ; Call SymputX(Cats('HLow'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('HLow_Q_Name'),_Name_) ; End ;
When(3) Do ; Call SymputX(Cats('LHigh'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('LHigh_Q_Name'),_Name_) ; End ;
When(4) Do ; Call SymputX(Cats('High'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('High_Q_Name'),_Name_) ; End ;
OtherWise ;
End ;
Run ;

%Put Quantile &Low_Q_Name. As Low&Prefix     =&&&Low&Prefix. ;
%Put Quantile &HLow_Q_Name. As HLow&Prefix   =&&&HLow&Prefix. ;
%Put Quantile &LHigh_Q_Name. As LHigh&Prefix =&&&LHigh&Prefix. ;
%Put Quantile &High_Q_Name. As High&Prefix   =&&&High&Prefix. ;

%DeleteDs(&QOut._Tran)
%DeleteDs(&QOut)

%Exit:
%Mend ;

/*%Macro Quantile5(QDS,QVar,Prefix=&Qvar.)/Store Secure ;*/
/*%Let QOut=Quantile ;*/
/**/
/*PROC UNIVARIATE DATA = &QDS. NoPrint OUTTABLE=&QOut.;*/
/*Where &Qvar. GT 0 ;*/
/*VAR &QVar.;*/
/*RUN;*/
/**/
/*Proc Transpose data=&QOut. Out=&QOut._Tran ;*/
/*Var _Numeric_ ;*/
/*Run ;*/
/**/
/*Data*/
/*   &QOut._Tran*/
/*   ;*/
/*   Set*/
/*      &QOut._Tran*/
/*	  ;*/
/*WHere _Label_ ? 'Percentile' And _Name_ NE '_P1_' And _Name_ NE '_P99_' ;*/
/*Run ;*/
/**/
/*Proc Sort Data=&QOut._Tran Nodupkey ;*/
/*By*/
/*  Descending Col1*/
/*  ;*/
/*Run ;*/
/**/
/*Data*/
/*   &QOut._Tran*/
/*   ;*/
/*   Set*/
/*      &QOut._Tran*/
/*	  ;*/
/*Last_Q=Lag(Col1) ;*/
/*Last_Q_Name=Lag(_Name_) ;*/
/*Curr_Q=Col1 ;*/
/*QDiff=Sum(Last_Q,-1*Curr_Q) ;*/
/*Percent=(Curr_Q/Last_Q) ;*/
/*Format Percent Percent10. ;*/
/*Drop Col1 ;*/
/*Run ;*/
/**/
/*Proc Sort Data=&QOut._Tran ;*/
/*By*/
/*  Percent*/
/*  ;*/
/*Run ;*/
/**/
/*%Let Dsn=%Sysfunc(open(&QOut._Tran));*/
/*%Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;*/
/*%Let Dsn=%Sysfunc(Close(&Dsn)) ;*/
/**/
/*%If &Nobs LT 4 %Then %Do ;*/
/*    %PUT ERROR: Not Enough Values to Process Quantile 5 Macro !!! ;*/
/*	%Goto Exit ;*/
/*%End ;*/
/**/
/*Data*/
/*   &QOut._Tran*/
/*   ;*/
/*   Retain j %Sysevalf(&Nobs./4,ceil) Cnt 0;*/
/*   i=Min(j,&Nobs.) ;*/
/*   Set*/
/*      &QOut._Tran Point=i*/
/*	  ;*/
/*   If Cnt Le 4 Then Do ;*/
/*   Cnt=Cnt+1 ;*/
/*   Output ;*/
/*   End ;*/
/*   Else STOP ;*/
/*   J=I + 1 ;*/
/*   If I GE &Nobs. then STOP ;*/
/*Run ;*/
/**/
/*Proc Sort Data=&QOut._Tran ;*/
/*By*/
/*  Curr_Q*/
/*  ;*/
/*Run ;*/
/**/
/*Data*/
/*   _Null_*/
/*   ;*/
/*Prefix=Substr("_&Prefix.",1,Min(25,Length(Strip("_&Prefix.")))) ;*/
/*Call Symputx('Prefix',Prefix) ;*/
/*Run ;*/
/**/
/*%Global Low&Prefix. HLow&Prefix. LHigh&Prefix. High&Prefix. ;*/
/**/
/*Data*/
/*   &QOut._Tran*/
/*   ;*/
/*   Set*/
/*      &QOut._Tran*/
/*	  ;*/
/*Select(_N_) ;*/
/*When(1) Do ; Call SymputX(Cats('Low'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('Low_Q_Name'),_Name_) ; End ;*/
/*When(2) Do ; Call SymputX(Cats('HLow'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('HLow_Q_Name'),_Name_) ; End ;*/
/*When(3) Do ; Call SymputX(Cats('LHigh'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('LHigh_Q_Name'),_Name_) ; End ;*/
/*When(4) Do ; Call SymputX(Cats('High'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('High_Q_Name'),_Name_) ; End ;*/
/*OtherWise ;*/
/*End ;*/
/*Run ;*/
/**/
/*%Put Quantile &Low_Q_Name. As Low&Prefix     =&&&Low&Prefix. ;*/
/*%Put Quantile &HLow_Q_Name. As HLow&Prefix   =&&&HLow&Prefix. ;*/
/*%Put Quantile &LHigh_Q_Name. As LHigh&Prefix =&&&LHigh&Prefix. ;*/
/*%Put Quantile &High_Q_Name. As High&Prefix   =&&&High&Prefix. ;*/
/**/
/*%DeleteDs(&QOut._Tran)*/
/*%DeleteDs(&QOut)*/
/**/
/*%Exit:*/
/*%Mend ;*/

%Macro Quantile3(QDS,QVar,Prefix=&Qvar.,RoundOff=NIL)/Store Secure ;
%Let QOut=Quantile ;

PROC UNIVARIATE DATA = &QDS. NoPrint OUTTABLE=&QOut.;
Where &Qvar. GT 0 ;
VAR &QVar.;
RUN;

Proc Transpose data=&QOut. Out=&QOut._Tran ;
Var _Numeric_ ;
Run ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
WHere _Label_ ? 'Percentile' And _Name_ NE '_P1_' And _Name_ NE '_P99_';
Run ;

Proc Sort Data=&QOut._Tran Nodupkey ;
By
  Descending Col1
  ;
Run ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
Last_Q=Lag(Col1) ;
Last_Q_Name=Lag(_Name_) ;
Curr_Q=Col1 ;
QDiff=Sum(Last_Q,-1*Curr_Q) ;
Percent=(Curr_Q/Last_Q) ;
Format Percent Percent10. ;
Drop Col1 ;
Run ;

Proc Sort Data=&QOut._Tran ;
By
  Percent
  ;
Run ;

%Let Dsn=%Sysfunc(open(&QOut._Tran));
%Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;
%Let Dsn=%Sysfunc(Close(&Dsn)) ;

%If &Nobs LT 2 %Then %Do ;
    %PUT ERROR: Not Enough Values to Process Quantile 3 Macro !!! ;
	%Goto Exit ;
%End ;

Data
   &QOut._Tran
   ;
   Retain j %Sysevalf(&Nobs./2,floor) Cnt 0;
   i=Min(j,&Nobs.) ;
   Set
      &QOut._Tran Point=i
	  ;
   If Cnt Le 2 Then Do ;
   Cnt=Cnt+1 ;
   Output ;
   End ;
   Else STOP ;
   J=I + 2 ;
   If I GE &Nobs. then STOP ;
Run ;

%If &RoundOff. Eq NIL %Then %Do ;
Proc Sort Data=&QOut._Tran ;
By
  Descending
  Curr_Q
  ;
Run ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
Z=1;
LCurr_Q=Lag(Curr_Q) ;
L2=(Length(Strip(Put(LCurr_Q,15.)))) ;
L1=(Length(Strip(Put(Curr_Q,15.))))  ;
Diff=(L2-L1) ;

Do i = 1 to (L1-1) ;
   Z=Z*10;
End ;

If Diff Eq 0 Or _N_ Eq 1 Then Do ;
   Curr_Q=Round(Curr_Q) ;
End ;
Else If Diff Eq 1 Then Do ;
   Curr_Q=Ceil(Curr_Q/Z)*Z ;
End ;
Else If Diff GT 1 Then Do ;
   Curr_Q=Ceil(Curr_Q/(Z*10))*Z*10 ;
End ;

Run ;
%End ;


Proc Sort Data=&QOut._Tran ;
By
  Curr_Q
  ;
Run ;

Data
   _Null_
   ;
Prefix=Substr("_&Prefix.",1,Min(25,Length(Strip("_&Prefix.")))) ;
Call Symputx('Prefix',Prefix) ;
Run ;

%Global Low&Prefix. High&Prefix. ;

Data
   &QOut._Tran
   ;
   Set
      &QOut._Tran
	  ;
Select(_N_) ;
When(1) Do ; Call SymputX(Cats('Low'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('Low_Q_Name'),_Name_) ; End ;
When(2) Do ; Call SymputX(Cats('High'||"&Prefix."),Curr_Q) ; Call SymputX(Cats('High_Q_Name'),_Name_) ; End ;
OtherWise ;
End ;
Run ;

%Put Quantile &Low_Q_Name. As Low&Prefix   =&&&Low&Prefix. ;
%Put Quantile &High_Q_Name. As High&Prefix  =&&&High&Prefix. ;

%DeleteDs(&QOut._Tran)
%DeleteDs(&QOut)

%Exit:

%Mend ;
