%Let RC=%Sysget(RC) ;
%Let PPID=%Sysget(PPID) ;
%Let PName=%Sysget(PName) ;
%Let Email=%Sysget(MYEMAIL) ;
%Let PWD=%Sysget(PWD) ;
%Let Subject=;

%Macro Dummy ;
%If &RC. GT 1 %Then
%Let Subject=%Str(&PName. Failed !!!, RC - &RC. PPID - &PPID. &SYSDATE9. &SYSDAY. &SYSTime.);
%Else %If &RC. EQ 1 %Then
%Let Subject=%Str(&PName. ran Successfully with Warnings !!!, RC - &RC. PPID - &PPID. &SYSDATE9. &SYSDAY. &SYSTime.);
%Else 
%Let Subject=%Str(&PName. ran Successfully !!!, RC - &RC. PPID - &PPID. &SYSDATE9. &SYSDAY. &SYSTime.);
%Mend ;

%Dummy

%Put RC=&RC ;
%Put PPID=&PPID ;
%Put PName=&PName ;
%Put Email=&Email ;
%Put PWD=&PWD ;
%Put Subject=&Subject;

Filename
SndEmail
email
From="&Email."
TO="&Email."
Type='text/plain'
Subject="&Subject."
;

Data
   _Null_
   ;
Time=Time() ;
Format Time Time9. ;
Infile "&PWD./temp.logt" End=EOF;
File SndEmail ;
If Not EOF ;
Put @1 "*******************************************************************************************************************************************************************";
Put @60 'Date & Time       : ' +1 "&SYSDATE9." +1 " - &SYSDAY. - " +1 Time  ;
Put @60 "Program Name      : " +1 "&PName."  ;
Put @60 "Current Directory : " +1 "&PWD."  ;
Put @60 "Process ID        : " +1 "&PPID."  ;
Put @60 "Return Code       : " +1 "&RC."  ;
Put @1 "*******************************************************************************************************************************************************************";
Do While(Not EOF);
Input ;
Put _infile_ ;
End ;

Run ;




