{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                     MODUL :  DOORS                                    *}
{*                   AUTORZY :  S.K. K.S.                                *}
{*                                                                       *}
{*                                                                       *}
{*     Wszelkie prawa autorskie zastrzezone, wykorzystywanie modulu      *}
{*     tylko za zgoda autorow, kontakt:                                  *}
{*                                                                       *}
{*     Modul jest czescia systemu Doors, zawiera obsluge Pol tekstowych  *}
{*                                                                       *}
{*                                                                       *}
{*     KamilSkoczylas@o2.pl                                              *}
{*                                                                       *}
{*************************************************************************}

UNIT Edits;

INTERFACE

{*************************************************************************}

USES
      Doors, Graph10E, Fonts, Standard, Errors;


TYPE
{*************************************************************************}

      {SZCZEGOLOWE PARAMETRY POLA TEKSTOWEGO}
      PEditParams   = ^TEditParams;
      TEditParams   = OBJECT

        {WSKAZNIK NA SIEBIE, NA CZESC GLOWNA -DEKLARACJE OBIEKTU}
        Obj         : PObject;

        {TEKST KTORY BEDZIE WIDOCZNY W POLU}
        Text        : STRING;

        {Z JAKIM INNA ZMIENNA BEDZIE SKOJARZONE POLE TEKSTOWE- AUTOZMIANA}
        AssignWith  : Pointer;

        {KOLOR TLA}
        BkColor     : Word;

        {KOLOR LITER}
        Color       : Word;

        {TYLKO WIELKIE LITERY}
        OnlyUpper   : Boolean;

        {CZCIONKA}
        Font        : PFont;

        {PRZEZROCZYSTOSC}
        Alpha       : Byte;

        {POZYCJA KURSORA KARETKI - NA KTORYM ZNAKU}
        Cursor      : Byte;

        {MAKSYMALNY ROZMIAR POLA TEKSTOWEGO}
        MaxLength   : Byte;

        {SZEROKOSC JEDNEJ LITERY W PIKSELACH}
        WLetter     : Byte;

        {WYSWIETLA OD TEJ LITERY}
        L1          : Byte;

        {PODAJE TEKST Z POLA}
        FUNCTION    GetActualText:STRING;

        {WSTAWIA ZNAK W POZYCJI KURSORA}
        PROCEDURE   Insert(Ch:Char);

        {USTAWIA KARETKE NA PODANYM ZNAKU}
        PROCEDURE   SetCursor(Poz:Byte);

        {USUWA ELEMENT ZA ZNAKIEM - WSYSA}
        PROCEDURE   Delete;

        {KASUJE ELEMENT PRZED ZNAKIEM}
        PROCEDURE   BackSpace;

        {USTAWIA POZYCJE KARETKI TAM GDZIE JEST KURSOR MYSZY}
        PROCEDURE   SetCursorFromMouse;

        {CZYSCI POLE TEKSTOWE}
        PROCEDURE   Clear;



      END;


{*************************************************************************}
PROCEDURE DodajZnak(Obj:PObject; LastKey:Byte);
PROCEDURE D10_DrawEdit(Buf:TEkran10Eh; Obj:PObject);FAR;
FUNCTION D_FreeEdit(Obj:PObject):Byte;FAR;
FUNCTION D_CreateEdit(Obj:PObject):Byte;
FUNCTION D_GetEditText(Obj:PObject):STRING;

{*************************************************************************}

{*************************************************************************}

IMPLEMENTATION

USES Doors10E,        {PODSTAWOWE PROCEDURY RYSUJACE}
     Doors_Ev,
     Keyb_x;

VAR  SpecKey:Word ABSOLUTE $40:$17;


{*************************************************************************}
FUNCTION D_GetEditText(Obj:PObject):STRING;
BEGIN
  IF Assigned(Obj) AND (Obj^.TypID=DOORS_EDIT) THEN
    D_GetEditText:=PEditParams(Obj^.Params)^.Text;
END;

FUNCTION D_CreateEdit(Obj:PObject):Byte;
{*************************************************************************
 Tworzy z dowolnego obiektu pole tekstowe i podstawia ustawienia domyslne
 *************************************************************************}
VAR Temp:PEditParams;

BEGIN
     D_CreateEdit:=E_OK;

     IF MaxAvail<SizeOf(TEditParams)+SizeOf(TPoz) THEN
       BEGIN
         D_CreateEdit:=E_PAMIEC;
         D_DeleteObject(Obj);
         Obj:=NIL;
         Exit;
       END;

     GetMem(Obj^.Params, SizeOf(TEditParams));
     New(Obj^.Pos);

     WITH Obj^ DO
     BEGIN
       Pos^.X:=0;
       Pos^.Y:=0;
       Pos^.Width:=40;
       Pos^.Height:=10;

       Temp:=Params;

       Temp^.Obj:=Obj;
       S_FillChar32(@Temp^.Text, SizeOf(Temp^.Text), 32);
       Temp^.Text:='Pole tekstowe';
       Temp^.BkColor:=DOORS_LIGHTBORDER;
       Temp^.Color:=DOORS_TEXT;
       Temp^.Font:=DefaultFont;
       Temp^.Alpha:=0;
       Temp^.AssignWith:=NIL;
       Temp^.OnlyUpper:=False;

       Temp^.MaxLength:=255;
       Temp^.Cursor:=1;
       Temp^.L1:=1;
       Temp^.WLetter:=8;



       TypID:=DOORS_EDIT;

     END;

END;


{*************************************************************************}

PROCEDURE D10_DrawEdit(Buf:TEkran10Eh; Obj:PObject);

VAR Edit : PEditParams;
    a    : Integer;
    PozX : TPoz;

BEGIN
   IF Obj^.Params=NIL THEN Exit;

   {Edit JEST TERAZ PARAMETRAMI POLA TEKSTOWEGO}
   Edit:=Obj^.Params;

   DOORS_BACKGROUND:=Edit^.BkColor;
   D10_DrawBackGround(Buf, Edit^.Alpha);

   D10_DrawBorder(Buf, DOORS_WKLESLY, Edit^.Alpha);

   V_WriteXY(Buf, Edit^.Font, Poz.X+2, Poz.Y+Poz.Height SHR 1-4,
                  Edit^.GetActualText, Edit^.Color, Edit^.WLetter);

   IF (Focused=Obj) AND DE_Migaj THEN
   V_VLine(Buf, Poz.X+2+(Edit^.Cursor-Edit^.L1)*Edit^.WLetter, Poz.Y+Poz.Height SHR 1-5, 12, $0);


END;


{*************************************************************************}
PROCEDURE DodajZnak(Obj:PObject; LastKey:Byte);
VAR Znak:CHAR;
BEGIN
 IF Obj^.TypID<>DOORS_EDIT THEN Exit;

  IF NOT (LastKey IN [1, 14, 15, 28, 29, 42, 54]) AND (LastKey<56)
     THEN

       BEGIN

         IF Key[VK_ALT] THEN Znak:=KeyAlt[LastKey] ELSE Znak:=KeyNorm[LastKey];
         IF Key[VK_SHIFT] THEN Znak:=KeyShift[LastKey];

         IF (SpecKey AND 64=64) THEN Znak:=UpCase(Znak);

         PEditParams(Obj^.Params)^.Insert(Znak);


       END

     {JEZELI JEST TO KLAWISZ FUNKCYJNY}
     ELSE


       CASE LastKey OF
         {KASUJE ZNAK ZA KURSOREM}
         83:PEditParams(Obj^.Params)^.Delete;
         {KASUJE ZNAK PRZED KURSOREM}
         14:PEditParams(Obj^.Params)^.BackSpace;

         VK_LEFT:PEditParams(Obj^.Params)^.SetCursor(PEditParams(Obj^.Params)^.Cursor-1);
         VK_RIGHT:PEditParams(Obj^.Params)^.SetCursor(PEditParams(Obj^.Params)^.Cursor+1);

         {HOME}
         71:PEditParams(Obj^.Params)^.SetCursor(1);
         {END}
         79:PEditParams(Obj^.Params)^.SetCursor(Byte(PEditParams(Obj^.Params)^.Text[0])+1);
         57:PEditParams(Obj^.Params)^.Insert(' ')



       END;



END;

{*************************************************************************}

FUNCTION D_FreeEdit(Obj:PObject):Byte;
VAR But:PEditParams;
BEGIN
     D_FreeEdit:=E_OK;

     IF (Obj=NIL) OR (Obj^.Params=NIL) OR (Obj^.TypID<>DOORS_EDIT) THEN BEGIN D_FreeEdit:=E_OBIEKT;Exit;END;

     But:=Obj^.Params;

     FreeMem(Obj^.Params, SizeOf(TEditParams));
     Obj^.Params:=NIL;
     Dispose(Obj^.Pos);
     Obj^.Pos:=NIL;
END;

{*************************************************************************}

PROCEDURE TEditParams.Clear;
BEGIN
  {CZYSCI POLE TEKSTOWE}
  Text:='';

  {USTAWIA KURSOR NA POCZATKU}
  SetCursor(1);

  {JESLI POLE TEKSTOWE JEST SKOJARZONE Z INNYM LANCUCHEM}
  {TO AUTOMATYCZNIE GO ZMIENIA}
  IF Assigned(AssignWith) THEN S_Move32(@Text, AssignWith, Byte(Text[0])+1);
END;


{*************************************************************************}
PROCEDURE TEditParams.SetCursorFromMouse;
BEGIN
  {USTAWIA POZYCJE KURSORA POBIERAJAC JA Z MYSZKI}
  SetCursor(L1-1+(Obj^.Events^.Mx-2-(WLetter SHR 1)) DIV WLetter);
END;

{*************************************************************************}
PROCEDURE TEditParams.SetCursor(Poz:Byte);
VAR Max  : Byte;

BEGIN
  IF (Poz<1) OR (Poz>=MaxLength) THEN Exit;
  IF Poz>Byte(Text[0])+1 THEN Poz:=Byte(Text[0])+1;

  {ILE LITER WYSWIETLANYCH}
  Max:=(Obj^.Pos^.Width-4) DIV WLetter;

  {JESLI ZMNIEJSZAJAC POZYCJE KURSORA O POLOWE TEKSTU ZMIESCIMY SIE }
  {I KURSOR ZOSTAL PRZESUNIETY PRZED WIDOCZNA POZYCJE 1 WYSWIETL. ZNAKU}
  {ZMNIEJSZ JEGO POZYCJE TAK ABY KURSOR ZNAJDOWAL SIE W POLOWIE}
  IF (1{Max{ SHR 1}<Poz) AND (Poz<=L1) THEN L1:=Poz-1{Max{ SHR 1} ELSE IF (Poz<=L1) THEN L1:=1;
  IF (Max{ SHR 1}<MaxLength-L1) AND (Poz>=L1+Max) THEN L1:=Poz-Max{ SHR 1} ELSE IF (Poz>=L1+Max) THEN L1:=MaxLength-Max;

  Cursor:=Poz;


END;

{*************************************************************************}
FUNCTION TEditParams.GetActualText:STRING;
VAR Max  : Byte;

BEGIN

  Max:=(Obj^.Pos^.Width-4) DIV WLetter;
  {IF (L1+Max>MaxLength) THEN Max:=MaxLength-L1;}
  GetActualText:=Copy(Text, L1, Max);
END;
{*************************************************************************}
PROCEDURE TEditParams.Insert(Ch:Char);
VAR a    : Byte;
    Max  : Byte;
BEGIN
  IF OnlyUpper THEN CH:=UPCase(Ch);
  IF (Byte(Text[0])>=MaxLength-2) THEN Exit;

  FOR a:=MaxLength DOWNTO Cursor+1 DO
    Text[a]:=Text[a-1];

  Text[Cursor]:=Ch;
  Inc(Byte(Text[0]));

  Inc(Cursor);

  SetCursor(Cursor);

  IF Assigned(AssignWith) THEN S_Move32(@Text, AssignWith, Byte(Text[0])+1);

END;
{*************************************************************************}
PROCEDURE TEditParams.Delete;
VAR a:Byte;
BEGIN
  IF (Cursor>Byte(Text[0])) THEN Exit;

  FOR a:=Cursor TO MaxLength-1 DO
    Text[a]:=Text[a+1];

  {DAJE SPACJE NA SAM KONIEC}
  Text[MaxLength]:=' ';

  Dec(BYTE(Text[0]));

  IF Assigned(AssignWith) THEN S_Move32(@Text, AssignWith, Byte(Text[0])+1);
END;
{*************************************************************************}
PROCEDURE TEditParams.BackSpace;
VAR a    : Byte;
    Max  : Byte;
BEGIN

  IF Cursor<=1 THEN Exit;

  FOR a:=Cursor TO MaxLength DO
    Text[a-1]:=Text[a];

  Dec(BYTE(Text[0]));
  Dec(Cursor);
  SetCursor(Cursor);

  IF Assigned(AssignWith) THEN S_Move32(@Text, AssignWith, Byte(Text[0])+1);
END;

{*************************************************************************}

BEGIN
  {WSTAWIA DO TABLICY PROCEDURE RYSUJACA TEN OBIEKT}
  DrawProc[DOORS_EDIT]:=D10_DrawEdit;

  {PROCEDURA WYWOLYWANA AUTOMATYCZNIE PRZY ZMIANIE ROZMIARU TEGO OBIEKTU}
  ResizeProc[DOORS_EDIT]:=NIL;

  {FUNKCJA ZWALNIAJACA PAMIEC}
  FreeFunc[DOORS_EDIT]:=D_FreeEdit;
END.
