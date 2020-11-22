%Macro ReadFile(File=,BaseDs=NIL,NewDS=NIL,Type=CSV,Dummy=No,FileDes=NIL,Encoding=NIL,FileLength=32767
               ,Compress=Nil,DLM=',',FileName=No,DLength=$100,RemoveCR=YES)/Store Secure;

%Put INFO: Macro ReadFile is Called !!! ;
%If %Upcase(&NewDS) eq NIL %Then
    %Let NewDS=ReadFile;

%If %Upcase(&Compress) ne NIL %Then
    %Let Compress=%Str((Compress=&Compress));
%Else %Let Compress= ;

%If %Upcase(&Type)=CSV %Then %Do ;
	%Let Dsd=%Str(DSD DLM=&DLM);
%End ;
%Else %Do ;
    %Let Dsd=%Str();
%End ;

%If %Upcase(&RemoveCR) eq YES %Then %Do ;
    %RemoveCr(File=&File.)
%End ;

%If %Upcase(&FileDes) ne NIL %Then %Do ;
    %If %Upcase(&RemoveCR) eq YES %Then %Do ;
        %RemoveCr(File=&FileDes.)
    %End ;
    Filename filedes1 &FileDes. ;
%End ;
%Else %Do ;
	Filename filedes1 &File. ;
%End ;

Filename Rfile1 &File. 
;

Data
   _Null_
   ;

Length fName RFileName $256 Name $32 Label LabelStat InputVars LengthStat $32767 Fmt $32767 X $32767;
InputVars='Input' ;
LengthStat='Informat' ;
LabelStat='Label' ;
Chk=1 ;
TmpC=1;

if _N_ eq 1 then do ;
   Declare hash vname() ;
   vname.definekey('Name') ;
   vname.definedata('Chk') ;
   vname.definedone() ;
end ;

infile filedes1 &Dsd _infile_=Allname filename=RFileName lrecl=&FileLength. truncover
%If %Upcase(&Encoding) ne NIL and %Upcase(&FileDes) eq NIL %Then %Do ; encoding=&Encoding. %End ; 
;

RFileName=Upcase(Scan(RFileName,Max(CountC(RFileName,'/'),1),'/')) ;
RFileName=Scan(RFileName,Max(CountC(RFileName,'.')-1,1),'.') ;

FNum=ANYFIRST(RFileName,1) ;
RFileName=Substr(RFileName,Max(1,FNum),Min(23,LengthN(Strip(RFileName))-(FNum-1))) ;

input ;
varcnt=countc(Allname,&Dlm) ;

Do i=1 to varcnt+1 ;
   fName=dequote(Scan(Allname,i,&Dlm)) ;
   Label=Compress(Scan(fName,1,'|'),'"','C') ;
   Fmt=Coalescec(Compress(Scan(fName,2,'|'),,'CS'),"&DLength.") ;
   If Countc(fmt,'.') eq 0 then
      Fmt =Cats(fmt,'.') ;
   X=ifc(substr(fmt,1,1) eq '$','$','' ) ;
   Name=Scan(fName,1,'|');

   If Missing(Name) Then Do ;
      Name=Cats(RFileName,'_TMP',Put(TmpC,Z3.)) ;
	  TmpC=TmpC+1 ;
   End ;
   Else If AnyDigit(Substr(Name,1,1)) GT 0 then Do ;
      Name=Cats('X',Name) ;
   End ;
   
      Name=Compress(Name,'*=$&%#@!(){}[]-+\.|?/:;,<>`~''"','C') ;
      Name=Translate(Strip(Name),'_',' ','_','/');

	  FNum=ANYFIRST(Name,1) ;
	  Name=Substr(Name,Max(1,FNum),Min(30,LengthN(Strip(Name))-(FNum-1))) ;

	  if vname.check() eq 0 then do ;
	       vname.find() ;
	       Chk=Chk+1 ;
		   vname.replace() ;
		   Name=cats(Name,put(Chk,Z2.)) ;
		   Chk=1;
		   vname.add() ;
	  end ;
	  else do ;
	       Chk = 1 ;
	       vname.add() ;
	  end ;

      Name = Compress(Name,'0D'x) ;
      InputVars=Catx(' ',InputVars,Name,X) ;
      LengthStat=Catx(' ',LengthStat,Name,Fmt) ;
	  LabelStat=Catx(' ',LabelStat,Name,'=',Quote(Strip(Label))) ;
	  
End ;
Call SymputX('Input',InputVars) ;
Call SymputX('Informat',LengthStat) ;
Call SymputX('Label',LabelStat) ;
stop ;
Run ;

%Put Input=&Input ;
%Put Informat=&Informat ;
%Put Label=&Label ;

%If %Upcase(&Dummy) eq NO %then %Do ;
Data
   &NewDS.&Compress.
   ;
&Informat ;
&Label ;
%If %Upcase(&FileName) ne NO  %Then %Do ; Length Filename X $256  ;   %End ;
Infile Rfile1 &DSD firstobs=2 truncover Lrecl=&FileLength. truncover 
%If %Upcase(&Encoding) ne NIL %Then %Do ; encoding=&Encoding. %End ; 
%If %Upcase(&FileName) ne NO  %Then %Do ; Filename=X   %End ; 
%If %Upcase(&RemoveCR) ne YES %Then %Do ; TermStr=CRLF %End ; ;
%If %Upcase(&FileName) ne NO  %Then %Do ; Filename=Strip(X) ;   %End ; 
&Input ;
Run ;
%END ;
%Else %Do ;
Data
   &NewDS.&Compress.
   ;
%If %Upcase(&FileName) ne NO  %Then %Do ; Length Filename $256 ;   %End ;
&Informat ;
&Label ;
Run ;

Proc Sql Noprint ;
Delete from &NewDS ;
Quit ;
%End ;

%If %Upcase(&BaseDs) ne NIL %Then %Do ;
Proc Append Base=&BaseDs Data=&NewDs Force ;
Run ;
%DeleteDs(&NewDs)
%End ;

%Put INFO: Macro ReadFile Ran !!! ;
%Mend ReadFile ;

