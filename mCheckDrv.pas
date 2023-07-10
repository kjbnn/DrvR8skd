unit mCheckDrv;

interface

uses
  Classes;

type
  TCheckDrv = class(TThread)
  private
  protected
    procedure Execute; override;
    procedure WriteExit;
    procedure WriteState;
    procedure Log(str: string);
  end;

const
 LiveTime = 2*60;

var
 LiveCount: array[1..4] of word;
 CheckDrv: TCheckDrv;

implementation

uses mMain, Windows, SysUtils, SCUunit, Comm, Messages, IniFiles,
  connection, DateUtils, R8Unit;


{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure CheckDrv.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ CheckDrv }

procedure TCheckDrv.Execute;
var
  i: byte;
begin
  while True do
  begin
    sleep(1000);
    if (LiveCount[1] + LiveCount[2] + LiveCount[3] + LiveCount[4])>0 then
      WriteState;
    for i:=1 to 4 do
    begin
      if LiveCount[i]=LiveTime then
      begin
        WriteExit;
        break;
      end;
      if LiveCount[i]>LiveTime then
      begin
        PostMessage(aMain.Handle, WM_QUIT, 0, 0);
        break;
      end;
    end;
    inc( LiveCount[1] );
    inc( LiveCount[2] );
    inc( LiveCount[4] );
    if not rbcp.Suspended then
      inc( LiveCount[3] );
  end;
end;


procedure TCheckDrv.WriteState;
var
  s: string;
begin
  s:= Format('rwt=%d, wbcp=%d, rbcp=%d, wrscu=%d', [
          LiveCount[1],
          LiveCount[2],
          LiveCount[3],
          LiveCount[4]  ]);
  Log( s );
end;


procedure TCheckDrv.WriteExit;
begin
  Log( 'Аварийный останов зависшего модуля!!!');
end;


procedure TCheckDrv.Log(str: string);
var
  tf: TextFile;
  SysTime: SYSTEMTIME;
  FileName, OldFileName, CurDir, OldDir, s: string;
  AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond: word;
  hFile, fileSize: Integer;
begin
 FileName:= Format('NET%uBIG%u.state',[rub.NetDevice, rub.BigDevice]);
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
   Insert(s, OldFileName, length(OldFileName)-5);
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
     Format('%u_%.2u.%.2u.%.4u_%.2u:%.2u:%.2u ',
     [LogCount, SysTime.wDay, SysTime.wMonth, SysTime.wYear, SysTime.wHour, SysTime.wMinute, SysTime.wSecond] ) + str
     );
   Flush(tf);
 FINALLY
   CloseFile(tf);
 END;

end;





end.
