%Macro Convert2Numeric(Ds=,Var=,Fmt=,compress=NIL)/Store Secure;

%Let Var=%Sysfunc(Compbl(&Var)) ;
%Let Fmt=%Sysfunc(Compbl(&Fmt)) ;

%Let varcnt=%Argcnt(&Var) ;
%Let Fmtcnt=%Argcnt(&Fmt) ;

%If &varcnt ne &Fmtcnt %then %do ;
    %Put ERROR: Number of Variable count and Format count not matched !!! ;
	%Let RC=0;
	%Goto EXIT ;
%End ;
%Else %Let RC=0;

%If %Sysfunc(countc(&Ds.,.)) Gt 0 %Then %Do ;
        %Let Lib =%Upcase(%Scan(&Ds.,1,.)) ;
        %Let DSx =%Upcase(%Scan(&Ds.,2,.)) ;
%End ;
%Else %Do ;
        %Let Lib =WORK ;
        %Let DSx =%Upcase(&Ds.) ;
%End ;

%Let Rename=;
%Let Length=Length;
%Let x=0 ;
%Let evar=;
%Let efmt=;
%Do i = 1 %to &varcnt ;

       Proc SQL noprint;
       Select 1 into : x from dictionary.columns 
        Where libname     ="%Cmpres(%Upcase(&Lib))"
          and memtype     ='DATA' 
          and Memname     ="%Cmpres(%Upcase(&DSx))"
          and upcase(Name)="%Cmpres(%Upcase(%Scan(&Var,&i,' ')))"
          and type        ="char"
            ;
       Quit ;

	   %If &x eq 1 %Then %Do ;
	       %Let evar   = &evar %Scan(&Var,&i,' ') ;
		   %Let efmt   = &efmt %Scan(&fmt,&i,' ') ;
           %Let Rename = &Rename %Cmpres(%Scan(&Var,&i,' ')) = %Cmpres(%Scan(&Var,&i,' '))_ ;
	   %End ;
	   %Else %Do;
	       %Put WARN: Variable %Scan(&Var,&i,' ') in the list is already numeric !!! ;
	   %End ;
	   %Let x =0 ;

%end ;

%If %Str(&evar) eq %str() %then %do ;
    %Put ERROR: No Character Variable in the list to convert to numeric !!! ;
	%Goto EXIT ;
%End ;

%Let EvarC = %Argcnt(&evar) ;
%Put Rename =&Rename ;
%Put Evar   = &evar ;
%Put EvarC = &EvarC ;
%Put efmt   = &efmt ;

Proc SQL Noprint;

Select Strip(Name) ||
       ' ' ||
	   Case 
	   %Do i = 1 %to &EvarC ;
            When upcase(Name)="%Cmpres(%Upcase(%Scan(&eVar,&i,' ')))" Then ''
	   %End ;
            When type eq 'char' then '$'
	        else '' end ||
	   Case 
	   %Do i = 1 %to &EvarC ;
             When upcase(Name)="%Cmpres(%Upcase(%Scan(&eVar,&i,' ')))" Then '8'
	   %End ;
	         Else Strip(Put(Length,5.)) End ||
	   '.'
	  ,Strip(Name) || '="' || Strip(label) || '"'
  into :Length SEPARATED by ' '
      ,:Label  SEPARATED by ' '
  from dictionary.columns
 Where libname     ="%Cmpres(%Upcase(&Lib))"
   and memtype     ='DATA' 
   and Memname     ="%Cmpres(%Upcase(&DSx))"
Order by varnum ;

Quit ;

%Put Length = &Length ;
%Put Label  = &Label  ;

Data
   &Ds. %If %Upcase(&compress) ne NIL %then %do ; (compress=&compress) %end ;
   ;
Length &Length ;
Label  &Label  ;
   Set
      &Ds.(Rename=(&rename.))
          ;

%Do i = 1 %to %Argcnt(&evar) ;
        %Cmpres(%Scan(&evar,&i,' ')) = Input(Compress(%Cmpres(%Scan(&evar,&i,' ')_),'$,'),%Scan(&efmt,&i,' ')) ;
		Drop %Cmpres(%Scan(&evar,&i,' ')_) ;
%End ;

Run ;

%EXIT:
%If   &RC eq 1 %Then %Put ERROR: Convert2Numeric Macro Unsuccessfull !!! ;
%Else                %Put SUCCESS: Convert2Numeric Macro is Successfull !!! ;

%Mend Convert2Numeric ;
