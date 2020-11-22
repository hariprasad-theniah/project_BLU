%Macro AddAccountDetails(AccountDetailDs,AmidName,Impaq=YES,Code=NIL)/Store Secure;

%DsExist(&AccountDetailDs.)
%Let AccountDetailLib=&DSLIB ;
%Let AccountDetailDsNm=&DSNM ;

%RecordsCount(&AccountDetailDs.)

%If &Nobs. LE 0 %Then %Do ;
    %Put ERROR: The Input dataset -> &AccountDetailDs. is EMPTY !!! ;
	%Goto Exit;
%End ;

%If &AmidName. Eq %Str() %Then %Do ;
    %Let AmidName=AMID ;
%End ;

    Options NoNotes ;
    Proc SQL NoPrint;
       Select Distinct Name
         into :Name
		 From Dictionary.Columns
        Where libname     ="%Cmpres(%Upcase(&AccountDetailLib.))"
          and memtype     ='DATA'
          and Memname     ="%Cmpres(%Upcase(&AccountDetailDsNm.))"
          and upcase(Name)="%Cmpres(%Upcase(&AmidName.))"
            ;
    Quit ;
	Options Notes;

%If Not %Symexist(Name) %Then %Do ;
    %Put ERROR: The Account Details Not Mapped - Amid variable not found!!! ;
    %Goto Exit;
%End ;

Libname Hari2004 '/sas/data2004/tsgwwcia/Hari/Data' ;

Proc SQL ;

Create table Amid_Cntry_Reg
as
Select Distinct Upcase(WCC_NM)  as Amid_Country
      ,WCC_SUB_REG_1_NM         as AMIDL2_Sub_Region
  From Hari2004.wcc_country_codes
 ;
Quit ;

%FMTMatch(Ds=Hari2004.region_country_iso,FMTName=$Cntyrnm,Var=ISO_Code,Value=COUNTRY_NAME,Other='')
%FMTMatch(Ds=Hari2004.region_country_iso,FMTName=$Cntyrgn,Var=ISO_Code,Value=HP_Region_Codei,Other='')
%FMTMatch(Ds=Amid_Cntry_Reg,FMTName=$AmidSubReg,Var=Amid_Country,Value=AMIDL2_Sub_Region,Other='')
%DeleteDs(Amid_Cntry_Reg)
%FmtMatch(Ds=Hari2004.CLASSCODE2010,FmtName=$CORPSEG,Var=L2_CLASSCODE,Value=HP_CUST_SEG,Other='')
%FmtMatch(Ds=Hari2004.industry_vert_seg,FmtName=$vertical,Var=VERTICAL,Value=Vertical_Name,Other='')
%FmtMatch(Ds=Hari2004.industry_vert_seg,FmtName=$Segment,Var=Segment,Value=Segment_Name,Other='')
%FmtMatch(Ds=Hari2004.industry_vert_seg,FmtName=$SegmentX,Var=VERTICAL,Value=Segment_Name,Other='')

%If %Upcase(&Impaq.) Eq YES %Then %Do ;
%RenameVar(&AccountDetailDs.,&AmidName.,AmidL2)
%FMTMatch(Ds=&AccountDetailDs.,FMTName=$Amid,Var=AmidL2)
%HashlookUp(BaseDs=&AccountDetailDs.,LookupDs=NCRF.ECM0301L2,Key=AmidL2,Values=ACCTNAME ACCTCLAS CORPSEG INDSEG L4AMID L4ACCTNAME
           ,Filter="Put(AmidL2,$Amid.) eq 'Y'")
Proc SQL ;
Create Table WWNCRF_AAD
As
(
Select Distinct AMidL2,ACCTCLAS As ACCTCLAS_WW,CORPSEG As CORPSEG_WW,INDSEG As INDSEG_WW,ISO2C As ISO2C_WW
  From NCRF.WWNCRF
 Where Put(AmidL2,$Amid.) Eq 'Y'
);
Quit ;
%HashlookUp(BaseDs=&AccountDetailDs.,LookupDs=WWNCRF_AAD,Key=AmidL2)
%DeleteDs(WWNCRF_AAD)
%RenameVar(&AccountDetailDs.,AmidL2,&AmidName.)
%End ;

%RenameVar(Hari2004.all_region_amid_hier
,L2_AMID_NUMBER L2_AMID_NAME L2_ACCOUNT_CLASS_CODE L2_CORP_SEG_CODE L4_AMID_NUMBER L4_AMID_NAME
,&AmidName. L2_AMID_NAME2 ACCTCLAS2 CORPSEG2 L4AMID2 L4ACCTNAME2)

%FMTMatch(Ds=&AccountDetailDs.,FMTName=$Amid,Var=&AmidName.)
%HashlookUp(BaseDs=&AccountDetailDs.,LookupDs=Hari2004.all_region_amid_hier
,Key=&AmidName.,Values=L2_AMID_NAME2 ACCTCLAS2 CORPSEG2 L4AMID2 L4ACCTNAME2
,Filter="Put(&AmidName.,$Amid.) eq 'Y'")

%RenameVar(Hari2004.all_region_amid_hier
,&AmidName. L2_AMID_NAME2 ACCTCLAS2 CORPSEG2 L4AMID2 L4ACCTNAME2
,L2_AMID_NUMBER L2_AMID_NAME L2_ACCOUNT_CLASS_CODE L2_CORP_SEG_CODE L4_AMID_NUMBER L4_AMID_NAME
)

%RenameVar(Hari2004.AMID_NAMES
,Amid Amid_Name AMID_L2_CLASS_CD  AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME
,&AmidName. Amid_Name2 AMID_L2_CLASS_CD2 AMID_L2_SEG_CD2 AMID_L42 AMID_L4_NAME2)

%HashlookUp(BaseDs=&AccountDetailDs.,LookupDs=Hari2004.AMID_NAMES
,Key=&AmidName.
,Values=Amid_Name2 AMID_L2_CLASS_CD2 AMID_L2_SEG_CD2 AMID_L42 AMID_L4_NAME2
,Filter="Put(&AmidName.,$Amid.) eq 'Y'")

%RenameVar(Hari2004.AMID_NAMES
,&AmidName. Amid_Name2 AMID_L2_CLASS_CD2 AMID_L2_SEG_CD2 AMID_L42 AMID_L4_NAME2
,Amid Amid_Name AMID_L2_CLASS_CD AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME)

Data
    &AccountDetailDs.
	;
Retain
AAD_Region_NAME
%If %Upcase(&Impaq.) Eq YES %Then %Do ;
AAD_COUNTRY_NAME_WW_NCRF 
%End ;
AAD_AMIDL2_Sub_Region AAD_COUNTRY_NAME AAD_L4AMID AAD_L4ACCTNAME FY
HQENTERPRISE_REGION HQENTERPRISE_COUNTRY CUSTOMER_SEGMENT FY11_CA_TIERING EB_INDUSTRIES_VERTICAL EB_INDUSTRIES_SEGMENT 
EB_INDUSTRIES_SUBSEGMENT
&AmidName. AAD_Amid_Name ACCTCLAS 
AAD_ACCTCLAS CORPSEG AAD_CORPSEG INDSEG AAD_INDSEG
;
Length AAD_COUNTRY_NAME AAD_AMIDL2_Sub_Region $100 AAD_Amid_Name $150 AAD_ACCTCLAS AAD_CORPSEG AAD_INDSEG $100
       ACCTCLAS CORPSEG INDSEG $8 AAD_Region_NAME $4
	   HQENTERPRISE_REGION $8 HQENTERPRISE_COUNTRY $75 CUSTOMER_SEGMENT $50 FY11_CA_TIERING $20 EB_INDUSTRIES_VERTICAL $20
       EB_INDUSTRIES_SEGMENT $50 EB_INDUSTRIES_SUBSEGMENT $50 FY $8
       ;
    Set
	   &AccountDetailDs.
	   ;
If Anyalpha(&AmidName.,3) Eq 0 Then Do ;
AAD_COUNTRY_NAME      =Put(Substr(&AmidName.,1,2),$Cntyrnm.) ;
AAD_Region_NAME       =Put(Substr(&AmidName.,1,2),$Cntyrgn.) ;

If Strip(AAD_Region_NAME) Eq 'AMR' Then AAD_Region_NAME='AMS' ;

AAD_AMIDL2_Sub_Region =Put(upcase(Strip(AAD_COUNTRY_NAME)),$AmidSubReg.);
End ;
%If %Upcase(&Impaq.) Eq YES %Then %Do ;
AAD_COUNTRY_NAME_WW_NCRF=Put(ISO2C_WW,$Cntyrnm.) ;
%End ;

ACCTCLAS=Coalescec(ACCTCLAS2
         %If %Upcase(&Impaq.) Eq YES %Then %Do ;
                  ,ACCTCLAS
		          ,ACCTCLAS_WW
		 %End ;
                  ,AMID_L2_CLASS_CD2);
CORPSEG=Coalescec(CORPSEG2
         %If %Upcase(&Impaq.) Eq YES %Then %Do ;
                 ,CORPSEG
		         ,CORPSEG_WW
		 %End ;
                 ,AMID_L2_SEG_CD2);

%If %Upcase(&Impaq.) Eq YES %Then %Do ;
INDSEG=Coalescec(INDSEG,INDSEG_WW);
%End ;
%Else %Do ;
INDSEG='' ;
%End ;

AAD_Amid_Name         =Coalescec(L2_AMID_NAME2
                                %If %Upcase(&Impaq.) Eq YES %Then %Do ; 
                                ,ACCTNAME
								%End ;
                                ,Amid_Name2) ;
AAD_ACCTCLAS          =Put(ACCTCLAS,$CORPSEG.);
AAD_CORPSEG           =Put(CORPSEG,$vertical.);
AAD_INDSEG            =Put(INDSEG,$Segment.);

AAD_L4AMID            =Coalescec(L4AMID2
                                %If %Upcase(&Impaq.) Eq YES %Then %Do ;
                                ,L4AMID
								%End ;
                                ,AMID_L42) ;
AAD_L4ACCTNAME        =Coalescec(L4ACCTNAME2
                                %If %Upcase(&Impaq.) Eq YES %Then %Do ;
                                ,L4ACCTNAME
								%End ;
                                ,AMID_L4_NAME2) ;

Drop CORPSEG2 L4AMID2 L4ACCTNAME2 ACCTCLAS2 L2_AMID_NAME2 Amid_Name2 AMID_L2_CLASS_CD2 AMID_L2_SEG_CD2 AMID_L42 AMID_L4_NAME2 
     %If &Code. Eq NIL %Then %Do ;
	     ACCTCLAS CORPSEG INDSEG
	 %End ;
     %If %Upcase(&Impaq.) Eq YES %Then %Do ;
         ACCTNAME L4AMID L4ACCTNAME ACCTCLAS_WW CORPSEG_WW INDSEG_WW ISO2C_WW
	 %End ;
     ;
Run ;

%RenameVar(&AccountDetailDs.,AAD_L4AMID,AMID_4)

%HashlookUp(BaseDs=&AccountDetailDs.,LookupDs=Hari2004.Global_Accounts
,Key=AMID_4
,Values=HQENTERPRISE_REGION HQENTERPRISE_COUNTRY CUSTOMER_SEGMENT FY11_CA_TIERING EB_INDUSTRIES_VERTICAL EB_INDUSTRIES_SEGMENT EB_INDUSTRIES_SUBSEGMENT FY
)

%RenameVar(&AccountDetailDs.,AMID_4,AAD_L4AMID)

Proc SQL NoPrint ;
Select Distinct FY Into :GA_FY From Hari2004.Global_Accounts ;

Update &AccountDetailDs.
   Set FY=Case When FY ? 'FY' Then 'YES' 
               Else 'NO' End
   ;
Quit ;

%RenameVar(&AccountDetailDs.,FY,GA_Flag)

%AssignLabel(&AccountDetailDs.
,AAD_Region_NAME,Region Name
,AAD_COUNTRY_NAME,Country Name
,AAD_AMIDL2_Sub_Region,Sub Region
,AAD_L4AMID,L4 Account Number
,AAD_L4ACCTNAME,L4 Account Name
,AAD_Amid_Name,L2 Account Name
,AAD_ACCTCLAS,L2 Class Name
,AAD_CORPSEG,L2 Corporate Segment Name
,AAD_INDSEG,L2 Industry Segment Name
,GA_Flag,Global Accounts &GA_FY. Flag 
,HQENTERPRISE_REGION,Global Accounts &GA_FY. - HQ/Enterprise Region 
,HQENTERPRISE_COUNTRY,Global Accounts &GA_FY. - HQ/Enterprise country
,CUSTOMER_SEGMENT,Global Accounts &GA_FY. - Customer Segment
,FY11_CA_TIERING,Global Accounts &GA_FY. - CA Tiering
,EB_INDUSTRIES_VERTICAL,Global Accounts &GA_FY. - EB Industries Vertical
,EB_INDUSTRIES_SEGMENT,Global Accounts &GA_FY. - EB Industries Segment
,EB_INDUSTRIES_SUBSEGMENT,Global Accounts &GA_FY. - EB Industries Sub-segment
%If &Code. Ne NIL %Then %Do ;
,ACCTCLAS,L2 Class Code
,CORPSEG,L2 Corporate Segment Code
,INDSEG,L2 Industry Segment Code
%End ;
)

%Exit:

%Mend AddAccountDetails ;
