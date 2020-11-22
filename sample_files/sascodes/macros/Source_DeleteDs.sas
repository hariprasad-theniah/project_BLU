%Macro DeleteDs(NDs)/Store Secure;

%Do DeleteDs_1 = 1 %to %Argcnt(&NDs) ;
%Let Ds=%Scan(&Nds,&DeleteDs_1,' ') ;
%If %Sysfunc(countc(&DS.,.)) Gt 0 %Then %Do ;
	%Let Lib = %Upcase(%Scan(&DS.,1,.)) ;
	%Let DS  = %Upcase(%Scan(&DS.,2,.)) ;
%End ;
%Else %Do ;
	%Let Lib = WORK ;
	%Let DS  = %Upcase(&DS.) ;
%End ;

Proc Datasets Lib=&Lib nolist;
Delete &Ds ;
Quit ; 
%Put INFO: &Ds got deleted !!! ;
%End ;

%Mend DeleteDs ;

