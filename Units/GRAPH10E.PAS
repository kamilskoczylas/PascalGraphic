{$G+}
UNIT Graph10E;


INTERFACE
USES Types, Fonts, Errors, Standard, MMX;


CONST
  V_MaxEX=320;
  V_MaxEY=200;

  BrakZnaku:ARRAY[0..7] OF Byte=
  {(00, 66, 36, 24, 24, 36, 66, 00);}
  (0, 0, 0, 0, 0, 0, 0, 0);

  EkranRect:TRect=
  (X:0;Y:0;W:320;H:200);

  MMX_Enabled=FALSE;

  VerticalRetrace:Boolean=True;

  V_TextNormal:Boolean=True;
  VGA_Tryb:Boolean=FAlse;

TYPE
  TEkran10Eh=RECORD
    Ekr1 : Pointer;
    Ekr2 : Pointer;
  END;

  TObraz=RECORD
    W,
    H             : Word;
    TCol          : Word;
    Transparent   : Boolean;
    BMP           : Pointer;
    BPP           : Byte;
    Paleta        : Pointer;
  END;

  TPicture       =^TObraz;

  TBMPCaption    = RECORD
    BM           : Word;
    Size         : Longint;
    rezerw       : Longint;
    obraz_offset : Longint;
    info         : Longint;
    Width        : Longint;
    Height       : Longint;
    LPO          : Word;
    BPP          : Word;
    kompresja    : Longint;
    Size_Obr     : Longint;
    HDPI         : Longint;
    VDPI         : Longint;
    Colors       : Longint;
    UColors      : Longint;
  END;

  TRGB           = RECORD
    R, G, B      : Byte;
  END;

  TPaleta        = RECORD
    Color        : ARRAY[0..255] OF TRGB;
  END;

  PPaleta        =^TPaleta;

{*************************************************************************}

VAR
    DefaultRect  : TRect;
    V_Ekran      : TEkran10Eh;


{*************************************************************************}

FUNCTION V_RGB(r, g, b : Byte) : Word;
{FUNCTION  V_RGB(R, G, B:Byte):Word;}
FUNCTION  V_GetBuf(VAR Buf:TEkran10Eh):Byte;
FUNCTION  V_LoadBMP24(Buf:TPicture;CONST Fn:STRING):Boolean;

PROCEDURE V_PrintScreen(CONST Fn:STRING);
PROCEDURE V_ToRGB(c : Word; VAR r, g, b : Byte);
{PROCEDURE V_ToRGB(Col:Word;VAR R, G, B:Byte);}
PROCEDURE V_FreeBuf(VAR Buf:TEkran10Eh);
PROCEDURE ShowCaptionBMP(CONST Fn:STRING);
PROCEDURE V_VRet;
PROCEDURE V_FillChar32(Dest:Pointer;Count:word; Value:Word);
PROCEDURE V_FlipBuf(Buf : TEkran10Eh);
PROCEDURE V_Set10Eh;
PROCEDURE V_End10Eh;
PROCEDURE V_ClearScreen(Buf:TEkran10Eh; Col:Word);
PROCEDURE V_HLine(Buf:TEkran10Eh; X, Y, W:Integer;C:Word);
PROCEDURE V_VLine(Buf:TEkran10Eh; X, Y, H:Integer;C:Word);
PROCEDURE V_Pix(Buf:TEkran10Eh; X, Y:Integer;C:Word);
PROCEDURE V_Line(Buf:TEkran10Eh; X1, Y1, X2, Y2:Integer;C:Word);
PROCEDURE V_HLineAlpha1(Buf:TEkran10Eh; X, Y, W:Integer;C:Word;Alpha:Byte);
PROCEDURE V_RozmyjEkran(Buf:TEkran10Eh; Speed:Byte);
PROCEDURE V_KopiujObraz(Buf:TEkran10Eh; Obraz:TPicture; X, Y:Integer);
PROCEDURE V_NewImage(VAR Picture:TPicture);
PROCEDURE V_FreeImage(VAR Picture:TPicture);
PROCEDURE V_WriteXY(Buf:TEkran10Eh;Font:PFont;X, Y:Integer;CONST S:STRING;C:Word;StepX:Byte);
PROCEDURE V_CenterText(Buf:TEkran10Eh;Font:PFont;X, Y:Integer;CONST S:STRING;C:Word;StepX:Byte);
PROCEDURE V_CopyLine(Buf:TEkran10Eh; Dest:Pointer; X, Y, W:Integer);
PROCEDURE V_CopyFromLine(Buf:TEkran10Eh; Line:Pointer; X, Y, W:Integer);
PROCEDURE V_LineX(X1, Y1, X2, Y2 : Integer; C: Word);
PROCEDURE V_CreateMirroredBMP(VAR Source, Dest:TPicture);


IMPLEMENTATION


{*************************************************************************}
{FUNCTION V_RGB(r, g, b : Byte) : Word;ASSEMBLER;
ASM
  Mov  Al, [r]
  Shl  Ax, 5
  Mov  Al, [g]
  Shl  Ax, 3
  And  Al, 11100000b
  Shr  [b], 3
  Or   Al, [b]
END;
{*************************************************************************}
PROCEDURE V_ToRGB(c : Word; VAR r, g, b : Byte); ASSEMBLER;
ASM
  Mov  Cx, Ds
  Mov  Ax, [c]
  Lds  Bx, [b]
  Mov  [Bx], Al
  Shl  BYTE PTR [Bx], 3
  Shr  Ax, 5
  Lds  Bx, [g]
  Mov  [Bx], Al
  Shl  BYTE PTR [Bx], 2
  Shr  Ax, 6
  Lds  Bx, [r]
  Mov  [Bx], Al
  Shl  BYTE PTR [Bx], 3
  Mov  Ds, Cx
END;

{*************************************************************************}
FUNCTION V_RGB(R, G, B:Byte):Word;
BEGIN
  V_RGB:=(B SHR 3) OR ((G SHR 2) SHL 5) OR ((R SHR 3) SHL 11);
END;
{*************************************************************************
PROCEDURE V_ToRGB(Col:Word;VAR R, G, B:Byte);
BEGIN
  R:=(Col AND (31 SHL 11)) SHR 8;
  G:=(Col AND (63 SHL 5)) SHR 3;
  B:=BYTE(Col SHL 3);
END;
{*************************************************************************}

FUNCTION V_GetBuf(VAR Buf:TEkran10Eh):Byte;
BEGIN
  Buf.EKR1:=NIL;
  Buf.EKR2:=NIL;

  V_GetBuf:=E_OK;
  IF MemAvail<128000 THEN
  BEGIN
    V_GetBuf:=E_PAMIEC;
    Exit;
  END;

  GetMem(Buf.EKR1, 64000);
  GetMem(Buf.EKR2, 64000);

  V_Ekran.EKR1:=Buf.EKR1;
  V_Ekran.EKR2:=Buf.EKR2;
END;
{*************************************************************************}
PROCEDURE V_FreeBuf(VAR Buf:TEkran10Eh);
BEGIN
  FreeMem(Buf.EKR1, 64000);
  FreeMem(Buf.EKR2, 64000);
  Buf.EKR1:=NIL;
  Buf.EKR2:=NIL;

  V_Ekran.EKR1:=NIL;
  V_Ekran.EKR2:=NIL;
END;
{*************************************************************************}
PROCEDURE V_VRet;
BEGIN
IF VerticalRetrace THEN
   ASM

       Mov Dx, 3dah

       @Powrot:

         In   Al, Dx
         Test Al, 00001000b
         Jnz  @Powrot

       @Nie_Ma:

         In   Al, Dx
         Test Al, 00001000b
         Jz   @Nie_Ma

   END;
END;
{*************************************************************************}
PROCEDURE V_Move32(VAR Src;VAR Dest;Count, Offs: Word); ASSEMBLER;
ASM
  Mov  Cx, Count
  Mov  Dx, Cx
  And  Dx, 3
  Shr  Cx, 2

  Push Ds

  Lds  Si, Src
  Les  Di, Dest

  Add  Si, Offs

  Cld
  Db   $F3,$66,$A5

  Mov  Cx, Dx
  Rep  MovSb

  Pop  Ds
END;
{*************************************************************************}
PROCEDURE V_FillChar32(Dest:Pointer;Count:word; Value:Word);ASSEMBLER;
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
PROCEDURE V_FlipBuf(Buf : TEkran10Eh);
BEGIN


  IF VGA_Tryb THEN
  BEGIN
    ASM
    Mov AX, 4F05H
    Mov BX, 0
    Mov DX, 0
    Int 10H
  END;

    {KOPIOWANIE EKRANU WRAZ Z KONWERSJA NA TRYB 8-BITOWY}
    ASM
      Les  Di, Buf.Ekr1
      Mov  Cx, 32000
      Push Ds
      Mov  Ax, $A000
      Mov  Ds, Ax
      Xor  Si, Si

      @Petla:

        Mov  Bx, Es:[Di]
        Inc  Di
        Inc  Di
        Mov  Ax, Bx
        And  Ax, 0000000000011100b
        Shr  Ax, 2

        Mov  Dx, Bx
        And  Dx, 0000011100000000b
        Shr  Dx, 5
        Or   Ax, Dx

        And  Bx, 1100000000000000b
        Shr  Bx, 8
        Or   Ax, Bx

        Mov  Bx, Si
        Inc  Si
        Mov  Byte Ptr Ds:[Bx], Al

      Loop @Petla

      Pop  Ds

      Les  Di, Buf.Ekr2
      Mov  Cx, 32000
      Mov  Si, 31999
      Push Ds
      Mov  Ax, $A000
      Mov  Ds, Ax

      @Petla2:

        Mov  Bx, Es:[Di]
        Inc  Di
        Inc  Di
        Mov  Ax, Bx
        And  Ax, 0000000000011100b
        Shr  Ax, 2

        Mov  Dx, Bx
        And  Dx, 0000011100000000b
        Shr  Dx, 5
        Or   Ax, Dx

        And  Bx, 1100000000000000b
        Shr  Bx, 8
        Or   Ax, Bx

        Mov  Bx, Si
        Inc  Si
        Mov  Byte Ptr Ds:[Si], Al

      Loop @Petla2

      Pop  Ds


    END;

  END
  ELSE
  BEGIN

  ASM
    Mov AX, 4F05H
    Mov BX, 0
    Mov DX, 0
    Int 10H
  END;

  IF MMX_Enabled THEN
  BEGIN
    MMX_Move(Ptr($A000, 0),     Buf.Ekr1, 64000);
    MMX_Move(Ptr($A000, 64000), Buf.Ekr2, 1536);
  END ELSE
  BEGIN
    V_Move32(Buf.Ekr1^, Ptr($A000, 0)^, 64000, 0);
    V_Move32(Buf.Ekr2^, Ptr($A000, 64000)^, 1536, 0);
  END;

  ASM
    Mov AX, 4F05H
    Mov BX, 0
    Mov DX, 1
    Int 10H
  END;
  {IF MMX_Enabled THEN
  MMX_Move(Ptr($A000, 0), Buf.Ekr2 , 62464 1536);
  ELSE}
  V_Move32(Buf.Ekr2^, Ptr($A000, 0)^, 62464, 1536);

  END;

END;
{*************************************************************************}
PROCEDURE UpString(VAR S:STRING);
VAR i:Byte;
BEGIN
  FOR i:=1 TO Byte(S[0]) DO
    S[i]:=UpCase(S[i]);
END;
{*************************************************************************}
PROCEDURE V_Set10Eh;
VAR R, G, B:Byte;
    S:STRING;

BEGIN

IF (ParamCount>0) THEN
  BEGIN
    {DUZY PARAMETR}
    S:=ParamStr(1);
    UpString(S);
  END;

IF (S='VGA') THEN
  BEGIN

  ASM
    Mov   Ax, 13h
    Mov   Bx, 0
    Int   10h
  END;
    VGA_Tryb:=TRUE;

    {USTAWIANIE PALETY}
    FOR R:=0 TO 3 DO
    FOR G:=0 TO 7 DO
    FOR B:=0 TO 7 DO
      BEGIN
        PORT[$3c8]:=B OR (G SHL 3) OR (R SHL 6);

        PORT[$3c9]:=R SHL 4;
        PORT[$3c9]:=G SHL 3;
        PORT[$3c9]:=B SHL 3;
      END;


  END ELSE
  ASM
    Mov   Ax, 4F02h
    Mov   Bx, 10Eh
    Int   10h
  END;
END;
{*************************************************************************}
PROCEDURE V_End10Eh; ASSEMBLER;
ASM
  Mov   Ax, 4F02h
  Xor   Bh, Bh
  Mov   Bl, 03h
  Int   10h
END;
{*************************************************************************}
FUNCTION V_LoadBMP24(Buf:TPicture;CONST Fn:STRING):Boolean;
VAR
  Capt : TBMPCaption;
  F    : FILE;
  Size : Word;
  Temp : Word;
  I    : Word;
  BTem : Pointer;
  Addx : Word;
  BMPx : Pointer;
  TC   : Word;

BEGIN
  {JESLI FUNKCJA SIE NIE ZAKONCZY POWODZENIEM ZWROCI False}
  V_LoadBMP24:=False;

  {JEZELI JESZCZE NIE MA UTWORZONEGO OBRAZKA TO WYCHODZI}
  IF Buf=NIL THEN Exit;

  {OTWIERA PODANY PLIK}
  Assign(F, Fn);
  {$I-}
  Reset(F, 1);
  {$I+}

  {JESLI NIE ZNALEZIONO PLIKU WYCHODZI}
  IF IOResult<>0 THEN Exit;

  {WCZYTUJE NAGLOWEK INFORMACYJNY}
  BlockRead(F, Capt, SizeOf(Capt));

  {USTAWIA ROZMIAR OBRAZKA}
  Buf^.W:=Capt.Width;
  Buf^.H:=Capt.Height;

  {OBLICZANIE POTRZEBNYCH PAMIECI DLA OBRAZKA}
  {ORAZ DO BUFORA ODCZYTU Z DYSKU}
  Size:=Capt.Width*Capt.Height SHL 1;
  Temp:=Capt.Width SHL 1+Capt.Width;

  {W RAZIE POTRZEBY PRZYDZIELA PAMIEC DLA RYSUNKU}
  IF (Buf^.BMP=NIL) THEN
  BEGIN
   IF (MaxAvail>=Size) THEN GetMem(Buf^.BMP, Size)
      ELSE Exit;
  END;

  {JEZELI TO NIE JEST BITMAPA 24 BITOWA}
  IF Capt.BPP<>24  THEN BEGIN Close(F); Exit; END;

  {PRZESTAWIA WSKAZNIK PLIKU NA POCZATEK BITMAPY}
  Seek(F, Capt.Obraz_Offset);

  {PAMIEC DO ODCZYTU JEDNEJ LINII}
  IF MaxAvail<Temp THEN BEGIN Close(F); Exit; END;
  Temp:=Temp+(Temp AND 3);
  GetMem(BTem, Temp);

  {USTAWIA WSKAZNIK BUFORU NA OSTATNIA LINIE}
  Addx:=(Capt.Height-1)*(Capt.Width SHL 1);

  {BUFOR POMOCNICZY DLA ASSEMBLERA}
  BMPx:=Buf^.BMP;

  {WCZYTUJE I PRZEKSZTALCA BITMAPE OD KONCA}
  FOR I:=Capt.Height-1 DOWNTO 0 DO
  BEGIN
    BlockRead(F, BTem^, Temp);
    ASM
      Push Ds

      Les  Di, BMPx
      Add  Di, Addx

      Lds  Si, BTem

      Mov  Cx, Word Ptr Capt.Width

      @Petla:

        Xor  Ax, Ax
        Mov  Al, [Si]
        Inc  Si

        Xor  Bx, Bx
        Mov  Bl, [Si]
        Inc  Si

        Xor  Dx, Dx
        Mov  Dl, [Si]
        Inc  Si

        Shr  Ax, 3
        Shr  Bx, 2
        Shr  Dx, 3

        Shl  Bx, 5
        Shl  Dx, 11

        Or   Ax, Bx
        Or   Ax, Dx

        Mov  Es:[Di], Ax

        Inc  Di
        Inc  Di

      Dec  Cx
      Jnz  @Petla

      Pop  Ds
    END;
    Dec(Addx, (Capt.Width shl 1));

  END;

  {OKRESLANIE KOLORU PRZEZROCZYSTEGO}
  {LEWY GORNY PIKSEL}
  ASM
    Les  Di, BMPx
    Mov  Ax, Es:[Di]
    Mov  Tc, Ax
  END;

  {DOMYSLNY KOLOR PRZEZROCZYSTOSCI}
  Buf^.TCol:=Tc;

  {ZWALNIA PAMIEC OD BUFORA}
  FreeMem(BTem, Temp);

  {ZAMYKA PLIK}
  Close(F);

  {ZAZNACZA ZE WSZYSTKO SIE UDALO}
  V_LoadBMP24:=True;
END;

{*************************************************************************}
PROCEDURE V_ClearScreen(Buf:TEkran10Eh; Col:Word);
BEGIN
  IF MMX_Enabled THEN
  BEGIN
    MMX_FillChar(Buf.Ekr1, 64000, Col);
    MMX_FillChar(Buf.Ekr2, 64000, Col);
  END ELSE
  BEGIN
    V_FillChar32(Buf.Ekr1, 64000, Col);
    V_FillChar32(Buf.Ekr2, 64000, Col);
  END;
END;

{*************************************************************************}
FUNCTION V_ObetnijHLine(VAR X1, Y1, W:Integer):Boolean;
BEGIN
  V_ObetnijHLine:=TRUE;

  IF (Y1<DefaultRect.Y) OR (Y1>=DefaultRect.Y+DefaultRect.H) OR
     (X1>=DefaultRect.X+DefaultRect.W) OR (W<=0) OR (X1+W<=DefaultRect.X) THEN Exit;

  IF X1<DefaultRect.X THEN
	  BEGIN
      IF X1+W>DefaultRect.X+DefaultRect.W THEN W:=DefaultRect.W
      ELSE
		    W:=W+(X1-DefaultRect.X);

      X1:=DefaultRect.X;

		END ELSE
    IF X1+W>DefaultRect.X+DefaultRect.W THEN
			W:=DefaultRect.X+DefaultRect.W-X1;

  V_ObetnijHLine:=FALSE;
END;

{*************************************************************************}
FUNCTION V_ObetnijVLine(VAR X1, Y1, H:Integer):Boolean;
BEGIN
  V_ObetnijVLine:=TRUE;

  IF (X1<DefaultRect.X) OR (Y1>=DefaultRect.Y+DefaultRect.H) OR
     (X1>=DefaultRect.X+DefaultRect.W) OR (H<=0) OR (Y1+H<=DefaultRect.Y) THEN Exit;

  IF Y1<DefaultRect.Y THEN
	  BEGIN
      IF Y1+H>=DefaultRect.Y+DefaultRect.H THEN
      BEGIN
        H:=DefaultRect.Y+DefaultRect.H;
        Y1:=DefaultRect.Y;
      END ELSE
      BEGIN
		    H:=H+Y1-DefaultRect.Y;
				Y1:=DefaultRect.Y;
      END;
		END ELSE

    IF Y1+H>DefaultRect.Y+DefaultRect.H THEN
			H:=DefaultRect.Y+DefaultRect.H-Y1;

  V_ObetnijVLine:=FALSE;
END;

{*************************************************************************}

PROCEDURE V_HLine(Buf:TEkran10Eh; X, Y, W:Integer;C:Word);

VAR Ekr1, Ekr2:Pointer;
BEGIN

  IF V_ObetnijHLine(X, Y, W) THEN Exit;
  Ekr1:=Buf.Ekr1;
  Ekr2:=Buf.Ekr2;

  ASM
    Mov  Ax, Y
    Cmp  Ax, 100

    Ja   @Drugi

    Les  Di, Ekr1

    Jmp  @Dalej

    @Drugi:

      Les  Di, Ekr2
      Sub  Ax, 100

    @Dalej:

      Shl  Ax, 7
      Add  Di, Ax
      Shl  Ax, 2
      Add  Di, Ax
      Add  Di, X
      Add  Di, X

      Mov  Cx, W
      Mov  Bx, Cx
      And  Bx, 1
      Shr  Cx, 1

      Mov  Ax, C
      Db   $66
      Shl  Ax, 16
      Mov  Ax, C

      Cld

      Db   $F3, $66, $AB

      Mov  Cx, Bx
      Rep  StosW
   END;
END;
{*************************************************************************}
PROCEDURE V_Pix(Buf:TEkran10Eh; X, Y:Integer;C:Word);

VAR Ekr1, Ekr2:Pointer;
BEGIN

  IF (X<DefaultRect.X) OR (X>=DefaultRect.X+DefaultRect.W) OR
     (Y<DefaultRect.Y) OR (Y>=DefaultRect.Y+DefaultRect.H) THEN Exit;
  Ekr1:=Buf.Ekr1;
  Ekr2:=Buf.Ekr2;

  ASM
    Mov  Ax, Y
    Cmp  Ax, 100

    Ja   @Drugi

    Les  Bx, Ekr1

    Jmp  @Dalej

    @Drugi:

      Les  Bx, Ekr2
      Sub  Ax, 100

    @Dalej:

      Shl  Ax, 7
      Add  Bx, Ax
      Shl  Ax, 2
      Add  Bx, Ax
      Add  Bx, X
      Add  Bx, X
      Mov  Ax, C

      Mov  ES:[Bx], Ax
   END;
END;
{*************************************************************************}

PROCEDURE V_VLine(Buf:TEkran10Eh; X, Y, H:Integer;C:Word);

VAR Ekr1, Ekr2:Pointer;
BEGIN

  IF V_ObetnijVLine(X, Y, H) THEN Exit;
  Ekr1:=Buf.Ekr1;
  Ekr2:=Buf.Ekr2;

  ASM
    Mov  Ax, Y
    Cmp  Ax, 100

    Jnb  @ZaczynajOd2

    Les  Di, Ekr1
    Mov  Bx, Ax
    Shl  Bx, 7
    Add  Di, Bx
    Shl  Bx, 2
    Add  Di, Bx
    Add  Di, X
    Add  Di, X

    Jmp  @DrawLine

    @ZaczynajOd2:

    Les  Di, Ekr2
    Mov  Bx, Ax
    Sub  Bx, 100
    Shl  Bx, 7
    Add  Di, Bx
    Shl  Bx, 2
    Add  Di, Bx
    Add  Di, X
    Add  Di, X
    Xor  Ax, Ax

    @DrawLine:

    Mov  Cx, H
    Mov  Dx, C
    Cld

    @Petla:

      Cmp  Ax, 100
      Jb   @Dalej

      @Drugi:

        Les  Di, Ekr2
        Sub  Ax, 100
        Add  Di, X
        Add  Di, X

      @Dalej:

        Mov  ES:[DI], Dx
        Add  Di, 640
        Inc  Ax

    Loop @Petla

   END;
END;
{*************************************************************************}
{PROCEDURE V_Line(Buf:TEkran10Eh; X1, Y1, X2, Y2:Integer;C:Word);
FUNCTION Znak(X:Integer):Integer;
BEGIN
  IF X>0 THEN Znak:=1 ELSE
  IF X<0 THEN Znak:=-1 ELSE
  			  Znak:=0;
END;

PROCEDURE PrzytnijLinieX(VAR X1, Y1, X2, Y2:Integer; Rect:PRect);

VAR a, b:Real;
    Granica:Integer;

BEGIN

  Granica:=Rect^.X;
  {PRZECIECIE Z OSIA Z LEWEJ
  IF (X1<Granica) AND (X2>=Granica) THEN
  BEGIN
    {$Q-
    Y1:=(Y1+Round((Y2-Y1)*(Granica-X1)/(X2-X1)));
    X1:=Granica;
    {$Q+
  END;

  Granica:=Rect^.X+Rect^.W;
  {PRZECIECIE Z OSIA Z PRAWE  IF (X1<Granica) AND (X2>=Granica) THEN
  BEGIN
    {$Q-
    Y2:=(Y2+Round((Y2-Y1)*(X2-Granica)/(X2-X1)));
    X2:=Granica-1;
    {$
VAR l, s, d1x, d1y, d2x,
	  d2y, rx, ry, m, n,
    MaxX, MaxY, MinX, MinY    : Integer;
    Rect:TRect;
    a, b:Single;
    NY1, NX1, NX2, NY2    :Integer;

BEGIN

  S_Move32(@DefaultRect, @Rect, SizeOf(TRect));

  IF ((X1<Rect.X) AND (X2<Rect.X)) OR
     ((X1>=Rect.X+Rect.W) AND (X2>=Rect.X+Rect.W)) OR
     ((Y1<Rect.Y) AND (Y2<Rect.Y)) OR
     ((Y1>=Rect.Y+Rect.H) AND (Y2>=Rect.Y+Rect.H)) THEN Exit;


  IF (X1<>X2) AND (Y1<>Y2) THEN
  BEGIN
    {$Q-
    a:=(Y2-Y1)/(X2-X1);
    b:=((-X1)*(y2-y1)-(X2-X1)*(-X1))/(X2-X1);

    Y1:=-Round(a*Rect.X+b);
    Y2:=-Round(a*(Rect.X+Rect.W-1)+b);

    X1:=Round((b-Rect.Y)/a);
    X2:=Round((b-(Rect.Y+Rect.H-1))/a);
    {$Q+
  END;

    IF Y1<Rect.Y THEN Y1:=Rect.Y ELSE
    IF Y1>Rect.Y+Rect.H-1 THEN Y1:=Rect.Y+Rect.H-1;

    IF Y2<Rect.Y THEN Y2:=Rect.Y ELSE
    IF Y2>Rect.Y+Rect.H-1 THEN Y2:=Rect.Y+Rect.H-1;

    IF X1<Rect.X THEN X1:=Rect.X ELSE
    IF X1>Rect.X+Rect.W-1 THEN X1:=Rect.X+Rect.W-1;

    IF X2<Rect.X THEN X2:=Rect.X ELSE
    IF X2>Rect.X+Rect.W-1 THEN X2:=Rect.X+Rect.W-1;}


PROCEDURE V_LineX(X1, Y1, X2, Y2 : Integer; C: Word);

VAR
  P0, P1, tmp : Integer;
  EX1, EY1, EX2, EY2 : Integer;
  x, y : Integer;


  l, s, d1x, d1y, d2x,
  d2y, rx, ry, m, n,
  MaxX, MaxY, MinX, MinY    : Integer;
  Rect:TRect;
  a           : Single;
  Temp         : Integer;

  FUNCTION Znak(X:Integer):Integer;
  BEGIN
    IF X>0 THEN Znak:=1 ELSE
    IF X<0 THEN Znak:=-1 ELSE
  			    Znak:=0;
  END;


  PROCEDURE Zamien(VAR a, b : Integer);
  VAR
    c : Integer;
  BEGIN
    c := a;
    a := b;
    b := c;
  END;

  FUNCTION ObliczKod(x, y : Integer) : Byte;
  BEGIN
    ObliczKod := (Byte(x  < EX1 ) OR
                 (Byte(EX2 < x  ) SHL 1) OR
                 (Byte(y  < EY1 ) SHL 2) OR
                 (Byte(EY2 < y  ) SHL 3));
  END;

BEGIN

  S_Move32(@DefaultRect, @Rect, SizeOf(TRect));

  EX1 := Rect.X;
  EY1 := Rect.Y;
  EX2 := Rect.X+Rect.W-1;
  EY2 := Rect.Y+Rect.H-1;

{ !!! ZROBIC !!!
  Wykrywanie przypadkow poziomych i pionowych linii.
}
  IF x1=x2 THEN
  BEGIN

  IF y1>y2 THEN V_VLine(V_Ekran, x1, y2, y1-y2+1, C)
           ELSE V_VLine(V_Ekran, x1, y1, y2-y1+1, C);
    Exit;
  END;

  IF y1=y2 THEN
  BEGIN

    IF x1>x2 THEN V_HLine(V_Ekran, x2, y1, x1-x2+1, C)
             ELSE V_HLine(V_Ekran, x1, y1, x2-x1+1, C);
    Exit;

  END;


  WHILE (TRUE)
  DO BEGIN
    P0 := ObliczKod(x1, y1);
    P1 := ObliczKod(x2, y2);
    IF (P0 = 0) AND (P1 = 0)
    THEN
      Break
    ELSE IF (P0 AND P1) <> 0
    THEN
      Exit
    ELSE BEGIN
      IF (P0 = 0)
      THEN BEGIN
        Zamien(x1, x2);
        Zamien(y1, y2);
        Zamien(P0, P1);
      END;
      IF (P0 AND 1 <> 0)
      THEN BEGIN
        Temp:=X2-X1;IF Temp=0 THEN Inc(Temp);
        y1 := y1+(LongInt((EX1-X1))*(Y2-Y1)) DIV Temp;
        x1 := EX1;
      END;
      IF (P0 AND 2 <> 0)
      THEN BEGIN
        Temp:=X2-X1;IF Temp=0 THEN Inc(Temp);
        y1  := y1+(LongInt((EX2-x1))*(y2-y1)) DIV Temp;
        x1 := EX2;
      END;
      IF (P0 AND 4 <> 0)
      THEN BEGIN
        Temp:=Y2-Y1;IF Temp=0 THEN Inc(Temp);
        x1 := X1+(LongInt((EY1-Y1))*(X2-X1)) DIV Temp;
        y1 := EY1;
      END;
      IF (P0 AND 8 <> 0)
      THEN BEGIN
        Temp:=Y2-Y1;IF Temp=0 THEN Inc(Temp);
        x1 := x1+((EY2-y1)*(x2-x1)) DIV Temp;
        y1 := EY2;
      END;
    END;
  END;

  rx:=X2-X1;
  ry:=Y2-Y1;

  d1x:=Znak(rx);
  d1y:=Znak(ry);

  d2x:=Znak(rx);
  d2y:=0;
  m:=ABS(rx);
  n:=ABS(ry);

  IF m<=n THEN
  BEGIN
    d2x:=0;
    d2y:=Znak(ry);
    m:=ABS(ry);
    n:=ABS(rx);
  END;

  s:=m SHR 1;

  FOR l:=0 TO m DO

  BEGIN
    ASM
      Mov  Ax, Y1
      Cmp  Ax, 99
      Ja   @DrugiBufor

      Les  Di, V_Ekran.Ekr1
      Jmp  @DrawPix

      @DrugiBufor:

      Les  Di, V_Ekran.Ekr2
      Sub  Ax, 100

      @DrawPix:

      Shl  Ax, 7
      Add  Di, Ax
      Shl  Ax, 2
      Add  Di, Ax
      Add  Di, X1
      Add  Di, X1
      Mov  Ax, C
      Mov  Es:[Di], Ax
    END;

    s:=s+n;
    IF s>=m THEN
    BEGIN
      s:=s-m;
      X1:=X1+d1x;
      Y1:=Y1+D1Y;
    END ELSE
    BEGIN
      X1:=X1+D2X;
      Y1:=Y1+d2y;
    END;

  END;


END;

PROCEDURE V_Line(Buf:TEkran10Eh; X1, Y1, X2, Y2:Integer;C:Word);
FUNCTION Znak(X:Integer):Integer;
BEGIN
  IF X>0 THEN Znak:=1 ELSE
  IF X<0 THEN Znak:=-1 ELSE
  			  Znak:=0;
END;

PROCEDURE PrzytnijLinieX(VAR X1, Y1, X2, Y2:Integer; Rect:PRect);

VAR a, b:Real;
    Granica:Integer;
    X12, X22, Y22, Y12:LongInt;

BEGIN
  X12:=X1;
  X22:=X2;

  Y12:=Y1;
  Y22:=21;


  Granica:=Rect^.X;
  {PRZECIECIE Z OSIA Z LEWEJ}
  IF (X1<Granica) AND (X2>=Granica) THEN
  BEGIN
    Y12:=(Y1+Round((Y2-Y1)*(Granica-X1)/(X2-X1)));
    X12:=Granica;
  END;

  Granica:=Rect^.X+Rect^.W;
  {PRZECIECIE Z OSIA Z PRAWEJ}
  IF (X1<Granica) AND (X2>=Granica) THEN
  BEGIN
    Y22:=(Y2+Round((Y2-Y1)*(X2-Granica)/(X2-X1)));
    X22:=Granica-1;
  END;

  X1:=X12;
  X2:=X22;
  Y1:=Y12;
  Y2:=Y12;
END;

PROCEDURE PrzytnijLinieY(VAR X1, Y1, X2, Y2:Integer; Rect:PRect);
VAR a, b:Real;
    Granica:Integer;
    X12, X22, Y22, Y12:LongInt;

BEGIN
  X12:=X1;
  X22:=X2;

  Y12:=Y1;
  Y22:=21;


  Granica:=Rect^.Y;
  {PRZECIECIE Z GORNA KRAWEDZIA}
  IF (Y1<Granica) AND (Y2>=Granica) THEN
  BEGIN
    X12:=(X1+Round((X2-X1)*(Granica-Y1)/(Y2-Y1)));
    Y12:=Granica;
  END;

  Granica:=Rect^.Y+Rect^.H;
  {PRZECIECIE Z DOLNA KRAWEDZIA}
  IF (Y1<Granica) AND (Y2>=Granica) THEN
  BEGIN
    X22:=(X2+Round((X2-X1)*(Y2-Granica)/(Y2-Y1)));
    Y22:=Granica-1;
  END;

  X1:=X12;
  X2:=X22;
  Y1:=Y12;
  Y2:=Y12;
END;

VAR l, s, d1x, d1y, d2x,
	  d2y, rx, ry, m, n,
    MaxX, MaxY, MinX, MinY    : Integer;
    Rect:TRect;

BEGIN


  S_Move32(@DefaultRect, @Rect, SizeOf(TRect));

  {OBCINANIE LINI DLA Y}
  IF Y1>Y2 THEN BEGIN MaxY:=Y1;Y1:=Y2;Y2:=MaxY;MaxX:=X1;X1:=X2;X2:=MaxX END;
  IF (Y1>Rect.Y+Rect.H-1) OR (Y2<Rect.Y) THEN Exit;
  IF (Y1<Rect.Y) OR (Y2>Rect.Y+Rect.H-1) THEN PrzytnijLinieY(X1, Y1, X2, Y2, @Rect);

  {OBCINANIE LINI DLA X}
  IF X1>X2 THEN BEGIN MaxY:=Y1;Y1:=Y2;Y2:=MaxY;MaxX:=X1;X1:=X2;X2:=MaxX END;
  IF (X1>Rect.X+Rect.W-1) OR (X2<Rect.X) THEN Exit;
  IF (X1<Rect.X) OR (X2>Rect.X+Rect.W-1) THEN PrzytnijLinieX(X1, Y1, X2, Y2, @Rect);

  rx:=X2-X1;
  ry:=Y2-Y1;

  d1x:=Znak(rx);
  d1y:=Znak(ry);

  d2x:=Znak(rx);
  d2y:=0;
  m:=ABS(rx);
  n:=ABS(ry);

  IF m<=n THEN
  BEGIN
    d2x:=0;
    d2y:=Znak(ry);
    m:=ABS(ry);
    n:=ABS(rx);
  END;

  s:=m SHR 1;

  FOR l:=0 TO m DO

  BEGIN
    IF (Y1>=Rect.Y) AND (Y2<Rect.Y+Rect.H) AND
       (X1>=Rect.X) AND (X2<Rect.X+Rect.W) THEN
    ASM
      Mov  Ax, Y1
      Cmp  Ax, 99
      Ja   @DrugiBufor

      Les  Di, Buf.Ekr1
      Jmp  @DrawPix

      @DrugiBufor:

      Les  Di, Buf.Ekr2
      Sub  Ax, 100

      @DrawPix:

      Shl  Ax, 7
      Add  Di, Ax
      Shl  Ax, 2
      Add  Di, Ax
      Add  Di, X1
      Add  Di, X1
      Mov  Ax, C
      Mov  Es:[Di], Ax
    END;

    s:=s+n;
    IF s>=m THEN
    BEGIN
      s:=s-m;
      X1:=X1+d1x;
      Y1:=Y1+D1Y;
    END ELSE
    BEGIN
      X1:=X1+D2X;
      Y1:=Y1+d2y;
    END;

  END;

END;

{*************************************************************************}
PROCEDURE V_HLineAlpha1(Buf:TEkran10Eh; X, Y, W:Integer;C:Word;Alpha:Byte);
BEGIN

  IF (W<1) OR V_ObetnijHLine(X, Y, W) THEN Exit;

  ASM
    Mov  Ax, Y
    Cmp  Ax, 100

    Ja   @Drugi

    Les  Di, Buf.Ekr1

    Jmp  @Dalej

    @Drugi:

      Les  Di, Buf.Ekr2
      Sub  Ax, 100

    @Dalej:

      Shl  Ax, 7
      Add  Di, Ax
      Shl  Ax, 2
      Add  Di, Ax
      Add  Di, X
      Add  Di, X

      Mov  Cx, W

      Cld

    @Petla:
      Push Cx

      Mov  Cl, Alpha

      Mov  Bx, Es:[Di]
      Mov  Ax, C

      Mov  Dx, Bx
      Shr  Dx, 11
      Shr  Ax, 11
      Add  Dx, Ax
      Shr  Dx, Cl
      Shl  Dx, 11
      Mov  Es:[Di], Dx
      And  Bx, 0000011111111111b

      Mov  Ax, C
      And  Ax, 0000011111111111b
      Mov  Dx, Bx
      Shr  Dx, 5
      Shr  Ax, 5
      Add  Dx, Ax
      Shr  Dx, Cl
      Shl  Dx, 5
      Or   Es:[Di], Dx
      And  Bx, 0000000000011111b

      Mov  Ax, C
      And  Ax, 0000000000011111b
      Mov  Dx, Bx
      Add  Dx, Ax
      Shr  Dx, Cl
      Or   Es:[Di], Dx

      Inc  Di
      Inc  Di

      Pop  Cx

    Loop @Petla

   END;
END;
{*************************************************************************}
PROCEDURE V_RozmyjEkran(Buf:TEkran10Eh; Speed:Byte);
BEGIN
  ASM

    Xor  Dx, Dx
    Mov  Dl, Speed

    Les  Di, Buf.Ekr1
    Mov  Cx, 32000
    Cld

    @Petla:

    Mov  Bx, Es:[Di]
    Mov  Ax, Bx
    Shr  Ax, 11
    Sub  Ax, Dx

    Jnb  @NieZerujAx
    Xor  Ax, Ax

  @NieZerujAx:

    Shl  Ax, 11
    Mov  Es:[Di], Ax
    And  Bx, 0000011111111111b

    Mov  Ax, Bx
    Shr  Ax, 6
    Sub  Ax, Dx

    Jnb  @NieZerujAx2
    Xor  Ax, Ax

  @NieZerujAx2:

    Shl  Ax, 6
    Or   Es:[Di], Ax
    And  Bx, 0000000000011111b

    Sub  Bx, Dx

    Jnb  @NieZerujBx
    Xor  Bx, Bx

  @NieZerujBx:

    Or   Es:[Di], Bx

    Inc  Di
    Inc  Di

  Loop @Petla


    Les  Di, Buf.Ekr2
    Mov  Cx, 32000
    Cld

  @Petla2:

    Mov  Bx, Es:[Di]
    Mov  Ax, Bx
    Shr  Ax, 11
    Sub  Ax, Dx

    Jnb  @NieZerujAx2x
    Xor  Ax, Ax

  @NieZerujAx2x:

    Shl  Ax, 11
    Mov  Es:[Di], Ax
    And  Bx, 0000011111111111b

    Mov  Ax, Bx
    Shr  Ax, 6
    Sub  Ax, Dx

    Jnb  @NieZerujAx22
    Xor  Ax, Ax

  @NieZerujAx22:

    Shl  Ax, 6
    Or   Es:[Di], Ax
    And  Bx, 0000000000011111b

    Sub  Bx, Dx

    Jnb  @NieZerujBx2
    Xor  Bx, Bx

  @NieZerujBx2:

    Or   Es:[Di], Bx

    Inc  Di
    Inc  Di

  Loop @Petla2



  END;
END;
{*************************************************************************}
PROCEDURE V_KopiujObraz(Buf:TEkran10Eh; Obraz:TPicture; X, Y:Integer);

CONST    EW:Word=320;
         EH:Word=200;

VAR Lx,  Rx,  Gy  :Integer;
    LxE, RxE      :Integer;
    DyE, GyE      :Integer;
    Width, Height :Integer;
    CountY        :Integer;
    OffX          :Word;
	  SiGy, DiGyE   :Word;
    GyE2          :Word;
    Add2, TC      :Word;
    BMPx          :Pointer;

BEGIN
  IF NOT Assigned(Obraz) OR NOT Assigned(Obraz^.BMP) THEN Exit;

  WITH Obraz^ DO
  BEGIN

  IF X<0 THEN BEGIN LxE:=0;Lx:=-X;END
         ELSE BEGIN LxE:=X;Lx:= 0;END;

  IF Y<0 THEN BEGIN GyE:=0;Gy:=-Y;END
         ELSE BEGIN GyE:=Y;Gy:= 0;END;

  BMPx:=Obraz^.BMP;

  IF BMPx=NIL THEN Exit;

  IF (Lx>=W) OR (Gy>=H) THEN EXIT;


  IF LxE+W>EW THEN BEGIN RxE:=0;Rx:=Lx+LxE+W-(EW+Lx);END
  			      ELSE BEGIN RxE:=EW+Lx-(W+LxE);Rx:=0;END;

  IF GyE+H-Gy>EH THEN DyE:=0
  			         ELSE DyE:=EH+Gy-(GyE+H);

  OffX:=(LxE+RxE) SHL 1;

  IF EW-LxE-RxE>0 THEN Width :=EW-LxE-RxE ELSE Exit;
  IF EH-GyE-DyE>0 THEN Height:=EH-GyE-DyE ELSE Exit;

  CountY:=101-GyE;

  IF GyE>100 THEN GyE2:=GyE-100 ELSE GyE2:=GyE;
  IF CountY<=0 THEN BEGIN CountY:=0;Add2:=GyE2*(EW SHL 1);END ELSE Add2:=0;

  SiGy :=(Gy   *  W) SHL 1;
  DiGyE:=(GyE2 * EW) SHL 1;

  Lx:=Lx SHL 1;
  Rx:=Rx SHL 1;

  LxE:=LxE SHL 1;
  RxE:=RxE SHL 1;
  TC:=TCol;

  END; {Do With}

  IF Obraz^.Transparent THEN
  ASM
    Push Ds

    {DLA OBRAZU, JESLI WYCHODZI}
    {POZA EKRAN}
    Lds  Si, BMPx
    Add  Si, SiGy

    {DLA EKRANU, JESLI OBRAZ}
	  {ZACZYNA SIE W PEWNYM MOMENCIE}
    Les  Di, Buf.Ekr1
    Add  Di, LxE
    Add  Di, DiGyE

    Cmp  CountY, 0
    Jnz  @NoChangePointer

    Les  Di, Buf.Ekr2
    Mov  CountY, 100
    Add  Di, LxE
    Add  Di, Add2

    @NoChangePointer:

    {ORAZ ILE DODATKOWO  Rep MovSW}
    Mov  Ax, Width

    {ILE LINI MA RYSOWAC}
    Cld
    Mov  Cx, Height
    Inc  Cx

    {PETLA GLOWNA PROCEDURY}
    {KOPIUJACEJ LINIE}
  @KopiujCalosc:

    Dec  CountY
    Jz   @ChangePointer
    Loop @KopiujWiersz
    Jmp  @Koniec

  @ChangePointer:

    Les  Di, Buf.Ekr2
    Mov  CountY, 100
    Add  Di, LxE
    Add  Di, Add2

    Loop @KopiujWiersz
    Jmp  @Koniec

  @KopiujWiersz:

      Push Cx
      Mov  Cx, Ax
      Add  Si, Lx

      @XXX:

      Mov  Dx, [SI]
      Cmp  Dx, TC

      Je   @NieKopiujTego

      Mov  Es:[Di], Dx


      @NieKopiujTego:

      {ZMIANA ADRESOW Di i Si}
      Inc  Di
      Inc  Di
      Inc  Si
      Inc  Si

      Loop @XXX

    @NieKopiujReszty:

      Add  Di, OffX
      Add  Si, Rx
      Pop  Cx
      Jmp  @KopiujCalosc

  @Koniec:

    Pop Ds

  END
  ELSE
  ASM
    Push Ds

    {DLA OBRAZU, JESLI WYCHODZI}
    {POZA EKRAN}
    Lds  Si, BMPx
    Add  Si, SiGy

    {DLA EKRANU, JESLI OBRAZ}
	  {ZACZYNA SIE W PEWNYM MOMENCIE}
    Les  Di, Buf.Ekr1
    Add  Di, LxE
    Add  Di, DiGyE

    Cmp  CountY, 0
    Jnz  @NoChangePointer

    Les  Di, Buf.Ekr2
    Mov  CountY, 100
    Add  Di, LxE
    Add  Di, Add2

    @NoChangePointer:

    {ORAZ ILE DODATKOWO  Rep MovSW}
    Mov  Ax, Width

    {ILE LINI MA RYSOWAC}
    Cld
    Mov  Cx, Height
    Inc  Cx

    {PETLA GLOWNA PROCEDURY}
    {KOPIUJACEJ LINIE}
  @KopiujCalosc:

    Dec  CountY
    Jz   @ChangePointer
    Loop @KopiujWiersz
    Jmp  @Koniec

  @ChangePointer:

    Les  Di, Buf.Ekr2
    Mov  CountY, 100
    Add  Di, LxE
    Add  Di, Add2

    Loop @KopiujWiersz
    Jmp  @Koniec

  @KopiujWiersz:

      Push Cx
      Mov  Cx, Ax
      Mov  Bx, Ax
      And  Bx, 1
      Shr  Cx, 1
      Add  Si, Lx

      {KOPIOWANIE METODA 32 BITOWA}

      Cld
      Db   $F3,$66,$A5

      Mov  Cx, Bx
      Cld
      Rep  MovSW

      Add  Di, OffX
      Add  Si, Rx
      Pop  Cx
      Jmp  @KopiujCalosc

  @Koniec:

    Pop Ds

  END;
END;

{*************************************************************************}

PROCEDURE V_NewImage(VAR Picture:TPicture);
BEGIN

  Picture:=NIL;
  IF MaxAvail<SizeOf(TObraz) THEN EXIT;

  New(Picture);

  Picture^.W:=0;
  Picture^.H:=0;
  Picture^.TCol:=0;
  Picture^.Transparent:=False;
  Picture^.BMP:=NIL;
  Picture^.BPP:=16;
  Picture^.Paleta:=NIL;
END;

{*************************************************************************}

PROCEDURE V_FreeImage(VAR Picture:TPicture);
BEGIN
  IF Picture=NIL THEN Exit;

  IF Picture^.BMP<>NIL THEN
     FreeMem(Picture^.BMP, Picture^.W*Picture^.H*2);

  Dispose(Picture);
  Picture:=NIL;
END;

{*************************************************************************}

PROCEDURE V_WriteXY(Buf:TEkran10Eh;Font:PFont;X, Y:Integer;CONST S:STRING;C:Word;StepX:Byte);

VAR A, B, Count:Byte;
    Ex:Integer;
    Line:Pointer;
    DX0, DY:Integer;
    Change:Integer;
    Nr, SP, Temp:Byte;
    RectX:TRect;

BEGIN
  S_Move32(@DefaultRect, @RectX, SizeOf(TRect));

  IF (Font=NIL) OR (Font^.Wzor=NIL) OR (Font^.TabKon=NIL) OR (Font^.TabAscii=NIL) THEN Exit;

  {Ustalanie liczby wyswietlanych znakow}
  IF (RectX.W+RectX.X-1-X)<StepX THEN Exit;

  Count:=(RectX.W+RectX.X-1-X) DIV StepX;
  IF Byte(S[0])<Count THEN Count:=Byte(S[0]);

  {Kiedy nic nie trzeba rysowac}
  IF (Y<RectX.Y-8) OR (Y>=RectX.Y+RectX.H) OR
     (Count*StepX<RectX.X-X) OR (X>=RectX.W+RectX.X) THEN EXIT;



  DX0:=X;
  SP:=1;

  IF X<RectX.X THEN
     BEGIN
       SP:=((RectX.X-X) DIV StepX);
       IF ((RectX.X-X) MOD StepX<>0) THEN INC(SP);
       DX0:=RectX.X+StepX*SP-(RectX.X-X);
       INC(SP);
     END;

  FOR A:=SP TO Count DO
  BEGIN
    Change:=101-Y;IF Change<0 THEN Change:=0;
    IF Change>0 THEN Line:=Buf.Ekr1 ELSE Line:=Buf.Ekr2;
    Temp:=Font^.TabAscii^[BYTE(S[A])];

    FOR B:=0 TO 7 DO
    BEGIN
      IF (B+Y>=RectX.Y+RectX.H) OR (B+Y<RectX.Y) THEN Continue;

      IF Change>0 THEN
      BEGIN
        Dec(Change);
        IF Change=0 THEN Line:=Buf.Ekr2;
      END;


      IF (Temp>0) AND (Temp<=Font^.MaxL)
         THEN Nr:=Font^.Wzor^[Temp, B]
         ELSE Nr:=BrakZnaku[B];

      IF NOT V_TextNormal THEN Nr:=NOT Nr;
      Ex:=B+Y;
      IF Ex>99 THEN DEC(Ex, 100);

      IF Ex>=100 THEN Break;
      IF Ex>=0 THEN
         ASM
           Les  Di, Line
           Mov  Ax, Ex
           Shl  Ax, 7
           Add  Di, Ax
           Shl  Ax, 2
           Add  Di, Ax
           Mov  Ax, DX0
           Shl  Ax, 1
           Add  Di, Ax

           Mov  Dl, Nr
           Mov  Cx, 8
           Mov  Bl, 10000000b
           Mov  Ax, C

           Cld


           @Rysowanie:

             Test Bl, Dl
             Jz   @NoDraw

             Mov  Es:[Di], Ax

           @NoDraw:

             Shr  Bl, 1
             Inc  Di
             Inc  Di

           Loop @Rysowanie

         END;

    END;

    Inc(DX0, StepX);
  END;

END;


PROCEDURE V_CenterText(Buf:TEkran10Eh;Font:PFont;X, Y:Integer;CONST S:STRING;C:Word;StepX:Byte);
BEGIN
  V_WriteXY(Buf, Font, X-((BYTE(S[0])*StepX) SHR 1), Y, S, C, StepX);
END;

PROCEDURE V_CenterTextRect(Buf:TEkran10Eh;Font:PFont;Rect:TRect;X, Y:Integer;CONST S:STRING;C:Word;StepX:Byte);
BEGIN
  V_WriteXY(Buf, Font, X-((BYTE(S[0])*StepX) SHR 1), Y, S, C, StepX);
END;

PROCEDURE V_CopyLine(Buf:TEkran10Eh; Dest:Pointer; X, Y, W:Integer);
VAR Temp:Pointer;
BEGIN

  IF Y<100 THEN Temp:=Buf.Ekr1 ELSE BEGIN Temp:=Buf.Ekr2;Y:=Y-100;END;

  ASM
    Mov  Cx, W
    Shl  Cx, 1
    Mov  Dx, Cx
    And  Dx, 3
    Shr  Cx, 2

    Push Ds

    Les  Di, Dest
    Lds  Si, Temp

    Mov  Ax, Y
    Shl  Ax, 7
    Add  Si, Ax
    Shl  Ax, 2
    Add  Si, Ax

    Add  Si, X
    Add  Si, X

    Cld
    Db   $F3,$66,$A5

    Mov  Cx, Dx
    Rep  MovSb

    Pop  Ds
  END;
END;

PROCEDURE V_CopyFromLine(Buf:TEkran10Eh; Line:Pointer; X, Y, W:Integer);
VAR Temp:Pointer;
BEGIN

  IF Y<100 THEN Temp:=Buf.Ekr1 ELSE BEGIN Temp:=Buf.Ekr2;Y:=Y-100;END;
  IF X+W>=320 THEN W:=320-X;

  ASM
    Mov  Cx, W
    Shl  Cx, 1
    Mov  Dx, Cx
    And  Dx, 3
    Shr  Cx, 2

    Push Ds

    Les  Di, Temp
    Lds  Si, Line

    Mov  Ax, Y
    Shl  Ax, 7
    Add  Di, Ax
    Shl  Ax, 2
    Add  Di, Ax

    Add  Di, X
    Add  Di, X

    Cld
    Db   $F3,$66,$A5

    Mov  Cx, Dx
    Rep  MovSb

    Pop  Ds
  END;
END;

PROCEDURE V_CreateMirroredBMP(VAR Source, Dest:TPicture);
VAR Temp   : Pointer;
    Tmp    : Pointer;
    Needed : Word;
    W, H   : Integer;
BEGIN
  IF NOT Assigned(Source) OR NOT Assigned(Source^.BMP) THEN Exit;

  IF NOT Assigned(Dest) THEN
     V_NewImage(Dest);

  W:=Source^.W;
  H:=Source^.H;
  Needed:=2*W*H;

  Dest^:=Source^;
  Tmp:=Source^.BMP;

  IF MaxAvail>=Needed THEN
  BEGIN
    GetMem(Temp, Needed);
    Dest^.BMP:=Temp;
  END ELSE Exit;

  ASM
    Push Ds
    Les  Di, Temp
    Lds  Si, Tmp

    Mov  Cx, H

    @kopiujpion:
      Push Cx
      Mov  Cx, W

      Add  Di, Cx
      Add  Di, Cx



        @kopiujpoziom:
          Dec Di
          Dec Di

          Mov Ax,Ds:[Si]
          Mov Es:[Di], Ax

          Inc Si
          Inc Si
        Loop @kopiujpoziom

      Mov  Cx, W

      Add  Di, Cx
      Add  Di, Cx

      Pop Cx
    Loop @kopiujpion

    Pop  Ds
  END;

END;

PROCEDURE V_PrintScreen(CONST Fn:STRING);
TYPE
   TByteArr= ARRAY [ 0..0] OF Byte;
   TWordArr= ARRAY [ 0..0] OF Word;

VAR BMPCapt : TBMPCaption;
    F:FILE;
    Line:Pointer;
    Temp:Pointer;
    i, j:Integer;
    R, G, B:Byte;

BEGIN
  WITH BMPCapt DO
  BEGIN
    BM:=Byte('M') SHL 8 OR Byte('B');
    Size:=SizeOf(TBMPCaption)+V_MaxEX*V_MaxEy*3;
    rezerw:=0;
    obraz_offset:=SizeOf(TBMPCaption);
    info:=40;
    Width:=V_MaxEX;
    Height:=V_MaxEY;
    LPO:=1;
    BPP:=24;
    kompresja:=0;
    Size_Obr:=V_MaxEX*V_MaxEy*3;
    HDPI:=96;
    VDPI:=96;
    Colors:=0;
    UColors:=0;
  END;

  GetMem(Line, V_MaxEX*2);
  GetMem(Temp, V_MaxEX*3);

  Assign(F, Fn);
  Rewrite(F, 1);
  BlockWrite(F, BMPCapt, SizeOf(TBMPCaption));

  FOR i:= V_MaxEY-1 DOWNTO 0 DO
  BEGIN
    V_CopyLine(V_Ekran, Line, 0, i, V_MaxEX*2);
    FOR j:=0 TO V_MaxEX-1 DO
    BEGIN
      V_ToRGB(TWordArr(Line^)[j], R, G, B);
      TByteArr(Temp^)[j*3]:=B;
      TByteArr(Temp^)[j*3+1]:=G;
      TByteArr(Temp^)[j*3+2]:=R;
    END;

    BlockWrite(F, Temp^, V_MaxEX*3);
  END;


  FreeMem(Line, V_MaxEX*2);
  FreeMem(Temp, V_MaxEX*3);

  Close(F);
END;

PROCEDURE ShowCaptionBMP(CONST Fn:STRING);
VAR BMPCapt : TBMPCaption;
    F:FILE;

BEGIN
  Assign(F, Fn);
  Reset(F, 1);
  BlockRead(F, BMPCapt, SizeOf(TBMPCaption));
  Close(F);
  WITH BMPCapt DO
  BEGIN
    WriteLn(Size);
    WriteLn(info);
    WriteLn(rezerw);
    WriteLn(obraz_offset, ' ', SizeOf(TBMPCaption));
    WriteLn(LPO);
    WriteLn(kompresja);
    WriteLn(Colors);
    WriteLn(UColors);
  END;
END;

BEGIN
  DefaultRect:=EkranRect;
END.


