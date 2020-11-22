%Macro ChgFname(Path=,Ext=csv)/Store Secure;

%Let Path=%Sysfunc(ifc(%Sysfunc(Quote(%Substr(&Path,%Length(&Path)-1,1))) Eq "/"
                      ,&Path,%Sysfunc(quote(%Sysfunc(Cats(%Sysfunc(Dequote(&Path)),/)))))) ;

%Put INFO: The &Path is scanned for &Ext. extension files !!! ;
%Let Cmd=%Str("ls %Sysfunc(dequote(&Path))*.&Ext.") ;
Filename ChgFname Pipe &Cmd ;

Data
   _Null_
   ;

Length Command $1200 Filex $500 ;
Infile ChgFname End=EOF Lrecl=32767 truncover;

i =1 ;
Do While(Not EOF);
Input @1 Filex $500.;

Filex_=Translate(Filex,' ',',',' ','(',' ',')',' ','\',' ','-',' ','*',' ','&',' ','%',' ','#',' ','@',' ','!',' ','+');
If Countc(Strip(Filex_),' ') then do ;
   Nfname=Compress(Strip(Filex_),'*&%#@!+') ;
   Nfname=Compbl(Nfname);
   Nfname=Translate(Strip(Nfname),'_',' ');
   Command=Catx(' ','mv',quote(Strip(Filex)),Nfname) ;
   Filex=Strip(Nfname) ;
End ;
Else Command='' ;

If Not Missing(Command) then
Call System(Command);

Call SymputX('Nfile',Put(I,2.)) ;
I = I + 1 ;
End ;

Run ;
%Mend ChgFname ;
