%Macro UpdatePHier(File=NIL,BU=NIL)/Store Secure ;

%If &FILE Eq NIL Or &BU Eq NIL %Then %Do ;
    %Put ERROR: Need Input file and BU information to run this macro ;
    %Goto Exit;
%End ;

%ReadFile(File=&File.
         ,NewDs=ProductHierarchy_Temp
         ,Type=csv
         ,Compress=Char
		 ,FileDes="&InputPath./prod_hier.csv"
         )

Proc Sort Data=ProductHierarchy_Temp NoDupRecs;
By
  MANUFACTURING_PRODUCT_IDENTIFI
  ;
Run ;
Data
   ProductHierarchy_Temp
   ;
   Set
      ProductHierarchy_Temp
	  ;
BU=Strip("&BU.") ;
Run ;

%If %Sysfunc(exist(Hari2004.ProductHierarchy)) %Then %Do ;
Proc Copy In=Hari2004 Out=WORK ;
Select ProductHierarchy ;
Run ;

Data
   Hari2004.ProductHierarchy
   ;
   Update
      ProductHierarchy
	  ProductHierarchy_Temp
	  ;
   By
     MANUFACTURING_PRODUCT_IDENTIFI
	 ;
Run ;
%End ;
%Else %Do ;
Data
   Hari2004.ProductHierarchy
   ;
   Set
      ProductHierarchy_Temp
	  ;
Run ;
%End ;

%Exit:
%Mend UpdatePHier ;
