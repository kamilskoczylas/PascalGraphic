{$G+}{$N+}
UNIT Standard;

INTERFACE

USES Types, Dos;

VAR S_Ti       :Longint ABSOLUTE $40:$6C;
    S_NewTi    :Longint;
    S_NewFPSTi :Longint;
    S_SFPS     :Longint;
    S_Frames : LongInt;

FUNCTION  S_GetTime:Longint;
FUNCTION  S_ShowFPS(VAR Frames:Longint):Word;
FUNCTION  IntToStr(I:LongInt):String10;
FUNCTION  S_GetPath(CONST Path:STRING):STRING;
FUNCTION  StrToInt(S:String):Single;
FUNCTION  S_GetActualTime:String10;
PROCEDURE S_SetTi;
PROCEDURE S_FPS;
PROCEDURE S_Move32(Src, Dest:Pointer ;Count : Word);
PROCEDURE S_FillChar32(Dest:Pointer; Count, Value:Word);
function  Min(a, b : Integer) : Integer;
function Max(a, b : Integer) : Integer;
FUNCTION FileExists(FileName: STRING): Boolean;

IMPLEMENTATION

{*************************************************************************}
FUNCTION FileExists(FileName: STRING): Boolean;

VAR
     {IDENTYFIKATOR PLIKU}
     F: FILE;

BEGIN
 {$I-}

 {PODLACZ SIE DO PLIKU}
 Assign(F, FileName);

 {TYLKO DO ODCZYTU}
 FileMode := 0;

 {OTWORZ PLIK}
 Reset(F);

 {ZAMKNIJ}
 Close(F);

 {$I+}

 {JESLI NIE BYLO BLEDU PLIK ISTNIEJE}
 FileExists := (IOResult = 0) AND (FileName <> '');
END;

{*************************************************************************}


function Min(a, b : Integer) : Integer;
begin
  if (a > b) then
    Min := b
  else
    Min := a;
end;

function Max(a, b : Integer) : Integer;
begin
  if (a < b) then
    Max := b
  else
    Max := a;
end;


PROCEDURE S_Move32(Src, Dest:Pointer ;Count : Word); assembler;
ASM
  Mov  Cx, Count
  Mov  Dx, Cx
  And  Dx, 3
  Shr  Cx, 2

  Push Ds

  Lds  Si, Src
  Les  Di, Dest

  Cld
  Db   $F3,$66,$A5

  Mov  Cx, Dx
  Rep  MovSb

  Pop  Ds
END;

{*************************************************************************}

FUNCTION  IntToStr(I:LongInt):String10;
VAR S:String10;
BEGIN
  Str(I, S);
  IntToStr:=S;
END;
{*************************************************************************}
FUNCTION StrToInt(S:String):Single;
VAR I:Single;
    C:Integer;
BEGIN
  Val(S, I, C);
  StrToInt:=I;
END;

{*************************************************************************}

PROCEDURE S_FillChar32(Dest:Pointer;Count, Value:Word);ASSEMBLER;
ASM
  Mov Ax, Value
  Mov Cx, Ax
  Db  $66
  Shl Ax, 16
  Mov Ax, Cx

  Les Di, Dest
  Mov Cx, Count
  Mov Bx, Cx
  And Bx, 3
  Shr Cx, 2
  Cld

  Db  $F3, $66, $AB

  Mov Cx, Bx
  Cld
  Rep Stosb
END;

{*************************************************************************}

PROCEDURE S_SetTi;
BEGIN
  S_NewTi  := S_Ti;
  S_Frames := 0;
END;

{*************************************************************************}

FUNCTION S_GetTime:Longint;
VAR S_GTime:Longint;
BEGIN
  S_GTime:=S_Ti-S_NewTi;

  IF S_GTime<0 THEN
    BEGIN
      S_GTime:=S_GTime+$10000*24;
    END;

  S_GetTime:=S_GTime;
END;

{*************************************************************************}

FUNCTION S_ShowFPS(VAR Frames:Longint):Word;

VAR S_GTime:Longint;

BEGIN
  S_GTime:=S_Ti-S_NewTi;

  IF S_GTime<0 THEN
    BEGIN
      S_GTime:=S_GTime+$10000*24;
    END;


  IF S_GTime>=18 THEN
  S_SFPS:=Round(Frames*18.2/S_GTime);

  S_ShowFPS:=S_SFPS;

  IF S_GTime>=18 THEN
    BEGIN
      S_SetTi;
      Frames:=0;
    END;

END;
{*************************************************************************}

PROCEDURE S_FPS;
BEGIN
  Inc(S_Frames);
  IF (S_Ti - S_NewTi >= 18) THEN
  BEGIN
    WriteLn(S_Frames);
    S_SetTi;
  END;
END;

{*************************************************************************}
{ZWRACA SCIEZKE Z KTOREJ ZOSTAL URUCHOMIONY PROGRAM}
FUNCTION  S_GetPath(CONST Path:STRING):STRING;
VAR I:Byte;
BEGIN
  {NA POCZATEK NIE MA SCIEZKI}
  S_GetPath:='';

  {SPRAWDZA KIEDY WYSTAPIL ZNAK \ PRZED NAZWA PLIKU}
  FOR I:=BYTE(Path[0]) DOWNTO 1 DO

      {JESLI ZNAJDZIE}
      IF Path[I]='\' THEN
      BEGIN
        {TO CO PRZED tym ZNAKIEM BEDZIE SCIEZKA}
        S_GetPath:=Copy(Path, 1, I);

        {KONIEC FUNKCJI}
        Exit;
      END;
END;

{*************************************************************************}

FUNCTION  S_GetActualTime:String10;
VAR H, M, S, ss:Word;
    Ho, Mi     :STRING[2];
BEGIN
  GetTime(H, M, S, ss);

  IF H<10 THEN Ho:='0' ELSE Ho:='';
  IF M<10 THEN Mi:='0' ELSE Mi:='';

  Ho:=Ho+IntToStr(H);
  Mi:=Mi+IntToStr(M);

  S_GetActualTime:=Ho+':'+Mi;
END;

BEGIN
  S_NewFPSTi:=S_Ti;
END.