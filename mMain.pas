{$A-}
//{$DEFINE START_COMD}

unit mMain;

interface

// {$DEFINE RUN_WITHOUT_CONNECTION}      // Закоментировать !!!

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, cMainKsb, constants, connection, SharedBuffer,
  Spin, IniFiles, ComCtrls, AppEvnts, CheckLst, Grids, ValEdit, ScktComp,
  IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer,
  IdHTTPServer, Menus, commctrl, IdUDPBase, IdUDPClient, ImgList, Buttons,
  Mask, SyncObjs, RxRichEd;

const
  MAX_LOG_SIZE = 262144;
  REQUEST_VV = 'ViewVersion:';
  REQUEST_GV = 'GetVersion:';
  REQUEST_GF = 'GetFile:';
type

 TOption= record
   left, top, width, height: integer;
   LogForm: boolean;
   LogFile: boolean;
   SyncTime: Longword;
   RstTCTime: Longword;
   NReadyOnCheck: boolean;
   SendOldStateBlock: boolean;
   ForceSendStateBlockMinute: integer;
   BCPLineSpeed: word;
   SCULineSpeed: word;
   SCUPort: word;
   SaveR8hSecInterval: word;
   SysScanner: boolean;
   UC: string;
   Mode: string;
   ZoneOperationSecInterval: byte; //Заглушка 0 польз. (ляп СИГМА-ИС)
   DebugVar: String;
   BCPPass: boolean;
   FastStart: boolean;
   StartDrvTime: Longword;
   //
   Logged_Debug: word;
   Logged_InKSBMES: boolean;
   Logged_OutKSBMES: boolean;
   Logged_Delay: boolean;
   Logged_OnReadBCP: boolean;
   Logged_OnReadBCPTel: boolean;
   Logged_OnReadBCPStateTC: boolean;
   Logged_OnReadBCPStateDebug: boolean;
   Logged_OnReadBCPCalculateStateZone: boolean;
   Logged_OnExecBCPCmd: boolean;
   Logged_OnWriteBCP: boolean;
   Logged_OnReadSCU: boolean;
   Logged_OnWriteSCU: boolean;
 end;

 TFormPos=record
   left,
   top,
   width,
   height: integer;
 end;

 TMesRec = record
   m: KSBMES;
   s: string;
 end;

 TPassPermit = record
   ApNumber: word;
   NoPassTime: word;
   UserNumber: word;
 end;

 TRule=record
   Func: String [16];
   Arg: array [0..10] of word;
   TextRule: String [255];
 end;

  TaMain = class(TaMainKsb)
    ApplicationEvents1: TApplicationEvents;
    AnyTimer: TTimer;
    AntiFreezTimer: TTimer;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Memo1: TMemo;
    Panel2: TPanel;
    HaltTimer: TTimer;
    TabSheet1: TTabSheet;
    Panel3: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Label12: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    Edit7: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Panel4: TPanel;
    Button1: TButton;
    SpinEdit4: TSpinEdit;
    Panel5: TPanel;
    CheckBox3: TCheckBox;
    Button6: TButton;
    LabeledEdit1: TLabeledEdit;
    TabSheet4: TTabSheet;
    Panel7: TPanel;
    Memo2: TMemo;
    Edit12: TEdit;
    Button7: TButton;
    Panel12: TPanel;
    LabeledEdit2: TLabeledEdit;
    UCTimer: TTimer;
    StatusBar1: TStatusBar;
    ClientSocket1: TClientSocket;
    TimerWaitEnd: TTimer;
    SendSocketTimer: TTimer;
    IdHTTPServer1: TIdHTTPServer;
    StatusBar2: TStatusBar;
    PopupMenu2: TPopupMenu;
    N4: TMenuItem;
    StatusBar3: TStatusBar;
    N8: TMenuItem;
    N9: TMenuItem;
    N63: TMenuItem;
    N64: TMenuItem;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    TreeView1: TTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    VLE1: TValueListEditor;
    PopupMenu3: TPopupMenu;
    N3: TMenuItem;
    ImageList1: TImageList;
    Panel1: TPanel;
    Panel6: TPanel;
    MainMenu1: TMainMenu;
    N10: TMenuItem;
    PopupMenu1: TPopupMenu;
    Edit4: TEdit;
    Button2: TButton;
    CheckBox1: TCheckBox;
    RWTimer: TTimer;
    SpinEdit5: TSpinEdit;

    procedure FormCreate(Sender: TObject);
    procedure TimerVisibleTimer(Sender: TObject);
    procedure RWTimerTimer(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure AnyTimerTimer(Sender: TObject);
    procedure AntiFreezTimerTimer(Sender: TObject);
    procedure ChecBox3Click(Sender: TObject);
    procedure HaltTimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure WriteLog(str: string);
    procedure UCTimerTimer(Sender: TObject);
    procedure StatusBar1DblClick(Sender: TObject);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure TimerWaitEndTimer(Sender: TObject);
    procedure SendSocketTimerTimer(Sender: TObject);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure IdHTTPServer1CommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure StatusBar2DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure N4Click(Sender: TObject);
    procedure StatusBar2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth,
      MinHeight, MaxWidth, MaxHeight: Integer);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N64Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure VLE1GetEditMask(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure TimerStopTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DeleteUserZeroAL;
  private
    IsRecStart: Boolean;  //Признак начала получения данных
    SendCommand: string;
    msRead: TMemoryStream;
    temp_Online: byte;
    temp_ErrorCode: byte;
    temp_WorkTime: boolean;
    AutoBlockStateCount: Longword;
    ClockTimeCount: Longword;
    ResetTCTimeCount: Longword;
    SaveR8hCount: Longword;
    SecondTic: Longword;
    TimerVisiblePause: word;
    CommonMesBuf: TList; // общий буфер вх. MesKSB
    procedure ABlend (var Message: TMessage); message WM_QUIT;
  public
    procedure BlockStateToVU(BcpConnect: boolean=True; Step: byte=0); //изм.96
    procedure Consider(mes: KSBMES; str: string); override;
    procedure Send(mes: KSBMES); overload; override;
    procedure Send(mes: KSBMES; str: PChar); overload; override;
    procedure ConsiderBCP(mes: KSBMES; str : string);
    procedure SetOnline(Value: byte);
    procedure DrvErrorReport(code, param, cause, value: word);
    procedure DrvErrorReportForServerRubeg (code, user, card: word);
    procedure DrvReady;
    procedure Log(str: string; param: string='');
    procedure ReadParam;
    procedure UpdateParamListBox;
    procedure SmartCUSend (SmallDevice, Code: word);
    procedure StateString(TypeSource: word; Source: pointer; State: word; var Result: string);
  end;


 procedure Init(var mes: KSBMES); //override source
 function ShowVersion(FileName:string): string;
 function GetFileVersion(FileName: string; var VerInfo : TVSFixedFileInfo): boolean;
 procedure Debug (s: string);
 //
 procedure SetShZmkRule(idAP, idSH: word);
 procedure DelShZmkRule(idAP: word);
 procedure SetAnyCardMode(idAP: word; IdVar: byte);
 procedure DelAnyCardMode(idAP: word);
 //
 function FindRule(s: string): pointer;
 function StrToRule(s: string; var rule: TRule): boolean;
 procedure AddRule(rule: TRule);
 procedure DelRule(p: pointer);
 function ApplyAnyRule(var mes: KSBMES; var str: PChar): boolean;
 function ApplyPassRule(var mes: KSBMes): boolean;
 //
 function FindPassPermit(Number: word): pointer;
 function PassPermitEvent(var mes: KSBMES; var str: PChar): boolean;
 procedure CheckPassPermit;

var
  aMain: TaMain;
  HCount:Int64; // !!!!!!!!! Убрать
  _f,_c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8:LARGE_INTEGER;
  option: TOption;
  GlobalTempMes: KSBMES;
  lsACData: TList;
  lRule: TList;
  lPassPermit: TList;
  GraphicScannerHandle: THandle;
  InitGraphicScanner: Procedure (Left, Top, Col, Row: word); stdcall;
  ViewGraphicScanner: Procedure(Value: boolean); stdcall;
  DrawGraphicScanner: Procedure(m: array of byte; Num: word; Color: dword); stdcall;

implementation

uses R8Unit, Comm, R8OnRecive, KSBParam, DateUtils, Clipbrd,
  SCUunit, mCheckZoneOperation, mBCPConf, mCheckDrv;

{$R *.DFM}


//-----------------------------------------------------------------------------
procedure TaMain.FormCreate(Sender: TObject);
var
 StartError: word;
 s: string;

begin
 option.StartDrvTime:= PackTime(now);
 //IdHTTPServer1.Active:=True;
 TimerVisiblePause:= 0;
 CommonMesBuf:= TList.Create;
 lsACData:= TList.Create;
 lRule:= TList.Create;
 lPassPermit:= TList.Create;
 //
 StartError:= 1;
{ if StartError=1 then
 asm
        int 3;
 end;
 }


 TRY
   inherited;
   ClockTimeCount:= 0;
   ResetTCTimeCount:= 0;
   InitTimer.Enabled:= true;
   //
   StartError:= 2;
   rub:= TRubej.Create;
   rub.NetDevice:= GetKey('NETDEVICE',0);
   rub.BigDevice:= GetKey('BIGDEVICE',0);
   rub.Addr:= strtoint(getkey('ADDR','0'));
   rub.ComPort:= getkey('COM','COM1');
   rub.ComBaud:= strtoint(getkey('COMBAUD','28800'));
   rub.IP:= getkey('IP','192.168.0.8');
   rub.Port:= strtoint(getkey('PORT','2000'));
   GraphicScannerHandle:= LoadLibrary('GraphicScanner.dll');
   try
     InitGraphicScanner:= GetProcAddress(GraphicScannerHandle, 'InitGraphicScanner');
     ViewGraphicScanner:= GetProcAddress(GraphicScannerHandle, 'ViewGraphicScanner');
     DrawGraphicScanner:= GetProcAddress(GraphicScannerHandle, 'DrawGraphicScanner');
   except
     FreeLibrary(GraphicScannerHandle);
     GraphicScannerHandle:= 0;
   end;
   if GraphicScannerHandle>0 then
     InitGraphicScanner(0, 0, 40, 35);
   //
   StartError:= 3;
   ReadParam;
   UpdateParamListBox;
   //
   StartError:= 4;
   TheKSBParam.LoadFromFile(ReadPath()+Application.Title+'.ini');
   //
   StartError:= 5;
   if not FileExists(ReadPath() + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice])) then
     FileClose(FileCreate(ReadPath() + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice])));
   //
   WriteLog('Старт модуля (вер. ' + ShowVersion (Application.ExeName) + ')');
   StatusBar1.Panels.Items[0].Text:= Format('Net=%d Big=%d Версия %s  ', [ rub.NetDevice, rub.BigDevice, ShowVersion(Application.ExeName) ] );
   StatusBar1.Panels.Items[1].Text:= Format('БЦП №%d', [ rub.Addr ]);
   StatusBar2.Panels[0].Text:='0';
   StatusBar2.Panels[1].Text:='0';
   msRead:= TMemoryStream.Create;
   //
   StartError:= 6;
   InitBCPComm;
   rub.Start;
   //
   StartError:= 7;
   InitSCUComm;
   //
   CheckDrv:= TCheckDrv.Create(False);
   StartError:= 8;
   //
   left:= option.left;
   top:= option.top;
   width:= option.width;
   height:= option.height;
   //
 EXCEPT
   On E: Exception do
   begin
     case StartError of
       1: s:= 'Ошибка вызова TaMainKsb.FormCreate';
       2: s:= 'Ошибка №2 чтения файла Setting.ini';
       3: s:= 'Ошибка №3 чтения файла Setting.ini';
       4: s:= 'Ошибка чтения файла ' + Format('NET%uBIG%u.ini',[rub.NetDevice, rub.BigDevice]);
       5: s:= 'Ошибка чтения файла ' + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice]);
       6: s:= 'Ошибка инициализации связи с БЦП';
       7: s:= 'Ошибка инициализации связи с СКУ-02';
       8: s:= 'Ошибка чтения файла ' + Format('NET%uBIG%u.r8m',[rub.NetDevice, rub.BigDevice]);
       else s:= '';
     end;
     WriteLog( Format( 'Останов модуля!!! %s (%s)', [s, E.Message] ) );
     PostMessage(Handle, WM_QUIT, 0, 0);
   end;
 END;

 //
 TRY
   TimerVisible.Enabled:= False;
   RWTimer.Enabled:= True;
   AnyTimer.Enabled:= True;
   ZoneOperationTimer.Enabled:= True;
   TimerVisible.Enabled:= True;
   TimerVisible.Enabled:= True;
 EXCEPT
   On E: Exception do
   begin
     WriteLog( Format( 'Останов модуля на старте!!! %s (%s)', [s, E.Message] ) );
     PostMessage(Handle, WM_QUIT, 0, 0);
   end;
 END;
end;


procedure TaMain.ReadParam;
var
 i: word;
begin
 Debug('F:ReadParam');
 option.BCPLineSpeed:= strtoint (getkey('BCPLineSpeed','20'));
 RWTimer.Interval:= option.BCPLineSpeed;
 option.SCULineSpeed:= strtoint (getkey('SCULineSpeed','5'));
 option.SyncTime:= strtoint( getkey('SyncTime','3600') );
 option.RstTCTime:= strtoint( getkey('RstTCTime','0') );
 option.NReadyOnCheck:= strtoint(getkey('NREADYONCHECK','1'))=1;
 option.SendOldStateBlock:= strtoint (getkey('SENDOLDSTATEBLOCK','0'))=1;
 option.ForceSendStateBlockMinute:= strtoint (getkey('FORCESENDSTATEBLOCKMINUTE','0'));
 StatusBar1.Panels.Items[2].Text:=GetKey('FINDING','Местоположение...');
 option.SCUPort:= strtoint (getkey('SCUPort','50101'));
 option.SaveR8hSecInterval:= strtoint (getkey('SaveR8hSecInterval','30'));
 if not option.SaveR8hSecInterval in [1..60] then option.SaveR8hSecInterval:=30;

 option.UC:= getkey('UC','empty');
 option.left:= strtoint (getkey('POS_LEFT','0'));
 option.top:= strtoint (getkey('POS_TOP','0'));
 option.width:= strtoint (getkey('POS_WIDTH','313'));
 option.height:= strtoint (getkey('POS_HEIGHT','450'));
 //
 option.SysScanner:= strtoint(getkey('SysScanner','0'))=1;
 if GraphicScannerHandle>0 then
   ViewGraphicScanner(option.SysScanner);
 TabSheet1.TabVisible := strtoint(getkey('SysTab','0'))=1;
 option.LogForm:= strtoint(getkey('LogForm','0'))=1;
 option.LogFile:= strtoint(getkey('LogFile','1'))=1;
 option.Mode:= getkey('Mode','');
 option.ZoneOperationSecInterval:= strtoint (getkey('ZoneOperationSecInterval','0'));
 option.DebugVar:= getkey('DebugVar','');
 option.BCPPass:= strtoint(getkey('BCPPass','0'))=1;
 option.FastStart:= strtoint(getkey('FastStart','0'))=1;

 //
 if getkey('Mode','')<>'ROSTVSP' then
 if TreeView1.Items.Count>0 then
 for i:=0 to TreeView1.Items.Count-1 do
 if TreeView1.Items.Item[i].Text='СКУ' then
 begin
   TreeView1.Items.Item[i].Delete;
   break;
 end;
 //
 option.Logged_Debug:= strtoint(getkey('Logged_Debug','0'));
 option.Logged_InKSBMES:= strtoint(getkey('Logged_InKSBMES','0'))=1;
 option.Logged_OutKSBMES:= strtoint(getkey('Logged_OutKSBMES','0'))=1;
 option.Logged_Delay:= strtoint(getkey('Logged_Delay','0'))=1;
 option.Logged_OnReadBCP:= strtoint(getkey('Logged_OnReadBCP','0'))=1;
 option.Logged_OnReadBCPTel:= strtoint(getkey('Logged_OnReadBCPTel','0'))=1;
 option.Logged_OnReadBCPStateDebug:= strtoint(getkey('Logged_OnReadBCPStateDebug','0'))=1;
 option.Logged_OnReadBCPCalculateStateZone:= strtoint(getkey('Logged_OnReadBCPCalculateStateZone','0'))=1;
 option.Logged_OnExecBCPCmd:= strtoint(getkey('Logged_OnExecBCPCmd','0'))=1;
 option.Logged_OnWriteBCP:= strtoint(getkey('Logged_OnWriteBCP','0'))=1;
 option.Logged_OnReadSCU:= strtoint(getkey('Logged_OnReadSCU','0'))=1;
 option.Logged_OnWriteSCU:= strtoint(getkey('Logged_OnWriteSCU','0'))=1;
end;

procedure TaMain.UpdateParamListBox;
begin
 Debug('F:UpdateParamListBox');
with Option do
begin
 if memo2.Lines.Count>0 then
 memo2.Clear;
 memo2.Lines.Add('BCPLineSpeed = '+ IntToStr(BCPLineSpeed));
 memo2.Lines.Add('SCULineSpeed = '+ IntToStr(SCULineSpeed));
 memo2.Lines.Add('NReadyOnCheck = '+ IntToStr(byte(NReadyOnCheck)));
 memo2.Lines.Add('SyncTime = '+ IntToStr(SyncTime));
 memo2.Lines.Add('RstTCTime = '+ IntToStr(RstTCTime));
 memo2.Lines.Add('SendOldStateBlock = '+ IntToStr(byte(SendOldStateBlock)));
 memo2.Lines.Add('ForceSendStateBlockMinute = '+ IntToStr(ForceSendStateBlockMinute));
 memo2.Lines.Add('SCUPort = '+ IntToStr(SCUPort ));
 memo2.Lines.Add('SaveR8hSecInterval = '+ IntToStr(SaveR8hSecInterval ));
 memo2.Lines.Add('UC = '+ UC);
 memo2.Lines.Add('SysScanner = '+ IntToStr(byte(SysScanner)));
 memo2.Lines.Add('SysTab = '+ IntToStr(byte(TabSheet1.TabVisible)));
 //
 memo2.Lines.Add('LogForm = '+ IntToStr(byte(LogForm)));
 memo2.Lines.Add('LogFile = '+ IntToStr(byte(LogFile)));
 memo2.Lines.Add('Mode = '+ Mode);
 memo2.Lines.Add('ZoneOperationSecInterval = '+ IntToStr(ZoneOperationSecInterval));
 memo2.Lines.Add('DebugVar = '+ DebugVar);
 memo2.Lines.Add('BCPPass = '+ IntToStr(byte(BCPPass)));
 memo2.Lines.Add('FastStart = '+ IntToStr(byte(FastStart)));
 //
 memo2.Lines.Add('Logged_Debug = '+ IntToStr(Logged_Debug));
 memo2.Lines.Add('Logged_InKSBMES = '+ IntToStr(byte(Logged_InKSBMES)));
 memo2.Lines.Add('Logged_OutKSBMES = '+ IntToStr(byte(Logged_OutKSBMES))); 
 memo2.Lines.Add('Logged_Delay = '+ IntToStr(byte(Logged_Delay)));
 memo2.Lines.Add('Logged_OnReadBCP = '+ IntToStr(byte(Logged_OnReadBCP)));
 memo2.Lines.Add('Logged_OnReadBCPTel = '+ IntToStr(byte(Logged_OnReadBCPTel)));
 memo2.Lines.Add('Logged_OnReadBCPStateDebug = '+ IntToStr(byte(Logged_OnReadBCPStateDebug)));
 memo2.Lines.Add('Logged_OnReadBCPCalculateStateZone = '+ IntToStr(byte(Logged_OnReadBCPCalculateStateZone)));
 memo2.Lines.Add('Logged_OnExecBCPCmd = '+ IntToStr(byte(Logged_OnExecBCPCmd)));
 memo2.Lines.Add('Logged_OnWriteBCP = '+ IntToStr(byte(Logged_OnWriteBCP)));
 memo2.Lines.Add('Logged_OnReadSCU = '+ IntToStr(byte(Logged_OnReadSCU)));
 memo2.Lines.Add('Logged_OnWriteSCU = '+ IntToStr(byte(Logged_OnWriteSCU)));
end;
end;

procedure Init (var mes: KSBMES);
begin
  FillChar(mes, sizeof(KSBMES), 0);
  mes.VerMinor:=$AA;
  mes.VerMajor:=$55;
  mes.SendTime:=Now();
  mes.WriteTime:=Now();
  mes.TypeDevice:=$FFFF;
  mes.NumDevice:=$FFFF;
  mes.Proga:=$FFFF;
  mes.ElementId:=$FFFFFFFF;
end;


procedure TaMain.Send(mes: KSBMES; str: PChar);

procedure LogOutKSBMES(var mes: KSBMES; var str: PChar);
var
  st: string;
begin
 if (option.Logged_OutKSBMES) then
 begin
   st:= Format('SEND: Code=%d Sys=%d Type=%d Net=%d Big=%d Small=%d Mode=%d Part=%d Lev=%d Us=%d Card=%d Mon=%d Cam=%d' ,
     [
     mes.Code,
     mes.SysDevice,
     mes.TypeDevice,
     mes.NetDevice,
     mes.BigDevice,
     mes.SmallDevice,
     mes.Mode,
     mes.Partion,
     mes.Level,
     mes.User,
     mes.NumCard,
     mes.Monitor,
     mes.Camera
     ]);
   if mes.Size > 0 then
     st:= st + Format(' str(%d)=%s', [ mes.Size, Bin2Simbol(str, mes.Size) ]);
   Log(st);
 end;
end;

begin
  {
  if option.BCPPass then
  begin
    if ApplyPassRule(mes) then
    if ApplyAnyRule(mes, str) then
    begin
      LogOutKSBMES(mes, str);
      inherited;
    end;
  end
  else
  begin
    LogOutKSBMES(mes, str);
    inherited;
  end;
  }
  if ApplyPassRule(mes) then
  if ApplyAnyRule(mes, str) then
  begin
    LogOutKSBMES(mes, str);
    inherited;
  end;

  //
  if PassPermitEvent(mes, str) then
  begin
    LogOutKSBMES(mes, str);
    inherited;
  end;
end;


procedure TaMain.Send(mes: KSBMES);
begin
  Send(mes, '');
end;



//-----------------------------------------------------------------------------
procedure TaMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 if MessageBox(0, 'Завершить работу ?', 'Внимание', MB_OKCANCEL or MB_DEFBUTTON2 or MB_TASKMODAL or MB_ICONQUESTION) <> IDOK then
 begin
   CanClose:= false;
   exit;
 end;
 try
   setkey('POS_LEFT', left);
   setkey('POS_TOP', top);
   setkey('POS_WIDTH', width);
   setkey('POS_HEIGHT', height);
 except
   MessageBox(0, 'Exception B3E61-6F1E-45A5-9686-F048E018F045', 'Внимание', MB_OK);
 end;
 {
 if rub<>nil then
 if rub.WorkTime then
   rub.WriteBcpFile;
 }
 inherited;
end;

procedure TaMain.TimerStopTimer(Sender: TObject);
begin
 WriteLog('Останов модуля');
 inherited;
end;

//-----------------------------------------------------------------------------
procedure TaMain.DrvErrorReport(code, param, cause, value: word);
var
 mes : KSBMES;
 data: PChar;
 st: string;

begin
 Debug('F:DrvErrorReport');
 data:='';
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=rub.NetDevice;
 mes.BigDevice:=rub.BigDevice;
 mes.TypeDevice:=4; //панель
 mes.SmallDevice:=0;

 case param of
   4..14:
   begin
     st:= Format('Драйвер отклонил команду (%d). ', [code] );
   end;
   20:
   begin
     st:= st + Format('Команда управления зоной не выполнена %d', [code]);
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', value);
   end;
   21: st:= st + Format('Команда управления ТС не выполнена %d', [code]);
   22:
   begin
     st:= st + 'Команда управления БЦП не выполнена';
   end;
 end;

 case param of
   4: st:= 'Панель';
   5:
   begin
     st:= st + 'ШС';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', value);
   end;
   6:
   begin
     st:= st + 'Зона';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', value);
   end;
   7:
   begin
     st:= st + 'Реле';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', value);
   end;
   8:
   begin
     st:= st + 'Терминал';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', value);
   end;
   9:
   begin
     st:= st + 'СУ';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', value);
   end;
   10:
   begin
     st:= st + 'Пользователь';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', value);
   end;
   11: st:= st + 'Время';
   12: st:= st + 'Временная зона';
   13:
   begin
     st:= st + 'ТД';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', value);
   end;
   14:
   begin
     st:= st + 'УД';
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер УД', value);
   end;
 end;

 case param of
   4..14,
   20..21:
     st:=st+' №'+inttostr(value);
 end;

 case cause of
  1: st:= st + ' не найден(а,о)';
  2: st:= st + ' уже существует';
  3: st:= st + ' с неверным номером';
  4: st:= st + '. '+ DescriptionBCPRetCode(code);
 end;

 Log('SEND: ' + st);
 TheKSBParam.WriteIntegerParam(mes, data, 'Код сообщения', code);
 TheKSBParam.WriteIntegerParam(mes, data, 'Код параметра', param);
 TheKSBParam.WriteIntegerParam(mes, data, 'Код причины', cause);
 TheKSBParam.WriteIntegerParam(mes, data, 'Значение параметра', value);
 mes.Code:= R8_BAD_ARG_IN_ROSTEK_CMD;
 send(mes);
end;


procedure TaMain.DrvErrorReportForServerRubeg (code, user, card: word);
var
 mes : KSBMES;
 data: PChar;

begin
 Log(Format('SEND: Отчет в ServerRubeg об ошибке (code=%d, user=%d, card=%d)', [code, user, card]));
 Debug('F:DrvErrorReportForServerRubeg');
 data:='';
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=rub.NetDevice;
 mes.BigDevice:=rub.BigDevice;
 mes.TypeDevice:=4; //панель
 mes.SmallDevice:=0;
 //
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер сообщения', code);
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', user);
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер карты', card);
 mes.Code:=R8_BAD_ARG_IN_USER_CMD;
 send(mes);
end;

//------------------- Приход и буферизация сообщения --------------------------
procedure TaMain.Consider(mes: KSBMES; str: string);
var
 v :^TMesRec;
 st: String;
begin
 Debug('F:Consider');
 //отсекание своих сообщений
// if (mes.NetDevice=ModuleNetDevice)and
//    (mes.Proga=NumberApplication)and


 //Log(Format('Consider_1 (mes=%d)', [mes.Code] ));  //???
 //отсекание чужих сообщений
 case mes.Code of
 6002..6003,
 9000..9999:
   if ((mes.NetDevice=0)and
       (mes.BigDevice=0))or
      ((mes.NetDevice=rub.NetDevice)and
       (mes.BigDevice=rub.BigDevice)and
       (mes.Proga<>NumberApplication)) then
      else exit;
 else
   begin
     inherited Consider(mes, str);
     exit;
   end;
 end;//case
 //
 //Log(Format('Consider_2 (mes=%d comd=%d)', [mes.Code, rub.comd] ));  //???
 //Log(Format('Consider_3 (mes=%d)', [mes.Code] ));  //???
 //протокол вх. KSBMES
 if (option.Logged_InKSBMES) then
 begin
  st:= Format('READ: Code=%d Sys=%d Type=%d Net=%d Big=%d Small=%d Mode=%d Part=%d Lev=%d Us=%d Card=%d Mon=%d Cam=%d Prog=%d' ,
    [
    mes.Code,
    mes.SysDevice,
    mes.TypeDevice,
    mes.NetDevice,
    mes.BigDevice,
    mes.SmallDevice,
    mes.Mode,
    mes.Partion,
    mes.Level,
    mes.User,
    mes.NumCard,
    mes.Monitor,
    mes.Camera,
    mes.Proga
    ]);
   if mes.Size > 0 then
     st:= st + Format(' str(%d)=%s', [ mes.Size, str ]);
   Log(st);
 end;

 if CheckBox1.Checked then
 begin
   Log('Игнорирование вх.сообщения ...');
   exit;
 end;
 //добавление сообщения в буфер
 new(v);
 move(mes, v^.m , sizeof(KSBMES));
 v^.s:= str;
 CommonMesBuf.Add(v);
end;


//---------- Обработка сообщения из буфера ------------------------------------
procedure TaMain.ConsiderBCP(mes: KSBMES; str: string);
var
 ptc: PTTC;
 pcu: PTCU;
 pzn: PTZN;
 pgr: PTGR;
 pus: PTUS;
 l: array[0..{127}16386]  of BYTE; /// размер для УД ???
 i, j: word;
 data: PChar;
 ar: array [1..1000] of byte;

 total : int64;//longword;

 cu, gr, sh, ap, zn, rel, us, tzn, ud, term: word;
 stm: TDateTime;

begin
 Debug('F:ConsiderBCP');
 GlobalTempMes:= mes;
 //Log(Format('ConsiderBCP (mes=%d)', [mes.Code] ));  //???
 //
 data:= '';
 cu:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер СУ');
 gr:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер группы');
 sh:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер ШС');
 ap:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер ТД');
 zn:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер зоны');
 rel:=TheKSBParam.ReadIntegerParam(mes, data, 'Номер реле');
 us:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер пользователя');
 tzn:=TheKSBParam.ReadIntegerParam(mes, data, 'Номер ВЗ');
 ud:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер УД');
 stm:=TheKSBParam.ReadDoubleParam (mes, data, 'Время');
 term:= TheKSBParam.ReadIntegerParam(mes, data, 'Номер терминала');

 CASE mes.Code of
    R8_COMMAND_PANEL_REFRESH:
      if ((mes.NetDevice=0)and(mes.BigDevice=0)) or
         ((mes.NetDevice=rub.NetDevice)and(mes.BigDevice=rub.BigDevice)) then
         begin
           Log( Format('Выполняется команда (%d): Запрос состояний БЦП, СУ, ТС', [mes.Code]) );
           BlockStateToVU;
         end;

    R8_COMMAND_SH_ARM:
    begin
      Log(Format('Выполняется команда (%d): Поставить на охрану ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil
        then mTCControl (ptc^.Sernum, us, TC_ALARM_ARM)
        else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_SH_DISARM:
    begin
      Log(Format('Выполняется команда (%d): Снять с охраны ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_ALARM_DISARM)
      else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_SH_BYPASS:
    begin
      Log(Format('Выполняется команда (%d): Пропустить ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_ALARM_DISARM)
      else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_SH_RESET:
    begin
      Log(Format('Выполняется команда (%d): Сбросить ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil
      then
        case ptc^.Kind of
          1: mTCControl (ptc^.Sernum, us, TC_ALARM_DISARM);
          2: mTCControl (ptc^.Sernum, us, TC_PANIC_RESETTRAIN);
          3: mTCControl (ptc^.Sernum, us, TC_FIRE_RESETTRAIN);
          else aMain.Log('Critical logic 04C28D78-RRWF-42DE-8CBA-A3C8C5FFGG02');
        end
      else
        DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_SH_TEST:
    begin
      Log(Format('Выполняется команда (%d): Проверка ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_PANIC_TEST)
      else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_SH_RESTORE:
    begin
      Log(Format('Выполняется команда (%d): Восстановить ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:= rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_RESTORE)
      else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_RELAY_RESTORE:
    begin
      Log(Format('Выполняется команда (%d): Восстановить реле №%d', [mes.Code, mes.SmallDevice]));
      ptc:= rub.FindTC(mes.SmallDevice, 4);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_RESTORE)
      else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_AP_RESTORE:
    begin
      Log(Format('Выполняется команда (%d): Восстановить ТД №%d', [mes.Code, mes.SmallDevice]));
      ptc:= rub.FindTC(mes.SmallDevice, 9);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_RESTORE)
      else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_TERM_RESTORE:
    begin
      Log(Format('Выполняется команда (%d): Восстановить терм. №%d', [mes.Code, mes.SmallDevice]));
      ptc:= rub.FindTC(mes.SmallDevice, 7);
      if ptc<>nil
        then mTCControl (ptc^.Sernum, us, TC_RESTORE)
        else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_TERM_BLOCK:
    begin
      Log(Format('Выполняется команда (%d): Заблокировать терм. №%d', [mes.Code, mes.SmallDevice]));
      ptc:= rub.FindTC(mes.SmallDevice, 7);
      if ptc<>nil
        then mTCControl (ptc^.Sernum, us, TC_TERMINAL_BLOCK)
        else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_TERM_RESET:
    begin
      Log(Format('Выполняется команда (%d): Сбросить терм. №%d', [mes.Code, mes.SmallDevice]));
      ptc:= rub.FindTC(mes.SmallDevice, 7);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_TERMINAL_RESET)
      else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_SH_OFF:
    begin
      Log(Format('Выполняется команда (%d): Отключить ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil then
      mChangeTC
         (
          ptc^.Sernum,
          ptc^.Kind,
          ptc^.BCPNumber,
          ptc^.StringPointer,
          ptc^.Flags and $f7,
          ptc^.ParentZone,
          ptc^.Group,
          ptc^.HWType,
          ptc^.HWSerial ,
          ptc^.ElementHW,
          ptc^.ConfigDummy,
          ptc^.RestoreTime, // Время восст.
          0, // используется в ответах +84 на создание
          0, // используется в ответах +84 на создание
         )
          else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_SH_ON:
    begin
      Log(Format('Выполняется команда (%d): Подключить ШС №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 3);
      if ptc<>nil then
      mChangeTC
          (
           ptc^.Sernum,
           ptc^.Kind,
           ptc^.BCPNumber,
           ptc^.StringPointer,
           ptc^.Flags or 8,
           ptc^.ParentZone,
           ptc^.Group,
           ptc^.HWType,
           ptc^.HWSerial ,
           ptc^.ElementHW,
           ptc^.ConfigDummy,
           ptc^.RestoreTime, // Время восст.
           0, // используется в ответах +84 на создание
           0, // используется в ответах +84 на создание
          )
           else DrvErrorReport(mes.Code, 5, 1, mes.SmallDevice);
    end;

    R8_COMMAND_RELAY_OFF:
    begin
      Log(Format('Выполняется команда (%d): Отключить реле №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 4);
      if ptc<>nil then
      mChangeTC
         (
          ptc^.Sernum,
          ptc^.Kind,
          ptc^.BCPNumber,
          ptc^.StringPointer,
          ptc^.Flags and $f7,
          ptc^.ParentZone,
          ptc^.Group,
          ptc^.HWType,
          ptc^.HWSerial ,
          ptc^.ElementHW,
          ptc^.ConfigDummy,
          ptc^.RestoreTime, // Время восст.
          0, // используется в ответах +84 на создание
          0, // используется в ответах +84 на создание
         )
          else DrvErrorReport(mes.Code, 7, 1, mes.SmallDevice);
    end;

    R8_COMMAND_RELAY_ON:
    begin
      Log(Format('Выполняется команда (%d): Подключить реле №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 4);
      if ptc<>nil then
      mChangeTC
          (
           ptc^.Sernum,
           ptc^.Kind,
           ptc^.BCPNumber,
           ptc^.StringPointer,
           ptc^.Flags or 8,
           ptc^.ParentZone,
           ptc^.Group,
           ptc^.HWType,
           ptc^.HWSerial ,
           ptc^.ElementHW,
           ptc^.ConfigDummy,
           ptc^.RestoreTime, // Время восст.
           0, // используется в ответах +84 на создание
           0, // используется в ответах +84 на создание
          )
           else DrvErrorReport(mes.Code, 7, 1, mes.SmallDevice);
    end;

    R8_COMMAND_AP_OFF:
    begin
      Log(Format('Выполняется команда (%d): Отключить ТД №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 9);
      if ptc<>nil then
      mChangeTC
         (
          ptc^.Sernum,
          ptc^.Kind,
          ptc^.BCPNumber,
          ptc^.StringPointer,
          ptc^.Flags and $f7,
          ptc^.ParentZone,
          ptc^.Group,
          ptc^.HWType,
          ptc^.HWSerial ,
          ptc^.ElementHW,
          ptc^.ConfigDummy,
          ptc^.RestoreTime, // Время восст.
          0, // используется в ответах +84 на создание
          0, // используется в ответах +84 на создание
         )
          else DrvErrorReport(mes.Code, 13, 1, mes.SmallDevice);
    end;

    R8_COMMAND_AP_ON:
    begin
      Log(Format('Выполняется команда (%d): Подключить ТД №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 9);
      if ptc<>nil then
      mChangeTC
          (
           ptc^.Sernum,
           ptc^.Kind,
           ptc^.BCPNumber,
           ptc^.StringPointer,
           ptc^.Flags or 8,
           ptc^.ParentZone,
           ptc^.Group,
           ptc^.HWType,
           ptc^.HWSerial ,
           ptc^.ElementHW,
           ptc^.ConfigDummy,
           ptc^.RestoreTime, // Время восст.
           0, // используется в ответах +84 на создание
           0, // используется в ответах +84 на создание
          )
           else DrvErrorReport(mes.Code, 13, 1, mes.SmallDevice);
    end;


    R8_COMMAND_TERM_OFF:
    begin
      Log(Format('Выполняется команда (%d): Отключить терм. №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 7);
      if ptc<>nil then
      mChangeTC
         (
          ptc^.Sernum,
          ptc^.Kind,
          ptc^.BCPNumber,
          ptc^.StringPointer,
          ptc^.Flags and $f7,
          ptc^.ParentZone,
          ptc^.Group,
          ptc^.HWType,
          ptc^.HWSerial ,
          ptc^.ElementHW,
          ptc^.ConfigDummy,
          ptc^.RestoreTime, // Время восст.
          0, // используется в ответах +84 на создание
          0, // используется в ответах +84 на создание
         )
          else DrvErrorReport(mes.Code, 8, 1, mes.SmallDevice);
    end;

    R8_COMMAND_TERM_ON:
    begin
      Log(Format('Выполняется команда (%d): Подключить терм. №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 7);
      if ptc<>nil then
      mChangeTC
          (
           ptc^.Sernum,
           ptc^.Kind,
           ptc^.BCPNumber,
           ptc^.StringPointer,
           ptc^.Flags or 8,
           ptc^.ParentZone,
           ptc^.Group,
           ptc^.HWType,
           ptc^.HWSerial ,
           ptc^.ElementHW,
           ptc^.ConfigDummy,
           ptc^.RestoreTime, // Время восст.
           0, // используется в ответах +84 на создание
           0, // используется в ответах +84 на создание
          )
           else DrvErrorReport(mes.Code, 8, 1, mes.SmallDevice);
    end;

    R8_COMMAND_ZONE_ARM:
     begin
      Log(Format('Выполняется команда (%d): Поставить на охрану зону №%d', [mes.Code, mes.SmallDevice]));
      {
      ptc:=rub.FindTC(mes.SmallDevice, 2);
      if ptc<>nil
      then mUpZone (ptc^.ParentZone, us, 1)
      else DrvErrorReport(mes.Code, 6, 1, mes.SmallDevice);
      }
      ar[1]:= lo(mes.SmallDevice);
      ar[2]:= hi(mes.SmallDevice);
      pzn:=rub.FindZN(ar[1], 1);
      if pzn<>nil
      then mUpZone (pzn^.BCPNumber, us, 1)
      else DrvErrorReport(mes.Code, 6, 1, mes.SmallDevice);
     end;

    R8_COMMAND_ZONE_DISARM:
    begin
      Log(Format('Выполняется команда (%d): Снять с охраны зону №%d', [mes.Code, mes.SmallDevice]));
      {
      ptc:=rub.FindTC(mes.SmallDevice, 2);
      if ptc<>nil
      then mDownZone (ptc^.ParentZone, us)
      else DrvErrorReport(mes.Code, 6, 1, mes.SmallDevice);
      }
      ar[1]:= lo(mes.SmallDevice);
      ar[2]:= hi(mes.SmallDevice);
      pzn:=rub.FindZN(ar[1], 1);
      if pzn<>nil
      then mDownZone (pzn^.BCPNumber, us)
      else DrvErrorReport(mes.Code, 6, 1, mes.SmallDevice);
    end;

    R8_COMMAND_RELAY_0:
    begin
      Log(Format('Выполняется команда (%d): Выключить реле №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 4);
      if ptc<>nil
        then mTCControl (ptc^.Sernum, us, TC_ED_OFF)
        else DrvErrorReport(mes.Code, 7, 1, mes.SmallDevice);
    end;

    R8_COMMAND_RELAY_1:
    begin
      Log(Format('Выполняется команда (%d): Включить реле №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 4);
      if ptc<>nil
        then mTCControl (ptc^.Sernum, us, TC_ED_ON)
        else DrvErrorReport(mes.Code, 7, 1, mes.SmallDevice);
    end;

    R8_COMMAND_AP_PASS:
    begin
      Log(Format('Выполняется команда (%d): Разрешить проход через ТД №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 9);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_AP_LOCKOPEN)
      else DrvErrorReport(mes.Code, 13, 1, mes.SmallDevice);
    end;

    R8_COMMAND_AP_LOCK:
    begin
      Log(Format('Выполняется команда (%d): Закрыть ТД №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 9);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_AP_BLOCK)
      else DrvErrorReport(mes.Code, 13, 1, mes.SmallDevice);
    end;

    R8_COMMAND_AP_UNLOCK:
    begin
      Log(Format('Выполняется команда (%d): Открыть ТД №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 9);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_AP_DEBLOCK)
      else DrvErrorReport(mes.Code, 13, 1, mes.SmallDevice);
    end;

    R8_COMMAND_AP_RESET:
    begin
      Log(Format('Выполняется команда (%d): Сбросить ТД №%d', [mes.Code, mes.SmallDevice]));
      ptc:=rub.FindTC(mes.SmallDevice, 9);
      if ptc<>nil
      then mTCControl (ptc^.Sernum, us, TC_AP_RESET)
      else DrvErrorReport(mes.Code, 13, 1, mes.SmallDevice);
    end;

    R8_COMMAND_CU_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать СУ №%d', [mes.Code, cu]));
      Simbol2Bin(str, @l[0], mes.Size);
      pcu:= rub.FindCU(cu, 1);
      if (pcu=nil)and(cu>0)and(cu<=CU_MAX)
        then mCreateCU(cu, l[3]+256*l[4], l[2],  16*l[0] + 64*(byte(l[1]=0)) + 8*(byte((l[1] and $2)>0)) + 3  , l[5])
        else DrvErrorReport(mes.Code, 9, 2, cu); // рубеж,  адрес СУ,  тип СУ,  флаг (1bit-адрес СУ,  2bit-вкл/выкл)
    end;

    R8_COMMAND_CU_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать СУ №%d', [mes.Code, cu]));
      Simbol2Bin(str, @l[0], mes.Size);
      pcu:=rub.FindCU(cu, 1);
      if (pcu<>nil)and(cu>0)
        then mChangeCU(cu, pcu^.HWSerial, pcu^.HWType,  16*l[0] + 64*(byte(l[1]=0)) + 8*(byte((l[1] and $2)>0)) + 3  , l[2])
        else DrvErrorReport(mes.Code, 9, 1, cu); // рубеж,  адрес СУ,  тип СУ,  флаг (1bit-адрес СУ,  2bit-вкл/выкл)
    end;

    R8_COMMAND_CU_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить СУ №%d', [mes.Code, cu]));
      pcu:=rub.FindCU(cu, 1);
      if (pcu<>nil)and(cu>0)
        then mDeleteCU(pcu^.HWSerial, pcu^.HWType, 0)
        else DrvErrorReport(mes.Code, 9, 1, cu);      // рубеж,  адрес СУ,  тип СУ)
    end;

    R8_COMMAND_CU_ALL_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить все СУ', [mes.Code]));
      mDeleteCUs;
    end;

    R8_COMMAND_CU_CONFIG:
    begin
      Log(Format('Выполняется команда (%d): Запрос конфигурации СУ №%d', [mes.Code, cu]));
      pcu:=rub.FindCU(cu, 1);
      if (pcu=nil) then
      begin
        DrvErrorReport(mes.Code, 9, 1, cu);
        exit;
      end;
      Log(Format('SEND: Конфигурация СУ №%d', [cu]));
      FillChar(l,128,0);
      Init(mes);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.SmallDevice:=0;
      mes.TypeDevice:=4;
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер СУ', pcu^.Number);
      mes.Size:=(5+8);
      l[0]:=(pcu^.flags shr 4) and 1;
      if (pcu^.flags and $40)=0 then
        if (pcu^.flags and $08)=0
          then l[1]:=1
          else l[1]:=2;
      {
      l[1]:=((pcu^.flags shr 3) and 1);
      if ((pcu^.flags shr 6) and 1)>0 then
        l[1]:= 0;
      }
      l[2]:= pcu^.HWType;
      l[3]:= lo(pcu^.HWSerial);
      l[4]:= hi(pcu^.HWSerial);
      move(pcu^.ConfigDummy, l[5], 8);
      mes.Code:= R8_CU_CONFIG;
      aMain.Send(mes,PChar(@l[0]));
    end;

    R8_COMMAND_ZONE_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать зону №%d', [mes.Code, zn]));
      Simbol2Bin(str, @l[0], mes.Size); // l[0]..l[3]-номер зоны, l[4]-вид, l[5]-статус
      mCreateZone(l[0], l[4], l[5], l[6], zn)
      {l[7]:=lo(zn);
      l[8]:=hi(zn); }
      {
      pzn:=rub.FindZN(l[7], 1);
      if (pzn=nil)and(zn>0)and(zn<=ZN_MAX)
        then mCreateZone(l[0], l[4], l[5], l[6], zn)
        else if zn>0
         then DrvErrorReport(mes.Code, 6, 2, zn)
         else DrvErrorReport(mes.Code, 6, 3, zn);
      }
    end;

    R8_COMMAND_ZONE_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать зону №%d', [mes.Code, zn]));
      Simbol2Bin(str, @l[0], mes.Size); // l[0]-вид, l[1]-статус,
      l[3]:=lo(zn);
      l[4]:=hi(zn);
      pzn:=rub.FindZN(l[3], 1);
      if (pzn<>nil)and(zn>0)and(zn<=ZN_MAX)
        then mChangeZone(pzn^.BCPNumber, l[0], l[1], l[2], zn)
        else DrvErrorReport(mes.Code, 6, 1, zn);
    end;

    R8_COMMAND_ZONE_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить зону №%d', [mes.Code, zn]));
      l[0]:=lo(zn);
      l[1]:=hi(zn);
      pzn:=rub.FindZN(l[0], 1);
      if (pzn<>nil)and(zn>0)
        then mDeleteZone (pzn^.BCPNumber, 0)
        else DrvErrorReport(mes.Code, 6, 1, zn);
    end;

    R8_COMMAND_ZONE_ALL_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить все зоны', [mes.Code]));
      mDeleteZones;
    end;

    R8_COMMAND_ZONE_NAME_DELETE:
    begin
      Simbol2Bin(str, @l[0], mes.Size); // l[0]..l[3]-номер зоны
      mDeleteZone (l[0], 0);
    end;

    R8_COMMAND_ZONE_CONFIG:
    begin
      Log(Format('Выполняется команда (%d): Запрос конфигурации зоны №%d', [mes.Code, zn]));
      l[0]:=lo(zn);
      l[1]:=hi(zn);
      pzn:=rub.FindZN(l[0], 1);
      if (pzn=nil)and(zn=0) then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      FillChar(l,128,0);
      Init(mes);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.SmallDevice:=0;
      mes.TypeDevice:=4;
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер зоны', pzn^.Number);
      mes.Size:=6;
      move(pzn^.BCPNumber, l[0], 4);
      l[4]:=pzn^.Flags;
      l[5]:=pzn^.Status;
      mes.Code:=R8_ZONE_CONFIG;
      aMain.Send(mes,PChar(@l[0]));
    end;

    R8_COMMAND_GR_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать группу №%d', [mes.Code, gr]));
      Simbol2Bin(str, @l[0], mes.Size);
      pgr:= rub.FindGR(gr);
      if (pgr=nil) then
        mCreateGR(gr, l[0]);
    end;

    R8_COMMAND_GR_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать группу №%d', [mes.Code, gr]));
      Simbol2Bin(str, @l[0], mes.Size);
      pgr:= rub.FindGR(gr);
      if (pgr<>nil) then
        mChangeGR(gr, l[0]);
    end;

    R8_COMMAND_GR_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить группу №%d', [mes.Code, gr]));
      pgr:= rub.FindGR(gr);
      if (pgr<>nil) then
        mDeleteGR(gr);
    end;

    R8_COMMAND_GR_DELETE_ALL:
    begin
      Log(Format('Выполняется команда (%d): Удалить все группы', [mes.Code]));
      mDeleteGRs;
    end;

    R8_COMMAND_GR_GET:
    begin
      Log(Format('Выполняется команда (%d): Запрос конфигурации группы №%d', [mes.Code, gr]));
      pgr:= rub.FindGR(gr);
      if (pgr<>nil) then
        mGetGR(gr);
    end;

    R8_COMMAND_SH_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать ШС №%d', [mes.Code, sh]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:= rub.FindTC(sh, 3);
      if (ptc<>nil)or(sh=0){or(sh>SH_MAX)} then
      begin
        DrvErrorReport(mes.Code, 5, 2, sh);
        exit;
      end;
      l[28]:=lo(zn);
      l[29]:=hi(zn);
      pzn:= rub.FindZN(l[28], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      //
      j:= NewIdTC;
      if j>0 then
        mCreateTC(
                      j,                 // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // №ТС (4байта),
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // №зоны (4байта),
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 15 байт
                      l[27],             // время восст.
                      sh,                // ШС
                      zn                 // зона
                  );
    end;


    R8_COMMAND_SH_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать ШС №%d', [mes.Code, sh]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:=rub.FindTC(sh, 3);
      if (ptc=nil)or(sh=0){or(sh>SH_MAX)} then
      begin
        DrvErrorReport(mes.Code, 5, 1, sh);
        exit;
      end;
      l[28]:=lo(zn);
      l[29]:=hi(zn);
      pzn:=rub.FindZN(l[28], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      mChangeTC(
                      ptc^.Sernum,       // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // №ТС (4байта),
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // номер зоны,
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 16 байт
                      l[27],             // время восст.
                      sh,                // зона-ШС
                      zn                 // зона
                );
    end;

    R8_COMMAND_SH_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить ШС №%d', [mes.Code, sh]));
      ptc:=rub.FindTC(sh, 3);
      if (ptc=nil)or(sh=0) then
      begin
        DrvErrorReport(mes.Code, 5, 1, sh);
        exit;
      end;
      mDeleteTC (ptc^.Sernum);
    end;

    R8_COMMAND_SH_SERNUM_DELETE:
    begin
      ptc:=rub.FindTC(sh, 0);
      if ptc=nil then
      begin
        DrvErrorReport(mes.Code, 5, 1, sh);
        exit;
      end;
      mDeleteTC (ptc^.Sernum);
    end;

    R8_COMMAND_SH_CONFIG:
    begin
      Log(Format('Выполняется команда (%d): Запрос конфигурации ШС №%d', [mes.Code, sh]));
      ptc:=rub.FindTC(sh, 3);
      if (ptc=nil)or(sh=0) then
      begin
        DrvErrorReport(mes.Code, 5, 1, sh);
        exit;
      end;
      Log(Format('SEND: Конфигурация ШС №%d', [sh]));
      FillChar(l,128,0);
      Init(mes);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.SmallDevice:=0;
      mes.TypeDevice:=4;
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер ШС',   ptc^.ZoneVista);
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер зоны', ptc^.PartVista);
      mes.Size:=28;
      move(ptc^.Kind,  l[0], 7);
      move(ptc^.Group, l[7], 21);
      mes.Code:=R8_SH_CONFIG;
      aMain.Send(mes,PChar(@l[0]));
    end;


    R8_COMMAND_RN_DELETE_ALL:
    begin
      Log(Format('Выполняется команда (%d): Удалить все названия', [mes.Code]));
      mDeleteRNs;
    end;

    R8_COMMAND_RP_DELETE_ALL:
    begin
      Log(Format('Выполняется команда (%d): Удалить все программы', [mes.Code]));
      mDeleteRPs;
    end;

    R8_COMMAND_HD_DELETE_ALL:
    begin
      Log(Format('Выполняется команда (%d): Удалить все праздники', [mes.Code]));
      mDeleteHDs;
    end;

    //==============================================================================
    R8_COMMAND_APSHZMK_SET:
    begin
      Simbol2Bin(str, @l[0], mes.Size);
      Log(Format('Выполняется команда (%d): Установить ШС №%d замка ТД №%d', [mes.Code, sh, mes.SmallDevice]) );
      //проверка параметров (sh, zn)
      if (sh=0) then
      begin
        DrvErrorReport(mes.Code, 5, 2, sh);
        exit;
      end;
      l[28]:=lo(zn);
      l[29]:=hi(zn);
      pzn:= rub.FindZN(l[28], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      //установка правила
      DelShZmkRule(mes.SmallDevice);
      SetShZmkRule(mes.SmallDevice, sh);
      //установка ШС
      j:= NewIdTC;
      if j>0 then
      begin
        ptc:= rub.FindTC(sh, 3);
        if ptc=nil
          then mCreateTC(
                      j,                 // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // №ТС (4байта),
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // №зоны (4байта),
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 15 байт
                      l[27],             // время восст.
                      sh,                // ШС
                      zn                 // зона
                      )
          else mChangeTC(
                      ptc^.Sernum,       // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // №ТС (4байта),
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // номер зоны,
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 16 байт
                      l[27],             // время восст.
                      sh,                // зона-ШС
                      zn                 // зона
                      );
      end;
    end;


    R8_COMMAND_APSHZMK_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить ШС №%d замка ТД №%d', [mes.Code, sh, mes.SmallDevice ]) );
      ptc:= rub.FindTC(sh, 3);
      if (ptc=nil)or(sh=0) then
      begin
        DrvErrorReport(mes.Code, 5, 1, sh);
        exit;
      end;
      mDeleteTC (ptc^.Sernum);
    end;

    //==============================================================================


    R8_COMMAND_RELAY_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать реле №%d', [mes.Code, rel]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:=rub.FindTC(rel, 4);
      if (ptc<>nil)or(rel=0){or(rel>RL_MAX)} then
      begin
        DrvErrorReport(mes.Code, 7, 2, rel);
        exit;
      end;
      l[28]:=lo(zn);
      l[29]:=hi(zn);
      pzn:=rub.FindZN(l[28], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      //
      j:= NewIdTC;
      if j>0 then
        mCreateTC(
                      j,                 // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // №ТС (4байта),
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // №зоны (4байта),
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 15 байт
                      l[27],             // время восст.
                      rel,               // реле
                      zn                 // зона
                    );
    end;

    R8_COMMAND_RELAY_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать реле №%d', [mes.Code, rel]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:=rub.FindTC(rel, 4);
      if (ptc=nil)or(rel=0){or(rel>RL_MAX)} then
      begin
        DrvErrorReport(mes.Code, 7, 1, rel);
        exit;
      end;
      l[28]:=lo(zn);
      l[29]:=hi(zn);
      pzn:=rub.FindZN(l[28], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      mChangeTC(
                      ptc^.Sernum,       // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // l[1]..l[4]-номер зоны,
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // номер зоны,
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 16 байт
                      l[27],             // время восст.
                      rel,               // реле
                      zn                 // зона
                 );
    end;

    R8_COMMAND_RELAY_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить реле №%d', [mes.Code, rel]));
      ptc:=rub.FindTC(rel, 4);
      if (ptc=nil)or(rel=0) then
      begin
        DrvErrorReport(mes.Code, 7, 1, rel);
        exit;
      end;
      mDeleteTC (ptc^.Sernum);
    end;

    R8_COMMAND_RELAY_CONFIG:
    begin
      Log(Format('Выполняется команда (%d): Запрос конфигурации реле №%d', [mes.Code, rel]));
      ptc:=rub.FindTC(rel, 4);
      if (ptc=nil)or(rel=0) then
      begin
        DrvErrorReport(mes.Code, 7, 1, rel);
        exit;
      end;
      Log(Format('SEND: Конфигурация реле №%d', [rel]));
      FillChar(l,128,0);
      Init(mes);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.SmallDevice:=0;
      mes.TypeDevice:=4;
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер реле', ptc^.ZoneVista);
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер зоны', ptc^.PartVista);
      mes.Size:=28;
      move(ptc^.Kind,  l[0], 7);
      move(ptc^.Group, l[7], 21);
      mes.Code:=R8_RELAY_CONFIG;
      aMain.Send(mes,PChar(@l[0]));
    end;


    R8_COMMAND_AP_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать ТД №%d', [mes.Code, ap]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:= rub.FindTC(ap, 9);
      if (ptc<>nil)or(ap=0){or(ap>AP_MAX)} then
      begin
        DrvErrorReport(mes.Code, 13, 2, ap);
        exit;
      end;
      l[mes.Size]:= lo(zn);
      l[mes.Size+1]:= hi(zn);
      pzn:= rub.FindZN(l[mes.Size], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      //
      j:= NewIdTC;
      if j>0 then
      begin
        mCreateTC(
                      j,                 // sernum
                      l[0],              // тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле, 6-ТД)
                      l[1],              // №ТС (4байта),
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // №зоны (4байта),
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 15 байт
                      l[27],             // время восст.
                      ap,                // ТД
                      zn                 // зона
                  );
        if l[28]>0 then
          SetAnyCardMode(ap, l[29]);
      end;
    end;


    R8_COMMAND_AP_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать ТД №%d', [mes.Code, ap]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:=rub.FindTC(ap, 9);
      if (ptc=nil)or(ap=0){or(ap>AP_MAX)} then
      begin
        DrvErrorReport(mes.Code, 13, 1, ap);
        exit;
      end;
      l[mes.Size]:=lo(zn);
      l[mes.Size+1]:=hi(zn);
      pzn:=rub.FindZN(l[mes.Size], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      mChangeTC(
                      ptc^.Sernum,       // sernum
                      6,                 // тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле, 6-ТД)
                      l[1],              // l[1]..l[4]-номер зоны,
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // номер зоны,
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 16 байт
                      l[27],             // время восст.
                      ap,                // зона-ТД
                      zn                 // зона
                );
    end;

    R8_COMMAND_AP_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить ТД №%d', [mes.Code, ap]));
      ptc:=rub.FindTC(ap, 9);
      if (ptc=nil)or(ap=0) then
      begin
        DrvErrorReport(mes.Code, 13, 1, ap);
        exit;
      end;
      mDeleteTC (ptc^.Sernum);
      DelAnyCardMode(ap);
    end;

    R8_COMMAND_AP_SERNUM_DELETE:
    begin
      ptc:=rub.FindTC(ap, 0);
      if ptc=nil then
      begin
        DrvErrorReport(mes.Code, 13, 1, ap);
        exit;
      end;
      mDeleteTC (ptc^.Sernum);
    end;

    R8_COMMAND_AP_CONFIG:
    begin
      Log(Format('Выполняется команда (%d): Запрос конфигурации ТД №%d', [mes.Code, ap]));
      ptc:=rub.FindTC(ap, 9);
      if (ptc=nil)or(ap=0) then
      begin
        DrvErrorReport(mes.Code, 13, 1, ap);
        exit;
      end;
      Log(Format('SEND: Конфигурация ТД №%d', [ap]));
      FillChar(l,128,0);
      Init(mes);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.SmallDevice:=0;
      mes.TypeDevice:=4;
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер ТД',   ptc^.ZoneVista);
      TheKSBParam.WriteDoubleParam(mes, data, 'Номер зоны', ptc^.PartVista);
      mes.Size:=28;
      move(ptc^.Kind,  l[0], 7);
      move(ptc^.Group, l[7], 21);
      mes.Code:=R8_AP_CONFIG;
      aMain.Send(mes,PChar(@l[0]));
    end;


    R8_COMMAND_TERM_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать терминал №%d', [mes.Code, term]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:=rub.FindTC(term, 7);
      if (ptc<>nil)or(term=0){or(term>TERM_MAX)} then
      begin
        DrvErrorReport(mes.Code, 8, 2, term);
        exit;
      end;
      l[28]:=lo(zn);
      l[29]:=hi(zn);
      pzn:=rub.FindZN(l[28], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      //
      j:= NewIdTC;
      if j>0 then
        mCreateTC(
                      j,                 // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // №ТС (4байта),
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // №зоны (4байта),
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 15 байт
                      l[27],             // время восст.
                      term,              // Терминал
                      zn                 // зона
                  );
    end;


    R8_COMMAND_TERM_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать терминал №%d', [mes.Code, term]));
      Simbol2Bin(str, @l[0], mes.Size);
      ptc:=rub.FindTC(term, 7);
      if (ptc=nil)or(term=0){or(term>TERM_MAX)} then
      begin
        DrvErrorReport(mes.Code, 8, 1, term);
        exit;
      end;
      l[28]:=lo(zn);
      l[29]:=hi(zn);
      pzn:=rub.FindZN(l[28], 1);
      if pzn=nil then
      begin
        DrvErrorReport(mes.Code, 6, 1, zn);
        exit;
      end;
      mChangeTC(
                      ptc^.Sernum,       // sernum
                      l[0],              // l[0]-тип (1-охранный, 2-тревожный, 3-пожарный, 5-реле)
                      l[1],              // l[1]..l[4]-номер зоны,
                      l[5],              // l[5]-имя указатель на строку
                      l[6],              // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
                      pzn^.BCPNumber,    // номер зоны,
                      l[7],              // l[7]-группа
                      l[8],              // l[8]-тип оборудования
                      l[9]+l[10]*256,    // l[9]-мл.байт серийный номер HW l[10]-ст.байт серийный номер HW
                      l[11],             // l[11]-номер элемента
                      l[12],             // l[12]-конф. массив = 16 байт
                      l[27],             // время восст.
                      term,              // Терминал
                      zn                 // зона
                );
    end;

    R8_COMMAND_TERM_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить терминал №%d', [mes.Code, term]));
      ptc:= rub.FindTC(term, 7);
      if (ptc=nil)or(term=0) then
      begin
        DrvErrorReport(mes.Code, 8, 1, term);
        exit;
      end;
      mDeleteTC (ptc^.Sernum);
    end;
    ///



    R8_COMMAND_USER_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать пользователя №%d', [mes.Code, us]));
      Simbol2Bin(str, @l[0], mes.Size);
      pus:= rub.FindUS(us);
      if (pus<>nil)or(us=0)or(us>=60000) then
      begin
        DrvErrorReportForServerRubeg(mes.Code, us, l[3]+256*l[4]);
        DrvErrorReport(mes.Code, 10, 2, us);
        exit;
      end;

      total:= PackTime(stm);
      if total<0 then
      begin
        DrvErrorReportForServerRubeg(mes.Code, us, l[3]+256*l[4]);
        DrvErrorReport(mes.Code, 11, 0, 0);
        exit;
      end;

      if (l[16]+256*l[17])>0 then
      begin
        pzn:= rub.FindZN(l[16], 1);
        if pzn<>nil then
        move(pzn^.BCPNumber, l[21], 4)
        else
        begin
          DrvErrorReportForServerRubeg(mes.Code, us, l[3]+256*l[4]);
          DrvErrorReport(mes.Code, 6, 1, l[16]+l[17]*256);
          exit;
        end;
      end
      else
      begin
        l[21]:=$AA;
        l[22]:=$AA;
        l[23]:=$AA;
        l[24]:=$00;
      end;

      mCreateUser
              (
               l[0],                                         //flags
               us,                                           //id
               l[1],                                         //0-user, 1-wieg
               l[2],                                         //8 байт код-touchmem (wieg)
               l[10]+256*l[11]+65536*l[12]+16777216*l[13],   //4 байт пинкод
               l[14],                                        //AL1
               l[15],                                        //checkrulesLevel
               l[21],                                        //4 байт userzone
               total,                                        //до какого времени можно управлять зоной
               l[18],                                        //ВЗ доступа к БЦП
               l[19],                                        //AL2
               l[20],                                        //управления охраной
               );
    end;

    R8_COMMAND_USER_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать пользователя №%d', [mes.Code, us]));
      Simbol2Bin(str, @l[0], mes.Size);
      pus:=rub.FindUS(us);
      if (pus=nil)or(us=0)or(us>60000) then
      begin
        DrvErrorReportForServerRubeg(mes.Code, us, l[3]+256*l[4]);
        DrvErrorReport(mes.Code, 10, 1, us);
        exit;
      end;

      total:= PackTime(stm);
      if total<0 then
      begin
        DrvErrorReportForServerRubeg(mes.Code, us, l[3]+256*l[4]);
        DrvErrorReport(mes.Code, 11, 0, 0);
        exit;
      end;

      if (l[16]+256*l[17])>0 then
      begin
        pzn:=rub.FindZN(l[16], 1);
        if pzn<>nil then move(pzn^.BCPNumber, l[21], 4)
        else
        begin
          DrvErrorReportForServerRubeg(mes.Code, us, l[3]+256*l[4]);
          DrvErrorReport(mes.Code, 6, 1, l[16]+l[17]*256);
          exit;
        end;
      end
      else
      begin
        l[21]:=$AA;
        l[22]:=$AA;
        l[23]:=$AA;
        l[24]:=$00;
      end;

      mChangeUser
              (
               l[0],                                         //flags
               us,                                           //id
               l[1],                                         //0-user, 1-wieg
               l[2],                                         //8 байт код-touchmem (wieg)
               l[10]+256*l[11]+65536*l[12]+16777216*l[13],   //4 байт пинкод
               l[14],                                        //AL1
               l[15],                                        //checkrulesLevel
               l[21],                                        //4 байт userzone
               total,                                        //до какого времени можно управлять зоной
               l[18],                                        //ВЗ доступа к БЦП
               l[19],                                        //AL2
               l[20],                                        //управления охраной
               );
    end;

    R8_COMMAND_USER_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить пользователя №%d', [mes.Code, us]));
      pus:=rub.FindUS(us);
      if (pus=nil) then
      begin
        DrvErrorReportForServerRubeg(mes.Code, us, 0);
        DrvErrorReport(mes.Code, 10, 1, us);
        exit;
      end;
      if (us=0)or(us>60000) then
      begin
        DrvErrorReportForServerRubeg(mes.Code, us, 0);
        DrvErrorReport(mes.Code, 10, 3, us);
        exit;
      end;
      mDeleteUser (us);
    end;

    R8_COMMAND_USER_ALL_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить всех пользователей', [mes.Code]));
      mDeleteUsers;
    end;

    R8_COMMAND_USER_APBRESET:
    begin
      Log(Format('Выполняется команда (%d): Сбросить APB пользователя №%d', [mes.Code, mes.SmallDevice]));
      pus:= rub.FindUS(mes.SmallDevice);
      if (pus<>nil)
        then mUserControl(mes.SmallDevice)
        else Log(Format('Для команды (%d) пользователь №%d не найден', [mes.Code, mes.SmallDevice]));
    end;

    R8_COMMAND_BCP_ALLUSERSETSTATE:
    begin
      Log(Format('Выполняется команда (%d): Сбросить APB всех пользователей', [mes.Code]));
      mBCPControl(ACTION_BCP_ALLUSERAPBRESET);
    end;

    SUD_ADD_CARD:
    begin
      Log(Format('Выполняется команда (%d): Добавить карту №%d', [mes.Code, us]));
      Simbol2Bin(str, @l[0], mes.Size);
      //
      if (l[16]+256*l[17])>0 then
      begin
        pzn:= rub.FindZN(l[16], 1);
        if pzn<>nil then
        move(pzn^.BCPNumber, l[21], 4);
      end
      else
      begin
        l[21]:=$AA;
        l[22]:=$AA;
        l[23]:=$AA;
        l[24]:=$00;
      end;
      //
      pus:= rub.FindUS(us);
      if (l[14]=0)and(l[19]=0) then
      begin
        Log(Format('Карта с 0 УД. Выполняется удаление карты №%d' , [mes.Code, us]));
        mDeleteUser (us);
      end
      else
      if (us>0)and(us<60000) then
      if (pus=nil)
        then mCreateUser
              (
               l[0],                                         //flags
               us,                                           //id
               l[1],                                         //0-user, 1-wieg
               l[2],                                         //8 байт код-touchmem (wieg)
               l[10]+256*l[11]+65536*l[12]+16777216*l[13],   //4 байт пинкод
               l[14],                                        //AL1
               l[15],                                        //checkrulesLevel
               l[21],                                        //4 байт userzone
               PackTime(stm),                                //до какого времени можно управлять зоной
               l[18],                                        //ВЗ доступа к БЦП
               l[19],                                        //AL2
               l[20],                                        //управления охраной
               )
        else mChangeUser
              (
               l[0],                                         //flags
               us,                                           //id
               l[1],                                         //0-user, 1-wieg
               l[2],                                         //8 байт код-touchmem (wieg)
               l[10]+256*l[11]+65536*l[12]+16777216*l[13],   //4 байт пинкод
               l[14],                                        //AL1
               l[15],                                        //checkrulesLevel
               l[21],                                        //4 байт userzone
               PackTime(stm),                                //до какого времени можно управлять зоной
               l[18],                                        //ВЗ доступа к БЦП
               l[19],                                        //AL2
               l[20],                                        //управления охраной
               );
    end;

    SUD_DEL_CARD:
    begin
      Log(Format('Выполняется команда (%d): Удалить карту №%d', [mes.Code, us]));
      if (us>0)and(us<60000) then
        mDeleteUser (us);
    end;

    R8_COMMAND_TZ_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать ВЗ №%d', [mes.Code, tzn]));
      Simbol2Bin(str, @l[0], mes.Size);
      for i:=1 to mes.Size div 6 do
      begin
        if i=1 then j:=1 else j:=2;
        mCreateChangeTimeInterval
                         (
                          $03,
                          tzn,                   // ВЗ
                          l[6*(i-1)+0],          // ВИ
                          l[6*(i-1)+1],          // нач. час
                          l[6*(i-1)+2],          // кон. час
                          l[6*(i-1)+3],          // нач. мин
                          l[6*(i-1)+4],          // кон. мин
                          l[6*(i-1)+5],          // карта дней недели
                          j);
      end;
    end;

    R8_COMMAND_TZ_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать ВЗ №%d', [mes.Code, tzn]));
      Simbol2Bin(str, @l[0], mes.Size);
      for i:=1 to mes.Size div 6 do
      begin
        if i=1 then j:=3 else j:=4;
        mCreateChangeTimeInterval
                         (
                          $03,
                          tzn,                   // ВЗ
                          l[6*(i-1)+0],          // ВИ
                          l[6*(i-1)+1],          // нач. час
                          l[6*(i-1)+2],          // кон. час
                          l[6*(i-1)+3],          // нач. мин
                          l[6*(i-1)+4],          // кон. мин
                          l[6*(i-1)+5],          // карта дней недели
                          j);
      end;
    end;

    R8_COMMAND_TZ_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить ВЗ №%d', [mes.Code, tzn]));
      mDeleteTimeInterval(tzn);
    end;

    R8_COMMAND_TZ_ALL_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить все ВЗ', [mes.Code]));
      mDeleteTimeIntervals;
    end;

    R8_COMMAND_HOLIDAY_EDIT:
    begin
      Log(Format('Выполняется команда (%d): Редактировать праздники', [mes.Code]));
      Simbol2Bin(str, @l[0], mes.Size);
      if mes.Size=32 then
        mSetHoliday (l[0]);
    end;


    R8_COMMAND_SETTIME: //l[0..1]-year, l[2]-
    begin
      Log(Format('Выполняется команда (%d): Установить время', [mes.Code]));
      mSetClock(PackTime(stm));
    end;

    R8_COMMAND_GETTIME:
    begin
      Log(Format('Выполняется команда (%d): Запрос времени', [mes.Code]));
      mGetClock();
    end;

    R8_COMMAND_UD_CREATE:
    begin
      Log(Format('Выполняется команда (%d): Создать УД №%d', [mes.Code, ud]));
      Simbol2Bin(str, @l[0], mes.Size);
      for i:=1 to mes.Size div 12 do
      begin
        if i=1 then j:=1 else j:=2;
        if (l[2]=0)and(l[3]=0) then
        begin
          ar[1]:=$AA;
          ar[2]:=$AA;
          ar[3]:=$AA;
          ar[4]:=$00;
        end
        else
        begin
          pzn:= rub.FindZN(l[12*(i-1)+2], 1);
          if pzn<>nil
            then move(pzn^.BCPNumber, ar[1], 4)
            else
            begin
              DrvErrorReport(mes.Code, 6, 1, l[12*(i-1)+2] + l[12*(i-1)+3]*256);
              exit;
            end;
        end;
        mCreateChangePravo
                         (
                          $03 + $08*byte(l[12*(i-1)+0]>0) + $10*byte(l[12*(i-1)+1]=0),
                          ud ,                     // AL
                          ar[1],                   // номер зоны
                          l[12*(i-1)+4],           // статус зоны
                          l[12*(i-1)+5],           // тип объекта ТС
                          l[12*(i-1)+6],           // группа ТС
                          l[12*(i-1)+7]+
                          l[12*(i-1)+8]*256+
                          l[12*(i-1)+9]*65536+
                          l[12*(i-1)+10]*16777216, // карта разрешений
                          l[12*(i-1)+11],          // ВЗ
                          j);
      end;//for i
    end;

    R8_COMMAND_UD_CHANGE:
    begin
      Log(Format('Выполняется команда (%d): Редактировать УД №%d', [mes.Code, ud]));
      Simbol2Bin(str, @l[0], mes.Size);
      for i:=1 to mes.Size div 12 do
      begin
        if i=1 then j:=3 else j:=4;
        if (l[2]=0)and(l[3]=0) then
        begin
          ar[1]:=$AA;
          ar[2]:=$AA;
          ar[3]:=$AA;
          ar[4]:=$00;
        end
        else
        begin
          pzn:= rub.FindZN(l[12*(i-1)+2], 1);
          if pzn<>nil
            then move(pzn^.BCPNumber, ar[1], 4)
            else
            begin
              DrvErrorReport(mes.Code, 6, 1, l[12*(i-1)+2] + l[12*(i-1)+3]*256);
              exit;
            end;
        end;
        mCreateChangePravo
                         (
                          $03 + $08*byte(l[12*(i-1)+0]>0) + $10*byte(l[12*(i-1)+1]=0),
                          ud ,                     // AL
                          ar[1],                   // номер зоны
                          l[12*(i-1)+4],           // статус зоны
                          l[12*(i-1)+5],           // тип объекта ТС
                          l[12*(i-1)+6],           // группа ТС
                          l[12*(i-1)+7]+
                          l[12*(i-1)+8]*256+
                          l[12*(i-1)+9]*65536+
                          l[12*(i-1)+10]*16777216, // карта разрешений
                          l[12*(i-1)+11],          // ВЗ
                          j);
      end;//for i
    end;

    R8_COMMAND_UD_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить УД №%d', [mes.Code, ud]));
      mDeletePravo(ud);
    end;

    R8_COMMAND_UD_ALL_DELETE:
    begin
      Log(Format('Выполняется команда (%d): Удалить все УД', [mes.Code]));
      mDeletePrava;
    end;

    R8_COMMAND_CLEAR:
     begin
       Log(Format('Выполняется команда (%d): Очистить всю конфигурацию БЦП', [mes.Code]));
       mDeleteCUs;
       mDeleteZones;
       mDeleteGRs;
       mDeleteUsers;
       mDeleteTimeIntervals;
       mDeleteRNs;
       mDeleteRPs;
       mDeleteHDs;
       mDeletePrava;     
     end;

    R8_COMMAND_CLEARSYSERROR:
    begin
      Log(Format('Выполняется команда (%d): Сброс системной ошибки БЦП', [mes.Code]));
      mBCPControl(ACTION_BCP_CLEARSYSERROR);
    end;

    R8_COMMAND_STARTCHECKCONFIG:
    begin
      Log(Format('Выполняется команда (%d): Проверка конфигурации БЦП', [mes.Code]));
      mBCPControl(ACTION_BCP_STARTCHECKCONFIG);
    end;

    R8_COMMAND_BCP_RESET:
    begin
      Log(Format('Выполняется команда (%d): Сросить БЦП', [mes.Code]));
      mBCPControl(ACTION_BCP_RESET);
    end;

    R8_COMMAND_BCP_CONSOLELOCK:
    begin
      Log(Format('Выполняется команда (%d): Выход из сеанса в БЦП', [mes.Code]));
      mBCPControl(ACTION_BCP_CONSOLELOCK);
    end;

    R8_COMMAND_BCP_CONSOLEUNLOCK:
    begin
      Log(Format('Выполняется команда (%d): Сеанс администратора в БЦП', [mes.Code]));
      mBCPControl(ACTION_BCP_CONSOLEUNLOCK);
    end;

    R8_COMMAND_BCP_DMQCLEARTCO:
    begin
      Log(Format('Выполняется команда (%d): Восстановление всех готовых ШС', [mes.Code]));
      mBCPControl(ACTION_BCP_DMQCLEARTCO);
    end;

    R8_COMMAND_BCP_DMQCLEARNND:
    begin
      Log(Format('Выполняется команда (%d): Восстановление всех готовых СУ', [mes.Code]));
      mBCPControl(ACTION_BCP_DMQCLEARNND);
    end;

    R8_COMMAND_BCP_VAR_ASSIGN:
    begin
      Log(Format('Выполняется команда (%d): Переменная [%d] = %d', [mes.Code, mes.Partion, mes.Level]));
      mSetVar(mes.Partion and $FF, mes.Level, 0);
    end;



  //Убрать else оператор !!!!!!
  //else Log('БЦП: Нет реализации mes.Code:'+inttostr(mes.Code));

 END;//case


end;


//-----------------------------------------------------------------------------
procedure TaMain.BlockStateToVU(BcpConnect: boolean=True; step: byte=0);
//
//
procedure SendBlockSHState(var Mes: KSBMES; MaxValue: word; var block: array of byte);
var
  i: byte;
begin
  for i:=0 to (MaxValue div (512*8)) do
  begin
    Mes.Level:= i+1;
    send(Mes, PChar(@block[i*512]));
  end;
end;

const
  BufSize = 8192;

var
 mes: KSBMES;
 l: array [0..BufSize-1] of BYTE;
 i: integer;
 p: ^TTC;
 pzn: ^TZN;
 pcu: ^TCU;
 Max: word;
 data: PChar;


begin
 Debug('F:BlockStateToVU');
 data:= '';
 with rub do
 begin

   Init(mes);
   mes.SysDevice:= SYSTEM_OPS;
   mes.NetDevice:= rub.NetDevice;
   mes.BigDevice:= rub.BigDevice;
   mes.TypeDevice:= 4; //панель
   // -----------------------------------

   sleep(1000);
   //
   if BcpConnect then
   begin
     case Online of
       1: mes.Code:= R8_CONNECT_TRUE;
       else mes.Code:= R8_CONNECT_FALSE;
     end;
     send(mes);
   end;
   if  mes.Code=R8_CONNECT_TRUE
     then Log('SEND: Связь с БЦП в норме')
     else Log('SEND: Связь с БЦП нарушена');


   sleep(1000);
   //
   if (Step=0)or(Step=1) then
   begin

     if ErrorCode=$FF
       then mes.Code:= R8_OK
       else
       begin
         mes.Code:= R8_SYSERROR;
         mes.Level:= ErrorCode;
       end;
     send(mes);
     if  mes.Code= R8_OK
       then Log('SEND: Связь с БЦП в норме')
       else Log('SEND: Ошибка в БЦП');

   end;
   // -----------------------------------
   mes.Size:=128;



   sleep(1000);
   if (Step=0)or(Step=101) then
   begin

     //ВРЕМЕННОЕ РЕШЕНИЕ Н.У.
     FillChar(l,128,0);
     if rub.ZN.Count>0 then
     begin
       for i:=1 to rub.ZN.Count do
       begin
         pzn:= rub.ZN.Items[i-1];
         l[ (pzn^.Number-1) div 8 ]:=l[ (pzn^.Number-1) div 8 ] or ($80 shr ((pzn^.Number-1) mod 8));
       end;
       Log('SEND: Блок зон');
       mes.Code:= R8_BLOCK_ZONE_READY;
       send(mes,PChar(@l[0]));
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=2) then
   begin

     //R8_STATE_ZONE_READY
     FillChar(l,128,0);
     if rub.ZN.Count>0 then
     begin
       for i:=1 to rub.ZN.Count do
       begin
         pzn:=rub.ZN.Items[i-1];
         if (pzn^.State and $01)>0 then
           l[ (pzn^.Number-1) div 8 ]:=l[ (pzn^.Number-1) div 8 ] or ($80 shr ((pzn^.Number-1) mod 8));
       end;
       Log('SEND: Блок готовых зон');
       mes.Code:= R8_BLOCK_ZONE_READY;
       send(mes,PChar(@l[0]));
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=3) then
   begin

     //R8_STATE_ZONE_ALARM
     FillChar(l,128,0);
     if rub.ZN.Count>0 then
     begin
       for i:=1 to rub.ZN.Count do
       begin
         pzn:=rub.ZN.Items[i-1];
         if (pzn^.State and $04)>0 then
           l[ (pzn^.Number-1) div 8 ]:=l[ (pzn^.Number-1) div 8 ] or ($80 shr ((pzn^.Number-1) mod 8));
       end;
       Log('SEND: Блок зон в тревоге');
       mes.Code:= R8_BLOCK_ZONE_ALARM;
       send(mes,PChar(@l[0]));
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=4) then
   begin

     //R8_STATE_ZONE_CHECK
     FillChar(l,128,0);
     if rub.ZN.Count>0 then
     begin
       for i:=1 to rub.ZN.Count do
       begin
         pzn:=rub.ZN.Items[i-1];
         if (pzn^.State and $08)>0 then
           l[ (pzn^.Number-1) div 8 ]:=l[ (pzn^.Number-1) div 8 ] or ($80 shr ((pzn^.Number-1) mod 8));
       end;
       Log('SEND: Блок неиспр. зон');
       mes.Code:= R8_BLOCK_ZONE_CHECK;
       send(mes,PChar(@l[0]));
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=5) then
   begin

     //R8_STATE_ZONE_ARMED
     FillChar(l,128,0);
     if rub.ZN.Count>0 then
     begin
       for i:=1 to rub.ZN.Count do
       begin
         pzn:=rub.ZN.Items[i-1];
         if (pzn^.State and $02)>0 then
           l[ (pzn^.Number-1) div 8 ]:=l[ (pzn^.Number-1) div 8 ] or ($80 shr ((pzn^.Number-1) mod 8));
       end;
       Log('SEND: Блок зон на охране');
       mes.Code:= R8_BLOCK_ZONE_ARMED;
       send(mes,PChar(@l[0]));
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=6) then
   begin

     //R8_STATE_ZONE_BYPASS
     FillChar(l,128,0);
     if rub.ZN.Count>0 then
     begin
       for i:=1 to rub.ZN.Count do
       begin
         pzn:=rub.ZN.Items[i-1];
         if (pzn^.State and $10)>0 then
           l[ (pzn^.Number-1) div 8 ]:=l[ (pzn^.Number-1) div 8 ] or ($80 shr ((pzn^.Number-1) mod 8));
       end;
       Log('SEND: Блок зон в байпасе');
       mes.Code:= R8_BLOCK_ZONE_OFF;
       send(mes,PChar(@l[0]));
     end;

   end;



   // -----------------------------------
   mes.Size:=512;



   sleep(1000);
   if (Step=0)or(Step=7) then
   begin

     //R8_STATE_SH_ENABLED
     FillChar(l, BufSize, 0); Max:= 0;
     for i:=1 to rub.TC.Count do
     begin
       p:=rub.TC.Items[i-1];
       if (p^.Kind<1)and(p^.Kind>4) then
         continue;
       if (Max < p^.ZoneVista) then
         Max:= p^.ZoneVista;
       l[(p^.ZoneVista-1) div 8]:= l[(p^.ZoneVista-1) div 8] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     if Max>0 then
     begin
       Log('SEND: Блок доступных ШС');
       mes.Code:= R8_BLOCK_SH_ENABLED;
       if option.SendOldStateBlock
         then send(mes, PChar(@l[0]))
         else SendBlockSHState(mes, Max, l);
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=8) then
   begin

     //R8_STATE_SH_READY + техн. ШС
     FillChar(l, BufSize, 0); Max:= 0;
     for i:=1 to rub.TC.Count do
     begin
       p:= rub.TC.Items[i-1];
       if (p^.Kind<1)and(p^.Kind>4) then
         continue;
       if (Max < p^.ZoneVista) then
         Max:= p^.ZoneVista;
       if (p^.State and $01)>0 then
         l[(p^.ZoneVista-1) div 8]:= l[(p^.ZoneVista-1) div 8] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     if Max>0 then
     begin
       Log('SEND: Блок готовых ШС');
       mes.Code:= R8_BLOCK_SH_READY;
       if option.SendOldStateBlock
         then send(mes, PChar(@l[0]))
         else SendBlockSHState(mes, Max, l);
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=9) then
   begin

     //R8_STATE_SH_ALARM
     FillChar(l, BufSize, 0); Max:= 0;
     if rub.TC.Count>0 then
     for i:=1 to rub.TC.Count do
     begin
       p:= rub.TC.Items[i-1];
       if (p^.Kind<1)and(p^.Kind>4) then
         continue;
       if (Max < p^.ZoneVista) then
         Max:= p^.ZoneVista;
       if (p^.State and $04)>0 then
         l[(p^.ZoneVista-1) div 8]:= l[(p^.ZoneVista-1) div 8] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     if Max>0 then
     begin
       Log('SEND: Блок ШС в тревоге');
       mes.Code:= R8_BLOCK_SH_ALARM;
       if option.SendOldStateBlock
         then send(mes,PChar(@l[0]))
         else SendBlockSHState(mes, Max, l);
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=10) then
   begin

     //R8_STATE_SH_OFF
     FillChar(l, BufSize, 0); Max:= 0;
     for i:=1 to rub.TC.Count do
     begin
       p:=rub.TC.Items[i-1];
       if (p^.Kind<1)and(p^.Kind>4) then
         continue;
       if (Max < p^.ZoneVista) then
         Max:= p^.ZoneVista;
       if (p^.State and $10)>0 then
         l[(p^.ZoneVista-1) div 8]:= l[(p^.ZoneVista-1) div 8] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     //
     if Option.DebugVar='OFF_1' then
       FillChar(l, BufSize, $ff);
     if Option.DebugVar='OFF_0' then
       FillChar(l, BufSize, 0);
     //
     if Max>0 then
     begin
       Log('SEND: Блок откл. ШС');
       mes.Code:= R8_BLOCK_SH_OFF;
       if option.SendOldStateBlock
         then send(mes,PChar(@l[0]))
         else SendBlockSHState(mes, Max, l);
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=11) then
   begin

     //R8_STATE_SH_ARMED
     FillChar(l, BufSize, 0); Max:= 0;
     for i:=1 to rub.TC.Count do
     begin
       p:=rub.TC.Items[i-1];
       if (p^.Kind<1)and(p^.Kind>3) then
         continue;
       if (Max < p^.ZoneVista) then
         Max:= p^.ZoneVista;
       if (p^.State and $02)>0 then
         l[(p^.ZoneVista-1) div 8]:= l[(p^.ZoneVista-1) div 8] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     if Max>0 then
     begin
       Log('SEND: Блок ШС на охране');
       mes.Code:= R8_BLOCK_SH_ARMED;
       if option.SendOldStateBlock
         then send(mes,PChar(@l[0]))
         else SendBlockSHState(mes, Max, l);
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=12) then
   begin

     //R8_STATE_SH_CHECK
     FillChar(l, BufSize, 0); Max:= 0;
     for i:=1 to rub.TC.Count do
     begin
       p:=rub.TC.Items[i-1];
       if (p^.Kind<1)and(p^.Kind>4) then
         continue;
       if (Max < p^.ZoneVista) then
         Max:= p^.ZoneVista;
       if (p^.State and $08)>0 then
         l[(p^.ZoneVista-1) div 8]:= l[(p^.ZoneVista-1) div 8] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     if Max>0 then
     begin
       Log('SEND: Блок неиспр. ШС');
       mes.Code:= R8_BLOCK_SH_CHECK;
       if option.SendOldStateBlock
         then send(mes,PChar(@l[0]))
         else SendBlockSHState(mes, Max, l);
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=13) then
   begin

     //R8_BLOCK_SH_HW_FAULT
     FillChar(l, BufSize, 0); Max:= 0;
     for i:=1 to rub.TC.Count do
     begin
       p:=rub.TC.Items[i-1];
       if (p^.Kind<1)and(p^.Kind>4) then
         continue;
       if (Max < p^.ZoneVista) then
         Max:= p^.ZoneVista;
       if (p^.State and $20)=0 then
         l[(p^.ZoneVista-1) div 8]:= l[(p^.ZoneVista-1) div 8] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     //
     if Option.DebugVar='FAULT_1' then
       FillChar(l, BufSize, $ff);
     if Option.DebugVar='FAULT_0' then
       FillChar(l, BufSize, 0);
     //
     if Max>0 then
     begin
       Log('SEND: Блок ШС с неиспр. оборуд.');
       mes.Code:= R8_BLOCK_SH_HW_FAULT;
       if option.SendOldStateBlock
         then send(mes,PChar(@l[0]))
         else SendBlockSHState(mes, Max, l);
     end;

   end;


   // -----------------------------------
   //R8_STATE_RELAY_&&_CU
   mes.Size:=512;



   sleep(1000);
   if (Step=0)or(Step=14) then
   begin

     //R8_STATE_RELAY_ON
     Log('SEND: Блок доступных реле');
     FillChar(l,512,0); Max:= 0;

     for i:=1 to rub.TC.Count do
     begin
       p:=rub.TC.Items[i-1];
       if (p^.Kind<>5) then
         continue;
       inc(Max);
       if (p^.State and $02)>0 then
         l[(p^.ZoneVista-1) div 8 ]:= l[ (p^.ZoneVista-1) div 8 ] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     if Max>0 then
     begin
       mes.Code:= R8_BLOCK_RELAY_1;
       send(mes,PChar(@l[0]));
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=15) then
   begin

     //R8_STATE_RELAY_CONNECT
     Log('SEND: Блок реле с неиспр. оборуд.');
     FillChar(l,512,0); Max:= 0;
     for i:=1 to rub.TC.Count do
     begin
       p:=rub.TC.Items[i-1];
       if (p^.Kind<>5) then
         continue;
       inc(Max);
       if (p^.State and $20)=0 then
         l[ (p^.ZoneVista-1) div 8 ]:= l[ (p^.ZoneVista-1) div 8 ] or ($80 shr ((p^.ZoneVista-1) mod 8));
     end;
     if Max>0 then
     begin
       mes.Code:= R8_BLOCK_RELAY_CONNECT;
       send(mes,PChar(@l[0]));
     end;

   end;



   // -----------------------------------
   //R8_STATE_CU_CONNECT
   mes.Size:=512;


   sleep(1000);
   if (Step=0)or(Step=16) then
   begin

     Log('SEND: Блок СУ на связи');
     FillChar(l,512,0);
     for i:=1 to rub.CU.Count do
     begin
       pcu:= rub.CU.Items[i-1];
       if (pcu^.State and 1)>0 then
         l[(pcu^.Number-1) div 8 ]:= l[ (pcu^.Number-1) div 8 ] or ($80 shr ((pcu^.Number-1) mod 8));
     end;
     if rub.CU.Count>0 then
     begin
       mes.Code:= R8_BLOCK_CU_CONNECT;
       send(mes,PChar(@l[0]));
     end;

   end;



   sleep(1000);
   if (Step=0)or(Step=17) then
   begin

     //R8_STATE_CU_OPEN
     Log('SEND: Блок вскрытых СУ');
     FillChar(l,512,0);
     for i:=1 to rub.CU.Count do
     begin
       pcu:=rub.CU.Items[i-1];
       if (pcu^.State and $02)>0 then
         l[(pcu^.Number-1) div 8 ]:= l[ (pcu^.Number-1) div 8 ] or ($80 shr ((pcu^.Number-1) mod 8));
     end;
     if rub.CU.Count>0 then
     begin
       mes.Code:= R8_BLOCK_CU_OPEN;
       send(mes,PChar(@l[0]));
     end;

   end;


   
   sleep(1000);
   if (Step=0)or(Step=18) then
   begin

     // -----------------------------------
     Log('SEND: Блок состояний ТД');
     mes.SysDevice:= SYSTEM_SUD;
     mes.TypeDevice:= 0;
     FillChar(l, 1024, 0); Max:= 0;
     for i:=0 to rub.TC.Count-1 do
     begin
       p:= rub.TC.Items[i];
       if (p^.Kind<>6) then
         continue;
       l[Max*3 + 0]:= lo(p^.ZoneVista);
       l[Max*3 + 1]:= hi(p^.ZoneVista);
       l[Max*3 + 2]:= (APModeToRostek(p) shl 4) or APStateToRostek(p);
       inc(Max);
     end;
     if Max>0 then
     begin
       mes.Size:= 3*Max;
       mes.Code:= R8_BLOCK_AP_DATA;
       send(mes,PChar(@l[0]));
     end;

   end;


   
 end; //with
end;

//-----------------------------------------------------------------------------
procedure TaMain.TimerVisibleTimer(Sender: TObject);
var
  v :^TMesRec;
begin
  inherited; // TimerVisibleTimer > Consider  > Consider(overload, CommonMesBuf.Add)
  //
  AppKsb.LiveCount:= AppKsb.LiveCount + 1;
  if TimerVisiblePause>0 then
    exit;
  //
  {$IFNDEF RUN_WITHOUT_CONNECTION}
  if not (rub.comd in [4..17, 21..26]) then
  {$ENDIF}
  if CommonMesBuf.Count>0 then
  begin
    v:= CommonMesBuf.Items[0];
    case v^.m.Code of
      R8_COMMAND_CU_CREATE,
      R8_COMMAND_CU_DELETE,
      R8_COMMAND_AP_CREATE,
      R8_COMMAND_AP_CHANGE,
      R8_COMMAND_AP_DELETE,
      R8_COMMAND_GR_CREATE,
      R8_COMMAND_GR_DELETE,
      R8_COMMAND_UD_CREATE,
      R8_COMMAND_UD_CHANGE,
      R8_COMMAND_UD_DELETE,
      R8_COMMAND_TZ_CREATE,
      R8_COMMAND_TZ_CHANGE,
      R8_COMMAND_TZ_DELETE:
        TimerVisiblePause:= (2000 div 10);  //по умолчанию 3000
      R8_COMMAND_AP_LOCK,
      R8_COMMAND_AP_UNLOCK,
      R8_COMMAND_AP_RESET,
      SCU_HW_EDIT:
        TimerVisiblePause:= (2000 div 10);
    end;//case
    case v^.m.Code of
      9801..9999:
        scu.MesBuf.Add(v);
      else
      begin
        ConsiderBCP(v^.m, v^.s);
        Dispose(v); // 31.11.15
      end;
    end;//case
    CommonMesBuf.Remove(v);
  end;
  //
  if (CommonMesBuf.Count>10000) then
  begin
    Log('Переполнен CommonMesBuf вх. KSBMES');
    halt;
  end;
  if (scu.MesBuf.Count>256000) then
  begin
    Log('Переполнен scu.MesBuf вх. KSBMES');
    halt;
  end;


  //
end;

//-----------------------------------------------------------------------------
procedure TaMain.SetOnline(Value: byte);
var
 mes: KSBMES;
 data: PChar;
begin
 data:='';
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= rub.NetDevice;
 mes.BigDevice:= rub.BigDevice;
 mes.TypeDevice:= 4;
 //
 if Value<>rub.Online then
 case Value of
   1:
   begin
     rub.Online:= Value;
     mes.Code:= R8_CONNECT_TRUE;
     WriteLog('SEND: БЦП на связи');
     Send(mes);
     AntiFreezTimer.Enabled:= False;
     {if rub.WorkTime then
       BlockStateToVU;}
   end;
   else
   begin
     rub.Online:= Value;
     mes.Code:=R8_SMALL_CONNECT_FALSE;
     Log('SEND: Кратковременная (менее минуты) потеря связи с БЦП','ForceLog');
     Send(mes);
     AntiFreezTimer.Enabled:= True;
   end;
 end;//case
 //
end;

//-----------------------------------------------------------------------------
procedure TaMain.DrvReady;
var
 mes: KSBMES;
begin
 Log('SEND: Драйвер готов к работе');
 Init(mes);
 mes.SysDevice:= SYSTEM_PROGRAM;
 mes.NetDevice:= ModuleNetDevice;
 mes.BigDevice:= ModuleBigDevice;
 mes.TypeDevice:= 3;
 mes.Code:= R8_DRV_READY;
 Send(mes);
end;

//-------------------- RWTimer ------------------------------------------------
procedure TaMain.RWTimerTimer(Sender: TObject);
const
 CW_BUFFER = 0;
 CR_BUFFER = 1;
 CW_EXEC = 2;
 CR_EXEC = 3;


var
 t: PTTelegram;
 st: string;
 i: word;
 v: word;
 mes: KSBMES;
 data: PChar;
 time: Longword;
 OpCase: byte;

begin
 Debug('F:RWTimerTimer');
 data:= '';
 LiveCount[1]:= 0;
{
Слово состояния БЦП передается в каждом ответе БЦП.
Слово состояния содержит информация о состоянии ресурсов БЦП по отношению к АВУ.
#define PSW_DISPLAYCHANGE 0x00000001
#define PSW_NDSTATECHANGE 0x00000002
#define PSW_TCOSTATECHANGE 0x00000004
#define PSW_PROTOCOL 0x00000008
#define PSW_IDENTIFIERREADY 0x00000010
#define PSW_USERSTATECHANGE 0x00000020
#define PSW_SKAU01DATAREADY 0x00000040
#define PSW_TCOANALOGSTATECHANGE 0x00000080
#define PSW_SOVALOUDSPEAKEXT 0x00000100
#define PSW_SOVALOUDSPEAKINT 0x00000200
#define PSW_SOVAPHONESTATION 0x00000400
#define PSW_SYSTEMERROR 0x00000800
#define PSW_USERIDCODEBUFFER 0x00001000
#define PSW_NET2BCPSTATECHANG 0x00002000
#define PSW_RUBICONRPTSEATOFFIRE 0x00004000
#define PSW_KA2DATAREADY 0x00008000

Табл. 2 Слово состояния БЦП
Бит Описание
0 Изменилось содержимое дисплея БЦП
1 Изменилось состояние СУ
2 Изменилось состояние объектов ТС
3 В журнале событий появились новые записи
4 Идентификатор пользователя готов к передаче в АВУ
5 Изменилось состояние пользователей
6 Запрашиваемые данные состояния СКАУ-01 готовы к передаче в АВУ
7 Изменились аналоговые значения объектов ТС
8 Сова: Включение канала оповещения «Периметр»
9 Сова: Включение канала оповещения «Помещение»
10 Сова: Снятие трубки системного телефона
11 Флаг системной ошибки
12 Буфер кодов пользователей не пуст
13 Изменилось состояние сетевых БЦП
14 Рубикон-РПТ: изменились координаты очага пожара
15 КА2: данные от КА2 Рубикон получены и готовы для передачи в АВУ
16-31 Зарезервированы
}
 LabeledEdit1.Text:= inttostr(rub.comd);
 //
 QueryPerformanceFrequency(_f.QuadPart);
 QueryPerformanceCounter(_c3.QuadPart);
 //
 if option.DebugVar='COMD' then
 begin
  st:= IntToStr(rub.comd);
  Log('comd='+st);
 end;
 TRY
 //
 if rbcp.rbuf[0]>0 then
 begin
   Edit7.Text:= inttohex(rbcp.rbuf[6],2)+'-'+inttohex(rbcp.rbuf[7],2)+'-'+inttohex(rbcp.rbuf[8],2);
   Edit9.Text:= inttohex(rbcp.rbuf[10],2);
   Edit10.Text:= inttohex(rbcp.RetCode, 2);
 end;//if r.rbuf[0]>0 then

 if Option.Logged_OnReadBCP then
 if rbcp.rbuf[0]<>0 then
 begin
   st:= 'Logged_OnReadBCP: ';
   for i:=0 to rbcp.rbuf[5]+7 do
   st:= st+inttohex(rbcp.rbuf[i],2);
   Log(st);
 end;


 with rub do begin

  case comd of

    CW_BUFFER: //тест буфера БЦП
    begin
      if not WorkTime then
      begin
        WorkTime:= true;
        TabSheet2.TabVisible:= true;
        DrvReady;
        BlockStateToVU{(False)};
      end;
      new(t);
      mGetEvent(0, MesIndex, t);
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval); //изм.96 (почти по всем comd)
      comd:= CR_BUFFER;
    end; // 0:

    CR_BUFFER: //ожидание ответа буфера БЦП
    begin
      if WaitCount>0 then
        dec(WaitCount);
      //
      if WBuf.Count>0 then
      for i:=0 to WBuf.Count-1 do
      begin
        t:= WBuf.Items[i];
        v:= t^[241] + 256*t^[242];
        if v=0 then
        begin
          if i<>0 then
            WBuf.Move(i, 0);
          break;
        end
        else
        begin
          if (v > (2*RWTimer.Interval))
            then v:= v - 2*RWTimer.Interval
            else v:= 0;
          t^[241]:= lo(v);
          t^[242]:= hi(v);
        end;
      end;//for
      //
      if rbcp.rbuf[0]>0 then //дождались
      begin
        ReadBCPTelegram; // Обработка принятой телеграммы

        //===============================================
        OpCase:= 0;
        MesIndex:= $FFFF;
        //
        if (rbcp.rbuf[5]=7)and(WBuf.Count>0) then       //есть команды
          OpCase:= 3;
        if (rbcp.rbuf[6] and $04)>0 then                //есть измененное(ые) сосотяние(я)
          OpCase:= 2;
        if (rbcp.rbuf[6] and $08)>0 then                //есть событие(я)
          OpCase:= 1;
        //
        //
        comd:= CW_BUFFER;        
        case OpCase of
          0: //нет событий, состояний, команд
          begin
          end;
          1:
          begin
            if rbcp.rbuf[10]=$8d then
              MesIndex:= 256*rbcp.rbuf[14] + rbcp.rbuf[13];
          end;
          2:
          begin
            TempIndex:= $FFFF;
            comd:= 32;
          end;
          3:
          begin
            t:= WBuf.Items[0];
            v:= t^[241] + 256*t^[242];
            if v=0 then
              case (t^[0] + t^[1]*256) of
                1://УД
                begin
                  comd:= 36;
                  Temp2Index:= t^[2];
                  TempIndex:= $ffff;
                  WBuf.Remove(t);
                  Dispose(t);
                end;
                else
                  comd:= CW_EXEC;
              end;//case
          end;//3

        end;//case OpCase

       //===============================================

        SetOnline(1);
        FillChar(rbcp.rbuf,255,0); // Очистка телеграммы + Конец обработки
      end;//дождались

      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:= CW_BUFFER;
      end;
    end; // CR_BUFFER:



    CW_EXEC: // отправка команды
    if WBuf.Count>0 then
    begin
      t:= WBuf.Items[0];
      //==================== анализ на 84+создание+редактирование
      Cmd.comd:=0;
      //
      if (t^[6]=$84)and(t^[7]=$01)and(t^[8]=$01) then // создание зоны
      begin
        Cmd.comd:=1;
        move(t^[9], Cmd.zn, sizeof(TZN)-3);
        Cmd.zn.Number:=256*t^[255]+t^[254];
      end;
      if (t^[6]=$84)and(t^[7]=$01)and(t^[8]=$02) then // редактирование зоны
      begin
        Cmd.comd:=1;
        move(t^[9], Cmd.zn, sizeof(TZN)-3);
        Cmd.zn.Number:=256*t^[255]+t^[254];
      end;
      if (t^[6]=$84)and(t^[7]=$01)and(t^[8]=$06) then // запрос конф. зоны
      begin
        Cmd.comd:=1;
        move(t^[9], Cmd.zn.BCPNumber, 4); //!!!!! BCPNumber
        Cmd.zn.Number:=256*t^[255]+t^[254];
      end;
      //
      if (t^[6]=$84)and(t^[7]=$02)and(t^[8]=$01) then // создание ТС
      begin
        Cmd.comd:=2;
        move(t^[9], Cmd.tc, sizeof(TTC)-8-4{newTTC});
        Cmd.tc.ZoneVista:=256*t^[253]+t^[252];
        Cmd.tc.PartVista:=256*t^[255]+t^[254];
      end;
      if (t^[6]=$84)and(t^[7]=$02)and(t^[8]=$02) then // редактирование ТС
      begin
        Cmd.comd:=2;
        move(t^[9], Cmd.tc, sizeof(TTC)-8-4{newTTC});
        Cmd.tc.ZoneVista:=256*t^[253]+t^[252];
        Cmd.tc.PartVista:=256*t^[255]+t^[254];
      end;
      if (t^[6]=$84)and(t^[7]=$02)and(t^[8]=$04) then // запрос конф. ТС
      begin
        Cmd.comd:=2;
        move(t^[9], Cmd.tc.BCP, 4); //!!!!! tcoid
        Cmd.tc.ZoneVista:=256*t^[253]+t^[252];
        Cmd.tc.PartVista:=256*t^[255]+t^[254];
      end;
      //
      if (t^[6]=$84)and(t^[7]=$0A)and(t^[8]=$01) then
      Cmd.comd:=$03; // создание ВЗ
      if (t^[6]=$84)and(t^[7]=$0A)and(t^[8]=$03) then
      Cmd.comd:=$04; // редактирование ВЗ
      //
      if (t^[6]=$84)and(t^[7]=$03)and(t^[8]=$01) then // создание СУ
      begin
        Cmd.comd:=5;
        move(t^[9], Cmd.cu, sizeof(TCU)-7);
        Cmd.cu.Number:=256*t^[255]+t^[254];
      end;
      if (t^[6]=$84)and(t^[7]=$03)and(t^[8]=$02) then // редактирование СУ
      begin
        Cmd.comd:=5;
        move(t^[9], Cmd.cu, sizeof(TCU)-7);
        Cmd.cu.Number:=256*t^[255]+t^[254];
      end;
      if (t^[6]=$84)and(t^[7]=$03)and(t^[8]=$05) then // запрос конф. СУ
      begin
        Cmd.comd:=5;
        move(t^[9], Cmd.cu, 3); //!!!!! hid
        Cmd.cu.Number:=256*t^[255]+t^[254];
      end;
      //
      if (t^[6]=$84)and(t^[7]=$0B)and(t^[8]=$01) then
      Cmd.comd:=$06; // создание УД
      if (t^[6]=$84)and(t^[7]=$0B)and(t^[8]=$03) then
      Cmd.comd:=$07; // редактирование УД
      //
      //
      if (t^[6]=$84)and(t^[7]=$09)and(t^[8]=$01) then // создание группы
      begin
        Cmd.comd:=9;
        move(t^[9], Cmd.gr, sizeof(TGR));
        Cmd.gr.Num:=t^[255];
      end;
      if (t^[6]=$84)and(t^[7]=$09)and(t^[8]=$02) then // редактирование группы
      begin
        Cmd.comd:=9;
        move(t^[9], Cmd.gr, sizeof(TGR));
        Cmd.gr.Num:=t^[255];
      end;
      if (t^[6]=$84)and(t^[7]=$09)and(t^[8]=$05) then // запрос конф. группы
      begin
        Cmd.comd:=9;
        move(t^[9], Cmd.gr, sizeof(TGR));
        Cmd.gr.Num:=t^[255];
      end;
      if (t^[6]=$89)and(t^[7]=$02)and // установка времени
         (t^[8]=$00)and(t^[9]=$00)and
         (t^[10]=$00)and(t^[11]=$00)then
      begin
        time:= PackTime(now);
        t^[8]:= time and $FF;
        t^[9]:= time shr 8 and $FF;
        t^[10]:= time shr 16 and $FF;
        t^[11]:= time shr 24 and $FF;
        t^[12]:= lo(kc(t^,t^[5]+6)); t^[13]:= hi(kc(t^,t^[5]+6));
      end;
      //==================== анализ на 84+создание
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      //
      SetEvent(wbcp.ev);
      WaitCount:= round(1000/RWTimer.Interval);
      move(t^[256], mes, sizeof(KSBMES));
      if Option.Logged_OnExecBCPCmd then
      if mes.Code>0
        then Log( Format('В БЦП отправлена команда (%d)', [ mes.Code ] ) )
        else Log( Format('В БЦП отправлена команда (SYSTEM)', [] ) );

      //
      {if (t^[6]=$8e)and(eport<>nil) then
      begin
        WBuf.Delete(0);
        Dispose(t);
        comd:= 0;
        Cmd.comd:= 0;
        rub.MesIndex:= $FFFF;
      end
      else}
      begin
        comd:= CR_EXEC;
      end;
      //

    end //2:
    else comd:= 0;

    CR_EXEC:
    begin // ожидание ответа от команды
      if WaitCount>0 then
        dec(WaitCount);
      //
      if rbcp.rbuf[0]>0 then //дождались
      begin
        t:= WBuf.Items[0];
        //
        if (rbcp.RetCode<>$0)and
           (rbcp.RetCode<>$1e)and
           (rbcp.RetCode<>$1f) then
        begin
          // Отчет об ошибке от БЦП
          Init(mes);
          mes.SysDevice:= SYSTEM_OPS;
          mes.NetDevice:= rub.NetDevice;
          mes.BigDevice:= rub.BigDevice;
          mes.TypeDevice:= 4;
          mes.SmallDevice:= rbcp.RetCode;
          mes.Level:= rbcp.RetCode;
          mes.Code:= R8_BCP_ERROR;
          aMain.send(mes);
          //
          //отправка входящей от ВУ телеграммы с учетом замены кода сообщения
          //на R8_RETURN_ROSTEK_CMD_ON_ERROR
          //код сообщения возвращается в поле 'Код сообщения'
          move(t^[256], mes, sizeof(KSBMES));
          TheKSBParam.WriteIntegerParam(mes, data, 'Код сообщения', mes.Code);
          mes.Level:= rbcp.RetCode;
          mes.Code:= R8_RETURN_ROSTEK_CMD_ON_ERROR;
          aMain.send(mes);
          //
          move(t^[256], mes, sizeof(KSBMES));
          case mes.Code of
            R8_COMMAND_USER_CREATE,
            R8_COMMAND_USER_CHANGE,
            R8_COMMAND_USER_DELETE:
            DrvErrorReportForServerRubeg(mes.Code, mes.User, 0);
          end;
          //
          if mes.Code>0
            then Log( Format('БЦП отклонил команду (%d). Ошибка №%d (%s)',
                      [ mes.Code, rbcp.RetCode, DescriptionBCPRetCode(rbcp.RetCode)  ] ) )
            else Log( Format('БЦП отклонил команду (SYSTEM). Ошибка №%d (%s)',
                      [ rbcp.RetCode, DescriptionBCPRetCode(rbcp.RetCode)  ] ) );
        end
        else
        begin
          move(t^[256], mes, sizeof(KSBMES));
          if Option.Logged_OnExecBCPCmd then
          if mes.Code>0
            then Log( Format('БЦП принял команду (%d). Результат №%d (%s)',
                     [ mes.Code, rbcp.RetCode, DescriptionBCPRetCode(rbcp.RetCode)  ] ) )
            else Log( Format('БЦП принял команду (SYSTEM). Результат №%d (%s)',
                      [ rbcp.RetCode, DescriptionBCPRetCode(rbcp.RetCode)  ] ) );
        end;
          //
        ReadBCPTelegram;    // Обработка принятой телеграммы
        //
        WBuf.Delete(0);
        Dispose(t);
        comd:= 0;
        Cmd.comd:=0;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);  // Очистка телеграммы + Конец обработки
      end;

      if WaitCount=0 then //не дождались
      begin
        if WBuf.Count>0 then
        begin
          WBuf.Delete(0);
          Dispose(t);
        end;
        SetOnline(0);
        comd:=0;
      end;
    end; //3:

    4:
    begin // чтение конфигурации СУ-в
      new(t);
      mGetListCU(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=5;
    end; //4:

    5:
    begin // ожидание ответа при чтении конфигурации СУ-в
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if rbcp.RetCode=0 {(rbcp.rbuf[5]=$1B)} then
        begin
          comd:=4;
          TempIndex:=256*rbcp.rbuf[32]+rbcp.rbuf[31];
          ReadBCPTelegram;    // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация СУ ('+inttostr(CU.Count)+')');
          TempIndex:=$FFFF;
          comd:=6;               // переход к чтению конфигурации зон
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);      // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=4;
      end;
    end; //5:

    6:
    begin // чтение конфигурации зон
      new(t);
      mGetListZone(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=7;
    end; //6:

    7:
    begin // ожидание ответа при чтении конфигурации зон
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$14) then
        begin
          comd:=6;
          TempIndex:=256*rbcp.rbuf[25]+rbcp.rbuf[24];
          ReadBCPTelegram;  // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация зон ('+inttostr(ZN.Count)+')');
          TempIndex:=$FFFF;
          comd:=8;               // переход к чтению конфигурации ТС-в
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);      // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=6;
      end;
    end; //7:


    8: // чтение конфигурации ТС-в
    begin
      new(t);
      mGetListTC(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=9;
    end; //8:

    9: // ожидание ответа при чтении конфигурации ТС-в
    begin
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$31) then
        begin
          comd:=8;
          TempIndex:=256*rbcp.rbuf[54]+rbcp.rbuf[53];
          ReadBCPTelegram;    // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация ТС ('+inttostr(TC.Count)+')');
          TempIndex:=$FFFF;
          comd:=10;               // переход к чтению конфигурации пользователей
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);      // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=8;
      end;
    end; //9:


    10: // чтение конфигурации ГР
    begin
      new(t);
      mGetListGR(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=11;
    end; //10:

    11: // ожидание ответа при чтении конфигурации ГР
    begin
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.RetCode=0) then
        begin
          comd:=10;
          TempIndex:=256*rbcp.rbuf[20]+rbcp.rbuf[19];
          ReadBCPTelegram;    // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация групп ('+inttostr(GR.Count)+')');
          TempIndex:=$FFFF;
          comd:=12;               // переход к чтению конфигурации пользователей
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);      // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=10;
      end;
    end; //11:


    12: // чтение конфигурации пользователей
    begin
      new(t);
      mGetListUser(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:= 13 ;
    end; //12:

    13: // ожидание ответа при чтении конфигурации пользователей
    begin
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$2B) then
        begin
          comd:= 12;
          TempIndex:=256*rbcp.rbuf[48]+rbcp.rbuf[47];
          ReadBCPTelegram;    // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация пользователей ('+inttostr(US.Count)+')');
          TempIndex:=$FFFF;
          comd:=14;               // переход к чтению конфигурации временных зон
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);      // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:= 12;
      end;
    end; //13:


    14: // чтение конфигурации ВИ
    begin
      new(t);
      mGetListTimeInterval(0, TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=15;
    end; //14:

    15: // ожидание ответа при чтении конфигурации ВИ
    begin
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$15) then
        begin
          comd:=14;
          TempIndex:=256*rbcp.rbuf[26]+rbcp.rbuf[25];
          ReadBCPTelegram;    // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация ВИ ('+inttostr(TI.Count)+')');
          TempIndex:=$FFFF;
          //comd:=16;                  // переход к чтению конфигурации УД //изм 100
          comd:=18;                    // переход к чтению названий        //изм 100
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);      // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=14;
      end;
    end; //15:


    16:
    begin // чтение конфигурации прав
      new(t);
      mGetListPravo(0, TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=17;
    end; //16:

    17:
    begin // ожидание ответа при чтении конфигурации прав
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$1b) then
        begin
          comd:=16;
          TempIndex:=256*rbcp.rbuf[32]+rbcp.rbuf[31];
          ReadBCPTelegram;   // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация прав ('+inttostr(PR.Count)+')');
          NeedSaveR8h:= True;       //запись конфигурации БЦП в файл
          FinishReadCfg;
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);//Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=16;
      end;
    end; //17:


    18:
    begin // чтение названий
      new(t);
      mGetListRN(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=19;
    end; //18:

    19:
    begin // ожидание ответа при чтении названий
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$1c) then
        begin
          comd:=18;
          TempIndex:= rbcp.rbuf[15];
          ReadBCPTelegram;   // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация названий ('+inttostr(RN.Count)+')');
          TempIndex:=$FFFF;
          comd:=81;               // переход к чтению программ
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);//Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=18;
      end;
    end; //19:



    81:
    begin // чтение программ
      new(t);
      mGetListRP(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=82;
    end; //81:

    82:
    begin // ожидание ответа при чтении RSP
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$13) then
        begin
          comd:=81;
          TempIndex:=256*rbcp.rbuf[24]+rbcp.rbuf[23];
          ReadBCPTelegram;   // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация программ ('+inttostr(RP.Count)+')');
          TempIndex:=$FFFF;
          comd:=83;               // переход к чтению конфигурации RI
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);//Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=81;
      end;
    end; //82:


    83:
    begin // чтение инструкций
      new(t);
      mGetListRI(TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=84;
    end; //83:

    84:
    begin // ожидание ответа при чтении RSP
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$1b) then
        begin
          comd:=83;
          TempIndex:=256*rbcp.rbuf[32]+rbcp.rbuf[31];
          ReadBCPTelegram;   // Обработка принятой телеграммы
        end
        else
        begin
          Log('Прочитана конфигурация инструкций ('+inttostr(RI.Count)+')');
          TempIndex:=$FFFF;
          comd:=85;               // переход к чтению конфигурации праздников
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);//Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=83;
      end;
    end; //84:


    85:
    begin // чтение праздников
      new(t);
      mGetListHD(t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=86;
    end; //85:

    86:
    begin // ожидание ответа при чтении RSP
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$2d) then
        begin
          comd:=85;
          ReadBCPTelegram;   // Обработка принятой телеграммы
          Log('Прочитана конфигурация праздников');
          TempIndex:=$FFFF;
          comd:=16;               // переход к чтению конфигурации прав
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);//Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=85;
      end;
    end; //86:
    //------
    //------
    //------

    21: //чтение состояний СУ
    begin
      new(t);
      mGetStateCU(PTCU(CU.Items[TempIndex])^.HWType, PTCU(CU.Items[TempIndex])^.HWSerial, t);
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:= 22;
    end;//21:

    22: //ожидание ответа при чтении состояний СУ
    begin
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if rbcp.RetCode = 0 then
        begin
          ReadBCPTelegram; //обработка принятой телеграммы
          inc(TempIndex);
          if TempIndex<CU.Count
            then comd:= 21
            else
            begin
              //переход на чтение состояний ТС, либо на рабочий режим
              if TC.Count>0 then
              begin
                comd:= 23;
                TempIndex:= 0;
              end
              else comd:= 0;//25;
              Log('Прочитаны состояния СУ');
            end;
        end
        else comd:= 21;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0); //Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:= 21;
      end;
    end; //22:

    23: // чтение состояний тс
    begin
      new(t);
      mGetStateTC(PTTC(TC.Items[TempIndex])^.Sernum, 1, t);
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:= 24;
    end; //23:

    24:
    begin //ожидание ответа при чтении состояний ТС
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if rbcp.RetCode = 0  then
        begin
          ReadBCPTelegram; //обработка принятой телеграммы
          inc(TempIndex);
          if TempIndex<TC.Count
            then comd:= 23
            else begin
              comd:= 0;//25;
              Log('Прочитаны состояния ТС');
            end;
        end
        else comd:= 23;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0); //Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:= 23;
      end;
    end; //24:


    25: // отправка команды
    if WBuf.Count>0 then
    begin
      t:= WBuf.Items[0];
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      WaitCount:= round(20000/RWTimer.Interval);
      comd:= 26;
    end; //25:

    26:
    begin // ожидание ответа от команды
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        t:= WBuf.Items[0];
        ReadBCPTelegram;   // Обработка принятой телеграммы
        WBuf.Delete(0);
        Dispose(t);
        if WBuf.Count>0
          then comd:= 25
          else comd:= 0;   // переход на чт. буф.
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);  // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:= 0;
      end;
    end; //26:

    //------
    //------
    //------

    28: //чтение состояний маркированных СУ
    begin
      new(t);
      mGetStateMarkCU(TempIndex, 2, t);
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:= 29;
    end; //28:

    29: //ожидание ответа при чтении состояний маркированных СУ
    begin
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if rbcp.RetCode = 0  then
        begin
          TempIndex:= 256*rbcp.rbuf[33]+rbcp.rbuf[32];
          ReadBCPTelegram;  // Обработка принятой телеграммы
          comd:= 28;
        end
        else
        begin
          MesIndex:= $FFFF;
          comd:= 0; // переход на опрос буфера
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0); // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:= 28;
      end;
    end; //29:

    32: //чтение состояний маркированных тс
    begin
      new(t);
      mGetStateMarkTC(TempIndex, 2, t);
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:= 33;
    end; //32:

    33: //ожидание ответа при чтении состояний маркированных ТС
    begin
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if rbcp.RetCode = 0  then                                       //!!!!!!!!!!!!!
        begin
          TempIndex:=256*rbcp.rbuf[36]+rbcp.rbuf[35];
          ReadBCPTelegram; //Обработка принятой телеграммы
          comd:= 32;
        end
        else
        begin
          MesIndex:= $FFFF;
          comd:= 0; // переход на опрос буфера
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0); //Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:= 32;
      end;
    end; //33:



    34: //чтение конфигурации временной зоны
    begin
      new(t);
      mGetListTimeInterval(Temp2Index, TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=35;
    end; //34:

    35:
    begin // ожидание ответа при чтении конфигурации временной зоны
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$15) then
        begin
          comd:=34;
          TempIndex:=256*rbcp.rbuf[26]+rbcp.rbuf[25];
          ReadBCPTelegram;    // Обработка принятой телеграммы
        end
        else
        begin
          rub.NeedSaveR8h:= True;
          comd:=0;
          TempIndex:=$FFFF;  //переход на рабочий режим
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);      // Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=34;
      end;
    end; //35:

    36:
    begin // чтение конфигурации УД
      new(t);
      mGetListPravo(Temp2Index, TempIndex, t);
      rbcp.rbuf[0]:=0;
      rbcp.InCount:=0;
      wbcp.Count:=Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      Dispose(t);
      WaitCount:= round(30000/RWTimer.Interval);
      comd:=37;
    end; //36:

    37:
    begin // ожидание ответа при чтении конфигурации УД
      if WaitCount>0 then dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        if (rbcp.rbuf[5]=$1b) then
        begin
          comd:=36;
          TempIndex:= 256*rbcp.rbuf[32]+rbcp.rbuf[31];
          ReadBCPTelegram; // Обработка принятой телеграммы
        end
        else
        begin
          Log( Format('Прочитана конфигурация УД №(%d)', [ Temp2Index ] ) );
          rub.NeedSaveR8h:= True;
          comd:=0;
          TempIndex:=$FFFF;// переход на рабочий режим
        end;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);// Очистка телеграммы + Конец обработки
      end;
      if WaitCount=0 then //не дождались
      begin
        SetOnline(0);
        comd:=36;
      end;
    end; //37:








    201: // отправка команды
    if WBuf.Count>0 then
    begin
      //sleep(10);
      t:= WBuf.Items[0];
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      WaitCount:= round(15000/RWTimer.Interval);
      move(t^[256], mes, sizeof(KSBMES));
      case t^[7] of
        1: Log( Format('В БЦП отправлена команда удаления зон', [] ) );
        2: Log( Format('В БЦП отправлена команда удаления ТС', [] ) );
        3: Log( Format('В БЦП отправлена команда удаления СУ', [] ) );
        4: Log( Format('В БЦП отправлена команда удаления пользователей', [] ) );
        6: Log( Format('В БЦП отправлена команда удаления программ', [] ) );
        9: Log( Format('В БЦП отправлена команда удаления групп', [] ) );
        10: Log( Format('В БЦП отправлена команда удаления ВЗ', [] ) );
        11: Log( Format('В БЦП отправлена команда удаления УД', [] ) );
        12: Log( Format('В БЦП отправлена команда удаления праздников', [] ) );
        14: Log( Format('В БЦП отправлена команда удаления названий', [] ) );
      end;//case
      comd:= 202;
    end
    else
    begin
      comd:= 203;
      rub.ClearConf;
      rub.ReadBcpFile;
      PrintConf;
      rub.SendCfgToBcp;
      //Application.ProcessMessages;
    end;//201
    202:
    begin // ожидание ответа от команды
      if WaitCount>0 then
        dec(WaitCount);

      if rbcp.rbuf[0]>0 then //дождались
      begin
        t:= WBuf.Items[0];
        if (rbcp.RetCode<>$0)and
           (rbcp.RetCode<>$1e)and
           (rbcp.RetCode<>$1f)
           then Log( Format('БЦП отклонил команду. Ошибка №%d (%s)',
                     [ rbcp.RetCode, DescriptionBCPRetCode(rbcp.RetCode)  ] ) );
        ReadBCPTelegram;

        WBuf.Delete(0);
        Log('WBuf.Count='+IntToStr(WBuf.Count));
        Dispose(t);
        comd:= 201;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);  // Очистка телеграммы + Конец обработки
      end;
      //
      if WaitCount=0 then //не дождались
      begin
        if WBuf.Count>0 then
        begin
          Log('Delete не дождались --->>> ');
          WBuf.Delete(0);
          Dispose(t);
        end;
        //SetOnline(0);
        comd:=201;
      end;
    end; //202


    203: // отправка команды
    if WBuf.Count>0 then
    begin
      t:= WBuf.Items[0];
      rbcp.rbuf[0]:= 0;
      rbcp.InCount:= 0;
      wbcp.Count:= Vrez0(t);
      move(t^, wbcp.wbuf[0], wbcp.Count);
      SetEvent(wbcp.ev);
      WaitCount:= round(10000/RWTimer.Interval);
      move(t^[256], mes, sizeof(KSBMES));
      comd:= 204;
    end
    else
    begin
      TempIndex:= $FFFF;
      MesIndex:= $FFFF;
      comd:= 0;
      //
      DeleteFile( ReadPath() + Format('NET%uBIG%u.r8c',[NetDevice, BigDevice]) );
      Halt;
    end;
    204:
    begin // ожидание ответа от команды
      if WaitCount>0 then
        dec(WaitCount);
      if rbcp.rbuf[0]>0 then //дождались
      begin
        t:= WBuf.Items[0];
        if (rbcp.RetCode<>$0)and
           (rbcp.RetCode<>$1e)and
           (rbcp.RetCode<>$1f)
           then Log( Format('БЦП отклонил команду. Ошибка №%d (%s)',
                     [ rbcp.RetCode, DescriptionBCPRetCode(rbcp.RetCode)  ] ) );
        ReadBCPTelegram;
        WBuf.Delete(0);
        Dispose(t);
        comd:= 203;
        SetOnline(1);
        FillChar(rbcp.rbuf,255,0);  // Очистка телеграммы + Конец обработки
      end;
      //
      if WaitCount=0 then //не дождались
      begin
        if WBuf.Count>0 then
        begin
          WBuf.Delete(0);
          Dispose(t);
        end;
        SetOnline(0);
        comd:=203;
      end;
    end; //204:













  end; // case comd

 end; // with rub

EXCEPT
 Log('>>>>>RWTimer :'+inttostr(rub.comd));
 st:='w.wbuf : ';
 if wbcp.Count>0 then for i:=0 to wbcp.Count-1 do st:=st+inttohex(wbcp.wbuf[i],2){+'-'};
 Log(st);
 st:='r.rbuf : ';
 if rbcp.InCount>0 then for i:=0 to rbcp.InCount-1 do st:=st+inttohex(rbcp.rbuf[i],2){+'-'};
 Log(st);
END;

 if Option.Logged_Delay then
 begin
   QueryPerformanceCounter(_c4.QuadPart);
   Log('RWTimer ['+inttostr(rub.comd)+'] : '+FloatToStr((_c4.QuadPart-_c3.QuadPart)/_f.QuadPart));
 end;
end;



procedure TaMain.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
begin
// exit;
 if (Msg.message={WM_CHAR}WM_QUIT){and(Msg.wParam=ord('5'))} then ViewGraphicScanner(True);
end;


procedure TaMain.AnyTimerTimer(Sender: TObject);
var
 exception: word;
begin
 exception:= 0;
 TRY
   SpinEdit1.Value:=rbcp.InCount;
   SpinEdit2.Value:=rub.WBuf.Count;
   SpinEdit3.Value:=rbcp.ErrorCount;
   //
   StatusBar2.Panels[0].Text:= inttostr(wbcp.TOTALCOUNT);
   StatusBar2.Panels[1].Text:= inttostr(rbcp.TOTALCOUNT);
   //
   if (temp_Online <> rub.Online) or
      (temp_ErrorCode <> rub.ErrorCode) or
      (temp_WorkTime <> rub.WorkTime) then
   begin
     StatusBar2.Panels.Items[2].Text:='-';
     StatusBar2.Panels.Items[2].Text:='';
     StatusBar2.Panels.Items[3].Text:='-';
     StatusBar2.Panels.Items[3].Text:='';
     StatusBar2.Panels.Items[4].Text:='-';
     StatusBar2.Panels.Items[4].Text:='';
     temp_Online:= rub.Online;
     temp_ErrorCode:= rub.ErrorCode;
     temp_WorkTime:= rub.WorkTime;
   end;
   //
   exception:= 1;
   if option.ForceSendStateBlockMinute<>0 then
     if rub.WorkTime then
       if AutoBlockStateCount>0
         then dec(AutoBlockStateCount)
         else
         begin
           BlockStateToVU;
           AutoBlockStateCount:= round(60 * 1000/AnyTimer.Interval) * option.ForceSendStateBlockMinute;
         end;
   //
  exception:= 2;
  if option.SyncTime>0 then
  begin
    if ClockTimeCount>0 then
      dec(ClockTimeCount)
      else
      begin
        mSetClock(0);
        rub.SetTimeAllScu;
        ClockTimeCount:= round(option.SyncTime * 1000/AnyTimer.Interval);
      end;
  end;
  //
  exception:= 3;
  if rub.NeedSaveR8h then
    if SaveR8hCount>0
       then dec(SaveR8hCount)
       else
       begin
         rub.SaveR8h;
         SaveR8hCount:= round(option.SaveR8hSecInterval * 1000/AnyTimer.Interval);
         rub.NeedSaveR8h:= False;
       end;
  //
  exception:= 4;
  if TimerVisiblePause>0 then
    dec(TimerVisiblePause);
  //StatusBar1.Panels.Items[2].Text:= inttostr(TimerVisiblePause);
   //
  exception:= 5;
  SecondTic:= SecondTic + AnyTimer.Interval;
  if SecondTic>1000 then
  begin
    SecondTic:= 0;
    CheckPassPermit;
  end;
  //
  exception:= 6;
  if option.RstTCTime>0 then
  begin
    if ResetTCTimeCount>0 then
      dec(ResetTCTimeCount)
      else
      begin
        mBCPControl(ACTION_BCP_DMQCLEARTCO);
        ResetTCTimeCount:= round(option.RstTCTime * 1000/AnyTimer.Interval);
      end;
  end;



   //
 EXCEPT
   Log( Format('Exception(AnyTimerTimer:%d)', [exception] ) );
 END;
end;

procedure TaMain.AntiFreezTimerTimer(Sender: TObject);
begin
 AntiFreezTimer.Enabled:= false;
 case rub.Online of
   1:;
   else
   begin
     Log('SEND: Зависание модуля с генерацией потери связи с БЦП ('+inttostr(rub.comd)+')','ForceLog');
     HaltTimer.Enabled:= true;
   end;
 end;//case
end;

procedure TaMain.ChecBox3Click(Sender: TObject);
begin
 if CheckBox3.Checked
   then RWTimer.Enabled:=true
   else RWTimer.Enabled:=false;
end;



procedure TaMain.HaltTimerTimer(Sender: TObject);
var
  mes : KSBMES;
begin
 Log('SEND: Экстренный останов модуля с генерацией потери связи с БЦП ('+inttostr(rub.comd)+')','ForceLog');
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=rub.NetDevice;
 mes.BigDevice:=rub.BigDevice;
 mes.TypeDevice:=4;
 mes.Code:= R8_CONNECT_FALSE;
 Send(mes);
 //Log( Format( 'Останов модуля! (Нет связи)', [] ) );
 SelfClose;
 //PostMessage(Handle, WM_QUIT, 0, 0);
end;


procedure TaMain.Log(str: string; param: string='');
var
  i: word;
  len: LongWord;
begin
 Try
   if (option.LogFile)or(param='ForceLog') then
     WriteLog(str);
   if (option.LogForm and Visible)or(param='ForceLog') then
   begin
     Memo1.Lines.Add(DateTimeToStr(Now) +' '+ str);
     StatusBar3.Panels[0].Text:= DateTimeToStr(Now) +'  '+ str;
     StatusBar3.Hint:= 'Последний ответ от БЦП: ' + StatusBar3.Panels[0].Text;
   end;
   //
   if memo1.Lines.Count>500 then       //!!!!!!!!!!
   begin
     len:= 0;
     for i:=0 to 399 do
       len:= len + word(length(Memo1.Lines[i]));
     Memo1.SelStart:= 0;
     Memo1.SelLength:= len;
     memo1.ClearSelection;
     SendMessage(Memo1.Handle,WM_VSCROLL,SB_BOTTOM,0)
   end;
   //
 Finally
 End;
end;


procedure TaMain.Button6Click(Sender: TObject);
begin
 RWTimerTimer(nil);
end;


procedure TaMain.Button7Click(Sender: TObject);
begin
 inherited;
 RWTimer.Interval:= strtoint(Edit12.Text);
end;

procedure TaMain.N64Click(Sender: TObject);
begin
 ReadParam;
 UpdateParamListBox;
end;

procedure TaMain.WriteLog(str: string);
var
  tf: TextFile;
  SysTime: SYSTEMTIME;
  FileName, OldFileName, CurDir, OldDir, s: string;
  AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond: word;
  hFile, fileSize: Integer;

begin
 FileName:= ExtractFileName(Application.ExeName);
 SetLength(FileName, Length(FileName)-4);
 FileName:= FileName + '.log';
 CurDir:= ReadPath();
 //
 FileName:= Format('NET%uBIG%u.log',[rub.NetDevice, rub.BigDevice]);
 CurDir:= ReadPath();
 //
 hFile:= FileOpen(CurDir + FileName, fmOpenRead);
 fileSize:= GetFileSize(hFile, nil);
 FileClose(hFile);
 if fileSize>MAX_LOG_SIZE then
 begin
   OldFileName:= FileName;
   DecodeDateTime (now, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
   s:= '_' + Format('%u%.2u%.2u_%.2u%.2u_%.2u%.3u', [AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond]);
   Insert(s, OldFileName, length(OldFileName)-3);
   //
   OldDir:= ReadPath() + 'DrvRubejOldFiles\';
   if not DirectoryExists(OldDir) then
     CreateDir(OldDir);
   //
   if not RenameFile (CurDir + FileName, OldDir + OldFileName) then
     str:= str + #13#10' Ошибка переименования: '+ IntToStr(GetLastError);
 end;
 //
 AssignFile(tf, CurDir + FileName);
 TRY
   if FileExists(CurDir + FileName)
     then Append(tf)
     else rewrite(tf);
   GetLocalTime(SysTime);
   Inc(LogCount);
   Writeln
     (tf,
     Format('%u-%.2u/%.2u/%.4u-%.2u:%.2u:%.2u ',
     [LogCount, SysTime.wDay, SysTime.wMonth, SysTime.wYear, SysTime.wHour, SysTime.wMinute, SysTime.wSecond] ) + str
     );
   Flush(tf);
 FINALLY
   CloseFile(tf);
 END;
end;

//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
function GetFileVersion(FileName: string; var VerInfo : TVSFixedFileInfo): boolean;
var
  InfoSize, puLen: DWORD;
  Pt, InfoPtr: Pointer;
begin
  InfoSize := GetFileVersionInfoSize( PChar(FileName), puLen );
  FillChar(VerInfo, SizeOf(TVSFixedFileInfo), 0);
  if InfoSize > 0 then
  begin
    GetMem(Pt,InfoSize);
    GetFileVersionInfo( PChar(FileName), 0, InfoSize, Pt);
    VerQueryValue(Pt,'\',InfoPtr,puLen);
    Move(InfoPtr^, VerInfo, sizeof(TVSFixedFileInfo) );
    FreeMem(Pt);
    Result := True;
  end
  else
   Result := False;
end;


function ShowVersion(FileName:string): string;
var
VerInfo : TVSFixedFileInfo;
begin
  if GetFileVersion(FileName, VerInfo) then
  Result:=Format('%u.%u.%u.%u',[HiWord(VerInfo.dwProductVersionMS), LoWord(VerInfo.dwProductVersionMS),
  HiWord(VerInfo.dwProductVersionLS), LoWord(VerInfo.dwProductVersionLS)])
  else
  Result:='UNKNOWN';
end;


//Проверка версии
procedure TaMain.StatusBar1DblClick(Sender: TObject);
begin
 try
 ClientSocket1.Open;
 SendCommand:= REQUEST_VV + Application.Title + '.exe';
 except
 end;
 //memo1.Lines.Add( 'Доступно обновление вер. ' + ShowVersion(Option.UC) );
end;


//Проверка обновления
procedure TaMain.UCTimerTimer(Sender: TObject);
begin 
 try
 ClientSocket1.Open;
 SendCommand:= REQUEST_GV + Application.Title + '.exe';
 except
 end;
end;


// Т Е С Т
//Отправка запроса
procedure TaMain.SendSocketTimerTimer(Sender: TObject);
begin
 if SendCommand = '' then
 exit;
 if not ClientSocket1.Active then
 exit;
 try
   //memo1.Lines.Add('>> Отправка запроса');
   IsRecStart := True;
   ClientSocket1.Socket.SendText(SendCommand);
 except
 end;
 SendCommand:= '';
end;


//сбой
procedure TaMain.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
 //Application.MessageBox(PChar('ErrorCode = ' + inttostr(ErrorCode)), 'Look', MB_OK);
 ErrorCode:=0;
 Socket.Close;
end;


//Чтение ответа
procedure TaMain.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
var
  Buf: ^Byte;
  Length: LongInt;

begin
  if IsRecStart then                 //Начало приема данных?
  begin
    msRead.Clear;
    IsRecStart := False;
  end;
  //
  Length := Socket.ReceiveLength;
  GetMem(Buf, Length);               //Резервируем буфер
  Socket.ReceiveBuf(Buf^, Length);   //Получаем данные
  msRead.Write(Buf^, Length);
  FreeMem(Buf, Length);              //Освобождаем буфер
  //
  memo1.Lines.Add(' >>> Buf^ = ' + inttostr(Length));
  TimerWaitEnd.Enabled := False;     //Прекращаем отсчет времени
  TimerWaitEnd.Enabled := True;      //Включаем отсчет времени
end;


//Формирование конца приема (Принятая посылка)
procedure TaMain.TimerWaitEndTimer(Sender: TObject);
var
  s: string;
  i: word;
  b: byte;
  s1, s2: string;
  fs: TFileStream;

begin
 TimerWaitEnd.Enabled := False;
 IsRecStart := True;
 if ClientSocket1.Active then
 ClientSocket1.Close;
 //
 if (msRead.Size=0) then
 exit;
 //
 msRead.Position:=0;

 s:='';
 for i:=0 to msRead.Size-1 do
 begin
   msRead.Read(b, 1);
   s:= s + chr(b);
 end;
 memo1.Lines.Add('>>> Отладка: ' + s);
 //
 i:= pos(REQUEST_GV, s);
 if i=1 then
 begin
   Delete(s, 1, length(REQUEST_GV) );
   s1:= s;
   s2:= ShowVersion (Application.ExeName);
   if (s1='UNKNOWN')or(s2='UNKNOWN')or(s1=s2) then
   exit;
   ClientSocket1.Open;
   SendCommand:= REQUEST_GF + Application.Title + '.exe';
   memo1.Lines.Add('Версия = ' + s1);
 end;
 //
 i:= pos(REQUEST_GF, s);
 if i=1 then
 begin
   fs:= TFileStream.Create(Application.Title + '.tmp', fmCreate);
   msRead.Position := length(REQUEST_GF);
   fs.CopyFrom(msRead, msRead.Size - msRead.Position);
   memo1.Lines.Add('fs.Size = ' + inttostr(fs.Size));
   FreeAndNil(fs);
 end;
 //
 {
 TRY
   AssignFile(f, 'update.bat');
   ReWrite(f);
   WriteLn(f, 'copy '+ Option.UC);
   WriteLn(f, 'start ' + Application.Title + '.exe');
   WriteLn(f, 'del update.bat');
   CloseFile(f);
   Winexec('update.bat', SW_HIDE);
   halt;
 EXCEPT
 END;
}

  {AssignFile(NewFile,
    Application.Title + '.tmp');     //Готовим файл
  if IsRecStart then                 //Начало приема данных?
  begin                              //-Да:
    Rewrite(NewFile, 1);             //Создаем новый файл
    IsRecStart := False              //Сбрасываем признак начала приема
  end
  else
  begin                              //-Нет, продолжение приема
    Reset(NewFile, 1)  ;             //Открываем файл
    Seek(NewFile, FileSize(NewFile)) //Переходим к его концу
  end;
  //
  BlockWrite(NewFile, Buf^, Length); //Пишем в файл
  CloseFile(NewFile); }               // и закрываем его

   {
   new(Buf);
   ms.Read(Buf^, 4);
   lInt:= Buf^;
   Dispose(Buf);
   }

end;



procedure TaMain.IdHTTPServer1CommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
 s : string;

begin
 s:= ARequestInfo.Document;
 Delete(s, 1, 1);
 try
   if s <>''
   then AResponseInfo.ContentStream:=TFileStream.Create ('c:\uc\' + s ,fmOpenRead)
   else AResponseInfo.ContentStream:=TFileStream.Create ('c:\uc\' + 'Index.html',fmOpenRead);
 except
   AResponseInfo.ContentStream:=TFileStream.Create ('c:\uc\' + 'NotResponse.html',fmOpenRead);
 end;
 memo1.Lines.Add(' >> ' + s);
 //AResponseInfo.ContentStream.Free;
end;

procedure TaMain.StatusBar2DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
var
  w: integer;
  s: string;
begin
  case Panel.Index of
  2:
  begin
    case rub.Online of
      0:
      begin
        StatusBar.Canvas.Brush.Color:= clRed;
        s:= 'Нет связи';
      end;
      1:
      begin
        StatusBar.Canvas.Brush.Color:= clBtnFace;
        s:= 'На связи';
      end;
      else
      begin
        StatusBar.Canvas.Brush.Color:= clBtnFace;
        s:= 'Н/Д';
      end;
    end;//case
    //
    StatusBar.Canvas.Brush.Style:= bsSolid;
    StatusBar.Canvas.Pen.Style:= psSolid;
    StatusBar.Canvas.Pen.Color:= clBtnFace;//clBlack;
    StatusBar.Canvas.FillRect(Rect);

    StatusBar.Canvas.Font.Color:= clBlack;
    w:= StatusBar.Canvas.TextWidth(s);
    StatusBar.Canvas.TextOut(Rect.Left + (Rect.Right-Rect.Left-w) div 2, Rect.Top, s);
  end;

  3:
  begin
    if rub.Online<>1 then
    begin
      StatusBar.Canvas.Brush.Color:= clBtnFace;
      s:= 'Н/Д';
    end
    else
      if rub.ErrorCode=$FF then
      begin
        StatusBar.Canvas.Brush.Color:= clBtnFace;
        s:= 'Норма';
      end
      else
      begin
        StatusBar.Canvas.Brush.Color:= clYellow;
        s:= 'Ошибка №' + inttostr(rub.ErrorCode);
      end;
    //
    StatusBar.Canvas.Brush.Style:= bsSolid;
    StatusBar.Canvas.Pen.Style:= psSolid;
    StatusBar.Canvas.Pen.Color:= clBtnFace;
    StatusBar.Canvas.FillRect(Rect);
    StatusBar.Canvas.Font.Color:= clBlack;
    w:= StatusBar.Canvas.TextWidth(s);
    StatusBar.Canvas.TextOut(Rect.Left + (Rect.Right-Rect.Left-w) div 2, Rect.Top, s);
  end;

  4: begin
    case rub.WorkTime of
    FALSE: begin
      StatusBar.Canvas.Brush.Color:= clBtnFace;
      s:='Старт...';
    end
    else begin
      StatusBar.Canvas.Brush.Color:= clBtnFace;
      s:='Норма';
    end;
    end;
    //
    StatusBar.Canvas.Brush.Style := bsSolid;
    StatusBar.Canvas.Pen.Style:= psSolid;
    StatusBar.Canvas.Pen.Color:= clBtnFace;
    StatusBar.Canvas.FillRect(Rect);
    StatusBar.Canvas.Font.Color := clBlack;
    w:= StatusBar.Canvas.TextWidth(s);
    StatusBar.Canvas.TextOut(Rect.Left + (Rect.Right-Rect.Left-w) div 2, Rect.Top, s);
  end;

  end;//case Panel.Index
end;

procedure TaMain.N4Click(Sender: TObject);
begin
 close;
end;

procedure TaMain.ABlend (var Message: TMessage);
begin
 case Message.WParam of
   0: AlphaBlend:= true;
   1: AlphaBlend:= false;
 end;
end;


procedure TaMain.StatusBar2MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
 w: array [0..4] of word;
begin
 w[0]:= TStatusBar(Sender).Panels[0].Width;
 w[1]:= w[0] + TStatusBar(Sender).Panels[1].Width;
 w[2]:= w[1] + TStatusBar(Sender).Panels[2].Width;
 w[3]:= w[2] + TStatusBar(Sender).Panels[3].Width;
 w[4]:= w[3] + TStatusBar(Sender).Panels[4].Width;
 if x < w[0] then
 TStatusBar(Sender).Hint:= 'Передано в БЦП' else
 if x < w[1] then
 TStatusBar(Sender).Hint:= 'Принято от БЦП' else
 if x < w[2] then
 TStatusBar(Sender).Hint:= 'Связь с БЦП' else
 if x < w[3] then
 TStatusBar(Sender).Hint:= 'Состояние БЦП' else
 if x < w[4] then
 TStatusBar(Sender).Hint:= 'Состояние драйвера' else
 TStatusBar(Sender).Hint:= '';
end;


procedure TaMain.FormConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: Integer);
var
 i: word;
begin
 MinHeight:= 26 + StatusBar1.Height + StatusBar2.Height + StatusBar3.Height;
 MinWidth:= 25;
 for i:=0 to 4 do
   MinWidth:= MinWidth + StatusBar2.Panels[i].Width;
 MinHeight:= MinHeight + 20;
end;


procedure TaMain.N8Click(Sender: TObject);
begin
 if memo1.Lines.Count=0 then
 exit;
 Clipboard.Clear;
 memo1.SelectAll;
 memo1.CopyToClipboard;
 memo1.ClearSelection;
end;

procedure TaMain.N9Click(Sender: TObject);
begin
 //if MessageBox(0, 'Очистить окно сообщений?', 'Внимание', MB_OKCANCEL or MB_DEFBUTTON2 or MB_SYSTEMMODAL or MB_ICONQUESTION)=IDOK then
 memo1.Clear;
end;

procedure Debug (s: string);
var
 sTime: string;
 position: byte;

begin
 case option.Logged_Debug of
   1: //Вывод имен функций
   begin
     QueryPerformanceFrequency(_f.QuadPart);
     QueryPerformanceCounter(_c2.QuadPart);
     sTime:= FloatToStr((_c2.QuadPart-_c1.QuadPart)/_f.QuadPart);
     position:= pos(',', sTime);
     Delete(sTime, position+3, length(sTime)-position-3);
     _c1:= _c2;
     //aMain.Log('Debug_('+inttostr(rub.comd)+')'+s+' > Tic='+sTime);
     aMain.Log( Format('Debug_(%d %d  %d) %s  %s', [ rub.comd, rub.Wbuf.Count, rub.WaitCount, s, sTime ]) );
   end;
 end; //case
end;


procedure TaMain.SmartCUSend (SmallDevice, Code: word);
var
 mes: KSBMes;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= rub.NetDevice;
 mes.BigDevice:= rub.BigDevice;
 mes.TypeDevice:= 9;
 mes.SmallDevice:= SmallDevice;
 mes.Code:= Code;
 send(mes);
end;




{
Побитные состояния зон/ШС:
для ОПС  <с - o - н - т - в - г>
для техн. <с - o - н - т - 2 - 1>,
где:
с - связь
о - опрос включен
н - неисправность
т - тревога
в - взятие
г - готовность
1 - первый бит номера области
2 - второй бит номера области
}

procedure TaMain.N3Click(Sender: TObject);
var
 tn: TTreeNode;
 st: string;
 v: ^TMesRec;
 mes: KSBMES;
 data: PChar;
 l: array[0..127] of Byte;
 ptc: PTTC;
 pzn: PTZN;
 pcu: PTCU;
 m: array [0..1] of byte;
 wTemp: word;

begin
 data:='';
 tn:= TreeView1.Selected;
 if tn=nil then
 exit;
 //
 {st:= Format('SelectedIndex=%d, StateIndex=%d, ImageIndex=%d',
 [ tn.SelectedIndex, tn.StateIndex, tn.ImageIndex ]);
 Memo3.Lines.Add(st);}
 //
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=rub.NetDevice;
 mes.BigDevice:=rub.BigDevice;
 FillChar(l,128,0);

 st:='';
 case tn.SelectedIndex of

   11: mes.Code:= R8_COMMAND_CLEARSYSERROR;
   12: mes.Code:= R8_COMMAND_STARTCHECKCONFIG;
   13: mSetClock(0);
   14: mBCPControl(ACTION_BCP_ALLUSERAPBRESET);
   15: DeleteUserZeroAL;

   21:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);
     pcu:= rub.FindCU(wTemp , 1);
     if pcu<>nil
       then StateString(0, pcu, pcu^.State, st)
       else st:= 'СУ №' + IntToStr(wTemp) + ' нет';
   end;//21

   31:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);
     m[0]:= lo(wTemp);
     m[1]:= hi(wTemp);
     pzn:= rub.FindZN(m, 1);
     if pzn<>nil
       then StateString(1, pzn, pzn^.State, st)
       else st:= 'Зоны №' + IntToStr(wTemp) + ' нет';
   end;//31

   41:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);
     ptc:= rub.FindTC(wTemp , 3);
     if ptc<>nil
       then StateString(2, ptc, ptc^.State, st)
       else st:= 'ШС №' + IntToStr(wTemp) + ' нет';
   end;//41

   51:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);
     ptc:= rub.FindTC(wTemp, 4);
     if ptc<>nil
       then StateString(2, ptc, ptc^.State, st)
       else st:= 'Реле №' + IntToStr(wTemp) + ' нет';
   end;//51

   61:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);
     ptc:= rub.FindTC(wTemp, 9);
     if ptc<>nil
       then StateString(2, ptc, ptc^.State, st)
       else st:= 'ТД №' + IntToStr(wTemp) + ' нет';
   end;//61  APStateToRostek

   62:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);
     ptc:= rub.FindTC(wTemp, 9);
     if ptc<>nil
       then StateString(3, ptc, 0, st)
       else st:= 'ТД №' + IntToStr(wTemp) + ' нет';
   end;//62

   63: mes.Code:= R8_COMMAND_AP_UNLOCK;
   64: mes.Code:= R8_COMMAND_AP_LOCK;
   65: mes.Code:= R8_COMMAND_AP_PASS;
   66: mes.Code:= R8_COMMAND_AP_RESET;

   71:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);
     ptc:= rub.FindTC(wTemp, 7);
     if ptc<>nil
       then StateString(2, ptc, ptc^.State, st)
       else st:= 'Терминала №' + IntToStr(wTemp) + ' нет';
   end;//71

   81: mes.Code:= SCU_GET_DEVVER;
   82: mes.Code:= SCU_GET_BOOTVER;
   83: mes.Code:= SCU_GET_STATEWORD;
   84: mes.Code:= SCU_GET_DEVSTATE;
   85: mes.Code:= SCU_TIME_GET;
   86: mes.Code:= SCU_TIME_EDIT;
   87: mes.Code:= SCU_NETWORK_GET;
   88: mes.Code:= SCU_NETWORK_EDIT;
   89: mes.Code:= SCU_PRG_DATA;

   91: mes.Code:= SCU_SHOCHR_ARM;
   92: mes.Code:= SCU_SHOCHR_DISARM;
   93: mes.Code:= SCU_SHOCHR_RESET;
   94: mes.Code:= SCU_SHTREV_RESET;
   95: mes.Code:= SCU_SHFIRE_RESET;
   96: mes.Code:= SCU_TC_RESTORE;
   101: mes.Code:= SCU_RELAY_1;
   102: mes.Code:= SCU_RELAY_0;
   103: mes.Code:= SCU_TC_RESTORE;
   111: mes.Code:= SCU_AP_UNLOCK;
   112: mes.Code:= SCU_AP_LOCK;
   113: mes.Code:= SCU_AP_PASS;
   114: mes.Code:= SCU_AP_RESET;

   121: rub.SetTimeAllScu;
   122: mes.Code:= SCU_USERMAP_WR_PERMIT;
   123: mes.Code:= SCU_USERMAP_WR_ALL;

   201: BlockStateToVU;
   202: rub.SaveR8h;
   203: rub.CfgToCsv;
   204:
   begin
     BCPConf:= TBCPConf.Create(self);
     BCPConf.DS1.Enabled:= True;
     ReadBCPConfFromCsv;
     BCPConf.ShowModal;
     BCPConf.Free;
   end;
   205: //изм.96
   if rub.CU.Count>0 then //переход на чтение состояний СУ
   begin
     rub.comd:= 21;
     rub.TempIndex:=0; //для использования CU.Items[TempIndex]
   end
   else
   if rub.TC.Count>0 then //переход на чтение состояний ТС
   begin
     rub.comd:= 23;
     rub.TempIndex:=0; //для использования CU.Items[TempIndex]
   end;

   206: rub.WriteBcpFile;
   207:
   if MessageBox(0, 'Передать конфигурацию в БЦП ?'+#13+'Это прведет к ПЕРЕЗАПИСИ конфигурации БЦП !!!', 'Внимание', MB_OKCANCEL or MB_DEFBUTTON2 or MB_TASKMODAL or MB_ICONQUESTION) = IDOK then
   begin
     //aMain.Log('Старт очистки конфигурации БЦП');
     RWTimer.Enabled:= False;
     rub.ClearWBuf; // на свякий случай
     mDeleteRPs;
     mDeleteRNs;
     mDeleteUsers;
     mDeletePrava;
     mDeleteZones;
     mDeleteGRs;
     mDeleteTimeIntervals;
     mDeleteHDs;
     mInCfgCUs;
     mDeleteCUs;
     mOutCfgCUs;
     RWTimer.Enabled:= True;
     rub.comd:= 201;
   end;
   208:
   begin
     wTemp:= StrToInt(VLE1.Values['Объект']);   
     BlockStateToVU(True, byte(wTemp));
   end;


 end;
 //
 if mes.Code>0 then
 begin
   case mes.Code of
     R8_COMMAND_AP_UNLOCK,
     R8_COMMAND_AP_LOCK,
     R8_COMMAND_AP_PASS,
     R8_COMMAND_AP_RESET:
     begin
       mes.TypeDevice:= 2;
       mes.SmallDevice:= StrToInt(VLE1.Values['Объект']);
       TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', StrToInt(VLE1.Values['Пользователь']));
     end;
     R8_COMMAND_CLEARSYSERROR,
     R8_COMMAND_STARTCHECKCONFIG:
     begin
       mes.TypeDevice:=4;
     end;
     SCU_GET_DEVVER,
     SCU_GET_BOOTVER,
     SCU_GET_STATEWORD,
     SCU_GET_DEVSTATE,
     SCU_TIME_GET,
     SCU_TIME_EDIT,
     SCU_NETWORK_GET,
     SCU_NETWORK_EDIT,
     SCU_PRG_DATA,
     SCU_SHOCHR_ARM,
     SCU_SHOCHR_DISARM,
     SCU_SHOCHR_RESET,
     SCU_SHTREV_RESET,
     SCU_SHFIRE_RESET,
     SCU_TC_RESTORE,
     SCU_RELAY_1,
     SCU_RELAY_0,
     SCU_AP_UNLOCK,
     SCU_AP_LOCK,
     SCU_AP_PASS,
     SCU_AP_RESET,
     SCU_USERMAP_WR_PERMIT,
     SCU_USERMAP_WR_ALL:
     begin
       mes.TypeDevice:=132;
     end;
   end;//case
   //
   new(v);
   move(mes, v^.m, sizeof(KSBMES));
   v^.s:= Bin2Simbol(PChar(@l[0]), mes.Size);
   case v^.m.Code of
    9801..9999: scu.MesBuf.Add(v);
    else ConsiderBCP(mes, '');
   end;
 end;//case
 //
 if st<>'' then
 Log(st);
end;


procedure TaMain.PageControl1Change(Sender: TObject);
begin
 case PageControl1.ActivePageIndex of
   0: Memo1.Parent:= TabSheet3;
   2: Memo1.Parent:= Panel6;
 end;
end;


procedure TaMain.VLE1GetEditMask(Sender: TObject; ACol, ARow: Integer;
  var Value: String);
begin
 if ACol=1 then
 case ARow of
   6..8: Value:='000.000.000.000';
 end;
end;

procedure TaMain.StateString(TypeSource: word; Source: pointer; State: word; var Result: string);
var
 ptc: ^TTC;
 pzn: ^TZN;
 pcu: ^TCU;
 st: string;

begin
 st:='';

 case TypeSource of

   0: //СУ
   begin
     pcu:= Source;
     st:= Format('СУ №%d [%s:%d]', [ pcu^.Number, HWTypeToStr(pcu^.HWType), pcu^.HWSerial ]) + st;
     if (State and $01)>0
       then st:= st +' Подключено'
       else st:= st +' Отключено';
     if (State and $01)>0 then
     if (State and $02)>0
       then st:= st + ' Вскрыто'
       else st:= st + ' Закрыто';
   end;

   1: //Зона
   begin
     pzn:= Source;
     st:= Format('Сост. зоны № %d ', [pzn^.Number]) + Result;
     if (State and $40)>0 then st:= st + ' Неизв.'
       else
       begin
         if (State and $28)>0 then st:= st + ' Неиспр.';
         if (State and $10)>0 then st:= st + ' Откл.';
         if (State and $04)>0 then st:= st + ' Тревога';
         if (State and $02)>0 then st:= st + ' Охрана ';
         if (State and $01)>0 then st:= st + ' Готова' else st:= st + ' Не готова';
       end;
   end;

   2: //ТС
   begin
     ptc:= Source;
     case ptc^.Kind of
       1..3:
       begin
         st:= Format('Сост. ШС №%d [%.5d] ', [ptc^.ZoneVista, ptc^.Sernum]) + Result;
         if (State and $40)>0 then st:= st + ' Неизвестно'
           else if (State and $20)>0 then st:= st + ' Неиспр. об.'
             else if (State and $10)>0 then st:= st + ' Откл.'
               else
               begin
                 if (State and $08)>0 then st:= st + ' Неиспр.';
                 if (State and $04)>0 then st:= st + ' Тревога';
                 if (State and $02)>0 then st:= st + ' Охрана';
                 if (State and $01)>0 then st:= st + ' Готов' else st:= st + ' Не готов';
               end;
       end;
       4:
       begin
         st:= Format('Сост. ШС №%d [%.5d] ', [ptc^.ZoneVista, ptc^.Sernum]) + Result;
         if (State and $40)>0 then st:= st + ' Неизвестно'
           else if (State and $20)>0 then st:= st + ' Неиспр. об.'
             else if (State and $10)>0 then st:= st + ' Откл.'
               else
               begin
                 if (State and $08)>0 then st:= st + ' Неиспр.';
                 if (State and $04)>0 then st:= st + ' Тревога';
                 st:= st + ' Область №'+inttostr(State and $03);
               end;
       end;
       5:
       begin
         st:= Format('Сост. реле №%d [%.5d] ', [ptc^.ZoneVista, ptc^.Sernum]) + Result;
         if (State and $40)>0 then st:= st + ' Неизвестно'
           else if (State and $20)>0 then st:= st + ' Неиспр. об.'
             else if (State and $10)>0 then st:= st + ' Откл.'
               else
               begin
                 if (State and $08)>0 then st:= st + ' Неиспр.';
                 if (State and $04)>0 then st:= st + ' Тревога';
                 if (State and $02)>0
                   then st:= st + ' вкл. '
                   else st:= st + ' выкл. ';
               end;
       end;
       6:
       begin
         st:= Format('Сост. ТД №%d [%.5d] ', [ptc^.ZoneVista, ptc^.Sernum]) + Result;
         if (State and $40)>0 then st:= st + ' Неизвестно'
           else if (State and $20)>0 then st:= st + ' Неиспр. об.'
             else if (State and $10)>0 then st:= st + ' Откл.'
               else if (State and $08)>0 then st:= st + ' Неиспр.'
                 else
                 case State of
                   1: st:= st + ' Норма';
                   2: st:= st + ' Дверь открыта';
                   3: st:= st + ' Дверь не закрыта';
                   4: st:= st + ' Взлом';
                   5: st:= st + ' Заблокирована';
                   6: st:= st + ' Разблокирована';
                   7: st:= st + ' Нападение';
                 end;
         st:= st + Format (' (РОСТЭК=%d)', [ APStateToRostek(ptc) ]);
       end;
       7:
       begin
         st:= Format('Сост. терм. №%d [%.5d] ', [ptc^.ZoneVista, ptc^.Sernum]) + Result;
         if (State and $40)>0 then st:= st + ' Неизвестно'
           else if (State and $20)>0 then st:= st + ' Неиспр. об.'
             else if (State and $10)>0 then st:= st + ' Откл.'
               else
               begin
                 if (State and $08)>0 then st:= st + ' Неиспр.';
                 if (State and $04)>0 then st:= st + ' Тревога. Попытка подбора кода';
                 if (State and $02)>0 then st:= st + ' Заблокирован';
                 if (State and $01)>0 then st:= st + ' Готов' else st:= st + ' Не готов';
               end;
       end;//7

       else st:= 'Ошибка 75A26-6000878080E: неизвестный тип ТС';
     end;//case Kind
   end; //ТС

   3: //ТД режим
   begin
     ptc:= Source;
     if ptc^.Kind=6 then
     begin
       st:= Format('Режим ТД №%d [%.5d] ', [ptc^.ZoneVista, ptc^.Sernum]) + Result;
       case (ptc^.ConfigDummy[0] shr 1) and $03 of
         0: st:= st + Format('Код или Карта (%d)', [ APModeToRostek(ptc) ]);
         1: st:= st + Format('Код и Карта (%d)', [ APModeToRostek(ptc) ]);
         2: st:= st + Format('Карта и Дверной код (%d)', [ APModeToRostek(ptc) ]);
         else st:= st + Format('Дверной код (%d)', [ APModeToRostek(ptc) ]);
       end;
     end; //if
   end;//3


   else st:= 'Ошибка 38FEE578080E: неизвестный тип объекта';

 end;//case TypeSource

 Result:= st;
end;


procedure SetShZmkRule(idAP, idSH: word);
var
  rule: TRule;
  s: string;
begin
  //добавление правила
  s:= Format('ШСЗМК,%d,%d', [idAP, idSH]);
  if FindRule(s)=nil then
    if StrToRule(s, rule) then
    begin
      AddRule(rule);
      SaveR8c('ПРАВИЛА', rule.TextRule, '1');
    end;
end;


procedure DelShZmkRule(idAP: word);
var
  pRule: ^TRule;
  i: word;
begin
  i:=0;
  while (lRule.Count>0)and(i<lRule.Count) do
  begin
    pRule:= lRule.Items[i];
    if pRule^.Func='ШСЗМК' then
    if pRule^.Arg[1]=idAP then
    begin
      //удаление правила
      DeleteR8c('ПРАВИЛА', pRule^.TextRule);
      DelRule(pRule);
      continue;
    end;
    inc(i);
  end;
end;


procedure SetAnyCardMode(idAP: word; IdVar: byte);
var
  rule: TRule;
  s: string;
begin
  //добавление правила
  if (idAP mod 2)>0
    then s:= Format('РЕЖИМЛК,%d,%d,%d', [idAP, idVar, idAP])
    else s:= Format('РЕЖИМЛК,%d,%d,%d', [idAP, idVar, idAP-1]);
  if FindRule(s)=nil then
    if StrToRule(s, rule) then
    begin
      AddRule(rule);
      SaveR8c('ПРАВИЛА', rule.TextRule, '1');
    end;
  //запись в Var
  mSetVar(idVar, 1, 0);
end;


procedure DelAnyCardMode(idAP: word);
var
  pRule: ^TRule;
  i: word;
begin
  i:=0;
  while i<lRule.Count do
  begin
    pRule:= lRule.Items[i];
    if pRule^.Func='РЕЖИМЛК' then
    if pRule^.Arg[1]=idAP then
    begin
      //запись в Var
      mSetVar(pRule^.Arg[2], 0, 0);
      //удаление правила
      DeleteR8c('ПРАВИЛА', pRule^.TextRule);
      DelRule(pRule);
      continue;
    end;
    inc(i);
  end;

  {
  pRule:= nil;
  if lRule.Count>0 then
    for i:=0 to lRule.Count-1 do
    begin
      pRule:= lRule.Items[i];
      if pRule^.Func='РЕЖИМЛК' then
      if pRule^.Arg[1]=idAP then
        break;
      pRule:= nil;
    end;

  if pRule<>nil then
  begin
    //запись в Var
    mSetVar(pRule^.Arg[2], 0, 0);
    //удаление правила
    DeleteR8c('ПРАВИЛА', pRule^.TextRule);
    DelRule(pRule);
  end;
  }

end;


function FindRule(s: String): pointer;
var
 pRule: ^TRule;
 i: word;
begin
  Result:= nil;
  if lRule.Count>0 then
    for i:=0 to lRule.Count-1 do
    begin
      pRule:= lRule.Items[i];
      if pRule^.TextRule=s then
      begin
        Result:= pRule;
        break;
      end;
    end;
end;


function StrToRule(s: string; var rule: TRule): boolean;
var
 i, ps: word;
 s1, s2: string;
 code: integer;

begin
  Result:= False;
  s1:= s;
  FillChar(rule, sizeof(rule), 0);
  ps:= Pos(',', s1);
  if (ps=0)and(ps>17) then
    exit;
  rule.Func:= Copy(s1, 1, ps-1);
  Delete(s1, 1, ps);
  //
  i:=1;
  repeat
    ps:= Pos(',', s1);
    //
    if ps>1 then
    begin
      s2:= Copy(s1, 1, ps-1);
      Val(s2, rule.Arg[i], code);
      if (code<>0) then
        exit;
    end
    else
    begin
      Val(s1, rule.Arg[i], code);
      if (code<>0) then
        exit;
    end;
    //
    Delete(s1, 1, ps);
    rule.Arg[0]:= i;
    inc(i);
  until (ps=0)or(i>10);
  //
  rule.TextRule:= s;
  Result:= True;
end;


procedure AddRule(rule: TRule);
var
 pRule:^TRule;
begin
  new(pRule);
  move(rule, pRule^, sizeof(rule));
  lRule.Add(pRule);
end;


procedure DelRule(p: pointer);
var
 pRule: ^TRule;
begin
 pRule:= p;
 if pRule<>nil then
 begin
   lRule.Remove(pRule);
   Dispose(pRule);
 end;
end;


function ApplyPassRule(var mes: KSBMes): boolean;
var
  s: string;
begin
 Debug('F:ApplyPassRule');
 Result:= True;
 case mes.Code of
   {
   R8_ZONE_CREATE,
   R8_ZONE_CHANGE,
   R8_ZONE_DELETE,
   R8_UD_CREATE,
   R8_UD_CHANGE,
   R8_UD_DELETE,
   R8_CU_CREATE,
   R8_CU_DELETE,
   R8_GETTIME:
     mes.TypeDevice:= 1;
   }
   R8_TZ_CREATE,
   R8_TZ_CHANGE,
   R8_TZ_DELETE:
   begin
     mes.SysDevice:= SYSTEM_OPS;
     mes.TypeDevice:= 4;
     mes.Level:= mes.Mode;
   end;
   
   R8_AP_CREATE,
   R8_AP_CHANGE,
   R8_AP_DELETE,
   R8_GR_CREATE,
   R8_GR_DELETE,
   R8_AP_OFF,
   R8_AP_ON,
   R8_AP_RESTORE,
   SUD_SET_LINK_READER,
   SUD_LOST_LINK_READER,
   SUD_BAD_LEVEL:
   begin
     mes.SysDevice:= SYSTEM_SUD;
     mes.TypeDevice:= 2;
   end;
 end;//case

 case mes.Code of
   R8_AP_CREATE,
   R8_AP_CHANGE,
   R8_AP_DELETE,
   R8_GR_CREATE,
   R8_GR_CHANGE,
   R8_GR_DELETE:
   begin
     mes.SmallDevice:= mes.Mode;
   end;
 end;//case

 //При отвале (разбежка Т>30с) СКУ у событий ДР, ДЗ корректируется №карты,
 //Взломы, Удержания пропускаются
 //Остальные технологические события (ШС двери, замка) зануляются
 {
 if SecondsBetween(mes.SendTime, mes.WriteTime)>30 then
   case mes.Code of
     SUD_ACCESS_GRANTED,
     SUD_BAD_LEVEL,
     SUD_BAD_PIN,
     SUD_NO_CARD,
     SUD_ACCESS_CHOOSE:
       if (mes.NumCard>0)and(mes.NumCard<2000) then
       if rub.ScuUserMap[mes.NumCard]>0 then
       begin
         mes.NumCard:= rub.ScuUserMap[mes.NumCard];
         mes.User:= mes.NumCard;
       end;
     SUD_GRANTED_BUTTON,
     SUD_HELD,
     SUD_FORCED:;
     ELSE
     begin
       mes.Code:= 0;
       Result:= False;
     end;
   end;//case
 }

 case mes.Code of
   SUD_ACCESS_GRANTED,
   SUD_BAD_LEVEL,
   SUD_BAD_PIN,
   SUD_NO_CARD,
   SUD_ACCESS_CHOOSE:
   begin
     //
     {
     s:= IntToStr(mes.NumCard);         ///му !!!
     amain.Log(s);                      ///му !!!
     }
     //
     if (mes.NumCard>0)and(mes.NumCard<2000) then
       if SecondsBetween(mes.SendTime, mes.WriteTime)>20 then
       begin
         mes.Code:= 0;
         Result:= False;
       end;
   end;
 end;//case

 if mes.Code=SUD_ACCESS_CHOOSE then
 begin
   if (mes.SmallDevice mod 2)>0
     then s:= Format('РЕЖИМЛК,%d,%d,%d', [mes.SmallDevice, mes.SmallDevice, mes.SmallDevice])
     else s:= Format('РЕЖИМЛК,%d,%d,%d', [mes.SmallDevice, mes.SmallDevice, mes.SmallDevice-1]);
   amain.Log(s);            ///му
   if FindRule(s)<>nil then
   begin
     amain.Log('FindRule'); ///му
     mes.Code:= 0;
     Result:= False;
   end;
 end;

 //
end;


function ApplyAnyRule(var mes: KSBMES; var str: PChar): boolean;
// Правила
// ШСЗМК,1,2 - ШС питания замка [ТД, ШС]
// РЕЖИМЛК,50,50,49 - режим Любая карта [ТД, Var, ТДslave]
// МАСКШСДВ,2 - маскировка событий откр. двери [ТД]
// ШСКЭО,2 - нажатие кнопки КЭО [ШС]
var
  i: word;
  rule: ^TRule;
  tmes: KSBMES;
begin
  Debug('F:ApplyAnyRule');
  Result:= True;
  if lRule.Count=0 then
    exit;
  move(mes, tmes, sizeof(KSBMES));
  //
  for i:=0 to lRule.Count-1 do
  begin
    rule:= lRule.Items[i];
    //
    //ШСЗМК
    if rule^.Func = 'ШСЗМК' then
    if mes.SysDevice = SYSTEM_OPS then
    if mes.NetDevice = rub.NetDevice then
    if mes.BigDevice = rub.BigDevice then
    begin
      if mes.Mode = rule^.Arg[2] then
      case mes.Code of
        R8_SH_CREATE,
        R8_SH_CHANGE,
        R8_SH_DELETE:
        begin
          mes.SysDevice:= SYSTEM_SUD;
          mes.TypeDevice:= 2;
          mes.SmallDevice:= rule^.Arg[1];
          mes.Mode:= 0;
          case mes.Code of
            R8_SH_CREATE,
            R8_SH_CHANGE:
              mes.Code:= R8_APSHZMK_SET;
            R8_SH_DELETE:
              mes.Code:= R8_APSHZMK_DELETE;
          end;
        end;
      end;
      if mes.SmallDevice = rule^.Arg[2] then
      case mes.Code of
        R8_SH_READY,
        R8_SH_RESTORE,
        R8_SH_NOTREADY,
        R8_SH_OFF,
        R8_SH_ON:
        begin
          mes.SysDevice:= SYSTEM_SUD;
          mes.TypeDevice:= 2;
          mes.SmallDevice:= rule^.Arg[1];
          case mes.Code of
            R8_SH_READY:
              mes.Code:= PCE_OUTPUT_DISABLED;
            R8_SH_NOTREADY:
              mes.Code:= PCE_OUTPUT_ENABLED;
          end;
        end;
      end;
      if mes.Code=R8_APSHZMK_DELETE then
        DelShZmkRule(rule^.Arg[1]);
    end;
    //
    //РЕЖИМЛК
    if rule^.Func = 'РЕЖИМЛК' then
    begin
      if mes.SmallDevice = rule^.Arg[3] then
        if mes.Code=SUD_ACCESS_GRANTED then
          if mes.User=0 then
          begin
            mes.Code:= 0;
            Result:= False;
          end;
      if mes.SmallDevice = rule^.Arg[1] then
        if mes.Code=SUD_ACCESS_GRANTED then
          if mes.User>0 then
             mes.Code:= SUD_GRANTED_FACILITY;
      if mes.SmallDevice = rule^.Arg[1] then
        if mes.Code=SUD_BAD_LEVEL then
           mes.Code:= SUD_GRANTED_FACILITY;
    end;
    //
    //МАСКШСДВ
    if rule^.Func = 'МАСКШСДВ' then
    if mes.SmallDevice = rule^.Arg[1] then
    case mes.Code of
      SUD_DOOR_OPEN,
      SUD_DOOR_CLOSE:
        Result:= False;
    end;//case
    //
    //ШСКЭО
    if rule^.Func = 'ШСКЭО' then
    if mes.SysDevice = SYSTEM_OPS then
    if mes.NetDevice = rub.NetDevice then
    if mes.BigDevice = rub.BigDevice then
    if mes.SmallDevice = rule^.Arg[1] then
    if mes.Code=R8_SH_NOTREADY then
       mes.Code:= R8_SH_ALARM;
    //
    //
  end;//for
end;



function FindPassPermit(Number: word): pointer;
var
 i: word;
 aperm:^ TPassPermit;

begin
  Debug('F:FindPassPermit');
  Result:= nil;
  if lPassPermit.Count>0 then
  for i:=0 to lPassPermit.Count-1 do
  begin
    aperm:= lPassPermit.items[i];
    if aperm^.ApNumber=Number then
    begin
      Result:= aperm;
      break;
    end;
  end;
end;


function PassPermitEvent(var mes: KSBMES; var str: PChar): boolean;
var
 aperm: ^TPassPermit;
 s: string;
begin
  Debug('F:PassPermitEvent');
  //по событию ДР ищется TPassPermit
  //    если нет, то создается класс TPassPermit,
  //    если найден, то рестартуется существующий
  //по событию Открыто
  //    ничего не происходит
  //    либо по ситуации (если время <= (Тзамка+10)) выдается "Проход совершен", удаляется ДР
  //по событиям Удержание, Взлом, Заблокирована, Разблокирована, Нападение
  //    удаляется (если есть) ДР с выдачей "Проход не совершен"
  //
  //
  Result:= False;
  //
  if SecondsBetween(mes.SendTime, mes.WriteTime)>30 then
    exit;
  //
  case mes.Code of

    SUD_ACCESS_GRANTED,
    SUD_GRANTED_FACILITY:
    begin
      aperm:= FindPassPermit(mes.SmallDevice);
      if aperm=nil then
      begin
        New(aperm);
        lPassPermit.Add(aperm);
      end;
      aperm^.ApNumber:= mes.SmallDevice;
      aperm^.NoPassTime:= 5+10;
      aperm^.UserNumber:= mes.NumCard;
    end;

    SUD_DOOR_OPEN:
    begin
      aperm:= FindPassPermit(mes.SmallDevice);
      if aperm<>nil then
      begin
        s:= 'ТД №'+inttostr(aperm^.ApNumber)+' Проход совершен пользователем №'+inttostr(aperm^.UserNumber);
        amain.Log('SEND: '+s);
        mes.NumCard:= aperm^.UserNumber;
        mes.Code:= SUD_OK_ENTER;
        Result:= True;
        lPassPermit.Remove(aperm);
        Dispose(aperm);
      end;
    end;

    SUD_OK_NOT_ENTER:;
    // Cюда входим
    // 1) по SUD_ACCESS_GRANTED
    // 2) по CheckPassPermit

  end;//case
end;


procedure CheckPassPermit;
var
 i: word;
 aperm: ^TPassPermit;
 mes: KSBMES;
 s: string;
 ptc: ^TTC;

begin
  Debug('F:CheckPassPermit');
  if lPassPermit.Count>0 then
  for i:=lPassPermit.Count-1 downto 0 do
  begin
    aperm:= lPassPermit.items[i];
    dec(aperm^.NoPassTime);
    if aperm^.NoPassTime<1 then
    begin
      ptc:= rub.FindTC(aperm^.ApNumber, 9);
      if ptc<>nil then
      if ptc^.State in [1,5,6] then
      begin
        s:= 'ТД №'+inttostr(aperm^.ApNumber)+' Проход не совершен пользователем №'+inttostr(aperm^.UserNumber);
        amain.Log('SEND: '+s);
        Init(mes);
        mes.SysDevice:= SYSTEM_SUD;
        mes.NetDevice:= rub.NetDevice;
        mes.BigDevice:= rub.BigDevice;
        mes.SmallDevice:= aperm^.ApNumber;
        mes.NumCard:= aperm^.UserNumber;
        mes.TypeDevice:= 2;
        mes.Code:= SUD_OK_NOT_ENTER;
        amain.Send(mes);
      end;
      lPassPermit.Remove(aperm);
      Dispose(aperm);
    end;
  end;
end;



procedure TaMain.Button2Click(Sender: TObject);
var
 s, s2: string;
 i, len: word;
begin
  s:= Edit4.Text;
  len:= length(s);
  if (len<2)or((len mod 2)>0) then
    exit;
  //
  FillChar(rbcp.rbuf, 255, 0);
  for i:=0 to (len div 2)-1 do
  begin
    s2:= '$' + copy (s, 2*i+1, 2);
    rbcp.rbuf[i]:= StrToInt(s2);
  end;
  //ReadBCPTelegram;
end;


procedure TaMain.Button1Click(Sender: TObject);
begin
 rub.comd:= SpinEdit4.Value;
 rub.TempIndex:= SpinEdit5.Value;
end;



procedure TaMain.DeleteUserZeroAL;
var
  i: word;
  pus: ^TUS;
begin
  for i:=1 to rub.US.Count do
  begin
    pus:= rub.US.Items[i-1];
    if (pus^.AL1=0)and(pus^.AL2=0) then
    begin
      Log(Format('Удаление пользователя (карты): %d', [pus^.Id]));
      mDeleteUser(pus^.Id)
    end;
  end;
end;

END.

