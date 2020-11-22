%Macro SaveCSV(File=,DS=,Zip=YES,Filter=NIL,Keep=NIL,Split=NO,Limit=999999,Sort=YES,Overwrite=NIL)/Store Secure;

%If Not %Sysfunc(exist(&Ds)) %Then %Do ;
    %Put ERROR: SaveCSV macro - The &Ds is not existing !!! ;
	%Goto EXIT ;
%End ;

%Let Type=CSV ;

%Let SaveCSV=&DS ;
%If %Bquote(&Filter) ne %Bquote(NIL) %Then %Let Where=%Str(Where %Sysfunc(Dequote(&Filter));) ;
%Else %Let Where=%str() ;

%Let cKeep=&Keep ;
%If %Bquote(%Upcase(&cKeep)) eq %Bquote(NIL) %Then %Do ;
%Let Keep=;
%End ;
%Else %if %Bquote(%Upcase(&Sort)) eq %Bquote(YES) %Then %Do ;
%Let Keep=%Bquote((Keep=&cKeep)) ;
proc Sort data=&SaveCSV.&Keep. Out=SaveCSV nodupkey;
&Where. 
by _All_ ;
run;
%Let SaveCSV=SaveCSV ;
%End ;
%Else %Do ;
%Let Keep=%Bquote((Keep=&cKeep)) ;
%End ;

%If %Bquote(&Filter) ne %Bquote(NIL) %Then %Do ;
Data 
   SaveCSV
   ;
   Set
      &SaveCSV.
	  ;
&Where.
Run ;
%Let SaveCSV=SaveCSV ;
%End ;

%RecordsCount(&SaveCSV.)

%if &Nobs le &Limit %Then %Do ;
    %Let Split=NO ;
%End ;
%else %if &Nobs gt &Limit %Then %Do ;
    %Put MACROMSG: SaveCSV macro - dataset size exceeds the limit specified &Limit, so SPLIT option will automatically set if not already;
    %Let Split=YES ;
%end ;

%If %Upcase(&Split) eq NO %Then %Do ;

filename Outfile &File lrecl=32767;

%If %Upcase(&Type) eq CSV %Then %do ;
ods listing close ;
ods csv file=Outfile;

/* %Put Where=&Where ; */
/* %Put Keep=&Keep ; */
proc print data =&SaveCSV.&Keep. noobs label;
&Where. 
%If %Bquote(%Upcase(&cKeep)) ne %Bquote(NIL) %Then %Do ; Var &cKeep ; %End ;
run;

ods csv close;
%RecordsCount(&SaveCSV.)
%Put MACROMSG: SaveCSV Macro created &File with &Nobs. records ;
%end ;

%If %Upcase(&Zip)=YES %Then %Do ;
%GZIP(File=&File,UnZIP=NO,OverWrite=&OverWrite.)
%End ;

%End ;
%Else %Do ;
%Put MACROMSG: SaveCSV macro - SPLIT enabled !!! ;
%Let File=%Sysfunc(dequote(&File)) ;
%Let SFile=%Substr(%Cmpres(&File),1,%Eval(%Sysfunc(length(%Cmpres(&File)))-4)) ;
%Let fparts=1 ;
%let fobs=1 ;
%let obs=&Limit ;

%Do %While(&fobs le &nobs) ;

%Let file=%Cmpres(&Sfile)_Prt&fparts..csv ;
%Put MACROMSG: SaveCSV Macro: The Data is writing into &File File ;
filename Outfile %Sysfunc(Quote(&File)) lrecl=32767;

%If %Bquote(%Upcase(&cKeep)) eq %Bquote(NIL) %Then %Do ;
%Let Keep=%Str((Obs=&obs firstobs=&fobs));
%End ;
%Else %Do ;
%Let Keep=%Bquote((Keep=&cKeep Obs=&obs firstobs=&fobs)) ;
%End ;

%If %Upcase(&Type) eq CSV %Then %do ;
ods listing close ;
ods csv file=Outfile;

/* %Put Where=&Where ; */
/* %Put Keep=&Keep ; */
proc print data =&SaveCSV.&Keep. noobs label;
&Where. 
%If %Bquote(%Upcase(&cKeep)) ne %Bquote(NIL) %Then %Do ; Var &cKeep ; %End ;
run;

ods csv close;
%Put MACROMSG: SaveCSV Macro created %Sysfunc(Quote(&File)) [[Part &fparts]];
%end ;

%If %Upcase(&Zip)=YES %Then %Do ;
%GZIP(File="&File",UnZIP=NO,OverWrite=&OverWrite.)
%End ;

%Let fparts=%Eval(&fparts + 1) ;
%Let fobs=%Eval(&obs+1) ;
%Let obs=%Sysfunc(ifn(%eval(&obs + &Limit) gt &nobs,&nobs,%eval(&obs + &Limit))) ;
 
%End ;
%Put MACROMSG: SaveCSV Macro - The &Ds dataset is Split into &fparts Parts ;
%End ;

%If %Bquote(&cKeep) Ne NIL %Then %Do; %DeleteDs(SaveCSV) %End ;

Ods Listing ;

%EXIT:

%Mend SaveCSV ;
