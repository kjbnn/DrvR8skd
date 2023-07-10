unit Comm;

interface
uses Classes, windows, Graphics, syncobjs,
     IdUDPBase, IdUDPClient,
     SharedBuffer;

type
 TBuf = array [0..8191] of byte;

 WBCPThread=class(TThread)
  protected
   o: Overlapped;
   mask: DWORD;
   stat: COMSTAT;
   error: DWORD;
   procedure Execute; override;
   procedure DrawWrite;
   procedure Print;
   procedure DrawReceiveEthernet;
  public
   wbuf: TBuf;
   Count: word;
   ev: DWORD;
   TOTALCOUNT: Int64;
   str: string;
  end;

 RBCPThread=class(TThread)
  protected
   o: Overlapped;
   mask: DWORD;
   stat: COMSTAT;
   error: DWORD;
   tCount: DWORD;
   trbuf: TBuf;
   procedure Execute; override;
   procedure Use;
   procedure DrawReceiveCom;
  public
   InBuffer: TBuf;
   InCount: Word;
   rbuf: TBuf;
   RetCode: word;
   ErrorCount: Word;
   TOTALCOUNT: Int64;
  end;

 TCOMPort = class
  public
   h: DWORD;
   mes: string;
   procedure Print;
   constructor Create (port, baud : string);
  end;

 WRSCUThread=class(TThread)
  protected
   Online: boolean;
   procedure Execute; override;
  public
   IdUDPClient: TIdUDPClient;
   wBuf: TBuf;
   rBuf: TBuf;
   wCount: word;
   rCount: word;
   GoodRecive: boolean;
   RetCode: byte;
   LifeLimit: byte;
   //
   cuHWSerial: word;
   cuIP: array [0..3] of byte;
   comd: word;    // режим
   subcomd: word; // подрежим
   TmpCurUser: word; //
   MesBuf: TList; // буфер вх. MesKSB
   mes: KSBMES;
   L, TmpL: array [0..1024] of byte;
   sh, ap, usk, zn, rel, us, tzn, ud, elm: word;
   stm : TDateTime;
   data: PChar;
   sLog: String;
   //
   procedure DrawRead;
   procedure DrawWrite;
   procedure Log;
   procedure Write;
   procedure Read;
  end;



procedure InitBCPComm;
procedure InitSCUComm;


var
 cport: TCOMPort;
 eport: TIdUDPClient;
 wbcp: WBCPThread;
 rbcp: RBCPThread;
 scu: WRSCUThread;

implementation
uses  SysUtils, mmain, connection, R8Unit, SCUunit,
  constants, Messages, Forms, mCheckDrv;

//--------------------------
//  Б Ц П   Р У Б Е Ж - 0 8
//--------------------------
procedure InitBCPComm;
begin
 if rub.ComPort<>'' then
 begin
   cport:= TCOMPort.Create(rub.ComPort, inttostr(rub.ComBaud));
 end
 else
 begin
   eport:= TIdUDPClient.Create(nil);
   eport.ReceiveTimeout:= 500; //500-по умолчанию
   eport.Host:= rub.IP;
   eport.Port:= rub.Port;
 end;
 //
 rbcp:= RBCPThread.Create(true);
 wbcp:= WBCPThread.Create(true);
 wbcp.ev:= CreateEvent(nil, false, false, nil);
 if cport<>nil then
 begin
   wbcp.o.hEvent:= CreateEvent(nil,true,false,nil);
   rbcp.o.hEvent:= CreateEvent(nil,true,false,nil);
 end;
 rbcp.InCount:= 0;
 rbcp.ErrorCount:= 0;
 wbcp.Resume;
 if cport<>nil then
   rbcp.Resume;
end;


constructor TCOMPort.Create (port, baud : string);
var
 dcb : TDCB;
begin
 h:=CreateFile(PChar('\\.\'+port), GENERIC_READ or GENERIC_WRITE ,0,nil,OPEN_EXISTING,FILE_FLAG_OVERLAPPED,0); //изм7.4
 //
 if(h=INVALID_HANDLE_VALUE) then
   Raise Exception.Create ('Ошибка открытия ' + port);
 if not SetupComm(h,4096,4096) then
   Raise Exception.Create ('Ошибка открытия ' + port);
 //
 GetCommState(h,dcb);
 BuildCommDCB(PChar('baud='+ baud + ' parity=N data=8 stop=1'),dcb);
 SetCommState(h,dcb);
 SetCommMask(h,EV_RXCHAR or EV_ERR{ or EV_TXEMPTY});
 PurgeComm(h,PURGE_TXABORT+PURGE_TXCLEAR+PURGE_RXABORT+PURGE_RXCLEAR);
end;


procedure TCOMPort.Print;  // Отладочная
begin
 exit;
 aMain.Log(cport.mes);
end;


procedure WBCPThread.DrawWrite;
var
 st: string;
 i: word;
begin
TRY
 if GraphicScannerHandle>0 then
   DrawGraphicScanner(wbuf, wbcp.Count, clRed);
 if Option.Logged_OnWriteBCP then
 begin
   st:='Logged_OnWriteBCP: ';
   for i:=0 to wbuf[5]+7 do
   st:= st+inttohex(wbuf[i],2){ + '-'};
   aMain.Log(st);
 end;
EXCEPT
 aMain.Log('WThread.DrawWrite');
END;
end;

procedure WBCPThread.Print;
begin
  aMain.Log(str);
end;


procedure WBCPThread.DrawReceiveEthernet;
begin
TRY
 if GraphicScannerHandle>0 then
   DrawGraphicScanner(rbcp.trbuf, rbcp.tCount, clLime);
EXCEPT
 aMain.Log('WThread.DrawReceiveEthernet');
END;
end;


procedure RBCPThread.DrawReceiveCom;
begin
TRY
 if GraphicScannerHandle>0 then
   DrawGraphicScanner(trbuf, tCount, clLime);
EXCEPT
 aMain.Log('RThread.DrawReceiveCom');
END;
end;

//----------------------------------------------------------------------------
procedure WBCPThread.Execute;
var
  i: DWORD;
  ksum: word;
  j: word;
begin

 while true do
 begin

 TRY
   LiveCount[2]:= 0;
   QueryPerformanceFrequency(_f.QuadPart);
   QueryPerformanceCounter(_c5.QuadPart);
   //str:= 'EPORT_1'; Synchronize(Print);
   WaitForSingleObject(wbcp.ev, INFINITE);
   //str:= 'EPORT_2'; Synchronize(Print);
   //
   inc(TOTALCOUNT);
   Synchronize(DrawWrite);
   //
   if cport<>nil then
   begin
     i:= 0;
     ClearCommError(cport.h,error,@stat);
     if(WriteFile(cport.h, wbuf, wbcp.Count, i, @o)=false) then
     if GetLastError<>ERROR_IO_PENDING then
     begin
       cport.mes:='WriteFile';
       Synchronize(cport.Print);
     end;
   end
   else
   begin
     try
       //str:= 'EPORT_3'; Synchronize(Print);
       eport.SendBuffer(wbuf, wbcp.Count);
       //rbcp.tCount:= eport.ReceiveBuffer(rbcp.trbuf, eport.BufferSize);
       //str:= 'EPORT_4'; Synchronize(Print);
       if TRUE{wbuf[6]<>$8e} then
       begin
         FillChar(rbcp.trbuf, 255, 0);
         rbcp.tCount:= eport.ReceiveBuffer(rbcp.trbuf, eport.BufferSize);
         str:='';
         for j:= 0 to 19 do
           str:= str + inttohex(rbcp.trbuf[j], 2);
         //str:= 'EPORT_4.1 rbcp.tCount = ' + IntToStr(rbcp.tCount) + ' >>' + str; Synchronize(Print);
       end
       else
       begin
         rbcp.tCount:= 0;
         FillChar(rbcp.trbuf,255,0);
         FillChar(rbcp.InBuffer,255,0);
         //str:= 'EPORT_4.2'; Synchronize(Print);
         {eport.Active:= False;
         Application.ProcessMessages;
         eport.Active:= True;}
       end;
     except
       aMain.WriteLog( Format( 'WBCPThread.Execute.eport', [] ) );
     end;
     Synchronize(DrawReceiveEthernet);
     if rbcp.tCount=0 then
       continue;
     move (rbcp.trbuf, rbcp.InBuffer[rbcp.InCount], rbcp.tCount);
     rbcp.InCount:= rbcp.InCount + rbcp.tCount;
     if rbcp.InCount>500 then
       aMain.Log('InCount='+inttostr(rbcp.InCount)); //////
     if (rbcp.InCount<15)or(rbcp.RBuf[0]<>0) then
       continue;
     if (rbcp.InBuffer[0]<>$b9)or(rbcp.InBuffer[1]<>$46)or(rbcp.InBuffer[5]=0) then
       continue;
     ksum:=kc(rbcp.InBuffer[0], rbcp.InBuffer[5]+6);
     // Удачная телеграмма
     if (rbcp.InBuffer[rbcp.InBuffer[5]+6+0]=lo(ksum))and(rbcp.InBuffer[rbcp.InBuffer[5]+6+1]=hi(ksum)) then
     begin
       move(rbcp.InBuffer[0], rbcp.rbuf, rbcp.InBuffer[5]+6+2); // копирование телеграммы
       rbcp.RetCode:= rbcp.rbuf[11] + 256 * rbcp.rbuf[12];
       FillChar(rbcp.InBuffer,255,0);
       rbcp.InCount:= 0;
       inc(rbcp.TOTALCOUNT);
     end;
   end; //elseif
   if not Option.Logged_Delay then
     continue;
   QueryPerformanceCounter(_c6.QuadPart);
   aMain.Log('WThread.Execute : '+FloatToStr((_c6.QuadPart-_c5.QuadPart)/_f.QuadPart));
  EXCEPT
    On E: Exception do
    begin
      aMain.WriteLog( Format( 'Заверение работы!!! Ошибка потока БЦП. %s', [E.Message] ) );
      PostMessage(aMain.Handle, WM_QUIT, 0, 0);
    end;
  END;

  end;//while
end;

//----------------------------------------------------------------------------
procedure RBCPThread.Execute;
var
 t: DWORD;

begin
 TRY
   while true do
   begin
     //
     LiveCount[3]:= 0;
     sleep(50);
     QueryPerformanceFrequency(_f.QuadPart);
     QueryPerformanceCounter(_c7.QuadPart);
     //
     ClearCommError(cport.h,error,@stat);
     if WaitCommEvent(cport.h,mask,@o) then
     begin
       cport.mes:='now='+inttostr(mask); Synchronize(cport.Print);
       Use;
     end
     else
     begin
       t:=GetLastError;
       if t<>ERROR_IO_PENDING then
       begin
         cport.mes:= 'Error='+inttostr(t)+' M='+inttostr(mask);
         Synchronize(cport.Print);
       end;
       if WaitForSingleObject(o.hEvent, INFINITE)=WAIT_OBJECT_0 then
       begin
         cport.mes:='background M='+inttostr(mask);
         Synchronize(cport.Print);
         Use;
         ResetEvent(o.hEvent);
       end;
     end;
     //
     if not Option.Logged_Delay then
       continue;
     QueryPerformanceCounter(_c8.QuadPart);
     aMain.Log('RThread.Execute : '+FloatToStr((_c8.QuadPart-_c7.QuadPart)/_f.QuadPart));
   end; //while

 EXCEPT
   On E: Exception do
   begin
     aMain.WriteLog( Format( 'Заверение работы!!! Ошибка потока чтения COM порта БЦП. %s', [E.Message] ) );
     PostMessage(aMain.Handle, WM_QUIT, 0, 0);
   end;
 END;
end;

//----------------------------------------------------------------------------
procedure RBCPThread.Use();
var
 i, ksum, del0: word;
begin
 if((mask and EV_ERR)>0) then
 begin
   ClearCommError(cport.h,error,@stat);
   Inc(ErrorCount);
   PurgeComm(cport.h, PURGE_RXABORT);
   aMain.Log('ErrorCount='+inttostr(ErrorCount));
 end;

 if((mask and EV_TXEMPTY)>0) then
 begin
   //
 end;

 if((mask and EV_RXCHAR)>0) then
 begin
   ClearCommError(cport.h,error,@stat);
   if(ReadFile(cport.h,trbuf,stat.cbInQue,tCount,@o)=false) then
   begin
     cport.mes:='ReadFile';
     Synchronize(cport.Print);
   end;
   if tCount=0 then
     exit;
   Synchronize(DrawReceiveCom);

   //вырезание 0 vvv
   del0:= 0;
   for i:=1 to tCount do
   begin
     if (del0+i)>tCount then
       break;
     if (rub.wasB9B6=1)and(trbuf[i-1]=0) then
     begin
       if i<tCount then
         move(trbuf[i], trbuf[i-1], tCount-i);
       inc(del0);
     end;
     if (trbuf[i-1]=$b6)or(trbuf[i-1]=$b9)
       then rub.wasB9B6:=1
       else rub.wasB9B6:=0;
   end;
   tCount:=tCount-del0;
   //вырезание 0 ^^^

   move (trbuf, InBuffer[InCount], tCount);
   InCount:=InCount+tCount;
   if InCount>500 then
     aMain.Log('InCount='+inttostr(InCount));
   if (InCount<15)or(RBuf[0]<>0) then
     exit;
   if (InBuffer[0]<>$b9)or(InBuffer[1]<>$46)or(InBuffer[5]=0) then
     exit;
   //
   ksum:=kc(InBuffer[0],InBuffer[5]+6);
   // Удачная телеграмма
   if (InBuffer[InBuffer[5]+6+0]=lo(ksum))and(InBuffer[InBuffer[5]+6+1]=hi(ksum)) then
   begin
     move(InBuffer[0], rbuf, InBuffer[5]+6+2); // копирование телеграммы
     RetCode:= rbuf[11] + 256 * rbuf[12];
     FillChar(InBuffer,255,0);
     InCount:= 0;
     inc(TOTALCOUNT);
   end;

 end;
end;


//---------------
//  С К У - 0 2
//---------------
procedure InitSCUComm;
begin
 scu:= WRSCUThread.Create(true);
 scu.Online:= false;
 scu.cuHWSerial:= 0;
 scu.comd:= 0;
 scu.MesBuf:= TList.Create;
 scu.IdUDPClient:= TIdUDPClient.Create(nil);
 scu.IdUDPClient.ReceiveTimeout:= 3000;
 scu.IdUDPClient.Port:= option.SCUPort;
 scu.Resume;
end;


procedure WRSCUThread.DrawRead;
var
 st: string;
 i: word;
begin
TRY
 if GraphicScannerHandle>0 then
   DrawGraphicScanner(rbuf, rCount, clYellow);
 if Option.Logged_OnReadSCU then
 begin
   st:='OnReadSCU: ';
   for i:=0 to rbuf[5]+7 do
     st:= st+inttohex(rbuf[i],2);
   aMain.Log(st);
 end;
EXCEPT
 aMain.Log('WRSCUThread.DrawRead');
END;
end;


procedure WRSCUThread.DrawWrite;
var
 st: string;
 i: word;
begin
TRY
 if GraphicScannerHandle>0 then
   DrawGraphicScanner(wbuf, wCount, $00FF88FF);
 if Option.Logged_OnWriteSCU then
 begin
   st:='Logged_OnWriteSCU: ';
   for i:=0 to wbuf[5]+7 do
     st:= st+inttohex(wbuf[i],2);
   aMain.Log(st);
 end;
EXCEPT
 aMain.Log('WRSCUThread.DrawWrite');
END;
end;


procedure WRSCUThread.Log;
begin
 aMain.Log(slog);
end;

procedure WRSCUThread.Write;
begin
 SCUWRITE (self);
end;

procedure WRSCUThread.Read;
begin
 SCUREAD (self);
end;



procedure WRSCUThread.Execute;
var
  ksum : word;
  st: String;
  i: word;
begin
 //
 while true do
 begin
   LiveCount[4]:= 0;
   sleep(option.SCULineSpeed);
   FillChar(wBuf, 255, 0);
   FillChar(rBuf, 255, 0);
   wCount:= 0;
   rCount:= 0;
   //
   TRY
   // формирование отправляемой телеграммы
     try
       //SCUWRITE (self); //вместо этого Synchronize
       Synchronize(Write);
     except
       sLog:= 'Exception: SCUWRITE';
       Synchronize(Log);
     end;
   if (wBuf[0]=0) then
     continue;
   IdUDPClient.Host:= inttostr(cuIP[0]) + '.'
     + inttostr(cuIP[1]) +'.'
     + inttostr(cuIP[2]) +'.'
     + inttostr(cuIP[3]);

   // Отправка-прием
   GoodRecive:= False;
   wCount:= wBuf[5]+8;
   Synchronize(DrawWrite);
   try
     IdUDPClient.SendBuffer(wBuf, wCount);
     rCount:= IdUDPClient.ReceiveBuffer(rBuf, IdUDPClient.BufferSize);
   except
     sLog:= 'Exception: WRSCUThread.Execute.SendBuffer_ReceiveBuffer';
     Synchronize(Log);
   end;
   Synchronize(DrawRead);

   // Проверка принятой телеграммы
   if (rCount>=11) then
   if (rBuf[0]=$b9) then
   if (rBuf[1]=$46) then
   if (rBuf[5]<>0) then
   begin
     ksum:=kc(rBuf[0], rBuf[5]+6);
     if (rBuf[rBuf[5]+6+0]=lo(ksum))and(rBuf[rBuf[5]+6+1]=hi(ksum)) then
     begin
       //Удачная телеграмма
       aMain.Edit1.Text:= inttohex(rbuf[6], 2);
       aMain.Edit2.Text:= inttohex(rbuf[7], 2);
       RetCode:= rbuf[8];
       aMain.Edit3.Text:= inttohex(RetCode, 2);
       GoodRecive:= True;
       try
         //SCUREAD (self);
         Synchronize(Read);
       except
         On E: Exception do
         begin
           st:='';
           for i:=0 to rBuf[5]+7 do
           case i of
             6,8: st:= st + '-';
             else st:= st + '.';
           end;
           sLog:= 'OnReadSCUException (' + E.Message + ') ' + st;
           Synchronize(Log);
         end;
       end;//try
       
     end;
   end;

   // Ошибка приема   + ДОБАВИТЬ УСЛОВИЕ, ЧТО ЭТО НЕ РЕЖИМ ЛОК. УПРАВЛЕНИЯ. !!!???
   if (rCount=0) then
   begin
     sLog:= Format('Ошибка приема. СУ не отвечает...', [] );
     if LifeLimit>0 then
       sLog:= sLog + Format(' Попыток повтора передачи %d', [LifeLimit] );
     Synchronize(Log);
     aMain.SmartCUSend (mes.SmallDevice, SCU_NOTANSWER);
     if LifeLimit>0 then
     begin
       dec(LifeLimit);
       dec(Subcomd);
     end
     else
       comd:= 0;
   end
   else
   if not GoodRecive then
   begin
     sLog:= 'Ошибка приема. Принято '+ IntToStr(rCount)+' байт...';
     Synchronize(Log);
     aMain.SmartCUSend (mes.SmallDevice, SCU_INCORRECTANSWER);
     comd:= 0;
   end;

   EXCEPT
     On E: Exception do
     begin
       sLog:= Format( 'Заверение работы!!! Ошибка потока СКУ-02. %s', [E.Message] );
       Synchronize(Log);
       PostMessage(aMain.Handle, WM_QUIT, 0, 0);
     end;
   END;

 end; // while

   {
   case WaitForSingleObject(ev, 1000) of
     WAIT_TIMEOUT: comd:=0;
     WAIT_OBJECT_0: comd:=0;
     WAIT_ABANDONED: comd:=0;
     WAIT_FAILED: comd:=0;
   end;
   }

end;




//---------------





end.

