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
       if s<>'№Зоны;Имя зоны;№;ID;Тип;Имя;№Группы;Тип СУ;№СУ;Элемент СУ;Подключено;Вид;Тампер;Восстановление;Данные' then
         Raise Exception.Create( Format('Не корректный файл Net%uBig%u.csv. Строка №%d', [ NetDevice, BigDevice, Row ]) );
       inc(Row);
       continue;
     end;
     //
     BCPConf.RxMD.Append;
     //
     //№Зоны;№;ID;Тип;Имя;№Группы;Тип СУ;№СУ;Элемент СУ;Подключено;Вид;Тампер;Восстановление;Данные;', []);
     for i:=0 to COLUMNS-1 do
     begin
       StrPos:= Pos(';', s);
       if (StrPos=0)and(i<>(COLUMNS-1)) then
         Raise Exception.Create( Format('Не корректный файл Net%uBig%u.csv. Строка №%d', [ NetDevice, BigDevice, Row ]) );
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
   s:= Format('№Зоны;Имя зоны;№;ID;Тип;Имя;№Группы;Тип СУ;№СУ;Элемент СУ;Подключено;Вид;Тампер;Восстановление;Данные', []);
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
   zonenumber: word; //№Зоны
   tcnumber: word; //№ТС
   tcid: word; //idТС
   tctype: byte; //Тип ТС
   tcname: byte; //Имя ТС
   tcgroupnumber: byte; //№Группы
   cutype: byte; //Тип СУ
   cunumber: word; //№СУ
   cuelement: byte; //Элемент СУ
   tcconnect: byte; //ТС Подключено
   tcview: byte; //Вид ТС
   tctamper: byte; //Тампер ТС
   tcalivetime: byte; //Восстановление ТС
   tcdata: string; //Данные ТС
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
   TheKSBParam.WriteIntegerParam(mes, '', 'Номер зоны', Value.zonenumber);
   FillChar(l,128,0);
   //
   s:= IntToStr(Value.tcnumber);
   StrToVal(s, l[1]);
   l[5]:= Value.tcname;                                         // l[5]-имя указатель на строку
   l[6]:= byte(Value.tctamper) shl 7 +
         Value.tcview shl 4 +
         byte(Value.tcconnect) shl 3 +
         3; // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
   l[7]:= Value.tcgroupnumber; // l[7]-группа
   l[8]:= Value.cutype; // l[8]-тип оборудования
   l[9]:= lo(Value.cunumber); // l[9]-мл.байт серийный номер HW
   l[10]:= hi(Value.cunumber); // l[10]-ст.байт серийный номер HW
   l[11]:= Value.cuelement; // l[11]-номер элемента
   Simbol2Bin(Value.tcdata, @l[12], 15);
   l[27]:= Value.tcalivetime;                          // Автовост.
   //
   case Value.tctype of
     1: //ОШ
     begin
       TheKSBParam.WriteIntegerParam(mes, '', 'Номер ШС', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 1; // l[0]-тип (1-охранный)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     2: //ТШ
     begin
       TheKSBParam.WriteIntegerParam(mes, '', 'Номер ШС', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 2; // l[0]-тип (2-тревожный)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     3: //ПШ
     begin
       TheKSBParam.WriteIntegerParam(mes, '', 'Номер ШС', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 3; // l[0]-тип (3-пожарный)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     4: //ТехШ
     begin
       TheKSBParam.WriteIntegerParam(mes, '', 'Номер ШС', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 4; // l[0]-тип (4-технолог.)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_SH_CREATE;
         1: mes.Code:= R8_COMMAND_SH_CHANGE;
         2: mes.Code:= R8_COMMAND_SH_DELETE;
       end;
     end;
     5: //РЕЛЕ
     begin
       TheKSBParam.WriteIntegerParam(mes, '', 'Номер реле', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 5; // l[0]-тип (5-реле)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_RELAY_CREATE;
         1: mes.Code:= R8_COMMAND_RELAY_CHANGE;
         2: mes.Code:= R8_COMMAND_RELAY_DELETE;
       end;
     end;
     6: //ТД
     begin
       TheKSBParam.WriteIntegerParam(mes, '', 'Номер ТД', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 6; // l[0]-тип (6-ТД)
       case ComboBox1.ItemIndex of
         0: mes.Code:= R8_COMMAND_AP_CREATE;
         1: mes.Code:= R8_COMMAND_AP_CHANGE;
         2: mes.Code:= R8_COMMAND_AP_DELETE;
       end;
     end;
     7: //Терм.
     begin
       TheKSBParam.WriteIntegerParam(mes, '', 'Номер терминала', Value.tcnumber);
       mes.Size:= 28;
       l[0]:= 7; // l[0]-тип (7-Терм.)
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
     MessageBox(0, PChar('Ошибка ввода (' + E.Message + ')'), 'Внимание', MB_OK or MB_SYSTEMMODAL{ or MB_ICONQUESTION});
 END;
end;


procedure TBCPConf.ToolButton4Click(Sender: TObject);
begin
 if RxMD.Filtered
   then MessageBox(0, 'Включен фильтр!'+#13#10+'Для сохранения отключите фильтр', 'Внимание', MB_OK or MB_TASKMODAL)
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
  if LabelDS='№Зоны' then FieldDS:='zonenumber';
  if LabelDS='№' then FieldDS:='tcnumber';
  if LabelDS='ID' then FieldDS:='tcid';
  if LabelDS='Тип' then FieldDS:='tctype';
  if LabelDS='Имя' then FieldDS:='tcname';
  if LabelDS='№Группы' then FieldDS:='tcgroupnumber';
  if LabelDS='Тип СУ' then FieldDS:='cutype';
  if LabelDS='№СУ' then FieldDS:='cunumber';
  if LabelDS='Элемент СУ' then FieldDS:='cuelement';
  if LabelDS='Подключено' then FieldDS:='tcconnect';
  if LabelDS='Вид' then FieldDS:='tcview';
  if LabelDS='Тампер' then FieldDS:='tctamper';
  if LabelDS='Восстановление' then FieldDS:='tcalivetime';
  if LabelDS='Данные' then FieldDS:='tcdata';
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
     // -- vvv -- только для не RxMemoryData
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
   Raise Exception.Create( Format('Не корректный ввод', [ ]) );
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
   DisplayName:= '№Строки';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'zonenumber';
   DisplayName:= '№Зоны';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcnumber';
   DisplayName:= '№';
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
   DisplayName:= 'Тип';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcname';
   DisplayName:= 'Имя';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcgroupnumber';
   DisplayName:= '№Группы';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'cutype';
   DisplayName:= 'Тип СУ';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'cunumber';
   DisplayName:= '№СУ';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'cuelement';
   DisplayName:= 'Элемент СУ';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcconnect';
   DisplayName:= 'Подкл.';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcview';
   DisplayName:= 'Вид';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tctamper';
   DisplayName:= 'Тампер';
 end;
 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 20;
   Name:= 'tcalivetime';
   DisplayName:= 'Восст.';
 end;

 with ds.FieldDefs.AddFieldDef do
 begin
   DataType:= ftString;
   Size:= 40;
   Name:= 'tcdata';
   DisplayName:= 'Данные';
 end;

 end;//
}
end;






end.

