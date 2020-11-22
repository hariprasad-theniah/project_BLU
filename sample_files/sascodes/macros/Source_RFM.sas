%Macro RFM(RFMInDs=NIL
          ,RFMOutDs=NIL
          ,Segments=3
          ,CreateCSV=NIL
          ,RWeight=1
          ,FWeight=1
          ,MWeight=1
		  ,Rounding=NIL
		  ,Filter=NIL
          ) / Store Secure;

%DsExist(&RFMInDs.)

%VarExist(&RFMInDs.,Amid)
%Let VarTest=&VarExist. ;

%If &VarTest. Eq %Str() %Then %Do ;
%Put ERROR: Fiscal_Year Variable specified not exist in the dataset !!! ;
%GOTO EXIT ;
%End ;

%VarExist(&RFMInDs.,Fiscal_Year)
%Let VarTest=&VarExist. ;

%If &VarTest. Eq %Str() %Then %Do ;
%Put ERROR: Fiscal_Year Variable specified not exist in the dataset !!! ;
%GOTO EXIT ;
%End ;

%VarExist(&RFMInDs.,FISCAL_QTR_NM)
%Let VarTest=&VarExist. ;

%If &VarTest. Eq %Str() %Then %Do ;
%Put ERROR: FISCAL_QTR_NM Variable specified not exist in the dataset !!! ;
%GOTO EXIT ;
%End ;

%VarExist(&RFMInDs.,Ship_Qty)
%Let VarTest=&VarExist. ;

%If &VarTest. Eq %Str() %Then %Do ;
%Put ERROR: Ship_Qty Variable specified not exist in the dataset !!! ;
%GOTO EXIT ;
%End ;

%VarExist(&RFMInDs.,SHIP_NET_USD_AMT)
%Let VarTest=&VarExist. ;

%If &VarTest. Eq %Str() %Then %Do ;
%Put  ERROR: Amid Variable specified not exist in the dataset !!! ;
%GOTO EXIT ;
%End ;

%If &Segments. Ne 5 And &Segments. Ne 3 %Then %Do ;
    %If &Segments. < 5 %Then %Do ;
        %Let Segments=3 ;
		%Put INFO: RFM macro supports only segments 3 or 5, as the segment value less than 5 the macro will run for segment 3 ;
    %End ;
	%Else %Do ;
        %Let Segments=5 ;
		%Put INFO: RFM macro supports only segments 3 or 5, as the segment value greater than 5 the macro will run for segment 5 ;
	%End ;
%End ;
    
DATA 
    &RFMInDs.
    ;
    SET 
       &RFMInDs.
       ;
%If %Bquote(&Filter.) Ne %Bquote(NIL) %then %Do ;
Where %Sysfunc(Dequote(&Filter.));
%End ;

FORMAT TRAN_MON MONYY7.;
TRAN_QTR=(Fiscal_Year*10)+INPUT(Compress(FISCAL_QTR_NM,'QTR'),1.);

RUN;

Proc Summary Data=&RFMInDs. Nway Missing ;
Class Amid TRAN_QTR;
Var Ship_Qty SHIP_NET_USD_AMT ;
Output Out=&RFMInDs._Summ(Drop=_:) Sum= ;
Run ;

PROC SQL;
CREATE TABLE &RFMInDs._Summ2 AS 
SELECT  Amid,
		COUNT(DISTINCT TRAN_QTR) AS FREQUENCY,
		Max(TRAN_QTR) As LATEST_TRAN_QTR,
		SUM(SHIP_NET_USD_AMT) AS Monetary,
		SUM(Ship_Qty) AS Quantity
FROM &RFMInDs._Summ
GROUP BY 1 
Having Calculated Monetary > 0
Order By 1
;
QUIT;

Data
   &RFMInDs._Summ2
   ;
   Set
      &RFMInDs._Summ2
	  ;
   By
     Amid
     ;
CURR_QTR=(Input(Substr("&Curr_FYQ.",1,4),4.)*10)+Input(Substr("&Curr_FYQ.",6,1),1.) ;
%QTRDiff(LATEST_TRAN_QTR,CURR_QTR,Out=Recency)
Drop CURR_QTR ;
Run ;

%Quantile&Segments.(&RFMInDs._Summ2,Monetary,RoundOff=&Rounding.)
%Quantile&Segments.(&RFMInDs._Summ2,Recency,RoundOff=&Rounding.)
%Quantile&Segments.(&RFMInDs._Summ2,FREQUENCY,RoundOff=&Rounding.)

Proc Format ;
%If &Segments. Eq 5 %then %do ;
Value Monetary
Low - &Low_Monetary. = '1'
&Low_Monetary. <- &HLow_Monetary. = '2'
&HLow_Monetary. <- &LHigh_Monetary. = '3'
&LHigh_Monetary. <- &High_Monetary. = '4'
&High_Monetary. <- High = '5'
;
Value Recency
Low - &Low_Recency. = '5'
&Low_Recency. <- &HLow_Recency. = '4'
&HLow_Recency. <- &LHigh_Recency. = '3' 
&LHigh_Recency. <- &High_Recency. = '2'
&High_Recency. <- High = '1'
;
Value Frequency
Low - &Low_Frequency. = '1'
&Low_Frequency.   <- &HLow_Frequency. = '2'
&HLow_Frequency.  <- &LHigh_Frequency. = '3' 
&LHigh_Frequency. <- &High_Frequency. = '4'
&High_Frequency.  <- High = '5'
;
%End ;
%Else %If &Segments. Eq 3 %then %do ;
Value Monetary
Low - &Low_Monetary. = '1'
&Low_Monetary.  <- &High_Monetary. = '2'
&High_Monetary. <- High = '3'
;
Value Recency
Low - &Low_Recency. = '3'
&Low_Recency.  <-  &High_Recency. = '2'
&High_Recency. <- High = '1'
;
Value Frequency
Low - &Low_Frequency. = '1'
&Low_Frequency.  <-  &High_Frequency. = '2'
&High_Frequency. <- High = '3'
;
%End ;
Run ;

%If &RFMOutDs. Eq NIL %Then %Do ; 
    %Let RFMOutDs=RFM ; 
%End ;

Data
   &RFMOutDs.
   ;
   Set
      &RFMInDs._Summ2
      ;
   By
     Amid
     ;
RFM= (Input(Put(Monetary,Monetary.),1.)*&MWeight.)
    *(Input(Put(Frequency,Frequency.),1.)*&FWeight.)
    *(Input(Put(Recency,Recency.),1.)*&RWeight.) ;
Format Monetary Monetary. Frequency Frequency. Recency Recency. ;
Label Monetary  = "Monetary score - &Segments. scale"
      Frequency = "Frequency score - &Segments. scale"
      Recency   = "Recent score - &Segments. scale"
      RFM       = "Recency * Frequency * Monetary - Score"
     ;
Run ;

%If &CreateCSV. Ne NIL %Then %Do ;
%SaveCSV(Ds=&RFMOutDs.,File="&OutputPath./&RFMOutDs._&Sysdate9..csv",OverWrite=YES) ;
%End ;

%Exit:

%Mend RFM;

/*%Impaq2Master(Hariship.ESSN_AMS_FY12Q1*/
/*,OutDs=BCSDSAMS*/
/*,PH=YES,AH=NO*/
/*,Filter="Put(Divcode,$ESSNBU.) In ('BCS') And FYEAR GE 2003 And Partner Ne 'Y'")*/
/**/
/*Data*/
/*   Harintrm.BCSDS*/
/*   ;*/
/*   Set*/
/*      BCSDSAMS(Keep=AMID Fiscal_Year Fiscal_Qtr_NM PROD_MFG_SKU_CD SHIP_QTY SHIP_NET_USD_AMT PROD_MFG_GBU_CD PROD_MFG_GBU_NM */
/*                    PROD_MFG_PRODUCT_LINE_NM PROD_MFG_PRODUCT_LINE_CD PROD_MFG_TYPE_DESC PROD_MFG_TYPE_CD PROD_MFG_LINE_DESC */
/*                    PROD_MFG_LINE_CD PROD_MFG_FAMILY_DESC PROD_MFG_FAMILY_CD PROD_MFG_PRODUCT_CD PROD_MFG_PRODUCT_DESC */
/*                    PROD_MFG_MODEL_CD PROD_MFG_MODEL_DESC PROD_MFG_SKU_NM)*/
/*	  Hariship.ShipmentMaster_BCS(Keep=AMID Fiscal_Year Fiscal_Qtr_NM PROD_MFG_SKU_CD SHIP_QTY SHIP_NET_USD_AMT PROD_MFG_GBU_CD */
/*                                  PROD_MFG_GBU_NM PROD_MFG_PRODUCT_LINE_NM PROD_MFG_PRODUCT_LINE_CD PROD_MFG_TYPE_DESC */
/*                                  PROD_MFG_TYPE_CD PROD_MFG_LINE_DESC PROD_MFG_LINE_CD PROD_MFG_FAMILY_DESC PROD_MFG_FAMILY_CD */
/*                                  PROD_MFG_PRODUCT_CD PROD_MFG_PRODUCT_DESC PROD_MFG_MODEL_CD PROD_MFG_MODEL_DESC */
/*                                  PROD_MFG_SKU_NM)*/
/*	  ;*/
/*Run ;*/
/**/
/*%RFM(RFMInDs=Harintrm.BCSDS,RFMOutDs=BCSRFM,Segments=5*/
/*,CreateCSV=YES*/
/*,Rounding=YES*/
/*)*/


