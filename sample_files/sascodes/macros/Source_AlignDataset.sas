%Macro AlignDatasets(
BaseDs=NIL
,BaseFile=NIL
,Ftype=CSV
,Ds=NIL
,Dlm=','
,Append2Base=NO
,Encoding=NIL
,RemoveCR=YES) / Store Secure ;

%Put Info: AlignDatasets Macro is been called !!! ;

%If &Ds. eq NIL %Then %Do ;
    %Put ERROR: No Input dataset to do the Alignment !!! ;
	%ABORT ABEND ;
	%GOTO Exit ;
%End ;
%Else %If &BaseDs. eq NIL and &BaseFile. eq NIL %Then %Do ;
    %Put ERROR: No Base to Align the Input Dataset !!! ;
	%ABORT ABEND ;
	%GOTO Exit ;
%End ;

%Let AlignBaseDs=&BaseDs. ;
%Let AlignDs=&Ds. ;

%If %Bquote(&BaseFile.) ne %Bquote(NIL) %Then %Do ;
%ReadFile(File=&BaseFile.,NewDs=AlignDS_Base,Type=&Ftype,Dummy=YES,Dlm=&Dlm.,Encoding=&Encoding.,RemoveCR=&RemoveCR.)
%Let Append2Base=NO ;
%Let AlignBaseDs=AlignDS_Base ;
%Put Info: The &AlignDs. Dataset will get aligned to %Sysfunc(Dequote(&BaseFile.)) File Layout !!! ;
%End;
%Else %Do ;
%Put Info: The &AlignDs. Dataset will get aligned to &AlignBaseDs. Layout !!! ;
%End ;

%Dsexist(&AlignBaseDs.)
%Let BLib=&DSLIB ;
%Let BDs=&DSNM ;
%Dsexist(&AlignDs.)
%Let ALib=&DSLIB ;
%Let ADs=&DSNM ;

Options NoNotes ;
Proc SQl Noprint;

Create Table BaseMdata_
as
Select name
      ,type
	  ,length
	  ,format
	  ,informat
	  ,varnum
  from Dictionary.columns
 Where Libname = "%Cmpres(%Upcase(&BLib))"
   And Memname = "%Cmpres(%Upcase(&BDs))"
   And Memtype = 'DATA'
   ;

Create Table Aligndata_
as
Select name
      ,type
	  ,length
	  ,format
	  ,informat
	  ,varnum
  from Dictionary.columns
 Where Libname = "%Cmpres(%Upcase(&ALib))"
   And Memname = "%Cmpres(%Upcase(&ADs))"
   And Memtype = 'DATA'
   ;

Select Catx(' '
      ,Coalesce(A.name,B.Name)
	  ,Cats(
	        Case when Coalesce(A.type,B.Type) eq 'char' then '$'
			     else '' end
	  ,Coalesce(A.Length,B.Length)
	   ))
  into :Length separated by ' '
  From BaseMdata_ A
  Full 
  Join Aligndata_ B
    On A.name = B.name
 Order
    By A.Varnum
   ;

Select Strip(Cats(A.name
                 ,'='
                 ,Case When Length(Strip(A.name)) lt 32 Then A.name
                       Else Substr(A.name,1,31) End
                 ,'_')
            )
      ,Strip(Cats(Case When Length(Strip(A.name)) lt 32 Then A.name
                       Else Substr(A.name,1,31) End
                 ,'_')
            )
      ,Case When A.type eq 'num' and B.type eq 'char' then Strip(A.name)
	        Else '' End
	  ,Case When A.type eq 'num' and B.type eq 'char' then Cats(Case When Length(Strip(A.name)) lt 32 Then A.name
                                                                     Else Substr(A.name,1,31) End
                                                               ,'_')
	        Else '' End
      ,Case When A.type eq 'num' and B.type eq 'char' then Strip(Coalesce(A.Informat,'15.'))
	        Else '' End
      ,Case When B.type eq 'num' and A.type eq 'char' then Strip(A.name)
	        Else '' End
	  ,Case When B.type eq 'num' and A.type eq 'char' then Cats(Case When Length(Strip(A.name)) lt 32 Then A.name
                                                                     Else Substr(A.name,1,31) End
                                                               ,'_')
	        Else '' End
      ,Case When B.type eq 'num' and A.type eq 'char' then Strip(Coalesce(A.Format,'30.'))
	        Else '' End
  into :Rename   separated by ' '
      ,:Drop     separated by ' '
	  ,:Keep1    separated by ' '
	  ,:Ren1     separated by ' '
	  ,:FmtKeep1 separated by ' '
	  ,:Keep2    separated by ' '
	  ,:Ren2     separated by ' '
	  ,:FmtKeep2 separated by ' '
  From BaseMdata_ A
  Join Aligndata_ B
    On A.name  = B.name
 Where A.type not = B.type
   ;

Quit ;

Options Notes ;

%DeleteDs(Aligndata_)
%DeleteDs(BaseMdata_)

%If %SYMEXIST(Keep1) %Then %Do ;
    %If %Cmpres(&Keep1) ne %Str() %Then %Do ;
        %Let Keep1=%Sysfunc(Compbl(&Keep1)) ;
    %End ;
    %ELSE %DO ;
        %Let Keep1=ALIGN_NULL;
    %END ;
%End ;
%ELSE %DO ;
%Let Keep1=ALIGN_NULL;
%END ;
%If %SYMEXIST(Keep2) %Then %Do ;
    %If %Cmpres(&Keep2) ne %Str() %Then %Do ;
        %Let Keep2=%Sysfunc(Compbl(&Keep2)) ;
    %End ;
    %ELSE %DO ;
        %Let Keep2=ALIGN_NULL;
    %END ;
%End ;
%ELSE %DO ;
%Let Keep2=ALIGN_NULL;
%END ;
%If %SYMEXIST(Ren1) %Then %Do ;
    %If %Cmpres(&Ren1) ne %Str() %Then %Do ;
        %Let Ren1=%Sysfunc(Compbl(&Ren1)) ;
    %End ;
    %ELSE %DO ;
        %Let Ren1=ALIGN_NULL;
    %END ;
%End ;
%ELSE %DO ;
%Let Ren1=ALIGN_NULL;
%END ;
%If %SYMEXIST(Ren2) %Then %Do ;
    %If %Cmpres(&Ren2) ne %Str() %Then %Do ;
        %Let Ren2=%Sysfunc(Compbl(&Ren2)) ;
    %End ;
    %ELSE %DO ;
        %Let Ren2=ALIGN_NULL;
    %END ;
%End ;
%ELSE %DO ;
%Let Ren2=ALIGN_NULL;
%END ;
%If %SYMEXIST(FmtKeep1) %Then %Do ;
    %If %Cmpres(&FmtKeep1) ne %Str() %Then %Do ;
        %Let FmtKeep1=%Sysfunc(Compbl(&FmtKeep1)) ;
    %End ;
    %ELSE %DO ;
        %Let FmtKeep1=ALIGN_NULL;
    %END ;
%End ;
%ELSE %DO ;
%Let FmtKeep1=ALIGN_NULL;
%END ;
%If %SYMEXIST(FmtKeep2) %Then %Do ;
    %If %Cmpres(&FmtKeep2) ne %Str() %Then %Do ;
        %Let FmtKeep2=%Sysfunc(Compbl(&FmtKeep2)) ;
    %End ;
    %ELSE %DO ;
        %Let FmtKeep2=ALIGN_NULL;
    %END ;
%End ;
%ELSE %DO ;
%Let FmtKeep2=ALIGN_NULL;
%END ;

%If %SYMEXIST(Rename) %Then %Do ;

%Put Rename = &Rename;
%Put Drop   = &Drop  ;

Data
    &AlignDs.
	;
Length &Length. ;
	Set
	   &AlignDs.(Rename=(&Rename.))
	   ;
%If %Str(&Keep1) ne ALIGN_NULL %Then %Do ;
%Put Keep1      = &Keep1.      ;
%Put Ren1       = &Ren1.       ;
%Put FmtKeep1   = &FmtKeep1.   ;
%Do AlignDatasets_i = 1 %To %Argcnt(&Keep1) ;
If "%Cmpres(%Scan(&FmtKeep1,&AlignDatasets_i,' '))" eq '15.' Then
   %Cmpres(%Scan(&Ren1,&AlignDatasets_i,' '))=Compress(%Cmpres(%Scan(&Ren1,&AlignDatasets_i,' ')),'$,') ;
   %Put INFO: %Cmpres(%Scan(&Keep1,&AlignDatasets_i,' ')) Variable is converted to Numeric ( %Cmpres(%Scan(&FmtKeep1,&AlignDatasets_i,' ')) ) !!! ;
%Cmpres(%Scan(&Keep1,&AlignDatasets_i,' ')) = Input(%Cmpres(%Scan(&Ren1,&AlignDatasets_i,' ')),%Cmpres(%Scan(&FmtKeep1,&AlignDatasets_i,' '))) ;
%End ;
%End ;
%If %Str(&Keep2) ne ALIGN_NULL %Then %Do ;
%Put Keep2      = &Keep2.      ;
%Put Ren2       = &Ren2.       ;
%Put FmtKeep2   = &FmtKeep2.   ;
%Do AlignDatasets_i = 1 %To %Argcnt(&Keep2) %While(&Keep2 ne %Str()) ;
%Put INFO: %Cmpres(%Scan(&Keep2,&AlignDatasets_i,' ')) Variable is converted to Character !!! ;
%Cmpres(%Scan(&Keep2,&AlignDatasets_i,' ')) = Put(%Cmpres(%Scan(&Ren2,&AlignDatasets_i,' ')),%Cmpres(%Scan(&FmtKeep2,&AlignDatasets_i,' '))) ;
%End ;
%End ;

Drop &Drop. ;
Run ;

%If %Bquote(&BaseFile.) ne %Bquote(NIL) %Then %Do ;
%DeleteDS(&AlignBaseDs.)
%End;
%Else %If %Upcase(&Append2Base.)  eq YES %Then %Do ;
Proc Append Base=&AlignBaseDs. Data=&AlignDs. Force;
Run ;
%Put Info: &AlignDs. Dataset is Appended to &AlignBaseDs. !!! ;
%End ;
%End ;

%EXIT:
%Put Info: AlignDatasets Macro Executed !!! ;

%Mend AlignDatasets;

/*%ReadFile(File="/sas/data02/tsgnacdka/Hari/Inputfiles/minks/1/APJBCSUnits2009-11.csv"*/
/*          ,NewDs=temp*/
/*          ,Type=csv*/
/*          ,Compress=Char*/
/*		  ,FileDes="/sas/data02/tsgnacdka/Hari/Inputfiles/minks/FieldDesc.csv"*/
/*         )*/

/*%AlignDatasets(*/
/*Baseds=NIL*/
/*,Ds=temp*/
/*,BaseFile="/sas/data02/tsgnacdka/Hari/Inputfiles/minks/FieldDesc.csv"*/
/*,Dlm='09'X*/
/*,Encoding='UTF-16LE'*/
/*,Append2Base=YES*/
/*,RemoveCr=NO*/
/*,Ftype=Csv*/
/*)*/
/**/
/*%DeleteDs(temp)*/
