%Macro RemoteSub(Code=NIL,Conn=NIL,Output=NIL,OutPath=NIL)/Store Secure ;

%If NOT %Symexist(PgmName) And NOT %Symexist(PgmPath) %Then %Do ;
%PgmPATH
%End ;

%If (NOT %Symexist(PgmName)) OR (%Bquote(&PgmName.) Eq %Bquote()) %then %Let PgmName=&Conn;
%Let TempPgmName=%Scan(&PgmName.,1,'.') ;

%If %BQuote(%Upcase(&OutPath.)) Ne %BQuote(NIL) %Then %Do ;
    %Let PgmPath=%Sysfunc(Dequote(&OutPath.));
%End ;
%Else %If (NOT %Symexist(PgmPath)) OR (%Bquote(&PgmPath.) Eq %Bquote()) %Then %Let PgmPath=%Str(~);

%Let Path=%Sysfunc(Quote(%Sysfunc(DeQuote(&PgmPath.)))) ;
%Let Path=%Sysfunc(ifc(%Sysfunc(Quote(%Substr(&Path,%Length(&Path)-1,1))) Eq "/"
                      ,&Path,%Sysfunc(quote(%Sysfunc(Cats(%Sysfunc(Dequote(&Path)),/)))))) ;

%Let PgmPath=%sysfunc(Dequote(&Path));

%If &Code NE NIL or &Conn NE NIL %Then %Do ;
options sascmd='sas' ;
%let &Conn =discover.houston.hp.com ;
signon &Conn. ;
%syslput rv1_code=&Code/Remote=&Conn.;
%Put LogPath : &PgmPath.&TempPgmName._&Conn..log ;
rsubmit &Conn. wait=no log="&PgmPath.&TempPgmName._&Conn..log" 
%If &Output. Ne NIL %Then %Do ;
%Put OutPath : &PgmPath.&TempPgmName._&Conn..lst ;
output="&PgmPath.&TempPgmName._&Conn..lst"
%End ;
;

%if &Code. ne NIL %then %do ;
%Include &rv1_code /Source2 ;

endrsubmit ;
%end ;
%End ;

%Mend RemoteSub;

/*%RemoteSub(Conn=Conn1)*/
/*Proc sort data=sashelp.prdsale out=prdsale;*/
/*By Country ;*/
/*run ;*/
/*endrsubmit ;*/
/**/
/*%RemoteSub(Conn=Conn2)*/
/*Proc sort data=sashelp.prdsal2 out=prdsal2;*/
/*By Country ;*/
/*run ;*/
/*endrsubmit ;*/
/**/
/*%RemoteSub(Conn=Conn3)*/
/*Proc sort data=sashelp.prdsal3 out=prdsal3;*/
/*By Country ;*/
/*run ;*/
/*endrsubmit ;*/
/**/
/*%CloseConn(Conn1 Conn2 Conn3)*/
