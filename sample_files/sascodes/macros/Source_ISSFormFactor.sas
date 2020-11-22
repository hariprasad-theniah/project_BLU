%Macro ISSFormFactor(ISSDS=NIL,OutDs=NIL,Filter=NIL)/Store Secure ;

%DsExist(&ISSDS.)

%VarExist(&ISSDS.,PROD_MFG_FAMILY_DESC)
%If &VarExist. Eq %Str() %Then %Do ;
    %Put ERROR: PROD_MFG_FAMILY_DESC is not exist with the Dataset &ISSDS. ;
	%Goto Exit ;
%End ;
%VarExist(&ISSDS.,PROD_MFG_PRODUCT_LINE_CD)
%If &VarExist. Eq %Str() %Then %Do ;
    %Put ERROR: PROD_MFG_PRODUCT_LINE_CD is not exist with the Dataset &ISSDS. ;
	%Goto Exit ;
%End ;
%VarExist(&ISSDS.,PROD_MFG_LINE_DESC)
%If &VarExist. Eq %Str() %Then %Do ;
    %Put ERROR: PROD_MFG_LINE_DESC is not exist with the Dataset &ISSDS. ;
	%Goto Exit ;
%End ;
%VarExist(&ISSDS.,PROD_MFG_TYPE_DESC)
%If &VarExist. Eq %Str() %Then %Do ;
    %Put ERROR: PROD_MFG_TYPE_DESC is not exist with the Dataset &ISSDS. ;
	%Goto Exit ;
%End ;
%VarExist(&ISSDS.,PROD_MFG_SKU_NM)
%If &VarExist. Eq %Str() %Then %Do ;
    %Put ERROR: PROD_MFG_SKU_NM is not exist with the Dataset &ISSDS. ;
    %Goto Exit ;
%End ;

%If %Upcase(&OutDs.) Eq NIL %Then %Let OutDs =ISSFormFactor_Ds ;

Data
   &OutDs.
   ;
   Set
      &ISSDS.
	  ;

%If %Bquote(&Filter) ne %BQuote(NIL) %Then %Do ;
Where %Sysfunc(Dequote(&Filter)) ;
%End ;

Retain pExp 0 pExp1 0;
Length FormFactor $50 Exp $512 Generation $4 Exp2 $20;

If _N_ Eq 1 Then Do ;
Exp=CatX('|'
        ,'/([Dd][Ll]\d{3,})'
		,'([Mm][Ll]\d{3,})'
		,'([Ss][Dd][Ii])'
		,'([Ss][Tt][Oo][Rr][Aa][Gg][Ee].*[Ss][Ee][Rr][Vv][Ee][Rr])'
		,'([Ss][Ee][Rr][Vv][Ee][Rr].*[Ss][Tt][Oo][Rr][Aa][Gg][Ee])'
		,'([Hh][Ii][Gg][Hh].*[Aa][Vv][Aa][Ii][Ll][Aa][Bb][Ii][Ll][Ii][Tt][Yy])'
		,'([Bb][Ll][Aa][Dd][Ee])'
		,'([Oo][Bb][Ss][Oo][Ll][Ee][Tt][Ee])/'
        );
		
/* Exp2='/(G[1-9].?)$/'; */
Exp2='/(\sG[1-9].?\b)/';
pExp=prxparse(Exp);
pExp1=prxparse(Exp2);
End ;

If PRXMATCH(pExp1,Strip(PROD_MFG_FAMILY_DESC)) Then Do ;
	Generation=Substr(Strip(prxposn(pExp1,0,Strip(PROD_MFG_FAMILY_DESC))),1,2) ;
End ;
Else If PRXMATCH(pExp1,Strip(PROD_MFG_SKU_NM)) Then Do ;
	Generation=Substr(Strip(prxposn(pExp1,0,Strip(PROD_MFG_SKU_NM))),1,2) ;
End ;
Else Generation='' ;

/*Generation=IfC(PRXMATCH(pExp1,Strip(PROD_MFG_FAMILY_DESC)),Substr(Strip(prxposn(pExp1,0,Strip(PROD_MFG_FAMILY_DESC))),1,2),'') ;*/

If Strip(PROD_MFG_PRODUCT_LINE_CD) Eq 'UZ' Then FormFactor='ISS Interconnect';
Else If PRXMATCH(pExp,PROD_MFG_LINE_DESC) Then Do ;
Match=PRXPAREN(pExp) ;
	Select(Match);
		When(1) FormFactor='Rack';
		When(2) FormFactor='Tower';
		When(3) FormFactor='SDI Core';
		When(4) FormFactor='Storage Server';
		When(5) FormFactor='Storage Server';
		When(6) FormFactor='HA Units';
		When(7) FormFactor='Blade';
		When(8) FormFactor='Obsolete Server';
		Otherwise FormFactor='Others';
	End;
End ;
Else If PRXMATCH(pExp,PROD_MFG_FAMILY_DESC) Then Do ;
Match=PRXPAREN(pExp) ;
	Select(Match);
		When(1) FormFactor='Rack';
		When(2) FormFactor='Tower';
		When(3) FormFactor='SDI Core';
		When(4) FormFactor='Storage Server';
		When(5) FormFactor='Storage Server';
		When(6) FormFactor='HA Units';
		When(7) FormFactor='Blade';
		When(8) FormFactor='Obsolete Server';
		Otherwise FormFactor='Others';
	End;
End ;
Else If PRXMATCH(pExp,PROD_MFG_TYPE_DESC) And PRXPAREN(pExp) Eq 7 Then FormFactor='Blade' ;
Else FormFactor='Others';

Drop Match pExp pExp1 Exp Exp2 ;

Run ;

%Put INFO: &OutDs. Is created by ISSFormFactor macro !!! ;

%EXIT:

%Mend ISSFormFactor ;

