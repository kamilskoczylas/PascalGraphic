{***********************************************************************}
{*                                                                     *}
{*     PODSTAWOWE OPERACJE NA PLIKACH DO PRACY DYPLOMOWEJ -DEMO_TP     *}
{*                                                                     *}
{***********************************************************************}
UNIT D_InOut;

INTERFACE

{***********************************************************************}

FUNCTION FileExists(FileName: STRING): Boolean;

{***********************************************************************}

IMPLEMENTATION

{***********************************************************************}

FUNCTION FileExists(FileName: STRING): Boolean;

VAR
     {IDENTYFIKATOR PLIKU}
     F: FILE;

BEGIN
 {$I-}

 {PODLACZ SIE DO PLIKU}
 Assign(F, FileName);

 {TYLKO DO ODCZYTU}
 FileMode := 0;

 {OTWORZ PLIK}
 Reset(F);

 {ZAMKNIJ}
 Close(F);

 {$I+}

 {JESLI NIE BYLO BLEDU PLIK ISTNIEJE}
 FileExists := (IOResult = 0) AND (FileName <> '');
END;

END.