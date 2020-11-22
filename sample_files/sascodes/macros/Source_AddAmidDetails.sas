%Macro AddAccountDetails(AccountDetailDs,AmidName)/Store Secure;

%DsExist(&AccountDetailDs.)
%Let AccountDetailLib=&DSLIB ;
%Let AccountDetailDsNm=&DSNM ;

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

Proc SQL ;

Create table Amid_Cntry_Reg
as
Select Distinct Upcase(WCC_NM)  as Amid_Country
      ,WCC_SUB_REG_1_NM         as AMIDL2_Sub_Region
  From Hari2004.wcc_country_codes
 ;
Quit ;

%FMTMatch(Ds=Hari2004.region_country_iso,FMTName=$Cntyrnm,Var=ISO_Code,Value=COUNTRY_NAME,Other='')
%FMTMatch(Ds=Amid_Cntry_Reg,FMTName=$AmidSubReg,Var=Amid_Country,Value=AMIDL2_Sub_Region,Other='')
%DeleteDs(Amid_Cntry_Reg)
%FmtMatch(Ds=Hari2004.CLASSCODE2010,FmtName=$CORPSEG,Var=L2_CLASSCODE,Value=HP_CUST_SEG,Other='')
%FmtMatch(Ds=Hari2004.industry_vert_seg,FmtName=$vertical,Var=VERTICAL,Value=Vertical_Name,Other='')
%FmtMatch(Ds=Hari2004.industry_vert_seg,FmtName=$Segment,Var=Segment,Value=Segment_Name,Other='')
%FmtMatch(Ds=Hari2004.industry_vert_seg,FmtName=$SegmentX,Var=VERTICAL,Value=Segment_Name,Other='')

%RenameVar(&AccountDetailDs.,&AmidName.,AmidL2)
%FMTMatch(Ds=&AccountDetailDs.,FMTName=$Amid,Var=AmidL2)
%HashlookUp(BaseDs=&AccountDetailDs.,LookupDs=NCRF.ECM0301L2,Key=AmidL2,Values=ACCTNAME ACCTCLAS CORPSEG INDSEG L4AMID L4ACCTNAME
           ,Filter="Put(AmidL2,$Amid.) eq 'Y'")
%RenameVar(&AccountDetailDs.,AmidL2,&AmidName.)

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
AAD_COUNTRY_NAME AAD_AMIDL2_Sub_Region AAD_L4AMID AAD_L4ACCTNAME &AmidName. AAD_Amid_Name AAD_ACCTCLAS AAD_CORPSEG AAD_INDSEG
;
Length AAD_COUNTRY_NAME AAD_AMIDL2_Sub_Region $100 AAD_Amid_Name $150 AAD_ACCTCLAS AAD_CORPSEG AAD_INDSEG $100;
    Set
	   &AccountDetailDs.
	   ;
If Anyalpha(&AmidName.,3) Eq 0 Then Do ;
AAD_COUNTRY_NAME      =Put(Substr(&AmidName.,1,2),$Cntyrnm.) ;
AAD_AMIDL2_Sub_Region =Put(upcase(Strip(AAD_COUNTRY_NAME)),$AmidSubReg.);
End ;
AAD_Amid_Name         =Coalescec(L2_AMID_NAME2,ACCTNAME,Amid_Name2) ;
AAD_ACCTCLAS          =Put(Coalescec(ACCTCLAS2,ACCTCLAS,AMID_L2_CLASS_CD2),$CORPSEG.);
AAD_CORPSEG           =Put(Coalescec(CORPSEG2,CORPSEG,AMID_L2_SEG_CD2),$vertical.);
AAD_INDSEG            =Coalescec(Put(Coalescec(INDSEG),$Segment.)
                            ,Put(Coalescec(CORPSEG2,CORPSEG,AMID_L2_SEG_CD2),$SegmentX.)) ;
AAD_L4AMID            =Coalescec(L4AMID2,L4AMID,AMID_L42) ;
AAD_L4ACCTNAME        =Coalescec(L4ACCTNAME2,L4ACCTNAME,AMID_L4_NAME2) ;
Drop CORPSEG2 L4AMID2 L4ACCTNAME2 ACCTCLAS2 L2_AMID_NAME2 ACCTNAME ACCTCLAS CORPSEG INDSEG L4AMID L4ACCTNAME
     Amid_Name2 AMID_L2_CLASS_CD2 AMID_L2_SEG_CD2 AMID_L42 AMID_L4_NAME2 ;
Run ;

%AssignLabel(&AccountDetailDs.
,AAD_COUNTRY_NAME,Country Name
,AAD_AMIDL2_Sub_Region,Sub Region
,AAD_L4AMID,L4 Account Nummber
,AAD_L4ACCTNAME,L4 Account Name
,AAD_Amid_Name,L2 Account Name
,AAD_ACCTCLAS,L2 Class Name
,AAD_CORPSEG,L2 Corporate Segment
,AAD_INDSEG,L2 Industry Segment
)

%Exit:

%Mend AddAccountDetails ;
