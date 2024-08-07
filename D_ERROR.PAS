{***********************************************************************}
{*                                                                     *}
{*               OBSLUGA BLEDOW DO PRACY DYPLOMOWEJ -DEMO_TP           *}
{*                                                                     *}
{***********************************************************************}

UNIT D_Error;

{***********************************************************************}

INTERFACE

{***********************************************************************}

CONST MaxError=12;


      E_Error:ARRAY[0..MaxError] OF STRING[40]=
      ('Wszystko OK',
       'Brak pamieci rzeczywistej',
       'Brak pliku ',
       'Nie zainstalowano sterownika myszki',
       'Nieprawidlowy format pliku',
       'Zly katalog',
       'Brak sterownika pamieci EMS',
       'Brakuje pamieci EMS',
       'Brak miejsca na dysku',
       'Bitmapa ma nieprawidlowa ilosc kolorow',
       'Bitmapa ma zla rozdzielczosc',
       'Brak podanego obiektu',
       'Zly format pliku');

       E_OK=0;
       E_PAMIEC=1;
       E_PLIK=2;
       E_MYSZ=3;
       E_FORMAT=4;
       E_KATALOG=5;
       E_EMS=6;
       E_PAMIECEMS=7;
       E_DYSK=8;
       E_BPP=9;
       E_SIZE=10;
       E_OBIEKT=11;
       E_ZLY_FORMAT=12;

       D_CAPTION='UWAGA NAPOTKANO BLEDY !';

{***********************************************************************}

TYPE   PError          =^TError;

{***********************************************************************}

       TError          = RECORD
         Next          : PError;
         Caption       : STRING[80];
       END;

{***********************************************************************}

VAR
       {PIERWSZY BLAD NA LISCIE}
       FirstError      : PError;

       {AKTUALNY STWORZONY BLAD}
       ActualError     : PError;


{***********************************************************************}

PROCEDURE AddError(CONST S:STRING);
PROCEDURE ShowErrors;
PROCEDURE FreeErrors;

{***********************************************************************}

IMPLEMENTATION

{***********************************************************************}

PROCEDURE AddError(CONST S:STRING);
BEGIN

  {JESLI JEST JUZ JAKIS BLAD}
  IF Assigned(ActualError) THEN

     BEGIN
       {TWORZY NOWY ELEMENT}
       New(ActualError^.Next);

       {PRZECHODZI DO NIEGO}
       ActualError:=ActualError^.Next;
     END
     ELSE
     BEGIN
       {JESLI NIE MA JESZCZE ZADNEGO TO GO TWORZY}
       New(ActualError);

       {PODSTAWIA DO PIERWSZEGO ELEMENTU NOWO STWORZONY}
       FirstError:=ActualError;
     END;

  {DODAJE KOMUNIKAT}
  Move(S, ActualError^.Caption, SizeOf(ActualError^.Caption));

  {NIE MA NA RAZIE KOLEJNEGO ELEMENTU}
  ActualError^.Next:=NIL;
END;


{***********************************************************************}

PROCEDURE ShowErrors;

VAR
    {W RAZIE BLEDU BEDZIE ZAWIERALO WARTOSC PORTU KLAWIATURY}
    PortValue  : Word;

BEGIN

  {JEZELI WSZYSTKO JEST BEZBLEDNIE WYCHODZI}
  IF NOT Assigned(FirstError) THEN Exit;

  {USTAWIENIE TRYBU TEKSTOWEGO}
  ASM
    Mov  Ax, 3h
    Int  10h
  END;

  {KOMUNIKAT POCZATKOWY}
  WriteLn(D_CAPTION);
  WriteLn;

  {BEDZIE PRZEGLADAL LISTE BLEDOW OD POCZATKU}
  ActualError:=FirstError;

  {DOPLOKI ISTNIEJE W PAMIECI ZAPIS BLEDU}
  WHILE Assigned(ActualError) DO
    BEGIN
      {WYPISZ KOMUNIKAT BLEDU}
      WriteLn('    '+ActualError^.Caption);

      {PRZEJDZ DO NASTEPNEGO BLEDU}
      ActualError:=ActualError^.Next;
    END;

  {INFORMACJA O WOLNEJ PAMIECI}
  WriteLn;
  WriteLn('WOLNA PAMIEC :', MemAvail);

  {PYTANIE O KONTUNUACJE}
  WriteLn;
  WriteLn('CZY CHCESZ KONTYNUOWAC? PROGRAM MOZE NIE DZIALAC POPRAWNIE (T/N)');

  {DOPLOKI NIE PUSCISZ KLAWISZA T LUB N}
  WHILE NOT (PortValue IN [{T}20+128, {N}49+128]) DO

  {POBIERA WARTOSC PORTU KLAWIATURY}
    PortValue:=PORT[$60];

  {JESLI NIE chcESZ KONTYNUOWAC}
  IF PortValue=49+128 THEN
  BEGIN
    {ZWOLNIJ PAMIEC}
    FreeErrors;

    {WYLACZ PROGRAM}
    Halt;
  END;



END;


{***********************************************************************}

PROCEDURE FreeErrors;
BEGIN

  {DOPLOKI ISTNIEJE W PAMIECI ZAPIS BLEDU}
  WHILE Assigned(FirstError) DO
    BEGIN
      {PODSTAW DO CHWILOWEJ PAMIECI ADRES PIERWSZEGO BLEDU}
      ActualError:=FirstError;

      {PRZEJDZ DO NASTEPNEGO BLEDU}
      FirstError:=ActualError^.Next;

      {ZWOLNIJ PAMIEC}
      Dispose(ActualError);
    END;

  {NIE MA JUZ NIC W PAMIECI}
  ActualError:=NIL;
END;

END.