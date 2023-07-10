unit mMini;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, ActnList;

type
  TaMini = class(TForm)
    StatusBar1: TStatusBar;
    StatusBar3: TStatusBar;
    StatusBar2: TStatusBar;
    StatusBar4: TStatusBar;
    StatusBar5: TStatusBar;
    StatusBar6: TStatusBar;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  aMini: TaMini;

implementation

uses mMain, Comm, R8Unit;

{$R *.dfm}

procedure TaMini.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 aMain.MiniMode:= False;
 aMain.Parent:= nil;
 aMain.Left:= left;
 aMain.top:= top;
end;

procedure TaMini.Timer1Timer(Sender: TObject);
begin
  case rub.Online of
    0:
    begin
      StatusBar1.Color:= clRed;
      StatusBar1.Panels[0].Text:='Нет связи';
    end;
    1:
    begin
      StatusBar1.Color:= clBtnFace;
      StatusBar1.Panels[0].Text:='На связи';
    end;
    else
    begin
      StatusBar1.Color:= clBtnFace;
      StatusBar1.Panels[0].Text:='Н/Д';
    end;
  end;//case

  if rub.Online=0 then
  begin
    StatusBar2.Color:= clBtnFace;
    StatusBar2.Panels[0].Text:= 'Н/Д';
  end
  else
    if rub.ErrorCode=$FF then
    begin
      StatusBar2.Color:= clBtnFace;
      StatusBar2.Panels[0].Text:= 'Норма';
    end
    else
    begin
      StatusBar2.Color:= clYellow;
      StatusBar2.Panels[0].Text:= 'Ошибка №' + inttostr(rub.ErrorCode);
    end;
  //
  if not rub.WorkTime then
  begin
    StatusBar3.Color:= clBtnFace;
    StatusBar3.Panels[0].Text:='Старт...';
  end
  else
  begin
    StatusBar3.Color:= clBtnFace;
    StatusBar3.Panels[0].Text:='Норма';
  end;
  //
  StatusBar4.Panels[0].Text:=inttostr(wbcp.TOTALCOUNT);
  StatusBar5.Panels[0].Text:=inttostr(rbcp.TOTALCOUNT);
end;



end.

