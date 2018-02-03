unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ComCtrls, dateutils, Vcl.Grids, Vcl.Buttons;

type
  TForm2 = class(TForm)
    tiMainForm: TTrayIcon;
    pmMainMenu: TPopupMenu;
    miExit: TMenuItem;
    miStartTimer: TMenuItem;
    tMainCook: TTimer;
    sgTimers: TStringGrid;
    tGridRefresh: TTimer;
    StringGrid1: TStringGrid;
    mmMain: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    btnAddTimerVariant: TButton;
    procedure miExitClick(Sender: TObject);
    procedure miStartTimerClick(Sender: TObject);
    procedure tMainCookTimer(Sender: TObject);
    procedure tGridRefreshTimer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
  private
    isExit: boolean;
  public
    { Public declarations }
  end;

  TTimerRec = record
    startTime: TDateTime;
    stopTime: TDateTime;
    messagePopup: string;
    enabled: boolean;
  end;

var
  Form2: TForm2;

  allTimers: array of TTimerRec;

implementation

{$R *.dfm}

procedure TForm2.Exit1Click(Sender: TObject);
begin
  isExit := true;
  Close;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not isExit then begin
    Action := caNone;
    Hide;
  end;
end;

procedure TForm2.miExitClick(Sender: TObject);
begin
  isExit := true;
  Close;
end;

procedure TForm2.miStartTimerClick(Sender: TObject);
var
  i: integer;
begin
  tMainCook.Enabled := false;
  tMainCook.Interval := 1000;
  tMainCook.Enabled := true;

  i := Length(allTimers);
  SetLength(allTimers, i+1);
  allTimers[i].startTime := Now;
//  allTimers[i].stopTime := dateutils.IncMinute(allTimers[i].startTime, StrToInt(eMainTimerValue.Text));
//  allTimers[i].messagePopup := 'TeaTime started at '+DateTimeToStr(allTimers[i].startTime)+' for '+eMainTimerValue.Text+' mins is done';
  allTimers[i].enabled := true;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin
  //
end;

procedure TForm2.tGridRefreshTimer(Sender: TObject);
var
  i: Integer;
begin
  sgTimers.RowCount := length(allTimers)+1;
  if sgTimers.RowCount > 1 then
    sgTimers.FixedRows := 1;
  sgTimers.Cells[1, 0] := 'Start';
  sgTimers.ColWidths[1] := 120;
  sgTimers.Cells[2, 0] := 'Stop';
  sgTimers.ColWidths[2] := 120;
  sgTimers.Cells[3, 0] := 'Message';
  sgTimers.ColWidths[3] := 250;

  for i := 0 to length(allTimers)-1 do begin
    sgTimers.Cells[0, i+1] := BoolToStr(allTimers[i].enabled, true);
    sgTimers.Cells[1, i+1] := DateTimeToStr(allTimers[i].startTime);
    sgTimers.Cells[2, i+1] := DateTimeToStr(allTimers[i].stopTime);
    sgTimers.Cells[3, i+1] := allTimers[i].messagePopup;
  end;
end;

procedure TForm2.tMainCookTimer(Sender: TObject);
var
  i: integer;
  minInterval: integer;
  n: TDateTime;
begin
  tMainCook.Enabled := false;

  minInterval := 1000 * 60 * 60;

  n := now;

  for i := 0 to length(allTimers)-1 do begin
    if not allTimers[i].enabled then
      Continue;

    if minInterval > -1 * MilliSecondsBetween(n, allTimers[i].stopTime) * dateutils.CompareDateTime(n, allTimers[i].stopTime) then
      minInterval := -1 * MilliSecondsBetween(n, allTimers[i].stopTime) * dateutils.CompareDateTime(n, allTimers[i].stopTime);
  end;

  if minInterval < 1000 then
    minInterval := 1000;

  for i := 0 to length(allTimers)-1 do begin
    if not allTimers[i].enabled then
      Continue;

    if -1 * MilliSecondsBetween(n, allTimers[i].stopTime) * dateutils.CompareDateTime(n, allTimers[i].stopTime) < 1000 then begin
      allTimers[i].enabled := false;
      tiMainForm.BalloonTitle := 'Tea timer';
      tiMainForm.BalloonHint := allTimers[i].messagePopup;
      tiMainForm.BalloonTimeout := 100000;
      tiMainForm.ShowBalloonHint;
    end;
  end;

  tMainCook.Interval := minInterval div 3;
  tMainCook.Enabled := true;

end;

end.
