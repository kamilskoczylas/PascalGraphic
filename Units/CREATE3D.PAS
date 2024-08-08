{$N+}
PROGRAM Creating3d;

USES G3d, Standard, Graph10E;

CONST
     Quality : Byte=40;
     FileName='G3d\fig2.txt';


VAR  Vert : PVertex;
     Fig  : PTriangle;
     DirX : STRING;
     F    : Text;
     i    : Word;
     Size : Word;




FUNCTION CreateCircle(R, H:Single):PTriangle;

VAR i, Kat1, Kat2:Byte;
    Temp:PTriangle;

BEGIN

  GetMem(Temp, SizeOf(TTriangle)*Quality*2);
  CreateCircle:=Temp;

  FOR i:=1 TO Quality DO
  BEGIN
    Kat1:=Round(255/(Quality)*i);

    IF i<Quality THEN

       Kat2:=Round(255/(Quality)*(i+1))
       ELSE
       Kat2:=Round(255/(Quality));

      {TROJKAT W GORZE}

      temp^.Vertex[0].X:= R*G3D_Sin[Kat1];
      temp^.Vertex[0].Z:= R*G3D_Cos[Kat1];

      temp^.Vertex[1].X:= R*G3D_Sin[Kat2];
      temp^.Vertex[1].Z:= R*G3D_Cos[Kat2];

      temp^.Vertex[0].Y:=-H/2;
      temp^.Vertex[1].Y:=-H/2;
      temp^.Vertex[2].Y:= H/2;

      temp^.Vertex[2].X:= R*G3D_Sin[Kat2];
      temp^.Vertex[2].Z:= R*G3D_Cos[Kat2];

      temp^.Vertex[0].C:= V_RGB(0, 255, 0);
      temp^.Vertex[1].C:= V_RGB(0, 155, 0);
      temp^.Vertex[2].C:= V_RGB(0, 55, 0);

      Inc(Temp);

      {TROJKAT W DOLE}
      temp^.Vertex[0].C:= V_RGB(255, 255, 0);
      temp^.Vertex[1].C:= V_RGB(155, 155, 0);
      temp^.Vertex[2].C:= V_RGB(55, 55, 0);

      temp^.Vertex[0].X:= R*G3D_Sin[Kat1];
      temp^.Vertex[0].Z:= R*G3D_Cos[Kat1];

      temp^.Vertex[1].X:= R*G3D_Sin[Kat2];
      temp^.Vertex[1].Z:= R*G3D_Cos[Kat2];

      temp^.Vertex[0].Y:= H/2;
      temp^.Vertex[1].Y:= H/2;
      temp^.Vertex[2].Y:=-H/2;

      temp^.Vertex[2].X:= R*G3D_Sin[Kat1];
      temp^.Vertex[2].Z:= R*G3D_Cos[Kat1];

      Inc(Temp);
  END;
END;


BEGIN
  DirX:=S_GetPath(ParamStr(0));

  Fig:=CreateCircle(10, 20);

  Assign(F, DirX+FileName);

  Rewrite(F);

  WriteLn(F, Quality*6);

  FOR i:=1 TO Quality*2 DO
  BEGIN
    Vert:=@Fig^.Vertex[0];
    WriteLn(F, Vert^.X:6:3,' ',Vert^.Y:6:3,  ' ',Vert^.Z:6:3,  ' ',Vert^.U,  ' ',Vert^.V,  ' ',Vert^.C);

    Vert:=@Fig^.Vertex[1];
    WriteLn(F, Vert^.X:6:3,' ',Vert^.Y:6:3,  ' ',Vert^.Z:6:3,  ' ',Vert^.U,  ' ',Vert^.V,  ' ',Vert^.C);

    Vert:=@Fig^.Vertex[2];
    WriteLn(F, Vert^.X:6:3,' ',Vert^.Y:6:3,  ' ',Vert^.Z:6:3,  ' ',Vert^.U,  ' ',Vert^.V,  ' ',Vert^.C);


    Inc(Fig);
  END;



  Close(F);


END.