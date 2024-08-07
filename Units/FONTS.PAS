UNIT FONTS;

INTERFACE

USES Types, Errors, Standard;

TYPE
    PFont=^TFont;

    TWzor=ARRAY[1..255, 0..7] OF Byte;
    PWzor=^TWzor;

    TTabKon=ARRAY[1..255] OF Byte;
    PTabKon=^TTabKon;

    TTabAscii=ARRAY[0..255] OF Byte;
    PTabAscii=^TTabKon;

    TFontFile=RECORD
      FileType      :ARRAY [1..4] OF CHAR;
      MaxL          :Byte;
    END;

    TFont=RECORD
      MaxL          :Byte;
      Wzor          :PWzor;
      TabKon        :PTabKon;
      TabAscii      :PTabAscii;
    END;

VAR

    DefaultFont:PFont;



FUNCTION F_LoadFont(Font:PFont; CONST Fn:STRING):Byte;
FUNCTION F_SaveFont(Font:PFont; CONST Fn:STRING):Byte;
FUNCTION F_MakeAsciiTab(Font:PFont):Byte;

PROCEDURE F_NewFont(VAR Font:PFont);
PROCEDURE F_FreeFont(VAR Font:PFont);


IMPLEMENTATION

PROCEDURE F_NewFont(VAR Font:PFont);
BEGIN
  New(Font);

  Font^.MaxL:=0;
  Font^.Wzor  :=NIL;
  Font^.TabKon:=NIL;
  Font^.TabAscii:=NIL;
END;

PROCEDURE F_FreeFont(VAR Font:PFont);
BEGIN
  IF Font=NIL THEN Exit;
  IF Font^.Wzor  <>NIL THEN FreeMem(Font^.Wzor, Font^.MaxL SHL 3);
  IF Font^.TabKon<>NIL THEN FreeMem(Font^.TabKon, Font^.MaxL);
  IF Font^.TabAscii<>NIL THEN FreeMem(Font^.TabAscii, SizeOf(TTabAscii));
  Dispose(Font);
  Font:=NIL;
END;

FUNCTION F_MakeAsciiTab(Font:PFont):Byte;
VAR A:Byte;
BEGIN
  F_MakeAsciiTab:=E_OBIEKT;

  IF Font=NIL THEN Exit;
  IF Font^.TabAscii=NIL THEN GetMem(Font^.TabAscii, SizeOf(TTabAscii));

  S_FillChar32(Font^.TabAscii, SizeOf(TTabAscii), 0);

  FOR A:=1 TO Font^.MaxL DO
      Font^.TabAscii^[Font^.TabKon^[A]]:=A;

  F_MakeAsciiTab:=E_OK;

END;


FUNCTION F_LoadFont(Font:PFont; CONST Fn:STRING):Byte;
VAR F:File;
    Temp:TFontFile;

BEGIN
  F_LoadFont:=E_PLIK;

  IF Font=NIL THEN Exit;

  Assign(F, Fn);
  {$I-}
  Reset(F, 1);
  {$I+}

  F_LoadFont:=E_PLIK;
  IF IOResult<>0 THEN Exit;

  F_LoadFont:=E_ZLY_FORMAT;
  IF FileSize(F)<SizeOf(TFontFile) THEN Exit;

  BlockRead(F, Temp, SizeOf(TFontFile));
  Font^.MaxL:=Temp.MaxL;


  IF (Temp.FileType<>'Font') OR
     (Temp.MaxL SHL 3+Temp.MaxL+SizeOf(TFontFile)<>FileSize(F)) OR
     ((MaxAvail<Temp.MaxL SHL 3+Temp.MaxL)
     AND NOT ((Font^.Wzor=NIL) OR (Font^.TabKon=NIL)))
     THEN
       BEGIN
         IF ((MaxAvail<Temp.MaxL SHL 3+Temp.MaxL)
         AND NOT ((Font^.Wzor=NIL) OR (Font^.TabKon=NIL)))
             THEN F_LoadFont:=E_PAMIEC
             ELSE F_LoadFont:=E_ZLY_FORMAT;

         Close(F);
         Exit;
       END;

  IF (Font^.Wzor=NIL) OR (Font^.TabKon=NIL)
  THEN
    BEGIN
      GetMem(Font^.Wzor, Temp.MaxL SHL 3);
      GetMem(Font^.TabKon, Temp.MaxL);
    END;


  BlockRead(F, Font^.Wzor^,   Temp.MaxL SHL 3);
  BlockRead(F, Font^.TabKon^, Temp.MaxL);

  F_MakeAsciiTab(Font);

  Close(F);
  F_LoadFont:=E_OK;
  DefaultFont:=Font;
END;

FUNCTION F_SaveFont(Font:PFont; CONST Fn:STRING):Byte;
VAR F:File;
    Temp:TFontFile;

BEGIN

  IF Font=NIL THEN Exit;

  Assign(F, Fn);
  {$I-}
  Rewrite(F, 1);
  {$I+}
  IF IOResult<>0 THEN Exit;

  Temp.FileType:='Font';
  Temp.MaxL:=Font^.MaxL;

  BlockWrite(F, Temp, SizeOf(TFontFile));

  BlockWrite(F, Font^.Wzor^,   Temp.MaxL SHL 3);
  BlockWrite(F, Font^.TabKon^, Temp.MaxL);


  Close(F);
  F_SaveFont:=E_OK;

END;


END.