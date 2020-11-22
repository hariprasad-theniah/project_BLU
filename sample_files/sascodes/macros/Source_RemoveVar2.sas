%Macro RemoveVar(Ds,Vars) / Store Secure ;

%Dsexist(&Ds.)
%Let RMVDS=&DSNM ;
%Let RMVDL=&DSLIB ;

%Put INFO: Variables &Vars. to DROP !!! ;

%Let DropVars=;
%Let Vars=%Upcase(&Vars.) ;
%Do i = 1 %to %ArgCnt(&Vars.) ;
    %Let DropVars=%Sysfunc(Strip(&DropVars %Sysfunc(Quote(%Cmpres(%Scan(&Vars,&i,' ')))))) ;
%End ;

%Let Vars=%Upcase(%Sysfunc(Translate(%Sysfunc(Compbl(&DropVars)),',',' '))) ;
%Let DropVars=;

Options NoNotes ;
Proc SQl Noprint;

Select Strip(Name)
  into :DropVars Separated by ','
  from Dictionary.columns
 Where Libname = "%Cmpres(%Upcase(&RMVDL))"
   And Memname = "%Cmpres(%Upcase(&RMVDS))"
   And Memtype = 'DATA'
   And Upcase(Name) in(&Vars.)
   ;

Quit ;
Options Notes ;

%If &DropVars. eq %Str() %Then %Do ;
    %Put ERROR: No Variables in the list to drop from &Ds. Dataset !!! ;
    %Goto Exit ;
%End ;

%Let Vars=%Sysfunc(Compbl(%Bquote(&DropVars.))) ;

Options NoNotes ;
Proc SQL NOPRINT ;

Alter table &Ds.
Drop &Vars. ;

QUIT ;
Options Notes ;

%Put INFO: Actual Variables dropped &DropVars. !!! ;

%Exit:

%Mend RemoveVar ;
