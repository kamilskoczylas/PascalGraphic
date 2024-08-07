UNIT TYPES;

INTERFACE

TYPE
    PString   = ^STRING;
    PChar     = ^Char;
    String10  = STRING[10];

    PRect     = ^TRect;
    TRect     = RECORD
      X, Y,
      W, H    : Integer;
    END;


    PSprite   = ^TSprite;
    TSprite   = RECORD

      X, Y    : Integer;
      DX, DY  : Integer;
      Klatka  : Byte;

    END;


IMPLEMENTATION
END.