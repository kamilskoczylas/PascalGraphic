{$N+}
UNIT Polygons;

{*************************************************************************}
INTERFACE

USES G3D, Standard, Graph10E;

{*************************************************************************}

PROCEDURE G3D_RysujTrojkatAlpha(Tr:PTriangle;C:Word);
PROCEDURE G3D_RysujTrojkat(Tr:PTriangle;C:Word);
PROCEDURE G3D_RysujTrojkatTex(Buf:TEkran10Eh; Tex:Pointer;Tr:PTriangle;Col:Byte);
PROCEDURE G3D_RysujTrojkatRGB(Tr:PTriangle);

IMPLEMENTATION

{*************************************************************************}
PROCEDURE Zamien(S1,S2:PVertex);

VAR P:TVertex;
BEGIN
  S_Move32(S1, @P, SizeOf(TVertex));
  S_Move32(S2, S1, SizeOf(TVertex));
  S_Move32(@P, S2, SizeOf(TVertex));
END;

{*************************************************************************}

FUNCTION GetFromImage(Txt:Pointer;U, V, CountColors:Byte):Word;ASSEMBLER;
ASM
  Les Bx, Txt
  Mov Cl, CountColors
  Inc Cl
  Xor Ax, Ax
  Mov Al, V
  Shl Ax, Cl
  Xor Cx, Cx
  Add Cl, U
  Shl Cx, 1
  Add Bx, Cx
  Add Bx, Ax

  Mov Ax, ES:[Bx]

END;


{*************************************************************************}

PROCEDURE G3D_RysujTrojkatAlpha(Tr:PTriangle;C:Word);
VAR I, J    : Integer;
    Wa, Wb  : Single;
    P1, P2  : TVertex;
    X, Y, W : Integer;
    StartXa,
    StartXb : Single;

BEGIN
  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);
  IF Tr^.Vertex[1].Y>Tr^.Vertex[2].Y THEN Zamien(@Tr^.Vertex[1], @Tr^.Vertex[2]);
  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);

  IF Tr^.Vertex[1].Y<>Tr^.Vertex[0].Y THEN
     Wa:=(Tr^.Vertex[1].X-Tr^.Vertex[0].X-1)/ABS(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y) ELSE Wa:=0.1;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[0].Y THEN
     Wb:=(Tr^.Vertex[2].X-Tr^.Vertex[0].X)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y) ELSE Wb:=0.1;

  StartXa:=Tr^.Vertex[0].X;
  StartXb:=Tr^.Vertex[0].X;

  FOR I:=Integer(Trunc(Tr^.Vertex[0].Y)) TO Integer(Trunc(Tr^.Vertex[1].Y))-1 DO
  BEGIN
    P1.X:=StartXa;
    P1.Y:=I;

    P2.X:=StartXb;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    IF P1.X>P2.X THEN Zamien(@P1, @P2);

    {$R-}
    X:=Trunc(P1.X);
    Y:=I;
    W:=Trunc(P2.X)-Trunc(P1.X)+1;
    {$R+}
    IF W<1 THEN Continue;
    V_HLineAlpha1(V_Ekran, X, Y, W, C, 1);
  END;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[1].Y THEN
     Wa:=(Tr^.Vertex[2].X-Tr^.Vertex[1].X)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y) ELSE Wa:=0.01;

  StartXa:=Tr^.Vertex[1].X;


  FOR I:=Integer(Trunc(Tr^.Vertex[1].Y)) TO Integer(Trunc(Tr^.Vertex[2].Y)-1) DO
  BEGIN
    P1.X:=StartXa;
    P2.X:=StartXb;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    IF P1.X>P2.X THEN Zamien(@P1, @P2);
    {$R-}
    X:=Trunc(P1.X);
    Y:=I;
    W:=Trunc(P2.X)-Trunc(P1.X)+1;
    {$R+}
    IF W<1 THEN Continue;

    V_HLineAlpha1(V_Ekran, X, Y, W, C, 1);
  END;
END;
{*************************************************************************}

PROCEDURE G3D_RysujTrojkat(Tr:PTriangle;C:Word);
VAR I, J    : Integer;
    Wa, Wb  : Single;
    P1, P2  : TVertex;
    X, Y, W : Integer;
    StartXa,
    StartXb : Single;
    Y1, Y2, Y3:Integer;

BEGIN
  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);
  IF Tr^.Vertex[1].Y>Tr^.Vertex[2].Y THEN Zamien(@Tr^.Vertex[1], @Tr^.Vertex[2]);
  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);

  IF Tr^.Vertex[1].Y<>Tr^.Vertex[0].Y THEN
     Wa:=(Tr^.Vertex[1].X-Tr^.Vertex[0].X-1)/ABS(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y) ELSE Wa:=0.1;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[0].Y THEN
     Wb:=(Tr^.Vertex[2].X-Tr^.Vertex[0].X)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y) ELSE Wb:=0.1;

  StartXa:=Tr^.Vertex[0].X;
  StartXb:=Tr^.Vertex[0].X;

  Y1:=Trunc(Tr^.Vertex[0].Y);
  Y2:=Trunc(Tr^.Vertex[1].Y);

  IF (Y1<DefaultRect.Y) THEN
  BEGIN
    StartXa:=StartXa+Wa*(DefaultRect.Y-Y1);
    StartXb:=StartXb+Wb*(DefaultRect.Y-Y1);

    Y1:=DefaultRect.Y;
  END;

  IF (Y2>DefaultRect.Y+DefaultRect.W) THEN Y2:=DefaultRect.Y+DefaultRect.W;


  IF Y2>DefaultRect.Y THEN
  FOR I:=Y1 TO Y2-1 DO
  BEGIN
    P1.X:=StartXa;
    P1.Y:=I;

    P2.X:=StartXb;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    IF P1.X>P2.X THEN Zamien(@P1, @P2);

    {$R-}
    X:=Trunc(P1.X);
    W:=Trunc(P2.X)-Trunc(P1.X)+1;
    {$R+}
    IF W<1 THEN Continue;
    V_HLine(V_Ekran, X, I, W, C);
  END;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[1].Y THEN
     Wa:=(Tr^.Vertex[2].X-Tr^.Vertex[1].X)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y) ELSE Wa:=0.1;

  StartXa:=Tr^.Vertex[1].X;
  StartXb:=Tr^.Vertex[0].X+Wb*(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y);

  Y2:=Trunc(Tr^.Vertex[1].Y);
  Y3:=Trunc(Tr^.Vertex[2].Y);

  IF Y3>DefaultRect.Y+DefaultRect.W THEN Y3:=DefaultRect.Y+DefaultRect.W;

  IF Y2<DefaultRect.Y+DefaultRect.W THEN
  FOR I:=Y2 TO Y3-1 DO
  BEGIN
    P1.X:=StartXa;
    P2.X:=StartXb;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    IF P1.X>P2.X THEN Zamien(@P1, @P2);
    {$R-}
    X:=Trunc(P1.X);
    W:=Trunc(P2.X)-Trunc(P1.X)+1;
    {$R+}
    IF W<1 THEN Continue;

    V_HLine(V_Ekran, X, I, W, C);
  END;
END;
{*************************************************************************}

PROCEDURE G3D_RysujTrojkatRGB(Tr:PTriangle);
VAR I, J    : Integer;
    Wa, Wb  : Single;
    P1, P2  : TVertex;
    X, Y, W : Integer;
    StartXa,
    StartXb : Single;
    C       : Word;

    R1, G1, B1 : Byte;
    R2, G2, B2 : Byte;
    R3, G3, B3 : Byte;

    R, G, B    : Single;

    DHr, DHg, DHb : Single;

    DVr1, DVg1, DVb1 : Single;
    DVr2, DVg2, DVb2 : Single;

    DVrt, DVgt, DVbt : Single;


    AR1, AG1, AB1 : Single;
    AR2, AG2, AB2 : Single;
    ART, AGT, ABT : Single;

    PR, PG, PB : Single;


BEGIN



  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);
  IF Tr^.Vertex[1].Y>Tr^.Vertex[2].Y THEN Zamien(@Tr^.Vertex[1], @Tr^.Vertex[2]);
  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);

  IF Tr^.Vertex[1].Y<>Tr^.Vertex[0].Y THEN
     Wa:=(Tr^.Vertex[1].X-Tr^.Vertex[0].X-1)/ABS(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y) ELSE Wa:=0.1;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[0].Y THEN
     Wb:=(Tr^.Vertex[2].X-Tr^.Vertex[0].X)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y) ELSE Wb:=0.1;

  {OBLICZANIE KOLOROW RGB KAZDEGO Trojkata}
  V_ToRGB(Tr^.Vertex[0].C, R1, G1, B1);
  V_ToRGB(Tr^.Vertex[1].C, R2, G2, B2);
  V_ToRGB(Tr^.Vertex[2].C, R3, G3, B3);

  {OBLICZANIE POTRZEBNEGO PRZEJSCIA PIONOWEGO}
  IF Tr^.Vertex[1].Y<>Tr^.Vertex[0].Y THEN
  BEGIN
    {CZERWONY}
    DVr1:=(R2-R1)/(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y);

    {ZIELONY}
    DVg1:=(G2-G1)/(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y);

    {NIEBIESKI}
    DVb1:=(B2-B1)/(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y);
  END ELSE
  BEGIN
    DVr1:=0;
    DVg1:=0;
    DVb1:=0;
  END;



  IF Tr^.Vertex[2].Y<>Tr^.Vertex[0].Y THEN
  BEGIN
    {CZERWONY}
    DVr2:=(R3-R1)/(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y);

    {ZIELONY}
    DVg2:=(G3-G1)/(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y);

    {NIEBIESKI}
    DVb2:=(B3-B1)/(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y);
  END ELSE
  BEGIN
    DVr2:=0;
    DVg2:=0;
    DVb2:=0;
  END;


  StartXa:=Tr^.Vertex[0].X;
  StartXb:=Tr^.Vertex[0].X;

  {PODSTAWIA AKTUALNE KOLORY NA GORNY ROG}
  AR1:=R1;
  AG1:=G1;
  AB1:=B1;

  AR2:=R1;
  AG2:=G1;
  AB2:=B1;

  FOR I:=Integer(Trunc(Tr^.Vertex[0].Y)) TO Integer(Trunc(Tr^.Vertex[1].Y))-1 DO
  BEGIN
    P1.X:=StartXa;
    P1.Y:=I;

    P2.X:=StartXb;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    P1.C:=Tr^.Vertex[0].C;
    P2.C:=Tr^.Vertex[1].C;


    IF P1.X>P2.X THEN
    BEGIN
      Zamien(@P1, @P2);

      {ART:=AR1;
      AGT:=AG1;
      ABT:=AB1;

      AR1:=AR2;
      AG1:=AG2;
      AB1:=AB2;

      AR2:=ART;
      AG2:=AGT;
      AB2:=ABT;
      {
      DVrt:=DVr1;
      DVgt:=DVg1;
      DVbt:=DVb1;

      DVr1:=DVR2;
      DVg1:=DVg2;
      DVb1:=DVb2;

      DVR2:=DVrt;
      DVG2:=DVgt;
      DVB2:=DVbt;}


    END;

    {$R-}
    X:=Trunc(P1.X);
    W:=Trunc(P2.X);
    {$R+}


    {OBLICZANIE PRZEJSCIA KOLOROW POZIOMEGO}

    AR1:=AR1+DVr1;
    AG1:=AG1+DVg1;
    AB1:=AB1+DVb1;

    AR2:=AR2+DVr2;
    AG2:=AG2+DVg2;
    AB2:=AB2+DVb2;

    IF W<>X THEN
    BEGIN
      DHr:=(AR2-AR1)/(W-X+1);
      DHg:=(AG2-AG1)/(W-X+1);
      DHb:=(AB2-AB1)/(W-X+1);
    END ELSE
    BEGIN
      DHr:=0;
      DHg:=0;
      DHb:=0;
    END;

    PR:=AR1;
    PG:=AG1;
    PB:=AB1;

    FOR J:=X TO W DO
    BEGIN
      PR:=PR+DHr;
      PG:=PG+DHg;
      PB:=PB+DHb;

      {$R-}
      V_Pix(V_Ekran, J, I, V_RGB(Trunc(PR), Trunc(PG), Trunc(PB)));
      {$R+}
    END;
  END;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[1].Y THEN
     Wa:=(Tr^.Vertex[2].X-Tr^.Vertex[1].X)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y) ELSE Wa:=0.01;

  StartXa:=Tr^.Vertex[1].X;

  {OBLICZANIE POTRZEBNEGO PRZEJSCIA PIOPNOWEGO}
  {CZERWONY}
  IF Tr^.Vertex[2].Y<>Tr^.Vertex[1].Y THEN
  BEGIN
    DVr1:=(R3-R2)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y);

    {ZIELONY}
    DVg1:=(G3-G2)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y);

    {NIEBIESKI}
    DVb1:=(B3-B2)/ABS(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y);
  END ELSE
  BEGIN
    DVr1:=0;
    DVg1:=0;
    DVb1:=0;
  END;

  AR1:=R2;
  AG1:=G2;
  AB1:=B2;

  FOR I:=Integer(Trunc(Tr^.Vertex[1].Y)) TO Integer(Trunc(Tr^.Vertex[2].Y)-1) DO
  BEGIN
    P1.X:=StartXa;
    P2.X:=StartXb;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    IF P1.X>P2.X THEN
    BEGIN
      Zamien(@P1, @P2);

      {ART:=AR1;
      AGT:=AG1;
      ABT:=AB1;

      AR1:=AR2;
      AG1:=AG2;
      AB1:=AB2;

      AR2:=ART;
      AG2:=AGT;
      AB2:=ABT;

      DVrt:=DVr1;
      DVgt:=DVg1;
      DVbt:=DVb1;

      DVr1:=DVR2;
      DVg1:=DVg2;
      DVb1:=DVb2;

      DVR2:=DVrt;
      DVG2:=DVgt;
      DVB2:=DVbt;}
    END;

    {$R-}
    X:=Trunc(P1.X);
    W:=Trunc(P2.X);
    {$R+}

    {OBLICZANIE PRZEJSCIA KOLOROW POZIOMEGO}

    AR1:=AR1+DVr1;
    AG1:=AG1+DVg1;
    AB1:=AB1+DVb1;

    AR2:=AR2+DVr2;
    AG2:=AG2+DVg2;
    AB2:=AB2+DVb2;

    IF W<>X THEN
    BEGIN
      DHr:=(AR2-AR1)/(W-X+1);
      DHg:=(AG2-AG1)/(W-X+1);
      DHb:=(AB2-AB1)/(W-X+1);
    END ELSE
    BEGIN
      DHr:=0;
      DHg:=0;
      DHb:=0;
    END;

    PR:=AR1;
    PG:=AG1;
    PB:=AB1;

    FOR J:=X TO W DO
    BEGIN
      PR:=PR+DHr;
      PG:=PG+DHg;
      PB:=PB+DHb;
      {$R-}
      V_Pix(V_Ekran, J, I, V_RGB(Trunc(PR), Trunc(PG), Trunc(PB)));
      {$R+}
    END;
  END;
END;

{*************************************************************************}

PROCEDURE G3D_RysujTrojkatTex(Buf:TEkran10Eh; Tex:Pointer;Tr:PTriangle;Col:Byte);

VAR H                  :Word;
    I, J, W            :Integer;
    Wua, Wub           :Single;
    Wva, Wvb           :Single;
    Wa, Wb             :Single;
    StartXa, StartXb   :Single;
    StartUa, StartUb   :Single;
    StartVa, StartVb   :Single;
    NowU, NowV         :Single;

    P1, P2             :TVertex;
    Du, Dv             :Single;
    U, V:Byte;
    Y1, Y2, Y3         : Integer;

BEGIN

  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);
  IF Tr^.Vertex[1].Y>Tr^.Vertex[2].Y THEN Zamien(@Tr^.Vertex[1], @Tr^.Vertex[2]);
  IF Tr^.Vertex[0].Y>Tr^.Vertex[1].Y THEN Zamien(@Tr^.Vertex[0], @Tr^.Vertex[1]);




  IF Tr^.Vertex[1].Y<>Tr^.Vertex[0].Y THEN
     Wa:=(Tr^.Vertex[1].X-Tr^.Vertex[0].X)/(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y) ELSE Wa:=0;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[0].Y THEN
     Wb:=(Tr^.Vertex[2].X-Tr^.Vertex[0].X)/(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y) ELSE Wb:=0;

  IF Tr^.Vertex[1].Y<>Tr^.Vertex[0].Y THEN
     Wua:=(Tr^.Vertex[1].U-Tr^.Vertex[0].U)/(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y) ELSE Wua:=0;

  IF Tr^.Vertex[1].Y<>Tr^.Vertex[0].Y THEN
     Wva:=(Tr^.Vertex[1].V-Tr^.Vertex[0].V)/(Tr^.Vertex[1].Y-Tr^.Vertex[0].Y) ELSE Wva:=0;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[0].Y THEN
     Wub:=(Tr^.Vertex[2].U-Tr^.Vertex[0].U)/(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y) ELSE Wub:=0;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[0].Y THEN
     Wvb:=(Tr^.Vertex[2].V-Tr^.Vertex[0].V)/(Tr^.Vertex[2].Y-Tr^.Vertex[0].Y) ELSE Wvb:=0;




  StartXa:=Tr^.Vertex[0].X;
  StartXb:=Tr^.Vertex[0].X;

  StartUa:=Tr^.Vertex[0].U;
  StartVa:=Tr^.Vertex[0].V;

  StartUb:=Tr^.Vertex[0].U;
  StartVb:=Tr^.Vertex[0].V;

  Y1:=Trunc(Tr^.Vertex[0].Y);
  Y2:=Trunc(Tr^.Vertex[1].Y);

  IF (Y1<DefaultRect.Y) THEN Y1:=DefaultRect.Y;
  IF (Y2<DefaultRect.Y) THEN Y2:=DefaultRect.Y;



  {$R-}
  FOR I:=Y1 TO Y2-1 DO
  {$R+}
  BEGIN
    P1.X:=StartXa;
    P1.Y:=I;

    P2.X:=StartXb;
    P2.Y:=I;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    {DO TEKSTURY !!!}

    P1.U:=Trunc(StartUa);
    P1.V:=Trunc(StartVa);

    P2.U:=Trunc(StartUb);
    P2.V:=Trunc(StartVb);

    IF P1.X>P2.X THEN Zamien(@P1, @P2);

    StartUa:=StartUa+WUa;
    StartUb:=StartUb+WUb;

    StartVa:=StartVa+WVa;
    StartVb:=StartVb+WVb;

    W:=ABS(Trunc(P2.X-P1.X));

    IF W<>0 THEN Du:=(P2.U-P1.U)/W ELSE Du:=0;
    IF W<>0 THEN Dv:=(P2.V-P1.V)/W ELSE Dv:=0;

    NowU:=P1.U;
    NowV:=P1.V;


    IF (I>=0) AND (I<V_MaxEY) AND (P2.X>0) AND (P1.X<V_MaxEX) THEN


    FOR J:=Trunc(P1.X) TO Trunc(P2.X) DO
        BEGIN
          {$R-}
          U:=Trunc(NowU);
          V:=Trunc(NowV);
          {$R+}
          NowU:=NowU+DU;
          NowV:=NowV+DV;

          IF (J>=0) AND (J<V_MaxEX) THEN
             V_Pix(Buf, J, I, GetFromImage(Tex, U, V, Col));
        END;

  END;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[1].Y+1 THEN
     Wa:=(Tr^.Vertex[2].X-Tr^.Vertex[1].X)/(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y-1) ELSE Wa:=0;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[1].Y+1 THEN
     Wua:=(Tr^.Vertex[2].U-Tr^.Vertex[1].U)/(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y-1) ELSE Wua:=0;

  IF Tr^.Vertex[2].Y<>Tr^.Vertex[1].Y+1 THEN
     Wva:=(Tr^.Vertex[2].V-Tr^.Vertex[1].V)/(Tr^.Vertex[2].Y-Tr^.Vertex[1].Y-1) ELSE Wva:=0;

  StartXa:=Tr^.Vertex[1].X;

  StartUa:=Tr^.Vertex[1].U;
  StartVa:=Tr^.Vertex[1].V;

  {$R-}

  Y3:=Trunc(Tr^.Vertex[2].Y);
  IF Y3>DefaultRect.Y+DefaultRect.W THEN Y3:=DefaultRect.Y+DefaultRect.W;

  FOR I:=Y2 TO Y3-1 DO
  {$R+}
  BEGIN
    P1.X:=StartXa;
    P1.Y:=I;

    P2.X:=StartXb;
    P2.Y:=I;

    StartXa:=StartXa+Wa;
    StartXb:=StartXb+Wb;

    {DO TEKSTURY !!!}

    P1.U:=Trunc(StartUa);
    P1.V:=Trunc(StartVa);

    P2.U:=Trunc(StartUb);
    P2.V:=Trunc(StartVb);

    IF P1.X>P2.X THEN Zamien(@P1, @P2);

    StartUa:=StartUa+WUa;
    StartUb:=StartUb+WUb;

    StartVa:=StartVa+WVa;
    StartVb:=StartVb+WVb;

    W:=ABS(Trunc(P2.X-P1.X));

    IF W<>0 THEN Du:=(P2.U-P1.U)/W ELSE Du:=0;
    IF W<>0 THEN Dv:=(P2.V-P1.V)/W ELSE Dv:=0;

    NowU:=P1.U;
    NowV:=P1.V;

    IF (I>=0) AND (I<V_MaxEY) AND (P2.X>0) AND (P1.X<V_MaxEX) THEN

    FOR J:=Trunc(P1.X) TO Trunc(P2.X) DO
        BEGIN
          {$R-}
          U:=Trunc(NowU);
          V:=Trunc(NowV);
          {$R+}
          NowU:=NowU+DU;
          NowV:=NowV+DV;

          IF (J>=0) AND (J<V_MaxEX) THEN
          V_Pix(Buf, J, I, GetFromImage(Tex, U, V, Col));

      END;
  END;
  {END; {TUTAJ TRAFI KAZDY TROJKAT NIE SPELNIAJACY WYMOGOW}


END;


END.