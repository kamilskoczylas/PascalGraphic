{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                     MODUL :  DOORS_EV                                 *}
{*     OSTATNIA AKTUALIZACJA :  06.01.2005                               *}
{*                                                                       *}
{*                   AUTORZY :  S.K. K.S.                                *}
{*                                                                       *}
{*     MODUL SLUZY DO OBSLUGI ZDARZEN SYSTEMU DOORS                      *}
{*                                                                       *}
{*************************************************************************}

UNIT DOORS_EV;

{*************************************************************************}

INTERFACE

USES
    MouseX, Keyb_X, Doors, Standard;


{*************************************************************************}
CONST

    DE_KeyDelay     =4;

    ON_MOUSE_MOVE   =1;
    ON_MOUSE_ON     =2;
    ON_MOUSE_DOWN   =3;
    ON_MOUSE_UP     =4;
    ON_MOUSE_DRAG   =5;
    ON_START_DRAG   =6;
    ON_MOUSE_CLICK  =7;


    {KLAWIATUROWE ZDARZENIA MAJA BIT 3 USTAWIONY}
    ON_KEY_DOWN     =8;



{*************************************************************************}

VAR
    Events      : TEventsObj;
    DragingObj  : PObject;
    DragingChild: PObject;
    YToTopObj   : Integer;
    XToLeftObj  : Integer;
    YToTopChild : Integer;
    XToLeftChild: Integer;
    PSy, PSX    : Integer;

    LastKey     : Byte;
    BeforeKey   : Byte;
    Focused     : PObject;
    DE_Timer    : Longint ABSOLUTE $40:$6C;
    DE_OldTimer : Longint;
    TimerXX     : Longint;
    DE_KeyDelayX: Byte;

    DE_Migaj      : Boolean;
    StandardFocus : PObject;
    MouseOnObj    : PObject;
    AAx, AAy      : Integer;
    MyszX,
    MyszY         : Integer;





{*************************************************************************}

FUNCTION DE_GetEvents:Byte;
FUNCTION DE_ObjectEvent(Obj:PObject; Event:Byte):Boolean;
PROCEDURE DE_ExecuteEvents(Event:PEventsObj);
PROCEDURE DE_ExecuteKeyBoardEvents(Event:PEventsObj);
{*************************************************************************}

PROCEDURE DE_SetEvents;
PROCEDURE DE_DeleteEvents;

{*************************************************************************}
{Zdarzenia systemowe :                                                    }

FUNCTION DE_OnMouseMove(Mx, My:Integer):Byte;
FUNCTION DE_OnMouseOn(Mx, My:Integer):Byte;
FUNCTION DE_OnMouseDown(Mx, My, Button:Integer):Byte;
FUNCTION DE_OnMouseUP(Mx, My, Button:Integer):Byte;
FUNCTION DE_OnMouseDrag(Mx, My, Button:Integer):Byte;
FUNCTION DE_OnStartDragging(MX, MY:Integer):Byte;
FUNCTION DE_OnMouseClick(Mx, My, Button:Integer):Byte;

{*************************************************************************}

IMPLEMENTATION

USES Edits, Doors10E;

VAR
    Sx, Sy    : Integer;

    Button    : Byte;
    SButton   : Byte;
    OldButton : Byte;

{*************************************************************************}

FUNCTION DE_GetEvents:Byte;
BEGIN
  Sx:=MyszX;
  Sy:=MyszY;
  SButton:=Button;
  MouseButtonsXY(MyszX, MyszY, Button);

  BeforeKey:=LastKey;
  LastKey:=PORT[$60];

  IF TimerXX+DE_KeyDelay<=DE_Timer THEN
  BEGIN
    DE_Migaj:=NOT DE_Migaj;
    TimerXX:=DE_Timer;
  END;


  IF (Sx<>Myszx) OR (Sy<>Myszy) THEN
  {****************************************}
     DE_OnMouseMove(Myszx, Myszy);
  {****************************************}
     DE_OnMouseOn(Myszx, Myszy);

  IF Button<>M_ZADEN THEN
  {****************************************}
     DE_OnMouseDown(Myszx, Myszy, Button);
  {****************************************}
  IF (Button=M_ZADEN) AND (SButton<>M_ZADEN) THEN
  {****************************************}
     DE_OnMouseUp(Myszx, Myszy, SButton);
  {****************************************}
  IF (Button=M_LEWY) {AND ((Sx<>Myszx) OR (Sy<>Myszy))} THEN
     DE_OnMouseDrag(MyszX, MyszY, Button);
  {****************************************}
  IF (SButton=M_ZADEN) AND (Button=M_LEWY) AND
     (DragingObj=NIL) THEN
     DE_OnStartDragging(MyszX, MyszY);
  {****************************************}
  IF (SButton=M_LEWY) AND (Button=M_ZADEN) AND
     ((PSx=Myszx) AND (PSy=Myszy)) THEN
     DE_OnMouseClick(MyszX, MyszY, SButton);

  DE_SetEvents;

  S_FillChar32(@Events, SizeOf(TEventsObj), 0);
END;
{*************************************************************************}

FUNCTION DE_OnMouseMove(Mx, My:Integer):Byte;
BEGIN
  Events.Mx:=Mx;
  Events.My:=My;
  Events.Ev[ON_MOUSE_MOVE]:=TRUE;
END;
    {**************************************}
FUNCTION DE_OnMouseOn(Mx, My:Integer):Byte;
BEGIN
  Events.Mx:=Mx;
  Events.My:=My;
  Events.Ev[ON_MOUSE_ON]:=TRUE;
END;
    {**************************************}
FUNCTION DE_OnMouseDown(Mx, My, Button:Integer):Byte;
BEGIN
  Events.Mx:=Mx;
  Events.My:=My;
  Events.Button:=Button;
  Events.Ev[ON_MOUSE_DOWN]:=TRUE;
END;
    {**************************************}
FUNCTION DE_OnMouseUP(Mx, My, Button:Integer):Byte;
BEGIN
  Events.Mx:=Mx;
  Events.My:=My;
  Events.Button:=Button;
  Events.Ev[ON_MOUSE_UP]:=TRUE;
END;
    {**************************************}
FUNCTION DE_OnMouseDrag(Mx, My, Button:Integer):Byte;
BEGIN
  Events.Mx:=Mx;
  Events.My:=My;
  Events.Button:=Button;
  Events.Ev[ON_MOUSE_DRAG]:=TRUE;
END;
    {**************************************}
FUNCTION DE_OnStartDragging(MX, MY:Integer):Byte;
BEGIN
  Events.Mx:=Mx;
  Events.My:=My;
  Events.Ev[ON_START_DRAG]:=TRUE;
END;
    {**************************************}
FUNCTION DE_OnMouseClick(Mx, My, Button:Integer):Byte;
BEGIN
  Events.Mx:=Mx;
  Events.My:=My;
  Events.Button:=Button;
  Events.Ev[ON_MOUSE_CLICK]:=TRUE;
END;
    {**************************************}

{*************************************************************************}
FUNCTION DE_WOknie(Pos:PPoz;X, Y:Integer):Boolean;
BEGIN
DE_WOknie:=((Pos<>NIL) AND (X>=Pos^.X) AND
                           (X<=(Pos^.X+Pos^.Width)) AND

                           (Y>=Pos^.Y) AND
                           (Y<=(Pos^.Y+Pos^.Height)));
END;


{*************************************************************************}
PROCEDURE DE_SetEventsForObject(Obj:PObject; VAR Drag:PObject;VAR XToLeft, YToTop:Integer;AddX, AddY:Integer);
BEGIN

  IF (Obj=NIL) OR (Obj^.Events=NIL) OR NOT (Obj^.Visible) THEN Exit;

    {ZDARZENIA DLA MYSZKI :}
    IF NOT Events.Ev[ON_MOUSE_DOWN] THEN Drag:=NIL;

    {PRZECIAGANIE OBIEKTU}
      IF Obj^.CanDrag AND Events.Ev[ON_MOUSE_DRAG]
      AND (Drag=Obj) THEN
           BEGIN
             Obj^.Events^.Ev[ON_MOUSE_DRAG]:=TRUE;
             Obj^.Events^.Mx:=Events.Mx-AddX;
             Obj^.Events^.My:=Events.My-AddY;
             Obj^.Events^.Button:=Events.Button;

             Obj^.Pos^.X:=Events.Mx-AddX-XToLeft;
             Obj^.Pos^.Y:=Events.My-AddY-YToTop;
           END;

    {SPRAWDZANIE POZYCJI OBIEKTU, CZY MYSZKA W MOMENCIE
     ZDARZENIA BYLA NAD OBIEKTEM}


    IF DE_WOknie(Obj^.Pos, Events.Mx-AddX, Events.My-AddY) THEN
    BEGIN
      MouseOnObj:=Obj;
      AAx:=Addx;
      AAy:=Addy;
    END
    ELSE

    {JESLI OBIEKT NIE JEST W OKNIE}
    IF NOT Events.Ev[ON_MOUSE_DRAG] AND (Obj=Drag) THEN
           Drag:=NIL;


END;
{*************************************************************************}
PROCEDURE DE_SetXEvents(Obj:PObject; VAR Drag:PObject;VAR XToLeft, YToTop:Integer;AddX, AddY:Integer);
VAR TempX:TPoz;
BEGIN
  IF Obj=NIL THEN Exit;

        IF Events.Ev[ON_MOUSE_MOVE] THEN
           BEGIN
             Obj^.Events^.Ev[ON_MOUSE_MOVE]:=TRUE;
             Obj^.Events^.Mx:=Events.Mx-AddX;
             Obj^.Events^.My:=Events.My-AddY;
           END;

        IF Events.Ev[ON_MOUSE_ON] THEN
           BEGIN
             Obj^.Events^.Ev[ON_MOUSE_ON]:=TRUE;
             Obj^.Events^.Mx:=Events.Mx-AddX;
             Obj^.Events^.My:=Events.My-AddY;
           END;

        IF Events.Ev[ON_MOUSE_DOWN] THEN
           BEGIN
             Obj^.Events^.Ev[ON_MOUSE_DOWN]:=TRUE;
             Obj^.Events^.Mx:=Events.Mx-AddX;
             Obj^.Events^.My:=Events.My-AddY;
             Obj^.Events^.Button:=Events.Button;

        END;

        IF Events.Ev[ON_MOUSE_UP] THEN
           BEGIN
             Obj^.Events^.Ev[ON_MOUSE_UP]:=TRUE;
             Obj^.Events^.Mx:=Events.Mx-AddX;
             Obj^.Events^.My:=Events.My-AddY;
             Obj^.Events^.Button:=Events.Button;
             Drag:=NIL;
           END;

        IF Events.Ev[ON_START_DRAG] THEN
           BEGIN

             {TempX:=Obj^.Pos^;
             TempX.Height:=CAPTION_SIZE;


             IF DE_WOknie(@TempX, Events.Mx, Events.My) THEN
             BEGIN}

               Psx:=Events.Mx;
               Psy:=Events.My;

               Drag:=Obj;



               Obj^.Events^.Ev[ON_START_DRAG]:=TRUE;
               Obj^.Events^.Mx:=Events.Mx-AddX;
               Obj^.Events^.My:=Events.My-AddY;

               XToLeft:=Events.Mx-(Obj^.Pos^.X+AddX);
               YToTop:=Events.My-(Obj^.Pos^.Y+Addy);
             {END;}
           END;

        IF Events.Ev[ON_MOUSE_CLICK] THEN
           BEGIN
             Obj^.Events^.Ev[ON_MOUSE_CLICK]:=TRUE;
             Obj^.Events^.Mx:=Events.Mx-AddX;
             Obj^.Events^.My:=Events.My-AddY;
             Obj^.Events^.Button:=Events.Button;
             Drag:=NIL;

             {USTAWIA AKTYWNY OBIEKT NA BADANY}
             Focused:=Obj;
           END;

END;



PROCEDURE DE_GetEventsFromKeyboard;  FAR;
VAR Znak:CHAR;
BEGIN
  IF (Focused<>NIL) AND (Focused^.TYPID=DOORS_EDIT) THEN
  BEGIN
    LastKey:=PORT[$60];
    DodajZnak(Focused, PORT[$60]);
    DE_ExecuteKeyBoardEvents(Focused^.Events);

  END ELSE{JESLI JAKIS OBIEKT JEST AKTYWNY}

  IF Assigned(StandardFocus) THEN
  BEGIN
    LastKey:=PORT[$60];
    DodajZnak(StandardFocus, PORT[$60]);
    DE_ExecuteKeyBoardEvents(StandardFocus^.Events);

  END;



END;


{*************************************************************************}

PROCEDURE DE_SetEvents;

VAR Temp           : PObject;
    Active         : Boolean;


{USTAWIA ZDARZENIA DLA LISTY DZIECI}
PROCEDURE SetEventsForChildren(Obj:PObject;Ax, Ay:Integer);
VAR TAx,
    TAy : Integer; {ZAPAMIETUJE PRZERSUNIECIE RODZICA}
    Foc : PObject;
    Fc2 : PObject;

BEGIN

  {DOPLOKI ISTNIEJE TAKI OBIEKT}
  WHILE Assigned(Obj) DO
  BEGIN

    IF NOT Obj^.Visible THEN
       BEGIN
         {IDZIE DO KOLEJNEGO OBIEKTU}
         Obj:=Obj^.Next;

         {KONTUNUUJE PETLE WHILE}
         Continue;
       END;

    {PRZESUWA POZYCJE DZIECKA O POZYCJE RODZICA}
    TAx:=Ax+Obj^.Pos^.X;
    TAy:=Ay+Obj^.Pos^.Y;

    {ZAPAMIETUJE AKTYWNY OBIEKT
    Foc:=Focused;

    {ZAPAMIETUJE AKTYWNE DZIECKO
    Fc2:=Focused;}

    {USTAWIENIE ZDARZEN DLA BADANEGO OBIEKTU}
    DE_SetEventsForObject(Obj, DragingObj, XToLeftObj, YToTopObj, Ax, Ay);

    {WYWOLUJE REKURENCYJNIE ZDARZENIA DLA LISTY DZIECI}
    SetEventsForChildren(Obj^.Children, TAx, TAy);

    {AKTYWNE POZOSTANIE DZIECKO A NIE RODZIC}
    {IF (Fc2<>Foc) AND (Focused<>Fc2) THEN Focused:=Fc2;}

    {AKTYWNYM BEDZIE PRZESUWANY}
    Temp:=DragingObj;

    {PRZEJSCIE DO KOLEJNEGO OBIEKTU}
    Obj:=Obj^.Next;
  END;

END;

BEGIN
  MouseOnObj:=NIL;
  AAx:=0;AAy:=0;

  {REKURENCYJNE WYWOLYWANIE ZDARZEN DLA DZIECI}
  SetEventsForChildren(FirstObj, AAx, AAy);

  {ZAZNACZENIE ZDARZEN DLA AKTYWNEGO OBIEKTU}
  DE_SetXEvents(MouseOnObj, DragingObj, XToLeftObj, YToTopObj, AAx, AAy);

  IF Temp=DragingObj THEN Active:=TRUE ELSE Active:=FALSE;

  {WYWOLANIE PRZYPISANYCH PROCEDUR ZDARZENIOM}
  IF Assigned(MouseOnObj) THEN DE_ExecuteEvents(MouseOnObj^.Events);

  {USTAWIANIE AKTYWNEGO OBIEKTU}
  IF Active AND Assigned(DragingObj) THEN DragingObj^.SetActive;

  {USTAWIANIE POZYCJI KARETKI DLA OBIEKTOW TYPU Edit}
  IF Assigned(Focused) AND (PObject(Focused)^.TypID=DOORS_EDIT) THEN
  IF DE_ObjectEvent(Focused, ON_MOUSE_DOWN) THEN
     PEditParams(PObject(Focused)^.Params)^.SetCursorFromMouse;


END;

{*************************************************************************}
PROCEDURE DE_DeleteEvents;

VAR Obj, TempObj : PObject;

{KASOWANIE ZDARZEN DLA DZIECKA}
PROCEDURE DeleteChildrenEvents(XObj:PObject);
BEGIN

  {DOPLOKI NIE DOSZLISMY DO OSTATNIEGO DZIECKA}
  WHILE Assigned(XObj) DO
    BEGIN

      {JESLI ISTNIEJA DZIECI TO KASUJE ICH ZDARZENIA}
      IF Assigned(XObj^.Children) THEN DeleteChildrenEvents(XObj^.Children);

      {JESLI OBIEKT MA SWOJE ZDARZENIA}
      IF Assigned(XObj^.Events) THEN

        {CZYSCI PAMIEC ZDARZEN}
        S_FillChar32(@XObj^.Events^.Ev, SizeOf(TEvents), 0);

      {PRZECHODZI DO NASTEPNEGO RODZICA}
      XObj:=XObj^.Next;
    END;
END;

BEGIN
  DeleteChildrenEvents(FirstObj);
END;

{*************************************************************************}

FUNCTION DE_ObjectEvent(Obj:PObject; Event:Byte):Boolean;
BEGIN
  {NA RAZIE NIE MA TAKIEGO ZDARZENIA}
  DE_ObjectEvent:=False;

  {JESLI NIE MA PODANEGO OBIEKTU KONCZY PROCEDURE}
  IF (Obj=NIL) OR (Obj^.Events=NIL) THEN Exit;

  {JESLI ZDARZENIE WYSTAPILO}
  IF Obj^.Events^.Ev[Event] THEN DE_ObjectEvent:=True;
END;

{*************************************************************************}

PROCEDURE DE_ExecuteEvents(Event:PEventsObj);
VAR
     {TYMCZASOWA PAMIEC DO WYKONYWANIA ZDARZEN}
     Temp:PEventsProc;

BEGIN
  IF NOT Assigned(Event) THEN Exit;

  {DO TYMCZASOWEJ ADRES PIERWSZEGO ELEMENTU LISTY}
  Temp:=Event^.FirstProc;

  {DOPLOKI MA W PAMIECI ADRESY PROCEDUR}
  WHILE Assigned(Temp) DO
    BEGIN

      {WYKONYWANIE PROCEDURY}
      IF Event^.Ev[Temp^.EventID] AND Assigned(Temp^.ExecuteProc) THEN
      {WYKONUJE PROcEDURE}
         Temp^.ExecuteProc;

      {PRZECHODZI DO KOLEJNEGO ELEMENTU}
      Temp:=Temp^.Next;
    END;

END;

{*************************************************************************}

PROCEDURE DE_ExecuteKeyBoardEvents(Event:PEventsObj);
VAR
     {TYMCZASOWA PAMIEC DO WYKONYWANIA ZDARZEN}
     Temp:PEventsProc;

BEGIN
  IF NOT Assigned(Event) THEN Exit;

  {DO TYMCZASOWEJ ADRES PIERWSZEGO ELEMENTU LISTY}
  Temp:=Event^.FirstProc;

  {DOPLOKI MA W PAMIECI ADRESY PROCEDUR}
  WHILE Assigned(Temp) DO
    BEGIN

      {SPRAWDZENIE CZY TO BYLA KLAWIATURA I WYKONYWANIE PROCEDURY}
      IF (Temp^.EventID AND 8=8) AND Assigned(Temp^.ExecuteProc) THEN
      {WYKONUJE PROcEDURE}
         Temp^.ExecuteProc;

      {PRZECHODZI DO KOLEJNEGO ELEMENTU}
      Temp:=Temp^.Next;
    END;

END;

{*************************************************************************}

{*************************************************************************
                            INICJALIZACJA
 *************************************************************************}

{*************************************************************************}

BEGIN
  {ZERUJE WSZYSTKIE ZDARZENIA}
  S_FillChar32(@Events, SizeOf(TEventsObj), 0);

  StandardFocus:=NIL;

  {USTAWIA PROCEDURE WYWOLYWANA PRZEZ MODUL KeybX}
  KEYBOARD_EVENT:=DE_GetEventsFromKeyboard;
END.