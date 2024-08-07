unit MMX;

interface


procedure MMX_FillChar(Buf : Pointer; Count : Word; Value : Byte); far;
procedure MMX_Move(Dest, Src : Pointer; Count : Word); far;
procedure MMX_ClrScr(ModeSize : LongInt); far;
procedure MMX_FillScr(ModeSize : LongInt; Color : Byte); far;

implementation


procedure MMX_FillChar(Buf : Pointer; Count : Word; Value : Byte); external;
{$L FillChar.obj}

procedure MMX_Move(Dest, Src : Pointer; Count : Word); external;
{$L Move.obj}

procedure MMX_ClrScr(ModeSize : LongInt); external;
{$L ClrScr.obj}

procedure MMX_FillScr(ModeSize : LongInt; Color : Byte); external;
{$L FillScr.obj}

end.