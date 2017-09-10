program PRealHoliday_XE3;

uses
  Forms,
  URealHoliday in 'URealHoliday.pas' {FMain};

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.HintColor:=$00FFF9EC;
  Application.HintPause:=100;
  Application.HintHidePause:=3000;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
