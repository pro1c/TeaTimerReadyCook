program TeaTimerReadyCook;

uses
  Vcl.Forms,
  main in 'main.pas' {Form2},
  OptionsUtil in '..\..\RFQUtils\OptionsUtil.pas',
  StrU_new in '..\..\RFQUtils\StrU_new.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
