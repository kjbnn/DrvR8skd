unit mBCPConf;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ComCtrls, Spin, ToolWin, ExtCtrls, DBCtrls,
  Grids, DBGrids, RxMemDS, DB, DBClient, Mask, Buttons, DBTables, Provider,
  IBCustomDataSet, IBTable, rxDBLists;

type
  TMyDataSet=class(TDataSet)
  end;

  TBCPConf = class(TForm)
    ImageList1: TImageList;
    DBGrid1: TDBGrid;

    ToolBar1: TToolBar;
    ToolButton7: TToolButton;
    DBNavigator1: TDBNavigator;
    ToolButton9: TToolButton;
    ComboBox1: TComboBox;
    ToolButton1: TToolButton;
    CheckBox1: TCheckBox;
    ToolButton4: TToolButton;
    Panel1: TPanel;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    CheckBox2: TCheckBox;
    ToolButton10: TToolButton;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    DS1: TDataSource;
    RxMD200: TClientDataSet;
    RxMD200row: TIntegerField;
    RxMD200zonenumber: TStringField;
    RxMD200tcnumber: TStringField;
    RxMD200tcid: TStringField;
    RxMD200tctype: TStringField;
    RxMD200tcname: TStringField;
    RxMD200tcgroupnumber: TStringField;
    RxMD200cutype: TStringField;
    RxMD200cunumber: TStringField;
    RxMD200cuelement: TStringField;
    RxMD200tcconnect: TStringField;
    RxMD200tcview: TStringField;
    RxMD200tctamper: TStringField;
    RxMD200tcalivetime: TStringField;
    RxMD200tcdata: TStringField;
    RxMD: TRxMemoryData;
    ToolButton5: TToolButton;
    ToolButton12: TToolButton;
    ToolButton2: TToolButton;

    procedure ToolButton9Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure DS1DataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure RxMDFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    { Private declarations }
  public
    ds: TMyDataSet;
  end;

var
  BCPConf: TBCPConf;

procedure ReadBCPConfFromCsv;
procedure WriteTableCfgToCsv;
procedure LabelToFieldDS(LabelDS: string; var FieldDS: string);
procedure SetFilter;

implementation
uses R8Unit, mMain, connection, SharedBuffer, constants, KSBParam;

{$R *.dfm}


procedure ReadBCPConfFromCsv;
const
 COLUMNS = 15;
var
 tf: TextFile;
 s, st: string;
 i, StrPos, Row: word;

begin
 Debug('F:ReadBCPConfFromCsv');
 //
 s:= ReadPath() + Format('Net%uBig%u.csv',[rub.NetDevice, rub.BigDevice]);
 if FileExists(s)
   then AssignFile(tf, s)
   else exit;
     //
 if BCPConf.RxMD.Active then
   BCPConf.RxMD.Close;
 BCPConf.RxMD.Open;
 //BCPConf.RxMD.LoadFromFile('tc.cds');

 TRY
   with rub do begin
   Reset(tf);
   Row:= 0;
   //
   while not Eof(tf) do
   begin
     ReadLn(tf, s);
     if Row=0 then
     begin
       if s<>'�����;��� ����;�;ID;���;���;�������;��� ��;���;������� ��;����������;���;������;��������������;������' then
         Raise Exception.Create( Format('�� ���������� ���� Net%uBig%u.csv. ������ �%d', [ NetDevice, BigDevice, Row ]) );
       inc(Row);
       continue;
     end;
     //
     BCPConf.RxMD.Append;
     //
     //�����;�;ID;���;���;�������;��� ��;���;������� ��;����������;���;������;��������������;������;', []);
     for i:=0 to COLUMNS-1 do
     begin
       StrPos:= Pos(';', s);
       if (StrPos=0)and(i<>(COLUMNS-1)) then
         Raise Exception.Create( Format('�� ���������� ���� Net%uBig%u.csv. ������ �%d', [ NetDevice, BigDevice, Row ]) );
       if StrPos=0
         then st:= s
         else st:= Copy(s, 1, StrPos-1);
       st:= Trim(st);
       //
       BCPConf.RxMD.FieldByName('Row').AsInteger:= Row;
       case i of
         0: BCPConf.RxMD.FieldByName('zonenumber').AsString:= st;
         2: BCPConf.RxMD.FieldByName('tcnumber').AsString:= st;
         3: BCPConf.RxMD.FieldByName('tcid').AsString:= st;
         4: BCPConf.RxMD.FieldByName('tctype').AsString:= st;
         5: BCPConf.RxMD.FieldByName('tcname').AsString:= st;
         6: BCPConf.RxMD.FieldByName('tcgroupnumber').AsString:= st;
         7: BCPConf.RxMD.FieldByName('cutype').AsString:= st;
         8: BCPConf.RxMD.FieldByName('cunumber').AsString:= st;
         9: BCPConf.RxMD.FieldByName('cuelement').AsString:= st;
         10: BCPConf.RxMD.FieldByName('tcconnect').AsString:= st;
         11: BCPConf.RxMD.FieldByName('tcview').AsString:= st;
         12: BCPConf.RxMD.FieldByName('tctamper').AsString:= st;
         13: BCPConf.RxMD.FieldByName('tcalivetime').AsString:= st;
         14: BCPConf.RxMD.FieldByName('tcdata').AsString:= st;
       end;
       Delete(s, 1, StrPos);
     end;
     //
     BCPConf.RxMD.Post;
     inc(Row);
   end;//while


   end;//with

 FINALLY
   CloseFile(tf);
 END;
end;

procedure WriteTableCfgToCsv;
var
 tf: TextFile;
 s: String;
begin
 Debug('F:WriteTableCfgToCsv');
 //
 s:= ReadPath() + Format('Net%uBig%u.csv',[rub.NetDevice, rub.BigDevice]);
 AssignFile(tf, s);
 TRY
   Rewrite(tf);
   s:= Format('�����;��� ����;�;ID;���;���;�������;��� ��;���;������� ��;����������;���;������;��������������;������', []);
   Writeln(tf, s);
   BCPConf.RxMD.First;
   while not BCPConf.RxMD.Eof do
   begin
     s:= Format('%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s',
        [
        BCPConf.RxMD.FieldByName('zonenumber').AsString,
        BCPConf.RxMD.FieldByName('zonenumber').AsString,
        BCPConf.RxMD.FieldByName('tcnumber').AsString,
        BCPConf.RxMD.FieldByName('tcid').AsString,
        BCPConf.RxMD.FieldByName('tctype').AsString,
        BCPConf.RxMD.FieldByName('tcname').AsString,
        BCPConf.RxMD.FieldByName('tcgroupnumber').AsString,
        BCPConf.RxMD.FieldByName('cutype').AsString,
        BCPConf.RxMD.FieldByName('cunumber').AsString,
        BCPConf.RxMD.FieldByName('cuelement').AsString,
        BCPConf.RxMD.FieldByName('tcconnect').AsString,
        BCPConf.RxMD.FieldByName('tcview').AsString,
        BCPConf.RxMD.FieldByName('tctamper').AsString,
        BCPConf.RxMD.FieldByName('tcalivetime').AsString,
        BCPConf.RxMD.FieldByName('tcdata').AsString
        ] );
     Writeln(tf, s);
     BCPConf.RxMD.Next;
   end;
   //
   Flush(tf);
 FINALLY
   CloseFile(tf);
 END;
end;


procedure TBCPConf.ToolButton9Click(Sender: TObject);
begin
 ReadBCPConfFromCsv;
 CheckBox1.Checked:= False;
end;

procedure TBCPConf.ToolButton7Click(Sender: TObject);
type
 TTCRec = record
   zonenumber: word; //�����
   tcnumber: word; //���
   tcid: word; //id��
   tctype: byte; //��� ��
   tcname: byte; //��� ��
   tcgroupnumber: byte; //�������
   cutype: byte; //��� ��
   cunumber: word; //���
   cuelement: byte; //������� ��
   tcconnect: byte; //�� ����������
   tcview: byte; //��� ��
   tctamper: byte; //������ ��
   tcalivetime: byte; //�������������� ��
   tcdata: string; //������ ��
 end;

var
 mes: KSBMES;
 str: String;
 l: array[0..127] of BYTE;
 Value: TTCRec;
 s: string;

begin
 if BCPConf.RxMD.Eof then
   exit;
 TRY
   Value.zonenumber:= StrToInt( BCPConf.RxMD.FieldByName('zonenumber').AsString );
   Value.tcnumber:= StrToInt( BCPConf.RxMD.FieldByName('tcnumber').AsString );
   Value.tcid:= StrToInt( BCPConf.RxMD.FieldByName('tcid').AsString );
   Value.tctype:= TCTypeToInt( BCPConf.RxMD.FieldByName('tctype').AsString );
   Value.tcname:= StrToInt( BCPConf.RxMD.FieldByName('tcname').AsString );
   Value.tcgroupnumber:= StrToInt( BCPConf.RxMD.FieldByName('tcgroupnumber').AsString );
   Value.cutype:= StrToHWType( BCPConf.RxMD.FieldByName('cutype').AsString );
   Value.cunumber:= StrToInt( BCPConf.RxMD.FieldByName('cunumber').AsString );
   Value.cuelement:= StrToInt( BCPConf.RxMD.FieldByName('cuelement').AsString );
   Value.tcconnect:= StrToInt( BCPConf.RxMD.FieldByName('tcconnect').AsString );
   Value.tcview:= StrToInt( BCPConf.RxMD.FieldByName('tcview').AsString );
   Value.tctamper:= StrToInt( BCPConf.RxMD.FieldByName('tctamper').AsString );
   Value.tcalivetime:= StrToInt( BCPConf.RxMD.FieldByName('tcalivetime').AsString );
   Value.tcdata:= BCPConf.RxMD.FieldByName('tcdata').AsString;
   //
   Init(mes);
   mes.SysDevice:= SYSTEM_OPS;
   mes.NetDevice:= rub.NetDevice;
   mes.BigDevice:= rub.BigDevice;
   mes.TypeDevice:= 4;
   TheKSBParam.WriteIntegerParam(mes, '', '����� ����', Value.zonenumber);
   FillChar(l,128,0);
   //
   s:= IntToStr(Value.tcnumber);
   StrToVal(s, l[1]);
   l[5]:= Value.tcname;                                         // l[5]-��� ��������� �� ������
   l[6]:= byte(Value.tctamper) shl 7 +
         Value.tcview shl 4 +
         byte(Value.tcconnect) shl 3 +
         3; // l[6]-��.��� >> 110(��� 1���)(����������� 2����) 1 << ��.���
   l[7]:= Value.tcgroupnumber; // l[7]-������
   l[8]:= Value.cutype; // l[8]-��� ������������
   l[9]:= lo(Value.cunumber); // l[9]-��.���� �������� ����� HW
   l[10]:= hi(Value.cunumber); // l[10]-��.���� �������� ����� HW
   l[11]:= Value.cuelement; // l[11]-����� ��������
   Simbol2Bin(Value.tcdata, @l[12], 15);
   l[27]:= Value.tcalivetime;                          // ��������.
   //
   case Value.tctype of
     1: //��
     begin
       TheKSBParam.WriteIntegerParam(mes, '', '����� ��', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 1; // l[0]-��� (1-��������)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     2: //��
     begin
       TheKSBParam.WriteIntegerParam(mes, '', '����� ��', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 2; // l[0]-��� (2-���������)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     3: //��
     begin
       TheKSBParam.WriteIntegerParam(mes, '', '����� ��', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 3; // l[0]-��� (3-��������)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     4: //����
     begin
       TheKSBParam.WriteIntegerParam(mes, '', '����� ��', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 4; // l[0]-��� (4-��������.)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     5: //����
     begin
       TheKSBParam.WriteIntegerParam(mes, '', '����� ����', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 5; // l[0]-��� (5-����)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_RELAY_CREATE;
         1: mes.Code:= R8_COMMAND_RELAY_CHANGE;
         2: mes.Code:= R8_COMMAND_RELAY_DELETE;
       end;
     end;
     6: //��
     begin
       TheKSBParam.WriteIntegerParam(mes, '', '����� ��', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 6; // l[0]-��� (6-��)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_AP_CREATE;
         1: mes.Code:= R8_COMMAND_AP_CHANGE;
         2: mes.Code:= R8_COMMAND_AP_DELETE;
       end;
     end;
     7: //����.
     begin
       TheKSBParam.WriteIntegerParam(mes, '', '����� ���������', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 7; // l[0]-��� (7-����.)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_TERM_CREATE;
         1: mes.Code:= R8_COMMAND_TERM_CHANGE;
         2: mes.Code:= R8_COMMAND_TERM_DELETE;
       end;
     end;
     else exit;
   end;//case

   str:= Bin2Simbol(PChar(@l[0]), mes.Size);
   aMain.Consider(mes, str);
   BCPConf.RxMD.Next;
 EXCEPT
   On E: Exception do
     MessageBox(0, PChar('������ ����� (' + E.Message + ')'), '��������', MB_OK or MB_SYSTEMMODAL{ or MB_ICONQUESTION});
 END;
end;


procedure TBCPConf.ToolButton4Click(Sender: TObject);
begin
 if RxMD.Filtered
   then MessageBox(0, '������� ������!'+#13#10+'��� ���������� ��������� ������', '��������', MB_OK or MB_TASKMODAL)
   else WriteTableCfgToCsv;
end;

procedure TBCPConf.CheckBox1Click(Sender: TObject);
begin
 if CheckBox1.Checked then
   DBGrid1.Options:= [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit]
 else
   DBGrid1.Options:= [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgConfirmDelete,dgCancelOnExit];
end;

procedure LabelToFieldDS(LabelDS: string; var FieldDS: string);
begin
  if LabelDS='�����' then FieldDS:='zonenumber';
  if LabelDS='�' then FieldDS:='tcnumber';
  if LabelDS='ID' then FieldDS:='tcid';
  if LabelDS='���' then FieldDS:='tctype';
  if LabelDS='���' then FieldDS:='tcname';
  if LabelDS='�������' then FieldDS:='tcgroupnumber';
  if LabelDS='��� ��' then FieldDS:='cutype';
  if LabelDS='���' then FieldDS:='cunumber';
  if LabelDS='������� ��' then FieldDS:='cuelement';
  if LabelDS='����������' then FieldDS:='tcconnect';
  if LabelDS='���' then FieldDS:='tcview';
  if LabelDS='������' then FieldDS:='tctamper';
  if LabelDS='��������������' then FieldDS:='tcalivetime';
  if LabelDS='������' then FieldDS:='tcdata';
end;

procedure SetFilter;
var
 s: String;
begin
 with BCPConf do begin
   //
   RxMD.Filtered:= False;
   s:='';
   if (ComboBox2.ItemIndex>0)and(Edit1.Text<>'') then
   begin
     // -- vvv -- ������ ��� �� RxMemoryData
     LabelToFieldDS(ComboBox2.Text, s);
     RxMD.Filter:= s + '=' + '''' + Edit1.Text + '''';
     // -- ^^^ --
     RxMD.Filtered:= True;
   end;
   //
 end;//with
end;

procedure TBCPConf.RxMDFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
 s: string;
begin
  s:='';
  if (ComboBox2.ItemIndex>0)and(Edit1.Text<>'') then
    LabelToFieldDS(ComboBox2.Text, s);
  if s<>'' then
    Accept:= DataSet.FieldByName(s).AsString = Edit1.Text;
end;

procedure TBCPConf.ComboBox2Change(Sender: TObject);
begin
 SetFilter;
end;

procedure TBCPConf.Edit1Change(Sender: TObject);
begin
 SetFilter;
end;

procedure TBCPConf.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
 if Key in [''''] then
   Raise Exception.Create( Format('�� ���������� ����', [ ]) );
end;

procedure TBCPConf.DS1DataChange(Sender: TObject; Field: TField);
begin
 if not BCPConf.RxMD.Eof
   then Panel1.Caption:= BCPConf.RxMD.FieldByName('row').AsString
   else Panel1.Caption:= '';
end;


procedure TBCPConf.FormCreate(Sender: TObject);
begin
 {ds:= TMyDataSet.Create(self);
 ds.FieldDefs.Add('row', ftInteger);
 ds.FieldDefs.Add('zonenumber', ftString, 20);
 ds.FieldDefs.Add('zonenumber', ftString, 20);
 with ds do begin
 with FieldDefs.AddFieldDef do
 begin
   DataType:= ftInteger;
   Name:= 'row';
   DisplayName:= '�������';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'zonenumber';
   DisplayName:= '�����';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcnumber';
   DisplayName:= '�';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcid';
   DisplayName:= 'ID';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tctype';
   DisplayName:= '���';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcname';
   DisplayName:= '���';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcgroupnumber';
   DisplayName:= '�������';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'cutype';
   DisplayName:= '��� ��';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'cunumber';
   DisplayName:= '���';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'cuelement';
   DisplayName:= '������� ��';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcconnect';
   DisplayName:= '�����.';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcview';
   DisplayName:= '���';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tctamper';
   DisplayName:= '������';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcalivetime';
   DisplayName:= '�����.';
 end;

 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 40;
   Name:= 'tcdata';
   DisplayName:= '������';
 end;

 end;//
}
end;






end.

