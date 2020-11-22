%Macro SupportDataCleaning(SupportDS,OutDs=NIL,Region=XXX)/Store Secure;

%DsExist(&SupportDS.)

%If %Upcase(&OutDs.) Eq NIL %Then %Let OutDs=&Region._BCS_MIG_SUPP_CLND ;

%FmtMatch(Ds=HARI2004.BCS_SKU_LIST_17FEB2012
,FmtName=$PL
,Var=SKU
,Value=PL
,Other='#'
,Filter="PL in('1X','2M','TQ','TR','HA','SD2','SD - SUS','SD - OBS')"
)

%FMTMatch(Ds=Hari2004.BCS_PL23_Skus
,FMTName=$Version
,Var=SKU
,Value=VERSION
,Other='')

%FmtMatch(Ds=Hari2004.BCS_SKU_List_17Feb2012
,FmtName=$PT
,Var=SKU
,Value=ProcessorType
,Other='#'
,Filter="PL Eq '1X' And ProcessorType Eq 'Tukwila'"
)

Data
    &OutDs. (Compress=Char)
	;
	Set
	   &SupportDS.
	   ;

Length Fiscal_YR_QTR $10 Serial_Nbr_Clnd $50 Delete 3 PL $10;
Retain Serial_Nbr_Clnd '' Cnt 0;

PL     = Put(GOODS_PRODUCT_NBR,$PL.) ;
PL     = IfC(Put(GOODS_PRODUCT_NBR,$PT.) = 'Tukwila' & PL = '1X','1X_2',PL);

Amid=LVL2_AMID_CD ;
Amid_Name=LVL2_AMID_Name ;

Edate = Input(Compress(Scan(END_DATE,1,' '),'-'),YYMMDD10.);
Sdate = Input(Compress(Scan(START_DATE,1,' '),'-'),YYMMDD10.);

If Month(Edate) lt 11 then Fiscal_Year=Year(Edate) ;
Else Fiscal_Year=Year(Edate)+1 ;

Fiscal_Qtr_Exp=Put(Month(Edate),HpQtr.);

FY_Rep_QTR=CATS(Compress(Fiscal_Qtr_Exp,'TRtr'),"'",Put(Mod(Fiscal_Year,100),2.));

Fiscal_YR_QTR_N=(Fiscal_Year*100)+Input(Compress(Fiscal_Qtr_Exp,'QTRqtr'),1.) ;

YearMonth = Input(Put(edate,yymmn6.),6.);
Date_Aft_12_Months=Input(Put(Intnx('Month',Today(),12),yymmn6.),6.);
Xpiry_Nxt_12mnths=Ifn(YearMonth <= Date_Aft_12_Months,1,0);
Version		= Upcase(put(Goods_Product_Nbr,$Version.));
Drop Date_Aft_12_Months YearMonth ;

Run ;

Proc Sort Data=&OutDs. Out=&OutDs._TMP Nodupkey;
By
  LVL2_AMID_CD
  Sales_Doc_Nbr
  Goods_Product_Nbr
  Descending Serial_Nbr
  ;
Run ;

Data
   &OutDs._TMP
   ;
   Set
      &OutDs._TMP
	  ;
   By
     Amid
	 Sales_Doc_Nbr
     Goods_Product_Nbr
     Descending Serial_Nbr
     ;
Length Serial_Nbr_Clnd $50 ;
Retain Serial_Nbr_Clnd '' Cnt 0;

If First.Sales_Doc_Nbr Then Cnt=1 ;

If First.Goods_Product_Nbr Then Do ;
   Cnt=Cnt+1;
   If Not Missing(Serial_Nbr) Then Serial_Nbr_Clnd=Serial_Nbr ;
   Else Serial_Nbr_Clnd=Cats('DMY',Sales_Doc_Nbr,Goods_Product_Nbr,Put(Cnt,Z5.));
End ;
Else If Not Missing(Serial_Nbr) Then Do ;
Serial_Nbr_Clnd=Serial_Nbr ;
End ;

Drop Cnt ;
Run ;

%HashlookUp(BaseDs=&OutDs.
,LookUpDs=&OutDs._TMP
,Key=AMID Sales_Doc_Nbr Goods_Product_Nbr Serial_Nbr
,Values=Serial_Nbr_Clnd
)

Proc SQL ;

Create Table Product_Edate
as
Select Amid
      ,PL
      ,Serial_Nbr_Clnd
	  ,Min(Fiscal_YR_QTR_N) As Fiscal_YR_QTR_N
  From &OutDs.
 Group 
    by 1,2,3 ;

Quit ;

%HashlookUp(BaseDs=&OutDs.
,LookUpDs=Product_Edate
,Key=AMID PL Serial_Nbr_Clnd
,Values=Fiscal_YR_QTR_N
)
 
Proc Format ;
InValue Class
'Corporate'  = 1
'Enterprise' = 1
'COMMERCIAL' = 2
'Channels'   = 3
'SMB'        = 2
'Consumer'   = 2
Other        = 0
;
Value $Ind
'Network Equipment Providers'='2'
'Media & Entertainment'='3'
'Service Providers '='1'
'Banking'='3'
'Financial Markets'='1'
'Insurance'='2'
'Chemicals'='4'
'Healthcare Providers'='6'
'Healthcare Payers'='3'
'Life Sciences'='5'
'Pharmaceutical/Life Sciences'='2'
'Pharmaceutical'='1'
'Aerospace'='17'
'Automotive'='14'
'Consumer Packaged Goods'='12'
'Discrete - Energy & Nat. Res.'='13'
'Discrete - High Tech'='5'
'Discrete - Machinery'='10'
'Discrete - Media & Ent.'='9'
'Discrete Manufacturing'='8'
'Discrete - Retail & CG'='4'
'High Tech/Electronics'='7'
'Mining'='15'
'Oil and Gas'='16'
'Process Manufacturing'='11'
'Retail'='1'
'Transportation & Transportation Services'='6'
'Utilities'='3'
'Wholesale Trade'='2'
'Defense Manufactures'='1'
'Defense/Security/Police'='2'
'Education'='3'
'Education: Higher Ed/Universities'='4'
'Education: K-12 /School'='5'
'GOV: Administration & Finance'='6'
'Government: Federal/National'='7'
'Government: Justice'='8'
'Government / Multinational'='9'
'GOV: Public Health Programs'='10'
'Government: State/Local'='11'
'Government: Social Services'='12'
'Government: Treasury'='13'
'Amusement and Recreation'='11'
'Accounting'='12'
'Agriculture/forestry/fishing'='13'
'Business Consultancy'='7'
'Business Services'='6'
'Charities'='14'
'Construction'='14'
'Engineering services'='5'
'Graphic Arts **'='10'
'Hotels/Tourism/Travel Services'='9'
'Legal Services'='16'
'Marketing/Advertising/PR'='8'
'Other'='1'
'Personal Services'='3'
'Real Estate'='4'
'Research'='17'
'Computer Software/Services'='2'
Other='0'
;

Value $Corp
'Other Industries'='1'
'Financial Services Industry'='5'
'Health & Life Sciences'='4'
'Manufacturing & Distribution Industry'='3'
'Communications, Media & Entertainment'='2'
'Public Sector,& Education'='6'
Other='0'
;

run ;

Proc SQL NoPrint;
 
Select Count(Distinct Serial_Nbr_Clnd) Into :NoOfUnits From &OutDs. ;

Create Table DupAMid
As
Select Distinct Serial_Nbr_Clnd
      ,Amid
      ,Count(*) As Duplicates
  from (Select Distinct Serial_Nbr_Clnd,Amid 
          from &OutDs.
         Where Lowcase(Amid_name) ? 'hewlett'
            Or Lowcase(Amid_name) Like '% eds%'
            Or Lowcase(Amid_name) ? 'hp'
	        Or Amid in('','AUDEFAULT','NOMATCH','-','?')
			Or Amid not ? 'AUDEF'
       ) As A
 Group 
    by 1
Having Count(*) Gt 1 
;

Quit ;

%RecordsCount(DupAMid)

%If &Nobs. Gt 0 %Then %Do ;

%AddAccountDetails(DupAMid)

Proc SQL ;

Alter table DupAMid
Add Class Num,Delete Num;

Update DupAMid Set Class=Input(Strip(AAD_ACCTCLAS),Class.) ;

Create Table MinClass
as
Select Serial_Nbr_Clnd
      ,Put(Min(Class),1.) As Class
  from DupAMid
 Group 
    by 1
	;

Quit ;

%FmtMatch(Ds=MinClass,FmtName=$minCLass,Var=Serial_Nbr_Clnd,Value=Class)

Proc SQL ;

Update DupAMid Set Delete=1
 Where Put(Class,1.) NE Put(Serial_Nbr_Clnd,$minCLass.) 
   ;

Create Table DupAMid2
As
Select Distinct Serial_Nbr_Clnd
      ,Amid
	  ,Case When Upcase(AAD_Amid_Name) ? 'BEIJING'
        And Upcase(AAD_Amid_name) ? 'FOUNDER' 
        And Upcase(AAD_Amid_name) ? 'CENTURY'      Then 1 
       When Upcase(AAD_Amid_Name) ? 'BEIJING'
        And Upcase(AAD_Amid_name) ? 'FOUNDER' 
        And Upcase(AAD_Amid_name) ? 'ELECTRONIC'   Then 1 
       When Upcase(AAD_Amid_Name) ? 'CMC'
        And Upcase(AAD_Amid_name) ? 'SYSTEM'       Then 1 
       When ( Upcase(AAD_Amid_name) ?'COGNIZANT'     
        And Upcase(AAD_Amid_name) ? 'TECHNOLOGY' )  
         OR AAD_Amid_Name Eq 'CTS'                 Then 1 
       When Upcase(AAD_Amid_Name) ? 'DATA'     
        And Upcase(AAD_Amid_name) ? 'SYSTEMS'      Then 1 
       When Upcase(AAD_Amid_Name) ? 'DATACOM'      Then 1 
       When Upcase(AAD_Amid_Name) ? 'DATAGATE'     Then 1 
       When Upcase(AAD_Amid_Name) ? 'DELTEQ'       Then 1 
       When Upcase(AAD_Amid_Name) ? 'ECS'      
        And Upcase(AAD_Amid_name) ? 'COMPUTER'     Then 1 
       When Upcase(AAD_Amid_Name) ? 'ECS'      
        And Upcase(AAD_Amid_name) ? 'TECH'         Then 1 
       When Upcase(AAD_Amid_Name) ? 'FOUNDER'      
        And Upcase(AAD_Amid_name) ? 'HOLDING'      Then 1 
       When Upcase(AAD_Amid_Name) ? 'FLORA'      
        And Upcase(AAD_Amid_name) ? 'TELECOM'      Then 1 
       When Upcase(AAD_Amid_Name) ? 'INGRAM'       Then 1 
       When Upcase(AAD_Amid_Name) ? 'REDINGTON'    Then 1 
       When Upcase(AAD_Amid_Name) ? 'SINGTEL'       
        And Upcase(AAD_Amid_name) ? 'OPTUS'        Then 1 
       When Upcase(AAD_Amid_Name) ? 'SIS'      
        And Upcase(AAD_Amid_name) ? 'DISTRI'       Then 1 
       When Upcase(AAD_Amid_Name) ? 'SYSONE'       Then 1 
       When Upcase(AAD_Amid_Name) ? 'TECH'      
        And Upcase(AAD_Amid_name) ? 'PACIFIC'      Then 1 
       When Upcase(AAD_Amid_Name) ? 'DIGITAL'      
        And Upcase(AAD_Amid_name) ? 'YOUNGWOO'     Then 1 
       When Upcase(AAD_Amid_Name) ? 'ZUNGWON'      
        And Upcase(AAD_Amid_name) ? 'SYSTEM'       Then 1 
       When Upcase(AAD_Amid_Name) ? 'WIPRO'        Then 1 
       When Upcase(AAD_Amid_Name) ? 'TCS'          Then 1 
       When Upcase(AAD_Amid_Name) ? 'TATA'          
        And Upcase(AAD_Amid_name) ? 'CONSULTAN'    Then 1 
	   When Upcase(AAD_Amid_Name) ? 'ADVANCE'          
        And Upcase(AAD_Amid_name) ? 'WIRELESS'    
        And Upcase(AAD_Amid_name) ? 'NETWORK'      Then 1 
	   When Upcase(AAD_Amid_Name) ? 'BERCA'          
      And Upcase(AAD_Amid_name) ? 'HARDAYAPERKASA' Then 1
	   When Upcase(AAD_Amid_Name) ? 'ECS'          
        And Upcase(AAD_Amid_name) ? 'KUSH'         Then 1
       When Upcase(AAD_Amid_Name) ? 'SIGMA'          
        And Upcase(AAD_Amid_name) ? 'CIPTA'        Then 1
	   When Upcase(AAD_Amid_Name) ? 'KINMAX'          
        And Upcase(AAD_Amid_name) ? 'TECHNOLOGY'   Then 1
		Else 0 End as Flag
      ,Count(*) As Duplicates2
  from (Select Distinct Serial_Nbr_Clnd,AMid,AAD_Amid_Name from DupAmid 
         Where Delete In(.,0)
       ) As A
 Group 
    by 1
Having Count(*) Gt 1 
;

Quit ;

%HashlookUp(BaseDs=DupAMid2
,LookUpDs=DupAMid
,Key=AMID Serial_Nbr_Clnd
,Values=AAD_Amid_Name Duplicates AAD_L4AMID AAD_ACCTCLAS AAD_CORPSEG AAD_INDSEG
)

%HashlookUp(BaseDs=DupAMid2
,LookUpDs=&OutDs.
,Key=AMID Serial_Nbr_Clnd
,Values=Sdate Edate Sales_Doc_Nbr HW_SHIP_TO_PARTY_COUNTRY_CD
)

Proc Sort Data=DupAMid2 ;
By
     Serial_Nbr_Clnd
	 Flag
     Descending SDate
     Edate
	 Amid
	 AAD_L4AMID
     Duplicates2
  ;
Run ;

Data
   DupAMid2
   ;
   Set
      DupAMid2
	  ;
   By
     Serial_Nbr_Clnd
	 Flag
     Descending SDate
     Edate
	 Amid
	 AAD_L4AMID
     Duplicates2
   ;
LAmidL4=Lag(AAD_L4AMID) ;

If Not First.Serial_Nbr_Clnd Then Do ;
   If      AAD_L4AMID Eq LAmidL4  Then Delete=2 ;
   Else If Flag Eq 1              Then Delete=2 ;
End ;

Run ;

Proc SQL NoPrint;

Create Table MSDate
As
Select Serial_Nbr_Clnd,Max(SDate) As SDate,Count(*) As Duplicate3
  From ( Select Distinct Serial_Nbr_Clnd,SDate From DupAMid2
 Where Delete In(0,.) )
 Group 
    by 1
	;

Update DupAMid2 As A 
   Set Delete = 3
Where Exists 
           ( Select B.SDATE 
               from MSDate As B 
              Where A.Serial_Nbr_Clnd = B.Serial_Nbr_Clnd 
                And A.SDate NE B.SDATE
            ) ;

Quit ;

%HashlookUp(BaseDs=DupAMid
,LookUpDs=DupAMid2
,Key=AMID Serial_Nbr_Clnd
,Values=Delete
)

Data
   DupAMid
   ;
   Set
      DupAMid
	  ;
ValidR=Input(Cats(Put(AAD_CORPSEG,$Corp.),Put(AAD_INDSEG,$Ind.)),3.) ;
Run ;

Proc SQL ;

Create Table DupAMid3
As
Select Serial_Nbr_Clnd,Amid,Count(*) As Duplicates
From (Select Distinct Serial_Nbr_Clnd,AMid from DupAMid Where Delete In(0,.)) As A
Group By 1
Having Count(*) Gt 1
;

Create Table MaxValidR
As
Select Serial_Nbr_Clnd,Max(ValidR) As ValidR
from DupAMid 
Where Delete In(0,.)
Group 
  by 1 ;

Quit ;

%HashlookUp(BaseDs=DupAMid3
,LookUpDs=DupAMid
,Key=AMID Serial_Nbr_Clnd
,Values=Delete ValidR
)

Proc SQL ;

Update DupAMid3 As A 
   Set Delete = 4
Where Exists 
           ( Select 1 
               from MaxValidR As B 
              Where A.Serial_Nbr_Clnd = B.Serial_Nbr_Clnd 
                And A.ValidR NE B.ValidR
            ) ;

Quit ;

%HashlookUp(BaseDs=DupAMid
,LookUpDs=DupAMid3
,Key=AMID Serial_Nbr_Clnd
,Values=Delete
)

Proc SQL ;

Create Table DupAMid4
As
Select Serial_Nbr_Clnd,Amid,Count(*) As Duplicates
From (Select Distinct Serial_Nbr_Clnd,AMid from DupAMid Where Delete In(0,.)) As A
Group By 1
Having Count(*) Gt 1
;

Create Table Choose1
As
Select A.*
  from DupAMid A
 Inner 
  Join DupAMid4 B
    On A.Serial_Nbr_Clnd = B.Serial_Nbr_Clnd
   And A.Amid            = B.Amid
 Order 
    by Serial_Nbr_Clnd,Amid,AAD_L4AMID,AAD_Amid_Name
   ;

Quit ;

Data
   Choose1
   ;
   Set
      Choose1
	  ;
   By
     Serial_Nbr_Clnd
	 Amid
	 AAD_L4AMID
	 AAD_Amid_Name
	 ;
If First.Serial_Nbr_Clnd Then Delete=5 ;
Run ;

%HashlookUp(BaseDs=DupAMid
,LookUpDs=Choose1
,Key=AMID Serial_Nbr_Clnd
,Values=Delete
)

Proc Sort Data=DupAMid(Keep=Amid Serial_Nbr_Clnd Delete) Nodupkey;
By
  Amid
  Serial_Nbr_Clnd
  ;
Run ;

Proc Sort Data=&OutDs. ;
By
  Amid
  Serial_Nbr_Clnd
  Sdate
  ;
Run ;

Data
   &OutDs.
   ;
   Merge
      &OutDs.  (In=A)
	  DupAMid
	  ;
   By
     Amid
     Serial_Nbr_Clnd
	 ;
If A ;
Run ;
%End ;

Proc SQL NoPrint;
 
Select Count(Distinct Serial_Nbr_Clnd) Into :NoOfUnits_Last From &OutDs. Where Delete In(0,.) ;

Quit ;

%DeleteDs(&OutDs._TMP)
%DeleteDs(Product_Edate)
%DeleteDs(DupAMid)
%DeleteDs(MinClass)
%DeleteDs(DupAMid2)
%DeleteDs(MSDate)
%DeleteDs(DupAMid3)
%DeleteDs(DupAMid4)
%DeleteDs(MaxValidR)
%DeleteDs(Choose1)

%If &NoOfUnits. Eq &NoOfUnits_Last. %Then %Put INFO: SerialNumber Cleaned Sucessfully &NoOfUnits. = &NoOfUnits_Last. !!! ;
%Else %Put INFO: SerialNumber Not Cleaned Sucessfully - Difference &NoOfUnits. > &NoOfUnits_Last. !!! ;

%Exit:

%Mend SupportDataCleaning;
