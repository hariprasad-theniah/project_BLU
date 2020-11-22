%Macro ImpaqXtract(OutDs=,US=YES,LA=YES,CA=YES,PH=NIL,AH=NIL,Filter=NIL)/Store Secure ;

Data
    &OutDs.
	;
	Set
%If %Upcase(&US.) Eq YES %Then %Do ;
         Model.EDW_PARTSHIP (In = In_A)
%End ;
%If %Upcase(&CA.) Eq YES %Then %Do ;
       CAModel.EDW_PARTSHIP (In = In_B)
%End ;
%If %Upcase(&LA.) Eq YES %Then %Do ;
       LAModel.EDW_PARTSHIP (In = In_C)
%End ;
	   ;
%If %Bquote(&Filter) ne %Bquote(NIL) %Then %Do ;
Where %Sysfunc(Dequote(&Filter)) ;
%End ;

%If %Upcase(&US.) Eq YES %Then %Do ;
       If In_A Then Source='Model  ' ;
%End ;
%If %Upcase(&CA.) Eq YES %Then %Do ;
       If In_B Then Source='ModelCA' ;
%End ;
%If %Upcase(&LA.) Eq YES %Then %Do ;
       If In_C Then Source='ModelLA' ;
%End ;

Run ;

%If %Upcase(&PH.) Eq YES %Then %Do ;
%FMTMatch(Ds=&OutDs.,FMTName=$PARTID,Var=PARTID)
%HashlookUp(BaseDs=&OutDs.,LookupDs=DCPARTS.IPARTS,Key=PARTID
,Values=GRPCODE GRPDESC DIVCODE DIVDESC TYPECODE TYPEDESC LINECODE LINEDESC FAMCODE FAMDESC PRODCODE PRODDESC MODCODE MODDESC PARTDESC
,Filter="Put(PARTID,$PARTID.) eq 'Y'")
%End ;

%If %Upcase(&AH.) Eq YES %Then %Do ;
%AddAccountDetails(&OutDs.,AmidL2)
%End ;

%Mend ImpaqXtract;

/*%ImpaqXtract(OutDs=X,CA=No,LA=No,PH=YES,AH=YES,Filter="AmidL2 eq 'US078799095'")*/
