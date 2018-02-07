unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ComCtrls, dateutils, Vcl.Grids, Vcl.Buttons, OptionsUtil, StrU_new;

type
  TForm2 = class(TForm)
    tiMainForm: TTrayIcon;
    pmTrayMenu: TPopupMenu;
    miExit: TMenuItem;
    miStartTimer: TMenuItem;
    tMainCook: TTimer;
    sgTimers: TStringGrid;
    tGridRefresh: TTimer;
    sgTimerVariants: TStringGrid;
    mmMain: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    btnAddTimerVariant: TButton;
    cbPeriod: TComboBox;
    btnSave: TButton;
    procedure miExitClick(Sender: TObject);
    procedure miStartTimerClick(Sender: TObject);
    procedure tMainCookTimer(Sender: TObject);
    procedure tGridRefreshTimer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tiMainFormDblClick(Sender: TObject);
    procedure btnAddTimerVariantClick(Sender: TObject);
    procedure sgTimerVariantsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cbPeriodChange(Sender: TObject);
    procedure cbPeriodExit(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure sgTimerVariantsSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
  private
    isExit: boolean;
    AppOptions: TAppOptions;
    InitialValue: string;
    function StringToSeconds(s: string): integer;
    procedure RefreshMenu();
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

procedure TForm2.btnAddTimerVariantClick(Sender: TObject);
begin
  sgTimerVariants.RowCount := sgTimerVariants.RowCount + 1;
  RefreshMenu;
end;

procedure TForm2.sgTimerVariantsSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  R: TRect;
begin
  InitialValue := sgTimerVariants.Cells[ACol, ARow];

  if ((ACol = 0) and (ARow = 1)) then begin
    R := sgTimerVariants.CellRect(ACol, ARow);
    R.Left := R.Left + sgTimerVariants.Left;
    R.Right := R.Right + sgTimerVariants.Left;
    R.Top := R.Top + sgTimerVariants.Top;
    R.Bottom := R.Bottom + sgTimerVariants.Top;
    cbPeriod.Left := R.Left + 1;
    cbPeriod.Top := R.Top + 1;
    cbPeriod.Width := (R.Right + 1) - R.Left;
    cbPeriod.Height := (R.Bottom + 1) - R.Top;
    {Покажем combobox}
    cbPeriod.Visible := True;
    cbPeriod.SetFocus;
  end;
  CanSelect := true;
end;

procedure TForm2.sgTimerVariantsSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  if InitialValue <> Value then begin
    if ACol = 2 then begin
      StringToSeconds(Value);
    end;
  end;
end;

procedure TForm2.btnSaveClick(Sender: TObject);
var
  i: integer;
begin
  AppOptions.WriteInteger('TimersList', 'Count', sgTimerVariants.RowCount-1);

  for i := 0 to sgTimerVariants.RowCount-1 do begin
    AppOptions.WriteString('TimersList', 'Timer_'+IntToStr(i)+'_Name', sgTimerVariants.Cells[1,i+1]);
    AppOptions.WriteString('TimersList', 'Timer_'+IntToStr(i)+'_Interval', sgTimerVariants.Cells[2,i+1]);
  end;
end;

procedure TForm2.cbPeriodChange(Sender: TObject);
begin
  {Перебросим выбранное в значение из ComboBox в grid}
  sgTimerVariants.Cells[sgTimerVariants.Col, sgTimerVariants.Row] := cbPeriod.Items[cbPeriod.ItemIndex];
  cbPeriod.Visible := False;
  sgTimerVariants.SetFocus;
end;

procedure TForm2.cbPeriodExit(Sender: TObject);
begin
  {Перебросим выбранное в значение из ComboBox в grid}
  sgTimerVariants.Cells[sgTimerVariants.Col, sgTimerVariants.Row] := cbPeriod.Items[cbPeriod.ItemIndex];
  cbPeriod.Visible := False;
  sgTimerVariants.SetFocus;
end;

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

procedure TForm2.FormCreate(Sender: TObject);
var
  i, j: integer;
  s: string;
begin
  AppOptions := TAppOptions.Create(true);

  sgTimerVariants.Cells[1,0] := 'Variant name';
  sgTimerVariants.ColWidths[1] := AppOptions.ReadInteger('TimerVariants', 'ColWidth_1', 250);
  sgTimerVariants.Cells[2,0] := 'Time interval';
  sgTimerVariants.ColWidths[2] := AppOptions.ReadInteger('TimerVariants', 'ColWidth_2', 80);
  sgTimerVariants.Cells[3,0] := 'Message to shown then done';
  sgTimerVariants.ColWidths[3] := AppOptions.ReadInteger('TimerVariants', 'ColWidth_2', 350);

  j := AppOptions.ReadInteger('TimersList', 'Count', 0);
  if j = 0 then
    sgTimerVariants.RowCount := 2
  else
    sgTimerVariants.RowCount := 1+j;

  for i := 0 to j-1 do begin
    sgTimerVariants.Cells[0,i+1] := IntToStr(i);
    s := AppOptions.ReadString('TimersList', 'Timer_'+IntToStr(i)+'_Name', '');
    sgTimerVariants.Cells[1,i+1] := s;
    s := AppOptions.ReadString('TimersList', 'Timer_'+IntToStr(i)+'_Interval', '10s');
    sgTimerVariants.Cells[2,i+1] := s;
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

procedure TForm2.RefreshMenu;
var
  mi: TMenuItem;
  i: integer;
begin
  for i := pmTrayMenu.Items.Count-1 downto 0 do begin
    if Copy(pmTrayMenu.Items[i].Name, 1, 9) = 'TimerItem' then begin
      pmTrayMenu.Items[i].Free;
//      pmTrayMenu.Items.Delete(i);
    end;
  end;


  for i := sgTimerVariants.RowCount-1 downto 1 do begin
    mi := TMenuItem.Create(self);
    mi.Caption := sgTimerVariants.Cells[1, i];
    mi.Name := 'TimerItem'+IntToStr(i);
    pmTrayMenu.Items.Insert(0, mi);
  end;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin
  //
end;

function TForm2.StringToSeconds(s: string): integer;
var
  ea: TExplodeArray;
  i, j, v: Integer;
  vs, pr: string;
begin
  Result := 0;

  ea := Explode(' ', s);

  for i := 0 to length(ea)-1 do begin
    if Trim(ea[i]) = '' then
      Continue;

    j := 0;
    while (ea[i][j+1] >= '0') and (ea[i][j+1] <= '9') do
      inc(j);
    vs := Copy(ea[i], 1, j);
    v := StrToInt(vs);
    pr := Copy(ea[i], j+1, 10);

    if pr <> '' then begin
      case pr[1] of
        'm': v := v * 60;
        'h': v := v * 60*60;
        'd': v := v * 60*60*24;
      end;
    end;
    Result := Result + v;
  end;

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

procedure TForm2.tiMainFormDblClick(Sender: TObject);
begin
  Show;
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
