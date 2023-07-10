unit mMainControl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CMAINKSB, StdCtrls, Grids, Mask, ExtCtrls, Spin, ComCtrls, SharedBuffer,
  connection, constants, rxToolEdit, ToolWin, ImgList, Buttons, CheckLst,
  DBCtrls, DB, RxMemDS, dbcgrids, DBGrids, Menus;

type
  TmMain = class(TaMainKsb)
   PageControl1: TPageControl;
   TabSheet4: TTabSheet;
   TabSheet1: TTabSheet;
   TabSheet3: TTabSheet;
   TabSheet7: TTabSheet;
   TabSheet8: TTabSheet;
    GroupBox4: TGroupBox;
    ComboBox3: TComboBox;
    Label2: TLabel;
    Label1: TLabel;
    SpinEdit7: TSpinEdit;
    SpinEdit3: TSpinEdit;
    Label7: TLabel;
    Label8: TLabel;
    CheckBox2: TCheckBox;
    TabSheet6: TTabSheet;
    GroupBox6: TGroupBox;
    Label42: TLabel;
    SpinEdit30: TSpinEdit;
    Label43: TLabel;
    SpinEdit31: TSpinEdit;
    Label44: TLabel;
    SpinEdit32: TSpinEdit;
    Label45: TLabel;
    SpinEdit33: TSpinEdit;
    SpinEdit34: TSpinEdit;
    Label46: TLabel;
    SpinEdit35: TSpinEdit;
    Label47: TLabel;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    Label48: TLabel;
    MaskEdit1: TMaskEdit;
    TabSheet9: TTabSheet;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    ToolBar2: TToolBar;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    GroupBox14: TGroupBox;
    Label64: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    Label67: TLabel;
    MaskEdit_SCU_USK: TMaskEdit;
    CheckBox25: TCheckBox;
    CheckBox26: TCheckBox;
    ComboBox9: TComboBox;
    ComboBox10: TComboBox;
    SpinEdit41: TSpinEdit;
    CheckBox27: TCheckBox;
    Label68: TLabel;
    Panel1: TPanel;
    ToolBar3: TToolBar;
    ToolButton14: TToolButton;
    ToolButton23: TToolButton;
    ToolButton27: TToolButton;
    GroupBox15: TGroupBox;
    Label69: TLabel;
    Label70: TLabel;
    Label71: TLabel;
    Label72: TLabel;
    MaskEdit_SCU_AP: TMaskEdit;
    CheckBox22: TCheckBox;
    CheckBox23: TCheckBox;
    ComboBox11: TComboBox;
    ComboBox12: TComboBox;
    SpinEdit42: TSpinEdit;
    CheckBox24: TCheckBox;
    CheckBox28: TCheckBox;
    Panel2: TPanel;
    CheckListBox1: TCheckListBox;
    SpinEdit_SCU_USK: TSpinEdit;
    ToolButton5: TToolButton;
    SpinEdit_SCU_AP: TSpinEdit;
    Label78: TLabel;
    SpinEdit48: TSpinEdit;
    Label79: TLabel;
    SpinEdit49: TSpinEdit;
    CheckBox12: TCheckBox;
    Label83: TLabel;
    ComboBox18: TComboBox;
    ToolBar4: TToolBar;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton11: TToolButton;
    ToolBar5: TToolBar;
    SpinEdit_ZONE: TSpinEdit;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton25: TToolButton;
    GroupBox17: TGroupBox;
    Label84: TLabel;
    Edit_ZONE_NAME: TEdit;
    ToolButton26: TToolButton;
    ToolButton28: TToolButton;
    ToolButton30: TToolButton;
    RadioGroup6: TRadioGroup;
    Label4: TLabel;
    SpinEdit1: TSpinEdit;
    GroupBox18: TGroupBox;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    SpinEdit2: TSpinEdit;
    CheckBox1: TCheckBox;
    CheckBox4: TCheckBox;
    PageControl_TC: TPageControl;
    TabSheet16: TTabSheet;
    TabSheet17: TTabSheet;
    TabSheet18: TTabSheet;
    GroupBox11: TGroupBox;
    Label3: TLabel;
    Label59: TLabel;
    Label9: TLabel;
    Label60: TLabel;
    MaskEdit_BCP_AP: TMaskEdit;
    RadioGroup1: TRadioGroup;
    RadioGroup3: TRadioGroup;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    ComboBox7: TComboBox;
    ComboBox8: TComboBox;
    CheckBox19: TCheckBox;
    Edit5: TEdit;
    Panel4: TPanel;
    GroupBox12: TGroupBox;
    Label51: TLabel;
    Edit_TC_NAME: TEdit;
    RadioGroup_TC_VIEW: TRadioGroup;
    GroupBox8: TGroupBox;
    Label52: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    ComboBox_TC_TYPE: TComboBox;
    SpinEdit_TC_NUMBER: TSpinEdit;
    SpinEdit_TC_ELEMENT: TSpinEdit;
    CheckBox_ON: TCheckBox;
    CheckBox_TAMPER: TCheckBox;
    SpinEdit44: TSpinEdit;
    SpinEdit45: TSpinEdit;
    ToolBar1: TToolBar;
    ToolButton31: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    SpinEdit_TC: TSpinEdit;
    ToolBar7: TToolBar;
    ToolButton41: TToolButton;
    ToolButton42: TToolButton;
    ToolButton43: TToolButton;
    ToolBar6: TToolBar;
    ToolButton35: TToolButton;
    ToolButton36: TToolButton;
    ToolButton37: TToolButton;
    ToolButton32: TToolButton;
    ToolButton33: TToolButton;
    ToolBar8: TToolBar;
    GroupBox9: TGroupBox;
    Label56: TLabel;
    SpinEdit_USER_CONTROL: TSpinEdit;
    CheckBox1_USER_CONTROL: TCheckBox;
    ToolButton40: TToolButton;
    ToolBar9: TToolBar;
    SpinEdit_SCU_RELAY: TSpinEdit;
    ToolButton44: TToolButton;
    ToolButton47: TToolButton;
    ToolButton48: TToolButton;
    ToolBar10: TToolBar;
    SpinEdit_SCU_USER: TSpinEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    Label12: TLabel;
    MaskEdit_SCU_RELAY: TMaskEdit;
    ComboBox2: TComboBox;
    CheckBox7: TCheckBox;
    Label15: TLabel;
    Label16: TLabel;
    GroupBox5: TGroupBox;
    Label17: TLabel;
    SpinEdit11: TSpinEdit;
    Label19: TLabel;
    SpinEdit18: TSpinEdit;
    SpinEdit6: TSpinEdit;
    Label10: TLabel;
    SpinEdit8: TSpinEdit;
    Label14: TLabel;
    Timer1: TTimer;
    SpinEdit_SU: TSpinEdit;
    GroupBox7: TGroupBox;
    Label27: TLabel;
    Label32: TLabel;
    ComboBox4: TComboBox;
    GroupBox16: TGroupBox;
    Label73: TLabel;
    Label80: TLabel;
    Label76: TLabel;
    Label77: TLabel;
    Label81: TLabel;
    Label82: TLabel;
    SpinEdit52: TSpinEdit;
    SpinEdit51: TSpinEdit;
    SpinEdit50: TSpinEdit;
    ComboBox13: TComboBox;
    ComboBox14: TComboBox;
    ComboBox15: TComboBox;
    ComboBox16: TComboBox;
    ComboBox17: TComboBox;
    Label37: TLabel;
    SpinEdit22: TSpinEdit;
    Label39: TLabel;
    SpinEdit23: TSpinEdit;
    Label40: TLabel;
    SpinEdit24: TSpinEdit;
    CheckBox21: TCheckBox;
    CheckBox29: TCheckBox;
    ToolButton54: TToolButton;
    ToolButton55: TToolButton;
    ToolButton56: TToolButton;
    ToolButton49: TToolButton;
    ToolButton51: TToolButton;
    ToolButton52: TToolButton;
    CheckListBox2: TCheckListBox;
    CheckListBox3: TCheckListBox;
    Label49: TLabel;
    Label50: TLabel;
    SpinEdit25: TSpinEdit;
    Label33: TLabel;
    Label29: TLabel;
    CheckListBox4: TCheckListBox;
    Label34: TLabel;
    CheckListBox5: TCheckListBox;
    Label35: TLabel;
    Label36: TLabel;
    SpinEdit5: TSpinEdit;
    MaskEdit_SCU_USER: TMaskEdit;
    Label13: TLabel;
    SpinEdit21: TSpinEdit;
    Label57: TLabel;
    Label85: TLabel;
    Label86: TLabel;
    ToolButton50: TToolButton;
    ToolButton53: TToolButton;
    Edit1: TEdit;
    Label74: TLabel;
    ComboBox5: TComboBox;
    CheckBox3: TCheckBox;
    CheckBox5: TCheckBox;
    TabSheet2: TTabSheet;
    ToolBar11: TToolBar;
    ToolButton60: TToolButton;
    ToolButton61: TToolButton;
    GroupBox19: TGroupBox;
    GroupBox22: TGroupBox;
    GroupBox20: TGroupBox;
    GroupBox21: TGroupBox;
    Label98: TLabel;
    Label99: TLabel;
    Label105: TLabel;
    Label108: TLabel;
    Label106: TLabel;
    SpinEdit28: TSpinEdit;
    SpinEdit36: TSpinEdit;
    SpinEdit39: TSpinEdit;
    SpinEdit38: TSpinEdit;
    ComboBox26: TComboBox;
    Label91: TLabel;
    MaskEdit_SCU_HW: TMaskEdit;
    CheckBox20: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox33: TCheckBox;
    TabSheet5: TTabSheet;
    ToolBar12: TToolBar;
    SpinEdit_SCU_SH: TSpinEdit;
    ToolButton4: TToolButton;
    ToolButton6: TToolButton;
    ToolButton10: TToolButton;
    GroupBox25: TGroupBox;
    SpinEdit43: TSpinEdit;
    Edit_ZN_NAME: TEdit;
    GroupBox26: TGroupBox;
    Label21: TLabel;
    MaskEdit_BCP_USER: TMaskEdit;
    ToolBar14: TToolBar;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton24: TToolButton;
    ToolButton29: TToolButton;
    ToolButton45: TToolButton;
    Label61: TLabel;
    Edit9: TEdit;
    Label20: TLabel;
    DateEdit1: TDateEdit;
    GroupBox27: TGroupBox;
    Label11: TLabel;
    ComboBox1: TComboBox;
    SpinEdit9: TSpinEdit;
    Label18: TLabel;
    Label31: TLabel;
    SpinEdit19: TSpinEdit;
    GroupBox28: TGroupBox;
    Label24: TLabel;
    Label23: TLabel;
    Label28: TLabel;
    SpinEdit13: TSpinEdit;
    SpinEdit12: TSpinEdit;
    CheckBox6: TCheckBox;
    GroupBox29: TGroupBox;
    Label102: TLabel;
    SpinEdit20: TSpinEdit;
    Label25: TLabel;
    SpinEdit14: TSpinEdit;
    Label30: TLabel;
    SpinEdit15: TSpinEdit;
    ComboBox22: TComboBox;
    ComboBox23: TComboBox;
    Label22: TLabel;
    Label26: TLabel;
    Label103: TLabel;
    SpinEdit_BCP_USER: TSpinEdit;
    ToolButton59: TToolButton;
    ToolButton62: TToolButton;
    ToolButton63: TToolButton;
    SpinEdit4: TSpinEdit;
    ToolButton46: TToolButton;
    ToolButton58: TToolButton;
    ToolButton64: TToolButton;
    ToolButton65: TToolButton;
    ToolButton66: TToolButton;
    ToolButton67: TToolButton;
    SpinEdit_SCU_HW: TSpinEdit;
    ToolButton15: TToolButton;
    ToolButton70: TToolButton;
    ToolButton71: TToolButton;
    ToolButton72: TToolButton;
    ToolButton57: TToolButton;
    ToolBar15: TToolBar;
    SpinEdit_BCP_TZ: TSpinEdit;
    ToolButton73: TToolButton;
    ToolButton74: TToolButton;
    ToolButton75: TToolButton;
    ToolButton76: TToolButton;
    ToolButton77: TToolButton;
    ToolBar16: TToolBar;
    SpinEdit_BCP_UD: TSpinEdit;
    ToolButton78: TToolButton;
    ToolButton79: TToolButton;
    ToolButton80: TToolButton;
    ToolButton81: TToolButton;
    ToolButton82: TToolButton;
    ToolButton83: TToolButton;
    TIdata: TRxMemoryData;
    TISource: TDataSource;
    TIdataBeginHour: TSmallintField;
    TIdataEndHour: TSmallintField;
    TIdataBeginMin: TSmallintField;
    TIdataEndMin: TSmallintField;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    GroupBox13: TGroupBox;
    DBCheckBox1: TDBCheckBox;
    DBCheckBox2: TDBCheckBox;
    DBCheckBox3: TDBCheckBox;
    DBCheckBox4: TDBCheckBox;
    DBCheckBox5: TDBCheckBox;
    DBCheckBox6: TDBCheckBox;
    DBCheckBox7: TDBCheckBox;
    TIdataField1: TBooleanField;
    TIdataField2: TBooleanField;
    TIdataField3: TBooleanField;
    TIdataField4: TBooleanField;
    TIdataField5: TBooleanField;
    TIdataField6: TBooleanField;
    TIdataField7: TBooleanField;
    TIdataTZ: TIntegerField;
    TIdataField8: TBooleanField;
    ToolButton85: TToolButton;
    NOP: TTabSheet;
    TabSheet20: TTabSheet;
    TabSheet21: TTabSheet;
    TabSheet22: TTabSheet;
    GroupBox32: TGroupBox;
    Label38: TLabel;
    Label95: TLabel;
    MaskEdit4: TMaskEdit;
    CheckBox35: TCheckBox;
    CheckBox38: TCheckBox;
    CheckBox39: TCheckBox;
    CheckBox41: TCheckBox;
    CheckBox42: TCheckBox;
    ComboBox24: TComboBox;
    CheckBox43: TCheckBox;
    GroupBox33: TGroupBox;
    Label41: TLabel;
    SpinEdit26: TSpinEdit;
    Label100: TLabel;
    SpinEdit27: TSpinEdit;
    Label101: TLabel;
    SpinEdit29: TSpinEdit;
    Label104: TLabel;
    SpinEdit37: TSpinEdit;
    Label107: TLabel;
    SpinEdit40: TSpinEdit;
    Label109: TLabel;
    SpinEdit46: TSpinEdit;
    ToolButton84: TToolButton;
    ToolButton86: TToolButton;
    TabSheet19: TTabSheet;
    ToolBar17: TToolBar;
    SpinEdit_GROUP: TSpinEdit;
    ToolButton87: TToolButton;
    ToolButton88: TToolButton;
    ToolButton89: TToolButton;
    ToolButton90: TToolButton;
    ToolButton91: TToolButton;
    ToolButton92: TToolButton;
    ToolButton93: TToolButton;
    ToolButton94: TToolButton;
    ToolButton95: TToolButton;
    GroupBox34: TGroupBox;
    Label110: TLabel;
    SpinEdit57: TSpinEdit;
    ToolBar18: TToolBar;
    ToolButton96: TToolButton;
    ToolButton97: TToolButton;
    ToolButton98: TToolButton;
    ToolButton99: TToolButton;
    ToolButton100: TToolButton;
    ToolButton101: TToolButton;
    GroupBox10: TGroupBox;
    Label55: TLabel;
    Label58: TLabel;
    SpinEdit16: TSpinEdit;
    SpinEdit17: TSpinEdit;
    ToolButton102: TToolButton;
    ToolButton103: TToolButton;
    TabSheet10: TTabSheet;
    ToolBar19: TToolBar;
    ToolButton104: TToolButton;
    ToolButton107: TToolButton;
    ToolButton108: TToolButton;
    ToolButton109: TToolButton;
    ToolButton105: TToolButton;
    ToolButton106: TToolButton;
    ToolButton110: TToolButton;
    ToolButton111: TToolButton;
    ToolButton112: TToolButton;
    ToolButton113: TToolButton;
    ToolBar20: TToolBar;
    ToolButton114: TToolButton;
    ToolButton115: TToolButton;
    ToolButton116: TToolButton;
    ToolButton117: TToolButton;
    ToolButton118: TToolButton;
    ToolButton119: TToolButton;
    ToolBar21: TToolBar;
    ToolButton120: TToolButton;
    ToolButton121: TToolButton;
    ToolButton123: TToolButton;
    ToolButton124: TToolButton;
    ToolButton125: TToolButton;
    ToolBar22: TToolBar;
    ToolButton126: TToolButton;
    ToolButton129: TToolButton;
    ToolButton130: TToolButton;
    ToolButton131: TToolButton;
    ToolButton127: TToolButton;
    ToolButton128: TToolButton;
    ToolButton132: TToolButton;
    ToolButton122: TToolButton;
    ToolButton34: TToolButton;
    ToolButton38: TToolButton;
    ToolButton39: TToolButton;
    Label111: TLabel;
    SpinEdit56: TSpinEdit;
    Label112: TLabel;
    SpinEdit58: TSpinEdit;
    GroupBox3: TGroupBox;
    Label113: TLabel;
    Label115: TLabel;
    Label116: TLabel;
    MaskEdit5: TMaskEdit;
    CheckBox45: TCheckBox;
    SpinEdit61: TSpinEdit;
    SpinEdit62: TSpinEdit;
    SCU_SHPage: TPageControl;
    TabSheet23: TTabSheet;
    TabSheet24: TTabSheet;
    ToolBar13: TToolBar;
    ToolButton68: TToolButton;
    ToolButton69: TToolButton;
    ToolButton133: TToolButton;
    ToolButton135: TToolButton;
    GroupBox35: TGroupBox;
    Label114: TLabel;
    Label118: TLabel;
    Label120: TLabel;
    CheckBox40: TCheckBox;
    CheckBox44: TCheckBox;
    CheckBox46: TCheckBox;
    CheckBox47: TCheckBox;
    CheckBox48: TCheckBox;
    CheckBox49: TCheckBox;
    GroupBox36: TGroupBox;
    Label122: TLabel;
    Label123: TLabel;
    SpinEdit59: TSpinEdit;
    SpinEdit60: TSpinEdit;
    SpinEdit63: TSpinEdit;
    TabSheet25: TTabSheet;
    ToolBar23: TToolBar;
    ToolButton139: TToolButton;
    ToolButton140: TToolButton;
    GroupBox37: TGroupBox;
    Label124: TLabel;
    Label125: TLabel;
    Label126: TLabel;
    MaskEdit7: TMaskEdit;
    CheckBox50: TCheckBox;
    SpinEdit67: TSpinEdit;
    SpinEdit68: TSpinEdit;
    TabSheet26: TTabSheet;
    ToolBar24: TToolBar;
    ToolButton145: TToolButton;
    ToolButton146: TToolButton;
    TabSheet27: TTabSheet;
    ToolBar25: TToolBar;
    ToolButton150: TToolButton;
    CheckBox51: TCheckBox;
    CheckBox52: TCheckBox;
    CheckBox53: TCheckBox;
    CheckBox54: TCheckBox;
    MaskEdit_SCU_SH: TMaskEdit;
    CheckBox36: TCheckBox;
    CheckBox55: TCheckBox;
    CheckBox56: TCheckBox;
    CheckBox57: TCheckBox;
    CheckBox58: TCheckBox;
    CheckBox59: TCheckBox;
    Label75: TLabel;
    SpinEdit47: TSpinEdit;
    ToolButton134: TToolButton;
    ToolButton137: TToolButton;
    ToolButton136: TToolButton;
    ToolButton138: TToolButton;
    TabSheet15: TTabSheet;
    Panel3: TPanel;
    RadioGroup_ADDR: TRadioGroup;
    ToolButton141: TToolButton;
    ToolButton142: TToolButton;
    ToolButton143: TToolButton;
    TabSheet28: TTabSheet;
    Memo1: TMemo;
    Splitter1: TSplitter;
    Panel5: TPanel;
    CheckBox30: TCheckBox;
    GroupBox23: TGroupBox;
    Label87: TLabel;
    Label88: TLabel;
    Label89: TLabel;
    Label90: TLabel;
    Label93: TLabel;
    Label94: TLabel;
    SpinEdit_SysDevice: TSpinEdit;
    SpinEdit_TypeDevice: TSpinEdit;
    SpinEdit_NetDevice: TSpinEdit;
    SpinEdit_BigDevice: TSpinEdit;
    SpinEdit_SmallDevice: TSpinEdit;
    Memo_Code: TMemo;
    PopupMenu1: TPopupMenu;
    N2: TMenuItem;
    DBGrid2: TDBGrid;
    UDdata: TRxMemoryData;
    UDSource: TDataSource;
    UDdataZnStatus: TWordField;
    UDdataTCtype: TWordField;
    UDdataGrTC: TWordField;
    UDdataTimeZn: TWordField;
    UDdataMapHi: TWordField;
    UDdataMapLo: TWordField;
    UDdataZn: TWordField;
    DBNavigator2: TDBNavigator;
    ToolButton144: TToolButton;
    UDdataPermission: TWordField;
    Edit2: TEdit;
    SpinEdit_VAR: TSpinEdit;
    ToolButton147: TToolButton;
    ToolButton148: TToolButton;
    ToolButton149: TToolButton;
    SpinEdit_VARVALUE: TSpinEdit;
    ComboBox6: TComboBox;
    Label92: TLabel;
    ComboBox19: TComboBox;
    Label96: TLabel;
    ToolButton151: TToolButton;
    CheckBox31: TCheckBox;
    ToolButton154: TToolButton;
    SpinEdit10: TSpinEdit;
    TabSheet29: TTabSheet;
    TabSheet30: TTabSheet;
    TabSheet31: TTabSheet;
    ToolBar26: TToolBar;
    ToolButton152: TToolButton;
    GroupBox24: TGroupBox;
    Label97: TLabel;
    SpinEdit53: TSpinEdit;
    ToolButton153: TToolButton;
    ToolButton155: TToolButton;
    DBCheckBox8: TDBCheckBox;
    DateSource: TDataSource;
    DateData: TRxMemoryData;
    DateDataDay: TSmallintField;
    DateDataMonth: TSmallintField;
    GroupBox30: TGroupBox;
    ToolButton162: TToolButton;
    ToolButton163: TToolButton;
    Panel7: TPanel;
    DBGrid3: TDBGrid;
    Panel8: TPanel;
    Panel6: TPanel;

    procedure ComboBox3Change(Sender: TObject);
    procedure MaskEdit1KeyPress(Sender: TObject; var Key: Char);
    procedure SpinEdit16Change(Sender: TObject);
    procedure SpinEdit17Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure SpinEdit_TCChange(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure ToolButton21Click(Sender: TObject);
    procedure ToolButton22Click(Sender: TObject);
    procedure ToolButton25Click(Sender: TObject);
    procedure ToolButton26Click(Sender: TObject);
    procedure ToolButton28Click(Sender: TObject);
    procedure SpinEdit_ZONEChange(Sender: TObject);
    procedure SpinEdit_SUChange(Sender: TObject);
    procedure ToolButton36Click(Sender: TObject);
    procedure ToolButton37Click(Sender: TObject);
    procedure ToolButton41Click(Sender: TObject);
    procedure ToolButton42Click(Sender: TObject);
    procedure ToolButton32Click(Sender: TObject);
    procedure ToolButton33Click(Sender: TObject);
    procedure ToolButton40Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ToolButton47Click(Sender: TObject);
    procedure ToolButton23Click(Sender: TObject);
    procedure ToolButton54Click(Sender: TObject);
    procedure ToolButton55Click(Sender: TObject);
    procedure ToolButton56Click(Sender: TObject);
    procedure ToolButton51Click(Sender: TObject);
    procedure ToolButton49Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure ToolButton48Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure ToolButton50Click(Sender: TObject);
    procedure ToolButton53Click(Sender: TObject);
    procedure ToolButton60Click(Sender: TObject);
    procedure ToolButton61Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure SpinEdit43Change(Sender: TObject);
    procedure ToolButton16Click(Sender: TObject);
    procedure ToolButton17Click(Sender: TObject);
    procedure ToolButton18Click(Sender: TObject);
    procedure ToolButton62Click(Sender: TObject);
    procedure ToolButton45Click(Sender: TObject);
    procedure ToolButton59Click(Sender: TObject);
    procedure ToolButton46Click(Sender: TObject);
    procedure ToolButton64Click(Sender: TObject);
    procedure ToolButton65Click(Sender: TObject);
    procedure ToolButton66Click(Sender: TObject);
    procedure ToolButton67Click(Sender: TObject);
    procedure ToolButton34Click(Sender: TObject);
    procedure ToolButton70Click(Sender: TObject);
    procedure ToolButton71Click(Sender: TObject);
    procedure ToolButton73Click(Sender: TObject);
    procedure ToolButton74Click(Sender: TObject);
    procedure ToolButton75Click(Sender: TObject);
    procedure ToolButton77Click(Sender: TObject);
    procedure ToolButton78Click(Sender: TObject);
    procedure ToolButton79Click(Sender: TObject);
    procedure ToolButton80Click(Sender: TObject);
    procedure ToolButton82Click(Sender: TObject);
    procedure ToolButton35Click(Sender: TObject);
    procedure SpinEdit_BCP_TZChange(Sender: TObject);
    procedure TIdataAfterInsert(DataSet: TDataSet);
    procedure TIdataBeforePost(DataSet: TDataSet);
    procedure ToolButton84Click(Sender: TObject);
    procedure ToolButton88Click(Sender: TObject);
    procedure ToolButton89Click(Sender: TObject);
    procedure ToolButton90Click(Sender: TObject);
    procedure ToolButton92Click(Sender: TObject);
    procedure ToolButton94Click(Sender: TObject);
    procedure ToolButton95Click(Sender: TObject);
    procedure ToolButton97Click(Sender: TObject);
    procedure ToolButton98Click(Sender: TObject);
    procedure ToolButton99Click(Sender: TObject);
    procedure ToolButton102Click(Sender: TObject);
    procedure ToolButton103Click(Sender: TObject);
    procedure ToolButton104Click(Sender: TObject);
    procedure ToolButton108Click(Sender: TObject);
    procedure ToolButton109Click(Sender: TObject);
    procedure ToolButton105Click(Sender: TObject);
    procedure ToolButton106Click(Sender: TObject);
    procedure ToolButton111Click(Sender: TObject);
    procedure ToolButton112Click(Sender: TObject);
    procedure ToolButton127Click(Sender: TObject);
    procedure ToolButton115Click(Sender: TObject);
    procedure ToolButton116Click(Sender: TObject);
    procedure ToolButton128Click(Sender: TObject);
    procedure ToolButton132Click(Sender: TObject);
    procedure ToolButton39Click(Sender: TObject);
    procedure ToolButton38Click(Sender: TObject);
    procedure ToolButton68Click(Sender: TObject);
    procedure ToolButton69Click(Sender: TObject);
    procedure ToolButton133Click(Sender: TObject);
    procedure ToolButton135Click(Sender: TObject);
    procedure ToolButton140Click(Sender: TObject);
    procedure ToolButton146Click(Sender: TObject);
    procedure ToolButton137Click(Sender: TObject);
    procedure ToolButton136Click(Sender: TObject);
    procedure ToolButton138Click(Sender: TObject);
    procedure ToolButton141Click(Sender: TObject);
    procedure ToolButton142Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure UDdataAfterInsert(DataSet: TDataSet);
    procedure ToolButton148Click(Sender: TObject);
    procedure ToolButton43Click(Sender: TObject);
    procedure ToolButton153Click(Sender: TObject);
    procedure ToolButton163Click(Sender: TObject);

 private
  procedure WriteLog(str: string);
  procedure Log(str: string);
  procedure RefreshParamStrings;

  procedure SetBCP_CUParams(var m: array of byte);
  procedure GetBCP_CUParams(var m: array of byte);

  procedure SetBCP_SH1Params(var m: array of byte);
  procedure GetBCP_SH1Params(var m: array of byte);

  procedure SetBCP_SH2Params(var m: array of byte);
  procedure GetBCP_SH2Params(var m: array of byte);

  procedure SetBCP_APParams(var m: array of byte);
  procedure GetBCP_APParams(var m: array of byte);

  procedure SetBCP_TermParams(var m: array of byte);
  procedure GetBCP_TermParams(var m: array of byte);

  procedure SetBCP_UserParams(var m: array of byte);
  procedure GetBCP_UserParams(var m: array of byte);

  procedure ClearSCU_SHParams(var m: array of byte);
  procedure SetSCU_SHParams(var m: array of byte);
  procedure GetSCU_SHParams(var m: array of byte);

  procedure SetSCU_RelayParams(var m: array of byte);
  procedure GetSCU_RelayParams(var m: array of byte);

  procedure SetSCU_USKParams(var m: array of byte);
  procedure GetSCU_USKParams(var m: array of byte);

  procedure SetSCU_APParams(var m: array of byte);
  procedure GetSCU_APParams(var m: array of byte);

  procedure SetSCU_UserParams(var m: array of byte);
  procedure GetSCU_UserParams(var m: array of byte);

  procedure SetSCU_HWParams(var m: array of byte);
  procedure GetSCU_HWParams(var m: array of byte);


 public
  procedure Consider(mes : KSBMES; str : string); override;
 end;


var
  mMain: TmMain;
  data: PChar;

implementation

uses R8Unit, KSBParam, IniFiles, DateUtils;

{$R *.DFM}


procedure TmMain.FormCreate(Sender: TObject);
var
 i: word;
begin
 inherited;//обязательно
 StatusBar1.Panels.Items[0].Text:= ' Net/Big (Device) = ' + inttostr(SpinEdit16.Value) + '/' + inttostr(SpinEdit17.Value);
 StatusBar1.Panels.Items[1].Text:= 'СУ=' + inttostr(SpinEdit_SU.Value) + ', ' +
                                   'Зона=' + inttostr(SpinEdit_ZONE.Value) + ', ' +
                                   'ТС=' + inttostr(SpinEdit_TC.Value) + ', ' +'';
 if not FileExists(ReadPath()+Application.Title+'.ini') then
 begin
   WriteLog('Не найден '+Application.Title+'.ini файл');
   PostMessage(Handle, WM_QUIT, 0, 0);
   exit;
 end;
 TheKSBParam.LoadFromFile(ReadPath()+Application.Title+'.ini');
 //
 for i:=0 to 15 do
 begin
   DateData.Append;
   DateData.FieldByName('Day').AsInteger:= i+1;
   DateData.FieldByName('Month').AsInteger:= 1;
 end;
 DateData.Post;
end;


procedure TmMain.SpinEdit16Change(Sender: TObject);
begin
 StatusBar1.Panels.Items[0].Text:= ' Net/Big (Device) = ' + inttostr(SpinEdit16.Value) + '/' + inttostr(SpinEdit17.Value);
end;


procedure TmMain.SpinEdit17Change(Sender: TObject);
begin
 StatusBar1.Panels.Items[0].Text:= ' Net/Big (Device) = ' + inttostr(SpinEdit16.Value) + '/' + inttostr(SpinEdit17.Value);
end;

procedure TmMain.WriteLog(str: string);
const
  MAX_LOG_SIZE = 10000000;

var f: TIniFile;
    SysTime: SYSTEMTIME;
    Name, s: string;
    AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond: word;
    hFile, fileSize: Integer;
begin
 name:= ExtractFileName(Application.ExeName);
 SetLength(name, Length(name)-4);
 name:= ReadPath() + name;
 //
 hFile:= FileOpen(name + '.log', fmOpenRead);
 fileSize:= GetFileSize(hFile, nil);
 FileClose(hFile);
 if fileSize>MAX_LOG_SIZE then
 begin
   DecodeDateTime (now, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
   s:= Format('%u%u%u_%u%u_%u%u', [AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond]);
   if not RenameFile ( name + '.log', name + '_' + s + '.log' ) then
     s:= str + #13#10' Переименование прошло с ошибкой: '+ IntToStr(GetLastError);
 end;
 //
 f:= TIniFile.Create(name + '.log');
 GetLocalTime(SysTime);
 Inc(LogCount);
 f.WriteString(Application.ExeName,
  Format('%u-%.2u/%.2u/%.4u-%.2u:%.2u:%.2u',[LogCount, SysTime.wDay, SysTime.wMonth, SysTime.wYear, SysTime.wHour, SysTime.wMinute, SysTime.wSecond] ), str);
 f.Free();
end;


procedure TmMain.Log(str: string);
var
 i: word;
begin
 Try
   WriteLog(str);
   if memo1.Lines.Count>100000 then       //!!!!!!!!!!
     for i:=0 to 999 do
       memo1.Lines.Delete(0);
     Memo1.Lines.Add(DateTimeToStr(Now) +' '+ str);
 Finally
 End;
end;


procedure TmMain.N2Click(Sender: TObject);
begin
 Memo1.Lines.Clear;
end;


procedure TmMain.Consider(mes: KSBMES; str: string);
var
 l: array [0..1023] of byte;
 st: String;
 i: word;
 Find: boolean;
 s: string;
 v: word;
 ret: integer;
begin
 inherited Consider(mes, str);

 //
 if CheckBox30.Checked then
 begin
   //Фильтр
   Find:= True;
   if Find and (SpinEdit_SysDevice.Value>0) then
     if SpinEdit_SysDevice.Value<>mes.SysDevice then
       Find:= False;
   if Find and (SpinEdit_TypeDevice.Value>0) then
     if SpinEdit_TypeDevice.Value<>mes.TypeDevice then
       Find:= False;
   if Find and (SpinEdit_NetDevice.Value>0) then
     if SpinEdit_NetDevice.Value<>mes.NetDevice then
       Find:= False;
   if Find and (SpinEdit_BigDevice.Value>0) then
     if SpinEdit_BigDevice.Value<>mes.BigDevice then
       Find:= False;
   if Find and (SpinEdit_SmallDevice.Value>0) then
     if SpinEdit_SmallDevice.Value<>mes.SmallDevice then
       Find:= False;
   if Find and (Memo_Code.Lines.Count>0) then
   begin
     Find:= False;
     for i:=0 to Memo_Code.Lines.Count-1 do
     begin
       s:= Memo_Code.Lines.Strings[i];
       Val(s, v, ret);
       if ret<>0 then
         continue;
       if v<>mes.Code
         then continue
         else begin
           Find:= True;
           break;
         end;
     end;
   end;
   //Логирование
   if Find then
   begin
     st:= Format('Code=%d Sys=%d Net=%d Big=%d Small=%d Type=%d Mode=%d Part=%d Lev=%d Us=%d Card=%d Mon=%d Cam=%d Prog=%d' ,
                [
                mes.Code,
                mes.SysDevice,
                mes.NetDevice,
                mes.BigDevice,
                mes.SmallDevice,
                mes.TypeDevice,
                mes.Mode,
                mes.Partion,
                mes.Level,
                mes.User,
                mes.NumCard,
                mes.Monitor,
                mes.Camera,
                mes.Proga
                ]);
     if mes.Size>0 then
     st:= st + Format(' str(%d)=%s', [ mes.Size, str ]);
     Log(st);
   end;
 end;//if CheckBox30.Checked


 //Обработка
 if(mes.NetDevice<>SpinEdit16.Value) then
   exit;
 if(mes.BigDevice<>SpinEdit17.Value) then
   exit;
 Simbol2Bin(str, @l[0], mes.Size);
 //
 case mes.Code of
  R8_GETTIME: Edit2.Text:= DateTimeToStr(mes.CmdTime);

  R8_CU_CONFIG:
    GetBCP_CUParams(l);

  SCU_SH:
    GetSCU_SHParams(l);

  SCU_RELAY:
    GetSCU_RelayParams(l);

  SCU_USK:
    GetSCU_USKParams(l);

  SCU_AP:
    GetSCU_APParams(l);

  SCU_USER:
    GetSCU_UserParams(l);

  SCU_HW:
    GetSCU_HWParams(l);

 end;//case

end;

procedure TmMain.ToolButton163Click(Sender: TObject);
var
  l: array[0..127] of BYTE;
  mes: KSBMES;
  i, ti: byte;
begin
 DateData.Refresh;
 ti:= DateData.RecordCount;
 if (ti<>16) then
 begin
   MessageBox(0, 'Число праздничных дней не 16', 'Внимание', MB_OK or MB_DEFBUTTON2 or MB_SYSTEMMODAL or MB_ICONQUESTION);
   exit;
 end;
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 4;
 FillChar(l,128,0);
 //
 mes.Size:= 2 * ti;
 DateData.First;
 for i:=0 to ti-1 do
 begin
   l[i*2 + 0]:= DateData.FieldByName('Day').AsInteger;
   l[i*2 + 1]:= DateData.FieldByName('Month').AsInteger;
   DateData.Next;
 end;
 mes.Code:= R8_COMMAND_HOLIDAY_SET;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton73Click(Sender: TObject);
var
  l: array[0..127] of BYTE;
  mes: KSBMES;
  i, ti: byte;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер ВЗ', SpinEdit_BCP_TZ.Value);
 FillChar(l,128,0);
 TIdata.Refresh;
 ti:= TIdata.RecordCount;
 if (ti=0)or(ti>21) then
   exit;
 //
 mes.Size:= 6 * ti;
 TIdata.First;
 for i:=0 to ti-1 do
 begin
   l[i*6 + 0]:= i+1;
   l[i*6 + 1]:= TIdata.FieldByName('BeginHour').AsInteger;
   l[i*6 + 2]:= TIdata.FieldByName('EndHour').AsInteger;
   l[i*6 + 3]:= TIdata.FieldByName('BeginMin').AsInteger;
   l[i*6 + 4]:= TIdata.FieldByName('EndMin').AsInteger;
   l[i*6 + 5]:= byte(TIdata.FieldByName('1').AsBoolean=True) * 1 +
                byte(TIdata.FieldByName('2').AsBoolean=True) * 2 +
                byte(TIdata.FieldByName('3').AsBoolean=True) * 4 +
                byte(TIdata.FieldByName('4').AsBoolean=True) * 8 +
                byte(TIdata.FieldByName('5').AsBoolean=True) * 16 +
                byte(TIdata.FieldByName('6').AsBoolean=True) * 32 +
                byte(TIdata.FieldByName('7').AsBoolean=True) * 64 +
                byte(TIdata.FieldByName('8').AsBoolean=True) * 128;
   TIdata.Next;
 end;
 {
 l[0]:=1;                              // ВИ
 l[1]:=01;                             // нач. час
 l[2]:=20;                             // кон. час
 l[3]:=21;                             // нач. мин
 l[4]:=30;                             // кон. мин
 l[5]:=127;                            // карта дней недели

 l[6]:=2;                              // ВИ
 l[7]:=01;                             // нач. час
 l[8]:=10;                             // кон. час
 l[9]:=22;                             // нач. мин
 l[10]:=30;                            // кон. мин
 l[11]:=11;                            // карта дней недели
 }
 mes.Code:=R8_COMMAND_TZ_CREATE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton74Click(Sender: TObject);
var
  l: array[0..127] of BYTE;
  mes: KSBMES;
  i, ti: byte;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер ВЗ', SpinEdit_BCP_TZ.Value);
 FillChar(l,128,0);
 TIdata.Refresh;
 ti:= TIdata.RecordCount;
 if (ti=0)or(ti>21) then
   exit;
 //
 mes.Size:= 6 * ti;
 TIdata.First;
 for i:=0 to ti-1 do
 begin
   l[i*6 + 0]:= i+1;
   l[i*6 + 1]:= TIdata.FieldByName('BeginHour').AsInteger;
   l[i*6 + 2]:= TIdata.FieldByName('EndHour').AsInteger;
   l[i*6 + 3]:= TIdata.FieldByName('BeginMin').AsInteger;
   l[i*6 + 4]:= TIdata.FieldByName('EndMin').AsInteger;
   l[i*6 + 5]:= byte(TIdata.FieldByName('1').AsBoolean=True) * 1 +
                byte(TIdata.FieldByName('2').AsBoolean=True) * 2 +
                byte(TIdata.FieldByName('3').AsBoolean=True) * 4 +
                byte(TIdata.FieldByName('4').AsBoolean=True) * 8 +
                byte(TIdata.FieldByName('5').AsBoolean=True) * 16 +
                byte(TIdata.FieldByName('6').AsBoolean=True) * 32 +
                byte(TIdata.FieldByName('7').AsBoolean=True) * 64 +
                byte(TIdata.FieldByName('8').AsBoolean=True) * 128;
   TIdata.Next;                
 end;
 {
 mes.Size:=18;
 FillChar(l,128,0);
 l[0]:=1;                              // ВИ
 l[1]:=01;                             // нач. час
 l[2]:=20;                             // кон. час
 l[3]:=21;                             // нач. мин
 l[4]:=30;                             // кон. мин
 l[5]:=64;                             // карта дней недели
 l[6]:=2;                              // ВИ
 l[7]:=01;                             // нач. час
 l[8]:=23;                             // кон. час
 l[9]:=22;                             // нач. мин
 l[10]:=30;                            // кон. мин
 l[11]:=11;                            // карта дней недели
 l[12]:=3;                             // ВИ
 l[13]:=01;                            // нач. час
 l[14]:=13;                            // кон. час
 l[15]:=22;                            // нач. мин
 l[16]:=30;                            // кон. мин
 l[17]:=11;                            // карта дней недели
 }
 mes.Code:=R8_COMMAND_TZ_CHANGE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton75Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер ВЗ', SpinEdit_BCP_TZ.Value);
 mes.Code:=R8_COMMAND_TZ_DELETE;
 send(mes);
end;

procedure TmMain.ToolButton77Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_TZ_ALL_DELETE;
 send(mes);
end;

procedure TmMain.SpinEdit_BCP_TZChange(Sender: TObject);
begin
 //TIdata.Filter:= 'BeginHour=' + IntToStr(SpinEdit_BCP_TZ.Value);
end;

procedure TmMain.TIdataAfterInsert(DataSet: TDataSet);
begin
 TIdataTZ.Value:= SpinEdit_BCP_TZ.Value;
 TIdataBeginHour.Value:=0;
 TIdataBeginMin.Value:=0;
 TIdataEndHour.Value:=0;
 TIdataEndMin.Value:=0;
 TIdataField1.Value:= False;
 TIdataField2.Value:= False;
 TIdataField3.Value:= False;
 TIdataField4.Value:= False;
 TIdataField5.Value:= False;
 TIdataField6.Value:= False;
 TIdataField7.Value:= False;
 TIdataField8.Value:= False;
end;

procedure TmMain.TIdataBeforePost(DataSet: TDataSet);
var
 d1, d2: TDateTime;
begin
 d1:= StrToDateTime( Format('%d:%d', [TIdataBeginHour.Value, TIdataBeginMin.Value]) );
 d2:= StrToDateTime( Format('%d:%d', [TIdataEndHour.Value, TIdataEndMin.Value]) );
 if d1>=d2 then
   Raise Exception.Create('Неверно задан временной интервал.')
end;



procedure TmMain.ToolButton78Click(Sender: TObject);
var
  l: array[0..4095] of BYTE;
  mes: KSBMES;
  i, pr: word;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер УД', SpinEdit_BCP_UD.Value);
 mes.Size:=12;
 FillChar(l,4095,0);

 UDdata.Refresh;
 pr:= UDdata.RecordCount;
 if (pr=0)or(pr>340) then
   exit;

 mes.Size:= 12 * pr;
 UDdata.First;
 for i:=0 to pr-1 do
 begin
   l[i*12 + 0]:= byte(UDdata.FieldByName('ZnStatus').AsInteger>0);
   l[i*12 + 1]:= byte(UDdata.FieldByName('Permission').AsInteger=1);
   l[i*12 + 2]:= lo(UDdata.FieldByName('Zn').AsInteger);
   l[i*12 + 3]:= hi(UDdata.FieldByName('Zn').AsInteger);
   l[i*12 + 4]:= UDdata.FieldByName('ZnStatus').AsInteger;
   l[i*12 + 5]:= UDdata.FieldByName('TCtype').AsInteger;
   l[i*12 + 6]:= UDdata.FieldByName('GrTC').AsInteger;
   l[i*12 + 7]:= UDdata.FieldByName('MapLo').AsInteger;
   l[i*12 + 9]:= UDdata.FieldByName('MapHi').AsInteger;
   l[i*12 + 11]:= UDdata.FieldByName('TimeZn').AsInteger;
   UDdata.Next;
 end;
{
Массив =
0 байт = (0-nop, 1-право на все зо-ны со статусом, не превышающим статус в этом праве, см. 4байт)
1 байт =(0-запрещение,1-разреш. - е)

2 байт = lo (номер зоны)
3 байт = hi (номер зоны)
4 байт =статус зоны
5 байт = тип объекта ТС (см. прил. 6)
6 байт = группа ТС (0-все)

7..10 байт =карта разрешений (за-прещений), 7 байт мл.
11 байт = ВЗ (0-никогда, 255-всегда)
 * n, где n - число прав
}
 mes.Code:= R8_COMMAND_UD_CREATE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton79Click(Sender: TObject);
var
  l: array[0..4095] of BYTE;
  mes: KSBMES;
  i, pr: word;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер УД', SpinEdit_BCP_UD.Value);
 mes.Size:=12;
 FillChar(l,4095,0);

 UDdata.Refresh;
 pr:= UDdata.RecordCount;
 if (pr=0)or(pr>340) then
   exit;

 mes.Size:= 12 * pr;
 UDdata.First;
 for i:=0 to pr-1 do
 begin
   l[i*12 + 0]:= byte(UDdata.FieldByName('ZnStatus').AsInteger>0);
   l[i*12 + 1]:= byte(UDdata.FieldByName('Permission').AsInteger=1);
   l[i*12 + 2]:= lo(UDdata.FieldByName('Zn').AsInteger);
   l[i*12 + 3]:= hi(UDdata.FieldByName('Zn').AsInteger);
   l[i*12 + 4]:= UDdata.FieldByName('ZnStatus').AsInteger;
   l[i*12 + 5]:= UDdata.FieldByName('TCtype').AsInteger;
   l[i*12 + 6]:= UDdata.FieldByName('GrTC').AsInteger;
   l[i*12 + 7]:= UDdata.FieldByName('MapLo').AsInteger;
   l[i*12 + 9]:= UDdata.FieldByName('MapHi').AsInteger;
   l[i*12 + 11]:= UDdata.FieldByName('TimeZn').AsInteger;
   UDdata.Next;
 end;
 mes.Code:=R8_COMMAND_UD_CHANGE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton80Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер УД', SpinEdit_BCP_UD.Value);
 mes.Code:= R8_COMMAND_UD_DELETE;
 send(mes);
end;


procedure TmMain.ToolButton82Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:= R8_COMMAND_UD_ALL_DELETE;
 send(mes);
end;




procedure TmMain.ToolButton16Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_BCP_USER.Value);
 mes.CmdTime:= DateEdit1.Date; //Действие полномочий
 mes.Size:= 21;
 //----- Д О П Ы -----
 SetBCP_UserParams(l[0]);
 mes.Code:= R8_COMMAND_USER_CREATE;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton17Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_BCP_USER.Value);
 mes.CmdTime:= DateEdit1.Date; //Действие полномочий
 mes.Size:= 21;
 //----- Д О П Ы -----
 SetBCP_UserParams(l[0]);
 mes.Code:=R8_COMMAND_USER_CHANGE;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton18Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_BCP_USER.Value);
 mes.Code:=R8_COMMAND_USER_DELETE;
 send(mes);
end;

procedure TmMain.ToolButton62Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_USER_ALL_DELETE;
 send(mes);
end;

procedure TmMain.ToolButton38Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_BCP_USER.Value);
 SpinEdit19.Value:= SpinEdit_BCP_USER.Value;
 mes.CmdTime:= DateEdit1.Date; //Действие полномочий
 mes.Size:= 21;
 //----- Д О П Ы -----
 SetBCP_UserParams(l[0]);
 mes.Code:= SUD_ADD_CARD;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton39Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_BCP_USER.Value);
 mes.Code:=SUD_DEL_CARD;
 send(mes);
end;




procedure TmMain.ToolButton45Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
 i: integer;
begin
 for i:=0 to SpinEdit4.Value-1 do
 begin
   Init(mes);
   mes.SysDevice:=SYSTEM_OPS;
   mes.NetDevice:=SpinEdit16.Value;
   mes.BigDevice:=SpinEdit17.Value;
   mes.TypeDevice:=4;
   mes.Size:= 21;
   TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_BCP_USER.Value + i);
   mes.CmdTime:=DateEdit1.Date;           //Действие полномочий
   SetBCP_UserParams(l[0]);               //Парамеры
   mes.Code:=R8_COMMAND_USER_CREATE;
   send(mes,PChar(@l[0]));
 end;
end;

procedure TmMain.ToolButton59Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
 i: integer;
begin
 for i:=0 to SpinEdit4.Value-1 do
 begin
   Init(mes);
   mes.SysDevice:=SYSTEM_OPS;
   mes.NetDevice:=SpinEdit16.Value;
   mes.BigDevice:=SpinEdit17.Value;
   mes.TypeDevice:=4;
   mes.Size:= 21;
   TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_BCP_USER.Value + i);
   mes.CmdTime:=DateEdit1.Date;           //Действие полномочий
   SetBCP_UserParams(l[0]);               //Парамеры
   mes.Code:=R8_COMMAND_USER_DELETE;
   send(mes,PChar(@l[0]));
 end;
end;


procedure TmMain.ToolButton84Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:=12;
 mes.SmallDevice:= SpinEdit_BCP_USER.Value;
 mes.Code:= R8_COMMAND_USER_APBRESET;
 send(mes);
end;



procedure TmMain.ComboBox3Change(Sender: TObject);
var
 n: word;
 s1, s2: string;

begin
 s1:= copy(ComboBox3.Text, 1, 2);
 n:= strtoint(s1);
 case n of
   1:  s2:='00.00.00.00.00.00.00.00';
   2:  s2:='00.00.00.00.00.00.00.00';
   3:  s2:='00.00.00.00.00.00.00.00';
   4:  s2:='00.00.00.00.00.00.00.00';
   5:  s2:='00.00.00.00.00.00.00.00';
   6:  s2:='00.00.00.00.00.00.00.00';
   7:  s2:='00.00.00.00.00.00.00.00';
   8:  s2:='00.00.00.00.00.00.00.00';
   9:  s2:='00.00.00.00.00.00.00.00';
   10: s2:='00.00.00.00.00.00.00.00';
   11: s2:='00.00.00.00.00.00.00.00';
   12: s2:='00.00.00.00.00.00.00.00';
   13: s2:='00.00.00.00.00.00.00.00';
   14: s2:='00.00.00.00.00.00.00.00';
   16: s2:='00.00.00.00.00.00.00.00';
   17: s2:='00.00.00.00.00.00.00.00';
   18: s2:='00.00.00.00.00.00.00.00';
   19: s2:='00.00.00.00.00.00.00.00';
   20: s2:='00.00.00.00.00.00.00.00';
   21: s2:='00.00.00.00.00.00.00.00';
   22: s2:='00.00.00.00.00.00.00.00';
   23: s2:='00.00.00.00.00.00.00.00';
   24: s2:='00.00.00.00.00.00.00.00';
   25: s2:='00.00.00.00.00.00.00.00';
   26: s2:='00.00.00.00.00.00.00.00';
   27: s2:='00.00.00.00.00.00.00.00';
   28: s2:='00.00.00.00.00.00.00.00';
   29: s2:='00.00.00.00.00.00.00.00';
   30: s2:='00.00.00.00.00.00.00.00';
   31: s2:='00.00.00.00.00.00.00.00';
   32: s2:='00.00.C0.A8.00.01.00.00';
   33: s2:='00.00.00.00.00.00.00.00';
   34: s2:='00.00.00.00.00.00.00.00';
   35: s2:='00.00.00.00.00.00.00.00';
   36: s2:='00.00.00.00.00.00.00.00';
   37: s2:='00.00.00.00.00.00.00.00';
   38: s2:='00.00.00.00.00.00.00.00';
   39: s2:='00.00.00.00.00.00.00.00';
   40: s2:='00.00.00.00.00.00.00.00';
   41: s2:='00.00.00.00.00.00.00.00';
   42: s2:='00.00.00.00.00.00.00.00';
   43: s2:='00.00.00.00.00.00.00.00';
   44: s2:='00.00.00.00.00.00.00.00';
   45: s2:='00.00.00.00.00.00.00.00';
   46: s2:='00.00.00.00.00.00.00.00';
   47: s2:='00.00.00.00.00.00.00.00';
   48: s2:='00.00.00.00.00.00.00.00';
   49: s2:='00.00.00.00.00.00.00.00';
 end; //
 MaskEdit1.Text:= s2;
 //
 case n of
   1:  s2:='';
   2:  s2:='';
   3:  s2:='';
   4:  s2:='';
   5:  s2:='';
   6:  s2:='';
   7:  s2:='';
   8:  s2:='';
   9:  s2:='';
   10: s2:='';
   11: s2:='';
   12: s2:='';
   13: s2:='';
   14: s2:='';
   16: s2:='';
   17: s2:='';
   18: s2:='';
   19: s2:='';
   20: s2:='';
   21: s2:='';
   22: s2:='';
   23: s2:='';
   24: s2:='';
   25: s2:='';
   26: s2:='';
   27: s2:='';
   28: s2:='';
   29: s2:='';
   30: s2:='';
   31: s2:='';
   32: s2:='2-5 байты (IP-адрес); 0,1,6,7 байты (резерв)';
   33: s2:='';
   34: s2:='';
   35: s2:='';
   36: s2:='';
   37: s2:='';
   38: s2:='';
   39: s2:='';
   40: s2:='';
   41: s2:='';
   42: s2:='';
   43: s2:='';
   44: s2:='';
   45: s2:='';
   46: s2:='';
   47: s2:='';
   48: s2:='';
   49: s2:='';
 end; //
 MaskEdit1.Hint:= s2;


end;

procedure TmMain.MaskEdit1KeyPress(Sender: TObject; var Key: Char);
var
 c: char;
begin
  c:= UpperCase(Key)[1];
  if not (c in ['0'..'9','A'..'F',#8]) then
    Raise Exception.Create('Ошибка ввода.');
end;




























procedure TmMain.ToolButton8Click(Sender: TObject);
var
  l: array[0..127] of BYTE;
  mes: KSBMES;
  s: string;
  i: word;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', SpinEdit_SU.Value);
 mes.Size:=(5+8);
 FillChar(l,128,0);
 l[0]:=byte(CheckBox2.Checked);                    // Вкл/выкл
 l[1]:=SpinEdit3.Value;                            // линия
 l[2]:=strtoint(copy(ComboBox3.Text, 1, 2));       // l[0]-тип CУ
 l[3]:=lo(SpinEdit7.Value);                        // адрес СУ
 l[4]:=hi(SpinEdit7.Value);                        // адрес СУ
 for i:=0 to 7 do                                  // параметры
 begin
   s:= copy(MaskEdit1.Text, 1+i*3, 2);
   l[5+i]:= strtoint('$'+s);
 end;
 mes.Code:=R8_COMMAND_CU_CREATE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton9Click(Sender: TObject);
var
  l: array[0..127]  of BYTE;
  mes: KSBMES;
  s: string;
  i: word;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', SpinEdit_SU.Value);
 mes.Size:=(2+8);
 FillChar(l,128,0);
 l[0]:=byte(CheckBox2.Checked);                    // Вкл/выкл
 l[1]:=SpinEdit3.Value;                            // линия
 for i:=0 to 7 do                                  // параметры
 begin
   s:= copy(MaskEdit1.Text, 1+i*3, 2);
   l[2+i]:= strtoint('$'+s);
 end;
 mes.Code:=R8_COMMAND_CU_CHANGE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton11Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', SpinEdit_SU.Value);
 mes.Code:=R8_COMMAND_CU_DELETE;
 send(mes);
end;

procedure TmMain.ToolButton71Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_CU_ALL_DELETE;
 send(mes);
end;

procedure TmMain.ToolButton46Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', SpinEdit_SU.Value);
 mes.Code:=R8_COMMAND_CU_CONFIG;
 send(mes);
end;


procedure TmMain.ToolButton21Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', SpinEdit_ZONE.Value);
 mes.Size:= 7;
 FillChar(l,128,0);
 l[0]:= strtoint('$'+Edit_ZONE_NAME.Text[1]+Edit_ZONE_NAME.Text[2]);  // l[1]-Номер зоны
 l[1]:= strtoint('$'+Edit_ZONE_NAME.Text[3]+Edit_ZONE_NAME.Text[4]);  //
 l[2]:= strtoint('$'+Edit_ZONE_NAME.Text[5]+Edit_ZONE_NAME.Text[6]);  //
 l[3]:= strtoint('$'+Edit_ZONE_NAME.Text[7]+Edit_ZONE_NAME.Text[8]);  //
 l[4]:= 4*RadioGroup6.ItemIndex + 3;
 l[5]:= SpinEdit1.Value;
 l[6]:= SpinEdit58.Value;
 mes.Code:= R8_COMMAND_ZONE_CREATE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton22Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 4;
 mes.Size:= 3;
 FillChar(l,128,0);
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', SpinEdit_ZONE.Value);
 l[0]:= 4*RadioGroup6.ItemIndex+3;
 l[1]:= SpinEdit1.Value;
 l[2]:= SpinEdit58.Value;
 mes.Code:= R8_COMMAND_ZONE_CHANGE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton25Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', SpinEdit_ZONE.Value);
 mes.Code:= R8_COMMAND_ZONE_DELETE;
 send(mes);
end;

procedure TmMain.ToolButton70Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_ZONE_ALL_DELETE;
 send(mes);
end;

procedure TmMain.ToolButton26Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=6;
 mes.SmallDevice:=SpinEdit_ZONE.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit2.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_ZONE_ARM;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton28Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=6;
 mes.SmallDevice:=SpinEdit_ZONE.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit2.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_ZONE_DISARM;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.SpinEdit_ZONEChange(Sender: TObject);
var
 s: string;
 m: array [0..3] of byte;
 i: byte;
begin
 i:= length(SpinEdit_ZONE.Text);
 if (i=0) then
 exit;
 s:= IntToStr(SpinEdit_ZONE.Value);
 StrToVal(s, m);
 Edit_ZONE_NAME.Text:='';
 for i:=0 to 3 do
   Edit_ZONE_NAME.Text:=Edit_ZONE_NAME.Text+IntToHex(m[i],2);
 //
 StatusBar1.Panels.Items[1].Text:= 'СУ=' + inttostr(SpinEdit_SU.Value) + ', ' +
                                   'Зона=' + inttostr(SpinEdit_ZONE.Value) + ', ' +
                                   'ТС=' + inttostr(SpinEdit_TC.Value) + ', ' +'';
end;

procedure TmMain.SpinEdit_SUChange(Sender: TObject);
begin
 StatusBar1.Panels.Items[1].Text:= 'СУ=' + inttostr(SpinEdit_SU.Value) + ', ' +
                                   'Зона=' + inttostr(SpinEdit_ZONE.Value) + ', ' +
                                   'ТС=' + inttostr(SpinEdit_TC.Value) + ', ' +'';
end;




//------------------------------------------------------------------------------
procedure TmMain.ToolButton88Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Size:=1;
 FillChar(l,128,0);
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер группы', SpinEdit_GROUP.Value);
 l[0]:= SpinEdit57.Value;
 mes.Code:=R8_COMMAND_GR_CREATE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton89Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Size:=1;
 FillChar(l,128,0);
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер группы', SpinEdit_GROUP.Value);
 l[0]:= SpinEdit57.Value;
 mes.Code:=R8_COMMAND_GR_CHANGE;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton90Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер группы', SpinEdit_GROUP.Value);
 mes.Code:=R8_COMMAND_GR_DELETE;
 send(mes);
end;


procedure TmMain.ToolButton92Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_GR_DELETE_ALL;
 send(mes);
end;

procedure TmMain.ToolButton94Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер группы', SpinEdit_GROUP.Value);
 mes.Code:=R8_COMMAND_GR_GET;
 send(mes);
end;

procedure TmMain.ToolButton95Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_GR_GETLIST;
 send(mes);
end;

//------------------------------------------------------------------------------
procedure TmMain.ToolButton1Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 data:='';
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', SpinEdit_ZONE.Value);
 FillChar(l,128,0);
 //
 l[1]:= strtoint('$'+Edit_TC_NAME.Text[1]+Edit_TC_NAME.Text[2]);  // l[1]-номер ТС
 l[2]:= strtoint('$'+Edit_TC_NAME.Text[3]+Edit_TC_NAME.Text[4]);  //
 l[3]:= strtoint('$'+Edit_TC_NAME.Text[5]+Edit_TC_NAME.Text[6]);  //
 l[4]:= strtoint('$'+Edit_TC_NAME.Text[7]+Edit_TC_NAME.Text[8]);  //
 l[5]:= SpinEdit56.Value;                                         // l[5]-имя указатель на строку
 l[6]:= byte(CheckBox_TAMPER.checked) shl 7 +
         RadioGroup_TC_VIEW.ItemIndex shl 4 +
         byte(CheckBox_ON.checked) shl 3 +
         3; // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
 l[7]:= SpinEdit44.Value;                           // l[7]-группа                                        // l[7]-группа
 l[8]:= strtoint(copy(ComboBox_TC_TYPE.Text, 1, 2));// l[8]-тип оборудования
 l[9]:= lo(SpinEdit_TC_NUMBER.Value);               // l[9]-мл.байт серийный номер HW
 l[10]:= hi(SpinEdit_TC_NUMBER.Value);              // l[10]-ст.байт серийный номер HW
 l[11]:= SpinEdit_TC_ELEMENT.Value;                 // l[11]-номер элемента
 //l[12]..l[26] см. далее
 l[27]:= SpinEdit45.Value;                          // Автовост.
 //
 case PageControl_TC.ActivePageIndex of
   1: //ОШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 1; // l[0]-тип (1-охранный)
     SetBCP_SH1Params(l[12]);                         // l[12..26]-массив параметров
     mes.Code:= R8_COMMAND_SH_CREATE;
   end;
   2: //ТШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 2; // l[0]-тип (2-тревожный)
     SetBCP_SH2Params(l[12]);
     mes.Code:= R8_COMMAND_SH_CREATE;
   end;
   3: //ПШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 3; // l[0]-тип (3-пожарный)
     mes.Code:= R8_COMMAND_SH_CREATE;
   end;
   4: //ТехШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 4; // l[0]-тип (4-технолог.)
     mes.Code:= R8_COMMAND_SH_CREATE;
   end;
   5: //РЕЛЕ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 5; // l[0]-тип (5-реле)
     mes.Code:= R8_COMMAND_RELAY_CREATE;
   end;
   6: //ТД
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', SpinEdit_TC.Value);
     mes.Size:= 28+2;
     l[0]:= 6; // l[0]-тип (6-ТД)
     if CheckBox31.Checked
       then l[28]:= 1
       else l[28]:= 0;
     l[29]:= SpinEdit10.Value and $FF;
     SetBCP_APParams(l[12]);                           // l[12..26]-массив параметров ТД
     mes.Code:= R8_COMMAND_AP_CREATE;
   end;
   7: //Терм.
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 7; // l[0]-тип (7-Терм.)
     SetBCP_TermParams(l[12]);                           // l[12..26]-массив параметров Терм
     mes.Code:= R8_COMMAND_TERM_CREATE;
   end;
   10: //ШС замка
   begin
     mes.SmallDevice:= SpinEdit53.Value; //№ ТД
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value); //№ ШС
     mes.Size:= 28;
     l[0]:= 1; //(1-охранный)
     mes.Code:= R8_COMMAND_APSHZMK_SET;
   end;
   else exit;
 end;//case
 Send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton2Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 data:=''; 
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', SpinEdit_ZONE.Value);
 FillChar(l,128,0);
 //
 l[1]:= strtoint('$'+Edit_TC_NAME.Text[1]+Edit_TC_NAME.Text[2]);  // l[1]-номер ТС
 l[2]:= strtoint('$'+Edit_TC_NAME.Text[3]+Edit_TC_NAME.Text[4]);  //
 l[3]:= strtoint('$'+Edit_TC_NAME.Text[5]+Edit_TC_NAME.Text[6]);  //
 l[4]:= strtoint('$'+Edit_TC_NAME.Text[7]+Edit_TC_NAME.Text[8]);  //
 l[5]:= SpinEdit56.Value;                                         // l[5]-имя указатель на строку
 l[6]:= byte(CheckBox_TAMPER.checked) shl 7 +
         RadioGroup_TC_VIEW.ItemIndex shl 4 +
         byte(CheckBox_ON.checked) shl 3 +
         3; // l[6]-мл.бит >> 110(вкл 1бит)(отображение 2бита) 1 << ст.бит
 l[7]:= SpinEdit44.Value;                           // l[7]-группа                                        // l[7]-группа
 l[8]:= strtoint(copy(ComboBox_TC_TYPE.Text, 1, 2));// l[8]-тип оборудования
 l[9]:= lo(SpinEdit_TC_NUMBER.Value);               // l[9]-мл.байт серийный номер HW
 l[10]:= hi(SpinEdit_TC_NUMBER.Value);              // l[10]-ст.байт серийный номер HW
 l[11]:= SpinEdit_TC_ELEMENT.Value;                 // l[11]-номер элемента
 //l[12]..l[26] см. далее
 l[27]:= SpinEdit45.Value;                          // Автовост.
 //
 case PageControl_TC.ActivePageIndex of
   1: //ОШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 1; // l[0]-тип (1-охранный)
     SetBCP_SH1Params(l[12]);                         // l[12..26]-массив параметров
     mes.Code:= R8_COMMAND_SH_CHANGE;
   end;
   2: //ТШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 2; // l[0]-тип (2-тревожный)
     mes.Code:= R8_COMMAND_SH_CHANGE;
   end;
   3: //ПШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 3; // l[0]-тип (3-пожарный)
     mes.Code:= R8_COMMAND_SH_CHANGE;
   end;
   4: //ТехШ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 4; // l[0]-тип (4-технолог.)
     mes.Code:= R8_COMMAND_SH_CHANGE;
   end;
   5: //РЕЛЕ
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 5; // l[0]-тип (5-реле)
     mes.Code:= R8_COMMAND_RELAY_CHANGE;
   end;
   6: //ТД
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', SpinEdit_TC.Value);
     mes.Size:= 28+2;
     l[0]:= 6; // l[0]-тип (6-ТД)
     if CheckBox31.Checked
       then l[28]:= 1
       else l[28]:= 0;
     l[29]:= SpinEdit10.Value and $FF;
     SetBCP_APParams(l[12]);                           // l[12..27]-массив параметров ТД
     mes.Code:= R8_COMMAND_AP_CHANGE;
   end;
   7: //Терм.
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', SpinEdit_TC.Value);
     mes.Size:= 28;
     l[0]:= 7; // l[0]-тип (7-Терм.)
     SetBCP_TermParams(l[12]);                         // l[12..26]-массив параметров Терм
     mes.Code:= R8_COMMAND_TERM_CHANGE;
   end;
   10: //ШС замка
   begin
     mes.SmallDevice:= SpinEdit53.Value; //№ ТД
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value); //№ ШС
     mes.Size:= 28;
     l[0]:= 1; //(1-охранный)
     mes.Code:= R8_COMMAND_APSHZMK_SET;
   end;
 else exit;
 end;
 Send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton3Click(Sender: TObject);
var
 mes: KSBMES;
 l: array[0..127]  of BYTE;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 FillChar(l,128,0);
 // 
 case PageControl_TC.ActivePageIndex of
   1..4:
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value);
     mes.Code:=R8_COMMAND_SH_DELETE;
   end;
   5:
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', SpinEdit_TC.Value);
     mes.Code:=R8_COMMAND_RELAY_DELETE;
   end;
   6:
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', SpinEdit_TC.Value);
     mes.Code:=R8_COMMAND_AP_DELETE;
   end;
   7:
   begin
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', SpinEdit_TC.Value);
     mes.Code:=R8_COMMAND_TERM_DELETE;
   end;
   10:
   begin
     mes.SmallDevice:= SpinEdit53.Value; //№ ТД
     TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', SpinEdit_TC.Value); //№ ШС
     mes.Code:=R8_COMMAND_APSHZMK_DELETE;
   end;
   else exit;
 end;
 send(mes);
end;


procedure TmMain.ToolButton43Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:= SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_SH_RESTORE;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton41Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_SH_ARM;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton42Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_SH_DISARM;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton127Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_SH_BYPASS;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton115Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_SH_RESET;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton116Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_SH_TEST;
 send(mes,PChar(@l[0]));
end;



procedure TmMain.ToolButton32Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_SH_ON;
 send(mes);
end;


procedure TmMain.ToolButton33Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=5;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_SH_OFF;
 send(mes);
end;



procedure TmMain.ToolButton35Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=7;
 mes.SmallDevice:= SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_RELAY_RESTORE;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton36Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=7;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_RELAY_1;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton37Click(Sender: TObject);
var
 l: array[0..127]  of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=7;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_RELAY_0;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton40Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', SpinEdit_TC.Value);
 mes.Code:=R8_COMMAND_RELAY_CONFIG;
 Send(mes);
end;

procedure TmMain.ToolButton64Click(Sender: TObject);
var
 mes: KSBMES;
 l: array[0..127] of BYTE;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 10;
 mes.SmallDevice:= SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:= 1;
 FillChar(l,128,0);
 l[0]:= byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:= R8_COMMAND_AP_PASS;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton65Click(Sender: TObject);
var
 mes: KSBMES;
 l: array[0..127] of BYTE;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=10;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_AP_LOCK;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton66Click(Sender: TObject);
var
 mes: KSBMES;
 l: array[0..127] of BYTE;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=10;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_AP_UNLOCK;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton67Click(Sender: TObject);
var
 mes: KSBMES;
 l: array[0..127] of BYTE;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=10;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_AP_RESET;
 send(mes,PChar(@l[0]));
end;








procedure TmMain.SpinEdit_TCChange(Sender: TObject);
var
 s: string;
 m: array [0..3] of byte;
 i: byte;
begin
 if SpinEdit_TC.Text='' then
 exit;
 s:= IntToStr(SpinEdit_TC.Value);
 StrToVal(s, m);
 Edit_TC_NAME.Text:='';
 for i:=0 to 3 do
   Edit_TC_NAME.Text:=Edit_TC_NAME.Text+IntToHex(m[i],2);
 //
 StatusBar1.Panels.Items[1].Text:= 'СУ=' + inttostr(SpinEdit_SU.Value) + ', ' +
                                   'Зона=' + inttostr(SpinEdit_ZONE.Value) + ', ' +
                                   'ТС=' + inttostr(SpinEdit_TC.Value) + ', ' +'';
end;


procedure TmMain.SpinEdit43Change(Sender: TObject);
var
 s: string;
 m: array [0..3] of byte;
 i: byte;
begin
 if SpinEdit43.Text = ''
 then s:='0'
 else s:= IntToStr(SpinEdit43.Value);
 StrToVal(s, m);
 Edit_ZN_NAME.Text:='';
 for i:=0 to 3 do
   Edit_ZN_NAME.Text:=Edit_ZN_NAME.Text + IntToHex(m[i],2);
end;



//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

procedure TmMain.SetBCP_CUParams(var m: array of byte);
begin
//
end;


procedure TmMain.GetBCP_CUParams(var m: array of byte);
var
 i: word;
 s: String;

begin
 CheckBox2.Checked:= boolean(m[0]);    // Вкл/выкл
 SpinEdit3.Value:= m[1];               // линия
 s:= IntToStr(m[2]);
 if Length(s)=1 then s:= '0' + s;
 for i:=0 to ComboBox3.Items.Count-1 do
   if s = copy(ComboBox3.Items[i], 1, 2) then
   begin
     ComboBox3.ItemIndex:= i;
     break;
   end;
 SpinEdit7.Value:= m[3] + 256*m[4];
 s:= '';
 for i:=5+0 to 5+7 do
 begin
   s:= s + IntToHex(m[i], 2);
   if i<>(5+7) then
     s:= s + '.'
 end;
 MaskEdit1.Text:= s;
end;



procedure TmMain.GetBCP_SH1Params(var m: array of byte);
begin
//
end;

procedure TmMain.SetBCP_SH1Params(var m: array of byte);
begin
 FillChar(m, 14, 0);
 // Рзащелка ШС
 m[0]:= m[0] or byte(CheckBox39.Checked);
 // снятие без выключения
 m[0]:= m[0] or (byte(CheckBox35.Checked) shl 1);
 // свой терминал
 m[0]:= m[0] or (byte(CheckBox38.Checked) shl 2);
 // регистрация в журнале событий «Готов/Не готов»
 m[0]:= m[0] or (byte(CheckBox42.Checked) shl 3);
 // ДК разрешен
 m[0]:= m[0] or (byte(CheckBox41.Checked) shl 4);
// Задержка перехода в состояние «Готов»
 m[0]:= m[0] or (byte(CheckBox43.Checked) shl 5);
 // задержка на вход
 m[1]:= SpinEdit26.Value;
 // задержка на выход
 m[2]:= SpinEdit27.Value;
 // группа управления
 m[3]:= SpinEdit29.Value;
 // тип
 m[4]:= ComboBox24.ItemIndex;
 // группа автоуправления
 m[5]:= SpinEdit40.Value;
 // группа управления 2
 m[6]:= SpinEdit37.Value;
 // ID (TCOID.ID) EO aey AE
 m[7]:= 0;
 m[8]:= 0;
 m[9]:= 0;
 m[10]:= 0;
 // Время ДК
 m[11]:= 0;
end;


procedure TmMain.GetBCP_SH2Params(var m: array of byte);
begin
//
end;

procedure TmMain.SetBCP_SH2Params(var m: array of byte);
begin
 FillChar(m, 7, 0);
 // Рзащелка ШС
 m[0]:= m[0] or byte(CheckBox45.Checked);
 // группа управления
 m[1]:= SpinEdit61.Value;
 // группа управления 2
 m[7]:= SpinEdit62.Value;
end;



procedure TmMain.SetBCP_APParams(var m: array of byte);
var
 i: word;
begin
 FillChar(m, 14, 0);
 // Режим прохода
 m[0]:= m[0] or RadioGroup1.ItemIndex;
 // Идентификация
 i:= strtoint(copy(ComboBox7.Text, 1, 2));
 m[0]:= m[0] or (i shl 1);
 // Режим работы Авто/Запрос
 case RadioGroup3.ItemIndex of
   00, 03:;
   01, 02: m[0]:= m[0] or 8;
 end;//case
 // Запрет взлома
 if CheckBox16.checked then
 m[0]:= m[0] or $10;
 // Выход по кнопке
 if not CheckBox13.checked then
 m[0]:= m[0] or $20;
 // Контроль правил прохода
 if ComboBox8.ItemIndex>0 then
 m[0]:= m[0] or $40;
 // Рег. событий
 if CheckBox14.checked then
 m[0]:= m[0] or $80;
 // Дверной код
 for i:=0 to 3 do
 begin
   m[1+i]:=(StrToInt(Edit5.Text) shr (i*8)) mod 256;
 end;
 m[5]:=strtoint('$'+Edit_ZN_NAME.Text[1]+Edit_ZN_NAME.Text[2]);  // l[1]-номер ТС
 m[6]:=strtoint('$'+Edit_ZN_NAME.Text[3]+Edit_ZN_NAME.Text[4]);  //
 m[7]:=strtoint('$'+Edit_ZN_NAME.Text[5]+Edit_ZN_NAME.Text[6]);  //
 m[8]:=strtoint('$'+Edit_ZN_NAME.Text[7]+Edit_ZN_NAME.Text[8]);  //
 // Переход
 if CheckBox15.checked then
 m[9]:= m[9] or $01;
 // Разблокировка при пожаре
 if CheckBox17.checked then
 m[9]:= m[9] or $02;
 // Рег. проход по открыванию
 if CheckBox18.checked then
 m[9]:= m[9] or $04;
 // Режим работы Ручной/Запрос
 case RadioGroup3.ItemIndex of
   02: m[9]:= m[9] or $08;
 end;//case
 // Контроль правил при фиксации
 case ComboBox8.ItemIndex of
   01: m[9]:= m[9] or $10;
 end;//case
 // Режим передачи кодов в ПЭВМ
 case RadioGroup3.ItemIndex of
   03: m[9]:= m[9] or $20;
 end;//case
 // Запрет прохода при нападении
 if CheckBox19.checked then
 m[9]:= m[9] or $40;
end;


procedure TmMain.GetBCP_APParams(var m: array of byte);
var
 v: Longword;
begin
 // Режим прохода
 RadioGroup1.ItemIndex:= m[0] and $01;
 // Идентификация
 ComboBox7.ItemIndex:= (m[0] shr 1) and $03;
 // Режим работы Авто/Запрос
 RadioGroup3.ItemIndex:= byte((m[0] and $08) > 0);
 // Запрет взлома
 CheckBox16.checked:= (m[0] and $10) > 0;
 // Выход по кнопке
 CheckBox13.checked:= (m[0] or $20) > 0;
 // Контроль правил прохода
 ComboBox8.ItemIndex:= byte((m[0] and $40) > 0);
 // Рег. событий
 CheckBox14.checked:= (m[0] or $80) > 0;
 // Дверной код
 v:= m[1] + $100 * m[2] + $10000 * m[3] + $1000000 * m[4];
 Edit5.Text:= IntToStr(v);
 // Переход
 CheckBox15.checked:= (m[9] and $01) > 0;
 // Разблокировка при пожаре
 CheckBox17.checked:= (m[9] and $02) > 0;
 // Рег. проход по открыванию
 CheckBox18.checked:= (m[9] and $04) > 0;
 // Режим работы Ручной/Запрос
 if (m[9] and $08) > 0 then RadioGroup3.ItemIndex:=2;
 // Контроль правил при фиксации
 if ((m[9] and $10)>0) and (ComboBox8.ItemIndex=1) then
 ComboBox8.ItemIndex:= 2;
 // Режим передачи кодов в ПЭВМ
 if (m[9] and $20)>0 then RadioGroup3.ItemIndex:=3;
 // Запрет прохода при нападении
 CheckBox19.checked:= (m[9] and $40) > 0;
end;

procedure TmMain.GetBCP_TermParams(var m: array of byte);
begin
//
end;

procedure TmMain.SetBCP_TermParams(var m: array of byte);
begin
//
end;



procedure TmMain.SetBCP_UserParams(var m: array of byte);
var
 lw: longword;
 //v: Double;
begin
 FillChar(m,128,0);
 m[0]:= byte(CheckBox6.checked) shl 4 + 3;           // flags
 m[0]:= m[0] or (ComboBox23.ItemIndex shl 5);        // flags
 m[1]:= strtoint(copy(ComboBox1.Text, 1, 2));        // l[1]-тип идентификатора
 m[2]:= SpinEdit9.Value;                             // Facility
 m[3]:= lo(SpinEdit19.Value);                        // Card
 m[4]:= hi(SpinEdit19.Value);                        // Card
 lw:= strtoint(Edit9.Text);
 move(lw, m[10], 4);                                 // pincode
 m[14]:= SpinEdit12.Value;                           // AL1
 m[15]:= ComboBox22.ItemIndex;                       // Контроль правил
 m[16]:= lo(SpinEdit20.Value);                       // Номер зоны
 m[17]:= hi(SpinEdit20.Value);                       // --//--
 m[18]:= SpinEdit14.Value;                           // ВЗ доступа к БЦП
 m[19]:= SpinEdit13.Value;                           // AL2
 m[20]:= SpinEdit15.Value;                           // ВЗ пользователя
 {v:= DateEdit1.Date;
 move(v, m[21], 8);}
end;


procedure TmMain.GetBCP_UserParams(var m: array of byte);
begin

end;







procedure TmMain.ClearSCU_SHParams(var m: array of byte);
begin
 FillChar(m, 6, 0);
end;

procedure TmMain.SetSCU_SHParams(var m: array of byte);
begin
 FillChar(m, 6, 0);
 //Быстродействие 70мс
 m[0]:= m[0] or (byte(CheckBox48.Checked) shl 0);
 //Тип ШС
 m[0]:= m[0] or (SCU_SHPage.ActivePageIndex shl 1);
 //Датчик типа «Окно»
 m[0]:= m[0] or (byte(CheckBox47.Checked) shl 4);
 //Привязка к реле 1
 m[0]:= m[0] or (byte(CheckBox49.Checked) shl 5);
 //Привязка к реле 2
 m[0]:= m[0] or (byte(CheckBox40.Checked) shl 6);
 //Привязка к реле 3
 m[0]:= m[0] or (byte(CheckBox44.Checked) shl 7);
 //Тихая тревога
 m[1]:= m[1] or (byte(CheckBox46.Checked) shl 0);
 //Снятие без выхода на ПЦН
 m[1]:= m[1] or (byte(CheckBox54.Checked) shl 1);
 //Режим «Ожидание готовности»
 m[1]:= m[1] or (byte(CheckBox53.Checked) shl 2);
 //Задержка на вход
 m[2]:= SpinEdit59.Value;
 //Задержка на выход
 m[3]:= SpinEdit60.Value;
 //Гр. автоупр.
 m[4]:= m[4] or (SpinEdit63.Value and $03);
 //Ведущий в гр. автоупр.
 m[4]:= m[4] or (byte(CheckBox52.Checked) shl 2);
 //Автовосстановление
 m[4]:= m[4] or (byte(CheckBox51.Checked) shl 3);
 //Круглосуточный режим
 m[4]:= m[4] or (byte(CheckBox36.Checked) shl 4);
 //Контроль обрыва ШС
 m[4]:= m[4] or (byte(CheckBox55.Checked) shl 5);
 //Индикация при снятии
 m[4]:= m[4] or (byte(CheckBox56.Checked) shl 6);
 //Ведомый по готовности
 m[4]:= m[4] or (byte(CheckBox57.Checked) shl 7);
 //Номер ВЗ для автопостановки или снятии
 m[5]:= m[5] or (SpinEdit47.Value and $0F);
 //Постановка по началу ВЗ
 m[5]:= m[5] or (byte(CheckBox58.Checked) shl 4);
 //Снятие по окончанию ВЗ
 m[5]:= m[5] or (byte(CheckBox59.Checked) shl 5);
end;


/////////////////////////////////////////////////////////
procedure TmMain.GetSCU_SHParams(var m: array of byte);
begin
 //Быстродействие 70мс
 //m[0]:= m[0] or (byte(CheckBox48.Checked) shl 0);
 CheckBox48.checked:= (m[0] and $01) > 0;
 //Тип ШС
 //m[0]:= m[0] or (SCU_SHPage.ActivePageIndex shl 1);
 SCU_SHPage.ActivePageIndex:= (m[0] shr 1) and $07;
 //Датчик типа «Окно»
 //m[0]:= m[0] or (byte(CheckBox47.Checked) shl 4);
 CheckBox47.checked:= (m[0] and $10) > 0;
 //Привязка к реле 1
 //m[0]:= m[0] or (byte(CheckBox49.Checked) shl 5);
 CheckBox49.checked:= (m[0] and $20) > 0;
 //Привязка к реле 2
 //m[0]:= m[0] or (byte(CheckBox40.Checked) shl 6);
 CheckBox40.checked:= (m[0] and $40) > 0;
 //Привязка к реле 3
 //m[0]:= m[0] or (byte(CheckBox44.Checked) shl 7);
 CheckBox44.checked:= (m[0] and $80) > 0;

 //Тихая тревога
 //m[1]:= m[1] or (byte(CheckBox46.Checked) shl 0);
 CheckBox46.checked:= (m[1] and $01) > 0;
 //Снятие без выхода на ПЦН
 //m[1]:= m[1] or (byte(CheckBox54.Checked) shl 1);
 CheckBox54.checked:= (m[1] and $02) > 0;
 //Режим «Ожидание готовности»
 //m[1]:= m[1] or (byte(CheckBox53.Checked) shl 2);
 CheckBox53.checked:= (m[1] and $04) > 0;

 //Задержка на вход
 SpinEdit59.Value:= m[2];
 //Задержка на выход
 SpinEdit60.Value:= m[3];

 //Гр. автоупр.
 //m[4]:= m[4] or (SpinEdit63.Value and $03);
 SpinEdit63.Value:= m[4] and $03;
 //Ведущий в гр. автоупр.
 //m[4]:= m[4] or (byte(CheckBox52.Checked) shl 2);
 CheckBox52.checked:= (m[4] and $04) > 0;
 //Автовосстановление
 //m[4]:= m[4] or (byte(CheckBox51.Checked) shl 3);
 CheckBox51.checked:= (m[4] and $08) > 0;
 //Круглосуточный режим
 //m[4]:= m[4] or (byte(CheckBox36.Checked) shl 4);
 CheckBox36.checked:= (m[4] and $10) > 0;
 //Контроль обрыва ШС
 //m[4]:= m[4] or (byte(CheckBox55.Checked) shl 5);
 CheckBox55.checked:= (m[4] and $20) > 0;
 //Индикация при снятии
 //m[4]:= m[4] or (byte(CheckBox56.Checked) shl 6);
 CheckBox56.checked:= (m[4] and $40) > 0;
 //Ведомый по готовности
 //m[4]:= m[4] or (byte(CheckBox57.Checked) shl 7);
 CheckBox57.checked:= (m[4] and $80) > 0;

 //Номер ВЗ для автопостановки или снятии
 //m[5]:= m[5] or (SpinEdit47.Value and $0F);
 SpinEdit47.Value:= m[5] and $0F;
 //Постановка по началу ВЗ
 //m[5]:= m[5] or (byte(CheckBox58.Checked) shl 4);
 CheckBox58.checked:= (m[5] and $10) > 0;
 //Снятие по окончанию ВЗ
 //m[5]:= m[5] or (byte(CheckBox59.Checked) shl 5);
 CheckBox59.checked:= (m[5] and $20) > 0; 
end;



procedure TmMain.SetSCU_RelayParams(var m: array of byte);
var
 i, j: word;
begin
 FillChar(m, 6, 0);
 // Интерфейс
 case strtoint(copy(ComboBox2.Text, 1, 2)) of
   0: m[0]:= 0;
   1: m[0]:= 1;
   2: m[0]:= 2;
   3: m[0]:= 3;
   4: m[0]:= 4;
   5: m[0]:= 5;
   6: m[0]:= 6;
   7: m[0]:= 7;
   8: m[0]:= 8;
   9: m[0]:= 9;
 end;//case
 // Время работы
 m[1]:= SpinEdit11.Value;
 // Время задежки
 m[2]:= SpinEdit18.Value;
 // Время импульса
 m[3]:= SpinEdit8.Value;
 // Время паузы
 m[4]:= SpinEdit6.Value;
 // Инверсный режим
 if CheckBox7.checked then
 m[5]:= m[5] or $01;
 j:=0;
 for i:=0 to 5 do
   j:= j + m[i];
 if j=0 then
   m[5]:= m[5] or $80;
end;


procedure TmMain.GetSCU_RelayParams(var m: array of byte);
begin
 // Интерфейс
 ComboBox2.ItemIndex:= m[0];
 // Время работы
 SpinEdit11.Value:= m[1];
 // Время задежки
 SpinEdit18.Value:= m[2];
 // Время импульса
 SpinEdit8.Value:= m[3];
 // Время паузы
 SpinEdit6.Value:= m[4];
 // Инверсный режим
 CheckBox7.checked:= (m[5] and $01) > 0;
end;



procedure TmMain.SetSCU_USKParams(var m: array of byte);
var
 i: word;
begin
 FillChar(m, 6, 0);
 // Интерфейс
 case strtoint(copy(ComboBox9.Text, 1, 2)) of
   0: m[0]:= 0;
   1: m[0]:= 1;
   2: m[0]:= 2;
   3: m[0]:= 3;
   4: m[0]:= 4;
   5: m[0]:= 5;
 end;//case
 // Идентификатор
 case strtoint(copy(ComboBox10.Text, 1, 2)) of
   0: m[0]:= m[0] or $00;
   1: m[0]:= m[0] or $08;
   2: m[0]:= m[0] or $10;
   3: m[0]:= m[0] or $18;
 end;//case
 // Терминал
 if CheckBox26.checked then
 m[0]:= m[0] or $20;
 // Инверсия
 if CheckBox27.checked then
 m[0]:= m[0] or $40;
 // Переход в авт. режим
 if CheckBox25.checked then
 m[0]:= m[0] or $80;
 // Связанные ШС
 for i:=0 to 5 do
 if CheckListBox1.Checked[i] then
   m[1]:= m[1] or (1 shl i);
 //Таймаут передачи кода
 m[2]:= SpinEdit41.Value;
 // Функция (для БЦП)
 m[3]:= strtoint(copy(ComboBox5.Text, 1, 2));
 m[4]:= 0;
 m[5]:= 0;
end;


procedure TmMain.GetSCU_USKParams(var m: array of byte);
var
 i: word;
begin
 // Интерфейс
 ComboBox9.ItemIndex:= m[0] and $07;
 // Идентификатор
 ComboBox10.ItemIndex:= (m[0] shr 3) and $3;
 // Терминал
 CheckBox26.checked:= (m[0] and $20) > 0;
 // Инверсия
 CheckBox27.checked:= (m[0] and $40) > 0;
 // Переход в авт. режим
 CheckBox25.checked:= (m[0] and $80) > 0;
 // Связанные ШС
 for i:=0 to 5 do
 CheckListBox1.Checked[i]:= (m[1] and (1 shl i)) > 0;
 // Таймаут передачи кода
 SpinEdit41.Value:= m[2];
 // Функция (для БЦП)
 ComboBox5.ItemIndex:= m[3];
end;


procedure TmMain.SetSCU_APParams(var m: array of byte);
begin
 FillChar(m, 14, 0);
 // Вкл./Выкл.
 if CheckBox28.checked then
 m[0]:= m[0] or $01;
 // Тип прохода
 m[0]:= m[0] or (strtoint(copy(ComboBox11.Text, 1, 2)) shl 1);
 // Режим прохода
 m[0]:= m[0] or (strtoint(copy(ComboBox12.Text, 1, 2)) shl 4);
 // УСК двери №1
 m[1]:= m[1] or (strtoint(copy(ComboBox13.Text, 1, 2)) shl 0);
 // УСК двери №2
 m[1]:= m[1] or (strtoint(copy(ComboBox14.Text, 1, 2)) shl 2);
 // УСК двери №3
 m[1]:= m[1] or (strtoint(copy(ComboBox15.Text, 1, 2)) shl 4);
 // Индикация взлома
 if CheckBox23.checked then
 m[1]:= m[1] or $40;
 // Индикация удержания
 if CheckBox22.checked then
 m[1]:= m[1] or $80;
 // Реле двери №1
 m[2]:= m[2] or (strtoint(copy(ComboBox16.Text, 1, 2)) shl 0);
 // Реле двери №2
 m[2]:= m[2] or (strtoint(copy(ComboBox17.Text, 1, 2)) shl 2);
 // ШС кнопки
 m[3]:= m[3] + SpinEdit50.Value shl 0;
 // ШС двери
 m[3]:= m[3] + SpinEdit51.Value shl 3;
 // Контроль удержания
 if CheckBox12.checked then
 m[3]:= m[3] or $40;
 // Контроль взлома
 if CheckBox24.checked then
 m[3]:= m[3] or $80;
 // ШС шлюза
 m[4]:= SpinEdit52.Value;
 // Таймаут прохода (открытия двери) время в шлюзе
 m[5]:= SpinEdit42.Value;
 // Время замка
 m[6]:= SpinEdit48.Value;
 // Время открытия двери
 m[7]:= SpinEdit49.Value;
 // Задержка прохода в шлюзе
 m[8]:= SpinEdit22.Value;
 // Блокир. по ВЗ
 m[9]:= SpinEdit23.Value;
 // Разблокир. по ВЗ
 m[10]:= SpinEdit24.Value;
 // Блок. по всей ВЗ
 if CheckBox21.checked then
 m[11]:= m[11] or $01;
 // Разблок. по всей ВЗ
 if CheckBox29.checked then
 m[11]:= m[11] or $02;
 // Тип регистрации прохода
 m[11]:= m[11] or (strtoint(copy(ComboBox18.Text, 1, 2)) shl 2);
end;

//-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
procedure TmMain.GetSCU_APParams(var m: array of byte);
begin
 // Вкл./Выкл.
 CheckBox28.checked:= (m[0] and $01) > 0;
 // Тип прохода
 ComboBox11.ItemIndex:= (m[0] shr 1) and $07;
 // Режим прохода
 ComboBox12.ItemIndex:= (m[0] shr 4) and $0F;
 // УСК двери №1
 ComboBox13.ItemIndex:= (m[1] shr 0) and $03;
 // УСК двери №2
 ComboBox14.ItemIndex:= (m[1] shr 2) and $03;
 // УСК двери №3
 ComboBox15.ItemIndex:= (m[1] shr 4) and $03;
 // Индикация взлома
 CheckBox23.checked:= (m[1] and $40) > 0;
 // Индикация удержания
 CheckBox22.checked:= (m[1] and $80) > 0;
 // Реле двери №1
 ComboBox16.ItemIndex:= (m[2] shr 0) and $03;
 // Реле двери №2
 ComboBox17.ItemIndex:= (m[2] shr 2) and $03;
 // ШС кнопки
 SpinEdit50.Value:= (m[3] shr 0) and $07;
 // ШС двери
 SpinEdit51.Value:= (m[3] shr 3) and $07;
 // Контроль удержания
 CheckBox12.checked:= (m[3] and $40) > 0;
 // Контроль взлома
 CheckBox24.checked:= (m[3] and $80) > 0;
 // ШС шлюза
 SpinEdit52.Value:= m[4];
 // Таймаут прохода (открытия двери) время в шлюзе
 SpinEdit42.Value:= m[5];
 // Время замка
 SpinEdit48.Value:= m[6];
 // Время открытия двери
 SpinEdit49.Value:= m[7];
 // Задержка прохода в шлюзе
 SpinEdit22.Value:= m[8];
 // Блокир. по ВЗ
 SpinEdit23.Value:= m[9];
 // Разблокир. по ВЗ
 SpinEdit24.Value:= m[10];
 // Блок. по всей ВЗ
 CheckBox21.checked:= (m[11] and $01) > 0;
 // Разблок. по всей ВЗ
 CheckBox29.checked:= (m[11] and $02) > 0;
 // Тип регистрации прохода
 ComboBox18.ItemIndex:= byte ((m[11] and $04) > 0);
end;

procedure TmMain.SetSCU_UserParams(var m: array of byte);
var
 i: word;
 v: LongWord;
begin
 FillChar(m, 22, 0);
 // B649 2039 031D 8404 020A     00 00 0000 0000 FE57 04 01    0000 1B16 0000 0000 0000 0000 00    39 3B48 46
 // Код ключа
 m[5]:= SpinEdit21.Value;
 m[6]:= hi(SpinEdit25.Value);
 m[7]:= lo(SpinEdit25.Value);
 // Тип ключа
 m[8]:= strtoint(copy(ComboBox4.Text, 1, 2));
 // ШС на взятие
 for i:=0 to 5 do
   if CheckListBox2.Checked[i] then
     m[9]:= m[9] or (1 shl i);
 // ШС на снятие
 for i:=0 to 5 do
   if CheckListBox3.Checked[i] then
      m[10]:= m[10] or (1 shl i);
 // Мастер
 if CheckBox3.Checked then
   m[10]:= m[10] or $40;
 // ТД на вход
 for i:=0 to 2 do
   if CheckListBox4.Checked[i] then
     m[11]:= m[11] or (1 shl i);
 // ТД на выход
 for i:=0 to 2 do
   if CheckListBox5.Checked[i] then
      m[11]:= m[11] or (1 shl (i+3));
 // Блокировка
 if CheckBox5.Checked then
   m[11]:= m[11] or $40;
 // ВЗ
 m[12]:= SpinEdit5.Value;
 // ПИН-код
 if length(Edit1.Text)>0 then
 v:= StrToInt(Edit1.Text);
 move (v, m[13], 4);
end;


procedure TmMain.GetSCU_UserParams(var m: array of byte);
var
 i: word;
 v: LongWord;
begin
 // B649 2039 031D 8404 020A     00 00 0000 0000 FE57 04 01    0000 1B16 0000 0000 0000 0000 00    39 3B48 46
 // Код ключа
 SpinEdit21.Value:= m[5];
 SpinEdit25.Value:= 256 * m[6] + m[7];
 // Тип ключа
 ComboBox4.ItemIndex:= m[8];
 // ШС на взятие
 for i:=0 to 5 do
   CheckListBox2.Checked[i]:= ((m[9] shr i) and $01) > 0;
 // ШС на снятие
 for i:=0 to 5 do
   CheckListBox3.Checked[i]:= ((m[10] shr i) and $01) > 0;
 // Мастер
 CheckBox3.Checked:= (m[10] and $40) > 0;
 // ТД на вход
 for i:=0 to 2 do
   CheckListBox4.Checked[i]:= ((m[11] shr i) and $01) > 0;
 // ТД на выход
 for i:=0 to 2 do
   CheckListBox5.Checked[i]:= ((m[11] shr (i+3)) and $01) > 0;
 // Блокировка
 CheckBox5.Checked:= (m[10] and $40) > 0;
 // ВЗ
 SpinEdit5.Value:= m[12];
 // ПИН-код
 move (m[13], v, 4);
 Edit1.Text:= IntToStr(v);
end;


procedure TmMain.SetSCU_HWParams(var m: array of byte);
begin
 //УСК + Допы
 m[0]:= strtoint(copy(ComboBox6.Text, 1, 2));
 //ТД
 m[1]:= SpinEdit28.Value;
 m[2]:= SpinEdit36.Value;
 m[3]:= SpinEdit39.Value;
 m[4]:= SpinEdit38.Value;
 if CheckBox20.Checked then
  m[5]:= m[5] or $01;
 if CheckBox8.Checked then
  m[5]:= m[5] or $02;
 if CheckBox11.Checked then
  m[5]:= m[5] or $04;
 //Инверсия Реле
 if CheckBox33.Checked then
 m[5]:= m[5] or $08;
 //Номер Реле
 m[5]:= m[5] or (ComboBox26.ItemIndex shl 4);
 //Тип ТД
 m[5]:= m[5] or (ComboBox19.ItemIndex shl 6);
end;


procedure TmMain.GetSCU_HWParams(var m: array of byte);
var
 i: word;
begin
 //УСК + Допы
 ComboBox6.ItemIndex:= -1;
 for i:=0 to ComboBox6.Items.Count-1 do
 if strtoint(copy(ComboBox6.Items[i], 1, 2)) = m[0] then
 begin
   ComboBox6.ItemIndex:= i;
   break;
 end;
 //ТД
 SpinEdit28.Value:= m[1];
 SpinEdit36.Value:= m[2];
 SpinEdit39.Value:= m[3];
 SpinEdit38.Value:= m[4];
 CheckBox20.Checked:= (m[5] and $01) > 0;
 CheckBox8.Checked:=  (m[5] and $02) > 0;
 CheckBox11.Checked:= (m[5] and $04) > 0;
 //Инверсия Реле
 CheckBox33.Checked:= (m[5] and $08) > 0;
 //Номер Реле
 ComboBox26.ItemIndex:= (m[5] shr 4) and $03;
 //Тип ТД 
 ComboBox19.ItemIndex:= (m[5] shr 6) and $01;
 //
end;


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure TmMain.RefreshParamStrings;
var
 m: array [0..32] of byte;
 i: word;
 s: String;

begin

 //Обновление MaskEdit_BCP_AP
 SetBCP_APParams(m);
 s:='';
 for i:=0 to 15 do
 begin
   s:= s + IntToHex(m[i],2);
   case i of
     15:;
     else s:= s + '.';
   end;
 end;
 MaskEdit_BCP_AP.Text:= s;
 //Обновление MaskEdit_SCU_SH
 SetSCU_SHParams(m);
 s:='';
 for i:=0 to 5 do
 begin
   s:= s + IntToHex(m[i],2);
   case i of
     5:;
     else s:= s + '.';
   end;
 end;
 MaskEdit_SCU_SH.Text:= s;
 //Обновление MaskEdit_SCU_RELAY
 SetSCU_RelayParams(m);
 s:='';
 for i:=0 to 5 do
 begin
   s:= s + IntToHex(m[i],2);
   case i of
     5:;
     else s:= s + '.';
   end;
 end;
 MaskEdit_SCU_RELAY.Text:= s;
 //Обновление MaskEdit_SCU_USK
 SetSCU_USKParams(m);
 s:='';
 for i:=0 to 5 do
 begin
   s:= s + IntToHex(m[i],2);
   case i of
     5:;
     else s:= s + '.';
   end;
 end;
 MaskEdit_SCU_USK.Text:= s;
 //Обновление MaskEdit_SCU_AP
 SetSCU_APParams(m);
 s:='';
 for i:=0 to 13 do
 begin
   s:= s + IntToHex(m[i],2);
   case i of
     13:;
     else s:= s + '.';
   end;
 end;
 MaskEdit_SCU_AP.Text:= s;
 //Обновление MaskEdit_SCU_USER
 SetSCU_UserParams(m);
 s:='';
 for i:=0 to 21 do
 begin
   s:= s + IntToHex(m[i],2);
   case i of
     21:;
     else s:= s + '.';
   end;
 end;
 MaskEdit_SCU_USER.Text:= s;
 //Обновление MaskEdit_FULLHW
 SetSCU_HWParams(m);
 s:='';
 for i:=0 to 5 do
 begin
   s:= s + IntToHex(m[i],2);
   case i of
     5:;
     else s:= s + '.';
   end;
 end;
 MaskEdit_SCU_HW.Text:= s;
end;

//Не используется
procedure FillString (n: byte; m: array of byte);
var
 i: word;
 s: String;
begin

 s:='';
 for i:=0 to n-1 do
 begin
   s:= s + IntToHex(m[i],2);
   if i<(n-1) then
     s:= s + '.';
 end;
end;


procedure TmMain.Timer1Timer(Sender: TObject);
begin
 RefreshParamStrings;
end;


procedure TmMain.ToolButton6Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_SH.Value;
 FillChar(l,128,0);
 SetSCU_SHParams(l[0]);
 mes.Size:= 6;
 mes.Code:=SCU_SH_EDIT;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton10Click(Sender: TObject);
var
 mes: KSBMES;
begin
 SCU_SHPage.ActivePageIndex:= 0;
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_SH.Value;
 mes.Code:=SCU_SH_GET;
 send(mes);
end;

procedure TmMain.ToolButton68Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Mode:= SpinEdit_SU.Value;
 mes.Level:= SpinEdit_SCU_SH.Value;
 mes.Code:= SCU_TC_RESTORE;
 send(mes);
end;

procedure TmMain.ToolButton69Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Mode:= SpinEdit_SU.Value;
 mes.Level:= SpinEdit_SCU_SH.Value;
 mes.Code:= SCU_SHOCHR_ARM;
 send(mes);
end;

procedure TmMain.ToolButton133Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Mode:= SpinEdit_SU.Value;
 mes.Level:= SpinEdit_SCU_SH.Value;
 mes.Code:= SCU_SHOCHR_DISARM;
 send(mes);
end;

procedure TmMain.ToolButton135Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Mode:= SpinEdit_SU.Value;
 mes.Level:= SpinEdit_SCU_SH.Value;
 mes.Code:= SCU_SHOCHR_RESET;
 send(mes);
end;

procedure TmMain.ToolButton140Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Mode:= SpinEdit_SU.Value;
 mes.Level:= SpinEdit_SCU_SH.Value;
 mes.Code:= SCU_SHTREV_RESET;
 send(mes);
end;

procedure TmMain.ToolButton146Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Mode:= SpinEdit_SU.Value;
 mes.Level:= SpinEdit_SCU_SH.Value;
 mes.Code:= SCU_SHFIRE_RESET;
 send(mes);
end;

procedure TmMain.ToolButton137Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_SH.Value;
 FillChar(l,128,0);
 mes.Size:= 6;
 mes.Code:=SCU_SH_EDIT;
 send(mes, PChar(@l[0]));
end;


procedure TmMain.ToolButton47Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_RELAY.Value;
 FillChar(l,128,0);
 SetSCU_RelayParams(l[0]);
 mes.Size:= 6;
 mes.Code:=SCU_RELAY_EDIT;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton48Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_RELAY.Value;
 mes.Code:=SCU_RELAY_GET;
 send(mes);
end;

procedure TmMain.ToolButton13Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_USK.Value;
 FillChar(l,128,0);
 SetSCU_USKParams(l[0]);
 mes.Size:= 6;
 mes.Code:=SCU_USK_EDIT;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton12Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_USK.Value;
 mes.Code:=SCU_USK_GET;
 send(mes);
end;


procedure TmMain.ToolButton23Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_AP.Value;
 FillChar(l,128,0);
 SetSCU_APParams(l[0]);
 mes.Size:= 14;
 mes.Code:= SCU_AP_EDIT;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton14Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_AP.Value;
 mes.Code:=SCU_AP_GET;
 send(mes);
end;


procedure TmMain.ToolButton34Click(Sender: TObject);
var
 mes: KSBMES;
begin
Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= SpinEdit16.Value;
 mes.BigDevice:= SpinEdit17.Value;
 mes.TypeDevice:= 132;
 data:='';
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', SpinEdit_SU.Value);
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер элемента', SpinEdit_SCU_AP.Value);
 mes.Code:= SCU_AP_PASS;
 send(mes);
end;







procedure TmMain.ToolButton54Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_USER.Value;
 FillChar(l,128,0);
 SetSCU_UserParams(l[0]);
 mes.Size:= 22;
 mes.Code:=SCU_USER_ADD;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton55Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_USER.Value;
 FillChar(l,128,0);
 SetSCU_UserParams(l[0]);
 mes.Size:= 22;
 mes.Code:=SCU_USER_EDIT;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton56Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_USER.Value;
 FillChar(l,128,0);
 mes.Code:=SCU_USER_DELETE;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton50Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_USER.Value;
 FillChar(l,128,0);
 mes.Code:=SCU_USER_GET;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton53Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 FillChar(l,128,0);
 mes.Code:=SCU_USER_GETLIST;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton51Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_USER.Value;
 FillChar(l,128,0);
 SetSCU_UserParams(l[0]);
 mes.Size:= 22;
 mes.Code:=SCU_USER_ADDNOCHECK;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton49Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 FillChar(l,128,0);
 mes.Code:=SCU_USER_DELETE_ALL;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton60Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0 then
 begin
   mes.Mode:= SpinEdit_SU.Value;
   mes.Camera:= mes.Mode;
 end
 else
   mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_HW.Value;
 FillChar(l,128,0);
 SetSCU_HWParams(l[0]);
 mes.Size:= 6;
 mes.Code:=SCU_HW_EDIT;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton61Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 if RadioGroup_ADDR.ItemIndex=0
   then
   begin
     mes.Mode:= SpinEdit_SU.Value;
     mes.Camera:= mes.Mode;
   end
   else
     mes.Mode:= SpinEdit_TC.Value;
 //
 mes.Level:= SpinEdit_SCU_HW.Value;
 mes.Code:=SCU_HW_GET;
 send(mes);
end;




procedure TmMain.ToolButton97Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.CmdTime:=now;
 mes.Code:=R8_COMMAND_SETTIME;
 send(mes);
end;

procedure TmMain.ToolButton98Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_GETTIME;
 send(mes);
end;

procedure TmMain.ToolButton102Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_CLEARSYSERROR;
 send(mes);
end;

procedure TmMain.ToolButton103Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:=R8_COMMAND_STARTCHECKCONFIG;
 send(mes);
end;

procedure TmMain.ToolButton136Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:= R8_COMMAND_BCP_RESET;
 send(mes);
end;

procedure TmMain.ToolButton138Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:= R8_COMMAND_BCP_CONSOLEUNLOCK;
 send(mes);
end;

procedure TmMain.ToolButton141Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:= R8_COMMAND_BCP_DMQCLEARNND;
 send(mes);
end;

procedure TmMain.ToolButton142Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:= R8_COMMAND_BCP_DMQCLEARTCO;
 send(mes);
end;

procedure TmMain.ToolButton153Click(Sender: TObject);
var
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:= R8_COMMAND_BCP_ALLUSERSETSTATE;
 send(mes);
end;

procedure TmMain.ToolButton99Click(Sender: TObject);
var
  mes: KSBMES;
begin
 if MessageBox(0, 'Очистить всю конфигурацию БЦП ?', 'Внимание', MB_OKCANCEL or MB_DEFBUTTON2 or MB_SYSTEMMODAL or MB_ICONQUESTION) = IDOK then
 begin
   Init(mes);
   mes.SysDevice:=SYSTEM_OPS;
   mes.NetDevice:=SpinEdit16.Value;
   mes.BigDevice:=SpinEdit17.Value;
   mes.SmallDevice:=0;
   mes.TypeDevice:=4;
   mes.Code:=R8_COMMAND_CLEAR;
   send(mes);
 end;
end;


procedure TmMain.ToolButton104Click(Sender: TObject);
var
 l: array[0..127] of BYTE;
 mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=8;
 mes.SmallDevice:= SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:=R8_COMMAND_TERM_RESTORE;
 send(mes,PChar(@l[0]));
end;


procedure TmMain.ToolButton128Click(Sender: TObject);
var
 mes : KSBMES;
 l: array[0..127] of BYTE;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=8;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:= R8_COMMAND_TERM_BLOCK;
 send(mes,PChar(@l[0])); 
end;

procedure TmMain.ToolButton132Click(Sender: TObject);
var
 mes : KSBMES;
 l: array[0..127] of BYTE; 
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=8;
 mes.SmallDevice:=SpinEdit_TC.Value;
 TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', SpinEdit_USER_CONTROL.Value);
 mes.Size:=1;
 FillChar(l,128,0);
 l[0]:=byte(CheckBox1_USER_CONTROL.Checked);       // l[0]-проверять ли пользователя
 mes.Code:= R8_COMMAND_TERM_RESET;
 send(mes,PChar(@l[0]));
end;

procedure TmMain.ToolButton108Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=8;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_TERM_ON;
 send(mes);
end;

procedure TmMain.ToolButton109Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=8;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_TERM_OFF;
 send(mes);
end;


procedure TmMain.ToolButton105Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=10;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_AP_ON;
 send(mes);
end;

procedure TmMain.ToolButton106Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=10;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_AP_OFF;
 send(mes);
end;

procedure TmMain.ToolButton111Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=7;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_RELAY_ON;
 send(mes);
end;

procedure TmMain.ToolButton112Click(Sender: TObject);
var
 mes : KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=7;
 mes.SmallDevice:=SpinEdit_TC.Value;
 mes.Code:=R8_COMMAND_RELAY_OFF;
 send(mes);
end;

procedure TmMain.UDdataAfterInsert(DataSet: TDataSet);
begin
 UDdataPermission.Value:= 0;
 UDdataZn.Value:=0;
 UDdataTCtype.Value:=0;
 UDdataGrTC.Value:=0;
 UDdataTimeZn.Value:=255;
 UDdataMapHi.Value:= 0;
 UDdataMapLo.Value:= 0;
 UDdataZnStatus.Value:= 0;
end;


procedure TmMain.ToolButton148Click(Sender: TObject);
var
  mes: KSBMES;
begin
 Init(mes);
 mes.SysDevice:=SYSTEM_OPS;
 mes.NetDevice:=SpinEdit16.Value;
 mes.BigDevice:=SpinEdit17.Value;
 mes.TypeDevice:=4;
 mes.Code:= R8_COMMAND_BCP_VAR_ASSIGN;
 mes.Partion:= SpinEdit_VAR.Value;
 mes.Level:= SpinEdit_VARVALUE.Value;
 send(mes);
end;







END.



