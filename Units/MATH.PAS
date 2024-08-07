{$N+}
UNIT  Math;

INTERFACE


CONST MaxOP      =5;
      MaxFunc    =3;

      Prioryt    : ARRAY[1..MaxOP] OF BYTE=
      (1, 1, 2, 2, 0);

      Znak       : ARRAY[1..MaxOP] OF CHAR=
      ('+','-','*','/','x');

      Funkcje    : ARRAY[1..MaxFunc] OF CHAR=
      ('!','^','%');


TYPE PListM      =^TListM;
     TListM      = RECORD
       Next      : PListM;
       Liczba    : Single;
       Operacja  : Byte;  {1+,2-,3*,4/}
       Prev      : PListM;
     END;

     PListS      =^TListS;
     TListS      = OBJECT
       Next      : PListM;
       Liczba    : Single;
       Operacja  : Byte;  {1+,2-,3*,4/}
       Priorytet : Byte;
       Prev      : PListM;
     END;

FUNCTION ZaladujDoListy(CONST R:STRING):PListM;
FUNCTION ObliczListe(First:PListM):Single;
FUNCTION SzukajRownan(CONST S:STRING):PListS;

IMPLEMENTATION


PROCEDURE ZdefiniujZmienna(Nazwa:Char; Adres:Pointer);
BEGIN

END;


FUNCTION Silnia(x:Single):Single;
VAR i:Byte;
    w:Single;
BEGIN
  Silnia:=x;
  {ZBYT DUZA WARTOSC!}
  IF x>12 THEN Exit;

  w:=1;
  FOR i:=2 TO Round(x) DO
    w:=w*i;

  Silnia:=w;
END;

FUNCTION Potega(x, y:Single):Single;
VAR i:Byte;
    w:Single;
BEGIN
  {ZBYT DUZA WARTOSC!}
  Potega:=x;
  IF y>15 THEN Exit;

  w:=1;
  FOR i:=1 TO ABS(Round(y)) DO
    w:=w*x;

  IF y<0 THEN w:=1/w;

  Potega:=w;

END;

FUNCTION ObliczLiczbe(i:Byte;l, l2:Single):Single;
BEGIN
  CASE i OF
    1:l:=Silnia(l);
    2:l:=Potega(l, l2);
    3:l:=l/100;
  END;

  ObliczLiczbe:=l;
END;

FUNCTION Oblicz(a, b:Single;Op:Byte):Single;
BEGIN
  CASE Op OF
    1:Oblicz:=a+b;
    2:Oblicz:=a-b;
    3:Oblicz:=a*b;
    4:Oblicz:=a/b;
  END;
END;


FUNCTION ZaladujDoListy(CONST R:STRING):PListM;
VAR Temp  : PListM;
    First : PListM;
    i, p,
    j     : Byte;
    x     : Integer;
    l, l2 : Single;
BEGIN
  i:=1;
  Temp:=NIL;

  REPEAT

      {SZUKA POCZATKU KOLEJNEJ LICZBY}
      WHILE NOT (R[i] IN ['-','.','0'..'9']) AND (i<Byte(R[0])) DO Inc(i);

      p:=i;
      {DODAWANIE KOLEJNEJ LICZBY DO LISTY}
      WHILE (R[i] IN ['-','.','0'..'9'])  AND (i<=Byte(R[0])) DO Inc(i);
      Val(Copy(R, p, i-p), l, x);

      {JESLI LICZBA JEST POLACZONA Z FUNKCJA}
      FOR p:=1 TO MaxFunc DO
      IF R[i]=Funkcje[p] THEN
      BEGIN

        IF Funkcje[p]='^' THEN
        BEGIN
          j:=i+1;
          Inc(i);
          {SZUKANIE POTEGI}
          WHILE (R[i] IN ['-','.','0'..'9']) AND (i<=Byte(R[0])) DO Inc(i);
          Val(Copy(R, j, i-j), l2, x);

        END;
        l:=ObliczLiczbe(p, l, l2);
        Break;
      END;

      {DODAWANIE ZNAKU PO TEJ LICZBIE}
      FOR p:=1 TO MaxOP DO
      IF R[i]=Znak[p] THEN Break;

      IF (p=MaxOP) AND (R[i]<>Znak[p]) THEN
      BEGIN
      {NAWIAS LUB KONIEC}
        {WriteLn('Koniec :',l);}
        p:=5;
        {Continue;}
      END;

      {TWORZY NOWY ELEMENT LISTY}
      IF Temp<>NIL THEN
      BEGIN
        New(Temp^.Next);
        Temp^.Next^.Prev:=Temp;
        temp:=Temp^.Next;
        Temp^.Next:=NIL;
        Temp^.Liczba:=l;
        Temp^.Operacja:=p;
        {WriteLn(l:5:3,' ',Znak[p])}
      END ELSE
      BEGIN
        New(Temp);
        Temp^.Prev:=NIL;
        Temp^.Next:=NIL;
        First:=Temp;
        Temp^.Liczba:=l;
        Temp^.Operacja:=p;
        {WriteLn(l:5:3,' ',Znak[p])}
      END;

      Inc(i);


   UNTIL i>Byte(R[0]);

  ZaladujDoListy:=First;
END;


FUNCTION ObliczListe(First:PListM):Single;
VAR Temp  : PListM;
    L     : Single;
    Op    : Byte;

BEGIN
  l:=0;
  WHILE (First^.Next<>NIL) DO
    BEGIN
      IF (First^.Prev=NIL) OR (Prioryt[First^.Prev^.Operacja]>=Prioryt[First^.Operacja]) THEN
         BEGIN
           IF First^.Prev<>NIL THEN
           BEGIN
             l:=Oblicz(l, First^.Liczba, First^.Prev^.Operacja);
           END ELSE l:=First^.Liczba;

           Temp:=First;
           First:=First^.Next;
           Dispose(Temp);
         END
         ELSE
         IF Assigned(First^.Next) THEN
         BEGIN
           First^.Liczba:=Oblicz(First^.Liczba, First^.Next^.Liczba, First^.Operacja);
           First^.Operacja:=First^.Next^.Operacja;
           Temp:=First^.Next;
           First^.Next:=First^.Next^.Next;
           First^.Next^.Prev:=First;
           Dispose(Temp);
         END;

    END;

  IF Assigned(First^.Prev) THEN
    l:=Oblicz(l, First^.Liczba, First^.Prev^.Operacja) ELSE
  IF Assigned(First^.Next) THEN
    l:=Oblicz(l, First^.Liczba, First^.Next^.Operacja) ELSE
    l:=First^.Liczba;



  ObliczListe:=l;
END;


{NOWA WARTOSC NA LISCIE}
FUNCTION NewValue(l:Single;o, p:Byte):PListS;
VAR Temp : PListS;
BEGIN
  New(Temp);

  Temp^.Next:=NIL;
  Temp^.Prev:=NIL;
  Temp^.liczba:=l;
  Temp^.operacja:=o;
  Temp^.Priorytet:=p;

  NewValue:=Temp;

END;



{POSZUKUJE KAWALKOW WYRAZEN W NAWIASACH}
FUNCTION SzukajRownan(CONST S:STRING):PListS;

VAR
    {POCZATEK I KONIEC PRZEDZIALU TEKSTU}
    i,
    j,
    k    : Byte;

    {PRIORYTET}
    p    : Byte;

BEGIN

  {OD PIERWSZEGO ZNAKU}
  k:=1;

  REPEAT

    {POSZUKIWANIE NAWIASU OTWIERAJACEGO KOLEJNE ROWNANIA}
    IF S[k]='(' THEN
       BEGIN
         {ZWIEKSZENIE ZAGLEBIENIA W WYRAZENIU}
         Inc(p);

         {USTAWIENIE POCZATKOWEGO ZNAKU W TEKSCIE ROZPOCZYNAJACEGO NOWE PODWYRAZENIE}
         i:=k;
       END;

    {POSZUKIWANIE NAWIASU ZAMYKAJACEGO KOLEJNE ROWNANIA}
    IF S[k]=')' THEN
       BEGIN
         {USTAWIENIE KONCOWEGO ZNAKU W TEKSCIE PODWYRAZENIA}
         j:=k;

         {OBLICZA CALY NAWIAS}


         {ZMNIEJSZENIE ZAGLEBIENIA W WYRAZENIU}
         Dec(p);
       END;

    {ROZPATRYWANY KOLEJNY ZNAK}
    Inc(k);

  UNTIL (j>=Byte(S[0]));



END;


END.