%Macro RemoveVar(Ds,Vars)/Store Secure ;

%If NOT %Sysfunc(exist(&DS.)) %Then %Do ;
    %Put ERROR: The &Ds. NOT EXISTING !!! ;
        %Goto Exit ;
%End ;

%Let Dsid=%Sysfunc(Open(&Ds.)) ;
%Let Vars=%Sysfunc(Compbl(&Vars.)) ;
%Let NewVars=;

%Do i = 1 %to %Argcnt(&Vars.) ;
    %If %Sysfunc(Varnum(&Dsid.,%Scan(&Vars.,&i,' '))) %Then %Do ;
	    %Let NewVars=&NewVars %Scan(&Vars.,&i,' ');
    %End ;
	%Else %Do ;
	    %Put INFO: The variable %Scan(&Vars.,&i,' ') NOT EXIST in &Ds. Dataset !!! ;
	%End ;
%End ;
%Let Dsid=%Sysfunc(Close(&Dsid.)) ;

%If &NewVars. eq %Str() %Then %Do ;
    %Put ERROR: No Variables in the list to drop from &Ds. Dataset !!! ;
    %Goto Exit ;
%End ;
%Let Vars=%Sysfunc(Compbl(&NewVars.)) ;

%Let Vars=%Sysfunc(Translate(%Sysfunc(Compbl(&Vars)),',',' ')) ;

Proc SQL NoPrint ;

Alter table &Ds.
Drop &Vars. ;

Quit ;

%Exit:

%Mend RemoveVar ;
