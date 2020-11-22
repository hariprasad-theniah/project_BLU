%Macro QuerySplit(SQLCode=Nil,Conn=Nil,Output=RemoteSub,InList=,NewDS=)/Store Secure ;

%If &Code NE Nil or &Conn NE Nil %Then %Do ;
options sascmd='sas' ;
%let &Conn =discover.houston.hp.com ;
signon &Conn. ;
%syslput rv1_code=&Code ;
%syslput Filter=&InList;
%syslput DSN=&NewDS;

rsubmit &Conn. wait=no log="/sas/data02/tsgnacdka/Hari/LogFiles/&Output..log" output="/sas/data02/tsgnacdka/Hari/LogFiles/&Output..lst";

%Include &rv1_code /Source2 ;

endrsubmit ;
%End ;

%Mend QuerySplit;
