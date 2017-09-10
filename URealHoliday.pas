unit URealHoliday;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, DateUtils, Grids, Buttons,
  Mask, registry,ShellApi, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.Imaging.jpeg;

type
  TFMain = class(TForm)
    PC: TPageControl;
    TS1: TTabSheet;
    PBottom: TPanel;
    PMain: TPanel;
    BOkMain: TBitBtn;
    REmain: TRichEdit;
    TrayIcon1: TTrayIcon;
    ApplicationEvents1: TApplicationEvents;
    IExit: TImage;
    LLink: TLabel;
    PBut: TPanel;
    I1: TImage;
    BBInc: TBitBtn;
    BBDec: TBitBtn;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BBIncClick(Sender: TObject);
    procedure BBDecClick(Sender: TObject);
    procedure SetIndents(Size:byte);
    procedure REmainEnter(Sender: TObject);
    procedure PButMouseEnter(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
    procedure ApplicationEvents1Activate(Sender: TObject);
    procedure IExitMouseEnter(Sender: TObject);
    procedure IExitMouseLeave(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure REmainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BOkMainClick(Sender: TObject);
    procedure REmainMouseEnter(Sender: TObject);
    procedure LLinkClick(Sender: TObject);
    procedure LLinkMouseEnter(Sender: TObject);
    procedure PBottomMouseEnter(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }
  end;


    Type trec=Record
    data:string;
    text:string;
    age:byte;
    End;

const DelayConst=10;

var
  FMain: TFMain;
  rec:array of trec; //������ � ����� ��������
  i:word;
  num:word;
  FontSize:byte;
  Reg:TRegistry;
  implementation

{$R *.dfm}

procedure TFMain.SetIndents(size:byte);
var
 S, L: Integer;
begin

 S := REMain.SelStart;
 L := REMain.SelLength;
 REMain.Lines.BeginUpdate;
 REMain.SelectAll;
// REMain.Paragraph.LeftIndent := size;
 REMain.Paragraph.FirstIndent := size;
 REMain.Paragraph.RightIndent := size;
 REMain.SelStart := S;
 REMain.SelLength := L;
 REMain.Lines.EndUpdate;
end;


procedure TFMain.TrayIcon1Click(Sender: TObject);
begin
FMain.Show;
end;

Procedure LoadHoliday; //��������� ��� �������� �� ����� � ������
var
tempStr:string;
fOption:textfile; //���� � ����� ��������
fn:string; //��� ����� � �����������
dat:string;

  function AgeAdd(Age:string):string;
  var LastNum:string;
  begin
    if length(Age)>1 then begin
      LastNum:=copy(Age,Length(Age)-1,2);
      if (StrToInt(Age)>10)and(StrToInt(Age)<20) then result:='���' else
      if LastNum[2]='1' then result:='���' else
      if Pos(LastNum[2],'234')<>0 then result:='����' else
      if Pos(LastNum[2],'567890')<>0 then result:='���';
      exit;
    end;
    LastNum:=copy(Age,Length(Age),1);
    if LastNum='1' then result:='���' else
    if Pos(LastNum,'234')<>0 then result:='����' else
    if Pos(LastNum,'567890')<>0 then result:='���';
  end;

  function TextWithAge(txt:string):string;
  var StrYear:string;
      Year,Age,NowYear:integer;
  begin
    result:=txt;
    NowYear:=StrToInt(FormatDateTime('yyyy',now));
    StrYear:=copy(txt,Length(txt)-3,4);
    if TryStrToInt(StrYear,Year)=false then exit;
    if (Year<1)or(Year>NowYear) then exit;
    Age:=NowYear-Year;
    result:=result+' �. '+#13#10+'::: '+IntToStr(Age)+' '+AgeAdd(IntToStr(Age))+' :::';
  end;

  procedure LoadFromFile(FileName:string);
  var
    fHoliday:textfile; //���� � ������ ������ ��������
  begin
  assignfile(fHoliday,FileName);
  reset(fHoliday);
  while not EOF(fHoliday) do begin

  readln(fHoliday,tempStr);

  if tempStr[1]='#' then  Continue;

  dat:=copy(tempStr,1,5);
  //����� �������� �� ���� ����������� ����

  if
  (dat=FormatDateTime('dd.mm',now)) or
  (dat=FormatDateTime('dd.mm',IncDay(now,1))) or
  (dat=FormatDateTime('dd.mm',IncDay(now,2))) or
  (dat=FormatDateTime('dd.mm',IncDay(now,3))) or
  (dat=FormatDateTime('dd.mm',IncDay(now,4))) or
  (dat=FormatDateTime('dd.mm',IncDay(now,5))) or
  (dat=FormatDateTime('dd.mm',IncDay(now,6))) or
  (dat=FormatDateTime('dd.mm',IncDay(now,7))) then begin
    num:=num+1;
    SetLength(rec,num);
    rec[num-1].data:=dat;
    rec[num-1].text:=UTF8ToUnicodeString(copy(tempStr,7,Length(tempStr)-6));
    rec[num-1].text:=TextWithAge(rec[num-1].text);
  end;

  end;
  CloseFile(fHoliday);
  end;

begin

num:=1;
SetLength(rec,num);
rec[0].data:='27.08';
rec[0].text:='������ ������ - ����������� ���� ��������� 1985 �.';

//���� ���� � ������� ����������, �� ��������� �� ���� ���� � ����� � �������
if FileExists('option.ini') then begin
Assignfile(fOption,'option.ini');
Reset(fOption);

While not EOF(fOption) do begin
Readln(fOption,fn);

//���� ����� ���� ����������, �� ��������� �� ���� ��� ��� ��� �����
if fn[1]='#' then  Continue;
fn:=UTF8ToUnicodeString(fn);
if FileExists(fn) then LoadFromFile(fn)
else MessageDlg('���� '+fn+' �� ������! ',mtInformation, [mbOk],0);

//���� ����� � ������� ���, �� �������, ���� �� ���� Holiday.txt
end; //while
CloseFile(fOption);
end //options

else if fileexists('Holiday.txt') then LoadFromFile('Holiday.txt')
else MessageDlg('���� Holiday.txt �� ������! ',mtInformation, [mbOk],0);


end;

procedure Delay(dwMilliseconds: Longint);
var
   iStart, iStop: DWORD;
 begin
   iStart := GetTickCount;
   repeat
     iStop := GetTickCount;
     Application.ProcessMessages;
   until (iStop - iStart) >= dwMilliseconds;
end;


function MonthName(month:string):string;
var nummonth:byte;
begin
nummonth:=strtoint(month);
  case nummonth of
    1:result:='������';
    2:result:='�������';
    3:result:='�����';
    4:result:='������';
    5:result:='���';
    6:result:='����';
    7:result:='����';
    8:result:='�������';
    9:result:='��������';
    10:result:='�������';
    11:result:='������';
    12:result:='�������';
  end;
end;

function WeekDayName(WeekDay:string):string;
begin
  //Result:=WeekDay;
  if WeekDay='�����������' then Result:='� ����������� ' else
  if WeekDay='�������' then Result:='�� ������� ' else
  if WeekDay='�����' then Result:='� ����� ' else
  if WeekDay='�������' then Result:='� ������� ' else
  if WeekDay='�������' then Result:='� ������� ' else
  if WeekDay='�������' then Result:='� ������� ' else
  if WeekDay='�����������' then Result:='� ����������� ';
end;

Procedure OutputHoliday; //����� ���� �������� � ��� ���� �� 7 ����
var
a:array [0..7] of boolean; //��� ������ + 1
i:word; //��� ������
tmpStr:string;

procedure OutRecordText;
begin
FMain.REmain.SelAttributes.Color:=$002F2922;
FMain.REmain.SelAttributes.Style:=[];    //fsunderline
FMain.REmain.Lines.Add(rec[i].text);
FMain.REmain.SelAttributes.Color:=$00B37800;//$00462300;//
FMain.REmain.SelAttributes.Style:=[];
FMain.REmain.Lines.Add('***');
end;

procedure DelLastStar;
begin
if FMain.REmain.Lines[FMain.REmain.Lines.Count-1]='***' then begin
FMain.REmain.Lines.Delete(FMain.REmain.Lines.Count-1);
FMain.REmain.Lines.Add(' ');
end;
end;

function DelZero(DataStr:string):string;
begin
if DataStr[1]='0' then Result:=Copy(DataStr,2,Length(DataStr)-1)
else Result:=DataStr;
end;

begin

for i:=0 to 7 do a[i]:=false;

FMain.REMain.SelStart:=0;
FMain.REMain.Font.Size:=FontSize;

//������ ������ �� �����
FMain.REmain.SelAttributes.Size:=4;
FMain.REMain.Lines.Add('');

//�������
tmpStr:=FormatDateTime('dd.mm',now);
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[0]=false then begin
FMain.REmain.SelAttributes.Color:=clRed;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add('�������');
FMain.REmain.Lines.Add('');
a[0]:=true;
end;
OutRecordText;
end;
end;

//������
tmpStr:=FormatDateTime('dd.mm',IncDay(now,1));
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[1]=false then begin
DelLastStar;
FMain.REmain.SelAttributes.Color:=$00BF0000;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add('������');
FMain.REmain.Lines.Add('');
a[1]:=true;
end;
OutRecordText;
end;
end;


//����� 2 ���
tmpStr:=FormatDateTime('dd.mm',IncDay(now,2));
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[2]=false then begin
DelLastStar;
FMain.REmain.SelAttributes.Color:=$00462300;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add(WeekDayName(FormatDateTime('dddd',IncDay(now,2)))+DelZero(FormatDateTime('dd ',IncDay(now,2)))+Monthname(FormatDateTime('mm',IncDay(now,2)))+', ����� 2 ���');
FMain.REmain.Lines.Add('');
a[2]:=true;
end;
OutRecordText;
end;
end;

//����� 3 ���
tmpStr:=FormatDateTime('dd.mm',IncDay(now,3));
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[3]=false then begin
DelLastStar;
FMain.REmain.SelAttributes.Color:=$00462300;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add(WeekDayName(FormatDateTime('dddd',IncDay(now,3)))+DelZero(FormatDateTime('dd ',IncDay(now,3)))+Monthname(FormatDateTime('mm',IncDay(now,3)))+', ����� 3 ���');
FMain.REmain.Lines.Add('');
a[3]:=true;
end;
OutRecordText;
end;
end;


//����� 4 ���
tmpStr:=FormatDateTime('dd.mm',IncDay(now,4));
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[4]=false then begin
DelLastStar;
FMain.REmain.SelAttributes.Color:=$00462300;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add(WeekDayName(FormatDateTime('dddd',IncDay(now,4)))+DelZero(FormatDateTime('dd ',IncDay(now,4)))+Monthname(FormatDateTime('mm',IncDay(now,4)))+', ����� 4 ���');
FMain.REmain.Lines.Add('');
a[4]:=true;
end;
OutRecordText;
end;
end;


//����� 5 ����
tmpStr:=FormatDateTime('dd.mm',IncDay(now,5));
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[5]=false then begin
DelLastStar;
FMain.REmain.SelAttributes.Color:=$00462300;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add(WeekDayName(FormatDateTime('dddd',IncDay(now,5)))+DelZero(FormatDateTime('dd ',IncDay(now,5)))+Monthname(FormatDateTime('mm',IncDay(now,5)))+', ����� 5 ����');
FMain.REmain.Lines.Add('');
a[5]:=true;
end;
OutRecordText;
end;
end;


//����� 6 ����
tmpStr:=FormatDateTime('dd.mm',IncDay(now,6));
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[6]=false then begin
DelLastStar;
FMain.REmain.SelAttributes.Color:=$00462300;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add(WeekDayName(FormatDateTime('dddd',IncDay(now,6)))+DelZero(FormatDateTime('dd ',IncDay(now,6)))+Monthname(FormatDateTime('mm',IncDay(now,6)))+', ����� 6 ����');
FMain.REmain.Lines.Add('');
a[6]:=true;
end;
OutRecordText;
end;
end;

//����� ������
tmpStr:=FormatDateTime('dd.mm',IncDay(now,7));
for i := 0 to length(rec)-1 do begin
if tmpStr=rec[i].data then begin
if a[7]=false then begin
DelLastStar;
FMain.REmain.SelAttributes.Color:=$00462300;
FMain.REmain.SelAttributes.Style:=[fsBold, fsUnderLine];
FMain.REmain.Lines.Add(WeekDayName(FormatDateTime('dddd',IncDay(now,7)))+DelZero(FormatDateTime('dd ',IncDay(now,7)))+Monthname(FormatDateTime('mm',IncDay(now,7)))+', ����� ������');
FMain.REmain.Lines.Add('');
a[7]:=true;
end;
OutRecordText;
end;
end;

if  FMain.REMain.Lines.Count>1 then FMain.REMain.Lines.Delete(FMain.REMain.Lines.Count-1);
if  FMain.REMain.Lines.Count=0 then begin
FMain.REmain.SelAttributes.Color:=$00B37800;
FMain.REMain.Lines.Add('��� �������');
end;

{FMain.REmain.Lines.Add('');
FMain.REmain.SelAttributes.Color:=$00DDD9EC;
FMain.REmain.SelAttributes.Style:=[fsBold];
FMain.REmain.Lines.Add('RealHoliday.ru');
FMain.REmain.Lines.Add('Created by Simkin Andrew'); }

end;

procedure TFMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//����� ������� ��������� ������� ��������� ���� � �����
Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\Software\RealHoliday\Options', true);
    Reg.WriteInteger('Left',FMain.Left);
    Reg.WriteInteger('Top',FMain.Top);
    Reg.WriteInteger('Width',FMain.Width);
    Reg.WriteInteger('Height',FMain.Height);
    Reg.WriteInteger('FontSize',FontSize);
    Reg.CloseKey;
    Reg.Free;

CanClose:=true;
end;

Procedure TFMain.FormCreate(Sender: TObject);
begin
//������� � ��������� ����������� ���� � ���� ������
FMain.Caption:='�������: '+FormatDateTime('dddd ',now)+FormatDateTime('dd ',Date)+monthname(FormatDateTime('mm',now));
FMain.LLink.Caption:='RealAdmin.ru'+#13#10+'RealHoliday v2.1';
FontSize:=16;
//���� ���� � ���. ������� ����, �� ��������� �� ���� ����������
Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
if Reg.KeyExists('\Software\RealHoliday\Options') then begin
    Reg.OpenKey('\Software\RealHoliday\Options', true);
    FMain.Left:=Reg.ReadInteger('Left');
    FMain.Top:=Reg.ReadInteger('Top');
    FMain.Width:=Reg.ReadInteger('Width');
    FMain.Height:=Reg.ReadInteger('Height');
    FontSize:=Reg.ReadInteger('FontSize');
    Reg.CloseKey;
    FMain.Position:=poDesigned; //��������� �������� �����
end;
    Reg.Free;

LoadHoliday; //��������� ������ ���� ��������
OutputHoliday;  //������� �� ����� ������
//SetIndents(20);  //������ ������� � REMain �� �����
end;

procedure TFMain.FormMouseLeave(Sender: TObject);
var i:byte;
begin
PBut.Left:=-33;
{if (Pbut.Left=-3) then
for i:=1 to 30 do begin
PBut.Left:=PBut.Left-1;
delay(DelayConst);
end;}
end;

Procedure TFMain.FormResize(Sender: TObject);
begin
SetIndents(round(sqr(FMain.Width/150)));  //������ ������� � REMain �� �����
if FMain.ClientWidth<425 then LLink.Hide else LLink.show;
REMain.Repaint;
end;

procedure TFMain.IExitMouseEnter(Sender: TObject);
begin
//IExit.Picture.LoadFromFile('2.jpg');
end;

procedure TFMain.IExitMouseLeave(Sender: TObject);
begin
//IExit.Picture.LoadFromFile('1.jpg');
end;

procedure TFMain.LLinkClick(Sender: TObject);
begin
ShellExecute(Handle,'open','http://realadmin.ru',nil,nil,SW_ShowNormal);
end;

procedure TFMain.LLinkMouseEnter(Sender: TObject);
begin
LLink.Font.Color:=$00FF870F;
end;

procedure TFMain.BBIncClick(Sender: TObject);
begin

if (REMain.SelAttributes.Size<30) then begin
REMain.SelStart:=1;
REMain.SelLength:=length(remain.text)-1;
FontSize:=FontSize+2;
REMain.SelAttributes.Size:=FontSize;
end;

end;

procedure TFMain.BOkMainClick(Sender: TObject);
begin
close;
end;

procedure TFMain.ApplicationEvents1Activate(Sender: TObject);
var i:word;
begin
FMain.AlphaBlend:=false;
{FMain.AlphaBlendValue:=200;
for i:=1 to 55 do begin
FMain.AlphaBlendValue:=FMain.AlphaBlendValue+1;
delay(DelayConst);
end;}

end;

procedure TFMain.ApplicationEvents1Deactivate(Sender: TObject);
var i:word;
begin
PBut.Left:=-33;
LLink.Font.Color:=$00FFC68C;
FMain.AlphaBlend:=true;

{FMain.AlphaBlendValue:=255;
for i:=1 to 55 do begin
FMain.AlphaBlendValue:=FMain.AlphaBlendValue-1;
delay(DelayConst);
end;}

end;

procedure TFMain.BBDecClick(Sender: TObject);
begin
if (REMain.SelAttributes.Size>8) then begin
REMain.SelStart:=1;
REMain.SelLength:=length(remain.text)-1;
FontSize:=FontSize-2;
REMain.SelAttributes.Size:=FontSize;
end;
end;

procedure TFMain.PBottomMouseEnter(Sender: TObject);
begin
LLink.Font.Color:=$00FFC68C;
end;

procedure TFMain.PButMouseEnter(Sender: TObject);
var i:byte;
begin
PBut.Left:=-3;
LLink.Font.Color:=$00FFC68C;
{if Pbut.Left=-33 then
for i:=1 to 30 do begin
PBut.Left:=PBut.Left+1;
delay(DelayConst);
end;}

end;

procedure TFMain.REmainEnter(Sender: TObject);
begin
FMain.SelectNext(Self,true,true);
end;

procedure TFMain.REmainMouseEnter(Sender: TObject);
begin
PBut.Left:=-33;
end;

procedure TFMain.REmainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i:byte;
begin

{if Pbut.Left=-3 then
for i:=1 to 30 do begin
PBut.Left:=PBut.Left-1;
delay(DelayConst);
end;}
end;

end.
