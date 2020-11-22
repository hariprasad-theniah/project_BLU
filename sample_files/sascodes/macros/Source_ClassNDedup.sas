%Macro ClassNDedup(Ds=,NewDs=NIL,Var=,By=NIL)/Store Secure ;

%Let By=%Sysfunc(Strip(&By)) ;
%Let i=1 ;
%If %Upcase(&NewDs) eq NIL %then %Let NewDs=&Ds ;
Data
    &NewDs
	;
	Set
	   &Ds.
	   ;
	%If %Upcase(&By) ne NIL %Then %Do ; By &By ; %End;

%Do %While(%Scan(&var,&i,' ') ne %str()) ;
Retain %Sysfunc(cats(L,%Scan(&var,&i,' ')),$32.) ;

%If %Upcase(&By) ne NIL %Then %Do ;
	%Let CntByVar=%Sysfunc(Countc(&By,' ')) ;
	If First.%Cmpres(%Scan(&By,%Eval(&CntByVar+1),' ')) then %Sysfunc(cats(L,%Scan(&var,&i,' ')),$32.)=. ;
%End ;

If %Sysfunc(cats(L,%Scan(&var,&i,' ')),$32.) ne %Scan(&var,&i,' ') then %Sysfunc(cats(L,%Scan(&var,&i,' ')),$32.) = %Scan(&var,&i,' ') ;
Else If %Sysfunc(cats(L,%Scan(&var,&i,' ')),$32.) eq %Scan(&var,&i,' ') then %Scan(&var,&i,' ') =. ;

Drop %Sysfunc(cats(L,%Scan(&var,&i,' ')),$32.) ;
%Let i=%eval(&i+1) ;
%End ;

Run ;
%Mend ClassNDedup ;