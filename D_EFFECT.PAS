{$N+}{$G+}
{***********************************************************************}
{*                                                                     *}
{*           PODSTAWOWE EFEKTY DO PRACY DYPLOMOWEJ -DEMO_TP            *}
{*                                                                     *}
{***********************************************************************}

UNIT D_Effect;


INTERFACE
USES
     Graph10E, D_Types;


{***********************************************************************}

CONST

{***********************************************************************}
    {ILOSC GWIAZD}
    MaxStars=40;

    {ILOSC RAMION}
    MaxArms=8;

    {MAKSYMALNE ODCHYLENIE GWIAZD W GALAKTYCE OD NORMY}
    MaxAmpX=0;
    MaxAmpY=0;
    MaxAmpZ=0;

    AddY   =40;


    {MAKSYMALNA ODLEGLOSC WYSWIETLANYCH GWIAZD}
    MaxDistans=1000;
    Odl=255;

    MaxSpr  = 140;



{***********************************************************************}

VAR  {PRZYBLIZENIE}
     Dz                : Integer;

FUNCTION GetBufStars(nr:Byte):PStar;
PROCEDURE FreeStarsBuf(VAR Buf:PStar; Nr:Byte);
PROCEDURE RenderStars(Buf:TEkran10Eh; First:PStar; nr:Byte);
PROCEDURE ShowAnimations;
PROCEDURE Pomoc;
PROCEDURE Labirynth;

{***********************************************************************}

IMPLEMENTATION
USES Keyb_X,
     Standard,
     D_InOut,
     Fonts,
     G3d,
     MouseX,
     Doors10E;

{***********************************************************************}


PROCEDURE D_Move32(VAR Src;VAR Dest;Count, Offs: Word); ASSEMBLER;
ASM
  Mov  Cx, Count
  Mov  Dx, Cx
  And  Dx, 3
  Shr  Cx, 2

  Push Ds

  Lds  Si, Src
  Les  Di, Dest

  Add  Di, Offs

  Cld
  Db   $F3,$66,$A5

  Mov  Cx, Dx
  Rep  MovSb

  Pop  Ds
END;



FUNCTION GetBufStars(nr:Byte):PStar;
VAR
     Temp       : PStar;
     i, j       : Integer;
BEGIN

  CASE nr OF

  {POBIERANIE PAMIECI DLA RUCHOMYCH GWIAZD WGLAB}
  1:

  BEGIN

  {W RAZIE BRAKU PAMIECI}
  IF MaxAvail<(MaxStars*SizeOf(TStar)) THEN
    BEGIN

      {NIE BEDZIE GWIAZD}
      GetBufStars:=NIL;

      {WYCHODZI}
      Exit;
    END;

  {DEKLARUJE PAMIEC DLA GWIAZD}
  GetMem(Temp, MaxStars*SizeOf(TStar));

  {ZWRACA ADRES POCZATKU GWIAZD}
  GetBufStars:=Temp;

  {LOSUJE POZYCJE GWIAZD}
  FOR i:=1 TO MaxStars DO
  BEGIN
    WITH Temp^ DO
    BEGIN

      X:=Random(MaxDistans);
      Y:=Random(MaxDistans);
      Z:=Random(MaxDistans)+10;

    END;
    Inc(Temp);
  END;

  END;

  2:
  BEGIN
    {W RAZIE BRAKU PAMIECI}
    IF MaxAvail<(MaxStars*SizeOf(TStar)*MaxArms) THEN
      BEGIN

        {NIE BEDZIE GWIAZD}
        GetBufStars:=NIL;

        {WYCHODZI}
        Exit;
      END;

    {DEKLARUJE PAMIEC DLA GWIAZD}
    GetMem(Temp, MaxStars*SizeOf(TStar)*MaxArms);

    {ZWRACA ADRES POCZATKU GWIAZD}
    GetBufStars:=Temp;

    {LOSUJE POZYCJE GWIAZD}
    FOR j:=1 TO MaxArms DO
    FOR i:=1 TO MaxStars DO
    BEGIN
      WITH Temp^ DO
      BEGIN

        X:=Random(MaxAmpX)-Random(MaxAmpX)+Round(Cos((j/MaxArms+i/MaxStars/4)*pi*2)*i*2);
        Y:=Random(MaxAmpY)-Random(MaxAmpY)-AddY;
        Z:=Random(MaxAmpZ)-Random(MaxAmpZ)+MaxDistans SHR 2+Round(Sin((j/MaxArms+i/MaxStars/4)*pi*2)*i*2);

      END;
      Inc(Temp);
    END;
  END;
  END;
END;

PROCEDURE FreeStarsBuf(VAR Buf:PStar; Nr:Byte);
BEGIN

  {JESLI NIE MA CO ZWALNIAC}
  IF NOT Assigned(Buf) THEN Exit;

  {ZWALNIA PAMIEC}
  CASE nr OF
    1: FreeMem(Buf, MaxStars*SizeOf(TStar));
    2: FreeMem(Buf, MaxStars*SizeOf(TStar)*MaxArms);
  END;

  {ZAZNACZA ZE JUZ NIC NIE MA}
  Buf:=NIL;
END;

PROCEDURE RenderStars(Buf:TEkran10Eh;First:PStar; nr:Byte);
VAR
     i, j : Integer;
     x2,
     y2   : Integer;
     col  : Byte;
BEGIN

  CASE nr OF
  1:

  FOR i:=1 TO MaxStars DO
  BEGIN
    WITH First^ DO
    BEGIN

      Dec(Z, 4);

      Col:=Round((MaxDistans-Z)/MaxDistans*255);
      x2:=(V_MaxEX SHR 1)+Round(X*Odl/Z);
      y2:=(V_MaxEY SHR 1)-Round(Y*Odl/Z);
      V_Pix(Buf, X2, Y2, V_RGB(col, col, col));

      IF (Z<5) THEN
        BEGIN
          X:=Random(MaxDistans);
          Y:=Random(MaxDistans);
          Z:=MaxDistans;
        END;
    END;
    Inc(First);
  END;

  2:
  FOR j:=1 TO MaxArms DO
  FOR i:=1 TO MaxStars DO
  BEGIN

    WITH First^ DO
    BEGIN
      {Dec(Z, Dz);}
      Col:=Round((MaxDistans-Z)/MaxDistans*255);
      x2:=(V_MaxEX SHR 1)+Round(X*Odl/Z);
      y2:=(V_MaxEY SHR 1)-Round(Y*Odl/Z);
      V_Pix(Buf, X2, Y2, V_RGB(col, col, col));
    END;
    Inc(First);
  END;
  END; {CASE'a}

END;

PROCEDURE ShowAnimations;
VAR
     Obraz   : ARRAY[1..3] OF TPicture;
     i       : Byte;
     Sprite  : PSprite;
     Temp    : PSprite;
     TimeX   : LongInt;

BEGIN

  Opcja:=0;

  FOR i:=1 TO 3 DO
  BEGIN
    V_NewImage(Obraz[i]);
    V_LoadBMP24(Obraz[i], mDirectory+FileSpr+IntToStr(i)+'.bmp');
  END;

  IF MaxAvail<SizeOf(TSprite)*MaxSpr THEN
  BEGIN
    FOR i:=1 TO 3 DO
      V_FreeImage(Obraz[i]);
    Exit;
  END;

  GetMem(Sprite, SizeOf(TSprite)*MaxSpr);
  Temp:=Sprite;
  TimeX:=0;

  FOR i:=1 TO MaxSpr DO
      BEGIN
        Temp^.X:=Random(V_MaxEX);
        Temp^.Y:=Random(V_MaxEY);
        Temp^.DY:=Random(5)-Random(5);
        Temp^.DX:=Random(5)-Random(5);
        Temp^.Ani:=Random(3)+1;

        Inc(Temp);
      END;

  REPEAT
    V_ClearScreen(V_Ekran, 0);

    Temp:=Sprite;

    FOR i:=1 TO MaxSpr DO
      BEGIN
        Temp^.X:=Temp^.X+Temp^.DX;
        Temp^.Y:=Temp^.Y+Temp^.DY;

        IF (Random(100)=50) THEN
        BEGIN
          Inc(Temp^.Ani);
          IF Temp^.Ani>3 THEN Temp^.Ani:=1;
        END;

        IF (Temp^.Y<-100) OR (Temp^.Y> V_MaxEY) THEN
          Temp^.DY:=-Temp^.DY;

        IF (Temp^.X<-100) OR (Temp^.X> V_MaxEX) THEN Temp^.DX:=-Temp^.DX;


        V_KopiujObraz(V_Ekran, Obraz[Temp^.Ani], Temp^.X, Temp^.Y);
        Inc(Temp);

      END;

    IF S_Ti>TimeX+4 THEN TimeX:=S_Ti;


    V_Vret;
    V_FlipBuf(V_Ekran);

  UNTIL Key[VK_ESC];

  FreeMem(Sprite, SizeOf(TSprite)*MaxSpr);

  FOR i:=1 TO 3 DO
      V_FreeImage(Obraz[i]);
END;

PROCEDURE Pomoc;
VAR F:Text;
    s:STRING;
    i:Byte;

BEGIN
  Opcja:=0;
  V_ClearScreen(V_Ekran, V_RGB($77, $77, $77));

  IF FileExists(mDirectory+HelpFile) THEN
  Assign(F, mDirectory+HelpFile);
  Reset(F);
  i:=0;

  WHILE NOT Eof(F) DO
    BEGIN
      Inc(i);
      ReadLn(F, s);
      V_CenterText(V_Ekran, DefaultFont, V_MaxEX SHR 1, 10*i, s, $FFFF, 8);
    END;

  Close(F);

  V_FlipBuf(V_Ekran);

  REPEAT UNTIL Key[VK_ESC];


END;


PROCEDURE Labirynth;

CONST MaxW=8;
      MaxH=8;

      MaxRect=10;

      Rozm=20;

VAR
    Dane, Temp,
    TempLab : PTriangle;
    Size  : Word;
    Gracz : TVertex;

PROCEDURE Next3d;

BEGIN
  IF Dane<>NIL THEN
     FreeMem(Dane, Size*SizeOf(TTriangle));

  IF Temp<>NIL THEN
     FreeMem(Temp, Size*SizeOf(TTriangle));


  Dane:=G3d_Load(mDirectory+FileCube, Size);

  IF (MaxAvail<Size*SizeOf(TTriangle)+MaxRect*Size*SizeOf(TTriangle))
  OR (Dane=NIL)

  THEN
     BEGIN
       Temp:=NIL;
       IF Dane<>NIL THEN
       FreeMem(Dane, Size*SizeOf(TTriangle));
       Dane:=NIL;
       TempLab:=NIL;
       Exit;
     END;

  GetMem(Temp, Size*SizeOf(TTriangle));
  GetMem(TempLab, Size*SizeOf(TTriangle)*MaxRect);

END;

VAR Av:Single;
    Czas:LongInt;

    Lab : ARRAY[1..MaxW, 1..MaxH] OF Boolean;
    i, j  : Byte;
    c:Byte;
    mX, mY:Integer;
    Ly  :Byte;
    g:Single;

BEGIN

      Dane:=NIL;
      Temp:=NIL;
      TempLAB:=NIL;

      Next3d;

      Opcja:=0;
      Av:=0.4;

      KatX:=0;
      KatY:=0;
      KatZ:=0;
      Ly:=0;


      Vector.X:=0;
      Vector.Y:=0;
      Vector.Z:=G3D_MaxOdl*0.8;

      Gracz.X:=0;
      Gracz.Y:=-5;
      Gracz.Z:=10;

      Czas:=S_Ti;
      Randomize;

      FillChar(Lab, SizeOf(Lab), False);

      FOR i:=1 TO MaxRect DO
      BEGIN
        REPEAT
          mx:=Random(MaxW)+1;
          my:=Random(MaxH)+1;

        UNTIL NOT Lab[mX, mY];

        Lab[mX, mY]:=True;
      END;

      G3d_MaxOdl:=500;
      G3d_MinOdl:=2;
      MouseXY(V_MaxEX SHR 1, V_MaxEY SHR 1);
      Poz.X:=0;
      Poz.Y:=100;

      Poz.Width:=320;
      Poz.Height:=100;



  REPEAT

    IF Assigned(Dane) AND Assigned(TempLab) AND Assigned(Temp) THEN

    BEGIN
      V_ClearScreen(Ekran, G3d_KOLOR_MGLY);
      {D10_DrawBackGround2(Ekran, 0, 0, G3d_KOLOR_MGLY);}
    END
    ELSE

    V_ClearScreen(Ekran, 0);





    c:=0;


    {KOPIUJE TROJKATY}
    IF Assigned(Dane) AND Assigned(TempLab) AND Assigned(Temp) THEN

    FOR i:=1 TO MaxW DO
    FOR j:=MaxH DOWNTO 1 DO
    IF Lab[i, j] THEN
    BEGIN

      S_Move32(Dane, Temp, Size*SizeOf(TTriangle));

      Vector.X:=i*Rozm-(MaxW*Rozm SHR 1);
      Vector.Y:=0;
      Vector.Z:=j*Rozm;


      G3D_Transform(Temp, @Vector, Size);

      D_Move32(Temp^, TempLab^, Size*SizeOf(TTriangle), c*Size*SizeOf(TTriangle));

      Inc(c);

    END;


    MouseWhereXY(mX, mY);

    KatX:=-Round(((mY-(V_MaxEY SHR 1))/(V_MaxEY SHR 1))*16);
    KatY:=Ly-Round(((mX-(V_MaxEX SHR 1))/(V_MaxEX SHR 1))*32);



    IF KEY[VK_Up] THEN

    BEGIN

    {W LABIRYNCIE}
    IF (Gracz.X<MaxW*Rozm SHR 1) AND
       (Gracz.X>-(MaxW*Rozm SHR 1)) AND
       (Gracz.Z<0) AND
       (Gracz.Z>-MaxH*Rozm) THEN
       BEGIN

        IF  NOT Lab[Trunc(Gracz.X+MaxW*Rozm SHR 1) DIV Rozm+1,
            (-Trunc(Gracz.Z-G3D_Cos[NOT KatY]) DIV Rozm)+1] THEN
            Gracz.Z:=Gracz.Z-G3D_Cos[NOT KatY];

        IF  NOT Lab[Trunc(Gracz.X+G3D_Sin[KatY]+MaxW*Rozm SHR 1) DIV Rozm+1,
            -Trunc(Gracz.Z) DIV Rozm+1] THEN
            Gracz.X:=Gracz.X+G3D_Sin[KatY];

       END;
    IF
       ((Gracz.X>=MaxW*Rozm SHR 1) OR
       (Gracz.X<=-(MaxW*Rozm SHR 1)) AND
       (Gracz.Z<=-MaxH*Rozm) OR
       (Gracz.Z>=0)) THEN
       BEGIN
         Gracz.X:=Gracz.X+G3D_Sin[KatY];
         Gracz.Z:=Gracz.Z-G3D_Cos[NOT KatY];
       END;

    END;



    IF KEY[VK_Down] THEN
    BEGIN
      Gracz.Z:=Gracz.Z+G3D_Cos[NOT KatY];
      Gracz.X:=Gracz.X-G3D_Sin[KatY];
    END;

    IF KEY[VK_SPACE] THEN
    BEGIN
      Gracz.Y:=Gracz.Y-2;

    END;

    IF Gracz.Y<-5 THEN
    BEGIN
      g:=g+0.1;
      Gracz.Y:=Gracz.Y+g;

      IF Gracz.Y>-5 THEN
      BEGIN
        Gracz.Y:=-5;
        g:=0;
      END;
    END;


    IF KEY[VK_Left] THEN Inc(Ly);
    IF KEY[VK_Right] THEN Dec(Ly);

    G3D_Transform(TempLab, @Gracz, Size*MaxRect);
    G3D_Rotate(TempLab, KatX, KatY, KatZ, Size*MaxRect);


    {RYSUJE TROJKATY W BUFORZE}
    G3D_Render(TempLab, Size*MaxRect);

    {POWROT}
    V_VRet;

    {PRZERYSOWUJE}
    V_FlipBuf(Ekran);

  UNTIL PORT[$60]=1;

  IF Dane<>NIL THEN
     FreeMem(Dane, Size*SizeOf(TTriangle));

  IF Temp<>NIL THEN
     FreeMem(Temp, Size*SizeOf(TTriangle));

  IF TempLab<>NIL THEN
     FreeMem(TempLab, Size*SizeOf(TTriangle)*MaxRect);

  Dane:=NIL;
  Temp:=NIL;
  G3d_MaxOdl:=100;
  G3d_MinOdl:=5;

END;


BEGIN
  Dz:=3;
END.