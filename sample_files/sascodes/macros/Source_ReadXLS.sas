%Macro ReadXLS(File=,Datarow=1,Getnames=No,NewDS=,DBMS=XLS,Encoding=NIL)/Store Secure ;

Filename
ReadXLS
&File
%If %Upcase(&Encoding) ne NIL %Then %Do ; encoding=&Encoding. %End ;
;

Proc Import Datafile=ReadXLS Out=&NewDS. DBMS=&DBMS. Replace ;
Datarow=&Datarow. ;
GetNames=&Getnames. ;
Run ;

%If %Sysfunc(countc(&NewDS.,.)) Gt 0 %Then %Do ;
	%Let Where1 = Where Memname=Strip("%Upcase(%Scan(&NewDS.,2,.))") and  Libname=Strip("%Upcase(%Scan(&NewDS.,1,.))");
	%Let Lib = %Upcase(%Scan(&NewDS.,1,.)) ;
	%Let DS  = %Upcase(%Scan(&NewDS.,2,.)) ;
%End ;
%Else %Do ;
	%Let Where1 = Where Memname=Strip("%Upcase(&NewDS.)") and Libname='WORK';
	%Let Lib = WORK ;
	%Let DS  = %Upcase(&NewDS.) ;
%End ;

Proc SQL NoPrint;

	Select Name into :ColNames separated by ' ' from dictionary.columns &Where1. ;

Quit ;

Data
   _Null_
   ;
   Set 
      &NewDS.(Obs=1)
	  ;

Array Names(*) _Character_ ;

Do Iter = 1 to Dim(Names);
Names[Iter]=Substr(Strip(Names[Iter]),1,Min(Length(Strip(Names[Iter])),32)) ;
Names[Iter]=Compress(Names[Iter],'|$*&%#@!()-+\') ;
Names[Iter]=Translate(Strip(Names[Iter]),'_',' ','_','/','_',',','_','.');
Put Names[Iter]= Iter=;
Call Symputx('Name'||Put(Iter,8. -L),Dequote(Names[Iter]));
end ;

Run ;

Proc Sql ;
Delete from &NewDS. where Monotonic() eq 1 ;
Quit ;

Proc Datasets Lib=&Lib. NoList;
	Modify  &DS.;
		%Do j =  1 %to %eval(%Sysfunc(Countc(&ColNames,' '))+1) ;
			Rename %Scan(&ColNames,&j,' ') = &&Name&j. ;
		%End ;
	Run ;
quit;

%Mend ReadXLS;
