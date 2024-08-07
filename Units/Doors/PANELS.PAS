{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                     MODUL :  DOORS                                    *}
{*                   AUTORZY :  S.K. K.S.                                *}
{*                                                                       *}
{*                                                                       *}
{*     Wszelkie prawa autorskie zastrzezone, wykorzystywanie modulu      *}
{*     tylko za zgoda autorow, kontakt:                                  *}
{*                                                                       *}
{*     Modul jest czescia systemu Doors, zawiera obsluge Panelow         *}
{*                                                                       *}
{*                                                                       *}
{*     KamilSkoczylas@o2.pl                                              *}
{*                                                                       *}
{*************************************************************************}

UNIT Panels;

INTERFACE

{*************************************************************************}

USES
      Doors, Graph10E, Fonts, Standard, Errors;



TYPE

{*************************************************************************}

      {SZCZEGOLOWE PARAMETRY IKONY}
      PPanelParams   = ^TPanelParams;
      TPanelParams   = OBJECT

        {STYL Panel'a}
        Style       : Byte;

      END;


{*************************************************************************}
FUNCTION D_CreatePanel(Obj:PObject):Byte;
FUNCTION D_FreePanel(Obj:PObject):Byte;FAR;
PROCEDURE D10_DrawPanel(Buf:TEkran10Eh; Obj:PObject);FAR;

{*************************************************************************}

IMPLEMENTATION

USES Doors10E,        {PODSTAWOWE PROCEDURY RYSUJACE}
     Doors_Ev;


{*************************************************************************}
FUNCTION D_CreatePanel(Obj:PObject):Byte;
{*************************************************************************
 Tworzy z dowolnego obiektu przycisk i podstawia ustawienia domyslne
 *************************************************************************}
VAR Temp:PPanelParams;

BEGIN
     D_CreatePanel:=E_OK;

     IF MaxAvail<SizeOf(TPanelParams)+SizeOf(TPoz) THEN
       BEGIN
         D_CreatePanel:=E_PAMIEC;
         D_DeleteObject(Obj);
         Obj:=NIL;
         Exit;
       END;

     GetMem(Obj^.Params, SizeOf(TPanelParams));
     New(Obj^.Pos);

     WITH Obj^ DO
     BEGIN
       Pos^.X:=0;
       Pos^.Y:=0;
       Pos^.Width:=40;
       Pos^.Height:=10;

       Temp:=Params;


       Temp^.Style:=0;
       TypID:=DOORS_Panel;

     END;

END;

{*************************************************************************}
FUNCTION D_FreePanel(Obj:PObject):Byte;

VAR But:PPanelParams;
BEGIN
     D_FreePanel:=E_OK;

     IF (Obj=NIL) OR (Obj^.Params=NIL) OR (Obj^.TypID<>DOORS_Panel) THEN BEGIN D_FreePanel:=E_OBIEKT;Exit;END;

     But:=Obj^.Params;

     FreeMem(Obj^.Params, SizeOf(TPanelParams));
     Obj^.Params:=NIL;
     Dispose(Obj^.Pos);
     Obj^.Pos:=NIL;
END;


{*************************************************************************}
PROCEDURE D10_DrawPanel(Buf:TEkran10Eh; Obj:PObject);

VAR XPanel : PPanelParams;
    a      : Integer;

BEGIN
  XPanel:=Obj^.Params;
  D10_DrawBorder(Buf, XPanel^.Style, 0);
END;


{*************************************************************************}

BEGIN
  {WSTAWIA DO TABLICY PROCEDURE RYSUJACA TEN OBIEKT}
  DrawProc[DOORS_Panel]:=D10_DrawPanel;

  {PROCEDURA WYWOLYWANA AUTOMATYCZNIE PRZY ZMIANIE ROZMIARU TEGO OBIEKTU}
  ResizeProc[DOORS_Panel]:=NIL;

  {FUNKCJA ZWALNIAJACA PAMIEC}
  FreeFunc[DOORS_Panel]:=D_FreePanel;
END.
