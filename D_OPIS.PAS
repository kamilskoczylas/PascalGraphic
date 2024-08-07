{$N+}
UNIT D_OPIS;

INTERFACE


PROCEDURE PokazOpis;

IMPLEMENTATION
USES G3d,
     Graph10E,
     Keyb_X,
     D_Effect,
     D_Types,
     Standard;


CONST Nr:Byte=0;
VAR Bitmap:TPicture;
    Ax:Single;
    Dane3d, Temp3d : PTriangle;
    Size3d  : Word;



PROCEDURE NextDescript;
BEGIN

  V_FreeImage(Bitmap);

  Inc(Nr);
  IF Nr>MaxFig THEN Nr:=1;

  V_NewImage(Bitmap);
  V_LoadBMP24(Bitmap, mDirectory+File3dName+IntToStr(Nr)+File3dExt);

  IF Assigned(Bitmap) THEN Bitmap^.Transparent:=TRUE;

  G3D_AssignTexture(Dane3d, Size3d, Bitmap);

  Vector.Z:=0;
  Ax:=0.001;
  KatZ:=128;
  KatX:=64;

END;


PROCEDURE PokazOpis;
VAR Stars:PStar;
BEGIN

  Nr:=0;

  Dane3d:=NIL;
  Temp3d:=NIL;

  Dane3d:=G3d_Load(mDirectory+File3dDesc, Size3d);
  IF MaxAvail<Size3d*SizeOf(TTriangle) THEN
     BEGIN
       Temp3d:=NIL;
       IF Dane3d<>NIL THEN
       FreeMem(Dane3d, Size3d*SizeOf(TTriangle));
       Dane3d:=NIL;
       Exit;
     END;

  GetMem(Temp3d, Size3d*SizeOf(TTriangle));

  V_NewImage(Bitmap);
  NextDescript;

  Opcja:=0;
  Stars:=GetBufStars(1);

      KatX:=64;
      KatY:=0;



      Vector.X:=0;
      Vector.Y:=-7;
      Vector.Z:=0;

      G3D_METODA:=G3D_METODA_TEKSTURA;
      G3D_MaxOdl:=500;

  REPEAT
    {CZYSCI EKRAN}
    V_ClearScreen(V_Ekran, 0);

    {RYSUJE GWIAZDY}
    RenderStars(V_Ekran, Stars, 1);

    {KOPIUJE TROJKATY}
    S_Move32(Dane3d, Temp3d, Size3d*SizeOf(TTriangle));

    {OBRACA I PRZESUWA OBIEKT}

    IF Nr=4 THEN Inc(KatZ);
    IF (Vector.Z>G3d_MaxOdl*0.25) AND (KatX>10) THEN Dec(KatX);

    G3D_Rotate(Temp3d, KatX, KatY, KatZ, Size3d);
    G3D_Transform(Temp3d, @Vector, Size3d);

    {RYSUJE TROJKATY W BUFORZE}
    G3D_Render(Temp3d, Size3d);

    Ax:=Ax+0.001;
    Vector.Z:=Vector.Z+Ax;
    IF Vector.Z>G3d_MaxOdl THEN NextDescript;


    {POWROT}
    V_VRet;

    {RYSUJE}
    V_FlipBuf(V_Ekran);

  UNTIL Key[VK_ESC];

  FreeStarsBuf(Stars, 1);
  V_FreeImage(Bitmap);

  IF Dane3d<>NIL THEN
     FreeMem(Dane3d, Size3d*SizeOf(TTriangle));

  IF Temp3d<>NIL THEN
     FreeMem(Temp3d, Size3d*SizeOf(TTriangle));

  Dane3d:=NIL;
  Temp3d:=NIL;

  G3D_METODA:=G3D_METODA_CIENIOWANIE_PLASKIE;
  G3D_MaxOdl:=200;
END;

END.