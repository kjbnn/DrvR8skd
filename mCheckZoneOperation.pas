unit mCheckZoneOperation;

interface
uses Classes, ExtCtrls;
type

  TZoneOperation=class
    Zone: word;
    Operation: byte;
    Timer: byte;
  end;

  TMyTimer=class(TTimer)
    procedure Tic (Sender: TObject);
  end;

var
  ZoneOperationList: TList;
  ZoneOperationTimer: TMyTimer;

 procedure CheckZoneOperation(Zone: word; Operation: byte);


implementation
uses windows, R8Unit, mMain, SharedBuffer, constants, connection, SCUunit,
  Comm;



procedure CheckZoneOperation(Zone: word; Operation: byte);
var
 i: word;
 zo: TZoneOperation;
 exist: boolean;

begin
 //Поиск в списке lsZoneOperation по зоне нужной TZoneOperation и если нет
 zo:= nil;
 exist:= False;
 if ZoneOperationList.Count>0 then
   for i:=0 to ZoneOperationList.Count-1 do
   begin
     zo:= ZoneOperationList.Items[i];
     if zo.Zone<>Zone then
       continue;
     exist:= True;
     break;
   end;
  //то создать
  if not exist then
  begin
    zo:= TZoneOperation.Create;
    zo.Zone:= Zone;
    zo.Operation:= Operation;
    zo.Timer:= option.ZoneOperationSecInterval;
  end;
  //новая операция
  if zo.Operation<>Operation then
  begin
    zo.Operation:= Operation;
    zo.Timer:= option.ZoneOperationSecInterval;
  end;
end;


procedure TMyTimer.Tic (Sender: TObject);
var
 i, j: word;
 zo: TZoneOperation;
 ptc: ^TTC;
 pcu: PTCU;
 NeedSend: boolean;
 v: ^TMesRec;
 mes: KSBMES;
 l: array[0..127] of Byte;

begin
 //нужно ли
 if option.ZoneOperationSecInterval=0 then
   exit; 
 if ZoneOperationList.Count=0 then
   exit;
 TRY
   //Проход по всему ZoneOperationList
   for i:=0 to ZoneOperationList.Count-1 do
   begin
     zo:= ZoneOperationList.Items[i];
     //еще не время
     if zo.Timer>0 then
       continue;
     //наверно не будет отправки
     NeedSend:= False;
     //По всем ШС-ам зоны
     if rub.TC.Count>0 then
       for j:=0 to rub.TC.Count-1 do
       begin
         ptc:= rub.TC.Items[j];
         if ptc^.PartVista<>zo.Zone then
           continue;
         if (ptc^.Kind<>1) then
           continue;
         if (ptc^.State and $3C)>0 then
           continue;
         if ptc^.ConfigDummy[4]<>0 then
          continue;
         if (zo.Operation=0) and ((ptc^.State and $02)=0) then
           continue;
         if (zo.Operation=1) and ((ptc^.State and $02)>0) then
           continue;
         NeedSend:= True;
         // отправка команды СУ по ШС-у
         Init(mes);
         mes.SysDevice:= SYSTEM_OPS;
         mes.NetDevice:= rub.NetDevice;
         mes.BigDevice:= rub.BigDevice;
         mes.TypeDevice:= 4;
         pcu:= rub.FindCU(65536*ptc^.HWType + ptc^.HWSerial, 0);
         mes.Mode:= pcu^.Number;
         mes.Level:= ptc^.ElementHW;
         FillChar(l,128,0);
         if (zo.Operation=0)
           then mes.Code:= SCU_SHOCHR_ARM
           else mes.Code:= SCU_SHOCHR_DISARM;
         new(v);
         move(mes, v^.m, sizeof(KSBMES));
         v^.s:= Bin2Simbol(PChar(@l[0]), mes.Size);
         case v^.m.Code of
           9801..9999: scu.MesBuf.Add(v);
           else aMain.ConsiderBCP(mes, '');
         end;
       end;
     //Иначе удаляем ZoneOperation из ZoneOperationList
     if not NeedSend then
     begin
       ZoneOperationList.Remove(zo);
       zo.Free;
     end;

// ar[0]:= Zone and $FF;
// ar[1]:= (Zone shr 8) and $FF;
// pzn:= rub.FindZN(ar[0], 1);

   end;

 //Проверка Timer: 0-отправка СУ команды по ШС-ам зоны иначе удаляем ZoneOperation из lsZoneOperation, 1..- dec(Timer)
 //Игнорируются ШС с неисправн, нет связи, откл., 24ч, 2..3типа
 EXCEPT
   aMain.Log( 'Exception(TMyTimer.Tic)' );
 END;
end;

initialization
  ZoneOperationList:= TList.Create;
  ZoneOperationTimer:= TMyTimer.Create(nil);
  ZoneOperationTimer.Enabled:= False;
  ZoneOperationTimer.Interval:= 1000;
  ZoneOperationTimer.OnTimer:= ZoneOperationTimer.Tic;

end.
