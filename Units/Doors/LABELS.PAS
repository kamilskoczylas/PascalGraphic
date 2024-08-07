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
{*     Modul jest czescia systemu Doors, zawiera obsluge Naglowkow       *}
{*                                                                       *}
{*                                                                       *}
{*     KamilSkoczylas@o2.pl                                              *}
{*                                                                       *}
{*************************************************************************}

UNIT Labels;

INTERFACE

{*************************************************************************}

USES
      Doors, Graph10E, Fonts, Standard, Errors;

      {

       ALIGN

         1- OD LEWEJ
         2- WYROWNANE


      }



TYPE

{*************************************************************************}

      {SZCZEGOLOWE PARAMETRY IKONY}
      PLabelParams   = ^TLabelParams;
      TLabelParams   = OBJECT

        {TEKST POD IKONA}
        Text        : STRING;

        {KOLORY TEKSTU - JAK W HTML}
        ALink       : Word;
        Link        : Word;
        HLink       : Word;

        {WCIECIE}
        Tab         : Byte;

        {STYL WYROWNANIA}
        Align       : Byte;

        {PODKRESLENIE}
        BkCol       :Word;
        BkCol2      :Word;

        {STYL LABEL'a}
        Style       : Byte;

        {TYP CZCIONKI}
        Font        : PFont;

        {STOPIEN PRZEZROCZYSTOSCI}
        Alpha       : Byte;

      END;


{*************************************************************************}
FUNCTION D_CreateLabel(Obj:PObject):Byte;
FUNCTION D_FreeLabel(Obj:PObject):Byte;FAR;
PROCEDURE D_SetLabelText(Obj:PObject;CONST Text:STRING);
PROCEDURE D10_DrawLabel(Buf:TEkran10Eh; Obj:PObject);FAR;

{*************************************************************************}

IMPLEMENTATION

USES Doors10E,        {PODSTAWOWE PROCEDURY RYSUJACE}
     Doors_Ev;


{*************************************************************************}
FUNCTION D_CreateLabel(Obj:PObject):Byte;
{*************************************************************************
 Tworzy z dowolnego obiektu przycisk i podstawia ustawienia domyslne
 *************************************************************************}
VAR Temp:PLabelParams;

BEGIN
     D_CreateLabel:=E_OK;

     IF MaxAvail<SizeOf(TLabelParams)+SizeOf(TPoz) THEN
       BEGIN
         D_CreateLabel:=E_PAMIEC;
         D_DeleteObject(Obj);
         Obj:=NIL;
         Exit;
       END;

     GetMem(Obj^.Params, SizeOf(TLabelParams));
     New(Obj^.Pos);

     WITH Obj^ DO
     BEGIN
       Pos^.X:=0;
       Pos^.Y:=0;
       Pos^.Width:=40;
       Pos^.Height:=10;

       Temp:=Params;

       Temp^.ALink:=DOORS_ALINK;
       Temp^.HLink:=DOORS_HLINK;
       Temp^.Link:= DOORS_LINK;

       Temp^.Align:=1;
       Temp^.Style:=1;
       Temp^.Tab:=0;
       Temp^.BkCol:=DOORS_CAPTION;
       Temp^.BkCol2:=DOORS_CAPTION2;

       Temp^.Text:='OK';
       Temp^.Font:=DefaultFont;
       Temp^.Alpha:=0;


       TypID:=DOORS_Label;

     END;

END;

{*************************************************************************}
FUNCTION D_FreeLabel(Obj:PObject):Byte;

VAR But:PLabelParams;
BEGIN
     D_FreeLabel:=E_OK;

     IF (Obj=NIL) OR (Obj^.Params=NIL) OR (Obj^.TypID<>DOORS_Label) THEN BEGIN D_FreeLabel:=E_OBIEKT;Exit;END;

     But:=Obj^.Params;

     FreeMem(Obj^.Params, SizeOf(TLabelParams));
     Obj^.Params:=NIL;
     Dispose(Obj^.Pos);
     Obj^.Pos:=NIL;
END;


{*************************************************************************}
PROCEDURE D_SetLabelText(Obj:PObject;CONST Text:STRING);
BEGIN

  {GDY ISTNIEJE TAKI OBIEKT I JEST PRZYCISKIEM}
  IF Assigned(Obj) AND (Obj^.TypID=DOORS_Label) AND Assigned(Obj^.Params) THEN

  {ZMIENIA NAZWE NA PRZYCISKU}
  S_Move32(@Text, @(PLabelParams(Obj^.Params)^.Text), Byte(Text[0])+1);
END;


{*************************************************************************}
PROCEDURE D10_DrawLabel(Buf:TEkran10Eh; Obj:PObject);

VAR XLabel : PLabelParams;
    a      : Integer;

BEGIN
  XLabel:=Obj^.Params;

  IF XLabel^.Text='-' THEN
    BEGIN
     D10_DrawSeparator(Buf, 2);
     Exit;
    END;


  IF XLabel^.Style<>3 THEN
  BEGIN

  IF NOT Obj^.Events^.Ev[ON_MOUSE_DOWN] THEN
  BEGIN
    IF NOT Obj^.Events^.Ev[ON_MOUSE_ON] THEN
    DOORS_FONT:=XLabel^.Link ELSE

    BEGIN
      {KOLOR CZCIONKI GDY KURSOR JEST NAD MYSZKA}
      DOORS_FONT:=XLabel^.HLink;

      {JESLI MA BYC PODKRESLENIE ETYKIETY}
      IF XLabel^.Style=1 THEN
        D10_DrawBackGround2(Buf, XLabel^.Alpha, XLabel^.BkCol, XLabel^.BkCol2);
    END;

  END
  ELSE
     DOORS_FONT:=XLabel^.ALink;

  END ELSE DOORS_FONT:=XLabel^.Link;

      IF XLabel^.Align=1 THEN
      V_WriteXY(Buf, XLabel^.Font, XLabel^.Tab+Poz.X+1, Poz.Y-3+(Poz.Height SHR 1),
                     XLabel^.Text, DOORS_FONT, 8);

      IF XLabel^.Align=2 THEN
      V_CenterText(Buf, XLabel^.Font, XLabel^.Tab+Poz.X+(Poz.Width SHR 1), Poz.Y-3+(Poz.Height SHR 1),
                     XLabel^.Text, DOORS_FONT, 8);

END;


{*************************************************************************}

BEGIN
  {WSTAWIA DO TABLICY PROCEDURE RYSUJACA TEN OBIEKT}
  DrawProc[DOORS_Label]:=D10_DrawLabel;

  {PROCEDURA WYWOLYWANA AUTOMATYCZNIE PRZY ZMIANIE ROZMIARU TEGO OBIEKTU}
  ResizeProc[DOORS_Label]:=NIL;

  {FUNKCJA ZWALNIAJACA PAMIEC}
  FreeFunc[DOORS_Label]:=D_FreeLabel;
END.
