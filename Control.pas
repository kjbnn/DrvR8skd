unit Control;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, ComCtrls, Grids, Menus, Mask, ToolEdit, cMainKsb;

type
  TRbControl = class(TaMainKsb)
    RadioGroup1: TRadioGroup;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Edit1: TEdit;
    Label6: TLabel;
    Label2: TLabel;
    SpinEdit7: TSpinEdit;
    Label1: TLabel;
    Button8: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    TabSheet4: TTabSheet;
    Button24: TButton;
    Button1: TButton;
    Button25: TButton;
    TabSheet5: TTabSheet;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    RadioGroup2: TRadioGroup;
    SpinEdit1: TSpinEdit;
    Label4: TLabel;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    Edit2: TEdit;
    Button23: TButton;
    Button2: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    SpinEdit2: TSpinEdit;
    Label5: TLabel;
    CheckBox1: TCheckBox;
    Button4: TButton;
    Button9: TButton;
    Button10: TButton;
    ComboBox3: TComboBox;
    SpinEdit3: TSpinEdit;
    Label7: TLabel;
    CheckBox2: TCheckBox;
    Button11: TButton;
    Label8: TLabel;
    Label3: TLabel;
    ComboBox2: TComboBox;
    Button17: TButton;
    Edit3: TEdit;
    Button18: TButton;
    Edit4: TEdit;
    Label9: TLabel;
    Button19: TButton;
    Label10: TLabel;
    Edit5: TEdit;
    Label11: TLabel;
    Edit6: TEdit;
    SpinEdit6: TSpinEdit;
    Label15: TLabel;
    Panel2: TPanel;
    ComboBox4: TComboBox;
    SpinEdit4: TSpinEdit;
    Label13: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    SpinEdit5: TSpinEdit;
    Button20: TButton;
    Label16: TLabel;
    Edit7: TEdit;
    Button21: TButton;
    Button22: TButton;
    Button28: TButton;
    TabSheet6: TTabSheet;
    ListBox1: TListBox;
    Button29: TButton;
    SpinEdit8: TSpinEdit;
    SpinEdit9: TSpinEdit;
    Label17: TLabel;
    Label18: TLabel;
    StringGrid1: TStringGrid;
    TimerRefrehGrid: TTimer;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Button30: TButton;
    CheckBox5: TCheckBox;
    Label19: TLabel;
    ComboBox5: TComboBox;
    TabSheet7: TTabSheet;
    Button31: TButton;
    Button32: TButton;
    Button33: TButton;
    CheckBox6: TCheckBox;
    Edit8: TEdit;
    SpinEdit10: TSpinEdit;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    SpinEdit12: TSpinEdit;
    Label24: TLabel;
    SpinEdit13: TSpinEdit;
    Label25: TLabel;
    SpinEdit14: TSpinEdit;
    Label26: TLabel;
    DateEdit1: TDateEdit;
    Button27: TButton;
    Label20: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Edit9: TEdit;
    Button34: TButton;
    TabSheet8: TTabSheet;
    Button26: TButton;
    Button35: TButton;
    Button36: TButton;
    Button37: TButton;
    StringGrid2: TStringGrid;
    GroupBox2: TGroupBox;
    Label29: TLabel;
    SpinEdit11: TSpinEdit;
    CheckBox7: TCheckBox;
    Label30: TLabel;
    SpinEdit15: TSpinEdit;
    procedure Button23Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure TimerRefrehGridTimer(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button33Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button34Click(Sender: TObject);
  private
  public
  end;

var
  RbControl: TRbControl;

implementation

uses Scanner, R8Unit, SharedBuffer, constants, connection;
{$R *.DFM}

//-----------------------------------------------------------------------------
procedure TRbControl.FormCreate(Sender: TObject);
var
 i:word;

begin
 ComboBox3.ItemIndex:=0;
 ComboBox4.ItemIndex:=0;
 ComboBox5.ItemIndex:=0; 
 ListBox1.ItemIndex:=0;

 StringGrid1.ColWidths[0]:=30;
 for i:=0 to 103 do StringGrid1.Cells[0, i+1]:=inttostr(i*10);
 for i:=0 to 9 do StringGrid1.Cells[i+1, 0]:=inttostr(i);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button23Click(Sender: TObject);
var
 buf : array[0..1000]of byte;
 i, n : integer;
 st : string;

begin
 st:=ComboBox1.Text;
 n:=Length(st);
 i:=0;
 while i<n do
  begin
   buf[i div 3]:= strtoint('$'+st[i+1]+st[i+2]);
   inc(i,3);
  end;

 n:=n div 3;
 buf[n+1]:=hi (kc(buf,n));
 buf[n]:=lo (kc(buf,n));
 Edit2.Text:=inttohex(kc(buf,n),2);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button5Click(Sender: TObject);
begin
//
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button6Click(Sender: TObject);
begin
//
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button7Click(Sender: TObject);
begin
//
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button24Click(Sender: TObject);
begin
 mGetVer(RadioGroup1.ItemIndex);
end;


//-----------------------------------------------------------------------------
procedure TRbControl.Button19Click(Sender: TObject);
begin
 mGetClock(RadioGroup1.ItemIndex);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button1Click(Sender: TObject);
const
 seconds_in_min=60;
 seconds_in_hour=3600;
 seconds_in_day=86400;
 seconds_in_year=31536000;
 FirstDayOfEachMonth : array [1..12] of word = (1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
 FirstDayOfEachMonthInLeapYear : array [1..12] of word = (1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336);

var
 year, month, d : word;
 h, m, Sec, MSec: word;
 total : longword;

begin
 DecodeTime(now, h, m, Sec, MSec);
 DecodeDate(now, year, month, d);
 total:=0;
 if year<2000 then exit;

 if year>2000 then total:=(year-2000)*seconds_in_year + (((year-2001) div 4)+1)*seconds_in_day;
 if IsLeapYear(year) then
  total:=total+(FirstDayOfEachMonthInLeapYear[month]-1)*seconds_in_day
  else
   total:=total+(FirstDayOfEachMonth[month]-1)*seconds_in_day;
 total:=total + (d-1)*seconds_in_day + h*seconds_in_hour + m*seconds_in_min + sec ;
 mSetClock(RadioGroup1.ItemIndex, total);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button25Click(Sender: TObject);
begin
 mGetWordBZP(RadioGroup1.ItemIndex);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button4Click(Sender: TObject);
begin
 mGetLisences(RadioGroup1.ItemIndex);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button8Click(Sender: TObject);
var
 m:array [0..3] of byte;
begin
 m[0]:=strtoint('$'+Edit1.Text[1]+Edit1.Text[2]);
 m[1]:=strtoint('$'+Edit1.Text[3]+Edit1.Text[4]);
 m[2]:=strtoint('$'+Edit1.Text[5]+Edit1.Text[6]);
 m[3]:=strtoint('$'+Edit1.Text[7]+Edit1.Text[8]);
 mCreateChangeZone(RadioGroup1.ItemIndex, m, 4*RadioGroup2.ItemIndex+3, SpinEdit1.Value, 0, 0);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button34Click(Sender: TObject);
var
 m:array [0..3] of byte;
begin
 m[0]:=strtoint('$'+Edit1.Text[1]+Edit1.Text[2]);
 m[1]:=strtoint('$'+Edit1.Text[3]+Edit1.Text[4]);
 m[2]:=strtoint('$'+Edit1.Text[5]+Edit1.Text[6]);
 m[3]:=strtoint('$'+Edit1.Text[7]+Edit1.Text[8]);
 mCreateChangeZone(RadioGroup1.ItemIndex, m, 4*RadioGroup2.ItemIndex+3, SpinEdit1.Value, 0, 1);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button12Click(Sender: TObject);
var
 m:array [0..3] of byte;
begin
 m[0]:=strtoint('$'+Edit1.Text[1]+Edit1.Text[2]);
 m[1]:=strtoint('$'+Edit1.Text[3]+Edit1.Text[4]);
 m[2]:=strtoint('$'+Edit1.Text[5]+Edit1.Text[6]);
 m[3]:=strtoint('$'+Edit1.Text[7]+Edit1.Text[8]);
 mDeleteGetZone(RadioGroup1.ItemIndex, m, 0);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button3Click(Sender: TObject);
var
 m:array [0..3] of byte;
begin
 m[0]:=strtoint('$'+Edit1.Text[1]+Edit1.Text[2]);
 m[1]:=strtoint('$'+Edit1.Text[3]+Edit1.Text[4]);
 m[2]:=strtoint('$'+Edit1.Text[5]+Edit1.Text[6]);
 m[3]:=strtoint('$'+Edit1.Text[7]+Edit1.Text[8]);
 mUpZone (RadioGroup1.ItemIndex, m, SpinEdit2.Value, byte(CheckBox1.Checked), byte(CheckBox4.Checked));
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button2Click(Sender: TObject);
var
 m:array [0..3] of byte;
begin
 m[0]:=strtoint('$'+Edit1.Text[1]+Edit1.Text[2]);
 m[1]:=strtoint('$'+Edit1.Text[3]+Edit1.Text[4]);
 m[2]:=strtoint('$'+Edit1.Text[5]+Edit1.Text[6]);
 m[3]:=strtoint('$'+Edit1.Text[7]+Edit1.Text[8]);
 mDownZone (RadioGroup1.ItemIndex, m, SpinEdit2.Value, byte(CheckBox1.Checked));
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button10Click(Sender: TObject);
var
 m:array [0..3] of byte;
begin
 m[0]:=strtoint('$'+Edit1.Text[1]+Edit1.Text[2]);
 m[1]:=strtoint('$'+Edit1.Text[3]+Edit1.Text[4]);
 m[2]:=strtoint('$'+Edit1.Text[5]+Edit1.Text[6]);
 m[3]:=strtoint('$'+Edit1.Text[7]+Edit1.Text[8]);
 mAroudZone (RadioGroup1.ItemIndex, m, SpinEdit2.Value, byte(CheckBox1.Checked));
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button9Click(Sender: TObject);
var
 m:array [0..3] of byte;
begin
 m[0]:=strtoint('$'+Edit1.Text[1]+Edit1.Text[2]);
 m[1]:=strtoint('$'+Edit1.Text[3]+Edit1.Text[4]);
 m[2]:=strtoint('$'+Edit1.Text[5]+Edit1.Text[6]);
 m[3]:=strtoint('$'+Edit1.Text[7]+Edit1.Text[8]);
 mResetZone (RadioGroup1.ItemIndex, m, SpinEdit2.Value, byte(CheckBox1.Checked));
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button13Click(Sender: TObject);
begin
 mCreateChangeCU(RadioGroup1.ItemIndex, SpinEdit7.Value, strtoint(copy(ComboBox3.Text,1,2)), 16*byte(CheckBox2.Checked) +8*(SpinEdit3.Value-1)+3, 0);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button11Click(Sender: TObject);
begin
 mCreateChangeCU(RadioGroup1.ItemIndex, SpinEdit7.Value, strtoint(copy(ComboBox3.Text,1,2)), 16*byte(CheckBox2.Checked) +8*(SpinEdit3.Value-1)+3, 1 );
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button14Click(Sender: TObject);
begin
 mDeleteGetCU(RadioGroup1.ItemIndex, SpinEdit7.Value, strtoint(copy(ComboBox3.Text,1,2)), 0);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button15Click(Sender: TObject);
var
 name_tc, name_zone, id_hid : array [0..3] of byte;
 config_union : array [0..15] of byte;

begin
 name_zone[0]:=strtoint('$'+Edit5.Text[1]+Edit5.Text[2]);
 name_zone[1]:=strtoint('$'+Edit5.Text[3]+Edit5.Text[4]);
 name_zone[2]:=strtoint('$'+Edit5.Text[5]+Edit5.Text[6]);
 name_zone[3]:=strtoint('$'+Edit5.Text[7]+Edit5.Text[8]);
 name_tc[0]:=strtoint('$'+Edit6.Text[1]+Edit5.Text[2]);
 name_tc[1]:=strtoint('$'+Edit6.Text[3]+Edit5.Text[4]);
 name_tc[2]:=strtoint('$'+Edit6.Text[5]+Edit5.Text[6]);
 name_tc[3]:=strtoint('$'+Edit6.Text[7]+Edit5.Text[8]);
 id_hid[0]:=strtoint(copy(ComboBox4.Text,1,2));
 id_hid[1]:=lo(SpinEdit4.Value);
 id_hid[2]:=hi(SpinEdit4.Value);
 config_union[0]:=0;                     // параметы шлейфа
 config_union[1]:=0;                     // задерка на вход
 config_union[2]:=0;                     // задерка на выход
 config_union[4]:=0;                     // тип

 mCreateChangeTC(RadioGroup1.ItemIndex,
                 SpinEdit6.Value,
                 strtoint(copy(ComboBox5.Text,1,2)),
                 name_tc,
                 0,
                 byte(CheckBox5.checked) shl 3 + 3,
                 name_zone,
                 0,
                 strtoint(copy(ComboBox4.Text,1,2)),
                 SpinEdit4.Value,
                 SpinEdit5.Value,
                 config_union,
                 0,
                 0,
                 0);

end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button30Click(Sender: TObject);
var
 name_tc, name_zone: array [0..3] of byte;
 config_union : array [0..15] of byte;

begin
 name_zone[0]:=strtoint('$'+Edit5.Text[1]+Edit5.Text[2]);
 name_zone[1]:=strtoint('$'+Edit5.Text[3]+Edit5.Text[4]);
 name_zone[2]:=strtoint('$'+Edit5.Text[5]+Edit5.Text[6]);
 name_zone[3]:=strtoint('$'+Edit5.Text[7]+Edit5.Text[8]);
 name_tc[0]:=strtoint('$'+Edit6.Text[1]+Edit5.Text[2]);
 name_tc[1]:=strtoint('$'+Edit6.Text[3]+Edit5.Text[4]);
 name_tc[2]:=strtoint('$'+Edit6.Text[5]+Edit5.Text[6]);
 name_tc[3]:=strtoint('$'+Edit6.Text[7]+Edit5.Text[8]);

 config_union[0]:=0;                     // параметы шлейфа
 config_union[1]:=0;                     // задерка на вход
 config_union[2]:=0;                     // задерка на выход
 config_union[4]:=0;                     // тип

 mDownTC(RadioGroup1.ItemIndex, SpinEdit6.Value, SpinEdit6.Value, byte(CheckBox7.Checked));
 mCreateChangeTC(RadioGroup1.ItemIndex,
                 SpinEdit6.Value,
                 strtoint(copy(ComboBox5.Text,1,2)),
                 name_tc,
                 0,
                 byte(CheckBox5.checked) shl 3 + 3,
                 name_zone,
                 0,
                 strtoint(copy(ComboBox4.Text,1,2)),
                 SpinEdit4.Value,
                 SpinEdit5.Value,
                 config_union,
                 0,
                 0,
                 1);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button16Click(Sender: TObject);
begin
 mDeleteGetTC(RadioGroup1.ItemIndex, SpinEdit6.Value, 0);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button20Click(Sender: TObject);
var
 t:PTTelegram;
begin
 new(t);
 mGetListTC(RadioGroup1.ItemIndex, strtoint('$'+Edit7.Text), t);
 rub[0].WBuf.Add(t);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button21Click(Sender: TObject);
begin
 mUpTC (RadioGroup1.ItemIndex, SpinEdit6.Value, SpinEdit11.Value, byte(CheckBox7.Checked));
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button22Click(Sender: TObject);
begin
 mDownTC (RadioGroup1.ItemIndex, SpinEdit6.Value, SpinEdit11.Value, byte(CheckBox7.Checked));
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button28Click(Sender: TObject);
begin
 mResetTC (RadioGroup1.ItemIndex, SpinEdit6.Value, SpinEdit6.Value, byte(CheckBox7.Checked));
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button31Click(Sender: TObject);
const
 seconds_in_min=60;
 seconds_in_hour=3600;
 seconds_in_day=86400;
 seconds_in_year=31536000;
 FirstDayOfEachMonth : array [1..12] of word = (1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
 FirstDayOfEachMonthInLeapYear : array [1..12] of word = (1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336);

var
 year, month, d : word;
 total : longword;
 code : array [0..7] of byte;
 m:array [0..3] of byte;

begin
 m[0]:=strtoint('$'+Edit8.Text[1]+Edit8.Text[2]);
 m[1]:=strtoint('$'+Edit8.Text[3]+Edit8.Text[4]);
 m[2]:=strtoint('$'+Edit8.Text[5]+Edit8.Text[6]);
 m[3]:=strtoint('$'+Edit8.Text[7]+Edit8.Text[8]);
 DecodeDate(DateEdit1.Date, year, month, d);
 total:=0;
 if year>2000 then total:=(year-2000)*seconds_in_year + (((year-2001) div 4)+1)*seconds_in_day;
 if IsLeapYear(year) then total:=total+(FirstDayOfEachMonthInLeapYear[month]-1)*seconds_in_day else total:=total+(FirstDayOfEachMonth[month]-1)*seconds_in_day;
 total:=total + (d-1)*seconds_in_day;
 if year<2000 then total:=0;

 mCreateChangeUser (RadioGroup1.ItemIndex,
             (byte(CheckBox6.checked) shl 4)+7,
             SpinEdit10.Value,
             0,
             code,
             strtoint(Edit9.Text),
             SpinEdit12.Value,
             0,
             m,
             SpinEdit15.Value,             
             total,
             SpinEdit14.Value,
             SpinEdit13.Value,
             0);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button32Click(Sender: TObject);
const
 seconds_in_min=60;
 seconds_in_hour=3600;
 seconds_in_day=86400;
 seconds_in_year=31536000;
 FirstDayOfEachMonth : array [1..12] of word = (1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
 FirstDayOfEachMonthInLeapYear : array [1..12] of word = (1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336);

var
 year, month, d : word;
 total : longword;
 code : array [0..7] of byte;
 m:array [0..3] of byte;

begin
 m[0]:=strtoint('$'+Edit8.Text[1]+Edit8.Text[2]);
 m[1]:=strtoint('$'+Edit8.Text[3]+Edit8.Text[4]);
 m[2]:=strtoint('$'+Edit8.Text[5]+Edit8.Text[6]);
 m[3]:=strtoint('$'+Edit8.Text[7]+Edit8.Text[8]);
 DecodeDate(DateEdit1.Date, year, month, d);
 total:=0;
 if year>2000 then total:=(year-2000)*seconds_in_year + (((year-2001) div 4)+1)*seconds_in_day;
 if IsLeapYear(year) then total:=total+(FirstDayOfEachMonthInLeapYear[month]-1)*seconds_in_day else total:=total+(FirstDayOfEachMonth[month]-1)*seconds_in_day;
 total:=total + (d-1)*seconds_in_day;
 if year<2000 then total:=0;

 mCreateChangeUser (RadioGroup1.ItemIndex,
             (byte(CheckBox6.checked) shl 4)+7,
             SpinEdit10.Value,
             0,
             code,
             strtoint(Edit9.Text),
             SpinEdit12.Value,
             0,
             m,
             SpinEdit15.Value,
             total,
             SpinEdit14.Value,
             SpinEdit13.Value,
             1);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button27Click(Sender: TObject);
begin
 mDeleteGetUser (RadioGroup1.ItemIndex, SpinEdit10.Value, 1);
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button33Click(Sender: TObject);
begin
 mDeleteGetUser (RadioGroup1.ItemIndex, SpinEdit10.Value, 0);
end;

//-----------------------------------------------------------------------------
//
//
procedure TRbControl.Button18Click(Sender: TObject);
var
 t:PTTelegram;
begin
 new(t);
 mGetEvent(RadioGroup1.ItemIndex, strtoint('$'+Edit4.Text), t);
 rub[0].WBuf.Add(t);
end;
//
//
//-----------------------------------------------------------------------------
//---------------------- Эмулятор ---------------------------------------------
//-----------------------------------------------------------------------------
procedure TRbControl.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
 z, i:word;
 p:^TTC;

begin
 z:=10*(ARow-1)+ACol-1;
 SpinEdit8.Value:=0;
 SpinEdit9.Value:=0;

 i:=0;
 while (i<rub[0].TC.Count) do
  begin
   p:=rub[0].TC.Items[i];
   if p^.ZoneVista=z then
    begin
     SpinEdit8.Value:=p^.ZoneVista;
     SpinEdit9.Value:=p^.PartVista;
     break;
    end;
   inc(i);
  end;

end;

//-----------------------------------------------------------------------------
procedure TRbControl.TimerRefrehGridTimer(Sender: TObject);
var
 p:^TTC;
 i:word;
 s:string;

begin
 for i:=1 to 1024 do StringGrid1.Cells[(i mod 10)+1, (i div 10)+1]:='';
 for i:=1 to rub[0].TC.Count do
  begin
   p:=rub[0].TC.Items[i-1];
   if (p^.State and 1)>0  then s:=   '' else s:='н';   // готовность
   if (p^.State and 2)>0  then s:=s+'в' else s:=s+'';  // взятотсть
   if (p^.State and 4)>0  then s:=s+'т' else s:=s+'';  // тревога
   if (p^.State and 8)>0  then s:=s+'х' else s:=s+'';  // неисправность
   if (p^.State and 16)>0 then s:=s+'о' else s:=s+'';  // обход
   if p^.ZoneVista<>0 then StringGrid1.Cells[(p^.ZoneVista mod 10)+1, (p^.ZoneVista div 10)+1]:=s else StringGrid1.Cells[(p^.ZoneVista mod 10)+1, (p^.ZoneVista div 10)+1]:='000';
  end;
end;

//-----------------------------------------------------------------------------
procedure TRbControl.Button29Click(Sender: TObject);
var
 i:word;
 p, pz:^TTC;
 mes : KSBMES;
 onestep : boolean;

begin
 if ListBox1.ItemIndex<=7 then
  begin
   pz:=nil;
   for i:=1 to rub[0].TC.Count do
    begin
     p:=rub[0].TC.Items[i-1];
     if SpinEdit8.Value=p^.ZoneVista then begin pz:=p; break; end;
    end;
   if pz=nil then exit;
   
   Init(mes);
   if ListBox1.Items[ListBox1.ItemIndex]='Зона взятa'            then begin pz^.State:=pz^.State or 2; mes.Code:=R8_ZONE_ARMED; end;
   if ListBox1.Items[ListBox1.ItemIndex]='Зона снята'            then begin pz^.State:=pz^.State and $fd; mes.Code:=R8_ZONE_DISARMED; end;
   if ListBox1.Items[ListBox1.ItemIndex]='Зона обойдена'         then begin pz^.State:=pz^.State or 16; mes.Code:=R8_ZONE_BYPASS; end;
   if ListBox1.Items[ListBox1.ItemIndex]='Зона без обхода'       then begin pz^.State:=pz^.State and $ef; mes.Code:=R8_ZONE_READY; end;
   if ListBox1.Items[ListBox1.ItemIndex]='Зона неготова'         then begin pz^.State:=pz^.State and $fe; mes.Code:=R8_ZONE_NOTREADY; end;
   if ListBox1.Items[ListBox1.ItemIndex]='Зона готова'           then begin pz^.State:=pz^.State or 1; mes.Code:=R8_ZONE_READY; end;
   if ListBox1.Items[ListBox1.ItemIndex]='Зона в тревоге'        then begin pz^.State:=pz^.State or 4; mes.Code:=R8_ZONE_ALARM; end;
   if ListBox1.Items[ListBox1.ItemIndex]='Сброс тревоги зоны'    then begin pz^.State:=pz^.State and $fb; mes.Code:=R8_CONNECT_TRUE; end;

   mes.SysDevice:=SYSTEM_OPS;
   mes.TypeDevice:=5;
   mes.NumDevice:=0;
   mes.NetDevice:=ModuleNetDevice;
   mes.BigDevice:=rub[0].BigDevice;
   mes.SmallDevice:=SpinEdit8.Value;
   mes.NumDevice:=0;
   Send(mes);
  end

  else

  begin
   onestep:=false;
   for i:=1 to rub[0].TC.Count do
    begin
     p:=rub[0].TC.Items[i-1];
     if SpinEdit9.Value=p^.PartVista then
      begin
       pz:=p;
       Init(mes);
       if ListBox1.Items[ListBox1.ItemIndex]='Раздел взят'  then begin pz^.State:=pz^.State or 2; mes.Code:=R8_PART_ARMED; end;
       if ListBox1.Items[ListBox1.ItemIndex]='Раздел снят'  then begin pz^.State:=pz^.State and $fd; mes.Code:=R8_PART_READY; end;

       if onestep then continue else onestep:=true;
       mes.SysDevice:=SYSTEM_OPS;
       mes.TypeDevice:=6;
       mes.NumDevice:=0;
       mes.NetDevice:=ModuleNetDevice;
       mes.BigDevice:=rub[0].BigDevice;
       mes.Partion:=SpinEdit9.Value;
       mes.SmallDevice:=SpinEdit9.Value;
       mes.NumDevice:=0;
       Send(mes);
      end;
    end;
  end;

end;


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------












END.


