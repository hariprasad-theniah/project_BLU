%Macro Impaq2Master(AMSDS,OutDs=NIL,PH=NIL,AH=NIL,Filter=NIL)/Store Secure ;

%If %Bquote(%Upcase(&OutDs.)) Ne %Bquote(NIL) %Then %Do ;

%If %Bquote(&Filter) ne %BQuote(NIL) %Then %Let Filter=%Str(Where %Sysfunc(Dequote(&Filter))) ;
%Else %Let Filter=%str() ;

    Data
	    &OutDs.
		;
		Set
		   &AMSDS.
		   ;
    &Filter. ;
    Run ;
	%Let AMSDS=&OutDs. ;
%End ;

%If %Bquote(%Upcase(&PH.)) Ne %Bquote(NIL) %Then %Do ;
%FMTMatch(Ds=&AMSDS.,FMTName=$PARTID,Var=PARTID)

%HashlookUp(BaseDs=&AMSDS.,LookupDs=DCPARTS.IPARTS,Key=PARTID
,Values=GRPCODE GRPDESC DIVCODE DIVDESC TYPECODE TYPEDESC LINECODE LINEDESC FAMCODE FAMDESC PRODCODE PRODDESC MODCODE MODDESC PARTDESC
,Filter="Put(PARTID,$PARTID.) eq 'Y'")
    Data
	&OutDs.
	;
	Set
	   &OutDS.
     ;
     Divcode=Substr(Divcode,2,2);
     Fiscal_Qtr_NM=Cats('QTR',Put(FQTR,1.)) ;
      Run ;

%End ;

%If %Bquote(%Upcase(&AH.)) Ne %Bquote(NIL) %Then %Do ;
%AddAccountDetails(&AMSDS.,AmidL2)
%End ;

%RenameVarX(&AMSDS.
,AMIDL2,AMID
,FYEAR,Fiscal_Year
,PARTID,PROD_MFG_SKU_CD
,QTY,SHIP_QTY
,NOR,SHIP_NET_USD_AMT
,GRPCODE,PROD_MFG_GBU_CD
,GRPDESC,PROD_MFG_GBU_NM
,DIVDESC,PROD_MFG_PRODUCT_LINE_NM
,DIVCODE,PROD_MFG_PRODUCT_LINE_CD
,TYPEDESC,PROD_MFG_TYPE_DESC
,TYPECODE,PROD_MFG_TYPE_CD
,LINEDESC,PROD_MFG_LINE_DESC
,LINECODE,PROD_MFG_LINE_CD
,FAMDESC,PROD_MFG_FAMILY_DESC
,FAMCODE,PROD_MFG_FAMILY_CD
,PRODCODE,PROD_MFG_PRODUCT_CD
,PRODDESC,PROD_MFG_PRODUCT_DESC
,MODCODE,PROD_MFG_MODEL_CD
,MODDESC,PROD_MFG_MODEL_DESC
,PARTDESC,PROD_MFG_SKU_NM
)

%Mend Impaq2Master ;
