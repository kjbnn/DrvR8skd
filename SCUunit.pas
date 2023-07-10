unit SCUunit;

interface
uses
  windows;

procedure SCUWRITE(p: pointer);
procedure SCUREAD (p: pointer);
function DescriptionSCURetCode(Code: word): string;

procedure Tlg_GetDevVer;
procedure Tlg_GetBootVer;
procedure Tlg_GetPrgData;
procedure Tlg_GetStateWord;
procedure Tlg_GetDevState;
procedure Tlg_GetAltDevState;
procedure Tlg_GetParamArray;

procedure Tlg_SetSH(Number: byte);
procedure Tlg_GetSH(Number: byte);
procedure Tlg_SetRelay(Number: byte);
procedure Tlg_GetRelay(Number: byte);
procedure Tlg_SetUSK(Number: byte);
procedure Tlg_GetUSK(Number: byte);
procedure Tlg_SetAP(Number: byte);
procedure Tlg_GetAP(Number: byte);

procedure Tlg_GetTime;
procedure Tlg_SetTime;
procedure Tlg_GetNetWork;
procedure Tlg_SetNetWork(var param: array of byte);

procedure Tlg_TC_Control(Control, Element: word);

procedure Tlg_User_Add(Number: word);
procedure Tlg_User_Edit(Number: word);
procedure Tlg_User_Delete(Number: word);
procedure Tlg_User_DeleteAll;
procedure Tlg_User_Get(Number: word);
procedure Tlg_User_GetList;
procedure Tlg_User_AddNoCheck(Number: word);


implementation

uses Comm, mMain, R8Unit, SysUtils, constants, SharedBuffer, connection, cMainKsb,
  KSBParam;

//----------------------------
// Суть - подготовить wBuf очередной команды в СКУ
// 1. Определяется comd:
//      0: извлечение вх.KSBMes
//      1: список пользователей
//      2: Set каждого HW параметра СКУ
// 2. Если что-то не так, то выход с результатом wbuf[0]=0
//----------------------------
procedure SCUWRITE(p: pointer);
type
 TScuParam=record
   Obj: word;
 end;

var
 scu: WRSCUThread;
 v: ^TMesRec;
 pcu: PTCU;
 ptc: PTTC;
 s, st: string;
 ScuParam: TScuParam;
 pus: PTUS;
 int: integer;

begin
 scu:= p;
 with scu do begin

 TRY

 case comd of

   0: //анализ вх.KSBMes буфера и лок. команды
   begin
     cuHWSerial:= 0;
     FillChar(cuIP, 4, 0);
     FillChar(mes, sizeof(KSBMES), 0);
     FillChar(L, 1024, 0);
     //
     if (MesBuf.Count>0) then
     begin
       v:= MesBuf.Items[0];
       ptc:= nil;
       //
       case v.m.TypeDevice of
         2, 4, 10:
         begin
           if (v.m.Mode<>v.m.Camera) then
           begin //адресация по ТД
             ptc:= rub.FindTC(v.m.Mode, 9);
             if ptc<>nil then
               pcu:= rub.FindCU(65536*ptc^.HWType + ptc^.HWSerial, 0);
           end
           else //адресация по СУ
             pcu:= rub.FindCU(v.m.Mode, 1);
           //
           if pcu<>nil then
             if PTCU(pcu)^.HWType=$20 then
             begin
               cuHWSerial:= pcu^.HWSerial;
               cuIP[0]:= pcu^.ConfigDummy[2];
               cuIP[1]:= pcu^.ConfigDummy[3];
               cuIP[2]:= pcu^.ConfigDummy[4];
               cuIP[3]:= pcu^.ConfigDummy[5];
               if ptc=nil
                 then ScuParam.Obj:= v.m.Level
                 else case ptc^.Kind of
                   1..4: ScuParam.Obj:= ptc^.ElementHW;
                   5: ScuParam.Obj:= ptc^.ElementHW - 6;
                   6: ScuParam.Obj:= ptc^.ElementHW - 9;
                 end;
             end;
         end;//4
         132:
         begin
           cuHWSerial:= StrToInt(aMain.VLE1.Values['Серийный номер']);
           st:= aMain.VLE1.Values['IP адрес'];
           cuIP[0]:= StrToInt(Copy(st, 1, 3));
           cuIP[1]:= StrToInt(Copy(st, 5, 3));
           cuIP[2]:= StrToInt(Copy(st, 9, 3));
           cuIP[3]:= StrToInt(Copy(st, 13, 3));
           ScuParam.Obj:= StrToInt(aMain.VLE1.Values['Объект']);
         end;//132
       end;//case
       //
       move(v.m, mes, sizeof(KSBMES));
       Simbol2Bin(v.s, @L[0], v.m.Size);
       data:='';
       sh:= ScuParam.Obj;
       ap:= ScuParam.Obj;
       usk:= ScuParam.Obj;
       rel:= ScuParam.Obj;
       us:= ScuParam.Obj;
       stm:=TheKSBParam.ReadDoubleParam (mes, data, 'Время');
       //
       MesBuf.Delete(0);
       Dispose(v);
     end
     else
       exit; //if (MesBuf.Count>0)
     //
     if (mes.Code=0)or(cuHWSerial=0)or(cuIP[0]=0) then
       exit;
     //
     //
     {
     s:= Format('Начало работы со СКУ-02 [Зав.№%d, IP %d.%d.%d.%d] TypeDevice=%d, Mode=%d, Camera=%d',
                 [ cuHWSerial, cuIP[0], cuIP[1], cuIP[2], cuIP[3], mes.TypeDevice, mes.Mode, mes.Camera ]);
     amain.Log( s );
     }
     s:= '';
     LifeLimit:= 0;

     case mes.Code of

       // системные запросы
       SCU_GET_DEVVER:
       begin
         s:='Запрос версии';
         Tlg_GetDevVer;
       end;

       SCU_GET_BOOTVER:
       begin
         s:='Запрос версии загрузчика';
         Tlg_GetBootVer;
       end;

       SCU_GET_STATEWORD:
       begin
         s:='Запрос словосостояния';
         Tlg_GetStateWord;
       end;

       SCU_GET_DEVSTATE:
       begin
         s:='Запрос состояния';
         Tlg_GetDevState;
       end;

       SCU_GET_ALTDEVSTATE:
       begin
         s:='Альтернативная команда запроса состояния';
         Tlg_GetAltDevState;
       end;

       SCU_GET_PARAMARRAY:
       begin
         s:= 'Запрос массива технологических параметров';
         Tlg_GetParamArray;
       end;

       SCU_TIME_GET:
       begin
         s:= 'Запрос времени';
         Tlg_GetTime;
       end;

       SCU_TIME_EDIT:
       begin
         s:= 'Установка времени';
         Tlg_SetTime;
       end;

       SCU_NETWORK_GET:
       begin
         s:= 'Запрос сетевых настроек';
         Tlg_GetNetWork;
       end;

       SCU_NETWORK_EDIT:
       begin
         s:= 'Изменение сетевых настроек';
         l[0]:= $0d;
         st:= aMain.VLE1.Values['Новый IP адрес'];
         l[1]:= StrToInt(Copy(st, 1, 3));
         l[2]:= StrToInt(Copy(st, 5, 3));
         l[3]:= StrToInt(Copy(st, 9, 3));
         l[4]:= StrToInt(Copy(st, 13, 3));
         st:= aMain.VLE1.Values['Новая маска'];
         l[5]:= StrToInt(Copy(st, 1, 3));
         l[6]:= StrToInt(Copy(st, 5, 3));
         l[7]:= StrToInt(Copy(st, 9, 3));
         l[8]:= StrToInt(Copy(st, 13, 3));
         st:= aMain.VLE1.Values['Новый шлюз'];
         l[9]:= StrToInt(Copy(st, 1, 3));
         l[10]:= StrToInt(Copy(st, 5, 3));
         l[11]:= StrToInt(Copy(st, 9, 3));
         l[12]:= StrToInt(Copy(st, 13, 3));
         l[13]:= $FF;
         l[14]:= $FF;
         l[15]:= $FF;
         l[16]:= $FF;
         Tlg_SetNetWork(l[0]);
       end;

       SCU_PRG_DATA:
       begin
         s:= 'Прошивка';
         Tlg_GetPrgData;
       end;

       // Редактирование/запрос объектов
       SCU_SH_EDIT:
       begin
         s:= 'Редактирование ШС №' + inttostr(sh);
         Tlg_SetSH(sh);
       end;

       SCU_SH_GET:
       begin
         s:= 'Запрос ШС №' + inttostr(sh);
         Tlg_GetSH(sh);
       end;

       SCU_RELAY_EDIT:
       begin
         s:= 'Редактирование реле №' + inttostr(rel);
         Tlg_SetRelay(rel);
       end;

       SCU_RELAY_GET:
       begin
         s:= 'Запрос реле №' + inttostr(rel);
         Tlg_GetRelay(rel);
       end;

       SCU_USK_EDIT:
       begin
         s:= 'Редактирование УСК №' + inttostr(usk);
         Tlg_SetUSK(usk);
       end;

       SCU_USK_GET:
       begin
         s:= 'Запрос УСК №' + inttostr(usk);
         Tlg_GetUSK(usk);
       end;

       SCU_AP_EDIT:
       begin
         s:= 'Редактирование ТД №' + inttostr(ap);
         Tlg_SetAP(ap);
       end;

       SCU_AP_GET:
       begin
         s:= 'Запрос ТД №' + inttostr(ap);
         Tlg_GetAP(ap);
       end;

       SCU_USER_ADD:
       begin
         s:= 'Добавление пользователя №' + inttostr(us);
         Tlg_User_Add(us);
       end;

       SCU_USER_EDIT:
       begin
         s:= 'Редактирование пользователя №' + inttostr(us);
         Tlg_User_Edit(us);
       end;

       SCU_USER_DELETE:
       begin
         s:= 'Удаление пользователя №' + inttostr(us);
         Tlg_User_Delete(us);
       end;

       SCU_USER_DELETE_ALL:
       begin
         s:= 'Удаление всех пользователей';
         Tlg_User_DeleteAll;
       end;

       SCU_USER_GET:
       begin
         s:= 'Запрос пользователя №' + inttostr(us);
         Tlg_User_Get(us);
       end;

       SCU_USER_GETLIST:
       begin
         s:= 'Запрос всех пользователей';
         comd:= 1;
         TmpCurUser:= $FFFF;
       end;

       SCU_USER_ADDNOCHECK:
       begin
         s:= 'Добавление пользователя №' + inttostr(us) + ' без проверки';
         Tlg_User_AddNoCheck(us);
       end;

       SCU_CARD_ADD:
       begin
         s:= 'Добавление карты №' + inttostr(us);
         Tlg_User_Add(us);
       end;

       SCU_CARD_DELETE:
       begin
         s:= 'Удаление карты №' + inttostr(us);
         Tlg_User_Delete(us);
       end;

       // Управление
       SCU_TC_RESTORE:
       begin
         s:= Format('Восстановить ТС №%d', [ScuParam.Obj]);
         Tlg_TC_Control($8302, ScuParam.Obj);
       end;

       SCU_SHOCHR_ARM:
       begin
         s:= Format('Взять ШС №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0101, ScuParam.Obj);
       end;

         SCU_SHOCHR_DISARM:
       begin
         s:= Format('Снять ШС №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0102, ScuParam.Obj);
       end;

       SCU_SHOCHR_RESET:
       begin
         s:= Format('Сбросить охранный ШС №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0103, ScuParam.Obj);
       end;

       SCU_SHTREV_RESET:
       begin
         s:= Format('Сбросить тревожный ШС №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0201, ScuParam.Obj);
       end;

       SCU_SHFIRE_RESET:
       begin
         s:= Format('Сбросить пожарный ШС №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0301, ScuParam.Obj);
       end;

       SCU_RELAY_1:
       begin
         s:= Format('Включить реле №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0501, ScuParam.Obj);
       end;

       SCU_RELAY_0:
       begin
         s:= Format('Выключить реле №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0502, ScuParam.Obj);
       end;

       SCU_AP_PASS:
       begin
         s:= Format('Открыть ТД №%d для прохода', [ScuParam.Obj]);
         Tlg_TC_Control($0602, ScuParam.Obj);
       end;

       SCU_AP_LOCK:
       begin
         s:= Format('Заблокировать ТД №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0603, ScuParam.Obj);
       end;

       SCU_AP_UNLOCK:
       begin
         s:= Format('Разблокировать ТД №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0604, ScuParam.Obj);
       end;

       SCU_AP_RESET:
       begin
         s:= Format('Сбросить ТД №%d', [ScuParam.Obj]);
         Tlg_TC_Control($0605, ScuParam.Obj);
       end;

       // Допы
       SCU_INCORRECTANSWER,
       SCU_NOTANSWER:
       begin
       end;

       SCU_HW_EDIT:
       begin
         s:= Format('Редакировать HW-конфигурацию №%d', [ScuParam.Obj]);
         move(l, TmpL, sizeof(l));
         case ((TmpL[5] shr 6) and 1) of
           0: comd:= 2; //HW1 - одиночная дверь    //Убрать исправление!!!
           1: comd:= 4; //HW2 - Вх.Вых             //Убрать исправление!!!
           else comd:= 0;
         end;
         Subcomd:= 0;
       end;

       SCU_HW_GET:
       begin
         s:= Format('Запрос HW-конфигурации №%d', [ScuParam.Obj]);
         comd:= 5; //HW2
         Subcomd:= 0;
       end;

       SCU_HW_EDITED,
       SCU_HW://Реагировать не нужно
       begin
         comd:= 0;
         Subcomd:= 0;
       end;

       SCU_USERMAP_WR_PERMIT://Реагировать не нужно
       begin
         s:= Format('Старт записи разрешенных пользователей из *.scu в прибор. Длительность около 1 минуты.', []);
         comd:= 11;
         Subcomd:= 0;
         LifeLimit:= 3;
       end;

       SCU_USERMAP_WR_ALL://Реагировать не нужно
       begin
         s:= Format('Старт записи всех пользователей из *.scu в прибор. Длительность около 1 минуты.', []);
         comd:= 12;
         Subcomd:= 0;
         LifeLimit:= 3;
       end;

       //Убрать else оператор !!!!!!
       //else amain.Log('СКУ: Нет реализации mes.Code:'+inttostr(mes.Code));

     end; //case

   end; //0

   1: //Запрос пользователей у СКУ
   begin
     Tlg_User_GetList;
   end; //1

   2: //Запись HW1 в СКУ
   begin
     inc(Subcomd);
     case Subcomd of

       1:
       if TmpL[3] in [1..6] then
       begin
         FillChar(l, 6, 0);
         Tlg_SetSH (TmpL[3]);
       end;
       2:
       if TmpL[4] in [1..6] then
       begin
         FillChar(l, 6, 0);
         Tlg_SetSH (TmpL[4]);
       end;
       3:
       begin
         FillChar(l, 6, 0);
         if ((TmpL[5] shr 4) and $03) > 0 then //№ реле
         begin
           if (TmpL[5] and $08) > 0
             then l[5]:= $01
             else l[5]:= $80;
           Tlg_SetRelay ((TmpL[5] shr 4) and $03);
         end;
       end;
       4:
       begin
         FillChar(l, 6, 0);
         l[0]:= $A1;
         case TmpL[0] of
           0: l[0]:= l[0];
           1: l[0]:= l[0] or $08;
           2: l[0]:= l[0] or $10;
           3: l[0]:= l[0] or $18;
         end;
         l[3]:= $07;
         Tlg_SetUSK(ap); // № УСК
       end;
       5:
       begin
         FillChar(l, 14, 0);
         l[0]:= 0;  // Тип и режим прохода
         case ap of // УСК двери
           1: l[1]:= $01;
           2: l[1]:= $04;
         end;

         if (TmpL[5] and $02) > 0 then // Индикация взлома
           l[1]:= l[1] or $40;
         if (TmpL[5] and $04) > 0 then // Индикация удержания
           l[1]:= l[1] or $80;
         l[2]:= (TmpL[5] shr 4) and $03; // Реле вх.двери
         l[3]:= l[3] + (TmpL[3] shl 0); // ШС кнопки
         l[3]:= l[3] + (TmpL[4] shl 3); // ШС двери
         if (TmpL[5] and $02) > 0 then // Взлом
           l[3]:= l[3] or $80;
         if (TmpL[5] and $04) > 0 then // Удержание
           l[3]:= l[3] or $40;
         l[4]:= 0; // ШС шлюза
         l[5]:= 0; // Таймаут прохода
         l[6]:= TmpL[1]; //Время замка
         l[7]:= TmpL[2]; //Время двери
         l[8]:= 0; // Задержка прохода в шлюзе
         l[9]:= 0; // Блокир. по ВЗ
         l[10]:= 0; // Разблокир. по ВЗ
         // Блок./Разблок по всей ВЗ, Рег. по СМК/карте
         l[11]:= 0;
         if (TmpL[5] and $01) > 0 then
           l[11]:= l[11] or $04;
         l[12]:= 0; // Макс.
         l[13]:= 0; // Резерв
         Tlg_SetAP(ap); // № ТД
       end;

       else
       begin //завершение операции
         comd:= 0;
       end;
     end; //case
   end;  //2

   3: //Чтение HW1 из СКУ
   begin
     inc(Subcomd);
     case Subcomd of
       1:
       begin
         Tlg_GetUSK(ap);
       end;
       2:
       begin
         Tlg_GetAP(ap);
       end;
       3:
       begin
         if ((TmpL[5] shr 4) and $03) > 0 then
           Tlg_GetRelay ((TmpL[5] shr 4) and $03);
       end;

       else
       begin //завершение операции
         comd:= 0;
       end;
     end;//case
   end; //3


   4: //Запись HW2 в СКУ
   begin
     inc(Subcomd);
     case Subcomd of

       1: //if ap=1 then // изм. 08.11.15
       if TmpL[3] in [1..6] then
       begin
         FillChar(l, 6, 0);
         Tlg_SetSH (TmpL[3]);
       end;
       2: //if ap=1 then // изм. 08.11.15
       if TmpL[4] in [1..6] then
       begin
         FillChar(l, 6, 0);
         Tlg_SetSH (TmpL[4]);
       end;
       3: //if ap=1 then // изм. 08.11.15
       begin
         FillChar(l, 6, 0);
         if ((TmpL[5] shr 4) and $03) > 0 then //№ реле
         begin
           if (TmpL[5] and $08) > 0
             then l[5]:= $01
             else l[5]:= $80;
           Tlg_SetRelay ((TmpL[5] shr 4) and $03);
         end;
       end;
       4:
       begin
         FillChar(l, 6, 0);
         l[0]:= $A1;
         case TmpL[0] of
           0: l[0]:= l[0];
           1: l[0]:= l[0] or $08;
           2: l[0]:= l[0] or $10;
           3: l[0]:= l[0] or $18;
         end;
         l[3]:= $07;
         Tlg_SetUSK(ap); // № УСК
       end;
       5: //if ap=1 then // изм. 08.11.15
       begin
         FillChar(l, 14, 0);
         l[0]:= 2;   // Тип и режим прохода
         l[1]:= $05; // УСК двери

         if (TmpL[5] and $02) > 0 then // Индикация взлома
           l[1]:= l[1] or $40;
         if (TmpL[5] and $04) > 0 then // Индикация удержания
           l[1]:= l[1] or $80;
         l[2]:= (TmpL[5] shr 4) and $03; // Реле вх.двери
         l[3]:= l[3] + (TmpL[3] shl 0); // ШС кнопки
         l[3]:= l[3] + (TmpL[4] shl 3); // ШС двери
         if (TmpL[5] and $02) > 0 then // Взлом
           l[3]:= l[3] or $80;
         if (TmpL[5] and $04) > 0 then // Удержание
           l[3]:= l[3] or $40;
         l[4]:= 0; // ШС шлюза
         l[5]:= 0; // Таймаут прохода
         l[6]:= TmpL[1]; //Время замка
         l[7]:= TmpL[2]; //Время двери
         l[8]:= 0; // Задержка прохода в шлюзе
         l[9]:= 0; // Блокир. по ВЗ
         l[10]:= 0; // Разблокир. по ВЗ
         // Блок./Разблок по всей ВЗ, Рег. по СМК/карте
         l[11]:= 0;
         if (TmpL[5] and $01) > 0 then
           l[11]:= l[11] or $04;
         l[12]:= 0; // Макс.
         l[13]:= 0; // Резерв
         Tlg_SetAP(ap); // № ТД
       end;

       else
       begin //завершение операции
         comd:= 0;
       end;
     end; //case
   end;  //4

   5: //Чтение HW2 из СКУ
   begin
     inc(Subcomd);
     case Subcomd of
       1:
       begin
         Tlg_GetUSK(ap);
       end;
       2:
       begin
         Tlg_GetAP(ap);
       end;
       3:
       begin
         if ((TmpL[5] shr 4) and $03) > 0 then
           Tlg_GetRelay ((TmpL[5] shr 4) and $03);
       end;

       else
       begin //завершение операции
         comd:= 0;
       end;
     end;//case
   end; //5


   11: //Запись разрешенных пользователей из *.scu в прибор
   begin

     case Subcomd of
       0: Tlg_User_DeleteAll;
       1..1999:
       begin
         FillChar(l,128,0);
         pus:= nil;
         if rub.ScuUserMap[Subcomd]>0 then
           pus:= rub.FindUS(rub.ScuUserMap[Subcomd]);
         if pus<>nil then
         begin
           l[5]:= pus^.IdentifierCode[0];
           l[6]:= pus^.IdentifierCode[2];
           l[7]:= pus^.IdentifierCode[1];
           l[8]:= $01;
           l[11]:= $3f;
           move (pus^.PinCode, l[13], 4);
           //
           rub.ScuUserfilter( pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256 );  //Слудет переименовать в SetPermitScuArray
           int:= -1;
           pcu:= rub.FindCU(65536*32 + scu.cuHWSerial, 0);
           if pcu<>nil then
             int:= rub.CU.IndexOf(pcu);
           case int of
             0..255:
               if rub.ScuSendArray[ int ] > 0 then
                 Tlg_User_Add(Subcomd);
           end;//case
         end;
       end //1..1999

       else
       begin //завершение операции
         comd:= 0;
         s:= Format('Ответ на команду (%d) от СКУ-02 [Зав.№%d, IP %d.%d.%d.%d]. ',
               [ mes.Code, cuHWSerial, cuIP[0], cuIP[1], cuIP[2], cuIP[3] ])  +
             Format('Запись пользователей из *.scu завершена', []);
         aMain.Log(s);
         s:= '';
       end;
     end;//case
     //
     inc(Subcomd);
   end; //11


   12: //Запись всех пользователей из *.scu в прибор
   begin

     case Subcomd of
       0: Tlg_User_DeleteAll;
       1..1999:
       begin
         FillChar(l,128,0);
         pus:= nil;
         if rub.ScuUserMap[Subcomd]>0 then
           pus:= rub.FindUS(rub.ScuUserMap[Subcomd]);
         if pus<>nil then
         begin
           l[5]:= pus^.IdentifierCode[0];
           l[6]:= pus^.IdentifierCode[2];
           l[7]:= pus^.IdentifierCode[1];
           l[8]:= $01;
           l[11]:= $3f;
           move (pus^.PinCode, l[13], 4);
           Tlg_User_Add(Subcomd);
         end;
       end //1..1999

       else
       begin //завершение операции
         comd:= 0;
         s:= Format('Ответ на команду (%d) от СКУ-02 [Зав.№%d, IP %d.%d.%d.%d]. ',
               [ mes.Code, cuHWSerial, cuIP[0], cuIP[1], cuIP[2], cuIP[3] ])  +
             Format('Запись пользователей из *.scu завершена', []);
         aMain.Log(s);
         s:= '';
       end;
     end;//case
     //
     inc(Subcomd);
   end; //12

   end;//case comd


   if s<>'' then
   begin
     s:= Format('Получена команда (%d) для СКУ-02 [Зав.№%d, IP %d.%d.%d.%d] ',
                 [mes.Code, cuHWSerial, cuIP[0], cuIP[1], cuIP[2], cuIP[3]])
       + s;
     aMain.Log(s);
   end;

 EXCEPT
   On E: Exception do
     aMain.Log
     (
       Format( 'Exception SCUWRITE СКУ-02 [Зав.№%d, IP %d.%d.%d.%d] по команде (%d). Шаг (%d). %s',
              [ cuHWSerial, cuIP[0], cuIP[1], cuIP[2], cuIP[3], mes.Code, comd, E.Message ] )
     );
 END;

 end; //with
end;

//----------------------------
procedure SCUREAD (p: pointer);
var
 scu: WRSCUThread;
 i: word;
 s: String;
 TempMesCode: word;

begin
 scu:= p;
 TempMesCode:= 0;
 s:= '';
 //
 with scu do begin


 case comd of
   0: //вх.KSBMes буфер
   begin

     if RetCode=0 then

       case mes.Code of

         SCU_SH_EDIT:
         begin
           TempMesCode:= SCU_SH_EDITED;
           s:= Format('ШС №%d редактирован', [ rBuf[11] ]);
         end;

         SCU_SH_GET:
         begin
           mes.Size:= 6;
           TempMesCode:= SCU_SH;
           if rBuf[5]=$0A then
           begin //СИГМА-БАГ
             move(rBuf[10], l, mes.Size);
             s:= Format('ШС №%d конфигурация', [ rBuf[9] ]);
           end
           else
           begin
             move(rBuf[12], l, mes.Size);
             s:= Format('ШС №%d конфигурация', [ rBuf[11] ]);
           end;
         end;

         SCU_RELAY_EDIT:
         begin
           TempMesCode:= SCU_RELAY_EDITED;
           s:= Format('Реле №%d редактировано', [ rBuf[11] ]);
         end;

         SCU_RELAY_GET:
         begin
           mes.Size:= 6;
           move(rBuf[12], l, mes.Size);
           TempMesCode:= SCU_RELAY;
           s:= Format('Реле №%d конфигурация', [ rBuf[11] ]);
         end;

         SCU_USK_EDIT:
         begin
           TempMesCode:= SCU_USK_EDITED;
           s:= Format('УСК №%d редактирован', [ rBuf[11] ]);
         end;

         SCU_USK_GET:
         begin
           mes.Size:= 6;
           move(rBuf[12], l, mes.Size);
           TempMesCode:= SCU_USK;
           s:= Format('УСК №%d конфигурация', [ rBuf[11] ]);
         end;

         SCU_AP_EDIT:
         begin
           TempMesCode:= SCU_AP_EDITED;
           s:= Format('ТД №%d редактирована', [ rBuf[11] ]);
         end;

         SCU_AP_GET:
         begin
           mes.Size:= 14;
           move(rBuf[12], l, mes.Size);
           TempMesCode:= SCU_AP;
           s:= Format('ТД №%d конфигурация', [ rBuf[11] ]);
         end;

         SCU_USER_ADD,
         SCU_USER_ADDNOCHECK:
         begin
           TempMesCode:= SCU_USER_ADDED;
           s:= Format('Пользователь №%d добавлен', [ rBuf[11]+256*rBuf[12] ]);
         end;

         SCU_USER_EDIT:
         begin
           TempMesCode:= SCU_USER_EDITED;
           s:= Format('Пользователь №%d редактирован', [ rBuf[11]+256*rBuf[12] ]);
         end;

         SCU_USER_DELETE:
         begin
           TempMesCode:= SCU_USER_DELETED;
           s:= Format('Пользователь №%d удален', [ rBuf[11]+256*rBuf[12] ]);
         end;
         SCU_USER_DELETE_ALL:
         begin
           TempMesCode:= SCU_USER_DELETED_ALL;
           s:= Format('Все пользователи удалены', [ ]);
         end;
         SCU_USER_GET:
         begin
           mes.Size:= 22;
           move(rBuf[13], l, mes.Size);
           TempMesCode:= SCU_USER;
           s:= Format('Пользователь №%d конфигурация', [ rBuf[11]+256*rBuf[12] ]);
         end;

         SCU_CARD_ADD:
         begin
           //TempMesCode:= SCU_CARD_ADDED;
           s:= Format('Карта №%d добавлена', [ rBuf[11]+256*rBuf[12] ]);
         end;

         SCU_CARD_DELETE:
         begin
           //TempMesCode:= SCU_CARD_DELETED;
           s:= Format('Карта №%d удалена', [ rBuf[11]+256*rBuf[12] ]);
         end;

         SCU_GET_DEVVER:
         begin
           s:= Format('Версия %d.%d', [rBuf[9], rBuf[10]]);
         end;
         SCU_GET_BOOTVER:
         begin
           s:= Format('Загрузчик %.2xh', [ rBuf[8] ]);
         end;
         SCU_GET_STATEWORD:
         begin
           s:= Format('Словосостояние %.2xh', [ rBuf[6] ]);
         end;
         SCU_GET_DEVSTATE:
         begin
           s:= Format('Состояние %.2x%.2x%.2x%.2x%.2xh', [ rBuf[9], rBuf[10], rBuf[11], rBuf[12], rBuf[13] ]);
         end;
         SCU_TIME_GET:
         begin
           s:= Format('Время %s', [ DateTimeToStr(UnPackTime(rBuf[10])) ]);
         end;
         SCU_TIME_EDIT:
         begin
           s:= Format('Установлено время', [ ]);
         end;

         SCU_NETWORK_GET:
         begin
           s:= Format('Сетевые настройки: IP %d.%d.%d.%d Маска %d.%d.%d.%d Шлюз %d.%d.%d.%d',
           [ rBuf[13], rBuf[14], rBuf[15], rBuf[16],
             rBuf[17], rBuf[18], rBuf[19], rBuf[20],
             rBuf[21], rBuf[22], rBuf[23], rBuf[24]
           ]);
         end;

         SCU_NETWORK_EDIT:
         begin
           s:= Format('Сетевые настройки редактированы', [  ]);
         end;

         SCU_SHOCHR_ARM:
         begin
           s:= Format('ШС №%d взят', [ wBuf[11] ]);
         end;

         SCU_SHOCHR_DISARM:
         begin
           s:= Format('ШС №%d снят', [ wBuf[11] ]);
         end;

         SCU_SHOCHR_RESET:
         begin
           s:= Format('ШС №%d сброшен', [ wBuf[11] ]);
         end;

         SCU_SHTREV_RESET:
         begin
           s:= Format('ШС №%d сброшен', [ wBuf[11] ]);
         end;

         SCU_SHFIRE_RESET:
         begin
           s:= Format('ШС №%d сброшен', [ wBuf[11] ]);
         end;

         SCU_RELAY_1:
         begin
           s:= Format('Реле №%d включено', [ wBuf[11]-6 ]);
         end;

         SCU_RELAY_0:
         begin
           s:= Format('Реле №%d выключено', [ wBuf[11]-6 ]);
         end;

         SCU_TC_RESTORE:
         begin
           s:= Format('ШС №%d восстановлен', [ wBuf[11] ]);
         end;

         SCU_AP_UNLOCK:
         begin
           s:= Format('ТД №%d открыта', [ wBuf[11]-9 ]);
         end;

         SCU_AP_LOCK:
         begin
           s:= Format('ТД №%d закрыта', [ wBuf[11]-9 ]);
         end;

         SCU_AP_PASS:
         begin
           s:= Format('ТД №%d открыт проход', [ wBuf[11]-9 ]);
         end;

         SCU_AP_RESET:
         begin
           s:= Format('ТД №%d сброшена', [ wBuf[11]-9 ]);
         end;

       end// case
       else
       begin
         s:= DescriptionSCURetCode(RetCode);
       end;
   end;//0


   1: //Список пользователей
   begin
     TmpCurUser:= rBuf[11] + 256 * rBuf[12];
     if  rBuf[8] = 30 then
     begin
       comd:= 0;
     end
     else
     begin
       s:='';
       for i:=0 to rBuf[5]+7 do
         s:= s + IntToHex(rBuf[i], 2) + '.';
       s:= 'Пользователь №' + IntToStr(rBuf[11]+256*rBuf[12]) + ' ' + s;
     end;
   end; //1


   2, 4: //Запись HW в СКУ
   case Subcomd of
     // изм. 08.11.15
     //4:
     //if ap=2 then
     //begin
     //  mes.Size:= 0;
     //  TempMesCode:= SCU_HW_EDITED;
     //  s:= Format('HW-конфигурация №%d редактирована', [ ap{rBuf[11]} ]);
     //end;
     5:
     begin
       mes.Size:= 0;
       TempMesCode:= SCU_HW_EDITED;
       s:= Format('HW-конфигурация №%d редактирована', [ ap{rBuf[11]} ]);
     end;
   end; //Subcomd //2


   3, 5:  //Чтение HW из СКУ
   case Subcomd of
     1:
     begin
       FillChar(TmpL, 256, 0);
       TmpL[0]:= (rBuf[12] shr 3) and $3;
       // требуется проанализировать состояние ТД
       // и возможно скорректировать режим
     end;
     2:
     begin
       TmpL[1]:= rBuf[12+6];
       TmpL[2]:= rBuf[12+7];
       TmpL[3]:= rBuf[12+3] and $07;
       TmpL[4]:= (rBuf[12+3] shr 3) and $07;
       case ((rBuf[12+0] shr 1) and $07) of
         0: TmpL[5]:= TmpL[5] or $00;
         1: TmpL[5]:= TmpL[5] or $40;
       end;
       TmpL[5]:= TmpL[5] or ((rBuf[12+2] and $03) shl 4);
       if (rBuf[12+11] and $04) > 0 then
         TmpL[5]:= TmpL[5] or $01;
       if (rBuf[12+ 3] and $80) > 0 then
         TmpL[5]:= TmpL[5] or $02;
       if (rBuf[12+ 3] and $40) > 0 then
         TmpL[5]:= TmpL[5] or $04;
       //
       //изм. 08.11.15
       {
       if ap=2 then
       begin
         move(TmpL, l, 256);
         mes.Size:= 6;
         TempMesCode:= SCU_HW;
         s:= Format('HW-конфигурация №%d', [ ap ]);
       end;
       }
     end;
     3:
     begin
       if (rBuf[17] and $01) > 0 then
         TmpL[5]:= TmpL[5] or $08;
       //
       move(TmpL, l, 256);
       mes.Size:= 6;
       TempMesCode:= SCU_HW;
       s:= Format('HW-конфигурация №%d', [ ap ]);
     end;
   end; //Subcomd //3


   11, //Запись разрешенных пользователей из *.scu в прибор
   12: //Запись всех пользователей из *.scu в прибор
   begin
     case Subcomd of
       1: s:= Format('Удалены все пользователи в приборе', []);
       2..2000: s:= Format('Пользователь №%d записан в прибор', [Subcomd]);
     end;
   end;

 end; //case

 if s<>'' then
 begin
   s:= Format('Ответ на команду (%d) от СКУ-02 [Зав.№%d, IP %d.%d.%d.%d]. ',
               [ mes.Code, cuHWSerial, cuIP[0], cuIP[1], cuIP[2], cuIP[3] ])
       + s;
   aMain.Log('SEND: '+s);
 end;

 //отправка телеграммы
 if (TempMesCode>0) then
 begin
   mes.Code:= TempMesCode;
   aMain.send (mes, PChar(@l[0]) );
 end

 end; //with scu

end;



function DescriptionSCURetCode(Code: word): string;
begin
 Debug('F:DescriptionSCURetCode');
 result:='Неизвестный код';
 case Code of
 0: result:=    'OK';
 1: result:=   	'Объект не найден';
 7: result:=   	'Неизвестный тип объекта ТС';
 8: result:=   	'Неизвестная команда управления';
 9: result:=   	'Уже выполнено';
 10: result:=   'Ошибка типа оборудования';
 15: result:=   'Объект заблокирован';
 16: result:=   'Объект не готов';
 24: result:=   'Неверное значение';
 25: result:=   'Объект уже существует';
 30: result:=   'Конец списка объектов';
 31: result:=   'Нет новых записей журнала событий';
 32: result:=   'Объект не сконфигурирован';
 34: result:=   'Неизвестная ошибка';
 54: result:=   'Ошибка загрузчика программы БЦП';
 end;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tlg_GetDevVer;
begin
 Debug('F:Tlg_GetDevVer');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$01; // длина без кс
   wBuf[6]:=$80; // команда
   wBuf[7]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[8]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetBootVer;
begin
 Debug('F:Tlg_GetBootVer');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$01; // длина без кс
   wBuf[6]:=$9b; // команда
   wBuf[7]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[8]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetPrgData;
begin
 Debug('F:Tlg_GetPrgData');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$01; // длина без кс
   wBuf[6]:=$9A; // команда
   wBuf[7]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[8]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetStateWord;
begin
 Debug('F:Tlg_GetStateWord');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$01; // длина без кс
   wBuf[6]:=$81; // команда
   wBuf[7]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[8]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetDevState;
begin
 Debug('F:Tlg_GetDevState');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$01; // длина без кс
   wBuf[6]:=$85; // команда
   wBuf[7]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[8]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetAltDevState;
begin
 Debug('F:Tlg_GetAltDevState');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$01; // длина без кс
   wBuf[6]:=$8b; // команда
   wBuf[7]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[8]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;


procedure Tlg_GetParamArray;
begin
 Debug('F:Tlg_GetParamArray');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$01; // длина без кс
   wBuf[6]:=$82; // команда
   wBuf[7]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[8]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

// v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v
///////////////////////////////////////////////////////////////////////////////

procedure Tlg_SetSH(Number: byte);
begin
 Debug('F:Tlg_SetSH');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$0C;    // длина без кс
   wBuf[6]:=$84;    // команда
   wBuf[7]:=$02;    // тип
   wBuf[8]:=$01;    // подкоманда
   wBuf[9]:=Number; // № ШС
   move (l, wBuf[10], 6);
   wBuf[16]:=lo(kc(wBuf[10], 6)); wBuf[17]:=hi(kc(wBuf[10], 6)); // кс
   wBuf[18]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[19]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetSH(Number: byte);
begin
 Debug('F:Tlg_GetSH');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=4;      // длина без кс
   wBuf[6]:=$84;    // команда
   wBuf[7]:=$02;    // тип
   wBuf[8]:=$02;    // подкоманда
   wBuf[9]:=Number; // № ШС
   wBuf[10]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[11]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure Tlg_SetRelay(Number: byte);
begin
 Debug('F:Tlg_SetRelay');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$0C;    // длина без кс
   wBuf[6]:=$84;    // команда
   wBuf[7]:=$02;    // тип
   wBuf[8]:=$03;    // подкоманда
   wBuf[9]:=Number; // № Реле;
   move (l, wBuf[10], 6);
   wBuf[16]:=lo(kc(wBuf[10], 6)); wBuf[17]:=hi(kc(wBuf[10], 6)); // кс
   wBuf[18]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[19]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetRelay(Number: byte);
begin
 Debug('F:Tlg_GetRelay');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=4;      // длина без кс
   wBuf[6]:=$84;    // команда
   wBuf[7]:=$02;    // тип
   wBuf[8]:=$04;    // подкоманда
   wBuf[9]:=Number; // № Реле;
   wBuf[10]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[11]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure Tlg_SetUSK(Number: byte);
begin
 Debug('F:Tlg_SetUSK');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$0C;    // длина без кс
   wBuf[6]:=$84;    // команда
   wBuf[7]:=$02;    // тип
   wBuf[8]:=$08;    // подкоманда
   wBuf[9]:=Number; // № УСК
   move (l, wBuf[10], 6);
   wBuf[16]:=lo(kc(wBuf[10], 6)); wBuf[17]:=hi(kc(wBuf[10], 6)); // кс
   wBuf[18]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[19]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetUSK(Number: byte);
begin
 Debug('F:Tlg_GetUSK');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=4;      // длина без кс
   wBuf[6]:=$84;    // команда
   wBuf[7]:=$02;    // тип
   wBuf[8]:=$09;    // подкоманда
   wBuf[9]:=Number; // № УСК
   wBuf[10]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[11]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;


///////////////////////////////////////////////////////////////////////////////
procedure Tlg_SetAP(Number: byte);
begin
 Debug('F:Tlg_SetAP');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$14;    // длина без кс
   wBuf[6]:=$84;    // команда
   wBuf[7]:=$02;    // тип
   wBuf[8]:=$0A;    // подкоманда
   wBuf[9]:=Number; // № ТД
   move (l, wBuf[10], 14);
   wBuf[24]:= lo(kc(wBuf[10], 14)); wBuf[25]:= hi(kc(wBuf[10], 14)); // кс
   wBuf[26]:= lo(kc(wBuf, wBuf[5] + 6)); wBuf[27]:= hi(kc(wBuf, wBuf[5] + 6)); // кс
 end;

end;

procedure Tlg_GetAP(Number: byte);
begin
 Debug('F:Tlg_GetAP');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$04;   // длина без кс
   wBuf[6]:=$84;   // команда
   wBuf[7]:=$02;   // тип
   wBuf[8]:=$0B;   // подкоманда
   wBuf[9]:=Number;  // № ТД
   wBuf[10]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[11]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

// ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
procedure Tlg_GetTime;
begin
 Debug('F:Tlg_GetTime');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$02; // длина без кс
   wBuf[6]:=$89; // команда
   wBuf[7]:=$1;  // запрос
   wBuf[8]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[9]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_SetTime;
var
 time: Longword;
begin
 Debug('F:Tlg_SetTime');
 with scu do begin
   time:= PackTime(now);
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$06; // длина без кс
   wBuf[6]:=$89; // команда
   wBuf[7]:=$02; // установка
   wBuf[8]:= time and $FF;
   wBuf[9]:= time shr  8 and $FF;
   wBuf[10]:=time shr 16 and $FF;
   wBuf[11]:=time shr 24 and $FF;
   wBuf[12]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[13]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_SetNetWork(var param: array of byte);
const
// param: array [0..16] of byte=($0d, 192, 168, 0, 1, 255, 255, 255, 0, 1, 3, 5 ,7, 255, 255, 255, 255);
 Port = 50101;
begin
 Debug('F:Tlg_SetNetWork');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$69;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$64;  // тип
   wBuf[8]:=$01;  // под команда
   wBuf[9]:=$0d;  // Eth
   FillChar(wBuf[10], 101, 0);
   move (param, wBuf[10], 17);
   wBuf[27]:= lo(Port);
   wBuf[28]:= hi(Port);
   wBuf[109]:=lo(kc(wBuf[10], 101)); wBuf[110]:=hi(kc(wBuf[10], 101)); // кс
   wBuf[111]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[112]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_GetNetWork;
begin
 Debug('F:Tlg_GetNetWork');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$04;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$64;  // тип
   wBuf[8]:=$02;  // под команда
   wBuf[9]:=$0d;  // Eth
   wBuf[10]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[11]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

//-----------------------------------------------------------------------------
procedure Tlg_TC_Control(Control, Element: word);
var
 TrueNumber: byte; //номер в иерархии СКУ-02
begin
 Debug('F:Tlg_TC_Control');
 with scu do begin
   //
   TrueNumber:= Element;
   TRY
   case mes.Code of
     SCU_TC_RESTORE,
     SCU_SHOCHR_DISARM,
     SCU_SHOCHR_ARM,
     SCU_SHOCHR_RESET,
     SCU_SHTREV_RESET,
     SCU_SHFIRE_RESET:
     begin
       if not TrueNumber in [1..6] then
       Raise Exception.Create('Не верный номер ШС.');
     end;

     SCU_RELAY_0,
     SCU_RELAY_1:
     begin
       TrueNumber:= TrueNumber + 6;
       if not TrueNumber in [7..9] then
       Raise Exception.Create('Не верный номер реле.');
     end;

     SCU_AP_PASS,
     SCU_AP_LOCK,
     SCU_AP_UNLOCK,
     SCU_AP_RESET:
     begin
       TrueNumber:= TrueNumber + 9;
       if not TrueNumber in [10..12] then
       Raise Exception.Create('Не верный номер ТД.');
     end;
   end;//case
   //
   EXCEPT
     On E: Exception do
       aMain.Log('Exception.Tlg_TC_Control(' + E.Message );
   END;
   //
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$07; // длина без кс
   wBuf[6]:=$87; // команда
   wBuf[7]:=lo(Control);
   wBuf[8]:=hi(Control);
   wBuf[9]:=lo(cuHWSerial);
   wBuf[10]:=hi(cuHWSerial);
   wBuf[11]:=lo(TrueNumber);
   wBuf[12]:=hi(TrueNumber);
   wBuf[13]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[14]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;
      //B649 2039 0307 8701 0539 0309 0018 91

procedure Tlg_User_Add(Number: word);
begin
 Debug('F:Tlg_User_Add');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$1d{(2+22)+2+3};// длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$04;  // тип
   wBuf[8]:=$01;  // под команда
   wBuf[9]:= lo(Number);  // Польз.
   wBuf[10]:=hi(Number);  // Польз.
   move (l, wBuf[11], 22);
   wBuf[33]:=lo(kc(wBuf[11], 22)); wBuf[34]:=hi(kc(wBuf[11], 22)); // кс
   wBuf[35]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[36]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;


procedure Tlg_User_Edit(Number: word);
begin
 Debug('F:Tlg_User_Edit');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$1d;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$04;  // тип
   wBuf[8]:=$02;  // под команда
   wBuf[9]:= lo(Number);  // Польз.
   wBuf[10]:=hi(Number);  // Польз.
   move (l, wBuf[11], 22);
   wBuf[33]:=lo(kc(wBuf[11], 22)); wBuf[34]:=hi(kc(wBuf[11], 22)); // кс
   wBuf[35]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[36]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_User_Delete(Number: word);
begin
 Debug('F:Tlg_User_Delete');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$05;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$04;  // тип
   wBuf[8]:=$03;  // под команда
   wBuf[9]:= lo(Number);  // Польз.
   wBuf[10]:=hi(Number);  // Польз.
   wBuf[11]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[12]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_User_DeleteAll;
begin
 Debug('F:Tlg_User_Delete_All');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$03;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$04;  // тип
   wBuf[8]:=$04;  // под команда
   wBuf[9]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[10]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_User_Get(Number: word);
begin
 Debug('F:Tlg_User_Get');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$05;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$04;  // тип
   wBuf[8]:=$05;  // под команда
   wBuf[9]:= lo(Number);  // Польз.
   wBuf[10]:=hi(Number);  // Польз.
   wBuf[11]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[12]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_User_GetList;
begin
 Debug('F:Tlg_User_GetList');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$05;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$04;  // тип
   wBuf[8]:=$06;  // под команда
   wBuf[9]:=lo(TmpCurUser); // TmpUser
   wBuf[10]:=hi(TmpCurUser);// TmpUser
   wBuf[11]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[12]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;

procedure Tlg_User_AddNoCheck(Number: word);
begin
 Debug('F:Tlg_User_AddNoCheck');
 with scu do begin
   wBuf[0]:=$B6; wBuf[1]:=$49; wBuf[2]:=$20;
   wBuf[3]:=lo(cuHWSerial);
   wBuf[4]:=hi(cuHWSerial);
   wBuf[5]:=$1d;  // длина без кс
   wBuf[6]:=$84;  // команда
   wBuf[7]:=$04;  // тип
   wBuf[8]:=$07;  // под команда
   wBuf[9]:= lo(Number);  // Польз.
   wBuf[10]:=hi(Number);  // Польз.
   move (l, wBuf[11], 22);
   wBuf[33]:=lo(kc(wBuf[11], 22)); wBuf[34]:=hi(kc(wBuf[11], 22)); // кс
   wBuf[35]:=lo(kc(wBuf, wBuf[5]+6)); wBuf[36]:=hi(kc(wBuf, wBuf[5]+6)); // кс
 end;
end;






END.



