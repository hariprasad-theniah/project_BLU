%Macro PgmPATH/Store Secure;
%Global PgmPath PgmName ;
%Let PgmPath=%Sysfunc(GetOption(SYSIN));
%Let PgmName=;
%If %Bquote(&PgmPath.) Ne %Bquote() %Then %Do ;
%Let PgmName=%Scan(&PgmPath.,-1,'/') ;
%Let PgmPath=%Substr(&PgmPath.,1,%Index(&PgmPath.,&PgmName.)-1) ;
%End ;

%Put Current Program Name = &PgmName. ;
%Put Current Program Path = &PgmPath. ;

%Mend PgmPATH;

