%Macro HashLookup(BaseDS=,LookupDS=,Key=NIL,Values=NIL,Filter=NIL)/Store Secure ;

%Let Key=%Sysfunc(Compbl(&Key)) ;
%Let Values=%Sysfunc(Compbl(&Values)) ;

%If &Key eq NIL %Then %Do ;
    %PUT ERROR: No Key Variable Specified !!!;
	%Goto Exit ;
%End ;

%If NOT %Sysfunc(exist(&BaseDS)) %Then %Do ;
    %Put ERROR: The &BaseDS NOT EXISTING !!! ;
	%Goto Exit ;
%End ;

%If NOT %Sysfunc(exist(&LookupDS)) %Then %Do ;
    %Put ERROR: The &LookupDS NOT EXISTING !!! ;
	%Goto Exit ;
%End ;

%Let Dsn=%Sysfunc(open(&BaseDS));
%Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;
%Let Dsn=%Sysfunc(Close(&Dsn)) ;

%If &Nobs eq 0 %Then %Do ;
    %PUT ERROR: &BaseDS is EMPTY !!!;
	%Goto Exit ;
%End ;

%Let Dsn=%Sysfunc(open(&LookupDS));
%Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;
%Let Dsn=%Sysfunc(Close(&Dsn)) ;

%If &Nobs eq 0 %Then %Do ;
    %PUT ERROR: &LookupDS is EMPTY !!!;
	%Goto Exit ;
%End ;

%Let Keys= ;
%Let rValues= ;
%Let Length=Length ;
%Let Sep=;

%Do i = 1 %to %ArgCnt(&Key);
    %Let Keys=%Sysfunc(Strip(&Keys. &Sep. %Cmpres(%Sysfunc(Quote(%Scan(&Key,&i,' ')))))) ;
	%Let Sep=, ;
%End ;

%If %Sysfunc(countc(&LookupDS.,.)) Gt 0 %Then %Do ;
        %Let Lib =%Upcase(%Scan(&LookupDS.,1,.)) ;
        %Let DS  =%Upcase(%Scan(&LookupDS.,2,.)) ;
%End ;
%Else %Do ;
        %Let Lib =WORK ;
        %Let DS  =%Upcase(&LookupDS.) ;
%End ;

%If %Bquote(%Upcase(&Values)) Eq %Bquote(NIL) %Then %Do ;
    %Let Values=;
    Proc SQL NoPrint;
       Select Name 
         into :Values Separated By ' '
         from dictionary.columns
        Where libname       ="%Cmpres(%Upcase(&Lib))"
          and memtype       ='DATA'
          and Memname       ="%Cmpres(%Upcase(&DS))"
          and upcase(Name) Not In
(
%Do i =1 %to %ArgCnt(&Key)-1 ;
"%Cmpres(%Upcase(%Scan(&Key,&i,' ')))",
%End ;
"%Cmpres(%Upcase(%Scan(&Key,&i,' ')))"
)
            ;
    Quit ;

%If %CMPRES(&Values) eq %STR()  %Then %Do ;
    %Put ERROR: No Values to LookUp !!! ;
    %GOTO EXIT ;
%End ;
%Else %Put INFO: HashLookup Macro will Lookup all the variables from &Lib..&DS. Dataset !!! ;

%End ;

%Let Sep = ;
%Do i = 1 %to %ArgCnt(&Values);
    %Put SQL I/P1 : %Cmpres(%Upcase(&Lib)) ;
	%Put SQL I/P2 : %Cmpres(%Upcase(&DS)) ;
	%Put SQL I/P3 : %Cmpres(%Upcase(%Scan(&Values,&i,' '))) ;
    Proc SQL NoPrint;
       Select Length
             ,Case Type
              When 'char' then '$'
              Else '' End 
         into :Lngth
             ,:Type from dictionary.columns
        Where libname     ="%Cmpres(%Upcase(&Lib))"
          and memtype     ='DATA'
          and Memname     ="%Cmpres(%Upcase(&DS))"
          and upcase(Name)="%Cmpres(%Upcase(%Scan(&Values,&i,' ')))"
            ;
    Quit ;
    %Let rValues=%Sysfunc(Strip(&rValues &Sep. %Cmpres(%Sysfunc(Quote(%Scan(&Values,&i,' ')))))) ;
	%Let Length=%Bquote(&Length %Cmpres(%Scan(&Values,&i,' ')) %Sysfunc(ifc(%Cmpres(&Type) eq $,%Sysfunc(Compress(&Type.&Lngth.)),8.))) ;
	%Let Sep=, ;
%End ;

%Put Keys = &Keys ;
%Put rValues = &rValues ;
%Put Length = &Length ;

%If %Bquote(&Filter) ne NIL %Then %Do ;
	Data
	    HashLookup_Filter
		;
		Set
		   &LookupDS
		   ;
    Where %Sysfunc(Dequote(&Filter)) ;
	Run ;
	%Let LookupDS=HashLookup_Filter ;

	%Let Dsn=%Sysfunc(open(&LookupDS));
    %Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;
    %Let Dsn=%Sysfunc(Close(&Dsn)) ;

    %If &Nobs eq 0 %Then %Do ;
        %PUT ERROR: &LookupDS is EMPTY !!!;
	    %Goto Exit ;
    %End ;
%End ;

Data
    &BaseDS
	;
	Set
	   &BaseDS
	   ;
&Length ;
if _n_ eq 1 then do ;
Declare hash h1(Dataset:"&LookupDS", DUPLICATE:'r', hashexp:16) ;
h1.definekey(&Keys) ;
h1.definedata(&rValues) ;
h1.definedone() ;
end ;

if h1.check() eq 0 then do ;
h1.find() ;
end ;
Run ;

%EXIT:

%Mend HashLookup ;
