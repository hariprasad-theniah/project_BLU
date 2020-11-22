%Macro Catalog(Catalog)/Store Secure ;
   Proc Catalog CATALOG=&Catalog. ;
        Contents;
   Run ;
%Mend Catalog ;