unit R8Unit;

interface

uses classes, SharedBuffer;

const
 //������� ���������� ��
 TC_RESTORE             = $8302;
 TC_ALARM_ARM           = $101;
 TC_ALARM_DISARM        = $102;
 TC_ALARM_RESETTRAIN    = $103;
 TC_ALARM_BYPASS        = $104;
 TC_PANIC_RESETTRAIN    = $201;
 TC_PANIC_TEST          = $202;
 TC_FIRE_RESETTRAIN     = $301;
 TC_ED_ON               = $501;
 TC_ED_OFF              = $502;
 TC_AP_LOCKOPEN         = $602;
 TC_AP_BLOCK            = $603;
 TC_AP_DEBLOCK          = $604;
 TC_AP_RESET            = $605;
 TC_TERMINAL_BLOCK      = $702;
 TC_TERMINAL_RESET      = $703;

 ACTION_BCP_ALLUSERAPBRESET     =2;  // ����� ���� ����������� ��� ���� �������������
 ACTION_BCP_ALLUSERSETSTATE     =3;  // ��������� ����� ��������� ��� ���� �������������
 ACTION_BCP_DMQCLEARTCO         =4;  // �������������� ���� �� �� ���������� ������ (�������������� ������ ������� ��)
 ACTION_BCP_DMQCLEARNND         =5;  // �������������� ���� �� �� ���������� ������ (�������������� ������ ������� ��)
 ACTION_BCP_CONSOLELOCK         =6;  // ���������� ������ ���������� ���
 ACTION_BCP_CONSOLEUNLOCK       =7;  // ������������� ������ ���������� ��� (����������� ������� ������ � ������� ��������������)
 ACTION_BCP_RESET               =8;  // ���������� ����� ���
 ACTION_BCP_CLEARSYSERROR       =10; // ����� ��������� ������
 ACTION_BCP_STARTCHECKCONFIG    =11; // �������� ������������ ���

type
 TTelegram = array [0..255 + sizeof(KSBMES)] of byte;
 PTTelegram = ^TTelegram;

 TAnyCard=record
   idAP: word;
   idVar: byte;
   Value: byte; //0-����, 1-���.
 end;

 TCU=record
   HWType: byte;
   HWSerial: word;
   Ver: byte;
   SubVer: byte;
   flags: byte;
   ConfigDummy: array [0..7] of byte;
   //����
   Number: word;// ����� � ��
   State: byte; // �-�-� (�������������-��������-�� �����)
   Link: pointer; // ��������� �� ����������� ���������
 end;

 {
        unsigned char fExist:[0..1]; 		// ������ 1
        unsigned char fBadRecord:[2];
        unsigned char fNetPoolNumber1_2:[3]; 	// ����� ����� ����� 1,2
        unsigned char fAttached:[4];		//1 � �� ����������
        unsigned char fBackup:[5];
        unsigned char fNetPoolNumber0:[6];	// ����� ����� ����� ���,0
 }

 TZN=record
   Flags: byte;
   BCPNumber: array [0..3] of byte;
   StringPointer: byte;
   Status: byte;
   CRC: word;
   Number: word;
   State: byte;
 end;

 TTC=record
   BCP: word;
   Sernum: word;
   Kind: byte;
   BCPNumber: array [0..3] of byte;
   StringPointer : byte;
   Flags: byte;
   ParentZone: array [0..3] of byte;
   Group: byte;
   HWType: byte;
   HWSerial: word;
   ElementHW: byte;
   ConfigDummy: array [0..14] of byte;
   RestoreTime: byte;
   CRC: word;
   //
   ZoneVista: word;
   PartVista: word;
   State: word;
   tempUser: word;
   Ext: Pointer;
 end;

 TGR=record
   Num: byte;
   TextNamePointer: byte;
   CRC: word;
 end;

 TUS=record
   Flags: byte;
   Id: word;
   TypeIdentifier: byte;
   IdentifierCode: array [0..7] of byte;
   PinCode: longword;
   AL1: byte;
   CheckRulesLevel: byte;
   ParentZone: array [0..3] of byte;
   LifeTime: longword;
   AccessToBCP: byte; //TZ
   AL2: byte;
   AccessToArm: byte; //TZ
   Reserv: byte;
 end;

 TTI=record
   Flags: byte;
   ParentTimeZone: byte;
   INumber: byte;
   BeginHour: byte;
   BeginMin: byte;
   EndHour: byte;
   EndMin: byte;
   DayMap: byte;
   CRC: word;
 end;

 TPR=record
   Flags: byte;
   AL: byte;
   Zone: array [0..3] of byte;
   ZoneStatus: byte;
   TCOType: byte;
   TCOGroup: byte;
   Map: longword;
   TimeZone: byte;
   CRC: word;
 end;

 TRN=record
   Num: byte;
   Data: array [0..15] of byte;
   CRC: word;
 end;

 TRP=record
   Flags: byte;
   Num: word;
   Name: word;
   Manual: byte;
   CRC: word;
 end;

 TRI=record
   Flags: byte;
   Obj: byte;
   Cmd: word;
   RSData: array [0..5] of byte;
   PNum: word;
   INum: word;
   CRC: word;
 end;

 THOLIDAY=record
   Flag: byte;
   Data: array [0..15] of word;
   Res: byte;
   CRC: word;
 end;

 PTCU = ^TCU;
 PTZN = ^TZN;
 PTTC = ^TTC;
 PTGR = ^TGR;
 PTUS = ^TUS;
 PTTI = ^TTI;
 PTPR = ^TPR;
 PTRN = ^TRN;
 PTRP = ^TRP;
 PTRI = ^TRI;

 TCmd=record
   comd: byte;
   cu: TCU;
   tc: TTC;
   zn: TZN;
   gr: TGR;
 end;

 TLink=record
   source_type: byte;
   source_num: word;
   child_type: byte;
   child_num: word;
   link_type: byte;
 end;

 TScuUserMapRecord=record
   scu_us: word;
   bcp_us: word;
 end;

 TRubej= class
   Addr: word;                                   // ����� �8
   NetDevice: byte;                              // NetDevice ������ �8
   BigDevice: byte;                              // BigDevice ������ �8
   ComPort: string;                              // COM ����
   ComBaud: word;                                // �������� COM �����
   IP: string;                                   // IP �����
   Port: word;                                   // IP ����

   WBuf: TList;                                  // ����� ������ �� ��������
   MesIndex: word;                               // ������ ������� � �8
   TempIndex: word;                              // ������ ��� ������� ��������� �� � ������������ ������������
   Temp2Index: byte;                             // ������ ��, ��
   wasB9B6: byte;                                // 0-���, 1-���� ��������� �������
   comd: byte;                                   // 0-, 1-, 2-
   WaitCount: word;                              // ������� ��������
   Online: byte;                                 // 0-��� �����, 1-�� �����, 2-����������
   ErrorCode: byte;                              // ����� ������, FF-��� ������
   WorkTime: boolean;                            // ������� �����
   Cmd: TCmd;
   NeedSaveR8h: boolean;
   CU: TList;                                    // ������ �� � �����������
   ZN: TList;                                    // ������ ��� � ����������� � �����������
   TC: TList;                                    // ������ �� � ����������� � �����������
   GR: TList;                                    // ������ �� � �����������
   US: TList;                                    // ������ �������������� � �����������
   TI: TList;                                    // ������ �� � �����������
   PR: TList;                                    // ������ �� � �����������
   RN: TList;                                    // ������ ������������
   RP: TList;                                    // ������ ��������
   RI: TList;                                    // ������ ����������
   HD: THOLIDAY;                                 // ������ ����������
   ScuUserMap: array [1..1999] of word;
   ScuSendArray: array [0..255] of byte;

   constructor Create;
   procedure Start;
   procedure ClearConf;
   procedure LoadCU(var t:array of byte; Number: word);
   procedure LoadZN(var t:array of byte; Number: word);
   procedure LoadTC(var t: array of byte; ZoneVista, PartVista: word);
   procedure LoadGR(var t: array of byte);
   procedure LoadUS(var t:array of byte);
   procedure LoadTI(var t: array of byte);
   procedure LoadPR(var t: array of byte);
   procedure LoadRN(var t: array of byte);
   procedure LoadRP(var t: array of byte);
   procedure LoadRI(var t: array of byte);
   procedure LoadHD(var t: array of byte);
   function FindCU(value: longword; FindMode: word): PTCU;
   function FindZN(var m:array of byte; FindMode: word): PTZN;
   function FindGR(Num: byte): PTGR;
   function FindTC(value, FindTCMode: word): pointer;//PTTC;
   function FindUS(value: word): PTUS;
   function FindTI(tmz, tmi: byte): PTTI;
   function FindPR(level: byte): PTPR;
   function FindEmpty_1001_IdCU: word;
   function FindEmpty_1001_IdZN: word;
   function FindEmpty_1001_IdSH: word;
   function FindEmpty_1001_IdRL: word;
   function FindEmpty_1001_IdAP: word;
   function FindEmpty_1001_IdTERM: word;
   function FindEmptyIdScuUser: word;
   function SetIdZN(m: array of byte): word;
   function SetIdTC(TCSerial: word; TCKind: byte): word;
   procedure SaveR8h;
   procedure CfgToCsv;
   //
   function FindUSInScuUserMap(value: word): word;
   procedure ScuUserfilter(BcpUser: word);
   procedure AddUserAllScu
                          (
                          UserNumber: word;
                          Facility: byte;
                          CardNumber: word;
                          Pin: longword
                          );
   procedure DelUserAllScu(UserNumber: word);
   procedure AddUserOneScu
                          (
                          UserNumber: word;
                          Facility: byte;
                          CardNumber: word;
                          Pin: longword
                          );
   procedure SetTimeAllScu;
   //
   procedure WriteBcpFile;
   function ReadBcpFile: boolean;
   procedure PrintConf;
   function SendCfgToBcp: boolean;
   procedure DeleteUD(AL: byte);
   procedure ClearWBuf;
 end;



const
 CU_MAX=1000;
 ZN_MAX=1000;
 SH_MAX=1000;
 RL_MAX=1000;
 AP_MAX=1000;
 TERM_MAX=1000;

 crc_table_x : array [0..255] of word = (
	$0000, $1189, $2312, $329b, $4624, $57ad, $6536, $74bf,
	$8c48, $9dc1, $af5a, $bed3, $ca6c, $dbe5, $e97e, $f8f7,
	$1081, $0108, $3393, $221a, $56a5, $472c, $75b7, $643e,
	$9cc9, $8d40, $bfdb, $ae52, $daed, $cb64, $f9ff, $e876,
	$2102, $308b, $0210, $1399, $6726, $76af, $4434, $55bd,
	$ad4a, $bcc3, $8e58, $9fd1, $eb6e, $fae7, $c87c, $d9f5,
	$3183, $200a, $1291, $0318, $77a7, $662e, $54b5, $453c,
	$bdcb, $ac42, $9ed9, $8f50, $fbef, $ea66, $d8fd, $c974,
	$4204, $538d, $6116, $709f, $0420, $15a9, $2732, $36bb,
	$ce4c, $dfc5, $ed5e, $fcd7, $8868, $99e1, $ab7a, $baf3,
	$5285, $430c, $7197, $601e, $14a1, $0528, $37b3, $263a,
	$decd, $cf44, $fddf, $ec56, $98e9, $8960, $bbfb, $aa72,
	$6306, $728f, $4014, $519d, $2522, $34ab, $0630, $17b9,
	$ef4e, $fec7, $cc5c, $ddd5, $a96a, $b8e3, $8a78, $9bf1,
	$7387, $620e, $5095, $411c, $35a3, $242a, $16b1, $0738,
	$ffcf, $ee46, $dcdd, $cd54, $b9eb, $a862, $9af9, $8b70,
	$8408, $9581, $a71a, $b693, $c22c, $d3a5, $e13e, $f0b7,
	$0840, $19c9, $2b52, $3adb, $4e64, $5fed, $6d76, $7cff,
	$9489, $8500, $b79b, $a612, $d2ad, $c324, $f1bf, $e036,
	$18c1, $0948, $3bd3, $2a5a, $5ee5, $4f6c, $7df7, $6c7e,
	$a50a, $b483, $8618, $9791, $e32e, $f2a7, $c03c, $d1b5,
	$2942, $38cb, $0a50, $1bd9, $6f66, $7eef, $4c74, $5dfd,
	$b58b, $a402, $9699, $8710, $f3af, $e226, $d0bd, $c134,
	$39c3, $284a, $1ad1, $0b58, $7fe7, $6e6e, $5cf5, $4d7c,
	$c60c, $d785, $e51e, $f497, $8028, $91a1, $a33a, $b2b3,
	$4a44, $5bcd, $6956, $78df, $0c60, $1de9, $2f72, $3efb,
	$d68d, $c704, $f59f, $e416, $90a9, $8120, $b3bb, $a232,
	$5ac5, $4b4c, $79d7, $685e, $1ce1, $0d68, $3ff3, $2e7a,
	$e70e, $f687, $c41c, $d595, $a12a, $b0a3, $8238, $93b1,
	$6b46, $7acf, $4854, $59dd, $2d62, $3ceb, $0e70, $1ff9,
	$f78f, $e606, $d49d, $c514, $b1ab, $a022, $92b9, $8330,
	$7bc7, $6a4e, $58d5, $495c, $3de3, $2c6a, $1ef1, $0f78 );

 seconds_in_min=60;
 seconds_in_hour=3600;
 seconds_in_day=86400;
 seconds_in_year=31536000;
 FirstDayOfEachMonth : array [1..12] of word = (1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
 FirstDayOfEachMonthInLeapYear : array [1..12] of word = (1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336);

 procedure FinishReadCfg;
 function ReadR8c: boolean;
 function Comp(Item1, Item2: Pointer): Integer;
 function CompCU(Item1, Item2: Pointer): Integer;
 function CompZN(Item1, Item2: Pointer): Integer;
 function CompTC(Item1, Item2: Pointer): Integer;
 function ToBCD (d: byte) : byte;
 function IsDigit(s: string): boolean;
 function NewIdTC: word;
 procedure mSetVar(Addres: byte; Value: word; ValueType: byte);
 function PackTime (time: TDateTime): Longword;
 function UnPackTime (var time: array of byte): TDateTime;
 function kc (var mas: array of byte; Num: byte): word;
 function ValToStr (var m: array of byte): string;
 function StrToVal (s: string; var m: array of byte): boolean;
 function Vrez0(t: PTTelegram): word;

 function GetR8c(sec, key, def: string): string;
 procedure SaveR8c(sec, key, value: string);
 procedure DeleteR8c(sec, key: string);
 procedure CopyFile(n1, n2: string);
 function ReadScuUserMap(sec, key, def: string): string;
 procedure WriteScuUserMap(sec, key, value: string);
 function TCTypeToStr(Kind: byte): String;
 function TCTypeToInt(Kind: string): word;
 function DescriptionBCPRetCode(Code: word): string;
 function HWTypeToStr(n: byte): string;
 function StrToHWType(s: string): byte;
 function HWTypeBCPError(n: byte): string;
 function LinkTypeToStr(n: byte): string;
 function StrToLinkType(s: string): byte;
 function ApEventAfterReset(CurState: word): word;
 procedure ChangeVal(var s1, s2: string);

 // ������� � �������
 procedure mGetVer;
 procedure mSetClock(time: Longword);
 procedure mGetClock;
 procedure mGetWordBCP;
 procedure mGetLisences;
 procedure mGetBCPInfo;
 procedure mGetBCPErrorInfo;
 //
 procedure mCreateCU(num, adr: word; typeCU, flags: byte; var Dummy: array of byte);
 procedure mChangeCU(num, adr: word; typeCU, flags: byte; var Dummy: array of byte);
 procedure mDeleteCU(adr: word; typeCU: byte; Number: word);
 procedure mGetCU(adr: word; typeCU: byte; Number: word);
 procedure mDeleteCUs;
 procedure mGetListCU(index: integer; t: PTTelegram);
 //
 procedure mCreateZone(var m: array of byte; conf, status, name: byte; PartVista: word);
 procedure mChangeZone(var m: array of byte; conf, status, name: byte; PartVista: word);
 procedure mDeleteZone(var m: array of byte; PartVista: word);
 procedure mDeleteZones;
 procedure mGetZone(var m: array of byte; PartVista: word);
 //
 procedure mGetListZone(index:integer; t:PTTelegram);
 procedure mUpZone(var name : array of byte; op: word; all_tc_ready: byte);
 procedure mDownZone(var name: array of byte; op: word);
 procedure mBypassZone(var name: array of byte; op: word; checkop: byte);
 procedure mRestoreZone(var name: array of byte; op: word; checkop: byte);
 //
 procedure mCreateTC (
                     sernum: word;
                     typeTC: byte;
                     var BCPNumber: array of byte;
                     name: byte;
                     flags: byte;
                     var zone: array of byte;
                     group: byte;
                     type_hid: byte;
                     serial_hid: word;
                     hw_element: byte;
                     var config_union: array of byte;
                     restoreTime: byte;
                     ZoneVista: word;
                     PartVista: word);
 procedure mChangeTC (
                     sernum: word;
                     typeTC: byte;
                     var BCPNumber: array of byte;
                     name: byte;
                     flags: byte;
                     var zone: array of byte;
                     group: byte;
                     type_hid: byte;
                     serial_hid: word;
                     hw_element: byte;
                     var config_union: array of byte;
                     restoreTime: byte;
                     ZoneVista: word;
                     PartVista: word);
 procedure mDeleteTC (sernum: word);
 procedure mGetTC(sernum: word; var time, event, user: array of byte);
 procedure mGetListTC(index: integer; t: PTTelegram);
 procedure mGetStateCU(typeCU: byte; sernumCU:word; t: PTTelegram); overload;
 procedure mGetStateCU(typeCU: byte; sernumCU:word); overload;
 procedure mGetStateMarkCU(Index: word; type_cmd: byte; t: PTTelegram);
 procedure mGetStateTC(Sernum: word; type_cmd: byte; t: PTTelegram); overload;
 procedure mGetStateTC(Sernum: word; type_cmd: byte); overload;
 procedure mGetStateMarkTC(Index: word; type_cmd: byte; t: PTTelegram);
 procedure mInCfgCUs;
 procedure mOutCfgCUs;
 procedure mTCControl(Sernum, Operator, Command: word);
 //
 procedure mCreateGR(Num, Name: byte);
 procedure mChangeGR(Num, Name: byte);
 procedure mDeleteGR(Num: byte);
 procedure mDeleteGRs;
 procedure mGetGR(Num: byte);
 procedure mGetListGR(index: integer; t: PTTelegram);
 //
 procedure mCreateUser
          (
           flags: byte;
           id: word;
           ident_type: byte;
           var code: array of byte;
           pincode: longword;
           acces_level1: byte;
           rule_control: byte;
           var zone: array of byte;
           life_time: longword;
           time_zone: byte;
           acces_level2: byte;
           accessToArm: byte
           );
 procedure mChangeUser
          (
           flags: byte;
           id: word;
           ident_type: byte;
           var code: array of byte;
           pincode: longword;
           acces_level1: byte;
           rule_control: byte;
           var zone: array of byte;
           life_time: longword;
           time_zone: byte;
           acces_level2: byte;
           accessToArm: byte
           );
 procedure mDeleteUser (id: word);
 procedure mDeleteUsers;
 procedure mGetUser (id: word);
 procedure mGetListUser (index: integer; t: PTTelegram);
 procedure mUserControl(User: word);
 //
 procedure mCreateChangeTimeInterval
            (
             Flags: byte;
             ParentTimeZone: byte;
             INumber: byte;
             BeginHour: byte;
             EndHour: byte;
             BeginMin: byte;
             EndMin: byte;
             DayMap: byte;
             type_cmd: byte
            );
 procedure mDeleteTimeInterval (id: byte);
 procedure mDeleteTimeIntervals;
 procedure mGetListTimeInterval (id: byte; index: word; t: PTTelegram);
 procedure mSetHoliday(var Dates: array of byte);
 //
 procedure mCreateChangePravo
            (
             Flags: byte;
             AL: byte;
             var Zone: array of byte;
             ZoneStatus: byte;
             TCOType: byte;
             TCOGroup: byte;
             Map: longword;
             TimeZone: byte;
             type_cmd: byte
            );
 procedure mDeletePravo (id: byte);
 procedure mDeletePrava;
 procedure mGetListPravo (id: byte; index: word; t: PTTelegram);
 procedure mPreGetListPravo(id: byte);
 procedure mGetEvent(mPort: byte; index: integer; t: PTTelegram);
 procedure mBCPControl(Command: byte);
 //
 procedure mGetListRN(index: byte; t: PTTelegram);
 procedure mDeleteRNs;
 procedure mGetListRP(index: word; t: PTTelegram);
 procedure mDeleteRPs;
 procedure mGetListRI(index: word; t: PTTelegram);
 procedure mGetListHD(t: PTTelegram);
 procedure mCreateHDs(
                Flag: byte;
                Data: array of word;
                Res: byte
                );
 procedure mDeleteHDs;
 procedure mCreateRN(Num: byte; Data: array of byte);
 procedure mCreateRP
                (
                Flags: byte;
                Num: word;
                Name: word;
                Manual: byte
                );
 procedure mCreateRI
                (
                Flags: byte;
                Obj: byte;
                Cmd: word;
                RSData: array of byte;
                PNum: word;
                INum: word
                );
 //

var
 r8ccopy: boolean=false;
 rub: TRubej;


implementation
uses mMain, Sysutils, windows, connection, inifiles, forms, Comm, constants;

//----------------------------------------//
//                 Scu                    //
//----------------------------------------//
function Comp(Item1, Item2 : Pointer): Integer;
type
 PLongword= ^Longword;

begin
 if PLongword(Item1)^ < PLongword(Item2)^ then result:=-1
   else if PLongword(Item1)^ > PLongword(Item2)^ then result:=1
     else result:=0;
end;

//-----------------------------------------------------------------------------
function CompCU(Item1, Item2 : Pointer):Integer;
type
 PTCU=^TCU;

begin
 if PTCU(Item1)^.Number < PTCU(Item2)^.Number then result:=-1
 else if PTCU(Item1)^.Number > PTCU(Item2)^.Number then result:=1
 else result:=0;
end;

//-----------------------------------------------------------------------------
function CompZN(Item1, Item2 : Pointer):Integer;
type
 PTCU=^TCU;

begin
 if PTZN(Item1)^.Number < PTZN(Item2)^.Number then result:=-1
 else if PTZN(Item1)^.Number > PTZN(Item2)^.Number then result:=1
 else result:=0;
end;

//-----------------------------------------------------------------------------
function CompTC(Item1, Item2 : Pointer):Integer;
type
 PTCU=^TCU;

begin
 if PTTC(Item1)^.ZoneVista < PTTC(Item2)^.ZoneVista then result:=-1
 else if PTTC(Item1)^.ZoneVista > PTTC(Item2)^.ZoneVista then result:=1
 else result:=0;
end;

//-----------------------------------------------------------------------------
function ToBCD(d: byte): byte;
var
  st:string;
begin
 st:= IntToStr(d);
 if length(st)<2 then st:='0'+st;
 result:= strtoint('$'+st);
end;








//-----------------------------------------------------------------------------
function kc (var mas: array of byte; Num: byte): word;
var
 i, crc: word;
begin
 crc:=0;
 for i:=0 to Num-1 do
   crc:= (crc shr 8) xor crc_table_x[(crc xor mas[i]) and $ff];
 result:= crc;
end;

//-----------------------------------------------------------------------------
function PackTime (time: TDateTime): Longword;
const
 seconds_in_min=60;
 seconds_in_hour=3600;
 seconds_in_day=86400;
 seconds_in_year=31536000;
 FirstDayOfEachMonth:array [1..12] of word = (1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
 FirstDayOfEachMonthInLeapYear : array [1..12] of word = (1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336);

var
 year, month, d : word;
 h, m, Sec, MSec: word;
 total : int64; //longword;

begin
 Result:= 0;
 DecodeTime(time, h, m, Sec, MSec);
 DecodeDate(time, year, month, d);
 total:=0;
 if year<2000 then
   exit;
 if year>2000
   then total:=(year-2000)*seconds_in_year + (((year-2001) div 4)+1)*seconds_in_day;
 if IsLeapYear(year)
   then total:=total+(FirstDayOfEachMonthInLeapYear[month]-1)*seconds_in_day
   else total:=total+(FirstDayOfEachMonth[month]-1)*seconds_in_day;
 Result:= total + (d-1)*seconds_in_day + h*seconds_in_hour + m*seconds_in_min + sec ;
end;

//-----------------------------------------------------------------------------
function UnPackTime (var time: array of byte): TDateTime;
const
 seconds_in_min=60;
 seconds_in_hour=3600;
 seconds_in_day=86400;
 seconds_in_year=31536000;
 FirstDayOfEachMonth:array [1..12] of word = (1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
 FirstDayOfEachMonthInLeapYear : array [1..12] of word = (1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336);

type RTime=record
 hour : byte;
 min  : byte;
 sec  : byte;
 day  : byte;
 month: byte;
 year : byte;
 weekday : byte;
 reserved : byte;
 end;

var
 t : Int64;
 rt: RTime;
 day: word;
 i:byte;

begin
 t:=16777216*time[3]+65536*time[2]+256*time[1]+time[0];
 rt.year:=t div seconds_in_year;
 if (rt.year>0) then rt.year:=(t-((rt.year-1) div 4 + 1)*seconds_in_day) div seconds_in_year;  //���7.6
 if (rt.year>0) then t:=t - rt.year*seconds_in_year - (((rt.year-1) div 4)+1)*seconds_in_day;
 day:=t div seconds_in_day + 1;

 i:=1;
 if IsLeapYear(rt.year+2000) then
  while(FirstDayOfEachMonthInLeapYear[i]<=day)and(i<13) do inc(i)
  else while(FirstDayOfEachMonth[i]<=day)and(i<13) do inc(i);
 dec(i);
 rt.month:=i;

 if IsLeapYear(rt.year+2000)  then
  t:=t-(FirstDayOfEachMonthInLeapYear[i]-1)*seconds_in_day
  else t:=t-(FirstDayOfEachMonth[i]-1)*seconds_in_day;

 rt.day:=(t div seconds_in_day)+1;
 t:=t - (rt.day-1)*seconds_in_day;

 rt.hour:=t div seconds_in_hour;
 t:=t - rt.hour*seconds_in_hour;

 rt.min:=t div seconds_in_min;
 rt.sec:=t - rt.min*seconds_in_min;

 Result:=EncodeDate(2000+rt.year, rt.month, rt.day) + EncodeTime(rt.hour, rt.min, rt.sec, 0);
end;

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
function IsDigit(s: string): boolean;
var i : integer;
begin
 Result:= False;
 if length(s)=0 then
 exit;
 //
 for i:= 1 to length(s) do
 if not (s[i] in ['0'..'9']) then
 exit;
 //
 Result:= True;
end;


function NewIdTC: word;
var
  i: word;
begin
  //���������� ��
  rub.TC.Sort(Comp);
  Result:= $8000;
  //����� ��
  for i:=0 to rub.TC.Count-1 do
    if (TTC((rub.TC.Items[i])^).Sernum > Result)
      then break
      else Result:= Result + 1;
  amain.Log( Format('! NewIdTC=%d', [Result]) );
end;


procedure FinishReadCfg;
begin
  WITH rub DO BEGIN
    //������ r8c
    r8ccopy:= False;
    if ReadR8c
      then aMain.Log('������� ��������� ���� ' + ReadPath() + Format('NET%uBIG%u.r8c',[NetDevice, BigDevice]) )
      else
      begin
        aMain.Log('������ ��������� ����� ' + ReadPath() + Format('NET%uBIG%u.r8c',[NetDevice, BigDevice]) );
        halt;
      end;
    r8ccopy:= True;
    //
    mGetBCPInfo;
    mGetBCPErrorInfo;
    //
    if rub.CU.Count>0 then //������� �� ������ ��������� ��
    begin
      rub.comd:=21;
      rub.TempIndex:=0; //��� ������������� CU.Items[TempIndex]
    end
    else
      if TC.Count>0 then //������� �� ������ ��������� ��
      begin
        comd:=23;
        TempIndex:=0; //��� ������������� CU.Items[TempIndex]
      end
      else comd:= 0;//25; //������� �� ���������� �����. ������
  END;
end;

               {val      TryStrToFloat}
function ReadR8c: boolean;
var
 s,s1,s2,s3: string;
 i, v: word;
 pn, pv, code: Integer;
 l: longword;
 pcu: PTCU;
 ptc: PTTC;
 pzn: PTZN;
 pus: PTUS;
 //pac: ^TAnyCard;
 rule: TRule;

 m: TTelegram;
 AppIni: TIniFile;
 scu, szn, ssh, srl, sap, sterm, srule{, sScuUserMap}: TStringList;

begin
 Debug('F:ReadR8c');
 Result:= False;
 //
 with rub do begin
   TRY
     s:=ReadPath() + Format('NET%uBIG%u.r8c',[NetDevice, BigDevice]);
     scu:=TStringList.Create;
     szn:=TStringList.Create;
     ssh:=TStringList.Create;
     srl:=TStringList.Create;
     sap:=TStringList.Create;
     sterm:=TStringList.Create;
     srule:=TStringList.Create;
     AppIni:= TIniFile.Create(s);
     AppIni.ReadSectionValues('��', scu);
     AppIni.ReadSectionValues('����', szn);
     AppIni.ReadSectionValues('��', ssh);
     AppIni.ReadSectionValues('����', srl);
     AppIni.ReadSectionValues('��', sap);
     AppIni.ReadSectionValues('��������', sterm);
     AppIni.ReadSectionValues('�������', srule);
     AppIni.Free;
     //
     // ���������� ������
     for i:=1 to srule.Count do
     begin
       s:= srule.Names[i-1];
       if StrToRule(s, rule) then
         begin
           if FindRule(rule.TextRule)=nil then
             AddRule(rule);
         end
         else DeleteR8c('�������', s);
     end;
     aMain.Log( Format('��������� ������������ ������ (%d)', [srule.Count]) );

     // �������� ������ � ������������ ����� � r8c.[��]
     for i:=1 to scu.Count do
     begin
       //s-�����
       //s1-�������� (��� ���� (s2) + ���.� (s3))
       s:=scu.Names[i-1];
       Val(s, pn, code);
       if (code<>0) then
       begin
         DeleteR8c('��', s);
         continue;
       end;
       s1:=scu.Values[s]; //��������
       s2:=copy(s1, 1, pos(':', s1)-1); // �������� (���)
       s3:=copy(s1, pos(':', s1)+1, length(s1)-pos(':', s1));  // �������� (�����)
       //s3:=copy(s1, pos(':', s1)+1, pos(':(', s1)-pos(':', s1)-1);
       //
       l:= StrToHWType(s2); //l-always digit
       if (l=0) then
       begin
         DeleteR8c('��', s);
         continue;
       end;
       Val(s3, l, code);
       if (code<>0) then
       begin
         DeleteR8c('��', s);
         continue;
       end;
       l:=StrToHWType(s2)*65536 + l;
       //
       pcu:=FindCU(l, 0);
       if pcu<>nil
         then pcu^.Number:= pn
         else if pn>CU_MAX
           then DeleteR8c('��', s)
           else SaveR8c('��', s, '');
     end;//for

     // �������� ������ � ������������ ����� � r8c.[����]
     for i:=1 to szn.Count do
     begin
       s:=szn.Names[i-1];
       //
       Val(s, pn, code);
       if (code<>0) then
       begin
         DeleteR8c('����', s);
         continue;
       end;
       //
       if not StrToVal(szn.Values[s], m) then
       begin
         if pn>ZN_MAX
         then DeleteR8c('����', s)
         else SaveR8c('����', s, '');
         continue;
       end;
       //
       pzn:=FindZN(m, 0);
       if pzn<>nil
         then pzn^.Number:= pn
         else if pn>ZN_MAX
           then DeleteR8c('����', s)
           else SaveR8c('����', s, '');
     end;

     // �������� ������ � ������������ ����� � r8c.[��]
     for i:=1 to ssh.Count do
     begin
       s:=ssh.Names[i-1];
       //
       Val(s, pn, code);
       if (code<>0) then
       begin
         DeleteR8c('��', s);
         continue;
       end;
       //
       Val(ssh.Values[s], pv, code);
       if (code<>0) then
       begin
         if pn>SH_MAX
           then DeleteR8c('��', s)
           else SaveR8c('��', s, '');
         continue;
       end;
       //
       ptc:=FindTC(pv, 5);
       if ptc<>nil
         then ptc^.ZoneVista:= pn
         else if pn>SH_MAX
           then DeleteR8c('��', s)
           else SaveR8c('��', s, '');
     end;

     // �������� ������ � ������������ ����� � r8c.[����]
     for i:=1 to srl.Count do
     begin
       s:=srl.Names[i-1];
       //
       Val(s, pn, code);
       if (code<>0) then
       begin
         DeleteR8c('����', s);
         continue;
       end;
       //
       Val(srl.Values[s], pv, code);
       if (code<>0) then
       begin
         if pn>RL_MAX
         then DeleteR8c('����', s)
         else SaveR8c('����', s, '');
         continue;
       end;
       //
       ptc:=FindTC(pv, 6);
       if ptc<>nil
       then ptc^.ZoneVista:= pn
       else if pn>RL_MAX
       then DeleteR8c('����', s)
       else SaveR8c('����', s, '');
     end;

     // �������� ������ � ������������ ����� � r8c.[��]
     for i:=1 to sap.Count do
     begin
       s:=sap.Names[i-1];
       //
       Val(s, pn, code);
       if (code<>0) then
       begin
         DeleteR8c('��', s);
         continue;
       end;
       //
       Val(sap.Values[s], pv, code);
       if (code<>0) then
       begin
         if pn>AP_MAX
         then DeleteR8c('��', s)
         else SaveR8c('��', s, '');
         continue;
       end;
       //
       ptc:=FindTC(pv, 10);
       if ptc<>nil
       then ptc^.ZoneVista:= pn
       else if pn>AP_MAX
       then DeleteR8c('��', s)
       else SaveR8c('��', s, '');
     end;

     // �������� ������ � ������������ ����� � r8c.[��������]
     for i:=1 to sterm.Count do
     begin
       s:=sterm.Names[i-1];
       //
       Val(s, pn, code);
       if (code<>0) then
       begin
         DeleteR8c('��������', s);
         continue;
       end;
       //
       Val(sterm.Values[s], pv, code);
       if (code<>0) then
       begin
         if pn>TERM_MAX
         then DeleteR8c('��������', s)
         else SaveR8c('��������', s, '');
         continue;
       end;
       //
       ptc:=FindTC(pv, 8);
       if ptc<>nil
       then ptc^.ZoneVista:= pn
       else if pn>TERM_MAX
       then DeleteR8c('��������', s)
       else SaveR8c('��������', s, '');
     end;

     // ���������� ��������������� ���� CU, ZN, TC
     if cu.Count>0 then
     for i:=1 to cu.Count do
     begin
       pcu:=cu.Items[i-1];
       if pcu^.Number=0 then
       pcu^.Number:=FindEmpty_1001_IdCU();
     end;
     if zn.Count>0 then
     for i:=1 to zn.Count do
     begin
       pzn:=zn.Items[i-1];
       if pzn^.Number=0 then
         pzn^.Number:=SetIdZN(pzn^.BCPNumber);
     end;
     if tc.Count>0 then
     for i:=1 to tc.Count do
     begin
       ptc:= tc.Items[i-1];
       if ptc^.ZoneVista=0 then
       case ptc^.Kind of
         1..4: ptc^.ZoneVista:= SetIdTC(ptc^.Sernum, 1);
         5: ptc^.ZoneVista:=    SetIdTC(ptc^.Sernum, 5);
         6: ptc^.ZoneVista:=    SetIdTC(ptc^.Sernum, 6);
         7: ptc^.ZoneVista:=    SetIdTC(ptc^.Sernum, 7);
       end;
     end;

     // ���������� ������� ��� ���� ��
     if tc.Count>0 then
     for i:=1 to tc.Count do
     begin
       ptc:= tc.Items[i-1];
       if (ptc^.PartVista<>0) then
         continue;
       pzn:= FindZN(ptc^.ParentZone, 0);
       if pzn=nil then
         aMain.Log(inttostr(ptc^.ZoneVista));
       ptc^.PartVista:= pzn^.Number;       {������ ��� ������ ����� ���������� ����� ������������ ��}
     end;

   // ����� � r8c ���� CU, ZN, TC
     CU.Sort(CompCU);
     ZN.Sort(CompZN);
     TC.Sort(CompTC);

     for i:=1 to cu.Count do
     begin
       pcu:= cu.Items[i-1];
       SaveR8c('��', inttostr(pcu^.Number), HWTypeToStr(pcu^.HWType) +':'+inttostr(pcu^.HWSerial));
     end;
     for i:=1 to zn.Count do
     begin
       pzn:=zn.Items[i-1];
       SaveR8c('����', inttostr(pzn^.Number), ValToStr(pzn^.BCPNumber));
     end;
     if tc.Count>0 then
     for i:=1 to tc.Count do
     begin
       ptc:=tc.Items[i-1];
       case ptc^.Kind of
       1..4: SaveR8c('��', inttostr(ptc^.ZoneVista), IntToStr(ptc^.Sernum));
       5:    SaveR8c('����', inttostr(ptc^.ZoneVista), IntToStr(ptc^.Sernum));
       6:    SaveR8c('��', inttostr(ptc^.ZoneVista), IntToStr(ptc^.Sernum));
       7:    SaveR8c('��������', inttostr(ptc^.ZoneVista), IntToStr(ptc^.Sernum));
       end;
     end;
    {
     // �������� ������ � ������������ ����� � r8c.[����� �����]
     if sac.Count>0 then
     for i:=1 to sac.Count do
     begin
       //s-����� ��
       s:= sac.Names[i-1];
       Val(s, pn, code);
       if (code<>0) then
       begin
         DeleteR8c('����� �����', s);
         continue;
       end;
       if rub.FindTC(pn, 9)=nil then
       begin
         DeleteR8c('����� �����', s);
         continue;
       end;
     end;

     // ���������� �� r8c.[����� �����] ������ � lsACData
     if tc.Count>0 then
     for i:=1 to tc.Count do
     begin
       ptc:= tc.Items[i-1];
       if ptc^.Kind<>6 then
         continue;
       new(pac);
       pac^.idAP:= ptc^.ZoneVista;
       lsACData.Add(pac);
       //
       s:= GetR8c('����� �����', IntToStr(pac^.idAP), '1,0');
       v:= Pos(',', s);
       if v=0 then
         s:= '1,0';
       SaveR8c('����� �����', IntToStr(pac^.idAP), s);
       pac^.idVar:= StrToInt (Copy(s, 1, v-1)) ;
       pac^.Value:= byte(s[v+1]='1');
     end;
     }

     aMain.Log( Format('���������� ScuUserMap �� �����...', []) );
     // ���������� ScuUserMap �� �����
     for i:=1 to 1999 do
     begin
       s:= ReadScuUserMap('���-���', IntToStr(i), '');
       Val(s, ScuUserMap[i], code);
       if (code<>0) then
         ScuUserMap[i]:= 0;
       pus:= FindUS(ScuUserMap[i]);
       v:= 0;
       if pus<>nil then
         if pus^.Id=( pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256 ) then
           v:= pus^.Id;
       //
       if (code<>0)and(s<>'')or(ScuUserMap[i]>0)and(v=0) then
       begin
         ScuUserMap[i]:= 0;
         //������ � ����
         WriteScuUserMap('���-���', IntToStr(i), '');
         //�������� �� ��� ���-02
         DelUserAllScu(i);
       end;
     end;

     aMain.Log( Format('���������� ScuUserMap �� ���...', []) );
     // ���������� ScuUserMap �� ���
     if US.Count>0 then
     //
     for i:=1 to US.Count do
     begin
       pus:= US.Items[i-1];
       if pus^.Id<>( pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256 ) then
         continue;
       //
       //
       if ((pus^.Flags shr 5) and $03)=2 then
       begin
         //
         if FindUSInScuUserMap(pus^.Id)=0 then
         begin
           v:= FindEmptyIdScuUser;
           if v=0 then
           begin
             aMain.Log('��������� ���� ������������� ���-02 !');
             break;
           end;
           ScuUserMap[v]:= pus^.Id;                                                   //������ � ScuUserMap
           WriteScuUserMap('���-���', IntToStr(v), IntToStr(pus^.Id));                //������ � ����
           AddUserAllScu(                                                             //�������� �� ��� ���-02
                         v,
                         pus^.IdentifierCode[0],
                         pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256,
                         pus^.PinCode
                         );
         end;
         //
       end
       else
       begin
         v:= FindUSInScuUserMap(pus^.Id);
         if v>0 then
         begin
           ScuUserMap[v]:= 0;                                                       //������ � ScuUserMap
           WriteScuUserMap('���-���', IntToStr(v), '');                             //������ � ����
           DelUserAllScu(v);                                                        //�������� �� ��� ���-02
         end;
       end;

     end;//for

     // �������� ���������� ������������ � r8c � � map
     Result:=True;
   EXCEPT
   END;
 end;


end;








//----------------------------------------//
//                 Scu                    //
//----------------------------------------//

function TRubej.FindUSInScuUserMap(value: word): word;
var
 i: word;
begin
 Debug('F:FindUSInScuUserMap');
 Result:= 0;
 for i:=1 to 1999 do
  if ScuUserMap[i]=value then
  begin
    Result:= i;
  end;
end;


procedure TRubej.ScuUserfilter(BcpUser: word);
var
 i, j: word;
 pcu: PTCU;
 ptc: PTTC;
 pus: PTUS;
 ppr: PTPR;

begin
 FillChar(ScuSendArray, SizeOf(ScuSendArray), 0 );
 pUS:= FindUS(BcpUser);
 if pUS=nil then
   exit;
 if (pUS^.AL1=$ff)or(pUS^.AL2=$ff) then
   FillChar(ScuSendArray, SizeOf(ScuSendArray), 1 );
 //
 if PR.Count>0 then
 for i:=0 to PR.Count-1 do
 begin
   ppr:= PR.Items[i];
   if (ppr^.Flags and $10)>0 then
     continue;
   if (ppr^.AL<>pUS^.AL1)and(ppr^.AL<>pUS^.AL2) then
     continue;
   if ppr^.TCOType<>6 then
     continue;
   ptc:= FindTC(ppr^.TCOGroup, 9);
   if ptc=nil then
     continue;
   if ptc^.HWType<>32 then
     continue;
   pcu:= FindCU(65536*ptc^.HWType + ptc^.HWSerial, 0);
   if pcu=nil then
     continue;
   j:= CU.IndexOf(pcu);
   ScuSendArray[j]:= 1;
 end;
end;


procedure TRubej.AddUserAllScu
                        (
                        UserNumber: word;
                        Facility: byte;
                        CardNumber: word;
                        Pin: longword
                        );
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
 i: word;
 v: ^TMesRec;
 pcu: PTCU;

begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= NetDevice;
 mes.BigDevice:= BigDevice;
 mes.TypeDevice:= 4;
 mes.Level:= UserNumber;
 //
 FillChar(l,128,0);
 l[5]:= Facility;
 l[6]:= hi(CardNumber);
 l[7]:= lo(CardNumber);
 l[8]:= $01;
 l[11]:= $3f;
 move (Pin, l[13], 4);
 mes.Size:= 22;
 mes.Code:= SCU_CARD_ADD;
 //
 ScuUserfilter(CardNumber);
 //
 if cu.Count>0 then
 for i:=0 to cu.Count-1 do
 begin
   pcu:= cu.Items[i];
   if pcu^.HWType<>32 then
     continue;
   if (pcu^.flags and $10)=0 then
     continue;
   if (pcu^.State and $01)=0 then
     continue;
   if ScuSendArray[i]=0 then
     continue;
   mes.Mode:= pcu^.Number;
   mes.Camera:= mes.Mode;
   new(v);
   move(mes, v^.m, sizeof(KSBMES));
   v^.s:= Bin2Simbol(PChar(@l[0]), mes.Size);
   scu.MesBuf.Add(v);
 end;
 //
end;


procedure TRubej.DelUserAllScu(UserNumber: word);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
 i: word;
 pcu: PTCU;
 v: ^TMesRec;

begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= NetDevice;
 mes.BigDevice:= BigDevice;
 mes.TypeDevice:= 4;
 mes.Level:= UserNumber;
 mes.Code:= SCU_CARD_DELETE;
 //
 if cu.Count>0 then
   for i:=0 to cu.Count-1 do
   begin
     pcu:= cu.Items[i];
     if pcu^.HWType<>32 then
       continue;
     if (pcu^.flags and $10)=0 then
       continue;
     if (pcu^.State and $01)=0 then
       continue;
     mes.Mode:= pcu^.Number;
     mes.Camera:= mes.Mode;
     new(v);
     move(mes, v^.m, sizeof(KSBMES));
     v^.s:= Bin2Simbol(PChar(@l[0]), mes.Size);
     scu.MesBuf.Add(v);
   end;
end;


procedure TRubej.AddUserOneScu
                        (
                        UserNumber: word;
                        Facility: byte;
                        CardNumber: word;
                        Pin: longword
                        );
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
 v: ^TMesRec;

begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= NetDevice;
 mes.BigDevice:= BigDevice;
 mes.TypeDevice:= 132;
 mes.Level:= UserNumber;
 //
 FillChar(l,128,0);
 l[5]:= Facility;
 l[6]:= hi(CardNumber);
 l[7]:= lo(CardNumber);
 l[8]:= $01;
 l[11]:= $3f;
 move (Pin, l[13], 4);
 mes.Size:= 22;
 mes.Code:= SCU_CARD_ADD;
 //
 new(v);
 move(mes, v^.m, sizeof(KSBMES));
 v^.s:= Bin2Simbol(PChar(@l[0]), mes.Size);
 scu.MesBuf.Add(v);
end;


procedure TRubej.SetTimeAllScu;
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
 i: word;
 pcu: PTCU;
 v: ^TMesRec;

begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= NetDevice;
 mes.BigDevice:= BigDevice;
 mes.TypeDevice:= 4;
 mes.Code:= SCU_TIME_EDIT;
 //
 if cu.Count>0 then
   for i:=0 to cu.Count-1 do
   begin
     pcu:= cu.Items[i];
     if pcu^.HWType<>32 then
       continue;
     if (pcu^.flags and $10)=0 then
       continue;
     if (pcu^.State and $01)=0 then
       continue;
     mes.Mode:= pcu^.Number;
     mes.Camera:= mes.Mode;
     new(v);
     move(mes, v^.m, sizeof(KSBMES));
     v^.s:= Bin2Simbol(PChar(@l[0]), mes.Size);
     scu.MesBuf.Add(v);
   end;
end;




//----------------------------------------//
//              TRubej                    //
//----------------------------------------//
constructor TRubej.Create;
begin
 WBuf:= TList.Create;
 Online:= 2;
 ErrorCode:= $FF;
 WorkTime:= false;
 wasB9B6:= 0;
 MesIndex:= $FFFF;
 //
 CU:= TList.Create;
 ZN:= TList.Create;
 GR:= TList.Create;
 TC:= TList.Create;
 US:= TList.Create;
 TI:= TList.Create;
 PR:= TList.Create;
 RN:= TList.Create;
 RP:= TList.Create;
 RI:= TList.Create;
 //
 TempIndex:=$FFFF;
 NeedSaveR8h:= False;
end;

procedure TRubej.Start;
var
  b: boolean;

begin
  b:= False;
  if Option.FastStart then
    b:= ReadBcpFile;
  //
  if b then
  begin
    PrintConf;
    FinishReadCfg;
  end
  else
  begin
    ClearConf;
    comd:= 4;
  end;

end;

procedure TRubej.ClearConf;
var
 pTCU:^TCU;
 pTZN:^TZN;
 pTTC:^TTC;
 pTUS:^TUS;
 pTTI:^TTI;
 pTPR:^TPR;
 pTGR:^TGR;
 pTRN:^TRN;
 pTRP:^TRP;
 pTRI:^TRI;
begin
 aMain.Log('������� ������������ ��������...');
 while CU.Count>0 do
 begin
   pTCU:=CU.Last;
   Dispose(pTCU);
   CU.Remove(pTCU);
 end;
 while ZN.Count>0 do
 begin
   pTZN:=ZN.Last;
   Dispose(pTZN);
   ZN.Remove(pTZN);
 end;
 while GR.Count>0 do
 begin
   pTGR:=GR.Last;
   Dispose(pTGR);
   GR.Remove(pTGR);
 end;
 while TC.Count>0 do
 begin
   pTTC:=TC.Last;
   Dispose(pTTC);
   TC.Remove(pTTC);
 end;
 while TI.Count>0 do
 begin
   pTTI:=TI.Last;
   Dispose(pTTI);
   TI.Remove(pTTI);
 end;
 while PR.Count>0 do
 begin
   pTPR:=PR.Last;
   Dispose(pTPR);
   PR.Remove(pTPR);
 end;
 while US.Count>0 do
 begin
   pTUS:=US.Last;
   Dispose(pTUS);
   US.Remove(pTUS);
 end;
 while RN.Count>0 do
 begin
   pTRN:=RN.Last;
   Dispose(pTRN);
   RN.Remove(pTRN);
 end;
 while RP.Count>0 do
 begin
   pTRP:=RP.Last;
   Dispose(pTRP);
   RP.Remove(pTRP);
 end;
 while RI.Count>0 do
 begin
   pTRI:=RI.Last;
   Dispose(pTRI);
   RI.Remove(pTRI);
 end;
 FillChar(HD, sizeof(THOLIDAY), 0);
 aMain.Log('������� ������������ �������� ���������');
end;


procedure TRubej.LoadCU(var t: array of byte; Number: word);
var
 p:^TCU;
 s: string;
begin
 Debug('F:LoadCU');
 new(p);
 move(t[0], p^, sizeof(TCU)-7);
 p^.Number:= Number;
 p^.State:= $01;
 p^.Link:= nil;
 CU.Add(p);
 exit;
 //��� ���-02
 if p^.HWType=32 then
 begin
   s:= inttostr(p^.ConfigDummy[2]) + '.' + inttostr(p^.ConfigDummy[3]) +'.'+ inttostr(p^.ConfigDummy[4]) +'.'+ inttostr(p^.ConfigDummy[5]);
 end;
end;

procedure TRubej.LoadZN(var t: array of byte; Number: word);
var
 p: ^TZN;
begin
 Debug('F:LoadZN');
 new(p);
 move(t, p^, sizeof(TZN)-3);
 p^.Number:= Number;
 p^.State:=1;
 ZN.Add(p);
end;

procedure TRubej.LoadTC (var t: array of byte; ZoneVista, PartVista: word);
var
 p: ^TTC;
begin
 Debug('F:LoadTC');
 new(p);
 move(t, p^, sizeof(TTC)-8-4{newTTC});
 p^.ZoneVista:= ZoneVista;
 p^.PartVista:= PartVista;
 case p^.Kind of
   1..7: p^.State:= $40;
   else p^.State:= $40;
 end;
 p^.tempUser:= 0;
 p^.Ext:= nil;
 TC.Add(p);
end;

procedure TRubej.LoadGR(var t: array of byte);
var
 p:^TGR;
begin
 Debug('F:LoadGR');
 new(p);
 move(t, p^, sizeof(TGR));
 GR.Add(p);
end;

procedure TRubej.LoadUS(var t: array of byte);
var
 p:^TUS;
begin
 Debug('F:LoadUS');
 new(p);
 move(t, p^, sizeof(TUS));
 US.Add(p);
end;

procedure TRubej.LoadTI(var t: array of byte);
var
 p:^TTI;
begin
 Debug('F:LoadTI');
 new(p);
 move(t, p^, sizeof(TTI));
 TI.Add(p);
end;

procedure TRubej.LoadPR(var t: array of byte);
var
 p:^TPR;
begin
 Debug('F:LoadPR');
 new(p);
 move(t, p^, sizeof(TPR));
 PR.Add(p);
end;

procedure TRubej.LoadRN(var t: array of byte);
var
 p:^TRN;
begin
 Debug('F:LoadRN');
 new(p);
 move(t, p^, sizeof(TRN));
 RN.Add(p);
end;

procedure TRubej.LoadRP(var t: array of byte);
var
 p:^TRP;
begin
 Debug('F:LoadRP');
 new(p);
 move(t, p^, sizeof(TRP));
 RP.Add(p);
end;

procedure TRubej.LoadRI(var t: array of byte);
var
 p:^TRI;
begin
 Debug('F:LoadRI');
 new(p);
 move(t, p^, sizeof(TRI));
 RI.Add(p);
end;

procedure TRubej.LoadHD(var t: array of byte);
begin
 Debug('F:LoadHD');
 move(t, HD, sizeof(THOLIDAY));
end;

function TRubej.FindCU(value: longword; FindMode: word): PTCU;
var
 i: word;
 p: ^TCU;
begin
 Debug('F:FindCU');
 result:=nil;
 for i:=1 to CU.Count do
 begin
   p:=CU.Items[i-1];
   case FindMode of
     0: if (65536*p^.HWType + p^.HWSerial)=value then
     begin
       result:=CU.Items[i-1];
       exit;
     end;
     1: if p^.Number=value then
     begin
       result:=CU.Items[i-1];
       exit;
     end;
   end
 end;
end;

function TRubej.FindZN(var m: array of byte; FindMode: word): PTZN;
var
 i: word;
 p:^TZN;
begin
 Debug('F:FindZN');
 result:= nil;
 for i:=1 to ZN.Count do
 begin
   p:=ZN.Items[i-1];
   case FindMode of
     0:
     if (p^.BCPNumber[0]=m[0])and(p^.BCPNumber[1]=m[1])and(p^.BCPNumber[2]=m[2])and(p^.BCPNumber[3]=m[3]) then
     begin
       result:= ZN.Items[i-1];
       exit;
     end;
     1:
     if (m[0]+m[1]*256)=p^.Number then
     begin
       result:= ZN.Items[i-1];
       exit;
     end;
   end;//case
 end;
end;

function TRubej.FindGR(Num: byte): PTGR;
var
 i: word;
 p: PTGR;
begin
 Debug('F:FindGR');
 result:=nil;
 if GR.Count>0 then
 for i:=1 to GR.Count do
 begin
   p:= GR.Items[i-1];
   if p^.Num=Num then
   begin
     result:= p;
     exit;
   end;
 end;
end;

function TRubej.FindTC(value, FindTCMode: word): pointer;//PTTC;
var
 i: word;
 p:^TTC;
begin
 Debug('F:FindTC');
 result:= nil;
 if TC.Count>0 then
 for i:=1 to TC.Count do
 begin
   p:=TC.Items[i-1];
   case FindTCMode of
     0:  if value=p^.Sernum then begin result:= TC.Items[i-1]; exit; end;
     1:  if value=p^.ZoneVista then begin result:= TC.Items[i-1]; exit; end;
     2:  if (value=p^.PartVista) then begin result:= TC.Items[i-1]; exit; end;
     //
     3:  if (value=p^.ZoneVista)and(p^.Kind>=1)and(p^.Kind<=4) then begin result:= TC.Items[i-1]; exit; end;  // ��
     4:  if (value=p^.ZoneVista)and(p^.Kind=5) then begin result:= TC.Items[i-1]; exit; end;                  // ����
     5:  if (value=p^.Sernum)and(p^.Kind>=1)and(p^.Kind<=4) then begin result:= TC.Items[i-1]; exit; end;     // ��
     6:  if (value=p^.Sernum)and(p^.Kind=5) then begin result:= TC.Items[i-1]; exit; end;                     // ����
     7:  if (value=p^.ZoneVista)and(p^.Kind=7) then begin result:= TC.Items[i-1]; exit; end;                  // ��������
     8:  if (value=p^.Sernum)and(p^.Kind=7) then begin result:= TC.Items[i-1]; exit; end;                     // ��������
     9:  if (value=p^.ZoneVista)and(p^.Kind=6) then begin result:= TC.Items[i-1]; exit; end;                  // ��
     10: if (value=p^.Sernum)and(p^.Kind=6) then begin result:= TC.Items[i-1]; exit; end;                     // ��
   end;
 end;
end;

function TRubej.FindUS(value: word): PTUS;
var
 i: word;
 p:^TUS;
begin
 Debug('F:FindUS');
 result:=nil;
 for i:=1 to US.Count do
 begin
   p:= US.Items[i-1];
   if p^.Id=value then
   begin
     result:= US.Items[i-1];
     exit;
   end;
 end;
end;

function TRubej.FindTI(tmz, tmi: byte): PTTI;
var
 i: word;
 p:^TTI;
begin
 Debug('F:FindTI');
 result:=nil;
 for i:=1 to TI.Count do
 begin
   p:=TI.Items[i-1];
   if (p^.ParentTimeZone=tmz)and(p^.INumber=tmi) then begin result:=TI.Items[i-1]; exit; end;
 end;
end;

function TRubej.FindPR(level : byte):PTPR;
var
 i: word;
 p:^TPR;

begin
 Debug('F:FindPR');
 result:=nil;
 for i:=1 to PR.Count do
 begin
   p:=PR.Items[i-1];
   if (p^.AL=level) then begin result:=PR.Items[i-1]; exit; end;
 end;
end;

function TRubej.FindEmpty_1001_IdCU(): word;
var
 i: word;
begin
 Debug('F:FindEmpty_1001_IdCU');
 result:=0;
 for i:=1001 to 1001+CU_MAX do
   if FindCU(i, 1)=nil then
   begin
     result:=i;
     exit;
   end;
end;

function TRubej.FindEmpty_1001_IdZN():word;
var
 i: word;
 a: array [0..1] of byte;
begin
 Debug('F:FindEmpty_1001_IdZN');
 result:= 0;
 for i:=1001 to 1001+ZN_MAX do
 begin
   a[0]:= lo(i);
   a[1]:= hi(i);
   if FindZN(a, 1)=nil then
   begin
     result:= i;
     exit;
   end;;
 end;
end;

function TRubej.FindEmpty_1001_IdSH():word;
var
 i: word;
begin
 Debug('F:FindEmpty_1001_IdSH');
 result:= 0;
 for i:=1001 to 1001+SH_MAX do
   if FindTC(i, 3)=nil then
   begin
     result:= i;
     exit;
   end;;
end;

function TRubej.FindEmpty_1001_IdRL():word;
var
 i: word;
begin
 Debug('F:FindEmpty_1001_IdRL');
 result:= 0;
 for i:=1001 to 1001+RL_MAX do
   if FindTC(i, 4)=nil
   then
   begin
     result:= i;
     exit;
   end;;
end;

function TRubej.FindEmpty_1001_IdAP():word;
var
 i: word;
begin
 Debug('F:FindEmpty_1001_IdAP');
 result:= 0;
 for i:=1001 to 1001+AP_MAX do
   if FindTC(i, 9)=nil then
   begin
     result:= i;
     exit;
   end;;
end;

function TRubej.FindEmpty_1001_IdTERM():word;
var
 i: word;
begin
 Debug('F:FindEmpty_1001_IdTERM');
 result:= 0;
 for i:=1001 to 1001+TERM_MAX do
   if FindTC(i, 7)=nil then
   begin
     result:= i;
     exit;
   end;;
end;


function TRubej.FindEmptyIdScuUser: word;
var
 i: word;
begin
 Debug('F:FindEmptyIdScuUser');
 Result:= 0;
 for i:=1 to 1999 do
   if ScuUserMap[i]=0 then
   begin
     Result:= i;
     exit;
   end;
end;


function TRubej.SetIdZN(m:array of byte): word;
var
 i, j: word;
 pzn: PTZN;
 s: string;
begin
 Debug('F:SetIdZN');
 //�� ������ �������� >1000
 Result:= FindEmpty_1001_IdZN();
 //������� ��������� �� ����.
 try
   s:= ValToStr(m);
   if pos('.', s)>0 then
     exit;
   i:= strtoint(s);
   // ����� ���������
   for j:=1 to ZN.Count do
   begin
     pzn:= ZN.Items[j-1];
     // ������� ������ ����
     if (pzn^.BCPNumber[0]=m[0])and
        (pzn^.BCPNumber[1]=m[1])and
        (pzn^.BCPNumber[2]=m[2])and
        (pzn^.BCPNumber[3]=m[3]) then
       continue;
     if pzn^.Number = i then
       exit;
   end;
   // ���������� �������� �� ���������
   Result:= i;
 except
 end;
end;


function TRubej.SetIdTC(TCSerial: word; TCKind: byte): word;
var
 i, j: word;
 p, ptc: PTTC;
 s: string;
 code: Integer;

begin
 Debug('F:SetIdTC');
 case TCKind of
   1..4:  Result:= FindEmpty_1001_IdSH();
   5:     Result:= FindEmpty_1001_IdRL();
   6:     Result:= FindEmpty_1001_IdAP();
   7:     Result:= FindEmpty_1001_IdTERM();
   else
   begin
     Result:= 0;
     aMain.Log('Critical logic {06558321-199F-42DE-8CBA-73C8C5849A02}');
   end;
 end;

 try
  ptc:= FindTC(TCSerial, 0);
  if ptc=nil then exit;
  //
  s:= ValToStr(ptc^.BCPNumber);
  Val(s, i, code);
  if (code<>0) then
  i:= 0;
  //
  for j:=1 to TC.Count do
  begin
    p:=TC.Items[j-1];
    case TCKind of
      1..4: if (p^.Kind<1)or(p^.Kind>4) then continue;
      5:    if (p^.Kind<>5) then continue;
      6:    if (p^.Kind<>6) then continue;
      7:    if (p^.Kind<>7) then continue;
    end;
    if p^.ZoneVista=i then exit; // ����� ������ �� ����� ������������ ��������
    if p^.ZoneVista<>0 then continue;
    if p=ptc then continue;
  end;
  Result:=i;
 except
 end;
end;


procedure TRubej.SaveR8h;
var
 pTCU:^TCU;
 pTZN:^TZN;
 pTGR:^TGR;
 pTTC:^TTC;
 pTUS:^TUS;
 pTTI:^TTI;
 pTPR:^TPR;
 tf : TextFile;
 s, st : string;
 i:word;

begin
 Debug('F:SaveR8h');
 s:=ReadPath() + Format('Net%uBig%u.r8h',[NetDevice, BigDevice]);
 AssignFile(tf, s);
 Rewrite(tf);
 TRY

 Writeln(tf, '[��]');
 if CU.Count>0 then
 for i:=1 to CU.Count do
 begin
   pTCU:=CU.Items[i-1];
   s:= Format('%s:%d ������=%d.%d ����� %d', [HWTypeToStr(pTCU^.HWType), pTCU^.HWSerial, pTCU^.Ver, pTCU^.SubVer, (pTCU^.flags shr 3) and 1 + 1 ]);
   if HWTypeToStr(pTCU^.HWType)='���-02'
   then s:= s + Format(' IP=%d.%d.%d.%d', [pTCU^.ConfigDummy[2], pTCU^.ConfigDummy[3], pTCU^.ConfigDummy[4], pTCU^.ConfigDummy[5]]);
   if (pTCU^.flags and $10)>0 then
     s:= s + '; ����������';
   Writeln(tf, s);
 end;

 Writeln(tf, '');
 Writeln(tf, '[����]');
 if ZN.Count>0 then
 for i:=1 to ZN.Count do
 begin
   pTZN:=ZN.Items[i-1];
   s:= Format('�����=%s ������=%d',[ValToStr(pTZN^.BCPNumber), pTZN^.Status]);
   Writeln(tf, s);
 end;

 Writeln(tf, '');
 Writeln(tf, '[������]');
 if GR.Count>0 then
 for i:=1 to GR.Count do
 begin
   pTGR:=GR.Items[i-1];
   s:= Format('�����=%d ���=%d', [pTGR^.Num, pTGR^.TextNamePointer]);
   Writeln(tf, s);
 end;

 Writeln(tf, '');
 Writeln(tf, '[��]');
 if TC.Count>0 then
 for i:=1 to TC.Count do
 begin
   pTTC:=TC.Items[i-1];
   s:= Format('��=%.5d �����=%d ����=%s ������=%d ���=%d ������������=%s:%d:%d',
             [pTTC^.Sernum, pTTC^.ZoneVista, ValToStr(pTTC^.ParentZone), pTTC^.Group, pTTC^.Kind, HWTypeToStr(pTTC^.HWType), pTTC^.HWSerial, pTTC^.ElementHW]);
   Writeln(tf, s);
 end;

 Writeln(tf, '');
 Writeln(tf, '[��]');
 if TI.Count>0 then
 for i:=1 to TI.Count do
 begin
   pTTI:=TI.Items[i-1];
   s:= Format('��=%d Flags=%.2xh �������� %.2d:%.2d-%.2d:%.2d ��� =%.2xh',
              [pTTI^.ParentTimeZone, pTTI^.Flags, pTTI^.BeginHour, pTTI^.BeginMin, pTTI^.EndHour, pTTI^.EndMin, pTTI^.DayMap]);
   Writeln(tf, s);
 end;

 Writeln(tf, '');
 Writeln(tf, '[�����]');
 if PR.Count>0 then
 for i:=1 to PR.Count do
 begin
   pTPR:=PR.Items[i-1];
   st:= ValToStr(pTPR^.Zone);
   s:= Format('AL=%d ����=%s ������ ����=%d',
              [pTPR^.AL, st, pTPR^.ZoneStatus]);
   s:= s + Format(' ���_��=%d ��.��=%d ����������=%.8xh', [pTPR^.TCOType, pTPR^.TCOGroup, pTPR^.Map]);
   s:= s + Format(' ��=%d Flags=%.2xh', [pTPR^.TimeZone, pTPR^.Flags]);
   Writeln(tf, s);
 end;


 Writeln(tf, '');
 Writeln(tf, '[������������]');
 if US.Count>0 then
 for i:=1 to US.Count do
 begin
   pTUS:=US.Items[i-1];
   s:= Format('��=%d ����=%s ���-���=%d ��� ��������������=%d',
       [pTUS^.Id, ValToStr(pTUS^.ParentZone), pTUS^.PinCode, pTUS^.TypeIdentifier]);
   s:= s + Format(' Facility=%d �����=%d', [pTUS^.IdentifierCode[0], pTUS^.IdentifierCode[1] + pTUS^.IdentifierCode[2]*256]);
   s:= s + Format(' ��1=%d ��2=%d APB=%d F=%.2xh', [pTUS^.AL1, pTUS^.AL2, pTUS^.CheckRulesLevel, pTUS^.Flags]);
   Writeln(tf, s);
 end;

 FINALLY
   Flush(tf);
   CloseFile(tf);
 END;
end;


procedure TRubej.CfgToCsv;
type
 arbyte = array of byte;

var
 pTTC: ^TTC;
 tf: TextFile;
 s, sZone, sData, sElementHW: string;
 i: word;

begin
 Debug('F:CfgToCsv');
 //
 s:= ReadPath() + Format('Net%uBig%u.csv',[NetDevice, BigDevice]);
 AssignFile(tf, s);
 TRY
   Rewrite(tf);
   //
   s:= Format('�����;��� ����;�;ID;���;���;�������;��� ��;���;������� ��;����������;���;������;��������������;������', []);
   Writeln(tf, s);
   //
   if TC.Count>0 then
   for i:=1 to TC.Count do
   begin
     pTTC:= TC.Items[i-1];
     //�����;
     //��� ����;
     //�;
     //id��;
     //���;
     //���;
     //�������;
     //��� ��;
     //���;
     //������� ��;
     //����������;
     //���;
     //������;
     //��������������
     //������;
     sZone:= ValToStr(pTTC^.ParentZone[0]);
     sData:= Bin2Simbol(PChar(@pTTC^.ConfigDummy[0]), 15);
     sElementHW:= IntToStr(pTTC^.ElementHW);
     if pTTC^.HWType=32 then
       case pTTC^.Kind of
         5: sElementHW:= IntToStr(pTTC^.ElementHW-6);
         6: sElementHW:= IntToStr(pTTC^.ElementHW-9);         
       end;
     s:= Format('%d;%s;%d;%.5d;%s;%d;%d;%s;%d;%s;%d;%d;%d;%d;%s',
              [ pTTC^.PartVista,
                sZone,
                pTTC^.ZoneVista,
                pTTC^.Sernum,
                TCTypeToStr(PTTC^.Kind),
                pTTC^.StringPointer,
                pTTC^.Group,
                HWTypeToStr(pTTC^.HWType),
                pTTC^.HWSerial,
                sElementHW,
                byte((pTTC^.Flags and $08)>0),
                (pTTC^.Flags shr 4) and $03,
                byte((pTTC^.Flags and $80)>0),
                pTTC^.RestoreTime,
                sData ] );
     Writeln(tf, s);
   end;
   //
   Flush(tf);
 FINALLY
   CloseFile(tf);
 END;

end;



//-----------------------------------------------------------------------------




//----------------------------------------//
//           Backup r8m, r8b              //
//----------------------------------------//

procedure ChangeVal(var s1, s2: string);
var
 i, len: word;
 b: byte;
begin
 len:= length(s1);
 s2:= '';
 for i:= 0 to (len div 2)-1 do
 begin
   b:= StrToInt( '$'+ copy(s1, 1+i*2, 2) );
   b:= b xor (3 shl (i mod 3));
   s2:= s2 + IntToHex(b, 2);
 end;
end;


procedure TRubej.WriteBcpFile;
type
 Tar256 = array [0..255] of byte;
var
 fb: TextFile;
 FileName, s1, s2: string;
 i, j: word;
 par: ^Tar256;
begin
 Debug('F:WriteBcpFile');
 FileName:= ReadPath() + Format('Net%uBig%u.bcp',[NetDevice, BigDevice]);
 AssignFile(fb, FileName);
 Rewrite(fb);
 TRY

 for i:=1 to CU.Count do
 begin
   s1:= IntToHex(3, 2);
   par:= CU.Items[i-1];
   for j:= 0 to sizeof(TCU)-1-7 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to ZN.Count do
 begin
   s1:= IntToHex(1, 2);
   par:= ZN.Items[i-1];
   for j:= 0 to sizeof(TZN)-1-3 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to GR.Count do
 begin
   s1:= IntToHex(9, 2);
   par:= GR.Items[i-1];
   for j:= 0 to sizeof(TGR)-1-0 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to TC.Count do
 begin
   s1:= IntToHex(2, 2);
   par:= TC.Items[i-1];
   for j:= 0 to sizeof(TTC)-1-12 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to TI.Count do
 begin
   s1:= IntToHex(10, 2);
   par:= TI.Items[i-1];
   for j:= 0 to sizeof(TTI)-1-0 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to PR.Count do
 begin
   s1:= IntToHex(11, 2);
   par:= PR.Items[i-1];
   for j:= 0 to sizeof(TPR)-1-0 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to US.Count do
 begin
   s1:= IntToHex(4, 2);
   par:= US.Items[i-1];
   for j:= 0 to sizeof(TUS)-1-0 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to RN.Count do
 begin
   s1:= IntToHex(14, 2);
   par:= RN.Items[i-1];
   for j:= 0 to sizeof(TRN)-1-0 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to RP.Count do
 begin
   s1:= IntToHex(6, 2);
   par:= RP.Items[i-1];
   for j:= 0 to sizeof(TRP)-1-0 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 for i:=1 to RI.Count do
 begin
   s1:= IntToHex(13, 2);
   par:= RI.Items[i-1];
   for j:= 0 to sizeof(TRI)-1-0 do
     s1:= s1 + IntToHex(par^[j], 2);
   ChangeVal(s1, s2);
   Writeln(fb, s2);
 end;

 new(par);
 move(HD, par^, sizeof(THOLIDAY));
 s1:= IntToHex(12, 2);
 for j:= 0 to sizeof(THOLIDAY)-1-0 do
   s1:= s1 + IntToHex( par^[j] , 2);
 Dispose(par);
 ChangeVal(s1, s2);
 Writeln(fb, s2);

 FINALLY
   Flush(fb);
   CloseFile(fb);
 END;
end;


function TRubej.ReadBcpFile: boolean;
type
 Tar256 = array [0..255] of byte;
var
 fb: TextFile;
 FileName, s1, s2: string;
 i, j, len: word;
 ar: Tar256;
begin
 Debug('F:ReadSBcpFile');
 Result:= False;
 amain.Log('������ ������������ ...');
 FileName:= ReadPath() + Format('Net%uBig%u.bcp',[NetDevice, BigDevice]);
 //
 if not FileExists(FileName) then
   exit;
 i:= 0;
 AssignFile(fb, FileName);
 TRY
   Reset(fb);
   While not eof(fb) do
   begin
     Readln(fb, s1);
     len:= length(s1);
     if (len=0)or((len div 2)>256)or((len mod 2)>1) then
       continue;
     ChangeVal(s1, s2);
     i:= StrToInt( '$'+Copy(s2, 1, 2) );
     case i of
       3:
       begin
         for j:= 0 to sizeof(TCU)-7-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadCU(ar[0], 0);
       end;
       1:
       begin
         for j:= 0 to sizeof(TZN)-3-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadZN(ar[0], 0);
       end;
       9:
       begin
         for j:= 0 to sizeof(TGR)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadGR(ar[0]);
       end;
       2:
       begin
         for j:= 0 to sizeof(TTC)-12-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadTC(ar[0], 0, 0);
       end;
       10:
       begin
         for j:= 0 to sizeof(TTI)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadTI(ar[0]);
       end;
       11:
       begin
         for j:= 0 to sizeof(TPR)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadPR(ar[0]);
       end;
       4:
       begin
         for j:= 0 to sizeof(TUS)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadUS(ar[0]);
       end;
       14:
       begin
         for j:= 0 to sizeof(TRN)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadRN(ar[0]);
       end;
       6:
       begin
         for j:= 0 to sizeof(TRP)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadRP(ar[0]);
       end;
       13:
       begin
         for j:= 0 to sizeof(TRI)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadRI(ar[0]);
       end;
       12:
       begin
         for j:= 0 to sizeof(THOLIDAY)-0-1 do
           ar[j]:= StrToInt( '$'+Copy(s2, 3+2*j, 2) );
         LoadHD(ar[0]);
       end;
     end;//case
   end;//while
   
   NeedSaveR8h:= True;
   Result:= True;
 EXCEPT
   amain.Log('���� ������ �������������: ('+inttostr(i)+')');
 END;
 CloseFile(fb);
end;

procedure TRubej.PrintConf;
begin
 amain.Log('��������� ������������...');
 amain.Log('�� ('+inttostr(CU.Count)+')');
 amain.Log('��� ('+inttostr(ZN.Count)+')');
 amain.Log('�� ('+inttostr(TC.Count)+')');
 amain.Log('����� ('+inttostr(GR.Count)+')');
 amain.Log('������������� ('+inttostr(US.Count)+')');
 amain.Log('�� ('+inttostr(TI.Count)+')');
 amain.Log('���� ('+inttostr(PR.Count)+')');
 amain.Log('�������� ('+inttostr(RN.Count)+')');
 amain.Log('�������� ('+inttostr(RP.Count)+')');
 amain.Log('���������� ('+inttostr(RI.Count)+')');
 amain.Log('����������');
end;

function TRubej.SendCfgToBcp: boolean;
var
 i: word;
 j: byte;
 pcu: PTCU;
 ptc: PTTC;
 pzn: PTZN;
 pgr: PTGR;
 pus: PTUS;
 pti: PTTI;
 ppr: PTPR;
 prn: PTRN;
 prp: PTRP;
 pri: PTRI;
begin
  Result:= True;
  if CU.Count>0 then
  for i:=0 to CU.Count-1 do
  begin
    pcu:= CU.items[i];
    mCreateCU(0, pcu^.HWSerial, pcu^.HWType, pcu^.flags, pcu^.ConfigDummy[0] );
  end;
  if ZN.Count>0 then
  for i:=0 to ZN.Count-1 do
  begin
    pzn:= ZN.items[i];
    mCreateZone(pzn^.BCPNumber, pzn^.Flags, pzn^.Status, pzn^.StringPointer, 0);
  end;
  if TC.Count>0 then
  for i:=0 to TC.Count-1 do
  begin
    ptc:= TC.items[i];
    mCreateTC( ptc^.Sernum,
               ptc^.Kind,
               ptc^.BCPNumber,
               ptc^.StringPointer,
               ptc^.Flags,
               ptc^.ParentZone,
               ptc^.Group,
               ptc^.HWType,
               ptc^.HWSerial,
               ptc^.ElementHW,
               ptc^.ConfigDummy,
               ptc^.RestoreTime,
               0,
               0);
  end;
  if GR.Count>0 then
  for i:=0 to GR.Count-1 do
  begin
    pgr:= GR.items[i];
    mCreateGR( pgr^.Num,
               pgr^.TextNamePointer);
  end;
  if US.Count>0 then
  for i:=0 to US.Count-1 do
  begin
    pus:= US.items[i];
    mCreateUser
           (
            pus^.Flags,
            pus^.Id,
            pus^.TypeIdentifier,
            pus^.IdentifierCode,
            pus^.PinCode,
            pus^.AL1,
            pus^.CheckRulesLevel,
            pus^.ParentZone,
            pus^.LifeTime,
            pus^.AccessToBCP,
            pus^.AL2,
            pus^.AccessToArm
            );
  end;
  if TI.Count>0 then
  for i:=0 to TI.Count-1 do
  begin
    pti:= TI.items[i];
    mCreateChangeTimeInterval
                       (
                        $03,
                        pti^.ParentTimeZone,
                        pti^.INumber,
                        pti^.BeginHour,
                        pti^.EndHour,
                        pti^.BeginMin,
                        pti^.EndMin,
                        pti^.DayMap,
                        1+byte(pti^.INumber>1)
                        );
  end;
  j:= 0;
  if PR.Count>0 then
  for i:=0 to PR.Count-1 do
  begin
    ppr:= PR.items[i];
    mCreateChangePravo
                       (
                        ppr^.Flags,
                        ppr^.AL,
                        ppr^.Zone,
                        ppr^.ZoneStatus,
                        ppr^.TCOType,
                        ppr^.TCOGroup,
                        ppr^.Map,
                        ppr^.TimeZone,
                        1+byte(j=ppr^.AL)
                        );
    j:= ppr^.AL;
  end;
  if RN.Count>0 then
  for i:=0 to RN.Count-1 do
  begin
    prn:= RN.items[i];

    mCreateRN(
                prn^.Num,
                prn^.Data
             );
  end;

  if RP.Count>0 then
  for i:=0 to RP.Count-1 do
  begin
    prp:= RP.items[i];
    mCreateRP(
        prp^.Flags,
        prp^.Num,
        prp^.Name,
        prp^.Manual
        );
  end;

  if RI.Count>0 then
  for i:=0 to RI.Count-1 do
  begin
    pri:= RI.items[i];
    mCreateRI(
                pri^.Flags,
                pri^.Obj,
                pri^.Cmd,
                pri^.RSData,
                pri^.PNum,
                pri^.INum
             );
  end;

 mCreateHDs(
        HD.Flag,
        HD.Data,
        HD.Res
        );
end;


procedure Trubej.DeleteUD(AL: byte);
var
 i: word;
 ppr: PTPR;
begin
  if PR.Count>0 then
    for i:=PR.Count-1 downto 0 do
    begin
      ppr:=PR.Items[i];
      if ppr^.AL=AL then
      begin
        PR.Remove(ppr);
        Dispose(ppr);
      end;
    end;
end;


procedure Trubej.ClearWBuf;
var
 t:^TTelegram;
begin
  while WBuf.Count>0 do
  begin
    t:= WBuf.Items[0];
    Dispose(t);
    WBuf.Delete(0);
  end;
end;


//-----------------------------------------------------------------------------
function ValToStr (var m: array of byte): string;
var
  st: string;
  i: byte;

begin
 st:='';
 for i:=0 to 2 do
 begin
   st:= st + IntToHex(m[i],2);
   if st[length(st)] = 'A' then SetLength(st, length(st)-1);
   if st[length(st)] = 'A' then SetLength(st, length(st)-1);
 end;
 //
 for i:=5 downto 0 do
   if ((m[3] shr i) and 1)>0 then Insert('.', st, i+2);
 //
 result:= st;
end;

//-----------------------------------------------------------------------------
function StrToVal (s: string; var m: array of byte): boolean;
const
 DigitArray: array [0..1] of char =('0','1');
 DigitSet: set of char = ['0','1','2','3','4','5','6','7','8','9'];

var
 i,j : byte;
 st : string;

begin
 Result:= false;
 //
 st:='';
 m[0]:=$00;
 m[1]:=$00;
 m[2]:=$00;
 m[3]:=$00;

 // �������� ������������ ��.������
 if (length(s)=0) or (length(s)>6) then
   exit;
 for i:=1 to length (s) do
   if s[i] in DigitSet
     then st:=st+s[i]
     else exit;

 // ������� ���������
 if (st='0') then
 begin
   m[0]:=$AA;
   m[1]:=$AA;
   m[2]:=$AA;
   Result:= True;
   exit;
 end;

 // �������
 for i:=1 to length(st) do
   if (i mod 2)>0
     then  m[(i-1) div 2]:=m[(i-1) div 2] or (strtoint(st[i]) shl 4)
     else m[(i-1) div 2]:=m[(i-1) div 2] or strtoint(st[i]);

 // ������� ��
 for i:=length(st)+1 to 6 do
   if (i mod 2)>0
     then  m[(i-1) div 2]:=m[(i-1) div 2] or ($A shl 4)
     else m[(i-1) div 2]:=m[(i-1) div 2] or $A;

 // ����������� �����
 j:=0;
 for i:=1 to length (s) do
   if s[i]<>'.'
   then inc(j)
   else m[3]:=m[3] or (1 shl (j-1));
 //
 Result:= True;
end;

//-----------------------------------------------------------------------------
function Vrez0(t: PTTelegram): word;
var
 i, Count: word;
begin
 i:=2;
 Count:= t^[5]+6+2;
 while (i<Count)and(cport<>nil) do
 begin
   if (t^[i]=$b6) then
   begin
     move (t^[i+1], t^[i+2], Count-i);
     t^[i+1]:=0;
     inc(Count);
   end;
   inc(i);
 end; //while
 result:= Count;
end;


//-----------------------------------------------------------------------------
















//-----------------------------------------------------------------------------
function GetR8c(sec, key, def: string) : string;
var
 str : string;
 ini : TIniFile;
begin
 Debug('F:GetR8c');
 ini:=TIniFile.Create(ReadPath() + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice]));
 str:=ini.ReadString(sec,key,def);
 Result:=AnsiUpperCase(str);
 ini.WriteString(sec, key, Result);
 ini.Free();
end;

procedure SaveR8c(sec, key, value: string);
var
 ini : TIniFile;
 s,d, CfgDir:string;
 year, month, day : word;
 h, m, c, MSec: word;
begin
 Debug('F:SaveR8c');
 s:= ReadPath() + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice]);
 CfgDir:= ReadPath() + 'DrvRubejOldFiles\';
 if not DirectoryExists(CfgDir) then
   CreateDir(CfgDir);
 d:= CfgDir + '�����_' + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice]);
 DecodeTime(now, h, m, c, MSec);
 DecodeDate(now, year, month, day);
 insert('_'+inttostr(year)+inttostr(month)+inttostr(day)+inttostr(h)+inttostr(m)+inttostr(c)+inttostr(MSec) , d, length(d)-3);
 if r8ccopy then
   CopyFile(s, d);
 Value:=AnsiUpperCase(value);
 ini:=TIniFile.Create(s);
 ini.WriteString(sec, key, value);
 ini.Free();
end;

procedure DeleteR8c(sec, key: string);
var
 ini : TIniFile;
 s,d, CfgDir:string;
 ls: TStringList;
 year, month, day : word;
 h, m, c, MSec: word;
 i: word;
begin
 Debug('F:DeleteR8c');
 s:= ReadPath() + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice]);
 CfgDir:= ReadPath() + 'DrvRubejOldFiles\';
 if not DirectoryExists(CfgDir) then
   CreateDir(CfgDir);
 d:= CfgDir + '�����_' + Format('NET%uBIG%u.r8c',[rub.NetDevice, rub.BigDevice]);
 DecodeTime(now, h, m, c, MSec);
 DecodeDate(now, year, month, day);
 insert('_'+inttostr(year)+inttostr(month)+inttostr(day)+inttostr(h)+inttostr(m)+inttostr(c)+inttostr(MSec) , d, length(d)-3);
 //
 ini:=TIniFile.Create(s);
 if key=''
   then
   begin
     ls:= TStringList.Create;
     ini.ReadSections(ls);
     if ls.Count>0 then
     begin
       i:= 0;
       while i<ls.Count do
       begin
         if ls[i]=sec then
         break;
         inc(i);
       end;
       if i<ls.Count then
       begin
         if r8ccopy then
           CopyFile(s, d);
         ini.EraseSection(sec);
       end;
       ls.Free;
     end
   end //key=''
   else
   begin
     if r8ccopy then
       CopyFile(s, d);
     ini.DeleteKey(sec, key);
   end;
 ini.Free();
end;


procedure CopyFile(n1, n2 : string);
var
 s:TStringList;
begin
 s:=TStringList.Create;
 s.LoadFromFile(n1);
 s.SaveToFile(n2);
 s.Free;
end;


function ReadScuUserMap(sec, key, def: string): string;
var
 str : string;
 ini : TIniFile;
begin
 Debug('F:ReadScuUserMap');
 str:= ReadPath() + Format('NET%uBIG%u.scu',[rub.NetDevice, rub.BigDevice]);
 ini:=TIniFile.Create(str);
 str:= ini.ReadString(sec,key,def);
 Result:= AnsiUpperCase(str);
 ini.WriteString(sec, key, Result);
 ini.Free();
end;

procedure WriteScuUserMap(sec, key, value: string);
var
 ini : TIniFile;
 str: string;
begin
 Debug('F:WriteScuUserMap');
 str:= ReadPath() + Format('NET%uBIG%u.scu',[rub.NetDevice, rub.BigDevice]);
 ini:= TIniFile.Create(str);
 Value:= AnsiUpperCase(value); 
 ini.WriteString(sec, key, value);
 ini.Free();
end;

//-----------------------------------------------------------------------------
function TCTypeToStr(Kind: byte): String;
begin
 case Kind of
   0: Result:= '�����';
   1: Result:= '�������� ��';
   2: Result:= '��������� ��';
   3: Result:= '�������� ��';
   4: Result:= '��������������� ��';
   5: Result:= '����';
   6: Result:= '����� �������';
   7: Result:= '��������';
   8: Result:= 'SLUICE';
   9: Result:= '����';
   else Result:= IntToStr(Kind);
   end;
end;

function TCTypeToInt(Kind: string): word;
begin
 if Kind='�����' then Result:= 0 else
 if Kind='�������� ��' then Result:= 1 else
 if Kind='��������� ��' then Result:= 2 else
 if Kind='�������� ��' then Result:= 3 else
 if Kind='��������������� ��' then Result:= 4 else
 if Kind='����' then Result:= 5 else
 if Kind='����� �������' then Result:= 6 else
 if Kind='��������' then Result:= 7 else
 if Kind='SLUICE' then Result:= 8 else
 if Kind='����' then Result:= 9 else
 Result:= StrToInt(Kind);
end;

function DescriptionBCPRetCode(Code: word): string;
begin
 Debug('F:DescriptionBCPRetCode');
 result:='����������� ���';
 case Code of
 0: result:=    'OK';
 1: result:=   	'������ �� ������';
 2: result:=   	'�� ���������';
 3: result:=   	'��� ����� � ��';
 4: result:=   	'��� ����';
 5: result:=   	'���� �� �������';
 6: result:=   	'������������ �� �������';
 7: result:=   	'����������� ��� ������� ��';
 8: result:=   	'����������� ������� ����������';
 9: result:=   	'��� ���������';
 10: result:=   '������ ���� ������������';
 11: result:=   '������������ �� ������';
 12: result:=   '������������ ������������';
 13: result:=   '����������� ���� ������������ �� �������';
 14: result:=   '������ �����������';
 15: result:=   '������ ������������';
 16: result:=   '������ �� �����';
 17: result:=   '������ �� ����� ��� ���������� �� ������';
 18: result:=   '�� ��� �������';
 19: result:=   '������ ��������';
 20: result:=   '������ ���������';
 21: result:=   '��� �����������';
 22: result:=   '������ ��������������';
 23: result:=   '��� ������';
 24: result:=   '�������� ��������';
 25: result:=   '������ ��� ����������';
 26: result:=   '������ ���� �������';
 27: result:=   '����������� �������';
 28: result:=   '������������ ��������� ������� ��';
 29: result:=   '��� �������������� ������';
 30: result:=   '����� ������ ��������';
 31: result:=   '��� ����� ������� ������� �������';
 32: result:=   '������ �� ���������������';
 33: result:=   '������ ����� � ��';
 34: result:=   '����������� ������';
 35: result:=   '�� ������ ��������� ���������';
 36: result:=   '��������� �������� �� ������';
 37: result:=   '������ ���� ���������� ���������';
 38: result:=   '������ � ��������� �������� ���������';
 39: result:=   '������������ ����� ����';
 40: result:=   '��������� ���������������� ���������';
 41: result:=   '��������� ���������� ���������';
 42: result:=   '������ ���� ��� ���������� ���������';
 43: result:=   '��������� ���������� � ������� ���������';
 44: result:=   '�� ���������';
 45: result:=   '������ ��������� �����';
 46: result:=   '����������� �������� �� ������ ������� �������';
 47: result:=   '����������� �������� �� ����������';
 48: result:=   '����������� ������ ������������';
 49: result:=   '������ �� �� ������';
 50: result:=   '�������� �� ����� ��� �24 ����';
 51: result:=   '�����';
 52: result:=   '������ �������� ������ �������';
 53: result:=   '������ ���������� �� ���������� ���������� ������������� ���������';
 54: result:=   '������ ���������� ��������� ���';
 55: result:=   '������ ������� ����������';
 56: result:=   '������ �������';
 57: result:=   '������� ��� �� ������';
 58: result:=   '������������� ������������';
 59: result:=   '������������ ��� ������������';
 end;
end;

function HWTypeToStr(n: byte): string;
var
 s: string;
begin
 Debug('F:HWTypeToStr');
 s:= inttostr(n);
 case n of
   1:  s:='���';
   2:  s:='���-03-4';
   3:  s:='��-01';
   4:  s:='����-01';
   5:  s:='���';
   6:  s:='���-02�';
   7:  s:='����-01';
   8:  s:='����-01';
   9:  s:='����-02';
   10: s:='�����-01';
   11: s:='���-02��';
   12: s:='���-02';
   13: s:='��-02';
   14: s:='���-01';
   16: s:='����-03';
   17: s:='����-04';
   18: s:='����-01';
   19: s:='�����-01�';
   20: s:='��-03';
   21: s:='�����';
   22: s:='������-101';
   23: s:='���-01';
   24: s:='����-01';
   25: s:='���-01';
   26: s:='����-01';
   27: s:='����-02';
   28: s:='����-01';
   29: s:='�-020';
   30: s:='����';
   31: s:='���-03';
   32: s:='���-02';
   33: s:='����';
   34: s:='���-�������';
   35: s:='���-�������';
   36: s:='��2-�������';
   37: s:='����';
   38: s:='MODBUS';
   39: s:='MODBUSDECONT';
   40: s:='MODBUSNEVOD';
   41: s:='��2-�������';
   42: s:='����-01';
   43: s:='��1-�������-�����';
   44: s:='��2-�������-����';
   45: s:='CONTACTID';
   46: s:='��-������';
   47: s:='���-03�';
   48: s:='������';
   49: s:='��1-�������';
 end;
 result:= s;
end;

function StrToHWType(s: string): byte;
var
 i: byte;
begin
 Debug('F:StrToHWType');
 Result:=0;
 for i:=1 to 49 do
 if HWTypeToStr(i)=s then
 begin
   Result:=i;
   Break;
 end;
end;

function HWTypeBCPError(n: byte): string;
var
 s: string;
begin
 Debug('F:HWTypeBCPError');
 s := inttostr(n);
 case n of
 0: s:= '����������� ������';
 1: s:= '����������� �������� ���������� � ������� �������';
 2: s:= '����������� ������� � ������� �������';
 3: s:= '����������� ������������ ���';
 4: s:= '����������� ������������ ��';
 5: s:= '����������� ������������ ��';
 6: s:= '����������� ������������ ����� ��';
 7: s:= '����������� ������������ ��������� ���';
 8: s:= '����������� ������������ �������� ���';
 9: s:= '����������� ������������ ������� �������';
 10: s:= '����������� ������������ �������������';
 11: s:= '����������� ������������ ����� ������';
 12: s:= '������ ��������� �����';
 13: s:= '����������� ������ ��������� ���������';
 14: s:= '������ ��������� ��������� ������������';
 15: s:= '����������� ������ � ��������� ��';
 16: s:= '����������� ������ � ����������� ������ (��� ����-01)';
 17: s:= '����������� �������� ���������� �� �������������';
 18: s:= '����������� ������������ ����������� ���';
 19: s:= '����������� �������� ����� �����';
 20: s:= '����������� ������ ����������������� �������';
 21: s:= '����������� ������ ������� ��������� �������';
 22: s:= '����������� ������������ ���������� ��������';
 23: s:= '������ ������ � Ethernet';
 24: s:= '������ �������� RAM';
 25: s:= '������ �������� EEPROM';
 26: s:= '������ �������� ����� ��������� �������';
 27: s:= '������ �������� ����������� RS-485';
 28: s:= '������ �������� ������� ����� ������ ���';
 29: s:= '������ ������ � ��';
 30: s:= '����������� ������ � ��������� ��';
 31: s:= '����������� ������ � ��������� �������������';
 32: s:= '����������� ������ � ��������� ���������� ����� ������';
 end;
 result:= s;
end;


function LinkTypeToStr(n: byte): string;
var
 s: String;
begin
 Debug('F:LinkTypeToStr');
 s:= inttostr(n);
 case n of
   1: s:='��';
   2: s:='��';
 end;
 result:= s;
end;


function StrToLinkType(s: string): byte;
var
 i: byte;
begin
 Debug('F:StrToLinkType');
 Result:=0;
 for i:=1 to 2 do
 if LinkTypeToStr(i)=s then
 begin
   Result:= i;
   Break;
 end;
end;

// �� ������� � �����. �� ������ ����������� ����� �������
function ApEventAfterReset(CurState: word): word;
begin
 Result:= 0;
 case CurState of
   1, 5, 6: Result:= RIC_MODE;
   3: Result:= SUD_RESETHELD;
   4: Result:= SUD_RESETFORCED;
 end;
 
end;

//-----------------------------------------------------------------------------




//----------------------------------------//
//               ����������               //
//----------------------------------------//
procedure mGetVer;
var
 t:^TTelegram;
begin
 Debug('F:mGetVer');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); t^[5]:=1; // ���������
 t^[6]:=$80; // �������
 t^[7]:=lo(kc(t^,t^[5]+6)); t^[8]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetClock;
var
 t:^TTelegram;
begin
 Debug('F:mGetClock');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); t^[5]:=2; // ���������
 t^[6]:=$89; // �������
 t^[7]:=$01; // �������
 t^[8]:=lo(kc(t^,t^[5]+6)); t^[9]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mSetClock(time: Longword);
var
 t: ^TTelegram;
begin
 Debug('F:mSetClock');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); t^[5]:=6; // ���������
 t^[6]:=$89; // �������
 t^[7]:=$02; // �������
 t^[8]:= time and $FF;
 t^[9]:= time shr  8 and $FF;
 t^[10]:=time shr 16 and $FF;
 t^[11]:=time shr 24 and $FF;
 // 42 6A 20 0A
 t^[12]:=lo(kc(t^,t^[5]+6)); t^[13]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetWordBCP;
var
 t:^TTelegram;
begin
 Debug('F:mGetWordBCP');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=1;  // ����� ��� ��
 t^[6]:=$81; // �������
 t^[7]:=lo(kc(t^,t^[5]+6)); t^[8]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetLisences;
var
 t:^TTelegram;
begin
 Debug('F:mGetLisences');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=1;  // ����� ��� ��
 t^[6]:=$8A; // �������
 t^[7]:=lo(kc(t^,t^[5]+6)); t^[8]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetBCPInfo;
var
 t:^TTelegram;
begin
 Debug('F:mGetBCPInfo');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=1;   // ����� ��� ��
 t^[6]:=$95; // �������
 t^[7]:=lo(kc(t^,t^[5]+6)); t^[8]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetBCPErrorInfo;
var
 t:^TTelegram;
begin
 Debug('F:mGetBCPErrorInfo');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=1;   // ����� ��� ��
 t^[6]:=$96; // �������
 t^[7]:=lo(kc(t^,t^[5]+6)); t^[8]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mCreateCU (num, adr: word; typeCU, flags: byte; var Dummy: array of byte);
var
 t: ^TTelegram;
begin
 Debug('F:mCreateCU');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=19; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$01; // ������� ��

 //hid
 t^[9]:=typeCU;
 t^[10]:=lo(adr);
 t^[11]:=hi(adr);
 //ver.
 t^[12]:=lo(0);
 t^[13]:=hi(0);
 //flags
 t^[14]:=flags;
 //������
 move(Dummy, t^[15], 8);
 //��
 t^[23]:=lo(kc(t^[9],14)); t^[24]:=hi(kc(t^[9],14)); // �� - ��
 t^[25]:=lo(kc(t^,t^[5]+6)); t^[26]:=hi(kc(t^,t^[5]+6)); // ��

 t^[254]:=lo(num);
 t^[255]:=hi(num);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

{
procedure mRestoreCfgCU(var ar: array of byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateCU');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=19; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$01; // ������� ��

 //hid
 t^[9]:=typeCU;
 t^[10]:=lo(adr);
 t^[11]:=hi(adr);
 //ver.
 t^[12]:=lo(0);
 t^[13]:=hi(0);
 //flags
 t^[14]:=flags;
 //������
 move(Dummy, t^[15], 8);
 //��
 t^[23]:=lo(kc(t^[9],14)); t^[24]:=hi(kc(t^[9],14)); // �� - ��
 t^[25]:=lo(kc(t^,t^[5]+6)); t^[26]:=hi(kc(t^,t^[5]+6)); // ��

 t^[254]:=lo(num);
 t^[255]:=hi(num);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;
}

procedure mChangeCU (num, adr: word; typeCU, flags: byte; var Dummy: array of byte);
var
 t:^TTelegram;
begin
 Debug('F:ChangeCU');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=19; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$02;// �������� ��

 //hid
 t^[9]:=typeCU;
 t^[10]:=lo(adr);
 t^[11]:=hi(adr);
 //ver.
 t^[12]:=lo(0);
 t^[13]:=hi(0);
 //flags
 t^[14]:=flags;
 //������
 move(Dummy, t^[15], 8);
 //��
 t^[23]:=lo(kc(t^[9],14)); t^[24]:=hi(kc(t^[9],14)); // �� - ��
 t^[25]:=lo(kc(t^,t^[5]+6)); t^[26]:=hi(kc(t^,t^[5]+6)); // ��
 t^[254]:=lo(num);
 t^[255]:=hi(num);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteCU (adr: word; typeCU: byte; Number: word);
var
 t:^TTelegram;
begin
 Debug('F:mDeleteCU');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$06; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$03; // ������� ��
 //hid
 t^[9]:=typeCU;
 t^[10]:=lo(adr);
 t^[11]:=hi(adr);

 t^[12]:=lo(kc(t^,t^[5]+6)); t^[13]:=hi(kc(t^,t^[5]+6)); // ��

 t^[254]:=lo(Number);
 t^[255]:=hi(Number);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteCUs;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteCUs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$04; // ������� ��� ��
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 //
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetCU (adr: word; typeCU: byte; Number: word);
var
 t:^TTelegram;
begin
 Debug('F:mGetCU');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$06; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$05; // ������ ��
 //hid
 t^[9]:=typeCU;
 t^[10]:=lo(adr);
 t^[11]:=hi(adr);
 t^[12]:=lo(kc(t^,t^[5]+6)); t^[13]:=hi(kc(t^,t^[5]+6)); // ��
 t^[254]:=lo(Number);
 t^[255]:=hi(Number);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListCU(index:integer; t:PTTelegram);
begin
 Debug('F:mGetListCU');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=5;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$06; // ������ ��
 t^[9]:=lo(index);
 t^[10]:=hi(index);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mGetStateCU(typeCU: byte; sernumCU: word; t: PTTelegram); overload;
begin
 Debug('F:mGetStateCU');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=6;   //����� ��� ��
 t^[6]:=$85; //�������
 t^[7]:=$03; //�� ������
 t^[8]:=1;   // 1-������ ��������� ��������� ��
 t^[9]:=typeCU;
 t^[10]:=lo(sernumCU);
 t^[11]:=hi(sernumCU);
 t^[12]:=lo(kc(t^,t^[5]+6)); t^[13]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mGetStateCU(typeCU: byte; sernumCU: word); overload;
var
 t:^TTelegram;
begin
 Debug('F:mGetStateCU_Buffered');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=6;   //����� ��� ��
 t^[6]:=$85; //�������
 t^[7]:=$03; //�� ������
 t^[8]:=1;   // 1-������ ��������� ��������� ��
 t^[9]:=typeCU;
 t^[10]:=lo(sernumCU);
 t^[11]:=hi(sernumCU);
 t^[12]:=lo(kc(t^,t^[5]+6)); t^[13]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 t^[241]:= lo(5000);
 t^[242]:= hi(5000);
end;

procedure mGetStateMarkCU(Index: word; type_cmd: byte; t: PTTelegram);
begin
 Debug('F:mGetStateMarkCU');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=5;   //����� ��� ��
 t^[6]:=$85; //�������
 t^[7]:=$03; //�� ������
 t^[8]:=2;//������ ��������� ��������� ����. ��
 t^[9]:=lo(index);
 t^[10]:=hi(index);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mInCfgCUs;
var
 t:^TTelegram;
begin
 Debug('F:mInCfgCUs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$0C; // �� ���� � ����� ���������������� ���
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 //
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mOutCfgCUs;
var
 t:^TTelegram;
begin
 Debug('F:mOutCfgCUs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$03; // ��
 t^[8]:=$0D; // �� ����� �� ������ ���������������� ���
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 //
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mCreateZone (var m: array of byte; conf, status, name: byte; PartVista: word);
var
 t:^TTelegram;
begin
 Debug('F:mCreateZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$0c;  // ����� ��� ��
 t^[6]:=$84;  // �������
 t^[7]:=$01;  // ����
 t^[8]:=$01;  // ������� ����
 t^[9]:=conf; // ��� �����������
 t^[10]:=m[0];
 t^[11]:=m[1];
 t^[12]:=m[2];
 t^[13]:=m[3];
 t^[14]:=name;
 t^[15]:=status;
 t^[16]:=lo(kc(t^[9],7)); t^[17]:=hi(kc(t^[9],7)); // �� - ����
 t^[18]:=lo(kc(t^,t^[5]+6)); t^[19]:=hi(kc(t^,t^[5]+6)); // ��
 
 t^[254]:=lo(PartVista);
 t^[255]:=hi(PartVista);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mChangeZone (var m: array of byte; conf, status, name: byte; PartVista: word);
var
 t:^TTelegram;
begin
 Debug('F:mChangeZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$0c;  // ����� ��� ��
 t^[6]:=$84;  // �������
 t^[7]:=$01;  // ����
 t^[8]:=$02;  // �������� ����
 t^[9]:=conf; // ��� �����������
 t^[10]:=m[0];
 t^[11]:=m[1];
 t^[12]:=m[2];
 t^[13]:=m[3];
 t^[14]:=name;
 t^[15]:=status;
 t^[16]:=lo(kc(t^[9],7)); t^[17]:=hi(kc(t^[9],7)); // �� - ����
 t^[18]:=lo(kc(t^,t^[5]+6)); t^[19]:=hi(kc(t^,t^[5]+6)); // ��

 t^[254]:=lo(PartVista);
 t^[255]:=hi(PartVista);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteZone (var m: array of byte; PartVista: word);
var
 t:^TTelegram;
begin
 Debug('F:mDeleteZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$01; // ����
 t^[8]:=$04; // ������� ����
 t^[9]:=m[0];
 t^[10]:=m[1];
 t^[11]:=m[2];
 t^[12]:=m[3];
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 t^[254]:=lo(PartVista);
 t^[255]:=hi(PartVista);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteZones;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteZones');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$01; // ����
 t^[8]:=$05; // ������� ��� ����
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 //
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetZone (var m: array of byte; PartVista:word);
var
 t:^TTelegram;
begin
 Debug('F:mGetZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$01; // ����
 t^[8]:=$06; // ������ ����
 t^[9]:=m[0];
 t^[10]:=m[1];
 t^[11]:=m[2];
 t^[12]:=m[3];
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 t^[254]:=lo(PartVista);
 t^[255]:=hi(PartVista);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListZone(index: integer; t: PTTelegram);
begin
 Debug('F:mGetListZone');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=5; // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$01; // ����
 t^[8]:=$07; // ������ ������
 t^[9]:=lo(index);  // lo ������ ����
 t^[10]:=hi(index); // hi ������ ����
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mUpZone  (var name: array of byte; op: word; all_tc_ready: byte);
var
 t:^TTelegram;
begin
 Debug('F:mUpZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$0d; // ����� ��� ��
 t^[6]:=$8F; // �������
 t^[7]:=lo($0101);// �����
 t^[8]:=hi($0101);
 if op>0 then t^[9]:=11 else t^[9]:=10; //
 t^[10]:=lo(op);
 t^[11]:=hi(op);
 move(name, t^[12], 4);
 t^[16]:=1; // ��� ��
 t^[17]:=0; // ������ �� ��
 if all_tc_ready>0 then t^[18]:=1 else t^[18]:=0; // ��������� ��� ���������� ���������
 t^[19]:=lo(kc(t^,t^[5]+6)); t^[20]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDownZone  (var name: array of byte; op: word);
var
 t:^TTelegram;
begin
 Debug('F:mDownZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$0d; // ����� ��� ��
 t^[6]:=$8F; // �������
 t^[7]:=lo($0102);// �����
 t^[8]:=hi($0102);
 if op>0 then t^[9]:=11 else t^[9]:=10; //
 t^[10]:=lo(op);
 t^[11]:=hi(op);
 move(name, t^[12], 4);
 t^[16]:=1; // ��� ��
 t^[17]:=0; // ������ �� ��
 t^[18]:=0; // ��������� ��� ���������� ���������
 t^[19]:=lo(kc(t^,t^[5]+6)); t^[20]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mBypassZone (var name: array of byte; op: word; checkop: byte);
var
 t:^TTelegram;
begin
 Debug('F:mBypassZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$0d; // ����� ��� ��
 t^[6]:=$8F; // �������
 t^[7]:=lo($0104);// ������
 t^[8]:=hi($0104);
 if checkop>0 then t^[9]:=11 else t^[9]:=10; //
 t^[10]:=lo(op);
 t^[11]:=hi(op);
 move(name, t^[12], 4);
 t^[16]:=0; // ��� ��
 t^[17]:=0; // ������ �� ��
 t^[18]:=0; // ��������� ��� ���������� ���������
 t^[19]:=lo(kc(t^,t^[5]+6)); t^[20]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mRestoreZone (var name: array of byte; op: word; checkop: byte);
var
 t:^TTelegram;
begin
 Debug('F:mRestoreZone');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$0d; // ����� ��� ��
 t^[6]:=$8F; // �������
 t^[7]:=lo($0103);// ��������
 t^[8]:=hi($0103);
 if checkop>0 then t^[9]:=11 else t^[9]:=10; //
 t^[10]:=lo(op);
 t^[11]:=hi(op);
 move(name, t^[12], 4);
 t^[16]:=0; // ��� ��
 t^[17]:=0; // ������ �� ��
 t^[18]:=0; // ��������� ��� ���������� ���������
 t^[19]:=lo(kc(t^,t^[5]+6)); t^[20]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mCreateTC (
                     sernum: word;
                     typeTC: byte;
                     var BCPNumber: array of byte;
                     name: byte;
                     flags: byte;
                     var zone: array of byte;
                     group: byte;
                     type_hid: byte;
                     serial_hid: word;
                     hw_element: byte;
                     var config_union: array of byte;
                     restoreTime: byte;
                     ZoneVista: word;
                     PartVista: word);
var
 t: ^TTelegram;
begin
 Debug('F:mCreateTC');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=41;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$02; // ��
 t^[8]:=$01; // ������� ��
 t^[9]:=lo(rub.Addr);           // ���
 t^[10]:=hi(rub.Addr);          // ---//---
 t^[11]:=lo(sernum);            // �� ID
 t^[12]:=hi(sernum);            // ---//---
 t^[13]:=typeTC;                // ��� �� (1-7)
 t^[14]:=BCPNumber[0];          // ����� �� � �������
 t^[15]:=BCPNumber[1];          // ---//---
 t^[16]:=BCPNumber[2];          // ---//---
 t^[17]:=BCPNumber[3];          // ---//---
 t^[18]:=name;                  // ������ ������ ����� ��
 t^[19]:=flags;                 // flags
 t^[20]:=zone[0];               // ������������ ����
 t^[21]:=zone[1];               // ---//---
 t^[22]:=zone[2];               // ---//---
 t^[23]:=zone[3];               // ---//---
 t^[24]:=group;                 // ������
 t^[25]:=type_hid;              // ��� ������������
 t^[26]:=lo(serial_hid);        // 16-��� ����� ������������
 t^[27]:=hi(serial_hid);        // ---//---
 case type_hid of
   32:
   case typeTC of
     1..4:  t^[28]:= hw_element;
     5:  t^[28]:= hw_element + 6;
     6:  t^[28]:= hw_element + 9;
   end; //case typeTC
   else t^[28]:=hw_element;     // ������� ������������
 end; //case type_hid
 move(config_union, t^[29], 15);// config union
 t^[44]:=restoreTime;           // ����� ��������������

 t^[45]:=lo(kc(t^[9],36)); t^[46]:=hi(kc(t^[9],36)); // �� - ��
 t^[47]:=lo(kc(t^,t^[5]+6)); t^[48]:=hi(kc(t^,t^[5]+6)); // ��
 t^[252]:=lo(ZoneVista);
 t^[253]:=hi(ZoneVista);
 t^[254]:=lo(PartVista);
 t^[255]:=hi(PartVista);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mChangeTC (
                     sernum: word;
                     typeTC: byte;
                     var BCPNumber: array of byte;
                     name: byte;
                     flags: byte;
                     var zone: array of byte;
                     group: byte;
                     type_hid: byte;
                     serial_hid: word;
                     hw_element: byte;
                     var config_union: array of byte;
                     restoreTime: byte;
                     ZoneVista: word;
                     PartVista: word);
var
 t:^TTelegram;
begin
 Debug('F:mChangeTC');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=41;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$02; // ��
 t^[8]:=$02;// �������� ��
 t^[9]:=lo(rub.Addr);           // ���
 t^[10]:=hi(rub.Addr);          // ---//---
 t^[11]:=lo(sernum);            // �� ID
 t^[12]:=hi(sernum);            // ---//---
 t^[13]:=typeTC;                // ��� (1-��������, 2-���������, 3-�������� ������)
 t^[14]:=BCPNumber[0];          // ����� �� � �������
 t^[15]:=BCPNumber[1];          // ---//---
 t^[16]:=BCPNumber[2];          // ---//---
 t^[17]:=BCPNumber[3];          // ---//---
 t^[18]:=name;                  // ������ ������ ����� ��
 t^[19]:=flags;                 // flags
 t^[20]:=zone[0];               // ������������ ����
 t^[21]:=zone[1];               // ---//---
 t^[22]:=zone[2];               // ---//---
 t^[23]:=zone[3];               // ---//---
 t^[24]:=group;                 // ������
 t^[25]:=type_hid;              // ��� ������������
 t^[26]:=lo(serial_hid);        // 16-��� ����� ������������
 t^[27]:=hi(serial_hid);        // ---//---
 //
 case type_hid of
   32:
   case typeTC of
     1..4:  t^[28]:= hw_element;
     5:  t^[28]:= hw_element + 6;
     6:  t^[28]:= hw_element + 9;
   end; //case typeTC
   else t^[28]:=hw_element;     // ������� ������������
 end; //case type_hid
 //
 //t^[28]:=hw_element;            // ������� �������������
 move(config_union, t^[29], 15);//  config union
 t^[44]:=restoreTime;           // ����� ��������������
 t^[45]:=lo(kc(t^[9],36)); t^[46]:=hi(kc(t^[9],36)); // �� - ��
 t^[47]:=lo(kc(t^,t^[5]+6)); t^[48]:=hi(kc(t^,t^[5]+6)); // ��
 t^[252]:=lo(ZoneVista);
 t^[253]:=hi(ZoneVista);
 t^[254]:=lo(PartVista);
 t^[255]:=hi(PartVista);
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteTC (sernum: word);
var
 t:^TTelegram;
begin
 Debug('F:mDeleteTC');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=7;   // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$02; // ��
 t^[8]:=$03; // ������� ��
 t^[9]:= lo(rub.Addr);
 t^[10]:=hi(rub.Addr);
 t^[11]:=lo(sernum);
 t^[12]:=hi(sernum);
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetTC (sernum: word; var time, event, user: array of byte);
var
 t:^TTelegram;
begin
 Debug('F:mGetTC');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=7;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$02; // ��
 t^[8]:=$04; // ������ ��
 t^[9]:= lo(rub.Addr);
 t^[10]:=hi(rub.Addr);
 t^[11]:=lo(sernum);
 t^[12]:=hi(sernum);
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(user, t^[248], 2); 
 move(time, t^[250], 4);
 move(event, t^[254], 2);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mTCControl(Sernum, Operator, Command: word);
var
 t:^TTelegram;
begin
 Debug('F:mTCControl');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$0a;         // ����� ��� ��
 t^[6]:=$8e;         // ���������� ��
 t^[7]:=lo(command); // �������
 t^[8]:=hi(command); // �������
 if operator>0
   then t^[9]:=11
   else t^[9]:=10;
 t^[10]:=lo(operator);
 t^[11]:=hi(operator);
 t^[12]:=lo(rub.Addr);
 t^[13]:=hi(rub.Addr);
 t^[14]:=lo(sernum);
 t^[15]:=hi(sernum);
 t^[16]:=lo(kc(t^,t^[5]+6)); t^[17]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListTC(Index: integer; t: PTTelegram);
begin
 Debug('F:mGetListTC');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$05; //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$02; // ��
 t^[8]:=$06; // ������ ��
 t^[9]:=lo(index);
 t^[10]:=hi(index);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mGetStateTC(Sernum: word; type_cmd: byte; t: PTTelegram); overload;
begin
 Debug('F:mGetStateTC');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07; //����� ��� ��
 t^[6]:=$85; //�������
 t^[7]:=$02; //�� ������
 t^[8]:=type_cmd; // 1-������ ��������� ��������� ��;  3-������ ���� ��������� ��
 t^[9]:=lo(rub.Addr);
 t^[10]:=hi(rub.Addr);
 t^[11]:=lo(sernum);
 t^[12]:=hi(sernum);
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mGetStateTC(Sernum: word; type_cmd: byte); overload;
var
 t:^TTelegram;
begin
 Debug('F:mGetStateTC_Buffered');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07; //����� ��� ��
 t^[6]:=$85; //�������
 t^[7]:=$02; //�� ������
 t^[8]:=type_cmd; // 1-������ ��������� ��������� ��;  3-������ ���� ��������� ��
 t^[9]:=lo(rub.Addr);
 t^[10]:=hi(rub.Addr);
 t^[11]:=lo(sernum);
 t^[12]:=hi(sernum);
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 t^[241]:= lo(5000);
 t^[242]:= hi(5000);
end;

procedure mGetStateMarkTC(Index: word; type_cmd: byte; t: PTTelegram);
begin
 Debug('F:mGetStateMarkTC');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$05; //����� ��� ��
 t^[6]:=$85; //�������
 t^[7]:=$02; //�� ������
 t^[8]:=type_cmd; // 2-������ ��������� ��������� ����. ��;  4-������ ���� ��������� ����. ��
 t^[9]:=lo(index);
 t^[10]:=hi(index);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mCreateGR(Num, Name: byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$01;   // ������� ��
 t^[9]:= Num;
 t^[10]:= Name;
 t^[11]:=lo(kc(t^[9],2)); t^[12]:=hi(kc(t^[9],2)); // �� - grope
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mChangeGR(Num, Name: byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$02;   // �������� ��
 t^[9]:= Num;
 t^[10]:= Name;
 t^[11]:=lo(kc(t^[9],2)); t^[12]:=hi(kc(t^[9],2)); // �� - grope
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteGR(Num: byte);
var
 t:^TTelegram;
begin
 Debug('F:mDeleteGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$04;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$03;   // ������� ��
 t^[9]:= Num;
 t^[10]:=lo(kc(t^,t^[5]+6)); t^[11]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteGRs;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteGRs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$04;   // ������� ��� ��
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetGR(Num: byte);
var
 t:^TTelegram;
begin
 Debug('F:mGetGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$04;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$05;   // ������ ��
 t^[9]:= Num;
 t^[10]:=lo(kc(t^,t^[5]+6)); t^[11]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
  //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListGR(index: integer; t: PTTelegram);
begin
 Debug('F:mGetListGR');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$05;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$06;   // ������ ��
 t^[9]:=lo(index);
 t^[10]:=hi(index);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mCreateUser
          (
           flags: byte;
           id: word;
           ident_type: byte;
           var code: array of byte;
           pincode: longword;
           acces_level1: byte;
           rule_control: byte;
           var zone:array of byte;
           life_time: longword;
           time_zone: byte;
           acces_level2: byte;
           accessToArm: byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateUser');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=35;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$04; // ������������
 t^[8]:=$01; // ������� ������������
 t^[9]:=flags;
 t^[10]:=lo(id);
 t^[11]:=hi(id);
 t^[12]:=ident_type;
 t^[13]:=code[0];
 t^[14]:=code[1];
 t^[15]:=code[2];
 t^[16]:=code[3];
 t^[17]:=code[4];
 t^[18]:=code[5];
 t^[19]:=code[6];
 t^[20]:=code[7];
 t^[21]:=pincode and $FF;
 t^[22]:=(pincode shr 8 ) and $FF;
 t^[23]:=(pincode shr 16) and $FF;
 t^[24]:=(pincode shr 24) and $FF;
 t^[25]:=acces_level1;
 t^[26]:=rule_control;
 move(zone, t^[27], 4);
 t^[31]:=life_time and $FF;
 t^[32]:=(life_time shr 8 ) and $FF;
 t^[33]:=(life_time shr 16) and $FF;
 t^[34]:=(life_time shr 24) and $FF;
 t^[35]:=time_zone;
 t^[36]:=acces_level2;
 t^[37]:=accessToArm;
 t^[38]:=0;
 t^[39]:=lo(kc(t^[9],30)); t^[40]:=hi(kc(t^[9],30)); // �� - user
 t^[41]:=lo(kc(t^,t^[5]+6)); t^[42]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mChangeUser
          (
           flags: byte;
           id: word;
           ident_type: byte;
           var code: array of byte;
           pincode: longword;
           acces_level1: byte;
           rule_control: byte;
           var zone:array of byte;
           life_time: longword;
           time_zone: byte;
           acces_level2: byte;
           accessToArm: byte);
var
 t:^TTelegram;
begin
 Debug('F:mChangeUser');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=35;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$04; // ������������
 t^[8]:=$02; // �������� ������������
 t^[9]:=flags;
 t^[10]:=lo(id);
 t^[11]:=hi(id);
 t^[12]:=ident_type;
 t^[13]:=code[0];
 t^[14]:=code[1];
 t^[15]:=code[2];
 t^[16]:=code[3];
 t^[17]:=code[4];
 t^[18]:=code[5];
 t^[19]:=code[6];
 t^[20]:=code[7];
 t^[21]:=pincode and $FF;
 t^[22]:=(pincode shr 8 ) and $FF;
 t^[23]:=(pincode shr 16) and $FF;
 t^[24]:=(pincode shr 24) and $FF;
 t^[25]:=acces_level1;
 t^[26]:=rule_control;
 move(zone, t^[27], 4);
 t^[31]:=life_time and $FF;
 t^[32]:=(life_time shr 8 ) and $FF;
 t^[33]:=(life_time shr 16) and $FF;
 t^[34]:=(life_time shr 24) and $FF;
 t^[35]:=time_zone;
 t^[36]:=acces_level2;
 t^[37]:=accessToArm;
 t^[38]:=0;
 t^[39]:=lo(kc(t^[9],30)); t^[40]:=hi(kc(t^[9],30)); // �� - user
 t^[41]:=lo(kc(t^,t^[5]+6)); t^[42]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteUser (id:word);
var
 t:^TTelegram;
begin
 Debug('F:mDeleteUser');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=5;   // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$04; // ������������
 t^[8]:=$03; // ������� ������������
 t^[9]:=lo(id);
 t^[10]:=hi(id);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteUsers;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteUsers');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=3;   // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$04; // ������������
 t^[8]:=$04; //
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetUser (id: word);
var
 t:^TTelegram;
begin
 Debug('F:mGetUser');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=5;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$04; // ������������
 t^[8]:=$05; // ��������� ������������
 t^[9]:=lo(id);
 t^[10]:=hi(id);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListUser (index:integer; t:PTTelegram);
begin
 Debug('F:mGetListUser');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=5;   // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$04; // ������������
 t^[8]:=$06; // ������ �������������
 t^[9]:=lo(index);
 t^[10]:=hi(index);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mUserControl(User: word);
var
 t:^TTelegram;
begin
 Debug('F:mUserControl');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=05;          // ����� ��� ��
 t^[6]:=$92;         // ����������
 t^[7]:=$04;         // ���-user
 t^[8]:=$03;         // ����� ���� �����������
 t^[9]:=lo(User);    // user
 t^[10]:=hi(User);   // user
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mCreateChangeTimeInterval
            (
             Flags:byte;
             ParentTimeZone:byte;
             INumber:byte;
             BeginHour:byte;
             EndHour:byte;
             BeginMin:byte;
             EndMin:byte;
             DayMap:byte;
             type_cmd:byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateChangeTimeInterval');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=13;   //����� ��� ��
 t^[6]:=$84;  // �������
 t^[7]:=$0A;  // ��
 t^[8]:=type_cmd;
 t^[9]:=flags;
 t^[10]:=ParentTimeZone;
 t^[11]:=INumber;
 t^[12]:=BeginHour;
 t^[13]:=BeginMin;
 t^[14]:=EndHour;
 t^[15]:=EndMin;
 t^[16]:=DayMap;
 t^[17]:=lo(kc(t^[9],8)); t^[18]:=hi(kc(t^[9],8)); // �� - ��
 t^[19]:=lo(kc(t^,t^[5]+6)); t^[20]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteTimeInterval (id: byte);
var
 t:^TTelegram;
begin
 Debug('F:mDeleteTimeInterval');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=4;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0A; // ��
 t^[8]:=$05; // ������� ��
 t^[9]:=id;
 t^[10]:=lo(kc(t^,t^[5]+6)); t^[11]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeleteTimeIntervals;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteTimeIntervals');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=3;   // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0A; // ��
 t^[8]:=$06; // ������� ��� ��
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListTimeInterval (id:byte; index:word; t:PTTelegram);
begin
 Debug('F:mGetListTimeInterval');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=6;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0A; // ��
 t^[8]:=$07; // ��������� ��
 t^[9]:=id;  // ����� ��
 t^[10]:=lo(index);
 t^[11]:=hi(index);
 t^[12]:=lo(kc(t^,t^[5]+6)); t^[13]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mSetHoliday(var Dates: array of byte);
var
 t:^TTelegram;
begin
 Debug('F:mSetHoliday');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=39;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0C; // Holiday
 t^[8]:=$01; // ����������

 t^[9]:=$01; // ������
 move(Dates, t^[10], 32);
 t^[42]:=$00; // ������
 t^[43]:=lo(kc(t^[9],34)); t^[44]:=hi(kc(t^[9],34)); // �� ���

 t^[45]:=lo(kc(t^,t^[5]+6)); t^[46]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mCreateChangePravo
            (
             Flags: byte;
             AL: byte;
             var Zone: array of byte;
             ZoneStatus:byte;
             TCOType: byte;
             TCOGroup: byte;
             Map: longword;
             TimeZone: byte;
             type_cmd: byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateChangePravo');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=19;   //����� ��� ��
 t^[6]:=$84;  // �������
 t^[7]:=$0B;  // ��
 t^[8]:=type_cmd;
 t^[9]:=flags;
 t^[10]:=AL;
 t^[11]:=Zone[0];
 t^[12]:=Zone[1];
 t^[13]:=Zone[2];
 t^[14]:=Zone[3];
 t^[15]:=ZoneStatus;
 t^[16]:=TCOType;
 t^[17]:=TCOGroup;
 t^[18]:=Map and $FF;
 t^[19]:=(Map shr 8 ) and $FF;
 t^[20]:=(Map shr 16) and $FF;
 t^[21]:=(Map shr 24) and $FF;
 t^[22]:=TimeZone;
 t^[23]:=lo(kc(t^[9],8)); t^[24]:=hi(kc(t^[9],8)); // �� - �����
 t^[25]:=lo(kc(t^,t^[5]+6)); t^[26]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeletePravo (id:byte);
var
 t:^TTelegram;
begin
 Debug('F:mDeletePravo');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=4;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0B; // ��
 t^[8]:=$05; // ������� ��
 t^[9]:=id;
 t^[10]:=lo(kc(t^,t^[5]+6)); t^[11]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mDeletePrava;
var
 t:^TTelegram;
begin
 Debug('F:mDeletePrava');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:= 3;   //����� ��� ��
 t^[6]:= $84; //�������
 t^[7]:= $0B; //��
 t^[8]:= $06; //������� ��� ��
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListPravo (id:byte; index:word; t:PTTelegram);
begin
 Debug('F:mGetListPravo');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=6;   //����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0B; // ��
 t^[8]:=$07; // ��������� �����
 t^[9]:=id;  // ����� ��
 t^[10]:=lo(index);
 t^[11]:=hi(index);
 t^[12]:=lo(kc(t^,t^[5]+6)); t^[13]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mPreGetListPravo(id: byte);
var
 t:^TTelegram;
begin
 Debug('F:mPreGetListPravo');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:= $01;//��
 t^[1]:= $00;
 t^[2]:= id; // ����� ��
 rub.WBuf.Add(t);
 t^[241]:= lo(15000);
 t^[242]:= hi(15000);
end;

procedure mGetEvent(mPort:byte; index:integer; t:PTTelegram);
begin
 Debug('F:mGetEvent');
 t[0]:=$B6; t[1]:=$49; t[2]:=$01; t[3]:=lo(rub.Addr); t[4]:=hi(rub.Addr); // ���������
 t[5]:=3; // ����� ��� ��
 t[6]:=$8D; // �������
 t[7]:=lo(index); // ������
 t[8]:=hi(index); // ������
 t[9]:=lo(kc(t^,t^[5]+6)); t[10]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mBCPControl(Command: byte);
var
 t:^TTelegram;
begin
 Debug('F:mBCPControl');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=03;          // ����� ��� ��
 t^[6]:=$92;         // ����������
 t^[7]:=100;         // ���-���
 t^[8]:=Command;
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mSetVar(Addres: byte; Value: word; ValueType: byte);
var
 t:^TTelegram;
begin
 Debug('F:mBCPControl');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:= 07;          // ����� ��� ��
 t^[6]:= $92;         // ����������
 t^[7]:= 07;          // ���-����������
 t^[8]:= 01;          // �������
 t^[9]:= Addres;
 t^[10]:= lo(Value);
 t^[11]:= hi(Value);
 t^[12]:= ValueType;
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

{

//-----------------------------------------------------------------------------
procedure mCreateGR(Num, Name: byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$01;   // ������� ��
 t^[9]:= Num;
 t^[10]:= Name;
 t^[11]:=lo(kc(t^[9],2)); t^[12]:=hi(kc(t^[9],2)); // �� - grope
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mChangeGR(Num, Name: byte);
var
 t:^TTelegram;
begin
 Debug('F:mCreateGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$02;   // �������� ��
 t^[9]:= Num;
 t^[10]:= Name;
 t^[11]:=lo(kc(t^[9],2)); t^[12]:=hi(kc(t^[9],2)); // �� - grope
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mDeleteGR(Num: byte);
var
 t:^TTelegram;
begin
 Debug('F:mDeleteGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$04;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$03;   // ������� ��
 t^[9]:= Num;
 t^[10]:=lo(kc(t^,t^[5]+6)); t^[11]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mDeleteGRs;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteGRs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$04;   // ������� ��� ��
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mGetGR(Num: byte);
var
 t:^TTelegram;
begin
 Debug('F:mGetGR');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$04;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$09;   // ��
 t^[8]:=$05;   // ������ ��
 t^[9]:= Num;
 t^[10]:=lo(kc(t^,t^[5]+6)); t^[11]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
  //
 t^[255]:= Num;
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

}

procedure mGetListRN(index: byte; t: PTTelegram);
begin
 Debug('F:mGetListRN');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$04;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$0e;   // ��������
 t^[8]:=$06;   // ������
 t^[9]:=index;
 t^[10]:=lo(kc(t^,t^[5]+6)); t^[11]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mDeleteRNs;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteRNs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$0e;   // ��������
 t^[8]:=$04;   // ���
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;

procedure mGetListRP(index: word; t: PTTelegram);
begin
 Debug('F:mGetListRP');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$05;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$06;   // ���������
 t^[8]:=$06;   // ������
 t^[9]:=lo(index);
 t^[10]:=hi(index);
 t^[11]:=lo(kc(t^,t^[5]+6)); t^[12]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mDeleteRPs;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteRPs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$03;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$06;   // ���������
 t^[8]:=$04;   // ���
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mGetListRI(index: word; t: PTTelegram);
begin
 Debug('F:mGetListRI');
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=$07;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$0d;   // ����������
 t^[8]:=$02;   // ������
 t^[9]:= 0;    // RP
 t^[10]:= 0;   // RP
 t^[11]:=lo(index);
 t^[12]:=hi(index);
 t^[13]:=lo(kc(t^,t^[5]+6)); t^[14]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mGetListHD(t: PTTelegram);
begin
 Debug('F:mGetListHD');
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=03;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0C; // Holiday
 t^[8]:=$02; // ������
 t^[9]:=lo(kc(t^,t^[5]+6)); t^[10]:=hi(kc(t^,t^[5]+6)); // ��
end;

procedure mDeleteHDs;
var
 t:^TTelegram;
begin
 Debug('F:mDeleteHDs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=39;   // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$0C;   // Holiday
 t^[8]:=$01;   // ���������
 FillChar(t^[9], sizeof(THOLIDAY),0);
 t^[43]:=lo(kc(t^[9], 34)); t^[44]:=hi(kc(t^[9], 34)); // ��
 t^[45]:=lo(kc(t^,t^[5]+6)); t^[46]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mCreateHDs(
                Flag: byte;
                Data: array of word;
                Res: byte
                );
var
 t:^TTelegram;
begin
 Debug('F:mCreateHDs');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=39;    // ����� ��� ��
 t^[6]:=$84;   // �������
 t^[7]:=$0C;   // Holiday
 t^[8]:=$01;   // ���������
 //
 t^[9]:=Flag;
 move(Data, t^[10], 32);
 t^[42]:=Res;
 t^[43]:=lo(kc(t^[9], 34)); t^[44]:=hi(kc(t^[9], 34)); // ��
 t^[45]:=lo(kc(t^,t^[5]+6)); t^[46]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mCreateRN(Num: byte; Data: array of byte);
var
 t:^TTelegram;
begin
 Debug('F:CreateRN');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=22;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0e; // ��������
 t^[8]:=$01; // �������
 t^[9]:= Num;
 move(Data, t^[10], 16);
 t^[26]:=lo(kc(t^[10], 16)); t^[27]:=hi(kc(t^[10], 16)); // �� ���
 t^[28]:=lo(kc(t^,t^[5]+6)); t^[29]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mCreateRP
                (
                Flags: byte;
                Num: word;
                Name: word;
                Manual: byte
                );
var
 t:^TTelegram;
begin
 Debug('F:mCreateRP');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=11;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$06; // ���������
 t^[8]:=$01; // �������
 //
 t^[9]:= Flags;
 t^[10]:= lo(Num);
 t^[11]:= hi(Num);
 t^[12]:= lo(Name);
 t^[13]:= hi(Name);
 t^[14]:= Manual;
 t^[15]:=lo(kc(t^[9], 6)); t^[16]:=hi(kc(t^[9], 6)); // �� ���
 t^[17]:=lo(kc(t^,t^[5]+6)); t^[18]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;


procedure mCreateRI
                (
                Flags: byte;
                Obj: byte;
                Cmd: word;
                RSData: array of byte;
                PNum: word;
                INum: word
                );
var
 t:^TTelegram;
begin
 Debug('F:mCreateRI');
 new(t);
 FillChar(t^, sizeof(TTelegram), 0);
 t^[0]:=$B6; t^[1]:=$49; t^[2]:=$01; t^[3]:=lo(rub.Addr); t^[4]:=hi(rub.Addr); // ���������
 t^[5]:=19;  // ����� ��� ��
 t^[6]:=$84; // �������
 t^[7]:=$0d; // ����������
 t^[8]:=$01; // �������
 //
 t^[9]:= Flags;
 t^[10]:= Obj;
 t^[11]:= lo(Cmd);
 t^[12]:= hi(Cmd);
 move(RSData, t^[13], 6);
 t^[19]:= lo(PNum);
 t^[20]:= hi(PNum);
 t^[21]:= lo(INum);
 t^[22]:= hi(INum);
 t^[23]:=lo(kc(t^[9], 14)); t^[24]:=hi(kc(t^[9], 14)); // ��
 t^[25]:=lo(kc(t^,t^[5]+6)); t^[26]:=hi(kc(t^,t^[5]+6)); // ��
 rub.WBuf.Add(t);
 move(GlobalTempMes, t^[256], sizeof(KSBMES));
end;






initialization

END.

