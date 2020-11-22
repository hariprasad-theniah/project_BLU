%Macro SupportData(SupportDS=NIL,OutDs=NIL,Region=NIL)/Store Secure;

%DsExist(&SupportDS.)

%If %Upcase(&OutDs.) Eq NIL %Then %Let OutDs=&Region._BCS_MIG_SUPP_CLND ;

%FmtMatch(Ds=Hari2004.bcs_sku_units_list,FmtName=$PL,Var=SKU,Value=PL,Other='',Filter="PL In('1X','2M','TQ','TR','HA')")
%FMTMatch(Ds=Hari2004.CW_MAP_DS,FMTName=$CWAMID,Var=Sold_To_Party_Id,Value=Lvl2_Cust_Mgmt_Acct_Id,Other='')
Data
    &Region._BCS_MIG_SUPP (Compress=Char)
	;
	Set
	   &SupportDS.
	   ;

PL     =Put(GOODS_PRODUCT_NBR,$PL.) ;

Amid=LVL2_AMID_CD ;
Amid_Name=LVL2_AMID_Name ;

If Missing(Amid) and Substr(SOLD_TO_PARTY_ID,1,2) eq 'CW' and ANYALPHA(SOLD_TO_PARTY_ID,3) eq 0 
Then Amid=Put(SOLD_TO_PARTY_ID,$CWAMID.) ;

Edate = Input(Compress(Scan(END_DATE,1,' '),'-'),YYMMDD10.);

YearMonth = Input(Put(edate,yymmn6.),6.);

If Month(Edate) lt 11 then Fiscal_Year=Year(Edate) ;
Else Fiscal_Year=Year(Edate)+1 ;

Fiscal_Qtr_Exp=Put(Month(Edate),HpQtr.);

Date_Aft_12_Months=Input(Put(Intnx('Month',Today(),12),yymmn6.),6.);
Xpiry_Nxt_12mnths=Ifn(YearMonth <= Date_Aft_12_Months,Item_Quantity,0);

Drop Edate Date_Aft_12_Months;
Run ;

Proc SQL ;

Create Table SAID_Max
As
Select Amid,Service_Agreement_ID,Max(YearMonth) As YearMonth
  From &Region._BCS_MIG_SUPP(Keep=Service_Agreement_ID YearMonth Amid)
 Group
    by 1,2
	;

Create Table &OutDs.
As
Select A.*
  From &Region._BCS_MIG_SUPP A
  Join SAID_Max         B
    On A.Amid = B.Amid
   And A.Service_Agreement_ID = B.Service_Agreement_ID
   And A.YearMonth = B.YearMonth
 ;
Quit ;

Proc Sort Data=&OutDs. Out=&Region._BCS_MIG_SUPP_Serial_Clns Nodupkey;
By
  Amid
  Sales_Doc_Nbr
  Goods_Product_Nbr
  Descending Serial_Nbr
  ;
Run ;

Data
   &Region._BCS_MIG_SUPP_Serial_Clns
   ;
   Set
      &Region._BCS_MIG_SUPP_Serial_Clns
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
,LookUpDs=&Region._BCS_MIG_SUPP_Serial_Clns
,Key=AMID Sales_Doc_Nbr Goods_Product_Nbr Serial_Nbr
,Values=Serial_Nbr_Clnd
)

%DeleteDs(&Region._BCS_MIG_SUPP_Serial_Clns)
%DeleteDs(SAID_Max)
%DeleteDs(&Region._BCS_MIG_SUPP)

%Mend SupportData ;
