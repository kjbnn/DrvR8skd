unit R8OnRecive;

interface
 procedure ReadBCPTelegram;
 function GetStateZN (zn: word; ptc: pointer=nil): word;
 function APModeToRostek(ptc: pointer): byte;
 function APStateToRostek(ptc: pointer): byte;


implementation
uses windows, Sysutils, mMain, R8Unit, SharedBuffer, constants, KSBParam,
  Comm,
  Forms, mCheckZoneOperation;

//-----------------------------------------------------------------------------
procedure ReadBCPTelegram;
type
 arbyte = array of byte;
var
 st: string;
 i,j : word;
 ptc: PTTC;
 pcu: PTCU;
 pzn: PTZN;
 pgr: PTGR;
 pus: PTUS;
 pti: PTTI;
 ppr: PTPR;
 prn: PTRN;
 prp: PTRP;

 mes: KSBMES;
 tt: TTelegram;
 t: PTTelegram;
 tState: word;
 data: PChar;
 ExceptStr: string;
 NewMes: boolean;


 
 {
 ptr    new     ->      num             send
 0      0       ->      0               0
 0      1       ->      >1000/hlt       1
 1      0       ->      exist           1
 1      1       ->      exist           1
 }
 Procedure EventLogAndTrySend
        (
        obj: pointer;
        var txt: string;
        code: word
        );
 begin
   if (obj<>nil)or NewMes then
     if (code>0) then
     begin
       mes.Code:= code;
       aMain.send(mes);
       aMain.Log('SEND: ' + DateTimeToStr(UnPackTime(rbcp.rbuf[16*i])) + ' ' + txt);
       txt:= '';
     end;

   if txt<>'' then
     aMain.Log('INT_: ' + DateTimeToStr(UnPackTime(rbcp.rbuf[16*i])) + ' ' + txt);
     
   mes.Code:= 0;
   txt:= '';
 end;


begin
 Debug('F:ReadBCPTelegram');
 data:='';
 st:= '';

 with rbcp do begin
   ExceptStr:='Старт_1';
   QueryPerformanceFrequency(_f.QuadPart);
   QueryPerformanceCounter(_c1.QuadPart);

 TRY
 //выход по пустышкам из буфера
 if (rbuf[5]=7)and(rbuf[10]=$8d) then
   exit;
 //печать OnReadBCPTel
 if Option.Logged_OnReadBCPTel then
 begin
   st:= 'OnReadBCPTel: ';
   for i:=0 to rbuf[5]+7 do
     st:= st + inttohex(rbuf[i],2);
   aMain.Log(st);
 end;
 //
 //
 case rbuf[10] of
  $80:
  begin
    st:= Format('Версия БЦП %d.%d. Версия БД %d.%d', [ rbuf[13], rbuf[14], rbuf[15], rbuf[16] ]);
    aMain.Log(st);
  end;
  //`````````````````````````````````````````````````````````````````````````````
  //`````` Чтение состояний `````````````````````````````````````````````````````
  //`````````````````````````````````````````````````````````````````````````````
  $85:
  case rbuf[13] of //тип объекта

    2://объект ТС
    begin
      // 1,2 запросы
      ExceptStr:= 'Состояние_1';
      case rbuf[14] of
        1:; // запрос структуры состояния объекта ТС
        2:; // запрос структуры состояния маркированного объекта ТС
        else exit;
      end;
      // ТС не найден
      ExceptStr:= 'Состояние_2';
      ptc:= rub.FindTC(256*rbuf[18]+rbuf[17], 0);
      if ptc=nil then
        exit; //Raise Exception.Create( Format('ТС [%x] не найден', [ 256*rbuf[18]+rbuf[17] ]) )


      // 5 - длина
      // 6..9 - словосостояния
      // 10 - код отправленной команды
      // 11..12 - код результата
      // 13 - данные...
      //
      //Конфигурирование
      // 13 - тип объекта (1)
      // 14 - команда конф.
      // 15 - данные конф.

      // ------------------------------------------------------------------------------------------------------------
      // ШС 1-3     -> неизв. - н.об. - откл.     - н - т - в - г
      // ШС 4       -> неизв. - н.об. - откл.     - н - т - Обл.2 - Обл.1
      // Реле 5     -> неизв. - н.об. - откл.     - н - т - вкл. - х
      // ТД 6       -> неизв. - н.об. - откл.     - н - 3бита (1-Норма, 2-Дверь открыта, 3-Удержание, 4-Взлом, 5-Заблокировано, 6-Разблокировано, 7-Нападение)
      // Терминал   -> неизв. - н.об. - откл.     - н - т - блок. -г
      // ------------------------------------------------------------------------------------------------------------
      // Вызывается каждый раз при чтении нач. сосотяний (comd=24) без отправки KSBMes и с присвоением tState
      // Вызывается каждый раз при чтении сосотяния созд/редакт ТС (comd=3) с отправкой KSBMes и с присвоением tState
      // Вызывается каждый раз в деж. режиме при отсутсвии событий и команд (comd=1) с отправкой KSBMes и без присвоением tState только для ШС и тлько готов неготов



      //Установка неизвестно по умолчанию
      tState:= $40;

      //1 проход (Состояние)
      case 256*rbuf[23]+rbuf[22] of
        $000:  if (256*rbuf[21]+rbuf[20]{ + rbuf[19]})=0
                 then tState:= $10  // ТС Отключено
                 else tState:= $28; // ТС Неиспр.об.
        $101:  tState:= $03;        // ШС Взят
        $102:  tState:= $01;        // ШС Готов
        $103:  tState:= $00;        // ШС Не готов
        $104:                       // ШС Проник.(Тревога)
          if (rbuf[19] and $04)=0
            then tState:= $04
            else tState:= $05;
        $105:                       // ШС Неиспр.КЗ
          if (rbuf[19] and $04)=0
            then tState:= $08
            else tState:= $09;
        $106:  tState:= $03;        // ШС Задержка на вход (м.б. не обрабатывать ?)
        $107:  tState:= $01;        // ШС Задержка на выход (м.б. не обрабатывать ?)
        $108:  tState:= $00;        // ШС Ожидание готовности (м.б. не обрабатывать ?)
        $109:  tState:= $08;        // ШС Ошибка ДК (м.б. не обрабатывать ?)
        $201:  tState:= 0+0+2+1;           //ШС Норма (взят)
        $202:  tState:= 0+4+2+0;           //ШС Тревога
        $203:  tState:= 8+0+0+0;           //ШС Неисправность
        $204:  tState:= 0+4+2+1;           //ШС Готов к восстановлению
        $205:  tState:= 0+0+2+1;           //ШС На проверке м.б. не обрабатывать ?
        $301:  tState:= 0+0+2+1;           //ШС Норма (Взят)
        $302:  tState:= 8+0+0+0;           //ШС Неисправность
        $303:  tState:= 0+4+2+0;           //ШС Внимание
        $304:  tState:= 0+4+2+0;           //ШС Пожар
        $305:  tState:= 0+4+2+1;           //ШС Готов к восстановлению
        $401:  tState:= 0+0+0+0;           // ШС Обл. 0
        $402:  tState:= 0+0+0+1;           // ШС Обл. 1
        $403:  tState:= 8+0+0+0;           // ШС неисправность
        $404:  tState:= 0+0+0+0;           // ШС готов
        $405:  tState:= 0+0+2+0;           // ШС Обл. 2
        $406:  tState:= 0+0+2+1;           // ШС Обл. 3
        $407:  tState:= 0+4+0+0;           // ШС Трев. Обл. 0
        $408:  tState:= 0+4+0+1;           // ШС Трев. Обл. 1
        $409:  tState:= 0+4+2+0;           // ШС Трев. Обл. 2
        $40A:  tState:= 0+4+2+1;           // ШС Трев. Обл. 3
        $501:  tState:= 0+0+2+1;           // ИУ вкл
        $502:  tState:= 0+0+0+1;           // ИУ выкл
        $503:  tState:= 0+0+0+1;           // ИУ задержка вкл
        $504:  tState:= 8+0+0+0;           // ИУ неисправность
        $601:  tState:= $01;               // ТД Норма
        $602:  tState:= $02;               // ТД Дверь открыта
        $603:  tState:= $03;               // ТД Удержание
        $604:  tState:= $04;               // ТД Взлом
        $605:  tState:= $05;               // ТД Заблокирована
        $606:  tState:= $06;               // ТД Разблокирована
        $607:  tState:= $07;               // ТД Нападение
        $701:  tState:= 0+0+0+1;           // Терм. норма
        $702:  tState:= 0+0+2+1;           // Терм. заблокирован

        $8301: tState:= $01; // Оборудование ТС в норме
        $8302: tState:= $28; // Оборудование ТС не найдено
        $8303: tState:= $28; // Оборудование ТС не сконфигурировано
        $8304: tState:= $28; // Оборудование отключено (неисправность ТС, ссылка на не существующее оборудование)
        $8305: tState:= $28; // Потеря связи с оборудованием ТС
        $8306: tState:= $28; // Потеря связи с ЛБ
        $8307: tState:= $28; // Неисправность оборудования ТС
        $8308: tState:= $28; // Объект ТС отключен. Опрос выкл.
        $8309: tState:= $28; // Шунтирование линии связи в СКЛБ
        $830A: tState:= $28; // КЗ линии связи в СКЛБ
        $830B: tState:= $28; // Готов к восстановлению

        else Raise Exception.Create( Format('ТС [%d] неизвестное состояние %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[23]+rbuf[22] ]) );
      end;//case 256*rbuf[23]+rbuf[22]

      //2 проход (HW+Событие)
      //Отсекание неизв. + откл.
      if (tState and $50)=0 then
      case ptc^.Kind of

        1..3:
        begin
          //В
          if ((ptc^.Kind=1)and((rbuf[24] and 1)>0))or(ptc^.Kind<>1) then
            tState:= tState or 2;
          //
          case ptc^.HWType of
            32:
            begin
              //Н
              if (rbuf[19] and $08)>0 then
                tState:= tState or $08;
            end;//32:
            1,4,9,16,17:
            begin
              //HW (готовность)
              if ptc^.Kind=1
                then j:= (rbuf[24] and 6) shr 1
                else j:= rbuf[24];
              if j=0
                then tState:= tState or $01
                else tState:= tState and $fe;
            end;//1,4,9,16,17:
          end;//case ptc^.HWType
          //СНТ
          case 256*rbuf[21]+rbuf[20] of
            0:;
            $0103,
            $0201,
            $0301: tState:= tState or $04; //т
            $0104,
            $0202,
            $0302: tState:= tState or $08; //н
            $8302: tState:= tState or $28; //сн
            else Raise Exception.Create( Format('ТС [%d] неизвестное событие %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
          if option.NReadyOnCheck then
            if (tState and $08)>0 then
              tState:= tState and $fe;
        end; //1..3:

        4:
        begin
          //зануление мл. бита данных
          tState:= tState and $fc;
          //н
          case rbuf[24] of
            0: tState:= tState or $00; //обл.0
            1: tState:= tState or $01; //обл.1
            2: tState:= tState or $08; //+н
            3: tState:= tState or $02; //обл.2
            4: tState:= tState or $03; //обл.3
            else Raise Exception.Create( Format('ТС [%d] неизвестное значение [24] %.2х', [ 256*rbuf[18]+rbuf[17], rbuf[24] ]) );
          end;
          //СНТ
          case 256*rbuf[21]+rbuf[20] of
            $0,
            $4,
            $0401,
            $0402,
            $0406,
            $0407:;
            $0403: tState:= tState or $08; //н
            $8302: tState:= tState or $28; //сн
            $0404,
            $0405,
            $0408,
            $0409: tState:=tState or $04; //т
            else Raise Exception.Create( Format('ТС [%d] неизвестное событие %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//4

        5:
        begin
          if (rbuf[24] and 1)>0 then
            tState:=tState or $02;        // вкл.
          //сн
          case 256*rbuf[21]+rbuf[20] of
            $0:;
            $0504: tState:= tState or $08; //н
            $8302: tState:= tState or $28; //сн
            else Raise Exception.Create( Format('ТС [%d] неизвестное событие %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//5

        6:
        begin
        {
typedef struct {
char fLockOpen:1; // 1 – замок открыт
char DoorState:2; // состояние двери
char WorkState:2; // рабочее состояние
uchar AuthorizationErrorCounter; // счетчик ошибок авторизации
uint LastUserRequestResult; // результат последнего запроса
}

{APState;
Состояние двери:
#define APDOORSTATE_CLOSED 0 // закрыта
#define APDOORSTATE_OPEN 1 // открыта
#define APDOORSTATE_NOCLOSED 2 // удержание
#define APDOORSTATE_ALARM 3 // взлом

Рабочее состояние:
#define APSTATE_NORM 0 // норма
#define APSTATE_BLOCKED 1 // заблокирована
#define APSTATE_DEBLOCKED 2 // разблокирована
        }
          case 256*rbuf[21]+rbuf[20] of
            $0,
            $60c,
            $60d:;
            $605:  tState:= $03; //уд.
            $606:  tState:= $04; //вз.
            $8302: tState:= $28; //сн
            else Raise Exception.Create( Format('ТС [%d] неизвестное событие %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//6

        7:
        begin
          if (rbuf[24] and 1)>0 then
            tState:= tState or $02;
          case 256*rbuf[21]+rbuf[20] of
            $0:;
            $704:  tState:= tState or $04;  //т
            $8302: tState:= tState or $28; //сн
            else Raise Exception.Create( Format('ТС [%d] неизвестное событие %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//7

        else Raise Exception.Create( Format('ТС [%d] неизвестый тип %.4x', [ 256*rbuf[18]+rbuf[17], ptc^.Kind ]) );
      end; //case ptc^.Kind


      //отсылаются на ВУ нетипичные для 8D события в режиме 3, 33 Активность, Готовность
      Init(mes);
      mes.SysDevice:= SYSTEM_OPS;
      mes.NetDevice:= rub.NetDevice;
      mes.BigDevice:= rub.BigDevice;
      mes.SmallDevice:= ptc^.ZoneVista;
      //
      if (tState and $40)=$00 then
        ptc^.State:= ptc^.State and {bf}$3f; //изм.96

      //================================================================================//
      // Эту кухню нужно переделать в ptc^.State:= tState; с отсроченным вычитванием 85 //
      // Здесь ТС абстрагирован от
      //================================================================================//
      // vvv

      case ptc^.Kind of
      //
      1..3:
      begin
        mes.TypeDevice:= 5;
        //
        //Готовность
        if (tState and $01)<>(ptc^.State and $01) then    //=$11 включился
        if (tState and $10)=0 then // включен
        if rub.WorkTime then
        case (tState and $05) of
          $00:
          begin
            ptc^.State:= ptc^.State and $fe;
            mes.Code:= R8_SH_NOTREADY;
            aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' не готов');
            aMain.Send(mes);
          end;
          $01:
          begin
            ptc^.State:= ptc^.State or $01;
            mes.Code:= R8_SH_READY;
            aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' готов');
            aMain.Send(mes);
          end;
          $04:
          begin
            ptc^.State:= ptc^.State and $fe;
            mes.Code:= R8_SH_NOTREADY_IN_ALARM;
            aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' не готов в тревоге');
            aMain.Send(mes);
          end;
          $05:
          begin
            ptc^.State:= ptc^.State or $01;
            mes.Code:= R8_SH_READY_IN_ALARM;
            aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' готов в тревоге');
            aMain.Send(mes);
          end;
        end;//case



        //Внимание! При восстановлении снятого ШС пользователь=0
        if (tState and $0c)<>(ptc^.State and $0c) then
        if (tState and $1e)=0 then // включен
        if rub.WorkTime then
        begin
          ptc^.State:= ptc^.State and $f3;
          mes.Code:= R8_SH_RESTORE;
          aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista) + ' восстановлен');
          aMain.Send(mes);
        end;

        //Откл.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_SH_OFF;
          aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' отключен');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef; //здесь на уже восстановленный ТС может наложиться старая сброшенная тревога
          mes.Code:= R8_SH_ON;
          aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' подключен');
          aMain.Send(mes);
        end;

        // Тек. сост. в режиме загрузки
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      4:
      begin
        mes.TypeDevice:= 5;

        //Откл.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_SH_OFF;
          aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' отключен');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_SH_ON;
          aMain.Log('SEND: ШС №'+inttostr(ptc^.ZoneVista)+ ' подключен');
          aMain.Send(mes);
        end;

        // Тек. сост. в режиме загрузки
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      5:
      begin
        mes.TypeDevice:= 7;
        //Откл.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_RELAY_OFF;
          aMain.Log('SEND: Реле №'+inttostr(ptc^.ZoneVista)+ ' отключено');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_RELAY_ON;
          aMain.Log('SEND: Реле №'+inttostr(ptc^.ZoneVista)+ ' подключено');
          aMain.Send(mes);
        end;
        // Тек. сост. в режиме загрузки
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      6:
      begin
        mes.SysDevice:= 1; //изм.08.11.15
        mes.TypeDevice:= 2; //изм.08.11.15
        //Откл.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_AP_OFF;
          aMain.Log('SEND: ТД №'+inttostr(ptc^.ZoneVista)+ ' отключена');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_AP_ON;
          aMain.Log('SEND: ТД №'+inttostr(ptc^.ZoneVista)+ ' подключена');
          aMain.Send(mes);
        end;

        //Состояние
        if (tState and $07)<>(ptc^.State and $07) then
        if (tState and $38)=0 then // включен и исправен
        if rub.WorkTime then
        case (tState and $07) of
          1: //восстановлена
          begin
            ptc^.State:= tState;
            mes.Code:= SUD_DOOR_CLOSE{R8_AP_RESET};
            aMain.Log('SEND: ТД №'+inttostr(ptc^.ZoneVista) + ' в норме (сброс)');
            aMain.Send(mes);
          end;
          2: //Открыта
          begin
            ptc^.State:= tState;
            mes.Code:= SUD_DOOR_OPEN{R8_AP_DOOROPEN};
            aMain.Log('SEND: ТД №'+inttostr(ptc^.ZoneVista) + ' открыта');
            aMain.Send(mes);
          end;
        end;//case
{
        $601:  tState:= $01;               // ТД Норма
        $602:  tState:= $02;               // ТД Дверь открыта
        $603:  tState:= $03;               // ТД Удержание
        $604:  tState:= $04;               // ТД Взлом
        $605:  tState:= $05;               // ТД Заблокирована
        $606:  tState:= $06;               // ТД Разблокирована
        $607:  tState:= $07;               // ТД Нападение
}
        // Тек. сост. в режиме загрузки
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      7:
      begin
        mes.TypeDevice:= 8;
        //Откл.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_TERM_OFF;
          aMain.Log('SEND: Терм. №'+inttostr(ptc^.ZoneVista)+ ' отключен');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_TERM_ON;
          aMain.Log('SEND: Терм. №'+inttostr(ptc^.ZoneVista)+ ' подключен');
          aMain.Send(mes);
        end;
        // Тек. сост. в режиме загрузки
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      else Raise Exception.Create('Неизвестный тип ТС 56CDCB-49412345:'+inttostr(ptc^.Kind));
      end; //case p^.Kind

      // ^^^
      //================================================================================//
      // Эту кухню нужно переделать в ptc^.State:= tState; с отсроченным вычитванием 85 //
      //================================================================================//



      //Вывод состояния
      if option.Logged_OnReadBCPStateDebug then
      begin
        st:= Format(' [%.4x, %.4x] <-> ', [ 256*rbuf[21]+rbuf[20] , 256*rbuf[23]+rbuf[22] ]);
        st:= st + Format('[%.2x...%.2x%.2x%.2x%.2x] ', [ rbuf[19], rbuf[24], rbuf[25], rbuf[26], rbuf[27] ]);
        aMain.StateString(2, ptc, ptc^.State, st);
        st:= 'Инфо >>> ' + st;
        aMain.Log(st);
      end;

      //Вывод неизв. сост.
      if (tState and $40)>0 then
        Raise Exception.Create( Format('ТС [%d] неизвестное вычисленное состояние %d', [ 256*rbuf[18]+rbuf[17], tState ]) );

      //вычисляются состояния производных объектов (зон и др.)
      case ptc^.Kind of
        1..4: GetStateZN(ptc^.PartVista);
      end;

    end;//2:объект ТС


    3://объект СУ
    begin
      pcu:= rub.FindCU(65536*rbuf[15]+256*rbuf[17]+rbuf[16], 0);

      { СУ не найдено |
        это не запрос структуры состояния СУ |
        структуры состояния маркированного СУ
      }
      if (pcu=nil)or((rbuf[14]<>1)and(rbuf[14]<>2)) then
        exit;

      {
      Состояние для каждого типа СУ здесь не раскрывается,
      так как используется для внутренних задач БЦП.
      Все состояния СУ транслируются в конечном итоге
      в состояния связанных с ними ТС.
      }
      tState:= 0;
      if ((rbuf[18] and $02)=0) and ((pcu^.flags and $10)>0)
        then tState:= tState or $01
        else tState:= tState and $fe;
      {
      // Не работает т.к производитель нет бита адекватной трактовки состяния связи
      tState:= $01;
      }
      if (tState and $01)>0 then
      if (rbuf[18] and $04)>0
        then tState:= tState or $02
        else tState:= tState and $fd;
      {
      if (rbuf[22]=0)and(rbuf[23]=0)and(rbuf[24]=0) then  //!!!!!!!!!!!!!
      tState:=0;
      }
      //
      if option.Logged_OnReadBCPStateDebug then
      begin
        st:= Format(' [%.2x,%.2x,%.2x,%.2x,%.2x,%.2x,%.2x,%.2x,%.2x] ', [rbuf[18], rbuf[19], rbuf[20], rbuf[21], rbuf[22], rbuf[23], rbuf[24], rbuf[25], rbuf[26] ]);
        st:= st + Format(' F=%.2x ->', [ pcu^.flags ]);
        aMain.StateString(0, pcu, tState, st);
        st:= 'Инфо >>> ' + st;
        aMain.Log(st);
      end;
      //
      Init(mes);
      mes.SysDevice:= SYSTEM_OPS;
      mes.NetDevice:= rub.NetDevice;
      mes.BigDevice:= rub.BigDevice;
      mes.SmallDevice := pcu^.Number;
      mes.TypeDevice:= 9;
      mes.Code:= 0;
      if (tState and 2)<>(pcu^.State and 2) then
      if (tState and 2)=0
        then mes.Code:=R8_CU_CLOSE
        {else mes.Code:=R8_CU_OPEN};
      if (mes.Code>0)and(rub.comd<>22) then
      begin
        aMain.Log( Format('SEND: СУ №%d закрыт', [pcu^.Number]) );
        aMain.Send(mes);
      end;
      pcu^.State:=tState;
    end;//3:объект СУ
    else Raise Exception.Create ('Неизвестный тип объекта F640F-2967-402E-BB45-EF2143E03C55:'+inttostr(rbuf[13]));

  end; //case rbuf[13] of


 //`````````````````````````````````````````````````````````````````````````````
 //````` Событие из буфера  (они лишь учавствуют в отправке mes: KSBMes) ````````
 //`````````````````````````````````````````````````````````````````````````````
 // !!! НЕ ПРОВЕРЯЙ ЛИШНЕЕ !!!
 //
  $8D:
  begin
    for i:=1 to ((rbuf[5]-10) div 16)  do
    begin
      //st:={#13+#10+}DateTimeToStr(UnPackTime(rbuf[16*i]))+ '  Тип объекта='+inttostr(rbuf[16*i+4])+'  Событие='+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
      //st:=st+#13+#10; for j:=0 to 15 do st:=st+inttohex(rbuf[16*i+j],2)+'-';
      //aMain.Memo1.Lines.Add(st);

      Init(mes);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.SendTime:= UnPackTime(rbuf[16*i]);
      NewMes:= True;
      if (option.StartDrvTime>mes.SendTime) then
        NewMes:= False;
      //
      case rbuf[16*i+4] of //тип объекта
        0:;

        1://Зона
        begin
          pzn:= rub.FindZN(rbuf[16*i+5], 0);
          if (pzn=nil) then
            case rbuf[16*i+9]+256*rbuf[16*i+10] of
              $8280:
              begin
                //запуск таймера принудительного завершения работы
                continue;
              end;
              $8281, $8282:
                continue;
            end;

          j:= pzn^.Number;
          mes.TypeDevice:= 4;
          TheKSBParam.WriteIntegerParam(mes, data, 'Номер зоны', j);

          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8280:
            begin
              st:= 'Создана зона ['+ValToStr(rbuf[16*i+5])+'] N='+inttostr(j) +' пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_ZONE_CREATE;
              mGetZone(rbuf[16*i+5], j);
            end;
            $8281:
            begin
              st:= 'Редактирована зона ['+ValToStr(rbuf[16*i+5])+'] N='+inttostr(j) +' пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_ZONE_CHANGE;
              mGetZone(rbuf[16*i+5], j);
            end;
            $8282:
            begin
              rub.ZN.Remove(pzn);
              Dispose(pzn);
              st:= 'Удалена зона ['+ValToStr(rbuf[16*i+5])+'] N='+inttostr(j) +' пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);;
              mes.Code:= R8_ZONE_DELETE;
              SaveR8c('ЗОНА', inttostr(j), '');
              rub.NeedSaveR8h:= True;
            end;
            else
              Raise Exception.Create ('Неизвестное событие зоны E53367E3-710A-4678-873E-C8B492D44206:'+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2));
          end;//case rbuf[16*i+9]+256*rbuf[16*i+10] of
        end;//1:Зона


        2://ТС
        begin
          ptc:= rub.FindTC(rbuf[16*i+7]+256*rbuf[16*i+8], 0);
          if ptc=nil then
          begin
            //запуск таймера принудительного завершения работы
            continue;
          end;

          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            1: //квитирование
            begin
              case ptc^.Kind of
                1..4: st:= 'Пользователь №'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' нажал "Принять" для ШС №'+inttostr(ptc^.ZoneVista);
                5: st:= 'Пользователь №'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' нажал "Принять" для реле №'+inttostr(ptc^.ZoneVista);
                6: st:= 'Пользователь №'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' нажал "Принять" для ТД №'+inttostr(ptc^.ZoneVista);
                7: st:= 'Пользователь №'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' нажал "Принять" для терминала №'+inttostr(ptc^.ZoneVista);
                else Raise Exception.Create ('Неизвестный тип ТС 11A97E80-CDCB70441:'+inttostr(ptc^.Kind));
              end;
              mes.Code:=R8_SH_HANDSHAKE;
            end;
            $101: //+в Постановка на охрану
            begin
              ptc^.State:= ptc^.State or $02;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_ARMED;
              st:= 'Постановка на охрану ШС №'+inttostr(ptc^.ZoneVista)+ ' пользователем №'+ inttostr(ptc^.tempUser);
              CheckZoneOperation(ptc^.PartVista, 1);
            end;
            $102: //-в Снятие с охраны
            begin
              ptc^.State:= ptc^.State and $fd;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_DISARMED;
              st:= 'Снятие с охраны ШС №'+inttostr(ptc^.ZoneVista)+ ' пользователем №'+ inttostr(ptc^.tempUser);
              CheckZoneOperation(ptc^.PartVista, 0);
            end;
            $103: //+т Проникновение. Переход физического ШС в состояние «Тревога», когда объект находится в состоянии «Взято».
            begin
              ptc^.State:= (ptc^.State and $fe) or $04;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_ALARM;
              st:= 'Тревога проникновения ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $104: //+н Неисправность. Переход физического ШС в состояние «Неисправность», когда объект находится в состоянии «Взято», «Готов», «Не готов».
            begin
              ptc^.State:= ptc^.State or $08;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_CHECK;
              st:= 'Неисправность (КЗ) ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $105: //+г+н Готов постановке на охрану или восстановлению. Переход физического ШС в состояние «Норма».
            begin
              ptc^.State:= ptc^.State or $01;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_READY;
              st:= 'Переход в норму ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $106: //-г Не готов к постановке на охрану. Переход физического ШС в состояние «Тревога», когда объект находится в состоянии «Готов» или «Проникновение». Переход физического ШС в состояние «Неисправность», когда объект находится в состоянии «Проникновение» или «Неисправность».
            begin
              ptc^.State:= ptc^.State and $fe;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_NOTREADY;
              st:= 'Не готов к постановке на охрану ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $107: //-т Сброс ШС
            begin
              ptc^.State:= ptc^.State and $fb;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_RESET;
              st:='Сброс ШС №'+inttostr(ptc^.ZoneVista)+ ' пользователем №'+ inttostr(ptc^.tempUser);
            end;
            $108: //Ничего. Пропуск не готового к постановке на охрану объекта
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_BYPASS;
              st:= 'Пропуск ШС №'+inttostr(ptc^.ZoneVista)+ ' пользователем №'+ inttostr(ptc^.tempUser);
            end;
            $109: //-в Задержка на вход. Переход физического ШС в состояние «Тревога», когда объект находится в состоянии «Взято» и для него определена задержка на вход.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_INDELAY;
              st:= 'Задержка на вход при снятии с охраны ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $10A: //+в Задержка на выход. Событие выдается при постановке объекта на охрану, если для него определена задержка на выход.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_OUTDELAY;
              st:= 'Задержка на выход при постановке на охрану ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $10B: //Ожидание готовности. При постановке на охрану, «Не готов»
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_WAITFORREADY;
              st:= 'Ожидание готовности ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $10C: //Ожидание готовности. При постановке на охрану, «Не готов»
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_WAITFORREADYCANCEL;
              st:= 'Отмена ожидания готовности ШС №'+inttostr(ptc^.ZoneVista);
            end;
            //ШСохр,трев (связь-опрос ТС -неисправность-тревога- взятие- готовность   )     с-о-н-т-в-г
            $201://+т  Тревога. Переход физического ШС в состояние «Тревога», когда объект находится в со-стоянии «Норма».
            begin
              ptc^.State:= ptc^.State or $04;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_ALARM;
              st:= 'Тревога ШС №'+inttostr(ptc^.ZoneVista);
            end;
            $202://+н  Неисправность. Переход физического ШС в состояние «Неисправность», когда объект находится в состоянии «Норма».
            begin ptc^.State:= ptc^.State or $08;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_CHECK;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' неисправен';
            end;
            $203://-т Сброс ШС
            begin
              ptc^.State:= ptc^.State and $fb;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_RESET;
              st:= 'Сброс ШС №'+inttostr(ptc^.ZoneVista)+ ' пользователем №'+ inttostr(ptc^.tempUser);
            end;
            $204://+г Готов к восстановлению. Переход физического ШС в состояние «Норма».
            begin
              ptc^.State:= ptc^.State or $01;
              ptc^.tempUser:=0;
              mes.Code:= R8_SH_READY;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' в норме';
            end;
            $205://-г Не готов к восстановлению. Переход физического ШС в состояние «Тревога» или «Неисправность», когда объект находится в состоянии «Тревога». Переход физического ШС в состояние «Неисправность», когда объект находится в состоянии «Неисправность».
            begin
              ptc^.State:= ptc^.State and $fe;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_NOTREADY;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' неготов';
            end;
            $206://Режим проверки
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];;
              mes.Code:= R8_SH_TEST;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' Режим проверки. Пользователь №'+ inttostr(ptc^.tempUser);;
            end;
            $207://Проверка пройдена
            begin
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_TESTPASSEDOK;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' Проверка пройдена';
            end;
            $208://Проверка не пройдена
            begin
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_TESTTIMEOUT;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' Проверка не пройдена';
            end;

            //ШСпож,трев (связь-опрос ТС -неисправность-пожар- взятие- готовность   )     с-о-н-п-в-г
            $301://+т  Тревога. Переход физического ШС в состояние «Тревога», когда объект находится в со-стоянии «Норма».
            begin
              ptc^.State:= ptc^.State or $04;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_FIRE_ALARM;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' Пожар';
            end;
            $302://+н  Неисправность. Переход физического ШС в состояние «Неисправность», когда объект находится в состоянии «Норма».
            begin ptc^.State:= ptc^.State or $08;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_CHECK;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' неисправен';
            end;
            $303://Внимание. при норме
            begin
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_FIRE_ATTENTION;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' внимание';
            end;
            $304://-т Сброс ШС
            begin
              ptc^.State:= ptc^.State and $fb;
              ptc^.tempUser:=rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_RESET;
              st:= 'Сброс ШС №'+inttostr(ptc^.ZoneVista)+ ' пользователем №'+ inttostr(ptc^.tempUser);
            end;
           $305://+г Готов к восстановлению. Переход физического ШС в состояние «Норма».
            begin
              ptc^.State:= ptc^.State or $01;
              ptc^.tempUser:=0;
              mes.Code:= R8_SH_READY;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' в норме';
            end;
            $306://-г Не готов к восстановлению. Переход физического ШС в состояние «Тревога» или «Неисправность», когда объект находится в состоянии «Тревога». Переход физического ШС в состояние «Неисправность», когда объект находится в состоянии «Неисправность».
            begin
              ptc^.State:= ptc^.State and $fe;
              ptc^.tempUser:=0;
              mes.Code:= R8_SH_NOTREADY;
              st:= 'ШС №'+inttostr(ptc^.ZoneVista)+' неготов';
            end;
            //ШСтехн (связь-опрос ТС -неисправность-тревога- сост.2бит - сост.1бит)  с-о-н-т-2-1
            $401://Область 0. Переход физического ШС в состояние в область 0. Замкнуто для дискретных ШС
            begin
              ptc^.State:= (ptc^.State and $fc) or $00;
              mes.Code:= R8_TECHNO_AREA0;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 0';
            end;
            $402://Область 1. Переход физического ШС в состояние в область 1. Разомкнуто для дискретных ШС
            begin
              ptc^.State:= (ptc^.State and $fc) or $01;
              mes.Code:= R8_TECHNO_AREA1;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 1';
            end;
            $403://Неисправность. Переход физического ШС в состояние «Неисправность».
            begin
              ptc^.State:= (ptc^.State and $f0) or $08;
              mes.Code:= R8_SH_CHECK;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Неисправность';
            end;
            $404://Тревожная область 0. Переход физического ШС в состояние в область 0, область 0 сконфигурирована как тревожная
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $00;
              //исключение
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA0;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 0. Тревога';
            end;
            $405://Тревожная область 1. Переход физического ШС в состояние в область 1, область 1 сконфигурирована как тревожная
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $01;
              //исключение
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA1;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 1. Тревога';
            end;
            $406://Область 2. Переход физического ШС в состояние в область 2
            begin
              ptc^.State:= (ptc^.State and $fc) or $02;
              mes.Code:= R8_TECHNO_AREA2;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 2';
            end;
            $407://Область 3. Переход физического ШС в состояние в область 3
            begin
              ptc^.State:= (ptc^.State and $fc) or $03;
              mes.Code:= R8_TECHNO_AREA3;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 3';
            end;
            $408://Тревожная область 2. Переход физического ШС в состояние в область 2, область 2 сконфигурирована как тревожная
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $02;
              //исключение
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA2;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 2. Тревога';
            end;
            $409://Тревожная область 3. Переход физического ШС в состояние в область 3, область 3 сконфигурирована как тревожная
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $03;
              //исключение
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA3;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= 'Тех.ШС №'+inttostr(ptc^.ZoneVista)+'. Область 3. Тревога';
            end;
            //реле (связь-резерв-неисправность-резерв-вкл-резерв) с-х-х-х-вкл-х
            $501://вкл.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State or $02;
              mes.Code:= R8_RELAY_1;
              st:= 'Реле №'+inttostr(ptc^.ZoneVista)+' включено';
            end;
            $502://выкл.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $fd;
              mes.Code:= R8_RELAY_0;
              st:= 'Реле №'+inttostr(ptc^.ZoneVista)+' выключено';
            end;
            $503://Задержка включения
            begin
              ptc^.State:= ptc^.State and $fd;
              mes.Code:= R8_RELAY_WAITON;
              st:= 'Реле №'+inttostr(ptc^.ZoneVista)+'. Задержка включения';
            end;
            $504://неисправно
            begin
              ptc^.State:= ptc^.State or $08;
              mes.Code:= R8_RELAY_CHECK;
              st:= 'Реле №'+inttostr(ptc^.ZoneVista)+' неисправно';
            end;
            $601://Вход (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $7;//ptc^.State:= $01;
              mes.Code:= R8_AP_IN;
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Вход. Проход пользователя №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $602://Выход (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $7;//ptc^.State:= $01;
              mes.Code:= R8_AP_OUT;
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Выход. Проход пользователя №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $603://Проход
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $7;//ptc^.State:= $01;
              mes.Code:= R8_AP_PASSENABLE;
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Проход по команде «Открыть замок» пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $604://Открывание двери
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $02;
              mes.Code:= R8_AP_DOOROPEN;
              mes.Code:= SUD_DOOR_OPEN;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Открывание двери пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $605://Удержание (!)
            begin
              ptc^.State:= $03;
              mes.Code:= R8_AP_DOORNOCLOSED;
              mes.Code:= SUD_HELD;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Удержание двери';
            end;
            $606://Взлом (!)
            begin
              ptc^.State:= $04;
              mes.Code:= R8_AP_DOORALARM;
              mes.Code:= SUD_FORCED;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Взлом двери';
            end;
            $607://Закрывание двери
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_DOORCLOSE;
              mes.Code:= R8_AP_DOORCLOSE;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Закрывание двери пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $608://Блокирование (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $05;
              mes.Code:= R8_AP_BLOCKING;
              mes.Code:= RIC_MODE;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Блокирование ТД пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Level:= APModeToRostek(ptc);
              mes.Partion:= APStateToRostek(ptc);
            end;
            $609://Разблокирование (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $06;
              mes.Code:= R8_AP_DEBLOCKING;
              mes.Code:= RIC_MODE;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Разблокирование ТД пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Level:= APModeToRostek(ptc);
              mes.Partion:= APStateToRostek(ptc);
            end;
            $60A://Выход по кнопке (!)
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_EXITBUTTON;
              mes.Code:= SUD_GRANTED_BUTTON;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Выход по кнопке.';
            end;
            $60B://Восстановление (сброс)
            begin
              mes.Code:= ApEventAfterReset(ptc^.State);
              case mes.Code of
                RIC_MODE:
                begin
                  ptc^.State:= $01;
                  st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Сброс (Режим норма). Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                end;
                SUD_RESETHELD:
                begin
                  ptc^.State:= $01;
                  st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Сброс (Отбой удержания). Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                end;
                SUD_RESETFORCED:
                begin
                  ptc^.State:= $01;
                  st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Сброс (Отбой взлома). Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                end;
                else
                  st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Сброс (БЕЗ ОТПРАВКИ). Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              end;//case
              mes.Level:= APModeToRostek(ptc);
              mes.Partion:= APStateToRostek(ptc);
            end;
            $60C://Ошибка авторизации
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_AUTHORIZATIONERROR;
              if ptc^.tempUser=0 then
              begin
                mes.Code:= SUD_NO_CARD;
                st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Нет карты в БЦП';
              end
              else
              begin
                mes.Code:= SUD_BAD_PIN;
                st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Доступ запрещен. Неверный пинкод пользователя №'+inttostr(ptc^.tempUser);
              end;
            end;
            $60D://подбор (!)
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_CODEFORGERY;
              mes.Code:= SUD_ACCESS_CHOOSE;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Попытка подбора кода пользователем №' + inttostr(ptc^.tempUser);
              // v !!!
              {
              amain.Log('>1>$60D:подбор');       //му    !!!
              amain.Log('>2>ТД №'+inttostr(ptc^.ZoneVista)+' Попытка подбора кода пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]));  //му !!!
              amain.Log('>3>ТД №'+inttostr(ptc^.ZoneVista)+' Попытка подбора кода пользователем №' + inttostr(ptc^.tempUser));  //му !!!
              }
              //^ !!!
            end;
            $60E://Запрос прохода
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_REQUESTPASS;
              mes.Code:= R8_AP_REQUESTPASS;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Запрос прохода пользователем №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $60F://Нападение
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $07;
              mes.Code:= R8_AP_FORCING;
              mes.Code:= R8_AP_FORCING;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Нападение. Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $610://Нарушение правил прохода
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_APBERROR;
              mes.Code:= SUD_BAD_APB;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Нарушение правил прохода. Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $611://Доступ разрешен
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_ACCESSGRANTED; //
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Доступ разрешен. Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $612://Таймаут
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_ACCESSTIMEOUT;
              mes.Code:= R8_AP_ACCESSTIMEOUT;
              st:= 'ТД №'+inttostr(ptc^.ZoneVista)+' Таймаут. Пользователь №'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            //терминал (связь-резерв -неисправность-тревога-откр-готовность) с-х-х-х-вкл-х
            $701: //Запрос пользователя
            begin
              mes.Code:= R8_TERM_REQUEST;
              st:= 'Терминал №'+inttostr(ptc^.ZoneVista)+'. Запрос пользователя';
            end;
            $702: //Блокирование работы терминала
            begin
              ptc^.State:= ptc^.State or $02;
              mes.Code:= R8_TERM_BLOCKING;
              st:= 'Терминал №'+inttostr(ptc^.ZoneVista)+'. Блокировка';
            end;
            $703: //Ошибка авторизации пользователя
            begin
              mes.Code:= R8_TERM_AUTHORIZATIONERROR;
              st:= 'Терминал №'+inttostr(ptc^.ZoneVista)+'. Ошибка авторизации';
            end;
            $704: //Попытка подбора кода. Событие выдается после трех, сделанных подряд, ошибок авто-ризации пользователя.
            begin
              ptc^.State:= ptc^.State or $04;
              mes.Code:= R8_TERM_CODEFORGERY;
              st:= 'Терминал №'+inttostr(ptc^.ZoneVista)+'. Попытка подбора кода';
            end;
            $705: //Восстановление работы терминала после блокирования
            begin
              ptc^.State:= ptc^.State and $f1;
              mes.Code:= R8_TERM_RESET;
              st:= 'Терминал №'+inttostr(ptc^.ZoneVista)+'. Восстановление работы терминала после блокирования';
            end;
            $706: //Пользовательская команда
            begin
              mes.Code:= R8_TERM_USERCOMMAND;
              st:= 'Терминал №'+inttostr(ptc^.ZoneVista)+'. Пользовательская команда';
            end;

            $8301: //-т Восстановление нормального состояния ТС, т.е. исключение ТС из тревожного списка БЦП
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13]; //изм.7.3
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  mes.Code:= R8_SH_RESTORE;
                  st:= 'ШС №'+inttostr(ptc^.ZoneVista)+'. Восстановлен пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= ptc^.State and $03;
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  mes.Code:= R8_RELAY_RESTORE;
                  st:= 'Реле №'+inttostr(ptc^.ZoneVista)+'. Восстановлено пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= ptc^.State and $03;
                end;
                6:
                begin
                  mes.TypeDevice:= 2;
                  mes.Code:= R8_AP_RESTORE;
                  st:= 'ТД №'+inttostr(ptc^.ZoneVista)+'. Восстановлена пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= $01;
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  mes.Code:= R8_TERM_RESTORE;
                  st:= 'Терминал №'+inttostr(ptc^.ZoneVista)+'. Восстановлен пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= ptc^.State and $03;
                end;
                else Raise Exception.Create ('Неизвестный тип ТС 468АЕ-CDCB-4944-B013-C79901D70001:'+inttostr(ptc^.Kind));
              end;//case
            end;

            $8302: //+т Неисправность оборудования ТС. Данное событие генерируется при переходе оборудования, с которым связан объект ТС, в состояние, не обеспечивающее нормальное функционирование ТС.
            begin
              ptc^.State:= ptc^.State or $20{28}; //изм.96
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  st:= 'ШС №' + inttostr(ptc^.ZoneVista)+'. Оборудование неисправно';
                  mes.Code:= R8_SH_HW_FAULT;
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  st:= 'Реле №' + inttostr(ptc^.ZoneVista)+'. Оборудование неисправно';
                  mes.Code:= R8_RELAY_HW_FAULT;
                end;
                6:
                begin
                  mes.SysDevice:= SYSTEM_SUD;
                  mes.TypeDevice:= 2;
                  st:= 'ТД №' + inttostr(ptc^.ZoneVista)+'. Оборудование неисправно';
                  mes.Code:= R8_AP_HW_FAULT;
                  mes.Code:= SUD_LOST_LINK_READER;
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  st:= 'Терминал №' + inttostr(ptc^.ZoneVista)+'. Оборудование неисправно';
                  mes.Code:= R8_TERM_HW_FAULT;
                end;
                else Raise Exception.Create ('Неизвестный тип ТС 753009556-9901D70002:' + inttostr(ptc^.Kind));
              end;//case
            end;

            $8303: //-н Восстановление работоспособности оборудования ТС
            begin
              ptc^.State:= ptc^.State and $0f;
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  st:= 'ШС №' + inttostr(ptc^.ZoneVista)+'. Оборудование в норме';
                  mes.Code:= R8_SH_HW_OK;
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  st:= 'Реле №' + inttostr(ptc^.ZoneVista)+'. Оборудование в норме';
                  mes.Code:= R8_RELAY_HW_OK;
                end;
                6:
                begin
                  mes.TypeDevice:= 2;
                  st:= 'ТД №'+inttostr(ptc^.ZoneVista)+'. Оборудование в норме';
                  mes.Code:= R8_AP_HW_OK;
                  mes.Code:= SUD_SET_LINK_READER;
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  st:= 'Терминал №' + inttostr(ptc^.ZoneVista)+'. Оборудование в норме';
                  mes.Code:= R8_TERM_HW_OK;
                end;
                else Raise Exception.Create ('Неизвестный тип ТС 18891D70003:' + inttostr(ptc^.Kind));
              end;//case
            end;

            $8304: // нет прав на управление ТС, не поверено !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  mes.Code:= R8_SH_NORIGTH;
                  st:= Format('ШС №%d. Нет прав управления у пользователя №%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  mes.Code:= R8_RELAY_NORIGTH;
                  st:= Format('Реле №%d. Нет прав управления у пользователя №%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                6:
                begin
                  mes.TypeDevice:= 2;
                  mes.Code:= R8_AP_NORIGTH;
                  mes.Code:= SUD_BAD_LEVEL;
                  st:= Format('ТД №%d. Нет прав управления у пользователя №%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  mes.Code:= R8_TERM_NORIGTH;
                  st:= Format('Терминал №%d. Нет прав управления у пользователя №%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                else Raise Exception.Create ('Неизвестный тип ТС 6711AAEE-B013-C79901D70004:' + inttostr(ptc^.Kind));
              end;//case
            end;

            $8380: //Создано ТС
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', ptc^.ZoneVista);
                  st:='Создан ШС ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_SH_CREATE;
                end;
                5:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', ptc^.ZoneVista);
                  st:='Создано реле ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_RELAY_CREATE;
                end;
                6:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', ptc^.ZoneVista);
                  st:='Создана ТД ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_AP_CREATE;
                end;
                7:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', ptc^.ZoneVista);
                  st:='Создан терминал ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_TERM_CREATE;
                end;
                else Raise Exception.Create ('Неизвестный тип ТС 880EEBB1301D70004:' + inttostr(ptc^.Kind));
              end;//case
              st:= st + ' пользователем №' + inttostr(ptc^.tempUser);
              mGetTC(256*rbuf[16*i+8]+rbuf[16*i+7], rbuf[16*i], rbuf[16*i+9], rbuf[16*i+12]);
              mGetStateTC(256*rbuf[16*i+8]+rbuf[16*i+7], 1);
            end;

            $8381: //Редактировано ТС
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', ptc^.ZoneVista);
                  st:= 'Редактирован ШС ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_SH_CHANGE;
                end;
                5:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', ptc^.ZoneVista);
                  st:= 'Редактировано реле ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_RELAY_CHANGE;
                end;
                6:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', ptc^.ZoneVista);
                  st:= 'Редактирована ТД ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_AP_CHANGE;
                end;
                7:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', ptc^.ZoneVista);
                  st:= 'Редактирован терминал ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_TERM_CHANGE;
                end;
                else Raise Exception.Create ('Неизвестный тип ТС 80100D-CDCB-4944-B013-C79901D70004:' + inttostr(ptc^.Kind));
              end;//case
              st:= st + ' пользователем №' + inttostr(ptc^.tempUser);
              mGetTC(256*rbuf[16*i+8]+rbuf[16*i+7], rbuf[16*i], rbuf[16*i+9], rbuf[16*i+12]);
              mGetStateTC(256*rbuf[16*i+8]+rbuf[16*i+7], 1);
            end;

            $8382: //Удалено ТС
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', ptc^.ZoneVista);
                  if ptc^.ZoneVista>SH_MAX then DeleteR8c('ШС', inttostr(ptc^.ZoneVista)) else SaveR8c('ШС', inttostr(ptc^.ZoneVista), '');
                  st:= 'Удален ШС ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_SH_DELETE;
                end;
                5:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', ptc^.ZoneVista);
                  if ptc^.ZoneVista>RL_MAX then DeleteR8c('РЕЛЕ', inttostr(ptc^.ZoneVista)) else SaveR8c('РЕЛЕ', inttostr(ptc^.ZoneVista), '');
                  st:= 'Удалено реле ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_RELAY_DELETE;
                end;
                6:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', ptc^.ZoneVista);
                  if ptc^.ZoneVista>AP_MAX then DeleteR8c('ТД', inttostr(ptc^.ZoneVista)) else SaveR8c('ТД', inttostr(ptc^.ZoneVista), '');
                  st:= 'Удалена ТД ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_AP_DELETE;
                end;
                7:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', ptc^.ZoneVista);
                  if ptc^.ZoneVista>TERM_MAX then DeleteR8c('ТЕРМИНАЛ', inttostr(ptc^.ZoneVista)) else SaveR8c('ТЕРМИНАЛ', inttostr(ptc^.ZoneVista), '');
                  st:= 'Удалено TERM ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_TERM_DELETE;
                end;
                else Raise Exception.Create ('Неизвестный тип ТС 33944D-CDCB-4944-B013-C79901D70004:' + inttostr(ptc^.Kind));
              end;//case
              st:= st + ' пользователем №' + inttostr(ptc^.tempUser);
              rub.TC.Remove(ptc);
              Dispose(ptc);
              GetStateZN(ptc^.PartVista); // запрос состояния ТС-ов зоны
              rub.NeedSaveR8h:= True;
            end;

            ELSE
              st:=Format('Неизвестное событие %x ТС типа %d', [ rbuf[16*i+9]+256*rbuf[16*i+10], rbuf[16*i+4] ]);

          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of

          //---------------------------------------//
          // окончательное формирование mes для ТС //
          //---------------------------------------//
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $1:
            begin
              case ptc^.Kind of
                1..4: mes.TypeDevice:=5;
                5: mes.TypeDevice:=7;
                6:
                begin
                  mes.SysDevice:= SYSTEM_SUD;
                  mes.TypeDevice:= 2;
                end;
                7: mes.TypeDevice:=8;
                else
                  Raise Exception.Create ('Неизвестный тип ТС 344E80-CDCB-4944-B013-C79901220004:' + inttostr(ptc^.Kind));
              end;
              mes.SmallDevice:= ptc^.ZoneVista;
            end;
            $101..$499:
            begin
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
            end;
            $501..$599:
            begin
              mes.TypeDevice:= 7;
              mes.SmallDevice:= ptc^.ZoneVista;
            end;
            $601..$699:
            begin
              mes.SysDevice:= SYSTEM_SUD;
              mes.TypeDevice:= 2; //считыватель
              mes.SmallDevice:= ptc^.ZoneVista;
            end;
            $701..$799:
            begin
              mes.TypeDevice:= 8;
              mes.SmallDevice:= ptc^.ZoneVista;
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $8301..$8304:
            begin
              case ptc^.Kind of
                6:
                begin
                  mes.SysDevice:= SYSTEM_SUD;
                  mes.TypeDevice:= 2; //считыватель
                end;
              end;//case
              mes.SmallDevice:= ptc^.ZoneVista;
            end;
            $8380..$8382:
            begin
              mes.TypeDevice:= 4;
              mes.SmallDevice:= 0;
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
          end;//case rbuf[16*i+9]+256*rbuf[16*i+10] of
          //
          case mes.Code of
            R8_SH_HANDSHAKE,
            R8_SH_ARMED,
            R8_SH_DISARMED,
            R8_SH_RESTORE,
            R8_RELAY_RESTORE,
            R8_RELAY_0,
            R8_RELAY_1,
            R8_TERM_RESTORE,
            R8_SH_BYPASS,
            R8_SH_RESET,
            R8_AP_IN,
            SUD_ACCESS_GRANTED,
            R8_AP_OUT,
            R8_AP_PASSENABLE,
            R8_AP_DOOROPEN,
            R8_AP_DOORCLOSE,
            R8_AP_BLOCKING,
            SUD_DOOR_CLOSE,
            R8_AP_DEBLOCKING,
            SUD_DOOR_OPEN,
            R8_AP_RESET,
            R8_AP_AUTHORIZATIONERROR,
            R8_AP_REQUESTPASS,
            R8_AP_FORCING,
            R8_AP_APBERROR,
            SUD_BAD_APB,
            R8_AP_ACCESSGRANTED,
            R8_AP_ACCESSTIMEOUT,
            //
            R8_ZONE_CREATE,
            R8_ZONE_CHANGE,
            R8_ZONE_DELETE,
            //
            R8_SH_CREATE,
            R8_SH_CHANGE,
            R8_SH_DELETE,
            R8_RELAY_CREATE,
            R8_RELAY_CHANGE,
            R8_RELAY_DELETE,
            R8_AP_CREATE,
            R8_AP_CHANGE,
            R8_AP_DELETE,
            R8_TERM_CREATE,
            R8_TERM_CHANGE,
            R8_TERM_DELETE,
            R8_SH_NORIGTH,
            R8_RELAY_NORIGTH,
            R8_TERM_NORIGTH:
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
          end;

          //if user=0
          case mes.Code of
            R8_SH_ARMED,
            R8_SH_DISARMED,
            R8_SH_RESTORE:
              if (ptc^.tempUser = 0) then
                if rub.TC.Count>0 then
                  for j:=0 to rub.TC.Count-1 do
                  begin
                    if PTTC(rub.TC.Items[j])^.PartVista=ptc^.PartVista then
                    if PTTC(rub.TC.Items[j])^.Kind in [1..3] then
                    if PTTC(rub.TC.Items[j])^.tempUser>0 then
                    begin
                      ptc^.tempUser:= PTTC(rub.TC.Items[j])^.tempUser;
                      st:= st + ' > ' + inttostr(ptc^.tempUser);
                      TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', ptc^.tempUser);
                      break;
                    end;
                  end;
          end;

          case mes.Code of
            R8_AP_IN,
            SUD_ACCESS_GRANTED,
            R8_AP_OUT,
            R8_AP_PASSENABLE,
            R8_AP_DOOROPEN,
            R8_AP_DOORCLOSE,
            R8_AP_BLOCKING,
            SUD_DOOR_CLOSE,
            R8_AP_DEBLOCKING,
            SUD_DOOR_OPEN,
            R8_AP_RESET,
            R8_AP_AUTHORIZATIONERROR,
            R8_AP_REQUESTPASS,
            R8_AP_FORCING,
            R8_AP_APBERROR,
            SUD_BAD_APB,
            R8_AP_ACCESSGRANTED,
            R8_AP_ACCESSTIMEOUT,
            R8_AP_NORIGTH,
            SUD_BAD_LEVEL,
            SUD_BAD_PIN:
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер карты', rbuf[16*i+12]+256*rbuf[16*i+13]);
          end;

          case mes.Code of
            SUD_ACCESS_CHOOSE:
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер карты', ptc^.tempUser);
          end;

          if option.Logged_OnReadBCPCalculateStateZone then
            aMain.Log('Logged_OnReadBCPCalculateStateZone: Событие зоны №'+inttostr(ptc^.PartVista)+ ', пользователь №'+ inttostr(ptc^.tempUser));

          case mes.Code of
            R8_SH_ALARM,
            R8_SH_RESTORE,
            R8_SH_ARMED,
            R8_SH_DISARMED,
            R8_SH_BYPASS,
            R8_SH_RESET:
            GetStateZN(ptc^.PartVista, ptc); //пересчет зоны для извлечения пользователя
          end;

        end; //2:ТС


        3://Оборудование-железо (по умолчанию панель)
        begin
          //определение pcu, mes.smalldevice, mes.user, NewMes
          pcu:= rub.FindCU(rbuf[16*i+6] + 256*rbuf[16*i+7] + 65536*rbuf[16*i+5], 0);
          //
          mes.TypeDevice:= 4;
          if pcu<>nil then
          begin
            mes.TypeDevice:= 9;
            mes.SmallDevice:= pcu^.Number;
          end;
          //
          if (pcu=nil)and(NewMes) then
            if rbuf[16*i+9]+256*rbuf[16*i+10]=$8480 then
            begin
              mes.TypeDevice:= 9;
              mes.SmallDevice:= rub.FindEmpty_1001_IdCU;
            end;
          //
          if rbuf[16*i+11] in [1,7,8] then
          begin
            mes.User:= rbuf[16*i+12]+256*rbuf[16*i+13];
          end;
          //
          //
          //
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            1: //квитирование
            begin
              st:= 'Пользователь №'+ inttostr(mes.User) +' нажал "Принять" для СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_SH_HANDSHAKE);
            end;
            $101..$999:
            begin
              st:= Format('Событие элемента [%d] СУ [%s:%d], не связанного с ТС', [ rbuf[16*i+9]+256*rbuf[16*i+10], HWTypeToStr(rbuf[16*i+5]), rbuf[16*i+6]+256*rbuf[16*i+7] ]);
              EventLogAndTrySend(pcu, st, 0);
            end;
            $2001:
            begin
              if (pcu<>nil) then
                pcu^.State:= pcu^.State and $FE;
              st:= 'Потеря связи с СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_CU_CONNECT_OFF);
              {
              for j:=1 to rub.TC.Count do
              begin
                ptc:=rub.TC.Items[j-1];
                mes.SmallDevice:=ptc^.ZoneVista;
                if (65536*ptc^.HWType+ptc^.HWSerial)<>(65536*rbuf[16*i+5]+rbuf[16*i+6]+256*rbuf[16*i+7]) then continue;
                case ptc^.Kind of
                  1..4: begin mes.TypeDevice:=5; mes.Code:= R8_SH_CONNECT_OFF; end;
                  5:    begin mes.TypeDevice:=7; mes.Code:= R8_RELAY_CONNECT_OFF; end;
                  6:    begin mes.TypeDevice:=2; mes.Code:= R8_AP_CONNECT_OFF; end;
                  7:    begin mes.TypeDevice:=8; mes.Code:= R8_TERM_CONNECT_OFF; end;
                  else continue;
                end;
                ptc^.State:=ptc^.State and $df;
                aMain.send(mes);
              end;
              }
            end;
            $2002:
            begin
              if (pcu<>nil) then
                pcu^.State:= pcu^.State or 1;
              st:= 'Восстановление связи с СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_CU_CONNECT_ON);
              {
              for j:=1 to rub.TC.Count do
              begin
                ptc:=rub.TC.Items[j-1];
                mes.SmallDevice:=ptc^.ZoneVista;
                if (65536*ptc^.HWType+ptc^.HWSerial)<>(65536*rbuf[16*i+5]+rbuf[16*i+6]+256*rbuf[16*i+7]) then continue;
                case ptc^.Kind of
                  1..4: begin mes.TypeDevice:=5; mes.Code:=R8_SH_CONNECT_ON; end;
                  5:    begin mes.TypeDevice:=7; mes.Code:=R8_RELAY_CONNECT_ON; end;
                  6:    begin mes.TypeDevice:=2; mes.Code:=R8_AP_CONNECT_ON; end;
                  7:    begin mes.TypeDevice:=8; mes.Code:=R8_TERM_CONNECT_ON; end;
                  else continue;
                end;
                ptc^.State:=ptc^.State or 20;
                aMain.send(mes);
              end;
              }
            end;
            $2003:
              if pcu=nil then //старое событие???  BACK
              begin
                st:= 'Вскрытие БЦП';
                EventLogAndTrySend(pcu, st, R8_BCP_OPEN);
              end
              else
              begin
                st:= 'Вскрытие СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
                EventLogAndTrySend(pcu, st, R8_CU_OPEN);
              end;
            $2101:
            begin
              st:= 'Включение БЦП';
              EventLogAndTrySend(pcu, st, R8_POWER_UP);
            end;
            $2102:
            begin
              st:= 'Выключение БЦП';
              EventLogAndTrySend(pcu, st, R8_POWER_DOWN);
            end;
            $2103:
            begin
              st:= 'Начало рабочей сессии БЦП пользователем №'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_USER_ENTER);
            end;
            $2104:
            begin
              st:= 'Конец рабочей сессии БЦП пользователем №'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_USER_EXIT);
            end;
            $2105:
            begin
              st:= 'Вход в режим конфигурирования пользователем №'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_ENTER_CONF);
            end;
            $2106:
            begin
              st:= 'Ошибка авторизации оператора';
              EventLogAndTrySend(pcu, st, R8_UNKNOWN_USER);
            end;
            $2107:
            begin
              st:= 'Блокировка клавиатуры БЦП при авторизации';
              EventLogAndTrySend(pcu, st, R8_LOCK_KEYBOARD);
            end;
            $2108:
            begin
              st:= 'Системная ошибка БЦП. Ошибка №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) + ' (' + HWTypeBCPError(rbuf[16*i+12]+256*rbuf[16*i+13])+')';
              rub.ErrorCode:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Level:= rub.ErrorCode;
              EventLogAndTrySend(pcu, st, R8_SYSERROR);
            end;
            $2109:
            begin
              st:= 'Вскрытие корпуса БЦП';
              EventLogAndTrySend(pcu, st, R8_OPEN);
            end;
            $210A:
            begin
              st:= 'Коррекция часов БЦП';
              EventLogAndTrySend(pcu, st, R8_SETTIME);
            end;
            $210B:
            begin
              st:= 'Коррекция часов БЦП';
              EventLogAndTrySend(pcu, st, R8_SETTIME);
            end;
            $210D:
            begin
              st:= 'БЦП. Переход на резервное питание';
              EventLogAndTrySend(pcu, st, R8_RESERV_POWER);
            end;
            $210E:
            begin
              st:= 'БЦП. Восстановление сетевого питания';
              EventLogAndTrySend(pcu, st, R8_NORMAL_POWER);
            end;
            $210F:
            begin
              st:= 'Разряд БА';
              EventLogAndTrySend(pcu, st, R8_BAT_LOW);
            end;
            $2110:
            begin
              st:= 'Восстановление БА';
              EventLogAndTrySend(pcu, st, R8_BAT_NORMAL);
            end;
            $2117:
            begin
              st:= 'Возврат к заводским установкам пользователем №' + inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_WORKSETTINGS);
            end;
            $2118:
            begin
              st:= 'Синхронизация часов БЦП';
              EventLogAndTrySend(pcu, st, R8_SYNC_TIME);
            end;
            $2126:
            begin
              st:= 'Сброс БЦП пользователем №' + inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_RESET);
            end;
            $2127://Неизвестное событие
            begin
              st:= 'Заводское тестирование';
              EventLogAndTrySend(pcu, st, R8_SELFTEST);
            end;
            $2128:
            begin
              st:= 'Сброс системных ошибок БЦП пользователем №' + inttostr(mes.User);
              rub.ErrorCode:= $FF;
              EventLogAndTrySend(pcu, st, R8_OK);
            end;
            $211A:
            begin
              st:= 'Сброс APB всех пользователей';
              EventLogAndTrySend(pcu, st, R8_BCP_ALLUSERSETSTATE);
            end;
            $2501:
            begin
              {
              mes.TypeDevice:= 9;
              mes.SmallDevice:= rbuf[16*i+6]+256*rbuf[16*i+7];
              mes.NumDevice:= mes.SmallDevice;
              st:= 'Вскрытие корпуса ИБП №'+inttostr(mes.SmallDevice);
              mes.Code:=R8_UPS_ACCESS;
              }
            end;
            $2502:
            begin
              st:= 'Неисправность выхода 1 ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT1_BAD);
            end;
            $2503:
            begin
              st:= 'Восстановление выхода 1 ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT1_OK);
            end;                          
            $2504:
            begin
              st:= 'Неисправность выхода 2 ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT2_BAD);
            end;
            $2505:
            begin
              st:= 'Восстановление выхода 2 ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT2_OK);
            end;
            $2506:
            begin
              st:= 'Неисправность входа 220 ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_IN220_BAD);
            end;
            $2507:
            begin
              st:= 'Восстановление входа 220 ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_IN220_OK);
            end;
            $2508:
            begin
              st:= 'Разряд (Неисправность) БА ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_BAD);
            end;
            $2509:
            begin
              st:= 'Заряд в норме (Восстановление) БА ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_OK);
            end;
            $250A:
            begin
              st:= 'Переход на резерв ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_RESERV_ON);
            end;
            $250B:
            begin
              st:= 'Воостановление питания 220 ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_RESERV_OFF);
            end;
            $250C:
            begin
              st:= 'Отключение БА ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_DISCONNECT);
            end;
            $250D:
            begin
              st:= 'Подключение БА ИБП ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_CONNECT);
            end;
            $320b:
            begin
              st:= 'Вскрытие СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] №'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_CU_OPEN);
            end;
            $8480:
            begin // создано СУ
              //для NewMes в ответе на команду ВУ создается СУ
              //поэтому если pcu=nil то это старое событие или вручную созданное СУ
              if (pcu=nil)and NewMes then
                mes.Mode:= rub.FindEmpty_1001_IdCU;
              if (pcu<>nil) then
                mes.Mode:= pcu^.Number;

              st:= 'Создано СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] N='+inttostr(mes.Mode)+' пользователем №'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_CU_CREATE);
              SaveR8c('СУ', inttostr(mes.Mode), HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7]) );
              if NewMes then
              begin
                mGetCU(rbuf[16*i+6]+256*rbuf[16*i+7], rbuf[16*i+5], mes.Mode);
                mGetStateCU(rbuf[16*i+5], rbuf[16*i+6]+256*rbuf[16*i+7]);
              end;
            end;

            $8481,
            $8381:
            begin // Редактировано СУ
              j:= pcu^.Number;
              mGetCU (rbuf[16*i+6]+256*rbuf[16*i+7], rbuf[16*i+5], j);
              mGetStateCU(rbuf[16*i+5], rbuf[16*i+6]+256*rbuf[16*i+7]);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', j);
              st:= 'Редактировано СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] N='+inttostr(j)+' пользователем №'+inttostr(mes.User);
              mes.Code:= R8_CU_CHANGE;
            end;
            $8482:
            begin // Удалено СУ
              j:= pcu^.Number;
              rub.CU.Remove(pcu);
              Dispose(pcu);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер СУ', j);
              st:= 'Удалено СУ ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] N='+inttostr(j)+' пользователем №'+inttostr(mes.User);
              mes.Code:= R8_CU_DELETE;
              if j>CU_MAX
                then DeleteR8c('СУ', inttostr(j))
                else SaveR8c('СУ', inttostr(j), '');
              rub.NeedSaveR8h:= True;
            end;



            Else
              case rbuf[16*i+9]+256*rbuf[16*i+10] of
                0,
                $101..$706,
                $8301:
                else
                begin
                  st:= Format('Неизвестное событие x%xh СУ по ТС (тип %d)', [ rbuf[16*i+9]+256*rbuf[16*i+10], rbuf[16*i+4] ]);
                  Raise Exception.Create (st);
                end;
              end;

          end; // case события СУ

          //этого события СУ не должно быть
          if (pcu=nil)and NewMes then
            case rbuf[16*i+9]+256*rbuf[16*i+10] of
              $1, $2003,
              $2101..$211A,
              $8481..$8482:; // БЦП
              $8480:
              begin
                //если время события < времени старта,
                //то отсроченная на 3 мин. перегрузка,
                //т.к. СУ могли вручную добавить
                continue;
                //если время события >времени старта,
                //создаем новое СУ
                //запрос конфигурации и сосотяния
                //то отсроченная на 3 мин. перегрузка,
              end;
              else
              begin
                //отложенная перезагрузка драйвера
                st:= '';
                for j:=0 to rbuf[5]+7 do
                begin
                  if j=13 then
                    st:= st + '.';
                  if j=rbuf[5]+5 then
                    st:= st + '.';
                  st:= st+inttohex(rbuf[j],2);
                end;
                EventLogAndTrySend(pcu, st, 0);
                aMain.Log('Критическая ошибка! Перезагрузка через 5 мин.');
                //отсроченная перезагрузка
                continue;
              end;
            end;


        end; //3:


        4://Пользователь
        begin
          pus:= rub.FindUS(rbuf[16*i+5]+rbuf[16*i+6]*256);
          if pus=nil then
          begin
            //запуск таймера принудительного завершения работы
            continue;
          end;
          //
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8501:
            begin
              st:= 'Сброс APB пользователя №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.Code:= R8_USER_APBRESET;
            end;
            $8502:
            begin
              st:= 'Блокирование пользователя №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.Code:= R8_USER_BLOCKING;
            end;
            $8503:
            begin
              st:= 'Разблокирование пользователя №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.Code:= R8_USER_DEBLOCKING;
            end;
            $8580:
            begin
              if pus^.Id<>(pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256) then
              begin
                st:= 'Создан пользователь №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:=R8_USER_CREATE;
              end
              else
              begin
                st:= 'Добавлена карта №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Level:= pus^.AL1;
                mes.Code:= SUD_ADDED_CARD;
              end;
              mGetUser(rbuf[16*i+5]+rbuf[16*i+6]*256);
            end;
            $8581:
            begin
              if pus^.Id<>(pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256) then
              begin
                st:= 'Редактирован пользователь №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:= R8_USER_CHANGE;
              end
              else
              begin
                st:= 'Добавлена карта №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Level:= pus^.AL1;
                mes.Code:= SUD_ADDED_CARD;
              end;
              mGetUser(rbuf[16*i+5]+rbuf[16*i+6]*256);
            end;
            $8582:
            begin
              if pus^.Id<>(pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256) then
              begin
                st:= 'Удален пользователь №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:= R8_USER_DELETE;
              end
              else
              begin
                st:= ' Удалена карта №'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:= SUD_DELETED_CARD;
              end;
              rub.US.Remove(pus);
              Dispose(pus);
              rub.NeedSaveR8h:= True;
            end;

            else
              st:= '4: Неизвестное событие пользователя = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of

          //-----------------------------------------//
          // окончательное формирование mes для User //
          //-----------------------------------------//
          case mes.Code of
            R8_USER_CREATE,
            R8_USER_CHANGE,
            R8_USER_DELETE:
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+5]+rbuf[16*i+6]*256);
            SUD_ADDED_CARD,
            SUD_DELETED_CARD,
            R8_USER_APBRESET,
            R8_USER_BLOCKING,
            R8_USER_DEBLOCKING:
            begin
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер карты', rbuf[16*i+5]+rbuf[16*i+6]*256);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.SysDevice:= SYSTEM_SUD;
              mes.TypeDevice:= 1; //контроллер доступа
            end;
          end;
          //
        end; //4:

        5://Часы
        begin
          st:= '5: Часы';
        end;
        6://Скрипт программа
        begin
          st:= '6: Скрипт программа';
        end;
        7://Скрипт переменная
        begin
          st:= '7: Скрипт переменная';
        end;
        8:;//Звук

        9: //Группы
        begin
          {
          pgr:= rub.FindGR(rbuf[16*i+5]);
          if pgr=nil then
          begin
            //запуск таймера принудительного завершения работы
            continue;
          end;
          //
          }
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8880:
            begin
              st:= 'Создана группа №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер группы', rbuf[16*i+5]);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_GR_CREATE;
              mGetGR(rbuf[16*i+5]);
            end;
            $8881:
            begin
              st:= 'Редактирована группа №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер группы', rbuf[16*i+5]);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_GR_CHANGE;
              mGetGR(rbuf[16*i+5]);
            end;
            $8882:
            begin
              st:= 'Удалена группа №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер группы', rbuf[16*i+5]);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_GR_DELETE;
              pgr:= rub.FindGR(rbuf[16*i+5]);
              rub.GR.Remove(pgr);
              Dispose(pgr);
              rub.NeedSaveR8h:= True;
            end;
            else
              st:= '9: Неизвестное событие группы = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case
        end;

        10:// ВЗ
        begin
          {
          pti:= rub.FindTI(rbuf[16*i+5], 1);
          if pti=nil then
          begin
            //запуск таймера принудительного завершения работы
            continue;
          end;
          }
          //
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
          $8980:
          begin
            st:= 'Создана ВЗ №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер ВЗ', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Code:= R8_TZ_CREATE;
          end;
          $8981:
          begin
            st:= 'Редактирована ВЗ №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер ВЗ', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Code:=R8_TZ_CHANGE;
          end;
          $8982:
          begin
            st:= 'Удалена ВЗ №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер ВЗ', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Code:=R8_TZ_DELETE;
          end;
          else  st:= '10: ВЗ = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of
        end; //10:

        11://УД
        begin
          { !!!!!
            ЭТО ЛИШНЯЯ ПРОВЕРКА СВОЕЙ ЛИШЬ МНИТЕЛЬНОСТИ, ЕЕ Н.УДАЛИТЬ
            а не проверка существования объекта в операциях редактирования и удаления

          ppr:= rub.FindPR(rbuf[16*i+5]);
          if pti=nil then
          begin
            //запуск таймера принудительного завершения работы
            continue;
          end;
          }
          //
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
          $8A80:
          begin
            st:= 'Создан УД №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер УД', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Level:= rbuf[16*i+5];
            mes.Code:= R8_UD_CREATE;
            rub.DeleteUD( rbuf[16*i+5] );
            {
            for j:=rub.PR.Count downto 1 do
            begin
              ppr:=rub.PR.Items[j-1];
              if ppr^.AL=rbuf[16*i+5] then
              begin
                rub.PR.Remove(ppr);
                Dispose(ppr);
              end;
            end;
            }
            mPreGetListPravo(rbuf[16*i+5]);
          end;
          $8A81:
          begin
            st:= 'Редактирован УД №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер УД', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Level:= rbuf[16*i+5];
            mes.Code:= R8_UD_CHANGE;
            rub.DeleteUD( rbuf[16*i+5] );
            {
            for j:=rub.PR.Count downto 1 do
            begin
              ppr:=rub.PR.Items[j-1];
              if ppr^.AL=rbuf[16*i+5] then
              begin
                rub.PR.Remove(ppr);
                Dispose(ppr);
              end;
            end;
            }
            mPreGetListPravo(rbuf[16*i+5]);
          end;
          $8A82:
          begin
            st:= 'Удален УД №'+inttostr(rbuf[16*i+5]) + ' пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер УД', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Level:= rbuf[16*i+5];
            mes.Code:= R8_UD_DELETE;
            for j:=rub.PR.Count downto 1 do
            begin
              ppr:= rub.PR.Items[j-1];
              if ppr^.AL=rbuf[16*i+5] then
              begin
                rub.PR.Remove(ppr);
                Dispose(ppr);
              end;
            end;
            rub.NeedSaveR8h:= True;
          end;
          else  st:= '11: УД = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of

        end; //11:


        12: //Спецдаты
        begin
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8B81:
            begin
              st:= 'Редактированы праздники пользователем №' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_HOLIDAY_EDITED;
              rub.NeedSaveR8h:= True;
            end;
          end;//case
        end; //12:


        13:;//Скрипт инструкция
        14:;//Название объекта
        100:;//БЦП
        else st:= inttohex(rbuf[16*i+4],2)+': Элемент = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
      end; //case rbuf[16*i+4] of //тип объекта



      // вывод текста и отправка на ВУ
      if mes.Code>0 then
      begin
        aMain.Log('SEND: ' + DateTimeToStr(UnPackTime(rbuf[16*i])) + ' ' + st);
        aMain.send(mes);
      end
      else
        if length(st)>0 then
          aMain.Log(DateTimeToStr(UnPackTime(rbuf[16*i])) + ' ' + st);

          
      //
    end; //for
  end; //$8D:


 //`````````````````````````````````````````````````````````````````````````````
 //````` Ответы от команд управления ТС `````````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````

  $8e:
  case RetCode of
    0:;
    {1..65535: amain.DrvErrorReport(rbuf[11]+256*rbuf[12], 21, 0, 0);} //изм.29 заблокировано от лишней генерации R8_DRV_ANSWER
  end;


 //`````````````````````````````````````````````````````````````````````````````
 //````` Установлено время``````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````
  $89:
  if rbuf[5]=$0B then
  begin
    st:='Дата/Время: ' + DateTimeToStr(UnPackTime(rbuf[13]));
    aMain.Log('SEND: ' + st);
    Init(mes);
    mes.SysDevice:=SYSTEM_OPS;
    mes.NetDevice:=rub.NetDevice;
    mes.BigDevice:=rub.BigDevice;
    mes.SmallDevice:=0;
    mes.TypeDevice:=4;
    TheKSBParam.WriteDoubleParam(mes, data, 'Время', UnPackTime(rbuf[13]));
    mes.Code:=R8_GETTIME;
    aMain.send(mes);
  end;


 //`````````````````````````````````````````````````````````````````````````````
 //````` Конфигурирование ``````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````
  $84:
  case rbuf[13] of // тип объекта

    1: // Зона-тип
    if RetCode = 0 then
    case rbuf[14] of

      $1:;//создание
      $2:;//изменение
      $3:;//удаление
      $4:;//удаление вместе с дочерними ТС
      $5: //удаление всех
      begin
        if rub.ZN.Count>0 then
        for i:= rub.ZN.Count-1 downto 0 do
        begin
          pzn:= rub.ZN.Items[i];
          Dispose(pzn);
          rub.ZN.Delete(i);
        end;
        if rub.TC.Count>0 then
        for i:= rub.TC.Count-1 downto 0 do
        begin
          ptc:= rub.TC.Items[i];
          Dispose(ptc);
          rub.TC.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' Удалены все зоны';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:=SYSTEM_OPS;
        mes.NetDevice:=rub.NetDevice;
        mes.BigDevice:=rub.BigDevice;
        mes.TypeDevice:=4;
        mes.Code:= R8_ZONE_ALL_DELETE;
        aMain.send(mes);
        DeleteR8c('ЗОНА', '');
        DeleteR8c('ШС', '');
        DeleteR8c('РЕЛЕ', '');
        DeleteR8c('ТД', '');
        DeleteR8c('ТЕРМИНАЛ', '');
        rub.NeedSaveR8h:= True;
      end;

      $6: //запрос
      if (rub.Cmd.comd=1) then
      begin
        pzn:= rub.FindZN(rbuf[16], 0);
        if pzn=nil
          then rub.LoadZN(rbuf[15], rub.Cmd.zn.Number) //создалась
          else move(rbuf[15], pzn^, sizeof(TZN)-3); //редактировалась
        SaveR8c('ЗОНА', inttostr(rub.Cmd.zn.Number), ValToStr(rub.Cmd.zn.BCPNumber));
        rub.NeedSaveR8h:= True;
      end;

      $7: //Запрос списка
      begin
        rub.LoadZN(rbuf[15], 0); // Обработка принятой телеграммы
      end;

      else  aMain.Log('$84: Зона = '+inttostr(rbuf[14]));
    end;// case rbuf[14] of


    2: // ТС-тип
    if RetCode = 0 then
    case rbuf[14] of

      $1://создание
      if (rub.Cmd.comd=2) then
      begin
        move(rub.Cmd.tc, tt[15], sizeof(TTC)-8-4{newTTC});
        rub.LoadTC(tt[15], rub.Cmd.tc.ZoneVista, rub.Cmd.tc.PartVista);
        case rub.Cmd.tc.Kind of
          1..4: SaveR8c('ШС', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
          5:    SaveR8c('РЕЛЕ', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
          6:    SaveR8c('ТД', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
          7:    SaveR8c('ТЕРМИНАЛ', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
        end;
        rub.NeedSaveR8h:= True;
      end;
      $2:;//изменение конфигурации
      $3:;//удаление
      $4://запрос конфигурации
      begin
        Init(mes);
        mes.SysDevice:= SYSTEM_OPS;
        mes.NetDevice:= rub.NetDevice;
        mes.BigDevice:= rub.BigDevice;
        mes.SmallDevice:= 0;
        mes.TypeDevice:= 4;
        //
        t:=rub.WBuf.Items[0];
        mes.SendTime:= UnPackTime(t[250]);
        //
        ptc:= rub.FindTC(256*rbuf[18]+rbuf[17], 0);
        if (ptc=nil) then
          rub.LoadTC(rbuf[15], 0, 0);

        ptc:= rub.FindTC(256*rbuf[18]+rbuf[17], 0);
        move(rbuf[15], ptc^, sizeof(TTC)-8-4{newTTC});
        pzn:= rub.FindZN(rbuf[26], 0);
        ptc^.PartVista:= pzn^.Number;
        ptc^.tempUser:= t[248]+256*t[249];
        //
        if ptc^.ZoneVista=0 then
        begin
          st:='';
          case rbuf[19] of
            1..4:
            begin
              ptc^.ZoneVista:= rub.SetIdTC(256*rbuf[18]+rbuf[17], 1);
              SaveR8c('ШС', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' Создан ШС ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер ШС', ptc^.ZoneVista);
              mes.Code:= R8_SH_CREATE;
            end;
            5:
            begin
              ptc^.ZoneVista:= rub.SetIdTC(256*rbuf[18]+rbuf[17], 5);
              SaveR8c('РЕЛЕ', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' Создано реле ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер реле', ptc^.ZoneVista);
              mes.Code:= R8_RELAY_CREATE;
            end;
            6:
            begin
              ptc^.ZoneVista:= rub.SetIdTC(256*rbuf[18]+rbuf[17], 6);
              SaveR8c('ТД', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' Создана ТД ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер ТД', ptc^.ZoneVista);
              mes.Code:= R8_AP_CREATE;
            end;
            7:
            begin
              ptc^.ZoneVista:= rub.SetIdTC(256*rbuf[18]+rbuf[17], 7);
              SaveR8c('ТЕРМИНАЛ', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' Создан терминал ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, 'Номер терминала', ptc^.ZoneVista);
              mes.Code:= R8_TERM_CREATE;
            end;
          end; //case
          if st  <>'' then
          begin
            st:= st  + ' пользователем №' + inttostr(ptc^.tempUser);
            aMain.Log('SEND: '+st);
          end;
          if mes.Code>0 then
          begin
            TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', ptc^.tempUser);
            aMain.Send(mes);
          end;
        end; //if
        rub.NeedSaveR8h:= True;
      end;//$4

      $6:// запрос списка
        rub.LoadTC(rbuf[15], 0, 0);

      else   aMain.Log('$84: ТС = '+inttostr(rbuf[14]));
    end;


    3: // СУ
    if RetCode = 0 then
    case rbuf[14] of

      $1://создание
      if (rub.Cmd.comd=5) then
      begin
        move(rub.Cmd.cu, tt, sizeof(TCU)-7);
        //Н.чтобы в дальнейшей обработке знали pcu^.Number
        rub.LoadCU(tt, rub.Cmd.cu.Number);
      end;
      $2:;//изменение
      $3:;//удаление
      $4: //удаление всех
      begin
        if rub.CU.Count>0 then
        for i:= rub.CU.Count-1 downto 0 do
        begin
          pcu:= rub.CU.Items[i];
          Dispose(pcu);
          rub.CU.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' Удалены все СУ';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:=SYSTEM_OPS;
        mes.NetDevice:=rub.NetDevice;
        mes.BigDevice:=rub.BigDevice;
        mes.TypeDevice:=4;
        mes.Code:= R8_CU_ALL_DELETE;
        aMain.send(mes);
        DeleteR8c('СУ', '');
        rub.NeedSaveR8h:= True;
      end;
      $5: //запрос конф.
      if (rub.Cmd.comd=5) then
      begin
        pcu:= rub.FindCU(256*rbuf[17]+rbuf[16]+65536*rbuf[15], 0);
        if pcu=nil
          then rub.LoadCU(rbuf[15], rub.Cmd.cu.Number)
          else move(rbuf[15], pcu^, sizeof(TCU)-7);
        rub.NeedSaveR8h:= True;
      end;
      $6: //Запрос списка
        rub.LoadCU(rbuf[15], 0);

      $0c:
      begin
        st:=DateTimeToStr(now) + ' СУ: Вход в режим конфигурирования БЦП';
        aMain.Log(st);
      end;

      $0d:
      begin
        st:=DateTimeToStr(now) + ' СУ: Выход из режима конфигурирования БЦП';
        aMain.Log(st);
      end;

      else aMain.Log('$84: СУ = '+inttostr(rbuf[14]));

    end;//case rbuf[14] of


    4: // User-тип
    if RetCode = 0 then
    case rbuf[14] of
      $1, 2:
      begin
        t:= rub.WBuf.Items[0];
        pus:= rub.FindUS(256*t[11]+t[10]);
        if pus=nil
          then rub.LoadUS(t[9])
          else move(t[9], pus^, sizeof(TUS));
        rub.NeedSaveR8h:= True;
      end;
      $3:
      begin
        //scu sync
        t:= rub.WBuf.Items[0];
        i:= 0;
        pus:= rub.FindUS(256*t[10]+t[9]);
        if pus<>nil then
          i:= rub.FindUSInScuUserMap(pus^.Id);
        if i<>0 then
        begin
          rub.ScuUserMap[i]:= 0;
         //Запись в файл
          WriteScuUserMap('СКУ-БЦП', IntToStr(i), '');
          //Отправка во все СКУ-02
          rub.DelUserAllScu(i);
        end;
       //scu sync
      end;
      $4:
       begin
        if rub.US.Count>0 then
        for i:= rub.US.Count-1 downto 0 do
        begin
          pus:= rub.US.Items[i];
          Dispose(pus);
          rub.US.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' Удалены все пользователи';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:=SYSTEM_OPS;
        mes.NetDevice:=rub.NetDevice;
        mes.BigDevice:=rub.BigDevice;
        mes.TypeDevice:=4;
        mes.Code:= R8_USER_ALL_DELETE;
        aMain.Send(mes);
        rub.NeedSaveR8h:= True;
      end;
      $5:
      begin
        pus:= rub.FindUS(256*rbuf[17]+rbuf[16]);
        if pus=nil
          then rub.LoadUS(rbuf[15])
          else move(rbuf[15], pus^, sizeof(TUS));
        rub.NeedSaveR8h:= True;
        //scu sync
        pus:= rub.FindUS(256*rbuf[17]+rbuf[16]);
        if pus^.Id=( pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256 ) then
        begin
          //
          if ((pus^.Flags shr 5) and $03)=2 then
          begin
            //
            if rub.FindUSInScuUserMap(pus^.Id)=0 then
            begin
              i:= rub.FindEmptyIdScuUser;
              if i=0
                then aMain.Log('Заполнена база пользователей СКУ-02 !')
                else
                begin
                  rub.ScuUserMap[i]:= pus^.Id;                                        //Запись в ScuUserMap
                  WriteScuUserMap('СКУ-БЦП', IntToStr(i), IntToStr(pus^.Id));         //Запись в файл
                  rub.AddUserAllScu(                                                  //Отправка во все СКУ-02
                                    i,
                                    pus^.IdentifierCode[0],
                                    pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256,
                                    pus^.PinCode
                                    );
                end;
            end;
          //
          end
          else
          begin
            i:= rub.FindUSInScuUserMap(pus^.Id);
            if i>0 then
            begin
              rub.ScuUserMap[i]:= 0;                                              //Запись в ScuUserMap
              WriteScuUserMap('СКУ-БЦП', IntToStr(i), '');                        //Запись в файл
              rub.DelUserAllScu(i);                                               //Отправка во все СКУ-02
            end;
          end;
        //
        end;
        //scu sync
      end;

      $6:
         rub.LoadUS(rbuf[15]);

      else aMain.Log('$84: User = '+inttostr(rbuf[14])); ;
    end; //4


    9: //Группа-тип
    if RetCode = 0 then
    case rbuf[14] of
      $1:;
      $2:;
      $3:;
      $4:
      begin
        if rub.GR.Count>0 then
        for i:= rub.GR.Count-1 downto 0 do
        begin
          pgr:= rub.GR.Items[i];
          Dispose(pgr);
          rub.GR.Delete(i);
        end;
        st:=DateTimeToStr(now)+ ' Удалены все группы';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:=SYSTEM_OPS;
        mes.NetDevice:=rub.NetDevice;
        mes.BigDevice:=rub.BigDevice;
        mes.TypeDevice:=4;
        mes.Code:= R8_GR_DELETEALL;
        aMain.Send(mes);
        rub.NeedSaveR8h:= True;
      end;
      $5:
      begin
        pgr:=rub.FindGR(rbuf[15]);
        if pgr=nil
          then rub.LoadGR(rbuf[15])
          else  move(rbuf[15], pgr^, sizeof(TGR));
        rub.NeedSaveR8h:= True;
      end;
      $6: //запрос списка
        rub.LoadGR(rbuf[15]);
      else aMain.Log('$84: Группа = '+inttostr(rbuf[14])); ;
    end; //case & 9


    10:// ВЗ
    begin
      if Retcode = 0 then
      case rbuf[14] of
        $1,2:; //создание
        $3,4:; //изменение
        $5:;   //удаление
        $6:    //удаление всех
        begin
          if rub.TI.Count>0 then
          for i:= rub.TI.Count-1 downto 0 do
          begin
            pti:= rub.TI.Items[i];
            Dispose(pti);
            rub.TI.Delete(i);
          end;
          st:=DateTimeToStr(now) + ' Удалены все ВЗ';
          aMain.Log('SEND: '+st);
          Init(mes);
          mes.SysDevice:=SYSTEM_OPS;
          mes.NetDevice:=rub.NetDevice;
          mes.BigDevice:=rub.BigDevice;
          mes.TypeDevice:=4;
          mes.Code:= R8_TZ_ALL_DELETE;
          aMain.send(mes);
          rub.NeedSaveR8h:= True;
        end;
        $7: //Запрос списка
        begin
          rub.LoadTI(rbuf[15]);
        end;
        else   aMain.Log('$84: ВЗ = '+inttostr(rbuf[14])); ;
      end;//case rbuf[14] of

      if (Retcode<>0)and(rbuf[14]=7) then
        rub.NeedSaveR8h:= True;
    end;//10

    11:// УД
    begin
      if RetCode = 0 then
      case rbuf[14] of
        $1,2:; //создание
        $3,4:; //изменение
        $5:;   //удаление
        $6:    //удаление всех
        begin
          if rub.PR.Count>0 then
          for i:= rub.PR.Count-1 downto 0 do
          begin
            ppr:= rub.PR.Items[i];
            Dispose(ppr);
            rub.PR.Delete(i);
          end;
          st:=DateTimeToStr(now) + ' Удалены все УД';
          aMain.Log('SEND: '+st);
          Init(mes);
          mes.SysDevice:=SYSTEM_OPS;
          mes.NetDevice:=rub.NetDevice;
          mes.BigDevice:=rub.BigDevice;
          mes.TypeDevice:=4;
          mes.Code:= R8_UD_ALL_DELETE;
          aMain.send(mes);
          rub.NeedSaveR8h:= True;
        end;
        $7:
          rub.LoadPR(rbuf[15]);
        else aMain.Log('$84: УД = '+inttostr(rbuf[14])); ;
      end;//case
    end; // 11


    12: // Праздники
    if RetCode = 0 then
    case rbuf[14] of
      $1:; //Редактирование всех
      $2: //Запрос
        rub.LoadHD(rbuf[15]);
      else aMain.Log('$84: HD = '+inttostr(rbuf[14]));
    end;//case rbuf[14] of
      {
      st:=DateTimeToStr(now) + '  праздники';
      aMain.Log('SEND: '+st);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.TypeDevice:=4;
      mes.Code:= R8_HOLIDAY_SET;
      aMain.send(mes);
      rub.NeedSaveR8h:= True;
      }


    14: // Названия
    if RetCode = 0 then
    case rbuf[14] of
      $1:;//создание
      $2:;//изменение
      $3:;//удаление
      $4: //удаление всех
      begin
        if rub.RN.Count>0 then
        for i:= rub.RN.Count-1 downto 0 do
        begin
          prn:= rub.RN.Items[i];
          Dispose(prn);
          rub.RN.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' Удалены все названия';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:= SYSTEM_OPS;
        mes.NetDevice:= rub.NetDevice;
        mes.BigDevice:= rub.BigDevice;
        mes.TypeDevice:= 4;
        mes.Code:= R8_RN_ALL_DELETE;
        aMain.send(mes);
        rub.NeedSaveR8h:= True;
      end;
      $5:; //запрос конф.
      $6: //Запрос списка
        rub.LoadRN(rbuf[15]);

      else aMain.Log('$84: RN = '+inttostr(rbuf[14]));
    end;//case & 14


    6: // Программы
    if RetCode = 0 then
    case rbuf[14] of
      $1:;//создание
      $2:;//изменение
      $3:;//удаление
      $4: //удаление всех
      begin
        if rub.RP.Count>0 then
        for i:= rub.RP.Count-1 downto 0 do
        begin
          prp:= rub.RP.Items[i];
          Dispose(prp);
          rub.RP.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' Удалены все программы';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:=SYSTEM_OPS;
        mes.NetDevice:=rub.NetDevice;
        mes.BigDevice:=rub.BigDevice;
        mes.TypeDevice:=4;
        mes.Code:= R8_RP_ALL_DELETE;
        aMain.send(mes);
        rub.NeedSaveR8h:= True;
      end;
      $5:; //запрос конф.
      $6: //Запрос списка
        rub.LoadRP(rbuf[15]);
      else aMain.Log('$84: RP = '+inttostr(rbuf[14]));
    end;//case & 6


    13: // Инструкции
    if RetCode = 0 then
    case rbuf[14] of
      $1:;//создание
      $2: //запрос списка
        rub.LoadRI(rbuf[15]);
      else aMain.Log('$84: RI = '+inttostr(rbuf[14]));
    end;//case & 13


    else
      if RetCode = 0 then
       aMain.Log('$84:'+inttostr(rbuf[13])+' = '+inttostr(rbuf[14]));

    end; // $84:



  //`````````````````````````````````````````````````````````````````````````````
 //````` Управление ТС    ``````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````
  $87:
  begin
    aMain.Log('Ошибка 0x87h. F6402E-BB45-EF2143E03C57');
  end;


 //`````````````````````````````````````````````````````````````````````````````
 //````` Управление зонами``````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````
  $8f:
  case RetCode of
    0:;
    1..65535: amain.DrvErrorReport(RetCode, 20, 0, 0);
  end; // $8f:

 //````````````````````````````````````````````````````````````````````````
  $92:
  case RetCode of
    0:;
    1..65535: amain.DrvErrorReport(RetCode, 22, 4, 0);
  end;//92

  $95:
  begin
    aMain.StatusBar1.Panels.Items[1].Text:= Format('БЦП №%d; Версия %d.%d.%d', [ rub.Addr, rbuf[13], rbuf[14], rbuf[17]+256*rbuf[18] ]);
    st:= '';
    for i:=0 to 31 do
      st:= st + Chr(rbuf[24+i]);
    st:= Format('Версия БЦП %d.%d.%d, Версия БД %d.%d', [ rbuf[13], rbuf[14], rbuf[17]+256*rbuf[18], rbuf[15], rbuf[16] ]);
    //st:= Format('Версия БЦП %d.%d.%d, Версия БД %d.%d; Дата: %s. Тип БЦП: %d; Описание: %s', [ rbuf[13], rbuf[14], rbuf[17]+256*rbuf[18], rbuf[15], rbuf[16], DateTimeToStr(UnPackTime(rbuf[19])),  rbuf[23], st ]);
    aMain.Log(st);
  end;

  $96:
  if (rbuf[14]+256*rbuf[15])>0 then
  begin
    rub.ErrorCode:= rbuf[16+12]+256*rbuf[16+13];
    st:=DateTimeToStr(UnPackTime(rbuf[16]))+ ' Системная ошибка БЦП. Ошибка №' + inttostr(rub.ErrorCode) + ' (' + HWTypeBCPError(rub.ErrorCode)+')';
    aMain.Log(st);
  end
  else rub.ErrorCode:= $FF;

  else //case rbuf[10]
  Raise Exception.Create ('Неизвестный ответ от БЦП');

  end; // case rbuf[10]

 EXCEPT
  On E: Exception do
  begin
    st:='';
    for j:=0 to rbuf[5]+7 do
    begin
      if j=13 then
        st:= st + '.';
      if j=rbuf[5]+5 then
        st:= st + '.';
      st:= st+inttohex(rbuf[j],2);
    end;
    aMain.Log( 'OnReadBCPException (' + E.Message + ') ' + st);
  end;

 END;//////

 if Option.Logged_Delay then
 begin
   QueryPerformanceCounter(_c2.QuadPart);
   amain.Log('CountOnRead ['+inttostr(rbuf[10])+'] : '+FloatToStr((_c2.QuadPart-_c1.QuadPart)/_f.QuadPart));
 end;

 end;// with rbcp
end;

//-----------------------------------------------------------------------------
function GetStateZN (zn: word; ptc: pointer=nil): word;
var
 i: word;
 p: PTTC;
 pzn: PTZN;
 m: array [0..1] of byte;
 mes: KSBMES;
 data: PChar;
 tState: byte;
 IsZnEmpty: boolean;
 IsAllShOff: boolean;
 st: string;
 User: word;

begin
 data:= '';
 Result:= 0;
 User:= 0;
 if ptc<>nil then
 User:= PTTC(ptc)^.tempUser;
 //
 IsZnEmpty:= True;
 IsAllShOff:= True;
 //
 m[0]:= lo(zn);
 m[1]:= hi(zn);
 pzn:= rub.FindZN(m, 1);
 if pzn=nil then
 exit;

 //текущее состояние зоны
 tState:=0+0+0+0+2+1;
 for i:=1 to rub.TC.Count do
 begin
   p:= rub.TC.Items[i-1];
   if (p^.PartVista<>zn) then
   continue;
   case p^.Kind of
     1..3:
     begin
       IsZnEmpty:= false;
       tState:= tState or (p^.State and $fc); // неиз-н.об.-o-н-т
       if (p^.State and $52)=$00 then
         tState:= tState and $fd; // снят
       if (p^.State and $51)=$00 then
         tState:= tState and $fe; // г
       if (p^.State and $10)=$00 then
         IsAllShOff:= False;
     end;//1..3
     4:
     begin
       IsZnEmpty:= false;
       tState:= tState or (p^.State and $fc); // неиз-н.об.-o-н-т
       if (p^.State and $10)=$00 then
         IsAllShOff:= False;
     end;//4
   end;//case
   //
   //Заглушка 0 польз. (ляп СИГМА-ИС)
   if User=0 then
   if p^.tempUser>0 then
     User:= p^.tempUser;
   //
 end;//for

 if IsZnEmpty then
   tState:= 1;
 if IsAllShOff then
   tState:= tState and $fd;

 //вывод состояния
 st:= '';
 if pzn^.State<>tState then
 if option.Logged_OnReadBCPStateDebug then
   aMain.StateString(1, pzn, tState, st);
 if st<>'' then
 begin
   st:= 'Инфо >>> ' + st;
   aMain.Log(st);
 end;
 //
 Init(mes);
 mes.SysDevice:= SYSTEM_OPS;
 mes.NetDevice:= rub.NetDevice;
 mes.BigDevice:= rub.BigDevice;
 mes.SmallDevice:= zn;
 mes.TypeDevice:= 6;
 //
 if option.Logged_OnReadBCPCalculateStateZone then
 aMain.Log('Logged_OnReadBCPCalculateStateZone: Пересчет зоны №'+inttostr(zn)+': До='+inttostr(pzn^.State)+' После='+inttostr(tState)+' Польз.='+inttostr(User)+' comd.='+inttostr(rub.comd));

 // Готовность
 if (tState and $01)<>(pzn^.State and $01) then
 if rub.WorkTime then
 if (tState and $01)=0 then
 begin
   aMain.Log('SEND: Зона №'+inttostr(pzn^.Number)+ ' не готова');
   mes.Code:= R8_ZONE_NOTREADY;
   aMain.Send(mes);
 end
 else
 begin
   aMain.Log('SEND: Зона №'+inttostr(pzn^.Number)+ ' готова');
   mes.Code:= R8_ZONE_READY;
   aMain.Send(mes);
 end;

 // Охрана
 if (tState and $02)<>(pzn^.State and $02) then
 if rub.WorkTime then
 if (tState and $02)=0 then
 begin
   aMain.Log('SEND: Снятие с охраны зоны №'+inttostr(pzn^.Number)+ ' пользователем №'+ inttostr(User));
   mes.Code:= R8_ZONE_DISARMED;
   TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', User);
   aMain.Send(mes);
 end
 else
 begin
   aMain.Log('SEND: Постановка на охрану зоны №'+inttostr(pzn^.Number)+ ' пользователем №'+ inttostr(User));
   mes.Code:= R8_ZONE_ARMED;
   TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', User);
   aMain.Send(mes);
 end;

 // Восстановление
 if (tState and $2c)<>(pzn^.State and $2c) then
 if rub.WorkTime then
 if (tState and $2c)=0 then
 begin
   aMain.Log('SEND: Зона №'+inttostr(pzn^.Number)+ ' восстановлена пользователем №'+ inttostr(User));
   mes.Code:= R8_ZONE_RESTORE;
   TheKSBParam.WriteIntegerParam(mes, data, 'Номер пользователя', User);
   aMain.Send(mes);
 end;

 // Тревога
 if (tState and $04)<>(pzn^.State and $04) then
 if rub.WorkTime then
 if (tState and $04)>0 then
 begin
   aMain.Log('SEND: Зона №'+inttostr(pzn^.Number)+ ' в тревоге');
   mes.Code:= R8_ZONE_ALARM;
   aMain.Send(mes);
 end;

 // Неисправность
 if (tState and $08)<>(pzn^.State and $08) then
 if rub.WorkTime then
 if (tState and $08)>0 then
 begin
   aMain.Log('SEND: Зона №'+inttostr(pzn^.Number)+ ' неисправна');
   mes.Code:= R8_ZONE_CHECK;
   aMain.Send(mes);
 end;

 // Откл.
 if (tState and $10)<>(pzn^.State and $10) then
 if rub.WorkTime then
 if (tState and $10)>0 then
 begin
   aMain.Log('SEND: Зона №'+inttostr(pzn^.Number)+ ' содержит откл. ШС');
   mes.Code:= R8_ZONE_SH_OFF;
   aMain.Send(mes);
 end
 else
 begin
   aMain.Log('SEND: Зона №'+inttostr(pzn^.Number)+ ' не содержит откл. ШС');
   mes.Code:= R8_ZONE_SH_ON;
   aMain.Send(mes);
 end;
 //
 pzn^.State:= tState;
 Result:= tState;
end;



function APModeToRostek(ptc: pointer): byte;
var
 p: PTTC;
begin
 p:= ptc;
 // БЦП реж.: 0-Код или Карта, 1-Код и Карта, 2-Карта и Дверной код, 3-Дверной код
 // ТД бит сост.: неизв. - откл. - н - (3бита: 1-Норма, 2-Дверь открыта, 3-Дверь не закрыта, 4-Взлом, 5-Заблокировано, 6-Разблокировано, 7-Нападение)
 // Rostek режим: 0-Закрыто, 1-Карта, 2-Код или карта, 3-Код и карта, 4-Открыто, 5-Фасилити, 6,7-Резерв, 8-Не актиивен
 Result:= 8;
 case (p^.ConfigDummy[0] shr 1) and $03 of
   0: Result:= 2; //Код или Карта
   1: Result:= 3; //Код и Карта
   2: Result:= 9; //Карта и Дверной код
   3: Result:= 10; //Дверной код
 end;
 case (p^.State and $0F) of
   5: Result:= 0; //Заблокирована
   6: Result:= 4; //Разблокирована
 end;
 if (p^.Flags and $08)=0 then
   Result:= 8; //Не активен
end;

function APStateToRostek(ptc: pointer): byte;
var
 p: PTTC;
begin
 p:= ptc;
 // ТД бит сост.: неизв. - откл. - н - (3бита: 1-Норма, 2-Дверь открыта, 3-Дверь не закрыта, 4-Взлом, 5-Заблокировано, 6-Разблокировано, 7-Нападение)
 // Rostek сост.: 0-Нет связи, 1-Готов, 2-Доступ разрешен, 3-Доступ запрещен, 4-Тревога, 5-Открыто, 6-Закрыто, 7-Несправность
 if (p^.State and $10)>0 then Result:= 0 //0-Нет связи
   else if (p^.State and $28)>0 then Result:= 7 //0-Неисправность
     else case p^.State of
       $01: Result:= 1; //Норма/Готов +
       $02: Result:= 2; //Дверь открыта/Доступ разрешен +
       $03: Result:= 4; //Удержание/Тревога +
       $04: Result:= 4; //Взлом/Тревога +
       $05: Result:= 6; //Заблокирована/Закрыто +
       $06: Result:= 5; //Разблокирована/Открыто +
       $07: Result:= 4; //Нападение/Тревога +
       else Result:= 7; //0-Неисправность
     end;
end;

//-----------------------------------------------------------------------------
END.





