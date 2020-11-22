%Macro ESS_Xtract(Year_GE=2003
                 ,ISS=NIL
				 ,BCS=NIL
				 ,SWD=NIL
				 ,APJ=NIL
				 ,EMEA=NIL
				 ,AMS=NIL
				 ,Country=NIL
				 ,PL=NIL
				 ,SKULIST_DS=NIL
				 ,Family_LVL=NIL
				 ,SKU_LVL=NIL
				 ,OutDS=ESS_Xtract_Summ
                 )/Store Secure;
%Put MACROMSG: ESS_Xtract is executing !!! ;
%If &ISS. Eq NIL & &BCS. Eq NIL & &SWD. Eq NIL %Then %Do ;
%Put ERROR: Atleast 1 BU should be selected to process the ESS_Xtract macro to execute !!! ;
%Goto Exit ;
%End ;

%If &APJ. Eq NIL & &EMEA. Eq NIL & &AMS. Eq NIL %Then %Do ;
%Put ERROR: Atleast 1 Region be selected to process the ESS_Xtract macro to execute !!! ;
%Goto Exit ;
%End ;

%If %Bquote(&PL.) Eq %Bquote(NIL) %Then %Do ;
    %Let PL_AMS_LIST=;
	%Let PL_EA_LIST=;
%End ;
%Else %Do ;
    %Let PL_AMS_LIST=%Bquote(And Substr(Divcode,2,2) In(&PL.));
	%Let PL_EA_LIST=%Bquote(And Strip(Prod_MFG_Product_Line_CD) In(&PL.));
%End ;

%If &SKULIST_DS. Ne NIL & %Sysfunc(Exist(&SKULIST_DS.)) %Then %Do ;
    %FmtMatch(Ds=&SKULIST_DS.
	,FmtName=$SKU
	,Var=SKU
	)
	%Let SKU_AMS_Filter=%Bquote(And Put(PartID,$SKU.) Eq 'Y') ;
	%Let SKU_EA_Filter=%Bquote(And Put(Prod_Mfg_SKU_CD,$SKU.) Eq 'Y') ;
%End ;
%Else %Do ;
    %Let SKU_AMS_Filter=;
	%Let SKU_EA_Filter=;
%End ;

%If &BCS. Ne NIL %Then %Let ESS_XtractX='BCS' ; %Else %Let ESS_XtractX=;
%If &ISS. Ne NIL %Then %Let ESS_XtractY='ISS' ; %Else %Let ESS_XtractY=;
%If &SWD. Ne NIL %Then %Let ESS_XtractZ='SWD' ; %Else %Let ESS_XtractZ=;

%If &APJ. Ne NIL %Then %Let ESS_XtractAPJ='APJ' ; %Else %Let ESS_XtractAPJ=;
%If &EMEA. Ne NIL %Then %Let ESS_XtractEMEA='EMEA' ; %Else %Let ESS_XtractEMEA=;

%If %Bquote(&Country.) Ne %Bquote(NIL) %Then %Let CntryWhere=%Bquote(And Strip(New_WCC_NM) In(&Country.));
%Else %Let CntryWhere=;

%If &ISS. Ne NIL %Then %Do ;
   %Let ISS_WHERE_AMS=%Str(And TYPECODE in('G13','GFF','GGH','GHH','GL5','GOO','GOR'));
   %Let ISS_WHERE_EA=%Str(And PROD_MFG_TYPE_CD in('G13','GFF','GGH','GHH','GL5','GOO','GOR'));
%End ;
%Else %Do ;
%Let ISS_WHERE_AMS=;
%Let ISS_WHERE_EA=;
%End ;

%If &AMS. Ne NIL %Then %Do ;
%Impaq2Master(Hariship.ESSN_AMS
,OutDs=ESS_Xtract_AMS
,PH=YES,AH=NO
,Filter="Put(Divcode,$ESSNBU.) In (&ESS_XtractX. &ESS_XtractY. &ESS_XtractZ.) 
And FYEAR GE &Year_GE.
 %Unquote(&PL_AMS_LIST.)
 %Unquote(&SKU_AMS_Filter.)
 &ISS_WHERE_AMS.
 And Partner Ne 'Y'
")
%End ;

%If &APJ. Ne NIL Or &EMEA. Ne NIL %Then %Do ;
%Let ESS_XtractKeepVar=%Str(AMID Fiscal_Year Fiscal_Qtr_NM PROD_MFG_SKU_CD SHIP_QTY SHIP_NET_USD_AMT PROD_MFG_GBU_CD PROD_MFG_GBU_NM
PROD_MFG_PRODUCT_LINE_NM PROD_MFG_PRODUCT_LINE_CD PROD_MFG_TYPE_DESC PROD_MFG_TYPE_CD PROD_MFG_LINE_DESC 
PROD_MFG_LINE_CD PROD_MFG_FAMILY_DESC PROD_MFG_FAMILY_CD PROD_MFG_PRODUCT_CD PROD_MFG_PRODUCT_DESC 
PROD_MFG_MODEL_CD PROD_MFG_MODEL_DESC PROD_MFG_SKU_NM New_WCC_NM
) ;
Data
   ESS_Xtract_EA
   ;
   Set
%If &ISS. Ne NIL %Then %Do ;
      Hariship.ShipmentMaster_ISS(Keep=&ESS_XtractKeepVar. MAINSUBREGION Where=(MAINSUBREGION IN(&ESS_XtractAPJ. &ESS_XtractEMEA.) 
                                                                  %Unquote(&SKU_EA_Filter.) %Unquote(&PL_EA_LIST.) And FISCAL_YEAR GE &Year_GE. 
                                                                  %Unquote(&CntryWhere.) &ISS_WHERE_EA.))
%End ;
%If &BCS. Ne NIL %Then %Do ;
	  Hariship.ShipmentMaster_BCS(Keep=&ESS_XtractKeepVar. MAINSUBREGION Where=(MAINSUBREGION IN(&ESS_XtractAPJ. &ESS_XtractEMEA.) 
                                                                  %Unquote(&SKU_EA_Filter.) %Unquote(&PL_EA_LIST.) %Unquote(&CntryWhere.)
																  And FISCAL_YEAR GE &Year_GE.))
%End ;
%If &SWD. Ne NIL %Then %Do ;
	  Hariship.ShipmentMaster_SWD(Keep=&ESS_XtractKeepVar. MAINSUBREGION Where=(MAINSUBREGION IN(&ESS_XtractAPJ. &ESS_XtractEMEA.) 
                                                                  %Unquote(&SKU_EA_Filter.) %Unquote(&PL_EA_LIST.) %Unquote(&CntryWhere.)
																  And FISCAL_YEAR GE &Year_GE.))
%End ;
     ;
Run ;
%End ;

%If %Sysfunc(exist(ESS_Xtract_AMS)) & %Sysfunc(exist(ESS_Xtract_EA)) %Then %Do ;
Proc Append Base=ESS_Xtract_EA Data=ESS_Xtract_AMS Force ;
Run ;
%DeleteDs(ESS_Xtract_AMS)
%End ;
%Else %If %Sysfunc(exist(ESS_Xtract_AMS)) %Then %Do ;
Proc Datasets Lib=WORK nodetails nolist ;
Change ESS_Xtract_AMS=ESS_Xtract_EA ;
Quit ;
%End ;

%Let PL_LVL=%Str(New_WCC_NM AMID Fiscal_Year Fiscal_Qtr_NM PROD_MFG_GBU_CD PROD_MFG_GBU_NM PROD_MFG_PRODUCT_LINE_NM PROD_MFG_PRODUCT_LINE_CD) ;

%If &SKU_LVL. Ne NIL %Then %Do ;
%Let Other_Hier=%Str(PROD_MFG_TYPE_DESC PROD_MFG_TYPE_CD PROD_MFG_LINE_DESC PROD_MFG_LINE_CD PROD_MFG_FAMILY_DESC PROD_MFG_FAMILY_CD
PROD_MFG_PRODUCT_CD PROD_MFG_PRODUCT_DESC PROD_MFG_MODEL_CD PROD_MFG_MODEL_DESC PROD_MFG_SKU_CD PROD_MFG_SKU_NM) ;
%End ;
%Else %If &Family_LVL. Ne NIL %Then %Do ;
%Let Other_Hier=%Str(PROD_MFG_TYPE_DESC PROD_MFG_TYPE_CD PROD_MFG_LINE_DESC PROD_MFG_LINE_CD PROD_MFG_FAMILY_DESC PROD_MFG_FAMILY_CD) ;
%End ;
%Else %Let Other_Hier= ;

Proc Summary Data=ESS_Xtract_EA Nway Missing ;
Class &PL_LVL. &Other_Hier. ;
Var SHIP_QTY SHIP_NET_USD_AMT ;
Output Out=&OutDS.(Drop=_:) Sum= ;
Run ;
%DeleteDs(ESS_Xtract_EA)

%RecordsCount(&OutDS.)

%Put MACROMSG: &OutDS. is created with &Nobs. records - by ESS_Xtract Macro !!! ;

%Exit:

%Mend ESS_Xtract;


