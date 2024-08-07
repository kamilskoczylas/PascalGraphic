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
{*     Modul jest czescia systemu Doors, zawiera obsluge Przyciskow      *}
{*                                                                       *}
{*                                                                       *}
{*     KamilSkoczylas@o2.pl                                              *}
{*                                                                       *}
{*************************************************************************}

UNIT Buttons;

INTERFACE

{*************************************************************************}

USES
      Doors, Graph10E, Fonts, Standard, Errors;

      {TYPY PRZYCISKU :}
      {
        0: NORMALNY, Z OBRAMOWANIEM
        1: OBRAMOWANIE PO NAJECHANIU MYSZKA
      }

TYPE

{*************************************************************************}

      {SZCZEGOLOWE PARAMETRY PRZYCISKU}
      PButtonParams = ^TButtonParams;
      TButtonParams = OBJECT

        {TEKST NA PRZYCISKU}
        Text        : STRING;

        {ZDJECIE ZAMIAST PRZYCISKU}
        Picture     : TPicture;

        {KOLOR TLA}
        Color       : Word;
        FontColor   : Word;

        {TYP CZCIONKI}
        Font        : PFont;

        {STOPIEN PRZEZROCZYSTOSCI}
        Alpha       : Byte;

        {TYP PRZYCISKU}
        Typ         : Byte;

      END;


{*************************************************************************}
FUNCTION D_CreateButton(Obj:PObject):Byte;
FUNCTION D_FreeButton(Obj:PObject):Byte;FAR;
PROCEDURE D_SetButtonText(Obj:PObject;CONST Text:STRING);
PROCEDURE D10_DrawButton(Buf:TEkran10Eh; Obj:PObject);FAR;

{*************************************************************************}

IMPLEMENTATION

USES Doors10E,        {PODSTAWOWE PROCEDURY RYSUJACE}
     Doors_Ev;


{*************************************************************************}
FUNCTION D_CreateButton(Obj:PObject):Byte;
{*************************************************************************
 Tworzy z dowolnego obiektu przycisk i podstawia ustawienia domyslne
 *************************************************************************}
VAR Temp:PButtonParams;

BEGIN
     D_CreateButton:=E_OK;

     IF MaxAvail<SizeOf(TButtonParams)+SizeOf(TPoz) THEN
       BEGIN
         D_CreateButton:=E_PAMIEC;
         D_DeleteObject(Obj);
         Obj:=NIL;
         Exit;
       END;

     GetMem(Obj^.Params, SizeOf(TButtonParams));
     New(Obj^.Pos);

     WITH Obj^ DO
     BEGIN
       Pos^.X:=0;
       Pos^.Y:=0;
       Pos^.Width:=40;
       Pos^.Height:=10;

       Temp:=Params;

       Temp^.Picture:=NIL;
       Temp^.Text:='OK';
       Temp^.Color:=DOORS_BACKGROUND;
       Temp^.FontColor:=DOORS_FONT;
       Temp^.Font:=DefaultFont;
       Temp^.Alpha:=0;

       {NORMALNY PRZYCISK}
       Temp^.Typ:=0;


       TypID:=DOORS_BUTTON;

     END;

END;

{*************************************************************************}
FUNCTION D_FreeButton(Obj:PObject):Byte;

VAR But:PButtonParams;
BEGIN
     D_FreeButton:=E_OK;

     IF (Obj=NIL) OR (Obj^.Params=NIL) OR (Obj^.TypID<>DOORS_BUTTON) THEN
       BEGIN
         D_FreeButton:=E_OBIEKT;
         Exit;
       END;

     But:=Obj^.Params;
     V_FreeImage(But^.Picture);

     FreeMem(Obj^.Params, SizeOf(TButtonParams));
     Obj^.Params:=NIL;
     Dispose(Obj^.Pos);
     Obj^.Pos:=NIL;
END;


{*************************************************************************}
PROCEDURE D_SetButtonText(Obj:PObject;CONST Text:STRING);
BEGIN

  {GDY ISTNIEJE TAKI OBIEKT I JEST PRZYCISKIEM}
  IF Assigned(Obj) AND (Obj^.TypID=DOORS_BUTTON) AND Assigned(Obj^.Params) THEN

  {ZMIENIA NAZWE NA PRZYCISKU}
  S_Move32(@Text, @(PButtonParams(Obj^.Params)^.Text), Byte(Text[0])+1);
END;


{*************************************************************************}


{*************************************************************************}
PROCEDURE D10_DrawButton(Buf:TEkran10Eh; Obj:PObject);

VAR Button : PButtonParams;
    a      : Integer;

BEGIN
  IF NOT Assigned(Obj) OR NOT Assigned(Obj^.Params) THEN Exit;


  Button:=Obj^.Params;
  DOORS_FONT:=Button^.FontColor;

  IF (Button^.Typ=1) AND (Obj^.Events^.Ev[ON_MOUSE_ON]) THEN
  BEGIN
    IF Obj^.Events^.Ev[ON_MOUSE_DOWN] THEN
    D10_DrawBorder(Buf, DOORS_WKLESLY, Button^.Alpha) ELSE
    D10_DrawBorder(Buf, DOORS_WYPUKLY, Button^.Alpha);
  END;

  IF (Button^.Picture=NIL) OR (Button^.Picture^.BMP=NIL) THEN
    BEGIN
      DOORS_BACKGROUND:=Button^.Color;
      D10_DrawBackGround(Buf, Button^.Alpha);

      IF Obj^.Events^.Ev[ON_MOUSE_DOWN] THEN
      BEGIN
        D10_DrawBorder(Buf, DOORS_WKLESLY, Button^.Alpha);

        V_CenterText(Buf, Button^.Font, Poz.X+(Poz.Width SHR 1), Poz.Y-3+(Poz.Height SHR 1),
                     Button^.Text,DOORS_DARKBORDER, 8);
        V_CenterText(Buf, Button^.Font, Poz.X+1+(Poz.Width SHR 1), Poz.Y-3+(Poz.Height SHR 1),
                     Button^.Text,DOORS_FONT, 8);
      END ELSE
      BEGIN
        D10_DrawBorder(Buf, DOORS_WYPUKLY, Button^.Alpha);

        V_CenterText(Buf, Button^.Font, Poz.X-1+(Poz.Width SHR 1), Poz.Y-4+(Poz.Height SHR 1),
                     Button^.Text,DOORS_DARKBORDER, 8);
        V_CenterText(Buf, Button^.Font, Poz.X+(Poz.Width SHR 1), Poz.Y-4+(Poz.Height SHR 1),
                     Button^.Text,DOORS_FONT, 8)
      END;
    END ELSE
    BEGIN
      IF Obj^.Events^.Ev[ON_MOUSE_DOWN] THEN
      V_KopiujObraz(Buf, Button^.Picture, Poz.X+1+(Poz.Width SHR 1)-(Button^.Picture^.W SHR 1),
                                          (Poz.Height SHR 1)-(Button^.Picture^.H SHR 1)+Poz.Y+1) ELSE

      V_KopiujObraz(Buf, Button^.Picture, Poz.X+(Poz.Width SHR 1)-(Button^.Picture^.W SHR 1),
                                          (Poz.Height SHR 1)-(Button^.Picture^.H SHR 1)+Poz.Y);

    END;
END;


{*************************************************************************}

BEGIN
  {WSTAWIA DO TABLICY PROCEDURE RYSUJACA TEN OBIEKT}
  DrawProc[DOORS_BUTTON]:=D10_DrawButton;

  {PROCEDURA WYWOLYWANA AUTOMATYCZNIE PRZY ZMIANIE ROZMIARU TEGO OBIEKTU}
  ResizeProc[DOORS_BUTTON]:=NIL;

  {FUNKCJA ZWALNIAJACA PAMIEC}
  FreeFunc[DOORS_BUTTON]:=D_FreeButton;
END.
