%Macro RenameVar(Ds,Vars,Nvars)/Store Secure;

%Let Vars=%Sysfunc(Compbl(&Vars)) ;
%Let Vars=%Sysfunc(Strip(&Vars)) ;
%Let Vars=%Upcase(&Vars) ;
%Let Nvars=%Sysfunc(Compbl(&Nvars)) ;
%Let Nvars=%Sysfunc(Strip(&Nvars)) ;
%Let Nvars=%Upcase(&Nvars) ;

%If %Argcnt(&Vars) ne %Argcnt(&Nvars) %Then %Do ;
    %Put ERROR: Pass New names for all the Variables to be renamed !!! ;
    %Goto Exit ;
%End ;

%If %Sysfunc(countc(&DS.,.)) Gt 0 %Then %Do ;
        %Let Lib = %Upcase(%Scan(&DS.,1,.)) ;
        %Let DS  = %Upcase(%Scan(&DS.,2,.)) ;
%End ;
%Else %Do ;
        %Let Lib = WORK ;
        %Let DS  = %Upcase(&DS.) ;
%End ;

Proc Datasets Lib=&Lib nolist;

Modify &Ds. ;
%Do RenameVar_1 = 1 %to %Argcnt(&Vars) ;

%If %Scan(&Vars,&RenameVar_1,' ') Ne %Scan(&Nvars,&RenameVar_1,' ') %Then %Do ;
Rename %Scan(&Vars,&RenameVar_1,' ') = %Scan(&Nvars,&RenameVar_1,' ') ;
/* %Put INFO: %Scan(&Vars,&RenameVar_1,' ') is renamed to %Scan(&Nvars,&RenameVar_1,' ') !!! ; */
%End ;
%Else %Do ;
%Put INFO: The Old Variable name and New Variable name are same !!! ;
%End ;

%End ;
Run ;

Quit ;

%Exit:
%Put INFO : Macro RenameVar executed !!! ;

%Mend RenameVar ;
