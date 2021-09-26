program PRealHoliday_XE3;

uses
  Forms,
  Windows,
  URealHoliday in 'URealHoliday.pas' {FMain};

var xHand: THandle;
var wnd: THandle;

{$R *.res}

begin
  xHand := CreateMutex(nil, True, 'REAL_HOLIDAY_ALREADY_EXISTS');
  if (GetLastError = ERROR_ALREADY_EXISTS)or(GetLastError = ERROR_ACCESS_DENIED) then
  begin
    wnd := FindWindow('TFMain',nil);
    if wnd<>0 then
    begin
      //при этом первая копия будет выведена на передний план
      SendMessage(wnd,WM_GOTOFOREGROUND,0,0);
    end;

    Application.Terminate;
    Exit;
  end;

  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.HintColor:=$00FFF9EC;
  Application.HintPause:=100;
  Application.HintHidePause:=3000;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
