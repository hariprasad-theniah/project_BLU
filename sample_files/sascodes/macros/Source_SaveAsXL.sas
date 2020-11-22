%Macro SaveAsXL(File=,DS=,Zip=YES,Filter=NIL,Keep=NIL,Split=NO,Limit=65000,Sort=YES,ByTab=NIL,ByDS=NIL)/Store Secure;

%Put NOTE: SaveAsXL Macro Supports only 65536 Records Use SPLIT and LIMIT option to Split the files;

%Let Ds=%Sysfunc(Compbl(&Ds.)) ;

%If %Sysfunc(CountC(&DS.,' ')) gt 0 and %BQuote(%Upcase(&ByTab.)) ne %BQuote(NIL) %Then %Do ;
    %Put ERROR: Wrong Combination of Variables - Multiple Datasets V/S By Group Tabulation ;
	%Goto EXIT ;
%End ;
%Else %If %Sysfunc(CountC(&DS.,' ')) eq 0 and %BQuote(%Upcase(&ByDS.)) ne %BQuote(NIL) %Then %Let ByDS=NIL ;

%If %BQuote(%Upcase(&ByDS.)) EQ %BQuote(NIL) %Then %DO ;
    %If Not %Sysfunc(exist(&Ds)) %Then %Do ;
        %Put ERROR: The &Ds is not existing !!! ;
	    %Goto EXIT ;
    %End ;

    %Let SaveAsXL=&DS ;

    %If %Bquote(&Filter) ne %Bquote(NIL) %Then %Let Where=%Str(Where %Sysfunc(Dequote(&Filter));) ;
    %Else %Let Where=%str() ;

    %Let cKeep=&Keep ;

    %If %Bquote(%Upcase(&cKeep)) eq %Bquote(NIL) %Then %Do ;
        %Let Keep=;
    %End ;
    %Else %if %Bquote(%Upcase(&Sort)) eq %Bquote(YES) %Then %Do ;
        %Let Keep=%Bquote((Keep=&cKeep)) ;
        proc Sort data=&DS.&Keep. Out=SaveAsXL nodupkey;
        &Where. 
        by _All_ ;
        run;
        %Let SaveAsXL=SaveAsXL ;
    %End ;
    %Else %Do ;
        %Let Keep=%Bquote((Keep=&cKeep)) ;
    %End ;

    %Let Dsn=%Sysfunc(open(&SaveAsXL));
    %Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;
    %Let Dsn=%Sysfunc(Close(&Dsn)) ;

    %If   &Nobs le &Limit %Then %Let Split=NO ;
    %Else %Let Split=YES ;

 %If %Upcase(&Split) eq NO %Then %Do ;

    filename Outfile &File lrecl=32767;

%*--------------------------------------------------------------------------------------------------------*
 | ODS Excel - Start
 *-------------------------------------------------------------------------------------------------------*;
    Ods Listing Close ;
    Ods tagsets.excelxp file=Outfile style=mystyle
        options( 
    %If %Bquote(%Upcase(&ByTab.)) eq %Bquote(NIL) %Then %Do ; sheet_interval='none' %End ;
    %Else %Do ; sheet_interval='bygroup'  %End ;
                suppress_bylines='yes'
               );

    %Put Where=&Where ;
    %Put Keep=&Keep ;

    proc print data =&SaveAsXL.&Keep. noobs label;
    &Where. 
    %If %Bquote(%Upcase(&ByTab.)) ne %Bquote(NIL) %Then %Do ;
        By &ByTab. ;
    %End ;
    %If %Bquote(%Upcase(&cKeep)) ne %Bquote(NIL) %Then %Do ; Var &cKeep ; %End ;
    run;

    Ods tagsets.excelxp close;
%*--------------------------------------------------------------------------------------------------------*
 | ODS Excel - END
 *-------------------------------------------------------------------------------------------------------*;
   %If %Upcase(&Zip)=YES %Then %Do ;
       %Let File=%Sysfunc(Dequote(&File)) ;
       x "gzip -9 &File " ;
   %End ;

%End ;
%Else %Do ;
   %Let File=%Sysfunc(dequote(&File)) ;
   %Let SFile=%Substr(%Cmpres(&File),1,%Eval(%Sysfunc(length(%Cmpres(&File)))-4)) ;
   %Let fparts=1 ;
   %let fobs=1 ;
   %let obs=&Limit ;

 %Do %While(&fobs le &nobs) ;

   %Let file=%Cmpres(&Sfile)_Prt&fparts..xls ;
   %Put The Data is writing into &File File ;
   filename Outfile %Sysfunc(Quote(&File)) lrecl=32767;

   %If %Bquote(%Upcase(&cKeep)) eq %Bquote(NIL) %Then %Do ;
       %Let Keep=%Str((Obs=&obs firstobs=&fobs));
   %End ;
   %Else %Do ;
       %Let Keep=%Bquote((Keep=&cKeep Obs=&obs firstobs=&fobs)) ;
   %End ;

   ods listing close ;
%*--------------------------------------------------------------------------------------------------------*
 | ODS Excel - Start
 *-------------------------------------------------------------------------------------------------------*;
   Ods Listing Close ;
   Ods tagsets.excelxp file=Outfile style=mystyle
         options( 
        %If %Bquote(%Upcase(&ByTab.)) eq %Bquote(NIL) %Then %Do ; sheet_interval='none' %END ;
        %Else %Do; sheet_interval='bygroup' %END ;
                   suppress_bylines='yes'
                   );

   %Put Where=&Where ;
   %Put Keep=&Keep ;
   proc print data =&SaveAsXL.&Keep. noobs label;
   &Where. 
   %If %Bquote(%Upcase(&ByTab.)) ne %Bquote(NIL) %Then %Do ;
       By &ByTab. ;
   %End ;
   %If %Bquote(%Upcase(&cKeep)) ne %Bquote(NIL) %Then %Do ; Var &cKeep ; %End ;
   run;

   Ods tagsets.excelxp close;
%*--------------------------------------------------------------------------------------------------------*
 | ODS Excel - END
 *-------------------------------------------------------------------------------------------------------*;

    %Put The Data is written into &File File [[Part &fparts]];

    %If %Upcase(&Zip)=YES %Then %Do ;
    %Let File=%Sysfunc(Dequote(&File)) ;
    x "gzip -9 &File " ;
    %End ;

    %Let fparts=%Eval(&fparts + 1) ;
    %Let fobs=%Eval(&obs+1) ;
    %Let obs=%Sysfunc(ifn(%eval(&obs + &Limit) gt &nobs,&nobs,%eval(&obs + &Limit))) ;
 
 %End ;
    %Put The &Ds is Split into &fparts Parts ;
    %If %Bquote(&cKeep) Ne NIL %Then %Do; %DeleteDs(SaveAsXL) %End ;

    Ods Listing ;
%End ;
%End ;
%Else %Do ;
%Let DSX=&Ds. ;

%*--------------------------------------------------------------------------------------------------------*
 | ODS Excel - Start
 *-------------------------------------------------------------------------------------------------------*;
Ods Listing Close ;
    filename Outfile &File lrecl=32767;
Ods tagsets.excelxp file=Outfile style=mystyle
      options( sheet_interval='none'
               suppress_bylines='yes'
             );

%Do SaveAsXL_i = 1 %To %ARGCNT(&DSX.) ;
    %Let Ds=%Scan(&DSX.,&SaveAsXL_i.,' ') ;
    %If Not %Sysfunc(exist(&Ds)) %Then %Do ;
        %Put ERROR: The &Ds is not existing !!! ;
    %End ;
	%Else %Do ;
	    %Let Dsn=%Sysfunc(open(&Ds.));
        %Let Nobs=%Sysfunc(Attrn(&Dsn,nobs)) ;
        %Let Dsn=%Sysfunc(Close(&Dsn)) ;
		%If &Nobs gt 65000 %Then 
            %Put WARN: &Ds Have more than 65000 records. This Version of Excel Supports only 65000 Records !!! ;
        ods tagsets.excelxp options(sheet_interval='none' sheet_name="&Ds.");
        proc print data =&DS. noobs label;
        run;
	%End ;
%End ;
Ods tagsets.excelxp close;
%*--------------------------------------------------------------------------------------------------------*
 | ODS Excel - END
 *-------------------------------------------------------------------------------------------------------*;
%End ;

%EXIT:

%Mend SaveAsXL ;

/*Data*/
/*    X*/
/*	;*/
/*x=1;*/
/*Run ;*/
/*Data*/
/*    y*/
/*	;*/
/*x=1;*/
/*Run ;*/
/*%SaveAsXL(Ds=X y,File="&OutputPath./Check.csv",ByDs=YES)*/
