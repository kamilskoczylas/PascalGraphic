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

PROGRAM PRACA;

{***********************************************************************}

USES
      D_Menu;      {PROJEKT WSZYSTKICH MENU, TWORZONE PRZYCISKI}



BEGIN

  {SPRAWDZA CZY KOMPUTER SPELNIA WSZYSTKIE WYMAGANIA}
  CheckErrors;

  {WCZYTUJE I WYSWIETLA MENU Z WYBOREM JEZYKA}
  Menu;

  {URUCHAMIA TRYB WINDOWSOWY}
  StartDoors;

  {FINALIZACJA, ZWALNIANIE PAMIECI}
  FreeMemory;

END.