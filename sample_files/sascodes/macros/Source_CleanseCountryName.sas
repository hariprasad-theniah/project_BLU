%Macro CleanseCountryName(Ds,CountryName)/Store Secure ;

%VarExist(&Ds.,&CountryName.)
%Let Country_Name=&VarExist. ;

%If &Country_Name. Eq %Str() %Then %Do ;
%Put ERROR: Country Variable specified not exist in the dataset !!! ;
%GOTO EXIT ;
%End ;

%Let Country_Name=%Cmpres(New_&Country_Name.) ;

Data
    &Ds.(Compress=Char)
	;
	Set
	   &Ds.
	   ;

Length &Country_Name. $100 ;
If      IndexW(&CountryName.,'Indent') gt 0 Then Do ;
    &Country_Name.=Substr(&CountryName.,1,IndexW(&CountryName.,'Indent') - 1);
End ;
Else If IndexW(&CountryName.,'Local')  gt 0 Then Do ;
    &Country_Name.=Substr(&CountryName.,1,IndexW(&CountryName.,'Local')  - 1);
End ;
Else If IndexW(&CountryName.,'Sales')  gt 0 Then Do ;
    &Country_Name.=Substr(&CountryName.,1,IndexW(&CountryName.,'Sales')  - 1);
End ;
Else Do ;
    &Country_Name.=Strip(&CountryName.);
End ;

If IndexW(&Country_Name.,'HQ')  gt 0 Then Do ;
    &Country_Name.=Tranwrd(&Country_Name.,'HQ','');
End ;
Else If Index(&Country_Name.,'sales') gt 0 or Index(&Country_Name.,'Sales') gt 0 Then Do ;
    &Country_Name.=Tranwrd(&Country_Name.,'Sales','');
	&Country_Name.=Tranwrd(&Country_Name.,'sales','');
	&Country_Name.=Tranwrd(&Country_Name.,'sale','');
	&Country_Name.=Tranwrd(&Country_Name.,'Sale','');
End ;

&Country_Name.=Strip(Compress(&Country_Name.,'.','C')) ;

If      Index(&Country_Name.,'Afghan')        Then &Country_Name.='Afghanistan' ;
Else If &Country_Name. Eq 'Azerbaijian'       Then &Country_Name.='Azerbaijan' ;
Else If Index(&Country_Name.,'Brunei')        Then &Country_Name.='Brunei' ;
Else If Index(&Country_Name.,'Korea')   
   And  Index(&Country_Name.,'Democratic')    Then &Country_Name.='Korea, Democratic People''s Republic of' ;
Else If Index(&Country_Name.,'Korea')         Then &Country_Name.='Korea, Republic of' ;
Else If Index(&Country_Name.,'New Zea')       Then &Country_Name.='New Zealand' ;
Else If Index(&Country_Name.,'Philipp')       Then &Country_Name.='Philippines' ;
Else If Index(&Country_Name.,'Emirates')      Then &Country_Name.='United Arab Emirates' ;
Else If Index(&Country_Name.,'Bosnia')        Then &Country_Name.='Bosnia and Herzegovina' ;
Else If Index(&Country_Name.,'Congo')
   And  ( Index(&Country_Name.,'Democratic')
    Or    Index(&Country_Name.,'Republic') )  Then &Country_Name.='Congo, The Democratic Republic of the' ;
Else If Index(&Country_Name.,'Congo')         Then &Country_Name.='Congo' ;
Else If Index(&Country_Name.,'Czech')         Then &Country_Name.='Czech Republic' ;
Else If Index(&Country_Name.,'Polynesia')     Then &Country_Name.='French Polynesia' ;
Else If Index(&Country_Name.,'Iran')          Then &Country_Name.='Iran (Islamic Republic Of)' ;
Else If Index(&Country_Name.,'Kyrgystan')     Then &Country_Name.='Kyrgyzstan' ;
Else If Index(&Country_Name.,'Libyan')        Then &Country_Name.='Libyan Arab Jamahiriya' ;
Else If Index(&Country_Name.,'Luxemburg')     Then &Country_Name.='Luxembourg' ;
Else If Index(&Country_Name.,'Macedonia')     Then &Country_Name.='Macedonia, The former Yuglosav, Republic Of' ;
Else If Index(&Country_Name.,'Moldova')       Then &Country_Name.='Moldova, Republic Of' ;
/*Else If Index(&Country_Name.,'Netherland')    Then &Country_Name.='Netherlands Antilles' ;*/
Else If ( Index(&Country_Name.,'South')     
    And  Index(&Country_Name.,'Africa') )
     Or  &Country_Name. Eq 'RSA'              Then &Country_Name.='South Africa' ;
Else If Index(&Country_Name.,'Syria')         Then &Country_Name.='Syrian Arab Republic' ;
Else If Index(&Country_Name.,'Tanzania')      Then &Country_Name.='Tanzania, United Republic of' ;
Else If Index(&Country_Name.,'Saudi')         Then &Country_Name.='Saudi Arabia' ;
Else If Index(&Country_Name.,'Russia')        Then &Country_Name.='Russia' ;
Else If &Country_Name. Eq 'Ukrainia'          Then &Country_Name.='Ukraine' ;
Else If Upcase(&Country_Name.) Eq 'UK'        Then &Country_Name.='United Kingdom' ;
 
Run ;

%EXIT:

%Mend CleanseCountryName;
