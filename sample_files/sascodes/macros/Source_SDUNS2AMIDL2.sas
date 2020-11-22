%Macro SDUNS2AMIDL2(AmidDS=NIL,SDUNSDS=NIL,OutDs=NIL,NCompare=NIL) / Store Secure ;
%If %Upcase(&SDUNSDS.) Ne NIL %Then %Do ;
%DsExist(&SDUNSDS.)

%VarExist(&SDUNSDS.,SDUNS)
%If &VarExist. Eq %Str() %Then %Do ;
    %Put ERROR: SDUNS is not exist with the Dataset &SDUNSDS. ;
	%Goto Exit ;
%End ;

%FmtMatch(Ds=&SDUNSDS.
,FmtName=$SDUNS
,Var=SDUNS
,Filter="Not Missing(SDUNS)"
)

Data
    %If %Upcase(&OutDs.) Ne NIL %Then %Do ; &OutDs. %End ;
    %Else %Do ; SDUNS2AMIDL2 %End ;
    ;
    Set
       DBWW.EDW_DBWW(Keep=Sduns AmidL2)
       ;
Where Put(
%If %Upcase(&NCompare.) Ne NIL %Then %Do ; Put(Input(Sduns,10.),9. -L) %End;
%Else %Do ; Sduns  %End;
,$SDUNS.) Eq 'Y' ;
Run ;
%END ;
%Else %If %Upcase(&AmidDs.) Ne NIL %Then %Do ;
%DsExist(&AmidDs.)

%VarExist(&AmidDs.,Amid)
%If &VarExist. Eq %Str() %Then %Do ;
    %Put ERROR: Amid is not exist with the Dataset &AmidDs. ;
	%Goto Exit ;
%End ;

%FmtMatch(Ds=&AmidDs.
,FmtName=$Amid
,Var=Amid
,Filter="Not Missing(Amid)"
)

Data
    %If %Upcase(&OutDs.) Ne NIL %Then %Do ; &OutDs. %End ;
    %Else %Do ; SDUNS2AMIDL2 %End ;
    ;
    Set
       DBWW.EDW_DBWW(Keep=Sduns AmidL2)
       ;
Where Put(AmidL2,$Amid.) Eq 'Y' ;
Run ;
%END ;
%Else %Do ;
%Put Error: No Input Dataset to process SDUNS2AMIDL2 Macro !!! ;
%End ;

%EXIT:
%Mend SDUNS2AMIDL2 ;
/*
%ReadFile(File="&InputPath./temp2.csv"
         ,NewDs=temp2
         ,Type=csv
         ,Compress=Char
         )
%SDUNS2AMIDL2(AmidDs=temp2,SDUNSDS=NIL,OutDs=temp3)
%FmtMatch(Ds=temp3
,FmtName=$SDUNS
,Var=SDUNS
)

%HashlookUp(BaseDs=temp3,LookupDs=HH.EDW_SITEDESCRIPTION,Key=SDUNS
,Values=HOMEPAGEURL
,Filter="Put(SDUNS,$SDUNS.) Eq 'Y')"
)

proc copy in=work out=Harintrm ;
select temp3 ;
run ;

Proc Sort Data=temp3(Keep=Amid HOMEPAGEURL) Out=HOMEPAGEURL nodupkey ;
By
  Amid
  HOMEPAGEURL
  ;
Run ;

%SaveCSV(Ds=HOMEPAGEURL,File="&OutputDs./HomePage_Sduns_HH.csv",OverWrite=YES)
*/
