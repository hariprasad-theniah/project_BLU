%Macro GZIP(Path=NIL,File=NIL,Ext=NIL,UnZip=YES,OverWrite=NIL)/Store Secure;

%If %Bquote(%Upcase(&Path.)) Eq %Bquote(NIL) And %Bquote(%Upcase(&File.)) Eq %Bquote(NIL) %Then %Do ;
    %Put ERROR: NO Input to GZIP macro to process !!! ;
    %Goto Exit ;
%End ;

%If %Bquote(%Upcase(&Path.)) Ne %Bquote(NIL) %Then %Do ;

%If %Upcase(&Ext.) Eq NIL %Then %Let Ext=csv;

%Let Path=%Sysfunc(ifc(%Sysfunc(Quote(%Substr(&Path,%Length(&Path)-1,1))) Eq "/"
                      ,&Path,%Sysfunc(quote(%Sysfunc(Cats(%Sysfunc(Dequote(&Path)),/)))))) ;

%If %Upcase(&UnZip.) Eq YES %Then %Do ;
X "gunzip %Sysfunc(dequote(&Path))%Cmpres(*.&Ext.).gz" ;
%Put INFO: All &Ext extensios files in %Sysfunc(dequote(&Path)) Location got UnZipped !!! ;
%End ;
%Else %If %Upcase(&OverWrite.) Eq NIL %Then %Do ; 
X "gzip %Sysfunc(dequote(&Path))%Cmpres(*.&Ext.)" ;
%Put INFO: All &Ext extensios files in %Sysfunc(dequote(&Path)) Location got Zipped !!! ;
%End ;
%Else %Do ;
X "gzip -f %Sysfunc(dequote(&Path))%Cmpres(*.&Ext.)" ;
%Put INFO: All &Ext extensios files in %Sysfunc(dequote(&Path)) Location got Zipped and OverWritten!!! ;
%End ;

%End ;
%Else %If %Bquote(%Upcase(&File.)) Ne %Bquote(NIL) %Then %Do ;

%Let File=%Sysfunc(dequote(&File.));

%If %Upcase(&UnZip.) Eq YES %Then %Do ;
X "gunzip &File." ;
%End ;
%Else %If %Upcase(&OverWrite.) Eq NIL And %Sysfunc(FileExist(&File..gz)) %Then %Do ; 
%PUT INFO: &File..gz Already Exists. Overwrite is set to FALSE, so the file will not be ZIPPED;
%End ;
%Else %If %Upcase(&OverWrite.) Eq NIL %Then %Do ;
X "gzip &File." ;
%Put INFO: &File. got Zipped !!! ;
%End ;
%Else %Do ;
X "gzip -f &File." ;
%Put INFO: &File. got Zipped and Overwritten !!! ;
%End ;

%End ;

%Exit:
%Mend GZIP ;
