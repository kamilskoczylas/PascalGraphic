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
{*     Modul jest czescia systemu Doors, zawiera obsluge Formularzy      *}
{*                                                                       *}
{*                                                                       *}
{*     KamilSkoczylas@o2.pl                                              *}
{*                                                                       *}
{*************************************************************************}

UNIT Forms;

INTERFACE

{*************************************************************************}

USES
      Doors, Graph10E, Fonts, Standard, Errors;


TYPE

{*************************************************************************}


      {SZCZEGOLOWE PATRAMETRY OKNA}
      PFormParams   = ^TFormParams;
      TFormParams   = OBJECT

        {NAGLOWEK - NAPIS NA PASKU OKNA}
        Caption     : STRING;

        {JAKIE ZDJECIE MA BYC WSTAWIONE JAKO FORMA}
        Picture     : TPicture;

        {JAK BARDZO PRZEZROCZYSTA FORMA (0-WOGOLE; 1-DO POLOWY)}
        Alpha       : Byte;

        {CZY WOGOLE MA BYC PRZEZROCZYSTA}
        Transparent : Boolean;

        {KOLOR PASKA NAGLOWKA -GORNY}
        CaptCol     : Word;

        {KOLOR PASKA NAGLOWKA -DOLNY}
        CaptCol2    : Word;

        {KOLOR TLA OKNA}
        BackCol     : Word;

        {RODZAJ CZCIONKI}
        Font        : PFont;

        {PROCEDURA RYSUJACA NA OKNIE}
        Drawing     : TProcedure;

        {JESLI OKNO MOZE BYC TYLKO NA PIERWSZYM PLANIE}
        OnlyActive  : Boolean;

        {WSKAZNIK NA PRZYCISKI :}

        {ZAMYKANIA OKNA}
        CloseButton : PObject;

        {MAKSYMALIZACJI}
        MaxButton   : PObject;

        {MINIMALIZACJI}
        MinButton   : PObject;
      END;

{*************************************************************************}

FUNCTION D_CreateForm(Obj:PObject;Typ:Byte):Byte;
PROCEDURE D10_DrawForm(Buf:TEkran10Eh; Obj:PObject);FAR;

{*************************************************************************}

IMPLEMENTATION

USES Doors10E,   {PODSTAWOWE PROCEDURY RYSUJACE}
     Doors_EV,
     Buttons;    {OBSLUGA PRZYCISKOW (ZAMYKANIE, MAKSYMALIZAJCA, MINI)}

{*************************************************************************}
PROCEDURE D10_DrawForm(Buf:TEkran10Eh; Obj:PObject);

VAR Form : PFormParams;
    a    : Integer;
    PozX : TPoz;

BEGIN
   IF Obj^.Params=NIL THEN Exit;


   {Form JEST TERAZ PARAMETRAMI FORMY}
   Form:=Obj^.Params;

   IF Form^.OnlyActive AND (LastObj<>Obj) THEN
      BEGIN
        Obj^.Visible:=False;
        Exit;
      END;


   IF (Form^.Picture=NIL) OR (Form^.Picture^.BMP=NIL) THEN
   BEGIN

     S_Move32(@Poz, @PozX, SizeOf(TPoz));
     IF Form^.Alpha>0 THEN
     Poz.Height:=CAPTION_SIZE
     ELSE Poz.Height:=CAPTION_SIZE+1;

     DOORS_BACKGROUND:=Form^.CaptCol;

     {RYSOWANIE NAGLOWKA WIELOBARWNEGO CZY JEDNOLITEGO}
     IF (Form^.CaptCol=Form^.CaptCol2) THEN
       D10_DrawBackGround(Buf, Form^.Alpha) ELSE
       D10_DrawBackGround2(Buf, Form^.Alpha, Form^.CaptCol, Form^.CaptCol2);



     Poz.Height:=PozX.Height-CAPTION_SIZE;

     IF Form^.Alpha>0 THEN
     Poz.Y:=PozX.Y+CAPTION_SIZE+1 ELSE
     Poz.Y:=PozX.Y+CAPTION_SIZE;

     DOORS_BACKGROUND:=Form^.BackCol;
     D10_DrawBackGround(Buf, Form^.Alpha);

     Poz.Y:=PozX.Y;
     Poz.Height:=PozX.Height;


   END; {DO OBRAZKA}
   D10_DrawBorder(Buf, DOORS_WYPUKLY, Form^.Alpha);

   V_CenterText(Buf, Form^.Font, Poz.X-1+(Poz.Width SHR 1), Poz.Y+CAPTION_SIZE SHR 1-4,
                     Form^.Caption, DOORS_LIGHTBORDER, 8);

   IF Assigned(Form^.Drawing) THEN
               Form^.Drawing;



END;

{*************************************************************************}

PROCEDURE D_ResizeForm(Obj:PObject);FAR;
BEGIN


  IF NOT Assigned(Obj) THEN Exit;

  WITH Obj^ DO
  WITH PFormParams(Params)^ DO
  BEGIN

  IF Assigned(CloseButton) THEN

    BEGIN
      CloseButton^.Pos^.X:=Pos^.Width-MINI_BUTTON_SIZE-3;
      CloseButton^.Pos^.Y:=3;
    END;

  IF Assigned(MaxButton) THEN
    BEGIN
      MaxButton^.Pos^.X:=Pos^.Width-MINI_BUTTON_SIZE*2-6;
      MaxButton^.Pos^.Y:=3;
    END;

  IF Assigned(MinButton) THEN
    BEGIN
      MinButton^.Pos^.X:=Pos^.Width-MINI_BUTTON_SIZE*3-7;
      MinButton^.Pos^.Y:=3;
    END;

    END;
END;

{*************************************************************************}

FUNCTION D_CreateForm(Obj:PObject;Typ:Byte):Byte;
{*************************************************************************
 Tworzy z dowolnego obiektu przycisk i podstawia ustawienia domyslne
 *************************************************************************}
VAR Temp:PFormParams;
    TempChild        : PObject;

BEGIN
     D_CreateForm:=E_OK;


     IF MaxAvail<SizeOf(TFormParams)+SizeOf(TPoz) THEN
       BEGIN
         D_CreateForm:=E_PAMIEC;
         D_DeleteObject(Obj);
         Obj:=NIL;
         Exit;
       END;

     GetMem(Obj^.Params, SizeOf(TFormParams));
     New(Obj^.Pos);

     WITH Obj^ DO
     BEGIN
       Pos^.X:=40;
       Pos^.Y:=20;
       Pos^.Width:=240;
       Pos^.Height:=160;

       Temp:=Params;

       Temp^.Picture:=NIL;
       Temp^.Caption:='OKNO';
       Temp^.Alpha:=0;
       Temp^.Transparent:=FALSE;
       Temp^.OnlyActive:=False;
       Temp^.Font:=DefaultFont;



       Temp^.BackCol:=DOORS_BACKGROUND;
       Temp^.Drawing:=NIL;
       Temp^.CaptCol:=DOORS_CAPTION;
       Temp^.CaptCol2:=DOORS_CAPTION2;


       TypID:=DOORS_FORM;

       {DODATKOWE PRZYCISKI}

       IF (Typ AND 1=1) THEN
       BEGIN

       {ZAMYKANIE}

       D_CreateChild(Obj, TempChild);
       D_CreateButton(TempChild);
       Temp^.CloseButton:=TempChild;

       PButtonParams(TempChild^.Params)^.Text:='x';
       PButtonParams(TempChild^.Params)^.Font:=DefaultFont;

       TempChild^.Resize(Obj^.Pos^.Width-MINI_BUTTON_SIZE-2, 3, MINI_BUTTON_SIZE, MINI_BUTTON_SIZE);

       END ELSE Temp^.CloseButton:=NIL;


       IF (Typ>1) AND (Typ AND 1=1)THEN
       BEGIN

       {MAKSYMALIZACJA}
       D_CreateChild(Obj, TempChild);
       D_CreateButton(TempChild);
       Temp^.MaxButton:=TempChild;

       PButtonParams(TempChild^.Params)^.Text:='-';
       PButtonParams(TempChild^.Params)^.Font:=DefaultFont;

       TempChild^.Resize(Obj^.Pos^.Width-MINI_BUTTON_SIZE*2-6, 3, MINI_BUTTON_SIZE, MINI_BUTTON_SIZE);


       {MINIMALIZACJA}
       D_CreateChild(Obj, TempChild);
       D_CreateButton(TempChild);
       Temp^.MinButton:=TempChild;

       PButtonParams(TempChild^.Params)^.Text:='.';
       PButtonParams(TempChild^.Params)^.Font:=DefaultFont;

       TempChild^.Resize(Obj^.Pos^.Width-MINI_BUTTON_SIZE*3-8, 3, MINI_BUTTON_SIZE, MINI_BUTTON_SIZE);
       END ELSE
       BEGIN
         Temp^.MinButton:=NIL;
         Temp^.MaxButton:=NIL;
       END;




     END;

END;

{*************************************************************************}
FUNCTION D_FreeForm(Obj:PObject):Byte;FAR;

VAR But:PFormParams;
BEGIN
     D_FreeForm:=E_OK;

     IF (Obj=NIL) OR (Obj^.Params=NIL) OR (Obj^.TypID<>DOORS_FORM) THEN BEGIN D_FreeForm:=E_OBIEKT;Exit;END;

     But:=Obj^.Params;
     V_FreeImage(But^.Picture);

     FreeMem(Obj^.Params, SizeOf(TFormParams));
     Obj^.Params:=NIL;
     Dispose(Obj^.Pos);
     Obj^.Pos:=NIL;
END;
{*************************************************************************}

BEGIN
  {WSTAWIA DO TABLICY PROCEDURE RYSUJACA TEN OBIEKT}
  DrawProc[DOORS_FORM]:=D10_DrawForm;

  {PROCEDURA WYWOLYWANA AUTOMATYCZNIE PRZY ZMIANIE ROZMIARU TEGO OBIEKTU}
  ResizeProc[DOORS_FORM]:=D_ResizeForm;

  {FUNKCJA ZWALNIAJACA PAMIEC}
  FreeFunc[DOORS_FORM]:=D_FreeForm;
END.
