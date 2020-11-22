%Macro FMTMatch(FmtName=,Ds=,Var=NIL,Value=NIL,Other="N",Filter=NIL)/Store Secure;
options MergeNoBy=nowarn ;

%Put INFO: Macro FMTMatch is Called ;

%If NOT %Sysfunc(exist(&Ds)) %Then %Do ;
    %Put ERROR: Macro FMTMatch - The &Ds dataset is NOT EXISTING !!! ;
	%Goto Exit ;
%End ;

%If &Var eq NIL %Then %Do ;
    %PUT ERROR: Macro FMTMatch - No Variable specified to create format !!!;
	%Goto Exit ;
%End ;

%RecordsCount(&Ds.)

%If &Nobs eq 0 %Then %Do ;
    %PUT MACROMSG: Macro FMTMatch - &Ds is EMPTY DUMMY Format will be created!!!;
%End ;

%If &FmtName eq %str() %Then %Let FmtName=$Dummy ;
%If %Sysfunc(dequote(&Other)) eq &Other %Then %Let Other=%Sysfunc(quote(&Other)) ;

%If %Bquote(%Upcase(%Bquote(&Filter))) ne NIL %Then %Do ;
    %Let Where = %Str(%Sysfunc(dequote(&Filter)) and) ;
%End ;
%Else %Let Where= ;

Data
   FMTMatch
   ;

Length Fmtname $32
       Start   $256
	   End     $256
	   Type    $1
	   Label   $256
	   HLO     $1
	   EEXCL   $1
	   SEXCL   $1
	   ;

Run ;

Proc SQL ;
Delete From FMTMatch ;
Quit ;

Data
    FMTMatchDs 
	;
	Set 
       &Ds.
	   ;
Where &Where not Missing(&Var) ;
Keep &Var %If %Upcase(&Value) ne NIL and %Sysfunc(Dequote(&Value)) eq &Value %Then %Do ; &Value %End ; ;
Run ;

Proc Sort Data=FMTMatchDs Nodupkey ;
By
  &Var
  ;
Run ;

%RecordsCount(FMTMatchDs)

%Put INFO: &Ds. have &Nobs. distinct key values to create the format !!! ;

Data
    FMTMatch
	;
%If &NOBS Ge 1 %Then %Do ;
	Merge
	   FMTMatch
	   FMTMatchDs End=EOF
	   ;
Fmtname="&FmtName";

%If %Upcase(&Value) ne NIL %Then %Do ;
Label=Strip(&Value) ;
%End ;
%Else %Do ;
Label='Y' ;
%End ;

Start=Strip(&Var);
End='' ;
EEXCL='N' ;
SEXCL='Y' ;

Output ;
If EOF Then do ;
   Start='' ;
   End='' ;
   HLO   = 'O' ;
   Label = &Other  ;
   Output ;
End ;
%End ;
%Else %Do ;
   Fmtname="&FmtName";
   Start='' ;
   End='' ;
   HLO   = 'O' ;
   Label = &Other  ;
   Output ;
%End ;

Keep Fmtname Start Label HLO ;

Run ;

Proc Format Cntlin=FMTMatch ;
Run ;

%Put INFO: &FmtName.. created with &Nobs values from &Ds. Dataset  !!! ;

%DeleteDs(FMTMatch)
%DeleteDs(FMTMatchDs)

%EXIT:
%Put INFO: Macro FMTMatch Ran;

%Mend FMTMatch ;