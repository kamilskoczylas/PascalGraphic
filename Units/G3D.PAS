{$N+}
{*************************************************************************}
{*                        MODUL OBSLUGUJACY GRAFIKE 3D                   *}
{*                                                                       *}
{*                        AUTORZY:                                       *}
{*                                                                       *}
{*                          STASZEK KOGUT                                *}
{*                          KAMIL   SKOCZYLAS                            *}
{*************************************************************************}
UNIT G3D;

INTERFACE
USES Graph10E, Standard;

{*************************************************************************}
CONST
  {METODY RYSOWANIA:}
    G3D_METODA_PUNKTOWA            = 1;
    G3D_METODA_SIATKOWA            = 2;
    G3D_METODA_CIENIOWANIE_PLASKIE = 3;
    G3D_METODA_CIENIOWANIE_ZWYKLE  = 4;
    G3D_METODA_TEKSTURA            = 5;
    G3D_METODA_CIENIOWANA_TEKSTURA = 6;

  {SKALOWANIE SWIATLA WEDLUG}

    G3D_WG_ODLEGLOSCI              = 1;
    G3D_WG_KATU                    = 2;

    G3D_KOLOR_MGLY: Word = $FFFF;

  {ODLEGLOSC KAMERY OD MONITORA}
    G3D_Odleglosc = 220;

    SKALUJ_KOLOR  : Byte ={G3D_WG_KATU;}
                           G3D_WG_ODLEGLOSCI;

  {METODA RYSOWANIA}
    G3D_Metoda    : Byte = G3D_METODA_CIENIOWANIE_PLASKIE;

    G3D_HalfX     : Integer = 160;
    G3D_HalfY     : Integer = 100;

    G3D_MaxOdl    : Single =100;
    G3D_MinOdl    : Single =5;
    G3D_MinAlpha  : Single =6;

  {RYSOWANIE PRZEZROCZYSTE}
    G3D_Alpha     : Boolean=False;

  {METODY KOLOROW}
    G3D_Tex16=4;
    G3D_Tex32=5;
    G3D_Tex64=6;
    G3D_Tex128=7;

    G3D_Text_Width : Byte = G3D_Tex128;



{*************************************************************************}

TYPE

  {DEFINICJA WIERZCHOLKA}
  PVertex       =^TVertex;
  TVertex       = RECORD

    {POZYCJE W PRZESTRZENI}
    X, Y, Z     : Single;
    {WSPOLRZEDNE TEKSTURY}
    U, V        : Byte;
    {KOLOR WIERZCHOLKA}
    C           : Word;
  END;


{*************************************************************************}

  {DEFINICJA TROJKATA}

  PTriangle     =^TTriangle;
  TTriangle     = RECORD
    {WIERZCHOLKI}
    Vertex      : ARRAY[0..2] OF TVertex;
    {ODLEGLOSC DO KAMERY}
    Odleglosc   : Single;
    Tekstura    : Pointer;
  END;


  {DEFINICJA TROJKATA}
  PVertex2D    =^TVertex2D;
  TVertex2D    = RECORD
    X, Y         : Integer;

  END;

  {DEFINICJA MACIERZY}

  PMatrix       =^TMatrix;
  TMatrix       = RECORD
    W, H        : Integer;
    Start       : PVertex;
    Copy        : PVertex2D;
  END;


{*************************************************************************}

VAR G3D_Sin     : ARRAY[0..255] OF Single;
    G3D_Cos     : ARRAY[0..255] OF Single;

    Swiatlo     : TVertex;

{*************************************************************************}
{PRZESUWA KAZDY WIERZCHOLEK TROJKATA O PODANY WEKTOR}
PROCEDURE G3D_Transform(Source:PTriangle; Vector:PVertex; Count:Word);
{*************************************************************************}
{OBRACA O KAT WSKAZANE TROJKATY}
PROCEDURE G3D_Rotate(Source:PTriangle; KatX, KatY, KatZ:Byte; Count:Word);
{*************************************************************************}
{RYSUJE W BUFORZE OBIEKTY 3D}
PROCEDURE G3D_Render(Source:PTriangle;Count:Word);
{*************************************************************************}
{WCZYTUJE OBIEKT 3D Z PLIKU}
FUNCTION G3D_Load(CONST Fn:STRING;VAR Count:Word):PTriangle;
{*************************************************************************}
PROCEDURE G3D_AssignTexture(Source:PTriangle;Size:Word;Texture:TPicture);

IMPLEMENTATION

USES Polygons;
{*************************************************************************}
TYPE
  TCompareFunc = FUNCTION ( a, b : Pointer ) : Integer;
{*************************************************************************}
{$F+}
FUNCTION Compare( a, b : Pointer ) : Integer;
VAR T1, T2 : PTriangle;
BEGIN
  T1:=a;
  T2:=b;

  {SPRAWDZA KTORA WARTOSC JEST WIEKSZA}
  IF T1^.Odleglosc>T2^.Odleglosc THEN Compare:=-1
                                 ELSE Compare:= 1;
END;
{$F-}
{*************************************************************************}
PROCEDURE InsertSort( t           : Pointer;
                      size, count : Integer;
                      compare     : TCompareFunc );
VAR
  i, j     : Integer;
  valuePos : Integer;
  tmp      : Pointer;
  tmpMem   : Pointer;

BEGIN
  valuePos := 0;
  tmp := t;
  tmpMem := NIL;
  GetMem( tmpMem, size );
  Move( t^, tmpMem^, size );
  FOR i := 1 TO (count - 1)
  DO BEGIN
    Inc( LongInt(tmp), size );
    IF ( compare( tmp, tmpMem ) < 0 )
    THEN BEGIN
      Move( tmp^, tmpMem^, size );
      valuePos := i;
    END;
  END;
  Move( t^, Pointer(LongInt(t) + size * valuePos)^, size );
  Move( tmpMem^, t^, size );
  FOR j := 1 TO (count - 1)
  DO BEGIN
    tmp := t;
    Inc( LongInt(t), size );
    Move( t^, tmpMem^, size );
    i := j - 1;
    WHILE ( compare( tmpMem, tmp ) < 0 )
    DO BEGIN
      Move( tmp^, Pointer(LongInt(tmp) + size)^, size );
      Dec( LongInt(tmp) , size );
    END;
    Move( tmpMem^, Pointer(LongInt(tmp) + size)^, size );
  END;
  FreeMem( tmpMem, size );
END;
{*************************************************************************}

{*************************************************************************}
PROCEDURE G3D_Transform(Source:PTriangle; Vector:PVertex; Count:Word);

VAR I     : Word;

BEGIN
  IF NOT Assigned(Source) THEN Exit;
  {DLA Count TROJKATOW}
  FOR I:=1 TO Count DO
  BEGIN
    {PRZESUNI¨CIE KAZDEJ WARTOSCI O WEKTOR, TROJKAT 1}
    Source^.Vertex[0].X:=Source^.Vertex[0].X+Vector^.X;
    Source^.Vertex[0].Y:=Source^.Vertex[0].Y+Vector^.Y;
    Source^.Vertex[0].Z:=Source^.Vertex[0].Z+Vector^.Z;

    {PRZESUNI¨CIE KAZDEJ WARTOSCI O WEKTOR, TROJKAT 2}
    Source^.Vertex[1].X:=Source^.Vertex[1].X+Vector^.X;
    Source^.Vertex[1].Y:=Source^.Vertex[1].Y+Vector^.Y;
    Source^.Vertex[1].Z:=Source^.Vertex[1].Z+Vector^.Z;

    {PRZESUNI¨CIE KAZDEJ WARTOSCI O WEKTOR, TROJKAT 3}
    Source^.Vertex[2].X:=Source^.Vertex[2].X+Vector^.X;
    Source^.Vertex[2].Y:=Source^.Vertex[2].Y+Vector^.Y;
    Source^.Vertex[2].Z:=Source^.Vertex[2].Z+Vector^.Z;

    {PRZEJSCIE DO NASTEPNEGO TROJKATA}
    Inc(Source);
  END;
END;
{*************************************************************************}

PROCEDURE G3D_RotateVertex(Source:PVertex; KatX, KatY, KatZ:Byte; Count:Word);

VAR I     : Word;
    Temp  : Single;

BEGIN
  IF NOT Assigned(Source) THEN Exit;

  FOR I:=1 TO Count DO
  BEGIN
    {OBROT WOKOL OSI Y :}
    IF KatY>0 THEN
    BEGIN
      Temp:=Source^.Z*G3D_Sin[KatY]+Source^.X*G3D_Cos[KatY];
      Source^.Z:=Source^.Z*G3D_Cos[KatY]-Source^.X*G3D_Sin[KatY];;
      Source^.X:=Temp;
    END;

    {OBROT WOKOL OSI X :}
    IF KatX>0 THEN
    BEGIN
      Temp:=Source^.Y*G3D_Sin[KatX]+Source^.Z*G3D_Cos[KatX];
      Source^.Y:=(Source^.Y*G3D_Cos[KatX]-Source^.Z*G3D_Sin[KatX]);
      Source^.Z:=Temp;
    END;

    {OBROT WOKOL OSI Z :}
    IF KatZ>0 THEN
    BEGIN
      Temp:=Source^.Y*G3D_Sin[KatZ]+Source^.X*G3D_Cos[KatZ];
      Source^.Y:=(Source^.Y*G3D_Cos[KatZ]-Source^.X*G3D_Sin[KatZ]);
      Source^.X:=Temp;
    END;

    {PRZEJSCIE DO NASTEPNEGO WIERZCHOLKA}
    Inc(Source);
  END;
END;

{*************************************************************************}
PROCEDURE G3D_Rotate(Source:PTriangle; KatX, KatY, KatZ:Byte; Count:Word);
VAR I     : Word;
BEGIN
  IF NOT Assigned(Source) THEN Exit;
  {PETLA DLA Count TROJKATOW}
  FOR I:=1 TO Count DO
  BEGIN
    {PRZEKSZTALCA O KAT 3 WIERZCHOLKI}
    G3D_RotateVertex(@Source^.Vertex[0], KatX, KatY, KatZ, 3);

    {PRZECHODZI DO NASTEPNEGO TROJKATA}
    Inc(Source);
  END;
END;

{*************************************************************************}
FUNCTION G3D_OdlegloscDoKamery(Source:PTriangle):Single;
BEGIN
  {ODLEGLOSC ZBADANA -SREDNIA}
  G3D_OdlegloscDoKamery:=(Sqrt(Sqr(Source^.Vertex[0].X)+Sqr(Source^.Vertex[0].Y)+Sqr(Source^.Vertex[0].Z))+
                          Sqrt(Sqr(Source^.Vertex[1].X)+Sqr(Source^.Vertex[1].Y)+Sqr(Source^.Vertex[1].Z))+
                          Sqrt(Sqr(Source^.Vertex[2].X)+Sqr(Source^.Vertex[2].Y)+Sqr(Source^.Vertex[2].Z)))/3;
END;
{*************************************************************************}

PROCEDURE G3D_SortTriangles(Source:PTriangle; Count:Word);
VAR Temp  : PTriangle;
    I     : Word;
BEGIN
  IF NOT Assigned(Source) THEN Exit;
  {TWORZENIE KOPII ADRESU PAMIECI POCZATKU TROJKATOW}
  temp:=Source;

  {PETLA NA Count RAZY}
  FOR I:=1 TO Count DO
  BEGIN
    {LICZY ODLEGLOSC NAJDALEJ POLOZONEGO PUNKTU TROJKATA DO KAMERY}
    Source^.Odleglosc:=G3D_OdlegloscDoKamery(Source);

    {KOLEJNY TROJKAT}
    Inc(Source);
  END;

  {SORTOWANIE TROJKATOW}
  InsertSort(Temp, SizeOf(TTriangle), Count, Compare);

END;

{*************************************************************************}
PROCEDURE NormalizujWektor(Triangle:PTriangle;VAR Temp:TVertex);

VAR
    Dl:Double;
BEGIN
  WITH Triangle^ DO
  BEGIN
    Temp.X:=(Vertex[0].X-Vertex[1].X)*(Vertex[2].X-Vertex[1].X);
    Temp.Y:=(Vertex[0].Y-Vertex[1].Y)*(Vertex[2].Y-Vertex[1].Y);
    Temp.Z:=(Vertex[0].Z-Vertex[1].Z)*(Vertex[2].Z-Vertex[1].Z);
  END;

  Dl:=Sqrt(Temp.X*Temp.X+Temp.Y*Temp.Y+Temp.Z*Temp.Z);

  {WEKTOR BEDZIE Z PRZEDZIALU -1 , 1}
  IF Dl<>0 THEN
  BEGIN
    Temp.X:=Temp.X/Dl;
    Temp.Y:=Temp.Y/Dl;
    Temp.Z:=Temp.Z/Dl;
  END ELSE
  BEGIN
    Temp.X:=0;
    Temp.Y:=0;
    Temp.Z:=0;
  END;

END;


{*************************************************************************}

FUNCTION SkalujKolor(Tr:PTriangle):Word;
VAR R, G, B:Byte;
    R1, G1, B1:Byte;
    Ws:Single;
    Temp:TVertex;
BEGIN
  IF SKALUJ_KOLOR=G3D_WG_ODLEGLOSCI THEN
  BEGIN
    V_ToRGB(Tr^.Vertex[0].C, R, G, B);
    V_ToRGB(G3D_KOLOR_MGLY, R1, G1, B1);

    Ws:=Tr^.Odleglosc/G3d_MaxOdl;
    SkalujKolor:=V_RGB(R-Round((R-R1)*Ws), G-Round((G-G1)*Ws), B-Round((B-B1)*Ws));
  END ELSE
  BEGIN
    V_ToRGB(Tr^.Vertex[0].C, R, G, B);

    NormalizujWektor(Tr, Temp);

    Ws:=Temp.X*Swiatlo.X+Temp.Y*Swiatlo.Y+Temp.Z*Swiatlo.Z;

    SkalujKolor:=V_RGB(R-Round(R*Ws), G-Round(G*Ws), B-Round(B*Ws));
  END;
END;

{*************************************************************************}

PROCEDURE G3D_Render(Source:PTriangle;Count:Word);
VAR X1, Y1,
    X2, Y2,
    X3, Y3  : Integer;

    I       : Word;
    Kol     : Word;
BEGIN
  IF NOT Assigned(Source) THEN Exit;

  {SORTOWANIE TROJKATOW PRZED WYSWIETLENIEM}
  G3D_SortTriangles(Source, Count);

  {PRZELICZANIE TROJKATOW W PRZESTRZENI NA DWUWYMIAROWE}
  FOR I:=1 TO Count DO
  BEGIN
    IF (Source^.Odleglosc>G3D_MaxOdl) OR (Source^.Odleglosc<G3D_MinOdl) OR ((Source^.Vertex[0].Z<G3D_MinOdl)
       OR (Source^.Vertex[1].Z<G3D_MinOdl) OR (Source^.Vertex[2].Z<G3D_MinOdl))
    THEN
      BEGIN
        Inc(Source);
        Continue;
      END;


    X1:=G3D_HalfX+Trunc(G3D_Odleglosc*Source^.Vertex[0].X/Source^.Vertex[0].Z);
    Y1:=G3D_HalfY-Trunc(G3D_Odleglosc*Source^.Vertex[0].Y/Source^.Vertex[0].Z);

    X2:=G3D_HalfX+Trunc(G3D_Odleglosc*Source^.Vertex[1].X/Source^.Vertex[1].Z);
    Y2:=G3D_HalfY-Trunc(G3D_Odleglosc*Source^.Vertex[1].Y/Source^.Vertex[1].Z);

    X3:=G3D_HalfX+Trunc(G3D_Odleglosc*Source^.Vertex[2].X/Source^.Vertex[2].Z);
    Y3:=G3D_HalfY-Trunc(G3D_Odleglosc*Source^.Vertex[2].Y/Source^.Vertex[2].Z);


    {WYBOR METODY RYSOWANIA}
    CASE G3D_Metoda OF

      G3D_METODA_PUNKTOWA:
        BEGIN
          V_Pix(V_Ekran, X1, Y1, Source^.Vertex[0].C);
          V_Pix(V_Ekran, X2, Y2, Source^.Vertex[1].C);
          V_Pix(V_Ekran, X3, Y3, Source^.Vertex[2].C);
        END;

      G3D_METODA_SIATKOWA:
        BEGIN
          V_Line(V_Ekran, X1, Y1, X2, Y2, Source^.Vertex[0].C);
          V_Line(V_Ekran, X2, Y2, X3, Y3, Source^.Vertex[1].C);
          V_Line(V_Ekran, X3, Y3, X1, Y1, Source^.Vertex[2].C);
        END;

      G3D_METODA_CIENIOWANIE_PLASKIE:
      BEGIN

         Source^.Vertex[0].X:=X1;
         Source^.Vertex[0].Y:=Y1;

         Source^.Vertex[1].X:=X2;
         Source^.Vertex[1].Y:=Y2;

         Source^.Vertex[2].X:=X3;
         Source^.Vertex[2].Y:=Y3;

         Kol:=SkalujKolor(Source);

         IF (G3D_Alpha) AND (Source^.Odleglosc<G3D_MinAlpha) THEN
              G3D_RysujTrojkatAlpha(Source, Source^.Vertex[0].C)
         ELSE G3D_RysujTrojkat(Source, Kol);
      END;

      G3D_METODA_CIENIOWANIE_ZWYKLE:
      BEGIN
         Source^.Vertex[0].X:=X1;
         Source^.Vertex[0].Y:=Y1;

         Source^.Vertex[1].X:=X2;
         Source^.Vertex[1].Y:=Y2;

         Source^.Vertex[2].X:=X3;
         Source^.Vertex[2].Y:=Y3;

         G3D_RysujTrojkatRGB(Source);
      END;

      G3D_METODA_TEKSTURA:
      BEGIN
         Source^.Vertex[0].X:=X1;
         Source^.Vertex[0].Y:=Y1;

         Source^.Vertex[1].X:=X2;
         Source^.Vertex[1].Y:=Y2;

         Source^.Vertex[2].X:=X3;
         Source^.Vertex[2].Y:=Y3;

         G3D_RysujTrojkatTex(V_Ekran, Source^.Tekstura, Source, G3D_Text_Width);
      END;

    END; {Case'a}

    {Kolejny trojkat}
    Inc(Source);

  END;

END;
{*************************************************************************}
PROCEDURE G3D_NewMatrix(VAR Matrix:PMatrix; W, H:Integer);
BEGIN
  {JEZELI BRAKUJE PAMIECI}
  IF MaxAvail<(W+1)*(H+1)*SizeOf(PVertex)+SizeOf(Matrix)+(W+1)*(H+1)*SizeOf(TVertex2D) THEN Exit;

  {NOWA MACIERZ}
  New(Matrix);

  {ROZMIAR MACIERZY}
  Matrix^.W:=W;
  Matrix^.W:=H;

  {PAMIEC DLA TROJKATOW}
  GetMem(Matrix^.Start, (W+1)*(H+1)*SizeOf(TVertex)+(W+1)*(H+1)*SizeOf(TVertex2D));
  GetMem(Matrix^.Copy,  (W+1)*(H+1)*SizeOf(TVertex2D));

END;

{*************************************************************************}
PROCEDURE G3D_FreeMatrix(VAR Matrix:PMatrix; W, H:Integer);
BEGIN
  {JEZELI NIE BYLO TAKIEJ MACIERZY}
  IF Matrix=NIL THEN Exit;

  {ZWALNIANIE PAMIECI DLA TROJKATOW}
  IF Matrix^.Start<>NIL THEN FreeMem(Matrix^.Start, (W+1)*(H+1)*SizeOf(TVertex));
  IF Matrix^.Copy <>NIL THEN FreeMem(Matrix^.Copy,  (W+1)*(H+1)*SizeOf(TVertex2D));

  {ZWALNIANIE STRUKTURY}
  Dispose(Matrix);

END;

{*************************************************************************}

PROCEDURE G3D_RenderMatrix(Source:PMatrix);
VAR X1, Y1,
    X2, Y2,
    X3, Y3  : Integer;

    I, J    : Word;
    Count   : Word;
    Temp    : PVertex2D;
    TempX   : PVertex;

    Matrix  : ARRAY[0..0, 0..0] OF TVertex2D;

BEGIN


  Count:=(Source^.W+1)*(Source^.H+1);

  Temp  :=Source^.Copy;
  TempX :=Source^.Start;


  {PRZELICZANIE TROJKATOW W PRZESTRZENI NA DWUWYMIAROWE}
  FOR I:=1 TO Count DO
  BEGIN

    {$R-}
    Temp^.X:=G3D_HalfX+Trunc(G3D_Odleglosc*TempX^.X/TempX^.Z);
    Temp^.Y:=G3D_HalfY-Trunc(G3D_Odleglosc*TempX^.Y/TempX^.Z);
    {$R+}

    Inc(TempX);
    Inc(Temp);
  END;

  TempX :=Source^.Start;
  Temp  :=Source^.Copy;

  {PRZELICZANIE TROJKATOW W PRZESTRZENI NA DWUWYMIAROWE}
  FOR I:=1 TO Source^.W DO
  FOR J:=1 TO Source^.H DO

  BEGIN


    {WYBOR METODY RYSOWANIA}
    CASE G3D_Metoda OF

      G3D_METODA_PUNKTOWA:
        BEGIN
          V_Pix(V_Ekran, Temp^.X, Temp^.Y, TempX^.C);
        END;
{
      G3D_METODA_SIATKOWA:
        BEGIN
          V_Line(Ekran, X1, Y1, X2, Y2, Source^.Vertex[0].C);

        END;

      G3D_METODA_CIENIOWANIE_PLASKIE:
      BEGIN
         Source^.Vertex[0].X:=X1;
         Source^.Vertex[0].Y:=Y1;

         Source^.Vertex[1].X:=X2;
         Source^.Vertex[1].Y:=Y2;

         Source^.Vertex[2].X:=X3;
         Source^.Vertex[2].Y:=Y3;

         IF (G3D_Alpha) AND (Source^.Odleglosc<G3D_MinAlpha) THEN
              G3D_RysujTrojkatAlpha(Source, Source^.Vertex[0].C)
         ELSE G3D_RysujTrojkat(Source, Source^.Vertex[0].C);
      END;

      G3D_METODA_CIENIOWANIE_ZWYKLE:
      BEGIN
         Source^.Vertex[0].X:=X1;
         Source^.Vertex[0].Y:=Y1;

         Source^.Vertex[1].X:=X2;
         Source^.Vertex[1].Y:=Y2;

         Source^.Vertex[2].X:=X3;
         Source^.Vertex[2].Y:=Y3;

         G3D_RysujTrojkatRGB(Source);
      END;

      G3D_METODA_TEKSTURA:
      BEGIN
         Source^.Vertex[0].X:=X1;
         Source^.Vertex[0].Y:=Y1;

         Source^.Vertex[1].X:=X2;
         Source^.Vertex[1].Y:=Y2;

         Source^.Vertex[2].X:=X3;
         Source^.Vertex[2].Y:=Y3;

         G3D_RysujTrojkatTex(Ekran, Source^.Tekstura, Source, G3D_Tex64);
      END;
    }
    END; {Case'a}

    {Kolejny trojkat}
    Inc(Temp);

  END;

END;

{*************************************************************************}
FUNCTION G3D_Load(CONST Fn:STRING;VAR Count:Word):PTriangle;
VAR F     : Text;
    i, j  : Word;

    Temp  : PTriangle;
    Vert  : PVertex;
BEGIN

  {NIE MA ZADNYCH DANYCH}
  Count:=0;
  i:=0;
  G3D_Load:=NIL;

  {KOJARZENIE I OTWIERANIE PLIKU}
  Assign(F, Fn);
  {$I-}
  Reset(F);
  {$I+}

  {JESLI BEDA BLEDY ZE ZNALEZIENIEM PLIKU WRACA}
  IF (IoResult<>0) THEN Exit;

  {ILE BEDZIE}
  ReadLn(F, Count);

  {JESLI BEDA BLEDY PAMIECI WRACA}
  IF (MemAvail<Count*SizeOf(TTriangle)) THEN Exit;

  {DEKLARUJE PAMIEC I JA CZYSCI}
  GetMem(Temp, Count*SizeOf(TTriangle));
  S_FillChar32(Temp, Count*SizeOf(TTriangle), 0);
  G3D_Load:=Temp;

  {DOPOKI NIE NAPOTKA KONCA PLIKU LUB DANYCH}
  WHILE NOT Eof(F) AND (i<Count) DO
  BEGIN
    FOR j:=0 TO 2 DO
    BEGIN
      {POBIERA ADRES TROJKATA}
      Vert:=@Temp^.Vertex[j];

      {WCZYTUJE WSZYSTKIE WSPOLRZEDNE WIERZCHOLKA}
      ReadLn(F, Vert^.X, Vert^.Y, Vert^.Z, Vert^.U, Vert^.V, Vert^.C);
    END;

    Inc(Temp);
    Inc(i);
  END;

  {ZAMYKA PLIK}
  Close(F);

END;
{*************************************************************************}
PROCEDURE G3D_AssignTexture(Source:PTriangle;Size:Word;Texture:TPicture);
VAR i:Word;
BEGIN
  IF Assigned(Source) THEN
  FOR i:= 1 TO Size DO
  BEGIN
    Source^.Tekstura:=Texture;
    Inc(Source);
  END;
END;

{*************************************************************************}
VAR A     : Integer;
BEGIN
  {OBLICZANIE TABLICY POMOCNICZEJ SINUSOW I COSINUSOW}
  FOR A:=1 TO 256 DO
    BEGIN
      G3D_Sin[A-1]:=Sin((A/256*360)*Pi/180);
      G3D_Cos[A-1]:=Cos((A/256*360)*Pi/180);
    END;

  Swiatlo.X:=0;
  Swiatlo.Y:=0;
  Swiatlo.Z:=10;
END.