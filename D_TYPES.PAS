{$N+}
UNIT D_Types;

INTERFACE
USES Graph10E, Fonts, Doors, {D_Effect, }G3D;


TYPE
{***********************************************************************}
    PStar      =^TStar;

    TStar      = RECORD
      X, Y, Z   : Integer;
    END;

{***********************************************************************}

    PSprite    = ^TSprite;
    TSprite    = RECORD
      X, Y     : Integer;
      Dx, dy   : Integer;
      ani      : Byte;
    END;


CONST

      {AUTOMATYCZNY OBROT}
      AutoRotate   : Boolean=True;

      {NAZWA PLIKU Z LISTA PLIKOW UZYWANYCH PRZEZ PROGRAM}
      FILE_LIST    = 'lista.txt';

      {KATALOG Z DANYMI}
      DataDir      = 'DemoTP\';

      {PLIK Z FLAGA WIELKIEJ BRYTANI}
      FileAng      = 'bitmapy\ang.bmp';

      {PLIK Z FLAGA POLSKI}
      FilePol      = 'bitmapy\pol.bmp';

      {PASEK START}
      FileStart    = 'bitmapy\start.bmp';

      {ZMIANA EGEKTU}
      FileChange   = 'bitmapy\chng.bmp';

      {GWIAZDY}
      FileStars    = 'bitmapy\chng2.bmp';

      {PLIK Z KURSOREM MYSZKI}
      CursorFile   = 'bitmapy\kur.bmp';

      {PLIK Z OPISEM FIGUR 3d}
      Fig3dFile    = '3d.txt';

      {OBRAZKI}
      FilePicture  = 'images\pict';

      {ILE ROZNYCH EFEKTOW}
      MaxTypes     = 4;
      MaxFig       : Byte =4;

      {OPIS TEKSTUR W PLIKU}
      PlikTekstur  : STRING[12]='tekstury.txt';

      {NAZWA CZCIONKI}
      FontName     = 'czcionki\default.fnt';
      FontName2    = 'czcionki\font.fnt';

      {PLIK POMOCY}
      HelpFile     = 'help.txt';
      FileCube     = 'lab.txt';

      {PLIK Z ZAPISEM FIGURY 3d}
      File3dName   = 'tekstury\opis';
      File3dExt    = '.bmp';

      File3dDesc   = 'opis.txt';


      {PLIK Z JEZYKIEM}
      FileLang     = 'Lang';
      LangExt      = '.txt';


      {NAZWA PLIKU OPISUJACEGO IKONY}
      OpisPulpitu  = 'pulpit';
      OpisExt      = '.txt';

      {KOLOTR TLA PULPITU}
      Kolor        : Word = 15;

      FileSpr      = 'bitmapy\sprite';


      {ILE MENU W PANELU PASKU START}
      MaxPan       = 8;
      MaxPan2      = 4;
      MaxExit      = 3;

      {ILE TEKSTOW}
      MaxTxt       = 30;

      {KTORE 3d}
      Typ3d        :Byte = 1;
      MaxTyp3d     = 2;

      {NAZWY MENU W PANELU WYLACZAJACYM}
      NazwyExit    : ARRAY[1..MaxExit] OF STRING[16]=
      ('WYù§CZ','URUCHOM PONOWNIE','ANULUJ');



VAR

      {KTORY JEZYK}
      Lang              : Byte;

      {KURSOR MYSZKI}
      Kursor            : TPicture;

      {CZCIONKA}
      Font              : PFont;
      Font2             : PFont;

      {WOLNA PAMIEC PRZY URUCHOMIENIU}
      MemF              : LongInt;

      {TEKSTY ANGIELSKIE LUB POLSKIE}
      Texts             : ARRAY[1..MaxTxt] OF STRING[30];

      {OKNO}
      StartBar          : PObject;
      Panel             : PObject;
      Panel2            : PObject;
      ExitPanel         : PObject;
      OpenPanel         : PObject;
      MemPan            : PObject;
      SettingsPanel     : PObject;
      MemoryTemp        : PObject;
      EditOpen          : PObject;
      AuthorPanel       : PObject;
      VertObj           : PObject;

      {PRZYCISK}
      Button            : PObject;

      {TYP ANIMACJI PRZY URUCHOMIONYM SYSTEMIE}
      Typ               : Byte;

      {PAMIEC DLA GWIAZD}
      Stars             : PStar;

      {TLO}
      TloBMP            : TPicture;

      {TYOP GWIAZD}
      StarType          : Byte;

      {CZY MA WYJSC Z PETLI GLOWNEJ}
      Koniec            : Boolean;

      {ZAWIERA NAZWE KATALOGU W KTORYM ZNAJDUJE SIE PROGRAM}
      mDirectory         : STRING;

      {PAMIEC DLA EKRANU}
      Ekran             : TEkran10Eh;

      {NAZWA TEKSTURY NA TYL}
      BgFile            : STRING[25];

      {ILE TROJKATOW 3D}
      Size3d            : Word;

      {GRAFIKA 3D - BUFOR PAMIECI Z TROJKATAMI}
      Dane3d            : PTriangle;
      Temp3d            : PTriangle;

      {PRZESUNIECIE OBIEKTOW}
      Vector            : TVertex;

      KatX,
      KatY,
      KatZ : Byte;

      {KTORA OPCJA ZOSTALA WYBRANA}
      Opcja       : Byte;







IMPLEMENTATION

BEGIN
  {ODLEGLOSC ZANIKANIA OBIEKTU}
  G3D_MaxOdl:=200;

  {KOLOR MGLY}
  G3D_KOLOR_MGLY:=V_RGB($00, 0, $80);

END.
