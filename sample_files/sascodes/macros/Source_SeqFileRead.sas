%Macro SeqFileRead(Path=,BaseDs=,NewDs=Nil,Ftype=CSV,FileDesc=NIL,Encoding=NIL,FName=No,Flength=32767
                  ,Cmpress=NIL,Append=YES,Dlen=$100,RmvCR=YES,Dlm=',',Aligned=YES)/Store Secure;

%If %Sysfunc(exist(&NewDs)) %Then %Put WARN: The &NewDs already exist, Old data might be lost !!! ;

%If %Upcase(&NewDs) ne NIL and %Upcase(&FileDesc) ne NIL %Then %Do ;
    %ReadFile(File=&FileDesc,NewDs=&NewDS,Type=&Ftype,FileDes=&FileDesc.,Encoding=&Encoding.,FileName=&FName.,Dummy=YES,RemoveCR=&RmvCR,Compress=&Cmpress,Dlm=&Dlm.)
	%Let BaseDs=&NewDS ;
%End ;
%Else %If %Upcase(&NewDs) ne NIL %Then %do ;
    %If %Upcase(&Append) ne YES %Then %Do ;
        Data &NewDS. ; Run ;
    %End ;
    %Let BaseDs=&NewDS ;
%End ;

%Let Path=%Sysfunc(ifc(%Sysfunc(Quote(%Substr(&Path,%Length(&Path)-1,1))) Eq "/"
                      ,&Path,%Sysfunc(quote(%Sysfunc(Cats(%Sysfunc(Dequote(&Path)),/)))))) ;

%Put INFO: The &Path is scanned for &Ftype extension files !!! ;
%Let Cmd=%Str("ls %Sysfunc(dequote(&Path))%Cmpres(*.&Ftype.)") ;

Filename SeqFile Pipe &Cmd ;

Data
   _Null_
   ;

Length Filex $256 ;
Infile SeqFile End=EOF Lrecl=32767 truncover;

i =1 ;
Do While(Not EOF);
Input @1 Filex $256.;

Put "File" i= Filex= ;

Call symputX(Cats('File',Put(i,8.)),Strip(Filex)) ;
Call SymputX('Nfile',Put(I,8.)) ;
I = I + 1 ;
Put I= ;
End ;
Stop ;

Run ;

%Do i = 1 %To &Nfile ;

%Put Reading ---> &&File&i. [[ &i ]];

    %If %Upcase(&Ftype) ne XLS and %Upcase(&Aligned) eq YES %Then %Do ;
	    %ReadFile(File="&&File&i.",NewDS=SeqFile,Type=CSV,FileDes=&FileDesc.,Encoding=&Encoding.,FileName=&FName.,Filelength=&Flength.
                 ,Dlength=&Dlen,RemoveCR=&RmvCR,Dlm=&Dlm)
	%End ;
	%Else %If %Upcase(&Ftype) ne XLS %Then %do ;
        %ReadFileX(File="&&File&i.",NewDS=SeqFile,Type=CSV,FileDes=&FileDesc.,Encoding=&Encoding.,FileName=&FName.,Filelength=&Flength.
                  ,Dlength=&Dlen,RemoveCR=&RmvCR,Dlm=&Dlm,Aligned=&Aligned.)
	%End ;
	%Else %Do ;
		%ReadXLS(File="&&File&i.",NewDS=SeqFile,Encoding=&Encoding.);
	%End ;

%If %Upcase(&Append) eq YES %Then %Do ;
Proc Append Base=&BaseDs. Data=SeqFile Force ;
Run ;
%End ;
%Else %Do ;
      Data
          &BaseDs. %If %Upcase(&Cmpress.) ne NIL %Then %Do ; ( Compress = &Cmpress. ) %End ;
          ;
          Set
             &BaseDs.
             SeqFile
	        ;
      Run ;
%End ;
%End ;

%DeleteDs(SeqFile)

%Mend SeqFileRead;
