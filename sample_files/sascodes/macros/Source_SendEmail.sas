%Macro SendEmail(From=NIL,To=NIL,CC=NIL,BCC=NIL,Attach=NIL,Type='text/plain',BodyMsg=NIL,BodyFile=Nil,BodyDs=Nil,Subject="Test")/Store Secure;

%If %Bquote(%Upcase(&BodyDs)) ne %Bquote(NIL) %then %Do ;
    %Let Type='text/html';
%End ;

Filename
SndEmail
email
%If %Upcase(&From)   ne NIL %Then %Do ; From=&From               %End ;
%If %Upcase(&To)     ne NIL %Then %Do ; To=(&To)                 %End ;
%If %Upcase(&CC)     ne NIL %Then %Do ; CC=(&CC)         %End ;
%If %Upcase(&Bcc)    ne NIL %Then %Do ; Bcc=(&Bcc)       %End ;
%If %Upcase(&Attach) ne NIL %Then %Do ; Attach=(&Attach) %End ;
Type=&Type
Subject=&Subject
;

%If %Bquote(%Sysfunc(Dequote(&BodyMsg.))) eq %Bquote(&BodyMsg.) %Then %Let BodyMsg=%Sysfunc(Quote(&BodyMsg.));

%Put BodyMsg=%Bquote(%Upcase(%Sysfunc(Dequote(&BodyMsg.))));

%If %Bquote(%Upcase(&BodyDs)) ne %Bquote(NIL) %then %Do ;
ODS Listing Close;
ODS HTML File=SndEmail ;

%Do i=1 %to %ArgCNT(&BodyDs) ;

Proc Print data=%Scan(&BodyDs,&i,' ') noobs Label;
%If %Bquote(%Upcase(%Sysfunc(Dequote(&BodyMsg.)))) Ne %Bquote(NIL) %Then %Do ;
    Title &BodyMsg. ;
%End ;
Run ;

%End ;

ODS HTML CLose ;
ODS Listing ;
%End ;
%Else %If %Upcase(&BodyFile) ne NIL %then %Do ;
Data
   _Null_
   ;
   File SndEmail ;
   %If %Bquote(%Upcase(%Sysfunc(Dequote(&BodyMsg.)))) Ne %Bquote(NIL) %Then %Do ;
   Put %Sysfunc(Quote(&BodyMsg.)) ;
   %End ;
   Length Body $32767 ;
   Infile &Bodyfile Truncover lrecl=32767 ;
   input ;
   Body=Trimn(_infile_) ;
   Put Body $Char256.;
Run ;
%End ;
%Else %Do ;
Data
   _Null_
   ;
   File SndEmail ;
   %If %Bquote(%Upcase(%Sysfunc(Dequote(&BodyMsg.)))) Ne %Bquote(NIL) %Then %Do ;
   Put %Sysfunc(Quote(&BodyMsg.)) ;
   %End ;
Run ;
%End ;

%Mend SendEmail ;
