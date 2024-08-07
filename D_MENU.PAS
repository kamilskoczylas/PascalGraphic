{$N+}
{***********************************************************************}
{                    KOD ZRODLOWY - PROGRAM GLOWNY                      }
{	                     PRACA DYPLOMOWA 2004/2005                  }
{ 	         PREZENTACJA MOZLIWOSCI GRAFICZNYCH W TURBO PASCALU     }
{                                                                       }
{                                                                       }
{        AUTOR:                                                         }
{          KAMIL SKOCZYLAS                                              }
{          KamilSkoczylas@o2.pl                                         }
{                                                                       }
{***********************************************************************}

UNIT D_MENU;


INTERFACE


{***********************************************************************}

PROCEDURE StartDoors;
PROCEDURE Start3d;
PROCEDURE Menu;
PROCEDURE CheckErrors;
PROCEDURE FreeMemory;
FUNCTION Give3dName:STRING;


{***********************************************************************}

IMPLEMENTATION
USES
      {MODULY}
      (* SPECJALNE DO PRACY DYPLOMOWEJ : *)

      D_Types,     {DEFINICJA WSZYSTKICH ZMIENNYCH I STALYCH GLOBALNYCH}
      SubProc,     {WSZYSTKIE PROCEDURY WYWOLYWANE AUTOMATYCZNIE PRZEZ WSKAZNIK}
      D_Fire,
      D_Opis,
      D_Images,


      (* OGOLNE : *)

      MouseX,      {MODUL OBSLUGI MYSZKI}
      Graph10E,    {OBSLUGA TRYBU VESA - 320x200x16bpp}
      D_Error,     {WYSWIETLANIE BLEDOW}
      Standard,    {OPERACJE STANDARDOWE, CZESTO WYKORZYSTYWANE}
      Fonts,       {OPERACJE NA CZCIONKACH}
      D_Effect,    {PROSTE EFEKTY GRAFICZNE, NP. GWIAZDY}
      Keyb_X,      {OBSLUGA KLAWIATURY}
      D_InOut,     {PROSTE OPERACJE NA PLIKACH}
      G3d,         {OBSLUGA GRAFIKI TROJWYMIAROWEJ}

      (* SYSTEM DOORS : *)

      Doors,       {MODUL DO TWORZENIA OKIEN, PRZYCISKOW ITP}
      Doors10E,    {RYSOWANIE ZBUDOWANYCH OBIEKTOW}
      Doors_EV,    {OBSLUGA ZDARZEN DLA OBIEKTOW}

      Buttons,     {OBSLUGA PRZYCISKOW}
      Forms,       {OBSLUGA OKIEN}
      Edits,       {OBSLUGA POL TEKLSTOWYCH}
      Labels,      {OBSLUGA NAPISOW}
      Panels,      {OBSLUGA PANELOW}
      Icons;       {OBSLUGA IKON}


{***********************************************************************}


FUNCTION Give3dName:STRING;
VAR F : Text;
    i : Byte;
    m : Byte;
    Fn : STRING[30];

BEGIN
  Assign(F, mDirectory+Fig3dFile);
  {$I-}
  Reset(F);
  {$I+}

  ReadLn(F, m);
  m:=Random(m)+1;
  i:=0;

  WHILE NOT Eof(F) AND (i<m) DO
  BEGIN
    Inc(i);
    ReadLn(F, Fn);
  END;

  Close(F);
  Give3dName:=Fn;
END;

PROCEDURE Start3d;
VAR
    Dane, Temp : PTriangle;
    Size  : Word;

PROCEDURE Next3d;

BEGIN
  IF Dane<>NIL THEN
     FreeMem(Dane, Size*SizeOf(TTriangle));

  IF Temp<>NIL THEN
     FreeMem(Temp, Size*SizeOf(TTriangle));


  Dane:=G3d_Load(mDirectory+Give3dName, Size);

  IF MaxAvail<Size*SizeOf(TTriangle) THEN
     BEGIN
       Temp:=NIL;
       IF Dane<>NIL THEN
       FreeMem(Dane, Size*SizeOf(TTriangle));
       Dane:=NIL;
       Exit;
     END;

  GetMem(Temp, Size*SizeOf(TTriangle));

END;

VAR Av:Single;
    Czas:LongInt;
BEGIN

      Dane:=NIL;
      Temp:=NIL;

      Next3d;

      Opcja:=0;
      Av:=0.4;

      KatX:=128;
      KatY:=0;
      KatZ:=0;


      Vector.X:=0;
      Vector.Y:=0;
      Vector.Z:=G3D_MaxOdl*0.8;

      Czas:=S_Ti;
      Randomize;


  REPEAT

    IF ABS(S_Ti-Czas)>50 THEN
    BEGIN
      Next3d;
      Czas:=S_Ti;
    END;

    V_ClearScreen(Ekran, G3d_KOLOR_MGLY);



    Inc(KatX);
    Inc(KatY);
    Inc(KatZ);

    IF (Vector.Z<G3d_MinOdl*5) OR (Vector.Z>G3d_MaxOdl*0.85) THEN Av:=-Av;

    Vector.Z:=Vector.Z+Av;


    {KOPIUJE TROJKATY}
    S_Move32(Dane, Temp, Size*SizeOf(TTriangle));

    {OBRACA I PRZESUWA OBIEKT}
    G3D_Rotate(Temp, KatX, KatY, KatZ, Size);
    G3D_Transform(Temp, @Vector, Size);

    {RYSUJE TROJKATY W BUFORZE}
    G3D_Render(Temp, Size);

    {POWROT}
    V_VRet;

    {PRZERYSOWUJE}
    V_FlipBuf(Ekran);

  UNTIL PORT[$60]=1;

  IF Dane<>NIL THEN
     FreeMem(Dane, Size*SizeOf(TTriangle));

  IF Temp<>NIL THEN
     FreeMem(Temp, Size*SizeOf(TTriangle));

  Dane:=NIL;
  Temp:=NIL;

END;

{***********************************************************************}

PROCEDURE LoadLang;
VAR F:Text;
    i:Byte;
BEGIN
  {JESLI NIE MA PLIKU NIE LADUJE NAPISOW}
  IF NOT FileExists(mDirectory+FileLang+IntToStr(Lang)+LangExt) THEN Exit;

  {KOJARZY PLIK}
  Assign(F, mDirectory+FileLang+IntToStr(Lang)+LangExt);

  {DO ODCZYTU}
  Reset(F);

  i:=0;

  {DOPLOKI MA WCZYTYWAC WCZYTUJE NAPISY}
  WHILE NOT Eof(F) AND (i<MaxTxt) DO
  BEGIN
    IF (i=0) OR (Texts[i][1]<>'*') THEN
    Inc(i);
    ReadLn(F, Texts[i]);
  END;

  {ZAMYKA PLIK}
  Close(F);

END;

{***********************************************************************}

PROCEDURE Menu;

VAR
    {ZMIENNE DLA OBRAZKOW FLAG}
    Lang1,
    Lang2     : TPicture;

    {PRZYCISKI}
    Button1   : PObject;
    Button2   : PObject;

    {ROZMYCIE EKRANU, JESLI WIEKSZE BLIZEJ CZARNEGO}
    Rozm      : Byte;

BEGIN

  {URUCHOMIENIE TRYBU GRAFICZNEGO 320x200x16bpp}
  V_Set10Eh;

  {NOWY RYSUNEK}
  V_NewImage(Lang1);

  {WCZYTAJ GO}
  V_LoadBMP24(Lang1, mDirectory+FileAng);

  {NOWY RYSUNEK}
  V_NewImage(Lang2);

  {WCZYTAJ GO}
  V_LoadBMP24(Lang2, mDirectory+FilePol);

  {TWORZY PRZYCISKI}
  D_CreateObject(Button1);
  D_CreateObject(Button2);

  D_CreateButton(Button1);
  D_CreateButton(Button2);

  {USTALANIE POZYCJI PRZYCISKOW}
  Button1^.Pos^.X:=(V_MaxEX SHR 1)-(Lang1^.W SHR 1);
  Button1^.Pos^.Y:=30;
  Button1^.Pos^.Width:=Lang1^.W;
  Button1^.Pos^.Height:=Lang1^.h;

  Button2^.Pos^.X:=(V_MaxEX SHR 1)-(Lang1^.W SHR 1);
  Button2^.Pos^.Y:=100;
  Button2^.Pos^.Width:=Lang1^.W;
  Button2^.Pos^.Height:=Lang1^.h;

  {ZAMIAST RYSOWAC STANDARDOWE PRZYCISKI RYSUJE BITMAPY}
  PButtonParams(Button1^.Params)^.Picture:=Lang1;
  PButtonParams(Button2^.Params)^.Picture:=Lang2;

  {USTALENIE POZYCJI KURSORA MYSZY}
  MouseXY(V_MaxEX SHR 1, V_MaxEY SHR 1);

  {PRZYDZIELANIE PAMIECI DLA GWIAZD}
  Stars:=GetBufStars(1);

  {KASOWANIE ZDARZEN}
  DE_DeleteEvents;

  {POCZATKOWE ROZMYCIE- CZARNE TLO}
  Rozm:=63;

  WHILE Rozm<64 DO
    BEGIN

      {CZYSCI EKRAN}
      V_ClearScreen(Ekran, 0);

      {RYSUJE GWIAZDY}
      RenderStars(Ekran, Stars, 1);

      {NAPISY}
      V_CenterText(Ekran, Font, V_MaxEX SHR 1, 16, 'PLEASE SELECT LANGUAGE', V_RGB($99, $99, $99), 8);
      V_CenterText(Ekran, Font, V_MaxEX SHR 1, 160, 'PROSZ¨ WYBRA J¨ZYK', V_RGB($99, $99, $99), 8);

      {USTAWIA ZDARZENIA}
      DE_GetEvents;

      {BADANIE ZDARZEN}
      IF DE_ObjectEvent(Button1, ON_MOUSE_CLICK) THEN Lang:=1;
      IF DE_ObjectEvent(Button2, ON_MOUSE_CLICK) THEN Lang:=2;

      {SCIEMNIANIE PO WYBRANIU OPCJI}
      IF Lang<>0 THEN Inc(Rozm) ELSE
      IF Rozm>0 THEN Dec(Rozm);

      {RYSUJE OBIEKTY}
      D10_DrawAll(Ekran);

      {KASUJE ZDARZENIA}
      DE_DeleteEvents;

      {RYSUJE KURSOR NA EKRANIE}
      D10_DrawCursor(Ekran, Kursor);

      {SCIEMNIANIE}
      IF Rozm>0 THEN V_RozmyjEkran(Ekran, Rozm);

      {CZEKANIE NA POWROT PIONOWY}
      V_VRet;

      {PRZERYSOWUJE ZAWARTOSC BUFORA NA MONITOR}
      V_FlipBuf(Ekran);

    END;

  {ZWOLNIJ PAMIEC Z OBIEKTOW}
  D_FreeAllMemory;

  {ZWALNIANIE PAMIECI GWIAZD}
  FreeStarsBuf(Stars, 1);

  {WCZYTUJE NAPISY}
  LoadLang;

  {URUCHOMIENIE PRZERWANIA OBSLUGUJACEGO KLAWIATURE}
  Keyb_Init;
END;

{***********************************************************************}

PROCEDURE StartDoors;
VAR
   {POMOCNICZE}
   i, j         : Integer;

   {DO TWORZENIA IKON}
   Temp         : PObject;
   TempX        : PObject;

   {ZMIANIA EFEKTU}
   ChangeEff    : PObject;

   {IDENTYFIKATOR PLIKU}
   F            : Text;

   {NAZWA PLIKU DLA IKONY}
   Fn           : STRING;

   {TEKSTURA PRZESUNIETA O:}
   DX, Dy       : Byte;

   Av:Single;



BEGIN
  Av:=0.2;

  {KOLOR PRZYCISKOW}
  DOORS_BACKGROUND:=V_RGB($00, $00, $FF);
  DOORS_CAPTION:=V_RGB($00, $FF, $FF);
  DOORS_CAPTION2:=V_RGB($00, $33, $FF);



  {TWORZENIE PASKU START}
  D_CreateObject(StartBar);
  D_CreateForm(StartBar, 0);

  {PARAMETRY PASKU START}
  WITH PFormParams(StartBar^.Params)^ DO
    BEGIN
      Caption:='';
      Alpha:=1;
    END;

  {ZMIANA ROZMIARU I USTALENIE POZYCJI}
  StartBar^.Resize(0, V_MaxEY-16, V_MaxEX, 16);

  {TWORZENIE PANELU PASKU START}
  D_CreateObject(Panel);
  D_CreateForm(Panel, 0);
  PFormParams(Panel^.Params)^.Caption:='DOORS 2005';
  Panel^.Resize(0, 40, 110, 144);
  PFormParams(Panel^.Params)^.OnlyActive:=True;
  PFormParams(Panel^.Params)^.Alpha:=1;

  {TWORZENIE PODMENU W PANELU}
  FOR i:=1 TO MAxPan DO
  BEGIN
    D_CreateChild(Panel, Temp);
    D_CreateLabel(Temp);

    Temp^.Resize(0, 5+i*15, 110, 14);
    PLabelParams(Temp^.Params)^.Text:=Texts[2+i];
    PLabelParams(Temp^.Params)^.Tab:=20;

    {FUNKCJE SYSTEMU}
    IF i=MaxPan-7 THEN D_NewEvent(Temp^.Events, ShowPanel2, ON_MOUSE_CLICK);
    IF i=MaxPan-5 THEN D_NewEvent(Temp^.Events, PomocOpen, ON_MOUSE_CLICK);
    IF i=MaxPan-4 THEN D_NewEvent(Temp^.Events, AuthorOpen, ON_MOUSE_CLICK);
    IF i=MaxPan-3 THEN D_NewEvent(Temp^.Events, Settings, ON_MOUSE_CLICK);
    IF i=MaxPan-2 THEN D_NewEvent(Temp^.Events , Doors_Open, ON_MOUSE_CLICK);
    IF i=MaxPan THEN D_NewEvent(Temp^.Events, Doors_End, ON_MOUSE_CLICK);

  END;

  {TWORZENIE PANELU PASKU START}
  D_CreateChild(Panel, Panel2);
  D_CreateForm(Panel2, 0);
  PFormParams(Panel2^.Params)^.Caption:='PROGRAMY';
  PFormParams(Panel2^.Params)^.Alpha:=1;
  Panel2^.Resize(109, -40, 100, 90);
  Panel2^.Visible:=False;

  {TWORZENIE PODMENU W PANELU}
  FOR i:=1 TO MaxPan2 DO
  BEGIN
    D_CreateChild(Panel2, Temp);
    D_CreateLabel(Temp);

    Temp^.Resize(0, 5+i*15, 100, 14);
    PLabelParams(Temp^.Params)^.Text:=Texts[23+i];
    PLabelParams(Temp^.Params)^.Tab:=10;
  END;

  {PANEL Z PAMIECIA}
  D_CreateChild(StartBar, MemoryTemp);
  D_CreatePanel(MemoryTemp);
  MemoryTemp^.Resize(V_MaxEX-120, 2, 55, 12);
  MemoryTemp^.Visible:=False;

  D_CreateChild(MemoryTemp, MemPan);
  D_CreateLabel(MemPan);
  MemPan^.Resize(0, 0, 50, 12);
  PLabelParams(MemPan^.Params)^.Style:=0;
  PLabelParams(MemPan^.Params)^.Align:=2;


  {PANEL Z GODZINA}
  D_CreateChild(StartBar, Temp);
  D_CreatePanel(Temp);
  Temp^.Resize(V_MaxEX-60, 2, 55, 12);

  D_CreateChild(Temp, TempX);
  D_CreateLabel(TempX);
  TempX^.Resize(4, 1, 50, 10);
  PLabelParams(TempX^.Params)^.Style:=0;
  Panel^.Visible:=FALSE;

  {TWORZENIE MENU AUTOR}
  D_CreateObject(AuthorPanel);
  D_CreateForm(AuthorPanel, 1);
  AuthorPanel^.Resize(40, 20, 240, 125);
  AuthorPanel^.CanDrag:=True;
  AuthorPanel^.Visible:=False;
  PFormParams(AuthorPanel^.Params)^.Caption:=Texts[9+MaxPan];
  PFormParams(AuthorPanel^.Params)^.Alpha:=1;
  D_NewEvent(PFormParams(AuthorPanel^.Params)^.CloseButton^.Events, AuthorEnd, ON_MOUSE_CLICK);

  FOR i:=1 TO 5 DO
    BEGIN
      D_CreateChild(AuthorPanel, Temp);
      D_CreateLabel(Temp);
      PLabelParams(Temp^.Params)^.Style:=0;
      PLabelParams(Temp^.Params)^.Align:=2;
      Temp^.Resize(5, 10+i*15, 230, 14);
      D_SetLabelText(Temp, Texts[9+MaxPan+i]);
    END;



  {TWORZENIE MENU Z USTAWIENIAMI}
  D_CreateObject(SettingsPanel);
  D_CreateForm(SettingsPanel, 1);
  SettingsPanel^.Resize(100, 30, 170, 125);
  SettingsPanel^.CanDrag:=True;
  SettingsPanel^.Visible:=False;
  PFormParams(SettingsPanel^.Params)^.Caption:=Texts[4+MaxPan];
  PFormParams(SettingsPanel^.Params)^.Alpha:=1;
  D_NewEvent(PFormParams(SettingsPanel^.Params)^.CloseButton^.Events, SettingsEnd, ON_MOUSE_CLICK);

  D_CreateChild(SettingsPanel, Temp);
  D_CreateButton(Temp);
  PButtonParams(Temp^.Params)^.Alpha:=1;
  Temp^.Resize(10, 25, 150, 15);
  D_SetButtonText(Temp, Texts[5+MaxPan]);
  D_NewEvent(Temp^.Events, ShowMemory, ON_MOUSE_CLICK);

  D_CreateChild(SettingsPanel, Temp);
  D_CreateButton(Temp);
  PButtonParams(Temp^.Params)^.Alpha:=1;
  Temp^.Resize(10, 45, 150, 15);
  D_SetButtonText(Temp, Texts[6+MaxPan]);
  {D_NewEvent(Temp^.Events, ShowMemory, ON_MOUSE_CLICK);}

  D_CreateChild(SettingsPanel, Temp);
  D_CreateButton(Temp);
  PButtonParams(Temp^.Params)^.Alpha:=1;
  Temp^.Resize(10, 65, 150, 15);
  D_NewEvent(Temp^.Events, TurnVerticalRetrace, ON_MOUSE_CLICK);
  VertObj:=Temp;
  D_SetButtonText(VertObj, Texts[7+MaxPan+Byte(VerticalRetrace)*8]);

  D_CreateChild(SettingsPanel, Temp);
  D_CreateButton(Temp);
  PButtonParams(Temp^.Params)^.Alpha:=1;
  Temp^.Resize(10, 85, 100, 15);
  D_SetButtonText(Temp, Texts[8+MaxPan]);
  D_NewEvent(Temp^.Events, TurnRotate, ON_MOUSE_CLICK);

  {TWORZENIE MENU URUCHAMIAJACEGO PROGRAM}
  D_CreateObject(OpenPanel);
  D_CreateForm(OpenPanel, 1);
  OpenPanel^.Resize(60, 100, 200, 60);
  OpenPanel^.CanDrag:=True;
  OpenPanel^.Visible:=False;

  PFormParams(OpenPanel^.Params)^.Caption:=Texts[2];
  PFormParams(OpenPanel^.Params)^.OnlyActive:=True;
  PFormParams(OpenPanel^.Params)^.Alpha:=1;
  D_NewEvent(PFormParams(OpenPanel^.Params)^.CloseButton^.Events, OpenEnd, ON_MOUSE_CLICK);

  D_CreateChild(OpenPanel, Temp);
  D_CreateEdit(Temp);
  Temp^.Resize(5, 40, 135, 15);
  PEditParams(Temp^.Params)^.Clear;
  PEditParams(Temp^.Params)^.Text:=mDirectory;
  PEditParams(Temp^.Params)^.Font:=Font2;

  EditOpen:=Temp;

  D_CreateChild(OpenPanel, Temp);
  D_CreateButton(Temp);
  Temp^.Resize(145, 40, 50, 15);
  D_NewEvent(Temp^.Events, JustOpen, ON_MOUSE_CLICK);

  D_CreateChild(OpenPanel, Temp);
  D_CreateLabel(Temp);

  Temp^.Resize(5, 25, 190, 10);
  PLabelParams(Temp^.Params)^.Text:=Texts[MaxPan+3];
  PLabelParams(Temp^.Params)^.Style:=3;


  {TWORZENIE MENU WYLACZAJACEGO PROGRAM}
  D_CreateObject(ExitPanel);
  D_CreateForm(ExitPanel, 1);
  ExitPanel^.Resize(60, 40, 200, 100);
  ExitPanel^.CanDrag:=True;
  ExitPanel^.Visible:=False;

  PFormParams(ExitPanel^.Params)^.Caption:=Texts[1];
  PFormParams(ExitPanel^.Params)^.OnlyActive:=True;
  PFormParams(ExitPanel^.Params)^.Alpha:=1;

  {TWORZENIE PODMENU W PANELU}
  FOR i:=1 TO MaxExit DO
  BEGIN
    D_CreateChild(ExitPanel, Temp);
    D_CreateButton(Temp);

    Temp^.Resize(30, 5+i*20, 140, 14);
    PButtonParams(Temp^.Params)^.Text:=Texts[i+27];
    PButtonParams(Temp^.Params)^.Alpha:=1;

    {FUNKCJE SYSTEMU}
    IF i=1 THEN D_NewEvent(Temp^.Events, Doors_EndX, ON_MOUSE_CLICK);
    IF i=2 THEN D_NewEvent(Temp^.Events, Doors_Reload, ON_MOUSE_CLICK);
    IF i=MaxExit THEN
    BEGIN
      D_NewEvent(Temp^.Events, Doors_Anuluj, ON_MOUSE_CLICK);
      D_NewEvent(PFormParams(ExitPanel^.Params)^.CloseButton^.Events , Doors_Anuluj, ON_MOUSE_CLICK);
    END;

  END;



  {TWORZENIE PASKU START}
  D_CreateChild(StartBar, Button);
  D_CreateButton(Button);

  {OBRAZEK NA PASKU START}
  V_NewImage(PButtonParams(Button^.Params)^.Picture);
  V_LoadBMP24(PButtonParams(Button^.Params)^.Picture, mDirectory+FileStart);
  PButtonParams(Button^.Params)^.Picture^.Transparent:=True;


  {TWORZY NOWY OBIEKT}
  D_CreateChild(StartBar, ChangeEff);

  {TWORZY PRZYCISK DO ZMIANY EFEKTOW}
  D_CreateButton(ChangeEff);

  {OBRAZEK NA PASKU SZYBKIEGO URUCHAMIANIA}
  V_NewImage(PButtonParams(ChangeEff^.Params)^.Picture);
  V_LoadBMP24(PButtonParams(ChangeEff^.Params)^.Picture, mDirectory+FileChange);

  PButtonParams(ChangeEff^.Params)^.Typ:=1;
  PButtonParams(ChangeEff^.Params)^.Picture^.Transparent:=True;

  ChangeEff^.Resize(70, 2, 12, 12);
  D_NewEvent(ChangeEff^.Events, NextEffect, ON_MOUSE_CLICK);


  {TWORZY NOWY OBIEKT}
  D_CreateChild(StartBar, ChangeEff);

  {TWORZY PRZYCISK DO ZMIANY GWIAZD}
  D_CreateButton(ChangeEff);
  ChangeEff^.Resize(90, 2, 12, 12);
  PButtonParams(ChangeEff^.Params)^.Typ:=1;
  D_NewEvent(ChangeEff^.Events, NextStars, ON_MOUSE_CLICK);

  {OBRAZEK NA PASKU DO ZMIANY GWIAZD}
  V_NewImage(PButtonParams(ChangeEff^.Params)^.Picture);
  V_LoadBMP24(PButtonParams(ChangeEff^.Params)^.Picture, mDirectory+FileStars);

  PButtonParams(ChangeEff^.Params)^.Picture^.Transparent:=True;
  Button^.Resize(2, 2, 50, 12);

  WITH PButtonParams(Button^.Params)^ DO
  BEGIN
    Text:='START';
  END;

  i:=1;

  IF FileExists(mDirectory+OpisPulpitu+IntToStr(Lang)+OpisExt) THEN
  BEGIN

  Assign(F, mDirectory+OpisPulpitu+IntToStr(Lang)+OpisExt);
  Reset(F);

  WHILE NOT Eof(F) DO
  BEGIN

      {TWORZY NOWY OBIEKT}
      D_CreateObject(Temp);

      {TWORZY IKONE}
      D_CreateIcon(Temp);

      {ZMIANA ROZMIARU I USTALENIE POZYCJI}
      Temp^.Resize(((i-1) DIV 4)*210+27, ((i-1) MOD 4)*45+5, 32, 32);


      IF i=6 THEN D_NewEvent(Temp^.Events, Animacje, ON_MOUSE_CLICK);
      IF i=5 THEN D_NewEvent(Temp^.Events, Opis, ON_MOUSE_CLICK);
      IF i=4 THEN D_NewEvent(Temp^.Events, AuthorOpen, ON_MOUSE_CLICK);
      IF i=3 THEN D_NewEvent(Temp^.Events, ShowPict, ON_MOUSE_CLICK);
      IF i=2 THEN D_NewEvent(Temp^.Events, Grafika3d, ON_MOUSE_CLICK);
      IF i=1 THEN D_NewEvent(Temp^.Events, Effects, ON_MOUSE_CLICK);

      WITH Temp^ DO
      BEGIN
        CanDrag:=TRUE;
      END;

      WITH PIconParams(Temp^.Params)^ DO
      BEGIN
        ReadLn(F, Text);
        ReadLn(F, Fn);

        V_NewImage(Picture);
        V_LoadBMP24(Picture, mDirectory+Fn);

        Picture^.Transparent:=TRUE;

      END;


    Inc(i);
  END;

  Close(F);
  END;

  {WSTAWIANIE ADRESOW PROCEDUR DO LISTY}
  D_NewEvent(Button^.Events, ShowPanel, ON_MOUSE_CLICK);

  {WCZYTANIE PIERWSZEGO EFEKTU}
  Typ:=MaxTypes;
  NextEffect;

  StarType:=1;

  {KASOWANIE ZDARZEN}
  DE_DeleteEvents;
  Opcja:=0;

  REPEAT

    {ZALEZNIE OD OPCJI}
    CASE Opcja OF
      0:BEGIN

          D_SetLabelText(TempX, S_GetActualTime);
          D_SetLabelText(MemPan, IntToStr(MemAvail));

          CASE Typ OF


              2:
                BEGIN
                  {CZYSCI EKRAN}
                  V_ClearScreen(Ekran, 0);

                  {RYSUJE GWIAZDY}
                  RenderStars(Ekran, Stars, StarType);
                END;

              3:
              BEGIN
                Poz.X:=-1;
                Poz.Y:=-1;

                Poz.Width:=V_MaxEX+2;
                Poz.Height:=V_MaxEY+2;

                D10_DrawBackGround2(Ekran, 0, DOORS_CAPTION, DOORS_CAPTION2);
              END;

              4:
                BEGIN

                  IF AutoRotate THEN
                  BEGIN
                    Inc(Katx);
                    Inc(Katy);
                    Inc(Katz);
                  END ELSE
                  BEGIN

                    IF Key[VK_LEFT] THEN Inc(KatY);
                    IF Key[VK_RIGHT] THEN Dec(KatY);

                    IF Key[VK_UP] THEN Inc(KatX);
                    IF Key[VK_DOWN] THEN Dec(KatX);

                    IF Key[44] THEN Inc(KatZ);
                    IF Key[45] THEN Dec(KatZ);
                  END;


                  IF (Vector.Z<G3d_MinOdl*5) OR (Vector.Z>G3d_MaxOdl*0.85) THEN Av:=-Av;

                  Vector.Z:=Vector.Z+Av;

                  {CZYSCI EKRAN}
                  V_ClearScreen(Ekran, G3D_KOLOR_MGLY);

                  {KOPIUJE TROJKATY}
                  S_Move32(Dane3d, Temp3d, Size3d*SizeOf(TTriangle));

                  {OBRACA I PRZESUWA OBIEKT}
                  G3D_Rotate(Temp3d, KatX, KatY, KatZ, Size3d);
                  G3D_Transform(Temp3d, @Vector, Size3d);

                  {RYSUJE TROJKATY W BUFORZE}
                  G3D_Render(Temp3d, Size3d);
                END;

          ELSE IF Typ IN [0, 1] THEN
            BEGIN
              {JEZELI MA BYC RUCHOMA TEKSTURA}
              IF Typ=1 THEN
                BEGIN
                  Inc(Dx);IF Dx>TloBmp^.W THEN Dec(Dx, TloBmp^.W);
                  Inc(Dy);IF Dy>TloBmp^.H THEN Dec(Dy, TloBmp^.H);
                END;

              {JESLI NIE BEDZIE TEKSTURY}
              IF NOT Assigned(TloBMP^.BMP) THEN

              {KASUJE EKRAN}
              V_ClearScreen(Ekran, Kolor) ELSE

              FOR i:=0 TO V_MaxEX DIV TloBMP^.W+1 DO
              FOR j:=0 TO V_MaxEY DIV TloBMP^.H+1 DO
                  V_KopiujObraz(Ekran, TloBMP, i*TloBMP^.W-Dx, j*TloBMP^.H-Dy);
            END;

          END;


          {USTAWIA ZDARZENIA}
          DE_GetEvents;

          {RYSUJE OBIEKTY}
          D10_DrawAll(Ekran);

          {KASUJE ZDARZENIA}
          DE_DeleteEvents;

          {RYSUJE KURSOR NA EKRANIE}
          D10_DrawCursor(Ekran, Kursor);
        END;


      1:
        {WYSWIETLA EFEKTY}
        Make_Fire;

      2:
        {URUCHAMIA 3D}
        IF Typ3d=1 THEN
        Start3d ELSE Labirynth;

      3:
        {OBRAZKI}
        ShowPicture;

      5:
        {OPIS}
        PokazOpis;

      6:
        {ANIMACJE}
        ShowAnimations;

      7:Pomoc;
    END;



    {CZEKANIE NA POWROT PIONOWY}
    V_VRet;

    {PRZERYSOWUJE ZAWARTOSC BUFORA NA MONITOR}
    V_FlipBuf(Ekran);


  UNTIL Koniec;

  {ZWALNIANIE PAMIECI GWIAZD}
  FreeStarsBuf(Stars, StarType);

  {ZWALNIANIE TEKSTURY}
  V_FreeImage(TloBMP);

  {ZWOLNIJ PAMIEC Z OBIEKTOW}
  D_FreeAllMemory;

END;

{***********************************************************************}

PROCEDURE CheckErrors;


VAR
    {IDENTYFIKATOR PLIKU}
    FileID         : Text;

    {NAZWA PLIKU DO SPRAWDZENIE}
    FileName       : STRING;


BEGIN

  {SPRAWDZANIE WOLNEJ PAMIECI}
  MemF:=MemAvail;

  {SPRAWDZANIE SCIEZKI DO URUCHOMIONEGO PROGRAMU}
  mDirectory:=S_GetPath(ParamStr(0))+DataDir;

  {DEKLAROWANIE PAMIECI EKRANU}
  IF V_GetBuf(Ekran)=E_PAMIEC THEN

     {JESLI BRAKUJE PAMIECI DODAJ BLAD}
     BEGIN
       AddError('- '+E_Error[E_PAMIEC]+' dla bufora ekranowego');

       AddError('  KONTYNUACJA NIE MA SENSU, MOZE SPOWODOWAC BLEDY!');
     END;

  {CZY JEST ZAINSTALOWANA MYSZKA}
  IF NOT MouseInstalled THEN

  {JESLI NIE DODAJ DO LISTY BLEDOW}
         AddError('- '+E_ERROR[E_MYSZ]);

  {JEZELI BRAKUJE PLIKU Z LISTA UZYWANYCH PLIKOW PRZEZ PROGRAM}
  IF NOT FileExists(mDirectory+FILE_LIST) THEN
         BEGIN

         {DODAJ DO LISTY BLEDOW}
         AddError('- '+E_ERROR[E_PLIK]+mDirectory+DataDir+FILE_LIST);
         AddError('  BEZ TEGO PLIKU NIE SPRAWDZE CZY ISTNIEJA INNE!');

         END
         ELSE
         BEGIN

           {SPRAWDZANIE LISTY PLIKOW}
           Assign(FileID, mDirectory+FILE_LIST);

           {OTWIERANIE PLIKU}
           Reset(FileID);

           {DOPLOKI SA DANE}
           WHILE NOT Eof(FileID) DO
           BEGIN

             {WCZYTAJ JE}
             ReadLn(FileID, FileName);

             {JESLI NIE MA PLIKU KTORY JEST NA LISCIE}
             IF NOT FileExists(mDirectory+FileName) THEN

             {DODAJ DO LISTY BLEDOW}
             AddError('- '+E_ERROR[E_PLIK]+DataDir+FileName)


           END;

           {ZAMYKANIE}
           Close(FileID);
         END;



  {WYSWIETLA KOMUNIKATY O BLEDACH}
  ShowErrors;

  {NOWA CZCIONKA}
  F_NewFont(Font2);

  {WCZYTAJ JA Z PLIKU}
  F_LoadFont(Font2, mDirectory+FontName2);

  {NOWA CZCIONKA}
  F_NewFont(Font);

  {WCZYTAJ JA Z PLIKU}
  F_LoadFont(Font, mDirectory+FontName);

  {NOWY RYSUNEK}
  V_NewImage(Kursor);

  {WCZYTAJ GO}
  V_LoadBMP24(Kursor, mDirectory+CursorFile);

  {KURSOR BEDZIE PRZEZROCZYSTY}
  Kursor^.Transparent:=TRUE;

  {ZWALNIA LISTE BLEDOW}
  FreeErrors;

END;

{***********************************************************************}

PROCEDURE FreeMemory;
BEGIN
  {ZAKONCZENIE PRACY Z MODULEM OBSLUGI KLAWIATURY}
  Keyb_End;

  {ZWOLNIJ PAMIEC KURSORA}
  V_FreeImage(Kursor);

  {BUFOR EKRANU WIRTUALNEGO}
  V_FreeBuf(Ekran);

  {ZWALNIA PAMIEC CZCIONKI}
  F_FreeFont(Font);
  F_FreeFont(Font2);

  {POWROT DO TRYBU TEKSTOWEGO}
  V_End10Eh;

  {BILNAS PAMIECI}
  WriteLn('PAMIEC POCZATKOWA : ',MemF);
  WriteLn('PAMIEC KONCOWA    : ',MemAvail);

END;

{***********************************************************************}

END.