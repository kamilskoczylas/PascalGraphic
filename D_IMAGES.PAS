UNIT D_Images;


INTERFACE
USES Graph10e,
     D_InOut,
     D_Types,
     Standard,
     Keyb_X;

PROCEDURE ShowPicture;

IMPLEMENTATION

CONST
   MaxResW = 800;
   MaxResH = 600;
   BPP     = 2;

VAR GlobalBank : Byte;
    nr         : Byte;
    snr        : Byte;
    MaxNr      : Byte;



PROCEDURE ClearScreen;
VAR i:Word;
BEGIN
  FOR i:=0 TO (MaxResW*MaxResH*BPP SHR 16) DO
    BEGIN
        GlobalBank:=i;

        ASM
          Mov AX, 4F05H
          Mov BX, 0
          Mov DX, i
          Int 10H
        END;

        S_FillChar32(Ptr($A000, 0), 60000, 0);
        S_FillChar32(Ptr($A000, 60001), 5535, 0);

    END;
END;


PROCEDURE PutPix(X, Y:LongInt; C:Word);

VAR Adres:LongInt;
    Bank :Word;
    Count:Word;

BEGIN



  Adres :=(Y*MaxResW+X)*BPP;
  Bank  :=Adres SHR 16;
  Count :=Adres AND $FFFF;

  IF GlobalBank<>Bank THEN
  BEGIN
    GlobalBank:=Bank;

  ASM
    Mov AX, 4F05H
    Mov BX, 0
    Mov DX, Bank
    Int 10H
  END;
  END;

  ASM

    Mov Ax, $A000
    Mov Es, Ax
    Mov Cx, C
    Mov Di, Count
    Mov Es:[Di], Cx

  END;


END;

PROCEDURE LoadBMP(CONST Fn:STRING);

TYPE TLine=ARRAY[0..2400] OF Byte;
     PLine=^TLine;

VAR F     : FILE;
    Capt  : TBMPCaption;
    Temp  : Pointer;

    j, i  : Word;
    Col   : Word;
    LCol  : LongInt;


    TempL : PLine;


BEGIN
  IF NOT FileExists(Fn) THEN
  BEGIN
    MaxNr:=Nr-1;
    Exit;
  END;

  Assign(F, Fn);
  Reset(F, 1);

  BlockRead(F, Capt, SizeOf(TBMPCaption));
  Seek(F, Capt.Obraz_Offset);

  ClearScreen;

  {IF MaxAvail<Capt.Width*(Capt.BPP SHR 8) THEN
  BEGIN}
  FOR j:=Capt.Height DOWNTO 1 DO
  FOR i:=1 TO Capt.Width DO
    BEGIN

    IF Capt.BPP=16 THEN
       BlockRead(F, Col, 2);

    IF Capt.BPP=24 THEN
    BEGIN
       BlockRead(F, LCol, 3);
       Col:=V_RGB(LCol SHR 16, LCol SHR 8, LCol);
    END;

      PutPix((MaxResW SHR 1)-(Capt.Width SHR 1)+i,
             (MaxResH SHR 1)-(Capt.Height SHR 1)+j, Col);
    END;
  {END ELSE
  BEGIN

    GetMem(TempL, Capt.Width*(Capt.BPP SHR 8));

    FOR j:=Capt.Height DOWNTO 1 DO
    BEGIN

      BlockRead(F, TempL^, Capt.Width*(Capt.BPP SHR 8));
      FOR i:=1 TO Capt.Width DO
      BEGIN
        IF Capt.BPP=16 THEN
           Col:=(TempL^[(i-1)*2] SHL 8)+ (TempL^[(i-1)*2+1]);

        IF Capt.BPP=24 THEN
           Col:=V_RGB(TempL^[(i-1)*3], TempL^[(i-1)*3+1], TempL^[(i-1)*3+2]);

          PutPix((MaxResW SHR 1)-(Capt.Width SHR 1)+i,
                 (MaxResH SHR 1)-(Capt.Height SHR 1)+j, Col);
      END;
    END;

    FreeMem(TempL, Capt.Width*(Capt.BPP SHR 8));

  END;}

  Close(F);
END;

PROCEDURE ShowPicture;
BEGIN
  Opcja:=0;

  {URUCHAMIA 800x600x16Bpp}
  ASM
    Mov  Ax, 4f02h
    Mov  Bx, 114h
    Int  10h
  END;

  snr:=1;
  nr:=0;
  MaxNr:=255;


  REPEAT

  IF nr<>snr THEN
  BEGIN
     LoadBMP(mDirectory+FilePicture+IntToStr(nr)+'.bmp');
     snr:=nr;
  END;

    IF Key[VK_DOWN] THEN Inc(Nr);
    IF Key[VK_UP]   THEN Dec(Nr);

    IF nr>Maxnr THEN Nr:=0;




  UNTIL PORT[$60]=1;



  V_Set10Eh;
END;

END.