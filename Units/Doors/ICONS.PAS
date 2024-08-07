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
{*     Modul jest czescia systemu Doors, zawiera obsluge Ikon            *}
{*                                                                       *}
{*                                                                       *}
{*     KamilSkoczylas@o2.pl                                              *}
{*                                                                       *}
{*************************************************************************}

UNIT Icons;

INTERFACE

{*************************************************************************}

USES
      Doors, Graph10E, Fonts, Standard, Errors;



TYPE

{*************************************************************************}

      {SZCZEGOLOWE PARAMETRY IKONY}
      PIconParams   = ^TIconParams;
      TIconParams   = OBJECT

        {TEKST POD IKONA}
        Text        : STRING;

        {ZDJECIE IKONY}
        Picture     : TPicture;

        {KOLOR CZCIONKI}
        Color       : Word;

        {TYP CZCIONKI}
        Font        : PFont;

        {STOPIEN PRZEZROCZYSTOSCI}
        Alpha       : Byte;

      END;


{*************************************************************************}
FUNCTION D_CreateIcon(Obj:PObject):Byte;
FUNCTION D_FreeIcon(Obj:PObject):Byte;FAR;
PROCEDURE D_SetIconText(Obj:PObject;CONST Text:STRING);
PROCEDURE D10_DrawIcon(Buf:TEkran10Eh; Obj:PObject);FAR;

{*************************************************************************}

IMPLEMENTATION

USES Doors10E,        {PODSTAWOWE PROCEDURY RYSUJACE}
     Doors_Ev;


{*************************************************************************}
FUNCTION D_CreateIcon(Obj:PObject):Byte;
{*************************************************************************
 Tworzy z dowolnego obiektu przycisk i podstawia ustawienia domyslne
 *************************************************************************}
VAR Temp:PIconParams;

BEGIN
     D_CreateIcon:=E_OK;

     IF MaxAvail<SizeOf(TIconParams)+SizeOf(TPoz) THEN
       BEGIN
         D_CreateIcon:=E_PAMIEC;
         D_DeleteObject(Obj);
         Obj:=NIL;
         Exit;
       END;

     GetMem(Obj^.Params, SizeOf(TIconParams));
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
       Temp^.Font:=DefaultFont;
       Temp^.Alpha:=0;
       Temp^.Color:=DOORS_FONT;

       TypID:=DOORS_Icon;

     END;

END;

{*************************************************************************}
FUNCTION D_FreeIcon(Obj:PObject):Byte;

VAR But:PIconParams;
BEGIN
     D_FreeIcon:=E_OK;

     IF (Obj=NIL) OR (Obj^.Params=NIL) OR (Obj^.TypID<>DOORS_Icon) THEN BEGIN D_FreeIcon:=E_OBIEKT;Exit;END;

     But:=Obj^.Params;
     V_FreeImage(But^.Picture);

     FreeMem(Obj^.Params, SizeOf(TIconParams));
     Obj^.Params:=NIL;
     Dispose(Obj^.Pos);
     Obj^.Pos:=NIL;
END;


{*************************************************************************}
PROCEDURE D_SetIconText(Obj:PObject;CONST Text:STRING);
BEGIN

  {GDY ISTNIEJE TAKI OBIEKT I JEST PRZYCISKIEM}
  IF Assigned(Obj) AND (Obj^.TypID=DOORS_ICON) AND Assigned(Obj^.Params) THEN

  {ZMIENIA NAZWE NA PRZYCISKU}
  S_Move32(@Text, @(PIconParams(Obj^.Params)^.Text), Byte(Text[0])+1);
END;


{*************************************************************************}


{*************************************************************************}
PROCEDURE D10_DrawIcon(Buf:TEkran10Eh; Obj:PObject);

VAR Icon : PIconParams;
    a      : Integer;

BEGIN
  Icon:=Obj^.Params;
  DOORS_FONT:=Icon^.Color;

  IF (Icon^.Picture=NIL) OR (Icon^.Picture^.BMP=NIL) THEN
    BEGIN
      D10_DrawBackGround(Buf, Icon^.Alpha);

    END ELSE
    BEGIN

      IF Obj^.Events^.Ev[ON_MOUSE_DOWN] THEN
      V_KopiujObraz(Buf, Icon^.Picture, Poz.X+1, Poz.Y+1) ELSE
      V_KopiujObraz(Buf, Icon^.Picture, Poz.X, Poz.Y);

    END;


    IF NOT Obj^.Events^.Ev[ON_MOUSE_DOWN] THEN
    BEGIN
      V_CenterText(Buf, Icon^.Font, Poz.X-1+(Poz.Width SHR 1), Poz.Y+1+(Poz.Height),
                     Icon^.Text,DOORS_DARKBORDER, 8);
      V_CenterText(Buf, Icon^.Font, Poz.X+(Poz.Width SHR 1), Poz.Y+1+(Poz.Height),
                     Icon^.Text,DOORS_FONT, 8)
    END ELSE
    BEGIN
      V_CenterText(Buf, Icon^.Font, Poz.X+(Poz.Width SHR 1), Poz.Y+2+(Poz.Height),
                     Icon^.Text,DOORS_DARKBORDER, 8);
      V_CenterText(Buf, Icon^.Font, Poz.X+1+(Poz.Width SHR 1), Poz.Y+2+(Poz.Height),
                     Icon^.Text,DOORS_FONT, 8)

    END;

END;


{*************************************************************************}

BEGIN
  {WSTAWIA DO TABLICY PROCEDURE RYSUJACA TEN OBIEKT}
  DrawProc[DOORS_ICON]:=D10_DrawIcon;

  {PROCEDURA WYWOLYWANA AUTOMATYCZNIE PRZY ZMIANIE ROZMIARU TEGO OBIEKTU}
  ResizeProc[DOORS_ICON]:=NIL;

  {FUNKCJA ZWALNIAJACA PAMIEC}
  FreeFunc[DOORS_ICON]:=D_FreeIcon;
END.
