%Macro RemoveCr(File=)/Store Secure ;
%Put INFO: Macro RemoveCr is Called for File &File !!! ;
%Let File=%Sysfunc(dequote(&File)) ;
X "mv &File &File._" ;
X "tr -d '\r' < &File._ > &File" ;
X "rm &file._" ;
%Let File=%Sysfunc(quote(&File)) ;
%Put INFO: Macro RemoveCr Ran !!! ;
%Mend RemoveCr ;
