UNIT D_Fire;
{*************************************************************************}
{*                                                                       *}
{*                       EFEKT OGNIA - KAMIL SKOCZYLAS                   *}
{*                    E - MAIL: BlackAmper@poczta.onet.pl                *}
{*                      pomysˆ ognia: Sebastian Chojniak                 *}
{*                              sebek1234@go2.pl                         *}
{*                                                                       *}
{*************************************************************************}


{$G+}{OBSLUGA INSTRUKCJI 286 - W ASSEMBLERZE Shr Ax, 2}
INTERFACE

USES Standard, Graph10E, D_Types;


{EYSUJE OGIEN W 13h}
PROCEDURE Make_Fire;

IMPLEMENTATION

TYPE PArrayEkr  =^TArrayEkr;
     TArrayEkr  = ARRAY[0..199, 0..319] OF BYTE;

VAR TAB:PArrayEkr;
    A, B, X:INTEGER;



{LOSUJE DOLNE RZEDY OGNIA}
PROCEDURE LOSUJ;
BEGIN
  FOR A:=0 TO 319 DO
  FOR B:=198 TO 199 DO
    BEGIN
      TAB^[B, A]:=RANDOM(100)+156;
    END;
END;


{PROCEDURA PRZYSPIESZONA W ASSEMBLERZE}
{TYLKO DLA 320 PIKSELI W POZIOMIE PRZY 8 BITACH}
PROCEDURE Blur(Buf:Pointer;Size:Word);
BEGIN
  ASM
    {POBIERA ADRES BUFORA}
    Les  Di, Buf

    {WCZYTUJE ILE RAZY WYKONA SIE PETLA}
    Mov  Cx, Size

    {PETLA GLOWNA}
    @Petla:

      {DODAWANIE SASIEDNICH WARTOSCI}
      Db   $66
      Xor  Ax, Ax
      {1 SKLADOWA}
      Mov  Al, Es:[Di+319]
      {2 SKLADOWA}
      Db   $66
      Xor  Dx, Dx
      Mov  Dl, Es:[Di+321]
      Add  Ax, Dx
      {3 SKLADOWA}
      Mov  Dl, Es:[Di+320]
      Db   $66
      Add  Ax, Dx
      {4 SKLADOWA}
      Mov  Dl, Es:[Di+640]
      Db   $66
      Add  Ax, Dx

      {DZIELENIE PRZEZ 4}
      Shr  Ax, 2

      Or   Ax, Ax
      jz   @Dalej
      Dec  Ax

      @Dalej:

      {ZAPIS NOWEGO BAJTU DO PAMIECI}
      Mov  Es:[Di], Ax
      Inc  Di

    Loop @Petla

  END;
END;

PROCEDURE Make_Fire;
BEGIN
  Opcja:=0;
  IF MaxAvail<64000 THEN Exit;

  New(Tab);
  S_FillChar32(Tab, 64000, 0);

  ASM
    MOV AX, 13H
    INT 10H
  END;

  FOR A:=255 DOWNTO 128 DO
    BEGIN
      PORT[$3C8]:=A;
      PORT[$3C9]:=63;
      PORT[$3C9]:=((A-128) DIV 2);
      PORT[$3C9]:=0;
    END;

  FOR A:=127 DOWNTO 0 DO
    BEGIN
      PORT[$3C8]:=A;
      PORT[$3C9]:=(A DIV 2);
      PORT[$3C9]:=0;
      PORT[$3C9]:=0;
    END;

  REPEAT
    {EFEKT ROZMYCIA}
    Blur(TAB, 63360);

    {LOSUJE DOLNE RZEDY OGNIA}
    LOSUJ;

    {POWROT PIONOWY}
    V_VRet;

    {KOPIUJE CALOSC NA EKRAN}
    S_Move32(TAB, Ptr($A000, 0), 64000);

  UNTIL PORT[$60]=1;

  Dispose(Tab);
  V_Set10Eh;

END;

END.