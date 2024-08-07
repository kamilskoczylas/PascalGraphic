{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                     MODUL :  DOORS10E                                 *}
{*     OSTATNIA AKTUALIZACJA :  09.01.2005                               *}
{*                                                                       *}
{*                   AUTORZY :  S.K. K.S.                                *}
{*                                                                       *}
{*     MODUL SLUZY DO GRAFIKI W TRYBIE 10Eh SYSTEMU Doors (R)            *}
{*                                                                       *}
{*************************************************************************}

UNIT DOORS10E;

{*************************************************************************}

INTERFACE

USES
    Doors, Standard, Graph10E, Doors_Ev, Fonts, MouseX,
    Types;

CONST

    DOORS_WKLESLY     =0;
    DOORS_WYPUKLY     =1;

    CAPTION_SIZE      =16;

VAR
    DefaultRectX : TRect;
    Poz          : TPoz;

    DOORS_BACKGROUND  :Word;
    DOORS_LIGHTBORDER :Word;
    DOORS_DARKBORDER  :Word;
    DOORS_CAPTION     :Word;
    DOORS_CAPTION2    :Word;
    DOORS_FONT        :Word;
    DOORS_TEXT        :Word;
    DOORS_LINK        :Word;
    DOORS_ALINK       :Word;
    DOORS_HLINK       :Word;



{*************************************************************************}
PROCEDURE D10_PrzytnijProstokat;
PROCEDURE D10_DrawAll(Buf:TEkran10Eh);
PROCEDURE D10_DrawList(Buf:TEkran10Eh; Lista:PObject; X, Y:Integer);
PROCEDURE D10_DrawObject(Buf:TEkran10Eh; Obj:PObject; AddX, AddY:Integer);
PROCEDURE D10_DrawCursor(Buf:TEkran10Eh; Picture:TPicture);

{*************************************************************************}
PROCEDURE D10_DrawBackground(Buf:TEkran10Eh; Alpha: Byte);
PROCEDURE D10_DrawBackground2(Buf:TEkran10Eh; Alpha: Byte;C1, C2:Word);
PROCEDURE D10_DrawBorder(Buf:TEkran10Eh; Typ:Byte; Alpha:Byte);
PROCEDURE D10_DrawSeparator(Buf:TEkran10Eh; Typ:Byte);
{*************************************************************************}
IMPLEMENTATION


{*************************************************************************}



PROCEDURE D10_DrawAll(Buf:TEkran10Eh);
BEGIN

  S_Move32(@EkranRect, @DefaultRectX, SizeOf(TRect));

  D10_DrawList(Buf, FirstObj, 0, 0);

  S_Move32(@EkranRect, @DefaultRectX, SizeOf(TRect));
END;
{*************************************************************************}
PROCEDURE D10_DrawList(Buf:TEkran10Eh; Lista:PObject; X, Y:Integer);
BEGIN

  {PRZYCINANIE PROSTOKATOW}
  S_Move32(@DefaultRect, @DefaultRectX, SizeOf(TRect));


  WHILE Assigned(Lista) DO
  BEGIN
    {NARYSUJ RODZICA}
    IF Lista^.Visible THEN
    BEGIN
      D10_DrawObject(Buf, Lista, X, Y);

      {NARYSUJ LISTE DZIECI}
      D10_DrawList(Buf, Lista^.Children, Lista^.Pos^.X+X, Lista^.Pos^.Y+Y);
    END;

    {KOLEJNY ELEMENT LISTY}
    Lista:=Lista^.Next;
  END;
END;
{*************************************************************************}
PROCEDURE D10_PrzytnijProstokat;
VAR
  X2, Y2 : Integer;
BEGIN
{  WITH (EkranRect)
  DO BEGIN
    WITH (DefaultRectX)
    DO BEGIN
      X2 := X+W-1;
      Y2 :=
    END;
  END}


  {(1) GDY GORNA KRAWEDZ JEST WYZEJ NIZ GORNA EKRANOWA}
  IF DefaultRectX.Y<EkranRect.Y THEN DefaultRectX.Y:=EkranRect.Y;

  {(2) GDY DOLNA KRAWEDZ JEST NIZEJ NIZ DOLNA EKRANOWA}
  IF DefaultRectX.Y+DefaultRectX.H>
     EkranRect.Y+EkranRect.H    THEN DefaultRectX.H:=((DefaultRectX.H+DefaultRectX.Y)-
                                                    (EkranRect.H+EkranRect.Y));

  {(3) GDY LEWA KRAWEDZ JEST PRZED LEWA EKRANOWA}
  IF DefaultRectX.X<EkranRect.X THEN DefaultRectX.X:=EkranRect.X;

  {(4) GDY PRAWA KRAWEDZ JEST WYZEJ NIZ PRAWA EKRANOWA}
  IF DefaultRectX.X+DefaultRectX.W>
     EkranRect.X+EkranRect.W    THEN DefaultRectX.W:=((DefaultRectX.W+DefaultRectX.X)-
                                                     (EkranRect.W+EkranRect.X));


END;
{*************************************************************************}
PROCEDURE D10_DrawObject(Buf:TEkran10Eh; Obj:PObject; AddX, AddY:Integer);
BEGIN
  IF (Obj=NIL) OR (Obj^.Pos=NIL) OR NOT (Obj^.Visible) THEN Exit;

  S_Move32(@DefaultRectX, @DefaultRect, SizeOf(TRect));
  S_Move32(Obj^.Pos, @Poz, SizeOf(TPoz));

  Poz.X:=Poz.X+AddX;
  Poz.Y:=Poz.Y+AddY;

  IF Assigned(DrawProc[Obj^.TypID]) THEN DrawProc[Obj^.TypID](Buf, Obj);

  {CASE  OF

    DOORS_FORM:D10_DrawForm(Buf, Obj);
    DOORS_BUTTON:D10_DrawButton(Buf, Obj);
    DOORS_EDIT:D10_DrawEdit(Buf, Obj);

  END;}

END;


{*************************************************************************}
PROCEDURE D10_DrawBackground(Buf:TEkran10Eh; Alpha: Byte);
VAR a, w  : Integer;
BEGIN
  w:=Poz.Width;

  IF Alpha=0 THEN
  BEGIN
    FOR a:=Poz.Y+1 TO Poz.Y-1+Poz.Height DO
      V_HLine(Buf, Poz.X+1, a, w-2, DOORS_BACKGROUND);
  END
    ELSE
    FOR a:=Poz.Y TO Poz.Y+Poz.Height DO
      V_HLineAlpha1(Buf, Poz.X, a, w, DOORS_BACKGROUND, Alpha);

END;
{*************************************************************************}
PROCEDURE D10_DrawBackground2(Buf:TEkran10Eh; Alpha: Byte;C1, C2:Word);
VAR a, w    : Integer;
    R, G, B : Byte;
    R2,G2,B2: Byte;

BEGIN
  w:=Poz.Width;

  V_ToRGB(C1, R, G, B);
  V_ToRGB(C2, R2, G2, B2);


  IF Alpha=0 THEN
  BEGIN
    FOR a:=Poz.Y+1 TO Poz.Y-1+Poz.Height DO
      V_HLine(Buf, Poz.X+1, a, w-2, V_RGB(R+Round((R2-R)/(Poz.Height-2)*(A-Poz.Y-1)),
                                        G+Round((G2-G)/(Poz.Height-2)*(A-Poz.Y-1)),
                                        B+Round((B2-B)/(Poz.Height-2)*(A-Poz.Y-1))));

  END
  ELSE
    FOR a:=Poz.Y TO Poz.Y+Poz.Height DO
      V_HLineAlpha1(Buf, Poz.X, a, w, V_RGB(R+Round((R2-R)/(Poz.Height+1)*(A-Poz.Y)),
                                        G+Round((G2-G)/(Poz.Height+1)*(A-Poz.Y)),
                                        B+Round((B2-B)/(Poz.Height+1)*(A-Poz.Y))), Alpha);


END;
{*************************************************************************}
PROCEDURE D10_DrawBorder(Buf:TEkran10Eh; Typ:Byte; Alpha:Byte);
VAR C1, C2 : Word;
BEGIN
  IF Alpha>0 THEN Exit;

  IF Typ=1 THEN
     BEGIN
       C1:=DOORS_LIGHTBORDER;
       C2:=DOORS_DARKBORDER;
     END ELSE
     BEGIN
       C2:=DOORS_LIGHTBORDER;
       C1:=DOORS_DARKBORDER;
     END;

  {GORA}
  V_HLine(Buf, Poz.X, Poz.Y, Poz.Width, C1);
  {DOL}
  V_HLine(Buf, Poz.X+1, Poz.Y+Poz.Height, Poz.Width-1, C2);
  {LEWO}
  V_VLine(Buf, Poz.X, Poz.Y+1, Poz.Height, C1);
  {PRAWO}
  V_VLine(Buf, Poz.X+Poz.Width-1, Poz.Y+1, Poz.Height-1, C2);
END;
{*************************************************************************}
PROCEDURE D10_DrawSeparator(Buf:TEkran10Eh; Typ:Byte);
VAR C1, C2 : Word;
BEGIN

  IF Typ=1 THEN
     BEGIN
       C1:=DOORS_LIGHTBORDER;
       C2:=DOORS_DARKBORDER;
     END ELSE
     BEGIN
       C2:=DOORS_LIGHTBORDER;
       C1:=DOORS_DARKBORDER;
     END;

  {GORA}
  V_HLine(Buf, Poz.X, Poz.Y+Poz.Height SHR 1, Poz.Width, C1);
  {DOL}
  V_HLine(Buf, Poz.X, Poz.Y+1+Poz.Height SHR 1, Poz.Width, C2);

END;

{*************************************************************************}
PROCEDURE D10_DrawCursor(Buf:TEkran10Eh; Picture:TPicture);
VAR X, Y:Integer;
BEGIN
  MouseWhereXY(X, Y);
  V_KopiujObraz(Buf, Picture, X, Y);
END;

BEGIN
  DOORS_BACKGROUND  :=V_RGB($88, $88, $88);
  DOORS_LIGHTBORDER :=V_RGB($BB, $BB, $BB);
  DOORS_DARKBORDER  :=V_RGB($44, $44, $44);
  DOORS_FONT        :=V_RGB($CC, $CC, $CC);
  DOORS_TEXT        :=V_RGB($FF, $FF, $FF);

  DOORS_CAPTION     :=V_RGB($00, $00, $FF);
  DOORS_CAPTION2    :=V_RGB($00, $00, $00);
  DOORS_ALINK       :=V_RGB($00, $FF, $00);
  DOORS_HLINK       :=V_RGB($FF, $FF, $00);
  DOORS_LINK        :=V_RGB($20, $20, $20);
END.