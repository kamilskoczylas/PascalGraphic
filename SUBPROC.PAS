{$N+}
{***********************************************************************}
{                    KOD ZRODLOWY - MODUL PROCEDUR POMOCNICZYCH         }
{	                     PRACA DYPLOMOWA 2004/2005                  }
{ 	         PREZENTACJA MOZLIWOSCI GRAFICZNYCH W TURBO PASCALU     }
{                                                                       }
{                                                                       }
{        AUTOR:                                                         }
{          KAMIL SKOCZYLAS                                              }
{          KamilSkoczylas@o2.pl                                         }
{                                                                       }
{                                                                       }
{        Modul zawiera procedury automatycznie wywolywane przez system  }
{        Doors                                                          }
{                                                                       }
{***********************************************************************}

{$M $4000, 0, 0}

UNIT SubProc;

INTERFACE

USES Doors,
     Panels,
     D_Effect,
     Graph10E,
     Standard,
     D_InOut,
     D_Types,
     Dos,
     G3d,
     Buttons;

{***********************************************************************}

PROCEDURE ShowPanel;FAR;
PROCEDURE ShowPanel2;FAR;
PROCEDURE NextStars;FAR;
PROCEDURE NextEffect;FAR;
PROCEDURE Doors_End;FAR;
PROCEDURE Doors_EndX;FAR;
PROCEDURE Doors_Anuluj;FAR;
PROCEDURE Doors_Reload;FAR;
PROCEDURE Doors_Open;FAR;
PROCEDURE Settings;FAR;
PROCEDURE ShowMemory;FAR;
PROCEDURE TurnVerticalRetrace;FAR;
PROCEDURE SettingsEnd;FAR;
PROCEDURE OpenEnd;FAR;
PROCEDURE AuthorEnd;FAR;
PROCEDURE TurnRotate;FAR;
PROCEDURE JustOpen;FAR;
PROCEDURE AuthorOpen;FAR;
PROCEDURE Grafika3d;FAR;
PROCEDURE Effects;FAR;
PROCEDURE Opis;FAR;
PROCEDURE ShowPict;FAR;
PROCEDURE Animacje;FAR;
PROCEDURE PomocOpen;FAR;

IMPLEMENTATION
USES
    Edits,
    D_Menu,
    Doors10E;


{***********************************************************************}
{***********************************************************************}
{             PROCEDURY WOWOLYWANE PRZEZ WSKAZNIK !!!                   }
{***********************************************************************}
{***********************************************************************}
PROCEDURE PomocOpen;
BEGIN
  Opcja:=7;
END;


PROCEDURE Animacje;
BEGIN
  Opcja:=6;
END;

PROCEDURE Opis;
BEGIN
  Opcja:=5;
END;


PROCEDURE ShowPict;
BEGIN
  Opcja:=3;
END;
{***********************************************************************}

PROCEDURE Effects;
BEGIN
  Opcja:=1;
END;

{***********************************************************************}

PROCEDURE Grafika3d;
BEGIN
  Opcja:=2;
  Typ3d:=Typ3d+1;
  IF Typ3d>MaxTyp3d THEN Typ3d:=1;
END;
{***********************************************************************}
PROCEDURE AuthorEnd;
BEGIN
  AuthorPanel^.Visible:=False;
END;
{***********************************************************************}

PROCEDURE AuthorOpen;
BEGIN
  AuthorPanel^.Show;
END;
{***********************************************************************}

PROCEDURE TurnVerticalRetrace;
BEGIN
  VerticalRetrace:=NOT VerticalRetrace;
  D_SetButtonText(VertObj, Texts[7+MaxPan+Byte(VerticalRetrace)*8]);
END;

{***********************************************************************}
PROCEDURE TurnRotate;
BEGIN
  AutoRotate:=NOT AutoRotate;
END;

{***********************************************************************}

PROCEDURE ShowMemory;
BEGIN
  MemoryTemp^.Visible:=NOT MemoryTemp^.Visible;
END;

{***********************************************************************}
PROCEDURE SettingsEnd;
BEGIN
  SettingsPanel^.Visible:=False;
END;
{***********************************************************************}
PROCEDURE OpenEnd;
BEGIN
  OpenPanel^.Visible:=False;
END;
{***********************************************************************}
PROCEDURE JustOpen;
BEGIN
  IF FileExists(PEditParams(EditOpen^.Params)^.Text) THEN
    BEGIN
      SwapVectors;
      Exec(PEditParams(EditOpen^.Params)^.Text, '');
      SwapVectors;
    END;
END;

{***********************************************************************}

PROCEDURE Settings;
BEGIN
  SettingsPanel^.Show;
END;

{***********************************************************************}

PROCEDURE Doors_Open;
BEGIN
  OpenPanel^.Show;
END;

{***********************************************************************}

{OKNO WYLACZANIA SYSTEMU}
PROCEDURE Doors_End;
BEGIN
  ExitPanel^.Show;
END;

{***********************************************************************}
PROCEDURE Doors_Reload;
BEGIN
  ASM
    Int 19h
  END;
END;

{***********************************************************************}

{OKNO WYLACZANIA SYSTEMU - ANULUJ}
PROCEDURE Doors_Anuluj;
BEGIN
  ExitPanel^.Visible:=FALSE;
END;

{***********************************************************************}

PROCEDURE Doors_EndX;
BEGIN
  Koniec:=True;
  Opcja:=0;
END;

{***********************************************************************}

{POKAZUJE PANEL PASKU START}
PROCEDURE ShowPanel;
BEGIN
  Panel^.SetActive;
  Panel^.Visible:=NOT Panel^.Visible;
END;

PROCEDURE ShowPanel2;
BEGIN
  Panel2^.Visible:=NOT Panel2^.Visible;
END;

{***********************************************************************}

{ZMIENIA PARAMETRY EFEKTU}
PROCEDURE NextStars;
BEGIN
  CASE Typ OF
  2:BEGIN
      IF NOT (StarType IN [1,2]) THEN StarType:=1;
      FreeStarsBuf(Stars, StarType);
      StarType:=3-StarType;
      Stars:=GetBufStars(StarType);
    END;
  3:
  BEGIN
      DOORS_CAPTION:=V_RGB(Random($FF), Random($FF), Random($FF));
      DOORS_CAPTION2:=V_RGB(Random($FF), Random($FF), Random($FF));
    END;
  4:
    BEGIN
      Inc(StarType);
      IF StarType>4 THEN StarType:=1;
      G3D_Metoda:=StarType;
    END;

  END;
END;

{***********************************************************************}

{ZMIENIA EFEKT WYGASZACZA NA NASTEPNY}
PROCEDURE NextEffect;
VAR F      : Text;
    count  : Byte;
    i      : Byte;
BEGIN
  Randomize;

  CASE Typ OF

    1:{ZWOLNIJ OBRAZEK}
      V_FreeImage(TloBMP);
    2:{ZWALNIANIE PAMIECI GWIAZD}
      FreeStarsBuf(Stars, StarType);
    4:
      BEGIN
        StarType:=1;

        IF Assigned(Temp3d) THEN
        FreeMem(Temp3d, Size3d*SizeOf(TTriangle));

        IF Assigned(Dane3d) THEN
        FreeMem(Dane3d, Size3d*SizeOf(TTriangle));

        Temp3d:=NIL;
        Dane3d:=NIL;


      END;
  END;


  Inc(Typ);
  IF Typ>MaxTypes THEN Typ:=0;

  CASE Typ OF
  0:BEGIN
      {PRZYDZIELANIE PAMIECI DLA GWIAZD}
      V_NewImage(TloBMP);

      IF FileExists(mDirectory+PlikTekstur) THEN
      BEGIN

        {KOJARZENIE PLIKU}
        Assign(F, mDirectory+PlikTekstur);

        {OTWIERA PLIK}
        Reset(F);

        {WCZYTUJE LICZBE ROZNYCH TEKSTUR}
        ReadLn(F, count);

        {OMIJA LOSOWA ILOSC PLIKOW}
        FOR i:=1 TO Random(Count) DO ReadLn(F);

        ReadLn(F, BgFile);


        {ZAMYKA PLIK}
        Close(F);
      END;


      {WCZYTANIE BITMAPY}
      V_LoadBMP24(TloBMP, mDirectory+BgFile);
    END;

  2:{PRZYDZIELANIE PAMIECI DLA GWIAZD}
    Stars:=GetBufStars(StarType);

  3:
    {LOSOWANIE KOLOROW}
    BEGIN
      DOORS_CAPTION:=V_RGB(Random($FF), Random($FF), Random($FF));
      DOORS_CAPTION2:=V_RGB(Random($FF), Random($FF), Random($FF));
    END;


  4:{WCZYTUJE DANE DLA GRAFIKI 3D}
    BEGIN
      KatX:=128;
      KatY:=0;
      KatZ:=0;

      Dane3d:=G3d_Load(mDirectory+Give3dName, Size3d);

      IF MemAvail<Size3d*SizeOf(TTriangle) THEN
         BEGIN
           Temp3d:=NIL;
           IF Dane3d<>NIL THEN
           FreeMem(Dane3d, Size3d*SizeOf(TTriangle));
           Dane3d:=NIL;
           Exit;
         END;

      GetMem(Temp3d, Size3d*SizeOf(TTriangle));
      Vector.X:=0;
      Vector.Y:=0;
      Vector.Z:=G3D_MaxOdl*0.8;
    END;





  END;
END;

{***********************************************************************}

END.
