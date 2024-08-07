{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                     MODUL :  DOORS                                    *}
{*     PIERWSZA AKTUALIZACJA :  05.01.2005                               *}
{*     OSTATNIA AKTUALIZACJA :  23.05.2005                               *}
{*                   AUTORZY :  S.K. K.S.                                *}
{*                                                                       *}
{*                                                                       *}
{*     Wszelkie prawa autorskie zastrzezone, wykorzystywanie modulu      *}
{*     tylko za zgoda autorow, kontakt:                                  *}
{*                                                                       *}
{*     KamilSkoczylas@o2.pl                                              *}
{*                                                                       *}
{*************************************************************************}


UNIT Doors;

{*************************************************************************}

INTERFACE

USES Errors,        {OBSLUGA I KODY BLEDOW}
     Graph10E,      {GRAFIKA W VESA, TRYB 10Eh}
     Standard,      {STANDARDOWE POLECENIA}
     Fonts;         {OBSLUGA CZCIONEK}


{*************************************************************************}

CONST
      MaxEvents=15;           {WSZYSTKICH ROZNYCH ZDARZEN}
      MINI_BUTTON_SIZE   =10; {ROZMIAR PRZYCISKU NA OKNIE}

      MAX_OBJECTS        =10;

{*************************************************************************}

      {NAZWY OBIEKTOW SYSTEMU SKKS DOORS}

      DOORS_FORM         = 1; {OKNO, NA KTORYM USTAWIA SIE OBIEKTY}
      DOORS_BUTTON       = 2; {PRZYCISK}
      DOORS_EDIT         = 3; {POLE TEKSTOWE}
      DOORS_PANEL        = 4; {PANEL NA KTORYM BEDA INNE OBIEKTY}
      DOORS_ICON         = 5;
      DOORS_LABEL        = 6; {NAPIS OBIEKTOWY}


{*************************************************************************}


TYPE

{*************************************************************************}

      PObject       = ^TObject;

{*************************************************************************}

      {PROCEDURA WYWOLYWANA JAKO ZDARZENIE}
      TProcedure    = PROCEDURE;

      {PROCEDURA RYSUJACA KONKRETNY OBIEKT}
      TDrawProc     = PROCEDURE (Buf:TEkran10Eh; Obj:PObject);

      {PROCEDURA ZMIENIAJACA ROZMIAR}
      TResizeProc   = PROCEDURE (Obj:PObject);

      {PROCEDURA ZWALNIAJACA PAMIEC}
      TFreeFunc     = FUNCTION (Obj:PObject) : Byte;

{*************************************************************************}

      PEventsProc   = ^TEventsProc;
      TEventsProc   = RECORD

        {NASTEPNE ZDARZENIE}
        Next        : PEventsProc;

        {TYP ZDAZRENIA}
        EventID     : Byte;

        {PROCEDRA, KTORA MA BYC WYWOLANA}
        ExecuteProc : TProcedure;
      END;

{*************************************************************************}

      TEvents       = ARRAY[0..MaxEvents] OF Boolean;

{*************************************************************************}

      PEventsObj    = ^TEventsObj;
      TEventsOBj    = OBJECT

        {POZYCJA MYSZKI}
        Mx, My      : Integer;

        {PRZYSICK MYSZY}
        Button      : Integer;

        {WCISNIETY KLAWISZ}
        Key         : Byte;

        {POZYCJA MYSZKI DO KRAWEDZI LEWEJ}
        XToLeft     : Integer;

        {POZYCJA MYSZKI DO KRAWEDZI GORNEJ}
        YToTop      : Integer;

        {TABLICA ZAISTNIALYCH ZDARZEN}
        Ev          : TEvents;



        {PIERWSZE ZDARZENIE  !!!! NA KONCU !!!!}
        FirstProc   : PEventsProc;

        {*****************************************************************}
        PROCEDURE   FreeEvents;


      END;

{*************************************************************************}


      {ZAPIS POZYCJI WYKORZYSTYWANY W OBIEKCIE}
      PPoz          = ^TPoz;
      TPoz          = RECORD

        {POZYCJA POZIOMA I PIONOWA}
        X, Y        :Integer;

        {SZEROKOSC I WYSOKOSC}
        Width       :Integer;
        Height      :Integer;

      END;
{*************************************************************************}

      {OBIEKT MODULU, NP. PRZYCISK, OKNO, IKONA}
      TObject       = OBJECT

        {NASTEPNY I POPRZEDNI OBIEKT}
        Next,
        Prev        : PObject;

        {WSKAZNIK NA ZDARZENIA}
        Events      : PEventsObj;

        {SPECYFICZNE PARAMETRY DLA OBIEKTU}
        Params      : Pointer;

        {TYP OBIEKTU, NP. PRZYCISK, POLE TEKSTOWE}
        TypID       : Byte;

        {WSKAZNIK NA SAMEGO SIEBIE}
        Obj         : PObject;

        {CZY MA REAGOWAC NA ZDARZENIA}
        Active      : Boolean;

        {CZY JEST WIDOCZNY}
        Visible     : Boolean;

        {CZY MOZNA GO PRZECIAGAC MYSZKA}
        CanDrag     : Boolean;

        {POZYCJA OBIEKTU}
        Pos         : PPoz;

        {PIERWSZY OBIEKT PODRZEDNY - DZIECKO, NP. PRZYCISK NA OKNIE}
        Children    : PObject;

        {OSTATNI OBIEKT PODRZEDNY}
        LastChild   : PObject;

        {WSKAZNIK NA OBIEKT NADRZEDNY}
        Parent      : PObject;


        {ZWALNIA WSZYSTKIE ZDARZENIA POWIAZANE Z OBIEKTEM}
        FUNCTION FreeEvents:BYTE;

        {ZWALNIA CALA PAMIEC OBIEKTU -RAZEM Z POWIAZANYMI BITMAPAMI}
        FUNCTION FreeMemory:BYTE;

        {ZMIENIA ROZMIAR OBIEKTU}
        PROCEDURE Resize(X, Y, W, H:Integer);

        {POKAZUJE OBIEKT I USTAWIA NA AKTYWNY}
        PROCEDURE Show;

        {USTAWIA OBIEKT NA PIERWSZY PLAN}
        PROCEDURE SetActive;

        {USTAWIA OBIEKT NA PIERWSZY PLAN}
        PROCEDURE Hide;

      END;
{*************************************************************************}
VAR
        {PIERWSZY OBIEKT}
        FirstObj    : PObject;

        {OSTATI OBIEKT}
        LastObj     : PObject;

        {TABLICA PROCEDUR RYSUJACYCH}
        DrawProc    : ARRAY[1..MAX_OBJECTS] OF TDrawProc;

        {PROCEDURY ZMIENIAJACE ROZMIAR}
        ResizeProc  : ARRAY[1..MAX_OBJECTS] OF TResizeProc;

        {PROCEDURY ZWALNIAJACE PAMIEC}
        FreeFunc    : ARRAY[1..MAX_OBJECTS] OF TFreeFunc;

{*************************************************************************}

{TWORZY OBIEKT GLOWNY, NADRZEDNY}
FUNCTION D_CreateObject(VAR Obj:PObject):Byte;

{TWORZY OBIEKT PODRZEDNY}
FUNCTION D_CreateChild(Parent:PObject;VAR Child:PObject):BYTE;

{USUWA OBIEKT}
FUNCTION D_DeleteObject(VAR Obj:PObject):Byte;

{ZWALNIA CALA PAMIEC ZABRANA PRZEZ SYSTEM}
FUNCTION D_FreeAllMemory:Byte;

{*************************************************************************}

{NOWE ZDARZENIE -WYWOLYWANE AUTOMATYCZNIE}
FUNCTION D_NewEvent(EvObj:PEventsObj; Proc:TProcedure;Event:Byte):PEventsProc;

{*************************************************************************}
IMPLEMENTATION
USES Doors10E;


{*************************************************************************}
PROCEDURE TEventsObj.FreeEvents;

VAR
     {TYMCZASOWA PAMIEC DO KASOWANIA ZDARZEN}
     Temp:PEventsProc;

BEGIN
  {DOPLOKI MA W PAMIECI ADRESY PROCEDUR}
  WHILE Assigned(FirstProc) DO
    BEGIN
      {ZAPAMIETUJE ADRES}
      Temp:=FirstProc;

      {PRZECHODZI DO KOLEJNEGO ELEMENTU}
      FirstProc:=FirstProc^.Next;

      {ZWALNIA PAMIEC STAREGO}
      Dispose(Temp);
    END;
END;

{*************************************************************************}

FUNCTION D_NewEvent(EvObj:PEventsObj; Proc:TProcedure;Event:Byte):PEventsProc;
VAR
     {TYMCZASOWA PAMIEC DO TWORZENIA ZDARZEN}
     Temp:PEventsProc;
BEGIN

  IF MaxAvail<SizeOf(TEventsProc) THEN Exit;

  IF NOT Assigned(EvObj) THEN
    BEGIN
      D_NewEvent:=NIL;
      Exit;
    END;

  {NOWE ZDARZENIE}
  New(Temp);

  {WSTAWIA PROCEDURE}
  Temp^.ExecuteProc:=TProcedure(Proc);

  {TYP ZDARZENIA}
  Temp^.EventID:=Event;

  {ZWRACA ADRES POZYCJI ZDARZENIA W LISCIE}
  D_NewEvent:=Temp;

  {KOLEJNYM ZDARZENIEM BEDZIE TO CO BYLO PIERWSZE}
  Temp^.Next:=EvObj^.FirstProc;

  {A PIERWSZYM NOWO UTWORZONE}
  EvObj^.FirstProc:=Temp;
END;

{*************************************************************************}
PROCEDURE TObject.Resize(X, Y, W, H:Integer);
BEGIN

  {JESLI ZMIENI SIE ROZMIAR JAKIEGOS OBIEKTU}
  {PRZYPISUJE JEGO POZYCJOM NOWE WARTOSCI}
  Pos^.X:=X;
  Pos^.Y:=Y;
  Pos^.Width:=W;
  Pos^.Height:=H;

  {JESLI OBIEKT WYMAGA ZMIANY INNYCH PARAMETROW TO WYWOLUJE PROCEDURE}
  IF Assigned(ResizeProc[TypID]) THEN ResizeProc[TypID](Obj);

END;

{*************************************************************************}
PROCEDURE TObject.Show;
BEGIN
  {OBIEKT BEDZIE WIDOCZNY}
  Visible:=TRUE;

  {I STANIE SIE AKTYWNY}
  SetActive;
END;

{*************************************************************************}
PROCEDURE TObject.Hide;
BEGIN
  {OBIEKT BEDZIE WIDOCZNY}
  Visible:=False;

END;



{*************************************************************************}
{USTAWIA STANDARDOWE WARTOSCI DLA OBIEKTU}
PROCEDURE SetDefaults(Obj:PObject);
BEGIN

  {JESLI NIE MA TAKIEGO OBIEKTU TO NIE MA CO USTAWIAC}
  IF NOT Assigned(Obj) THEN Exit;

  IF MemAvail<SizeOf(TEventsObj) THEN
  BEGIN
    WITH Obj^ DO
    BEGIN
      {NIE MA PAMIECI DLA ZDARZEN}
      Events:=NIL;

      {OBIEKT NIE MA PRZYDZIELONEJ PAMIECI NA PARAMETRY}
      Params   :=NIL;

      {TO PRZYKRE, NIE MA RODZICOW :) PRZYNAJMNIEJ JESZCZE NIE WIE NIC O NICH}
      Parent   :=NIL;

      {NIE MA POZYCJI}
      Pos      :=NIL;

      {NIE MA DZIECI, BO JAK}
      Children :=NIL;
      LastChild:=NIL;

    END;

    Exit;
  END;


  WITH Obj^ DO
    BEGIN
      {TWORZENIE NOWYCH ZDAZREN}
      New(Events);

      {NA RAZIE NIE BEDA MIALY ZADNYCH USTAWIONYCH}
      S_FillChar32(Events, SizeOf(TEventsOBj), 0);

      {PIERWSZE ZDARZENIE JEST JESZCZE NIEAKTYWNE}
      Events^.FirstProc:=NIL;

      {OBIEKT NIE MA PRZYDZIELONEJ PAMIECI NA PARAMETRY}
      Params   :=NIL;

      {JEST AKTYWNY}
      Active   :=True;

      {I WIDOCZNY}
      Visible  :=True;

      {ALE NIE WIADOMO CO TO BEDZIE}
      TypID    :=0;

      {NIE MOZNA GO PRZECIAGAC}
      CanDrag  :=False;

      {TO PRZYKRE, NIE MA RODZICOW :) PRZYNAJMNIEJ JESZCZE NIE WIE NIC O NICH}
      Parent   :=NIL;

      {NIE MA POZYCJI}
      Pos      :=NIL;

      {NIE MA DZIECI, BO JAK}
      Children :=NIL;
      LastChild:=NIL;


    END;
END;
{*************************************************************************}
{OBIEKT STANIE SIE WIDOCZNY, WYJDZIE NA WIERZCH}
PROCEDURE TObject.SetActive;

BEGIN

  IF Assigned(Parent) THEN
  BEGIN

    IF (Obj<>NIL) AND (Obj<>Parent^.LastChild) AND Assigned(Parent^.Children) THEN
    BEGIN

      IF Obj^.Prev<>NIL THEN
      BEGIN
        {USTAWIANIE KOLEJNOSCI OBIEKTOW}
        Obj^.Prev^.Next:=Obj^.Next;
        Obj^.Next^.Prev:=Obj^.Prev;
      END ELSE
      BEGIN
        Obj^.Next^.Prev:=NIL;
        Parent^.Children:=Obj^.Next;
      END;

      Parent^.LastChild^.Next:=Obj;
      Obj^.Next:=NIL;
      Obj^.Prev:=Parent^.LastChild;
      Parent^.LastChild:=Obj;
    END;

  END
  ELSE
  BEGIN
    IF (Obj<>NIL) AND (Obj<>LastObj) THEN
    BEGIN

      IF Obj^.Prev<>NIL THEN
      BEGIN
        {USTAWIANIE KOLEJNOSCI OBIEKTOW}
        Obj^.Prev^.Next:=Obj^.Next;
        Obj^.Next^.Prev:=Obj^.Prev;
      END ELSE
      BEGIN
        Obj^.Next^.Prev:=NIL;
        FirstObj:=Obj^.Next;
      END;

      LastObj^.Next:=Obj;
      Obj^.Next:=NIL;
      Obj^.Prev:=LastObj;
      LastObj:=Obj;
    END;
  END;
END;


{*************************************************************************}
FUNCTION D_CreateObject(VAR Obj:PObject):Byte;
VAR Temp:Pointer;

BEGIN
  {WSZYSTKO NA RAZIE OK}
  D_CreateObject:=E_OK;


  IF MaxAvail<(SizeOf(TObject)+SizeOf(TEventsObj)) THEN
    BEGIN
      D_CreateObject:=E_PAMIEC;
      Exit;
    END;

  New(Obj);
  Obj^.Obj:=Obj;

  {TWORZENIE LISTY OBIEKTOW (LastLst)}
  IF LastObj =NIL THEN
    BEGIN
      FirstObj:=Obj;
      LastObj:=Obj;
      Obj^.Next:=NIL;
      Obj^.Prev:=NIL;
    END ELSE
  BEGIN

    LastObj^.Next:=Obj;
    Temp:=LastObj;

    LastObj:=Obj;
    LastObj^.Prev:=Temp;
    LastObj^.Obj:=Obj;
    LastObj^.Next:=NIL;
  END;

  SetDefaults(Obj);

END;

{*************************************************************************}
FUNCTION D_CreateObjectChild(VAR Obj:PObject):Byte;
VAR Temp:Pointer;

BEGIN
  Obj:=NIL;

  {WSZYSTKO NA RAZIE OK}
  D_CreateObjectChild:=E_OK;

  IF MaxAvail<(SizeOf(TObject)+SizeOf(TEventsObj)) THEN
    BEGIN
      D_CreateObjectChild:=E_PAMIEC;
      Exit;
    END;

  New(Obj);

  Obj^.Next:=NIL;
  Obj^.Prev:=NIL;
  Obj^.Obj:=Obj;


  SetDefaults(Obj);

END;

{*************************************************************************}
FUNCTION D_CreateChild(Parent:PObject;VAR Child:PObject):BYTE;
VAR Temp:PObject;
BEGIN

  {UTWORZENIE NOWEGO ELEMENTU LISTY}
  D_CreateObjectChild(Child);

  {USTALENIE KTO JEST TATUSIEM NOWO POWSTALEGO DZIECKA :)}
  Child^.Parent:=Parent;

  {JESLI ISTNIEJE JUZ JAKIES DZIECKO}
  IF Assigned(Parent^.LastChild) THEN

  BEGIN
     {POPRZEDNIM BEDZIE TO CO BYLO OSTATNIE}
     Child^.Prev:=Parent^.LastChild;

     {OSTATNIM BEDZIE NOWO UTWORZONE}
     Parent^.LastChild^.Next:=Child;
     Parent^.LastChild:=Child;

  END
  ELSE
    BEGIN

     {JESLI NIE JAKO PIERWSZE}
     Parent^.Children:=Child;

     {I OSTATNIE}
     Parent^.LastChild:=Child;


    END;

END;

{*************************************************************************}
FUNCTION TObject.FreeEvents:BYTE;
BEGIN
  {WSZYSTKO OK}
  FreeEvents:=E_OK;

  {JESLI NIE MA OBIEKTU ZAZNACZA ZE JEDNAK NIE OK I WYCHODZI}
  IF Events=NIL THEN BEGIN FreeEvents:=E_OBIEKT;Exit;END;

  {ZWALNIA ADRESY PROCEDUR DLA KAZDEGO ZDARZENIA}
  Events^.FreeEvents;

  {ZWALNIA TABLICE ZDARZEN}
  Dispose(Events);
END;

{*************************************************************************}
FUNCTION TObject.FreeMemory:BYTE;
BEGIN
  FreeMemory:=E_OK;
  IF Obj=NIL THEN BEGIN FreeMemory:=E_OBIEKT;Exit;END;

  {WYWOLUJE PROCEDURE KTORA}
  IF Assigned(FreeFunc[Obj^.TypID]) THEN FreeFunc[Obj^.TypID](Obj);

  {ZWALNIA ZDARZENIA OBIEKTU}
  FreeEvents;

  {ZWALNIA OBIEKT}
  Dispose(Obj);

END;

{*************************************************************************}
FUNCTION D_DeleteObject(VAR Obj:PObject):Byte;
VAR Temp, Temp2, Temp3:PObject;
BEGIN
  D_DeleteObject:=E_OK;

  {JESLI NIE MA TAKIEGO OBIEKTU WYCHODZI}
  IF Obj=NIL THEN BEGIN D_DeleteObject:=E_OBIEKT;Exit;END;


  IF Assigned(Obj^.Parent) THEN
  BEGIN
    IF Obj^.Prev=NIL THEN
    BEGIN
      Temp:=Obj^.Next;
      Obj^.FreeMemory;
      Temp^.Prev:=NIL;
      Obj^.Parent^.Children:=Temp;
      {WriteLn('Kasowanie pierwszego');}
    END ELSE
    IF Obj^.Next=NIL THEN
    BEGIN
      Temp:=Obj^.Prev;
      Obj^.FreeMemory;
      Temp^.Next:=NIL;
      Obj^.Parent^.LastChild:=Temp;
      {WriteLn('Kasowanie ostatniego');}
    END ELSE
    BEGIN
      Temp:=Obj^.Prev;
      Temp2:=Obj^.Next;
      Temp^.Next:=Temp2;
      Temp2^.Prev:=Temp;
      Obj^.FreeMemory;
      {WriteLn('Kasowanie srodkowego');}
    END;
  END ELSE

  BEGIN
  IF Obj^.Prev=NIL THEN
    BEGIN
      Temp:=Obj^.Next;
      Obj^.FreeMemory;
      Temp^.Prev:=NIL;
      FirstObj:=Temp;
      {WriteLn('Kasowanie pierwszego');}
    END ELSE
    IF Obj^.Next=NIL THEN
    BEGIN
      Temp:=Obj^.Prev;
      Obj^.FreeMemory;
      Temp^.Next:=NIL;
      LastObj:=Temp;
      {WriteLn('Kasowanie ostatniego');}
    END ELSE
    BEGIN
      Temp:=Obj^.Prev;
      Temp2:=Obj^.Next;
      Temp^.Next:=Temp2;
      Temp2^.Prev:=Temp;
      Obj^.FreeMemory;
      {WriteLn('Kasowanie srodkowego');}
    END;
    END;


END;


{*************************************************************************}
FUNCTION D_FreeAllMemory:Byte;
VAR Temp:PObject;

PROCEDURE FreeAllChildren(First:PObject);
BEGIN

  WHILE Assigned(First) DO
    BEGIN
      {ZWALNIA REKURENCYJNIE PAMIEC WSZYSTKICH DZIECI}
      FreeAllChildren(First^.Children);

      {PODSTAWIA DO PAMIECI TYMCZASOWEJ}
      Temp:=First;

      {PRZEJSCIE DO KOLEJNEGO ELEMENTU}
      First:=First^.Next;

      {KASOWANIE POPRZEDNIEGO}
      D_DeleteObject(Temp);

    END;
END;

BEGIN

  {KASUJE WSZYSTKIE OBIEKTY Z PAMIECI}
  FreeAllChildren(FirstObj);

  {NIE MA PIERWSZEGO OBIEKTU}
  FirstObj     :=NIL;

  {ANI OSTATNIEGO}
  LastObj      :=NIL;

END;


{*************************************************************************}
BEGIN
  {NIE MA PIERWSZEGO OBIEKTU}
  FirstObj     :=NIL;

  {ANI OSTATNIEGO}
  LastObj      :=NIL;
END.