x umask 017;
options mautosource sasautos=('/sas/data03/ipgadmin/sas_progs' sasautos) YEARCUTOFF=1950;

%let compress=%sysfunc(getoption(compress));
%put *****************************;
%put  Dataset Compression is &compress;
%put *****************************;

%INCLUDE '/sas/data03/tsgcdkp/programs/libassign.sas';

libname Hari     '/sas/data02/tsgnacdka/Hari/mydata';
libname Hari2004 '/sas/data2004/tsgwwcia/Hari/Data/';
libname Hariship '/sas/data2004/tsgwwcia/Hari/Data/Shipment/';
libname Harisupp '/sas/data2004/tsgwwcia/Hari/Data/Support/';
libname Harintrm '/sas/data2004/tsgwwcia/Hari/Data/Intrim/';
libname macros   '/sas/data2004/tsgwwcia/Hari/codes/macros/' ;
libname formats  '/sas/data2004/tsgwwcia/Hari/codes/formats/' ;
libname edw      '/sas/data4005/saseit/tharip/' ;
libname bcsmig   '/sas/data2004/tsgwwcia/BCSMig' ;
* libname platform '/sas/app/gbiutil/file_audit/datasets/user_audit';

Options mstored sasmstore=macros fmtsearch=(formats PFMTS AFMTS VSDUNS);
options compress=char MERGENOBY=NOWARN;

Data
   _Null_
   ;
If Month(date()) lt 11 Then Do ;
   Curr_FYQ=Sum((Year(Date())*100),Input(Put(Month(Date()),2.),QTRN.)) ;
end ;
Else do ;
   Curr_FYQ=Sum(((Year(Date())+1)*100),Input(Put(Month(Date()),2.),QTRN.)) ;
End ;
Call Symputx('Curr_FYQ',Put(Curr_FYQ,6.)) ;
Run ;

%Let PgmPath=%Sysfunc(GetOption(SYSIN));
%Let PgmName=;
%Macro Dummy ;
%If %Bquote(&PgmPath.) Ne %Bquote() %Then %Do ;
%Let PgmName=%Scan(&PgmPath.,-1,'/') ;
%Let PgmPath=%Substr(&PgmPath.,1,%Index(&PgmPath.,&PgmName.)-1) ;
%End ;
%Mend ;
%Dummy

%Put HP Current Fiscal Year QTR( Curr_FYQ ) = &Curr_FYQ ;
%Put PgmName = &PgmName. ;
%Put PgmPath = &PgmPath. ;


/* AMS */
/*Connect to oracle(Path=SAPDMP.austin.hp.com User=ASIAPACIFIC_tharip pass='cAebb0b-eee8') ;*/
/* EMEA */
/*Connect to oracle(Path=SAPDMEMP.austin.hp.com User=ASIAPACIFIC_tharip pass='e7E28e1-00fd') ;*/
/* APJ */
/*Connect to oracle(Path=SAPDMP_AP.austin.hp.com User=ASIAPACIFIC_THARIP pass='A69478$01') ;*/
%Let MyUName=HARIPRASAD;
%Let MyPass=%Str('B69478!B1');
%Let InputPath=%Str(/sas/data2004/tsgwwcia/Hari/inputs);
%Let OutputPath=%Str(/sas/data2004/tsgwwcia/Hari/output);

/*proc template; 
define style mystyle; 
notes "My Simple Style"; 
class body / backgroundcolor = white color = black fontfamily = "Palatino" fontsize = 8pt; 
class systemtitle / fontfamily = "Verdana, Arial" fontsize = 16pt fontweight = bold ; 
class table / backgroundcolor = cxffffff bordercolor = black borderstyle = solid borderwidth = 1pt 
      cellpadding = 4pt cellspacing = 0pt frame = void rules = groups ; 
class header, footer / backgroundcolor = cxffffff fontfamily = "Verdana, Arial" fontweight = bold fontsize = 8pt; 
class data / fontfamily = "Palatino" fontsize = 8pt; 
end; run;*/
