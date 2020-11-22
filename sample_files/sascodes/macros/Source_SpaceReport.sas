%Macro SpaceReport(Path=,Email=)/Store secure ;

%If %Bquote(&PATH) eq %Bquote() %Then %Do;
    %Put ERROR: No Path Specified to run space report !!! ;
    %Goto EXIT ;
%End ;

%If %Bquote(&Email) eq %Bquote() %Then %Do ;
    %Put ERROR: No Email Specified to distribute the report !!! ;
    %Goto EXIT ;
%End ;

%Let Path=%Sysfunc(ifc(%Cmpres(%Sysfunc(Quote(%Substr(&Path,%Sysfunc(Lengthn(&Path))-1,1)))) eq "/"
                      ,&Path,%Sysfunc(quote(%Sysfunc(cats(%sysfunc(dequote(&Path)),/)))))) ;

%If %Bquote(%Sysfunc(Dequote(&Path)))  ne %Bquote(&Path)  %Then %Let Path=%Sysfunc(Dequote(&Path)) ;
%If %Bquote(%Sysfunc(Dequote(&Email))) eq %Bquote(&Email) %Then %Let Email=%Sysfunc(Quote(&Email)) ;

Filename SFile1 Pipe "ls -ltr &Path" ;
Filename SFile  Pipe "du -k &Path" ;
Filename SFile2 Pipe "df -k &Path" ;

Data
   _Null_
   ;

Infile SFile2 Obs=1 ;
Input ;
Infile=Compbl(_infile_) ;
Size=Substr(Infile,index(Infile,':')+2,(index(Infile,'total')-1) - (index(Infile,':')+2)) ;
Put Size=;
Call Symputx('TotSize',Put(Size,15.)) ;
Run ; 

Data
   _Null_
      ;

Infile SFile2 Firstobs=4 ;
Input ;
Infile=Compress(_infile_) ;
Size=Substr(Infile,1,index(Infile,'%')-1) ;
Put Size= ;
Call Symputx('Utilization',Put(Size,15.)) ;

Run ;

Data
    UserFolder1 (Where=(Not Missing(Folder)) Keep=User Folder)
	FileSpace   (Where=(Missing(Folder)    ) Keep=User Size Folder)
	;
Infile SFile1 Dsd Dlm='09'x truncover firstobs=2;
Length User $50. Ds_Fl_Nm $256 Size 8. infile $32767;

Input ;
infile=Compbl(_Infile_);

User=Scan(infile,3,' ') ;
Size=Input(Scan(infile,5,' '),15.)/1024 ;
Ds_Fl_Nm=Scan(infile,9,' ') ;

If Substr(infile,1,1) eq 'd' then Folder=Strip(Ds_Fl_Nm) ;

Run ;

Data
    UserFolder2 (Keep = Size Folder)
	RAccess     (Keep = FOLDER)
	RAccessX    (Keep = Folder)
	;
Infile SFile Lrecl=32767 truncover;
Length Path $256 Infile $32767 Size 8. Folder $256 Efolder $256 ;

Input ;
Infile=Compress(_infile_,,'c') ;
Infile=Compbl(Infile) ;
Size=Input(Scan(Infile,1,'/'),?? 15.);

RAccess1 =Index(Infile,'bad status') ;
RAccess2 =Index(Infile,'cannot open') ;

If RAccess1 or RAccess2 then infile=Compress(Infile,'<>') ;

Path=Tranwrd(Substr(Infile,Index(Infile,'/'),Length(Strip(Infile)) - Index(Infile,'/') + 1),"&Path",'') ;
If Not Missing(Path) Then Do ;
   Folder=Substr(Path,1,ifn(Index(Path,'/') gt 0,Index(Path,'/')-1,Length(Strip(Path))+1)) ;
   EFolder=Substr( Infile
                 , Findc(Infile,'/','B') + 1
                 , Length(Strip(Infile)) - Findc(Infile,'/','B')
                 );
   Folder=Strip(Folder) ;
End ;

If      RAccess1 gt 0 Then output RAccess ;
else if RAccess2 gt 0 Then output RAccessX ;
ELse If Strip(Folder) eq Strip(EFolder) Then Output UserFolder2 ;

Run ;

PROC SQL ;

Create table sfinal
as
Select A.*,B.User
  from UserFolder2 A 
      ,UserFolder1 B
 Where A.Folder=B.Folder
	;

Create table RAccess2
as
Select B.User,"Didn't give full access" as MSG Length=50
  from RAccess A 
  Left 
  Join UserFolder1 B
    on A.Folder=B.Folder
	;

Create table RAccess3
as
Select B.User,"Cannot Access this User Folder" as MSG Length=50
  from RAccessX A 
  Left 
  Join UserFolder1 B
    on A.Folder=B.Folder
	;

QUIT ;

Data
    sFinal ( Keep = User Size)
	;
	Set
	   sfinal
	   FileSpace
	   ;
Run ;

Proc Summary data=sFinal nway ;
Class User ;
Var Size ;
Output Out=Final(Drop=_:)  sum= ;
Run ;

Proc Sort Data=RAccess2 Nodupkey;
   By
     User
     ;
run ;

Proc Sort Data=RAccess3 Nodupkey;
   By
     User
     ;
run ;

Data
    Final(Drop=Folder MSG Where=(not missing(User)))
	;
    Merge
	     Final
	     RAccess2
		 RAccess3
	;
    By
      User
    ;
Percentage=(Size/&TotSize.) ;
Message=MSG ;
Label Percentage=' Percentage % ' ; 
Format Percentage Percent12.2 ;
Run ;

Proc sort data=Final ;
   by Descending Percentage ;
Run ;

Title " Space Report on &Path - %Sysfunc(Today(),Date9.) " ;
Title2 " Total Space Allocated : &TotSize. Kb" ;
Title3 " Total Space Utilized  : &utilization. %" ;
%SendEmail(From=&Email
          ,To=&Email
          ,BodyDs=Final
          ,Subject="Space Report"
          ,Type='text/html');
       
%DeleteDs(UserFolder1)
%DeleteDs(UserFolder2)
%DeleteDs(FileSpace)
%DeleteDs(RAccess)
%DeleteDs(RAccessX)
%DeleteDs(sfinal)
%DeleteDs(RAccess2)
%DeleteDs(RAccess3)
%DeleteDs(Final)

%EXIT:

%Mend SpaceReport ;
