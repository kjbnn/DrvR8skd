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
   ExceptStr:='�����_1';
   QueryPerformanceFrequency(_f.QuadPart);
   QueryPerformanceCounter(_c1.QuadPart);

 TRY
 //����� �� ��������� �� ������
 if (rbuf[5]=7)and(rbuf[10]=$8d) then
   exit;
 //������ OnReadBCPTel
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
    st:= Format('������ ��� %d.%d. ������ �� %d.%d', [ rbuf[13], rbuf[14], rbuf[15], rbuf[16] ]);
    aMain.Log(st);
  end;
  //`````````````````````````````````````````````````````````````````````````````
  //`````` ������ ��������� `````````````````````````````````````````````````````
  //`````````````````````````````````````````````````````````````````````````````
  $85:
  case rbuf[13] of //��� �������

    2://������ ��
    begin
      // 1,2 �������
      ExceptStr:= '���������_1';
      case rbuf[14] of
        1:; // ������ ��������� ��������� ������� ��
        2:; // ������ ��������� ��������� �������������� ������� ��
        else exit;
      end;
      // �� �� ������
      ExceptStr:= '���������_2';
      ptc:= rub.FindTC(256*rbuf[18]+rbuf[17], 0);
      if ptc=nil then
        exit; //Raise Exception.Create( Format('�� [%x] �� ������', [ 256*rbuf[18]+rbuf[17] ]) )


      // 5 - �����
      // 6..9 - ��������������
      // 10 - ��� ������������ �������
      // 11..12 - ��� ����������
      // 13 - ������...
      //
      //����������������
      // 13 - ��� ������� (1)
      // 14 - ������� ����.
      // 15 - ������ ����.

      // ------------------------------------------------------------------------------------------------------------
      // �� 1-3     -> �����. - �.��. - ����.     - � - � - � - �
      // �� 4       -> �����. - �.��. - ����.     - � - � - ���.2 - ���.1
      // ���� 5     -> �����. - �.��. - ����.     - � - � - ���. - �
      // �� 6       -> �����. - �.��. - ����.     - � - 3���� (1-�����, 2-����� �������, 3-���������, 4-�����, 5-�������������, 6-��������������, 7-���������)
      // ��������   -> �����. - �.��. - ����.     - � - � - ����. -�
      // ------------------------------------------------------------------------------------------------------------
      // ���������� ������ ��� ��� ������ ���. ��������� (comd=24) ��� �������� KSBMes � � ����������� tState
      // ���������� ������ ��� ��� ������ ��������� ����/������ �� (comd=3) � ��������� KSBMes � � ����������� tState
      // ���������� ������ ��� � ���. ������ ��� ��������� ������� � ������ (comd=1) � ��������� KSBMes � ��� ����������� tState ������ ��� �� � ����� ����� �������



      //��������� ���������� �� ���������
      tState:= $40;

      //1 ������ (���������)
      case 256*rbuf[23]+rbuf[22] of
        $000:  if (256*rbuf[21]+rbuf[20]{ + rbuf[19]})=0
                 then tState:= $10  // �� ���������
                 else tState:= $28; // �� ������.��.
        $101:  tState:= $03;        // �� ����
        $102:  tState:= $01;        // �� �����
        $103:  tState:= $00;        // �� �� �����
        $104:                       // �� ������.(�������)
          if (rbuf[19] and $04)=0
            then tState:= $04
            else tState:= $05;
        $105:                       // �� ������.��
          if (rbuf[19] and $04)=0
            then tState:= $08
            else tState:= $09;
        $106:  tState:= $03;        // �� �������� �� ���� (�.�. �� ������������ ?)
        $107:  tState:= $01;        // �� �������� �� ����� (�.�. �� ������������ ?)
        $108:  tState:= $00;        // �� �������� ���������� (�.�. �� ������������ ?)
        $109:  tState:= $08;        // �� ������ �� (�.�. �� ������������ ?)
        $201:  tState:= 0+0+2+1;           //�� ����� (����)
        $202:  tState:= 0+4+2+0;           //�� �������
        $203:  tState:= 8+0+0+0;           //�� �������������
        $204:  tState:= 0+4+2+1;           //�� ����� � ��������������
        $205:  tState:= 0+0+2+1;           //�� �� �������� �.�. �� ������������ ?
        $301:  tState:= 0+0+2+1;           //�� ����� (����)
        $302:  tState:= 8+0+0+0;           //�� �������������
        $303:  tState:= 0+4+2+0;           //�� ��������
        $304:  tState:= 0+4+2+0;           //�� �����
        $305:  tState:= 0+4+2+1;           //�� ����� � ��������������
        $401:  tState:= 0+0+0+0;           // �� ���. 0
        $402:  tState:= 0+0+0+1;           // �� ���. 1
        $403:  tState:= 8+0+0+0;           // �� �������������
        $404:  tState:= 0+0+0+0;           // �� �����
        $405:  tState:= 0+0+2+0;           // �� ���. 2
        $406:  tState:= 0+0+2+1;           // �� ���. 3
        $407:  tState:= 0+4+0+0;           // �� ����. ���. 0
        $408:  tState:= 0+4+0+1;           // �� ����. ���. 1
        $409:  tState:= 0+4+2+0;           // �� ����. ���. 2
        $40A:  tState:= 0+4+2+1;           // �� ����. ���. 3
        $501:  tState:= 0+0+2+1;           // �� ���
        $502:  tState:= 0+0+0+1;           // �� ����
        $503:  tState:= 0+0+0+1;           // �� �������� ���
        $504:  tState:= 8+0+0+0;           // �� �������������
        $601:  tState:= $01;               // �� �����
        $602:  tState:= $02;               // �� ����� �������
        $603:  tState:= $03;               // �� ���������
        $604:  tState:= $04;               // �� �����
        $605:  tState:= $05;               // �� �������������
        $606:  tState:= $06;               // �� ��������������
        $607:  tState:= $07;               // �� ���������
        $701:  tState:= 0+0+0+1;           // ����. �����
        $702:  tState:= 0+0+2+1;           // ����. ������������

        $8301: tState:= $01; // ������������ �� � �����
        $8302: tState:= $28; // ������������ �� �� �������
        $8303: tState:= $28; // ������������ �� �� ����������������
        $8304: tState:= $28; // ������������ ��������� (������������� ��, ������ �� �� ������������ ������������)
        $8305: tState:= $28; // ������ ����� � ������������� ��
        $8306: tState:= $28; // ������ ����� � ��
        $8307: tState:= $28; // ������������� ������������ ��
        $8308: tState:= $28; // ������ �� ��������. ����� ����.
        $8309: tState:= $28; // ������������ ����� ����� � ����
        $830A: tState:= $28; // �� ����� ����� � ����
        $830B: tState:= $28; // ����� � ��������������

        else Raise Exception.Create( Format('�� [%d] ����������� ��������� %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[23]+rbuf[22] ]) );
      end;//case 256*rbuf[23]+rbuf[22]

      //2 ������ (HW+�������)
      //��������� �����. + ����.
      if (tState and $50)=0 then
      case ptc^.Kind of

        1..3:
        begin
          //�
          if ((ptc^.Kind=1)and((rbuf[24] and 1)>0))or(ptc^.Kind<>1) then
            tState:= tState or 2;
          //
          case ptc^.HWType of
            32:
            begin
              //�
              if (rbuf[19] and $08)>0 then
                tState:= tState or $08;
            end;//32:
            1,4,9,16,17:
            begin
              //HW (����������)
              if ptc^.Kind=1
                then j:= (rbuf[24] and 6) shr 1
                else j:= rbuf[24];
              if j=0
                then tState:= tState or $01
                else tState:= tState and $fe;
            end;//1,4,9,16,17:
          end;//case ptc^.HWType
          //���
          case 256*rbuf[21]+rbuf[20] of
            0:;
            $0103,
            $0201,
            $0301: tState:= tState or $04; //�
            $0104,
            $0202,
            $0302: tState:= tState or $08; //�
            $8302: tState:= tState or $28; //��
            else Raise Exception.Create( Format('�� [%d] ����������� ������� %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
          if option.NReadyOnCheck then
            if (tState and $08)>0 then
              tState:= tState and $fe;
        end; //1..3:

        4:
        begin
          //��������� ��. ���� ������
          tState:= tState and $fc;
          //�
          case rbuf[24] of
            0: tState:= tState or $00; //���.0
            1: tState:= tState or $01; //���.1
            2: tState:= tState or $08; //+�
            3: tState:= tState or $02; //���.2
            4: tState:= tState or $03; //���.3
            else Raise Exception.Create( Format('�� [%d] ����������� �������� [24] %.2�', [ 256*rbuf[18]+rbuf[17], rbuf[24] ]) );
          end;
          //���
          case 256*rbuf[21]+rbuf[20] of
            $0,
            $4,
            $0401,
            $0402,
            $0406,
            $0407:;
            $0403: tState:= tState or $08; //�
            $8302: tState:= tState or $28; //��
            $0404,
            $0405,
            $0408,
            $0409: tState:=tState or $04; //�
            else Raise Exception.Create( Format('�� [%d] ����������� ������� %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//4

        5:
        begin
          if (rbuf[24] and 1)>0 then
            tState:=tState or $02;        // ���.
          //��
          case 256*rbuf[21]+rbuf[20] of
            $0:;
            $0504: tState:= tState or $08; //�
            $8302: tState:= tState or $28; //��
            else Raise Exception.Create( Format('�� [%d] ����������� ������� %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//5

        6:
        begin
        {
typedef struct {
char fLockOpen:1; // 1 � ����� ������
char DoorState:2; // ��������� �����
char WorkState:2; // ������� ���������
uchar AuthorizationErrorCounter; // ������� ������ �����������
uint LastUserRequestResult; // ��������� ���������� �������
}

{APState;
��������� �����:
#define APDOORSTATE_CLOSED 0 // �������
#define APDOORSTATE_OPEN 1 // �������
#define APDOORSTATE_NOCLOSED 2 // ���������
#define APDOORSTATE_ALARM 3 // �����

������� ���������:
#define APSTATE_NORM 0 // �����
#define APSTATE_BLOCKED 1 // �������������
#define APSTATE_DEBLOCKED 2 // ��������������
        }
          case 256*rbuf[21]+rbuf[20] of
            $0,
            $60c,
            $60d:;
            $605:  tState:= $03; //��.
            $606:  tState:= $04; //��.
            $8302: tState:= $28; //��
            else Raise Exception.Create( Format('�� [%d] ����������� ������� %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//6

        7:
        begin
          if (rbuf[24] and 1)>0 then
            tState:= tState or $02;
          case 256*rbuf[21]+rbuf[20] of
            $0:;
            $704:  tState:= tState or $04;  //�
            $8302: tState:= tState or $28; //��
            else Raise Exception.Create( Format('�� [%d] ����������� ������� %.4x', [ 256*rbuf[18]+rbuf[17], 256*rbuf[21]+rbuf[20] ]) );
          end;
        end;//7

        else Raise Exception.Create( Format('�� [%d] ���������� ��� %.4x', [ 256*rbuf[18]+rbuf[17], ptc^.Kind ]) );
      end; //case ptc^.Kind


      //���������� �� �� ���������� ��� 8D ������� � ������ 3, 33 ����������, ����������
      Init(mes);
      mes.SysDevice:= SYSTEM_OPS;
      mes.NetDevice:= rub.NetDevice;
      mes.BigDevice:= rub.BigDevice;
      mes.SmallDevice:= ptc^.ZoneVista;
      //
      if (tState and $40)=$00 then
        ptc^.State:= ptc^.State and {bf}$3f; //���.96

      //================================================================================//
      // ��� ����� ����� ���������� � ptc^.State:= tState; � ����������� ����������� 85 //
      // ����� �� ������������� ��
      //================================================================================//
      // vvv

      case ptc^.Kind of
      //
      1..3:
      begin
        mes.TypeDevice:= 5;
        //
        //����������
        if (tState and $01)<>(ptc^.State and $01) then    //=$11 ���������
        if (tState and $10)=0 then // �������
        if rub.WorkTime then
        case (tState and $05) of
          $00:
          begin
            ptc^.State:= ptc^.State and $fe;
            mes.Code:= R8_SH_NOTREADY;
            aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' �� �����');
            aMain.Send(mes);
          end;
          $01:
          begin
            ptc^.State:= ptc^.State or $01;
            mes.Code:= R8_SH_READY;
            aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' �����');
            aMain.Send(mes);
          end;
          $04:
          begin
            ptc^.State:= ptc^.State and $fe;
            mes.Code:= R8_SH_NOTREADY_IN_ALARM;
            aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' �� ����� � �������');
            aMain.Send(mes);
          end;
          $05:
          begin
            ptc^.State:= ptc^.State or $01;
            mes.Code:= R8_SH_READY_IN_ALARM;
            aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' ����� � �������');
            aMain.Send(mes);
          end;
        end;//case



        //��������! ��� �������������� ������� �� ������������=0
        if (tState and $0c)<>(ptc^.State and $0c) then
        if (tState and $1e)=0 then // �������
        if rub.WorkTime then
        begin
          ptc^.State:= ptc^.State and $f3;
          mes.Code:= R8_SH_RESTORE;
          aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista) + ' ������������');
          aMain.Send(mes);
        end;

        //����.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_SH_OFF;
          aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' ��������');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef; //����� �� ��� ��������������� �� ����� ���������� ������ ���������� �������
          mes.Code:= R8_SH_ON;
          aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' ���������');
          aMain.Send(mes);
        end;

        // ���. ����. � ������ ��������
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      4:
      begin
        mes.TypeDevice:= 5;

        //����.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_SH_OFF;
          aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' ��������');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_SH_ON;
          aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' ���������');
          aMain.Send(mes);
        end;

        // ���. ����. � ������ ��������
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      5:
      begin
        mes.TypeDevice:= 7;
        //����.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_RELAY_OFF;
          aMain.Log('SEND: ���� �'+inttostr(ptc^.ZoneVista)+ ' ���������');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_RELAY_ON;
          aMain.Log('SEND: ���� �'+inttostr(ptc^.ZoneVista)+ ' ����������');
          aMain.Send(mes);
        end;
        // ���. ����. � ������ ��������
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      6:
      begin
        mes.SysDevice:= 1; //���.08.11.15
        mes.TypeDevice:= 2; //���.08.11.15
        //����.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_AP_OFF;
          aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' ���������');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_AP_ON;
          aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista)+ ' ����������');
          aMain.Send(mes);
        end;

        //���������
        if (tState and $07)<>(ptc^.State and $07) then
        if (tState and $38)=0 then // ������� � ��������
        if rub.WorkTime then
        case (tState and $07) of
          1: //�������������
          begin
            ptc^.State:= tState;
            mes.Code:= SUD_DOOR_CLOSE{R8_AP_RESET};
            aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista) + ' � ����� (�����)');
            aMain.Send(mes);
          end;
          2: //�������
          begin
            ptc^.State:= tState;
            mes.Code:= SUD_DOOR_OPEN{R8_AP_DOOROPEN};
            aMain.Log('SEND: �� �'+inttostr(ptc^.ZoneVista) + ' �������');
            aMain.Send(mes);
          end;
        end;//case
{
        $601:  tState:= $01;               // �� �����
        $602:  tState:= $02;               // �� ����� �������
        $603:  tState:= $03;               // �� ���������
        $604:  tState:= $04;               // �� �����
        $605:  tState:= $05;               // �� �������������
        $606:  tState:= $06;               // �� ��������������
        $607:  tState:= $07;               // �� ���������
}
        // ���. ����. � ������ ��������
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      7:
      begin
        mes.TypeDevice:= 8;
        //����.
        if (tState and $10)<>(ptc^.State and $10) then
        if rub.WorkTime then
        if (tState and $10)>0 then
        begin
          ptc^.State:= $10;
          mes.Code:= R8_TERM_OFF;
          aMain.Log('SEND: ����. �'+inttostr(ptc^.ZoneVista)+ ' ��������');
          aMain.Send(mes);
        end
        else
        begin
          ptc^.State:= ptc^.State and $ef;
          mes.Code:= R8_TERM_ON;
          aMain.Log('SEND: ����. �'+inttostr(ptc^.ZoneVista)+ ' ���������');
          aMain.Send(mes);
        end;
        // ���. ����. � ������ ��������
        if not rub.WorkTime then
          ptc^.State:= tState;
      end;
      //
      else Raise Exception.Create('����������� ��� �� 56CDCB-49412345:'+inttostr(ptc^.Kind));
      end; //case p^.Kind

      // ^^^
      //================================================================================//
      // ��� ����� ����� ���������� � ptc^.State:= tState; � ����������� ����������� 85 //
      //================================================================================//



      //����� ���������
      if option.Logged_OnReadBCPStateDebug then
      begin
        st:= Format(' [%.4x, %.4x] <-> ', [ 256*rbuf[21]+rbuf[20] , 256*rbuf[23]+rbuf[22] ]);
        st:= st + Format('[%.2x...%.2x%.2x%.2x%.2x] ', [ rbuf[19], rbuf[24], rbuf[25], rbuf[26], rbuf[27] ]);
        aMain.StateString(2, ptc, ptc^.State, st);
        st:= '���� >>> ' + st;
        aMain.Log(st);
      end;

      //����� �����. ����.
      if (tState and $40)>0 then
        Raise Exception.Create( Format('�� [%d] ����������� ����������� ��������� %d', [ 256*rbuf[18]+rbuf[17], tState ]) );

      //����������� ��������� ����������� �������� (��� � ��.)
      case ptc^.Kind of
        1..4: GetStateZN(ptc^.PartVista);
      end;

    end;//2:������ ��


    3://������ ��
    begin
      pcu:= rub.FindCU(65536*rbuf[15]+256*rbuf[17]+rbuf[16], 0);

      { �� �� ������� |
        ��� �� ������ ��������� ��������� �� |
        ��������� ��������� �������������� ��
      }
      if (pcu=nil)or((rbuf[14]<>1)and(rbuf[14]<>2)) then
        exit;

      {
      ��������� ��� ������� ���� �� ����� �� ������������,
      ��� ��� ������������ ��� ���������� ����� ���.
      ��� ��������� �� ������������� � �������� �����
      � ��������� ��������� � ���� ��.
      }
      tState:= 0;
      if ((rbuf[18] and $02)=0) and ((pcu^.flags and $10)>0)
        then tState:= tState or $01
        else tState:= tState and $fe;
      {
      // �� �������� �.� ������������� ��� ���� ���������� ��������� �������� �����
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
        st:= '���� >>> ' + st;
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
        aMain.Log( Format('SEND: �� �%d ������', [pcu^.Number]) );
        aMain.Send(mes);
      end;
      pcu^.State:=tState;
    end;//3:������ ��
    else Raise Exception.Create ('����������� ��� ������� F640F-2967-402E-BB45-EF2143E03C55:'+inttostr(rbuf[13]));

  end; //case rbuf[13] of


 //`````````````````````````````````````````````````````````````````````````````
 //````` ������� �� ������  (��� ���� ���������� � �������� mes: KSBMes) ````````
 //`````````````````````````````````````````````````````````````````````````````
 // !!! �� �������� ������ !!!
 //
  $8D:
  begin
    for i:=1 to ((rbuf[5]-10) div 16)  do
    begin
      //st:={#13+#10+}DateTimeToStr(UnPackTime(rbuf[16*i]))+ '  ��� �������='+inttostr(rbuf[16*i+4])+'  �������='+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
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
      case rbuf[16*i+4] of //��� �������
        0:;

        1://����
        begin
          pzn:= rub.FindZN(rbuf[16*i+5], 0);
          if (pzn=nil) then
            case rbuf[16*i+9]+256*rbuf[16*i+10] of
              $8280:
              begin
                //������ ������� ��������������� ���������� ������
                continue;
              end;
              $8281, $8282:
                continue;
            end;

          j:= pzn^.Number;
          mes.TypeDevice:= 4;
          TheKSBParam.WriteIntegerParam(mes, data, '����� ����', j);

          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8280:
            begin
              st:= '������� ���� ['+ValToStr(rbuf[16*i+5])+'] N='+inttostr(j) +' ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_ZONE_CREATE;
              mGetZone(rbuf[16*i+5], j);
            end;
            $8281:
            begin
              st:= '������������� ���� ['+ValToStr(rbuf[16*i+5])+'] N='+inttostr(j) +' ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_ZONE_CHANGE;
              mGetZone(rbuf[16*i+5], j);
            end;
            $8282:
            begin
              rub.ZN.Remove(pzn);
              Dispose(pzn);
              st:= '������� ���� ['+ValToStr(rbuf[16*i+5])+'] N='+inttostr(j) +' ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);;
              mes.Code:= R8_ZONE_DELETE;
              SaveR8c('����', inttostr(j), '');
              rub.NeedSaveR8h:= True;
            end;
            else
              Raise Exception.Create ('����������� ������� ���� E53367E3-710A-4678-873E-C8B492D44206:'+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2));
          end;//case rbuf[16*i+9]+256*rbuf[16*i+10] of
        end;//1:����


        2://��
        begin
          ptc:= rub.FindTC(rbuf[16*i+7]+256*rbuf[16*i+8], 0);
          if ptc=nil then
          begin
            //������ ������� ��������������� ���������� ������
            continue;
          end;

          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            1: //������������
            begin
              case ptc^.Kind of
                1..4: st:= '������������ �'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' ����� "�������" ��� �� �'+inttostr(ptc^.ZoneVista);
                5: st:= '������������ �'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' ����� "�������" ��� ���� �'+inttostr(ptc^.ZoneVista);
                6: st:= '������������ �'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' ����� "�������" ��� �� �'+inttostr(ptc^.ZoneVista);
                7: st:= '������������ �'+ inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) +' ����� "�������" ��� ��������� �'+inttostr(ptc^.ZoneVista);
                else Raise Exception.Create ('����������� ��� �� 11A97E80-CDCB70441:'+inttostr(ptc^.Kind));
              end;
              mes.Code:=R8_SH_HANDSHAKE;
            end;
            $101: //+� ���������� �� ������
            begin
              ptc^.State:= ptc^.State or $02;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_ARMED;
              st:= '���������� �� ������ �� �'+inttostr(ptc^.ZoneVista)+ ' ������������� �'+ inttostr(ptc^.tempUser);
              CheckZoneOperation(ptc^.PartVista, 1);
            end;
            $102: //-� ������ � ������
            begin
              ptc^.State:= ptc^.State and $fd;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_DISARMED;
              st:= '������ � ������ �� �'+inttostr(ptc^.ZoneVista)+ ' ������������� �'+ inttostr(ptc^.tempUser);
              CheckZoneOperation(ptc^.PartVista, 0);
            end;
            $103: //+� �������������. ������� ����������� �� � ��������� ��������, ����� ������ ��������� � ��������� ������.
            begin
              ptc^.State:= (ptc^.State and $fe) or $04;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_ALARM;
              st:= '������� ������������� �� �'+inttostr(ptc^.ZoneVista);
            end;
            $104: //+� �������������. ������� ����������� �� � ��������� ���������������, ����� ������ ��������� � ��������� ������, ������, ��� �����.
            begin
              ptc^.State:= ptc^.State or $08;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_CHECK;
              st:= '������������� (��) �� �'+inttostr(ptc^.ZoneVista);
            end;
            $105: //+�+� ����� ���������� �� ������ ��� ��������������. ������� ����������� �� � ��������� ������.
            begin
              ptc^.State:= ptc^.State or $01;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_READY;
              st:= '������� � ����� �� �'+inttostr(ptc^.ZoneVista);
            end;
            $106: //-� �� ����� � ���������� �� ������. ������� ����������� �� � ��������� ��������, ����� ������ ��������� � ��������� ������ ��� ��������������. ������� ����������� �� � ��������� ���������������, ����� ������ ��������� � ��������� �������������� ��� ���������������.
            begin
              ptc^.State:= ptc^.State and $fe;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_NOTREADY;
              st:= '�� ����� � ���������� �� ������ �� �'+inttostr(ptc^.ZoneVista);
            end;
            $107: //-� ����� ��
            begin
              ptc^.State:= ptc^.State and $fb;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_RESET;
              st:='����� �� �'+inttostr(ptc^.ZoneVista)+ ' ������������� �'+ inttostr(ptc^.tempUser);
            end;
            $108: //������. ������� �� �������� � ���������� �� ������ �������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_BYPASS;
              st:= '������� �� �'+inttostr(ptc^.ZoneVista)+ ' ������������� �'+ inttostr(ptc^.tempUser);
            end;
            $109: //-� �������� �� ����. ������� ����������� �� � ��������� ��������, ����� ������ ��������� � ��������� ������ � ��� ���� ���������� �������� �� ����.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_INDELAY;
              st:= '�������� �� ���� ��� ������ � ������ �� �'+inttostr(ptc^.ZoneVista);
            end;
            $10A: //+� �������� �� �����. ������� �������� ��� ���������� ������� �� ������, ���� ��� ���� ���������� �������� �� �����.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_OUTDELAY;
              st:= '�������� �� ����� ��� ���������� �� ������ �� �'+inttostr(ptc^.ZoneVista);
            end;
            $10B: //�������� ����������. ��� ���������� �� ������, ��� �����
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_WAITFORREADY;
              st:= '�������� ���������� �� �'+inttostr(ptc^.ZoneVista);
            end;
            $10C: //�������� ����������. ��� ���������� �� ������, ��� �����
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_WAITFORREADYCANCEL;
              st:= '������ �������� ���������� �� �'+inttostr(ptc^.ZoneVista);
            end;
            //�����,���� (�����-����� �� -�������������-�������- ������- ����������   )     �-�-�-�-�-�
            $201://+�  �������. ������� ����������� �� � ��������� ��������, ����� ������ ��������� � ��-������� ������.
            begin
              ptc^.State:= ptc^.State or $04;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_ALARM;
              st:= '������� �� �'+inttostr(ptc^.ZoneVista);
            end;
            $202://+�  �������������. ������� ����������� �� � ��������� ���������������, ����� ������ ��������� � ��������� ������.
            begin ptc^.State:= ptc^.State or $08;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_CHECK;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����������';
            end;
            $203://-� ����� ��
            begin
              ptc^.State:= ptc^.State and $fb;
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_RESET;
              st:= '����� �� �'+inttostr(ptc^.ZoneVista)+ ' ������������� �'+ inttostr(ptc^.tempUser);
            end;
            $204://+� ����� � ��������������. ������� ����������� �� � ��������� ������.
            begin
              ptc^.State:= ptc^.State or $01;
              ptc^.tempUser:=0;
              mes.Code:= R8_SH_READY;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' � �����';
            end;
            $205://-� �� ����� � ��������������. ������� ����������� �� � ��������� �������� ��� ���������������, ����� ������ ��������� � ��������� ��������. ������� ����������� �� � ��������� ���������������, ����� ������ ��������� � ��������� ���������������.
            begin
              ptc^.State:= ptc^.State and $fe;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_NOTREADY;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' �������';
            end;
            $206://����� ��������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];;
              mes.Code:= R8_SH_TEST;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����� ��������. ������������ �'+ inttostr(ptc^.tempUser);;
            end;
            $207://�������� ��������
            begin
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_TESTPASSEDOK;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' �������� ��������';
            end;
            $208://�������� �� ��������
            begin
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_TESTTIMEOUT;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' �������� �� ��������';
            end;

            //�����,���� (�����-����� �� -�������������-�����- ������- ����������   )     �-�-�-�-�-�
            $301://+�  �������. ������� ����������� �� � ��������� ��������, ����� ������ ��������� � ��-������� ������.
            begin
              ptc^.State:= ptc^.State or $04;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_FIRE_ALARM;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' �����';
            end;
            $302://+�  �������������. ������� ����������� �� � ��������� ���������������, ����� ������ ��������� � ��������� ������.
            begin ptc^.State:= ptc^.State or $08;
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_CHECK;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����������';
            end;
            $303://��������. ��� �����
            begin
              ptc^.tempUser:= 0;
              mes.Code:= R8_SH_FIRE_ATTENTION;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ��������';
            end;
            $304://-� ����� ��
            begin
              ptc^.State:= ptc^.State and $fb;
              ptc^.tempUser:=rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Code:= R8_SH_RESET;
              st:= '����� �� �'+inttostr(ptc^.ZoneVista)+ ' ������������� �'+ inttostr(ptc^.tempUser);
            end;
           $305://+� ����� � ��������������. ������� ����������� �� � ��������� ������.
            begin
              ptc^.State:= ptc^.State or $01;
              ptc^.tempUser:=0;
              mes.Code:= R8_SH_READY;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' � �����';
            end;
            $306://-� �� ����� � ��������������. ������� ����������� �� � ��������� �������� ��� ���������������, ����� ������ ��������� � ��������� ��������. ������� ����������� �� � ��������� ���������������, ����� ������ ��������� � ��������� ���������������.
            begin
              ptc^.State:= ptc^.State and $fe;
              ptc^.tempUser:=0;
              mes.Code:= R8_SH_NOTREADY;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' �������';
            end;
            //������ (�����-����� �� -�������������-�������- ����.2��� - ����.1���)  �-�-�-�-2-1
            $401://������� 0. ������� ����������� �� � ��������� � ������� 0. �������� ��� ���������� ��
            begin
              ptc^.State:= (ptc^.State and $fc) or $00;
              mes.Code:= R8_TECHNO_AREA0;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 0';
            end;
            $402://������� 1. ������� ����������� �� � ��������� � ������� 1. ���������� ��� ���������� ��
            begin
              ptc^.State:= (ptc^.State and $fc) or $01;
              mes.Code:= R8_TECHNO_AREA1;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 1';
            end;
            $403://�������������. ������� ����������� �� � ��������� ���������������.
            begin
              ptc^.State:= (ptc^.State and $f0) or $08;
              mes.Code:= R8_SH_CHECK;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. �������������';
            end;
            $404://��������� ������� 0. ������� ����������� �� � ��������� � ������� 0, ������� 0 ���������������� ��� ���������
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $00;
              //����������
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA0;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 0. �������';
            end;
            $405://��������� ������� 1. ������� ����������� �� � ��������� � ������� 1, ������� 1 ���������������� ��� ���������
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $01;
              //����������
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA1;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 1. �������';
            end;
            $406://������� 2. ������� ����������� �� � ��������� � ������� 2
            begin
              ptc^.State:= (ptc^.State and $fc) or $02;
              mes.Code:= R8_TECHNO_AREA2;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 2';
            end;
            $407://������� 3. ������� ����������� �� � ��������� � ������� 3
            begin
              ptc^.State:= (ptc^.State and $fc) or $03;
              mes.Code:= R8_TECHNO_AREA3;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 3';
            end;
            $408://��������� ������� 2. ������� ����������� �� � ��������� � ������� 2, ������� 2 ���������������� ��� ���������
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $02;
              //����������
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA2;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 2. �������';
            end;
            $409://��������� ������� 3. ������� ����������� �� � ��������� � ������� 3, ������� 3 ���������������� ��� ���������
            begin
              ptc^.State:= (ptc^.State and $f0) or $04 or $03;
              //����������
              mes.TypeDevice:= 5;
              mes.SmallDevice:= ptc^.ZoneVista;
              mes.Code:= R8_TECHNO_AREA3;
              aMain.send(mes);
              mes.Code:= R8_TECHNO_ALARM;
              st:= '���.�� �'+inttostr(ptc^.ZoneVista)+'. ������� 3. �������';
            end;
            //���� (�����-������-�������������-������-���-������) �-�-�-�-���-�
            $501://���.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State or $02;
              mes.Code:= R8_RELAY_1;
              st:= '���� �'+inttostr(ptc^.ZoneVista)+' ��������';
            end;
            $502://����.
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $fd;
              mes.Code:= R8_RELAY_0;
              st:= '���� �'+inttostr(ptc^.ZoneVista)+' ���������';
            end;
            $503://�������� ���������
            begin
              ptc^.State:= ptc^.State and $fd;
              mes.Code:= R8_RELAY_WAITON;
              st:= '���� �'+inttostr(ptc^.ZoneVista)+'. �������� ���������';
            end;
            $504://����������
            begin
              ptc^.State:= ptc^.State or $08;
              mes.Code:= R8_RELAY_CHECK;
              st:= '���� �'+inttostr(ptc^.ZoneVista)+' ����������';
            end;
            $601://���� (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $7;//ptc^.State:= $01;
              mes.Code:= R8_AP_IN;
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����. ������ ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $602://����� (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $7;//ptc^.State:= $01;
              mes.Code:= R8_AP_OUT;
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' �����. ������ ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $603://������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= ptc^.State and $7;//ptc^.State:= $01;
              mes.Code:= R8_AP_PASSENABLE;
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ������ �� ������� �������� ����� ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $604://���������� �����
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $02;
              mes.Code:= R8_AP_DOOROPEN;
              mes.Code:= SUD_DOOR_OPEN;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ���������� ����� ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $605://��������� (!)
            begin
              ptc^.State:= $03;
              mes.Code:= R8_AP_DOORNOCLOSED;
              mes.Code:= SUD_HELD;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ��������� �����';
            end;
            $606://����� (!)
            begin
              ptc^.State:= $04;
              mes.Code:= R8_AP_DOORALARM;
              mes.Code:= SUD_FORCED;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����� �����';
            end;
            $607://���������� �����
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_DOORCLOSE;
              mes.Code:= R8_AP_DOORCLOSE;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ���������� ����� ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $608://������������ (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $05;
              mes.Code:= R8_AP_BLOCKING;
              mes.Code:= RIC_MODE;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ������������ �� ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Level:= APModeToRostek(ptc);
              mes.Partion:= APStateToRostek(ptc);
            end;
            $609://��������������� (!)
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $06;
              mes.Code:= R8_AP_DEBLOCKING;
              mes.Code:= RIC_MODE;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ��������������� �� ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Level:= APModeToRostek(ptc);
              mes.Partion:= APStateToRostek(ptc);
            end;
            $60A://����� �� ������ (!)
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_EXITBUTTON;
              mes.Code:= SUD_GRANTED_BUTTON;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����� �� ������.';
            end;
            $60B://�������������� (�����)
            begin
              mes.Code:= ApEventAfterReset(ptc^.State);
              case mes.Code of
                RIC_MODE:
                begin
                  ptc^.State:= $01;
                  st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����� (����� �����). ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                end;
                SUD_RESETHELD:
                begin
                  ptc^.State:= $01;
                  st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����� (����� ���������). ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                end;
                SUD_RESETFORCED:
                begin
                  ptc^.State:= $01;
                  st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����� (����� ������). ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                end;
                else
                  st:= '�� �'+inttostr(ptc^.ZoneVista)+' ����� (��� ��������). ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              end;//case
              mes.Level:= APModeToRostek(ptc);
              mes.Partion:= APStateToRostek(ptc);
            end;
            $60C://������ �����������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_AUTHORIZATIONERROR;
              if ptc^.tempUser=0 then
              begin
                mes.Code:= SUD_NO_CARD;
                st:= '�� �'+inttostr(ptc^.ZoneVista)+' ��� ����� � ���';
              end
              else
              begin
                mes.Code:= SUD_BAD_PIN;
                st:= '�� �'+inttostr(ptc^.ZoneVista)+' ������ ��������. �������� ������ ������������ �'+inttostr(ptc^.tempUser);
              end;
            end;
            $60D://������ (!)
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_CODEFORGERY;
              mes.Code:= SUD_ACCESS_CHOOSE;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ������� ������� ���� ������������� �' + inttostr(ptc^.tempUser);
              // v !!!
              {
              amain.Log('>1>$60D:������');       //��    !!!
              amain.Log('>2>�� �'+inttostr(ptc^.ZoneVista)+' ������� ������� ���� ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]));  //�� !!!
              amain.Log('>3>�� �'+inttostr(ptc^.ZoneVista)+' ������� ������� ���� ������������� �' + inttostr(ptc^.tempUser));  //�� !!!
              }
              //^ !!!
            end;
            $60E://������ �������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_REQUESTPASS;
              mes.Code:= R8_AP_REQUESTPASS;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ������ ������� ������������� �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $60F://���������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $07;
              mes.Code:= R8_AP_FORCING;
              mes.Code:= R8_AP_FORCING;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ���������. ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $610://��������� ������ �������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_APBERROR;
              mes.Code:= SUD_BAD_APB;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ��������� ������ �������. ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $611://������ ��������
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              ptc^.State:= $01;
              mes.Code:= R8_AP_ACCESSGRANTED; //
              mes.Code:= SUD_ACCESS_GRANTED;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' ������ ��������. ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $612://�������
            begin
              ptc^.State:= $01;
              mes.Code:= R8_AP_ACCESSTIMEOUT;
              mes.Code:= R8_AP_ACCESSTIMEOUT;
              st:= '�� �'+inttostr(ptc^.ZoneVista)+' �������. ������������ �'+inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            //�������� (�����-������ -�������������-�������-����-����������) �-�-�-�-���-�
            $701: //������ ������������
            begin
              mes.Code:= R8_TERM_REQUEST;
              st:= '�������� �'+inttostr(ptc^.ZoneVista)+'. ������ ������������';
            end;
            $702: //������������ ������ ���������
            begin
              ptc^.State:= ptc^.State or $02;
              mes.Code:= R8_TERM_BLOCKING;
              st:= '�������� �'+inttostr(ptc^.ZoneVista)+'. ����������';
            end;
            $703: //������ ����������� ������������
            begin
              mes.Code:= R8_TERM_AUTHORIZATIONERROR;
              st:= '�������� �'+inttostr(ptc^.ZoneVista)+'. ������ �����������';
            end;
            $704: //������� ������� ����. ������� �������� ����� ����, ��������� ������, ������ ����-������� ������������.
            begin
              ptc^.State:= ptc^.State or $04;
              mes.Code:= R8_TERM_CODEFORGERY;
              st:= '�������� �'+inttostr(ptc^.ZoneVista)+'. ������� ������� ����';
            end;
            $705: //�������������� ������ ��������� ����� ������������
            begin
              ptc^.State:= ptc^.State and $f1;
              mes.Code:= R8_TERM_RESET;
              st:= '�������� �'+inttostr(ptc^.ZoneVista)+'. �������������� ������ ��������� ����� ������������';
            end;
            $706: //���������������� �������
            begin
              mes.Code:= R8_TERM_USERCOMMAND;
              st:= '�������� �'+inttostr(ptc^.ZoneVista)+'. ���������������� �������';
            end;

            $8301: //-� �������������� ����������� ��������� ��, �.�. ���������� �� �� ���������� ������ ���
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13]; //���.7.3
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  mes.Code:= R8_SH_RESTORE;
                  st:= '�� �'+inttostr(ptc^.ZoneVista)+'. ������������ ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= ptc^.State and $03;
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  mes.Code:= R8_RELAY_RESTORE;
                  st:= '���� �'+inttostr(ptc^.ZoneVista)+'. ������������� ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= ptc^.State and $03;
                end;
                6:
                begin
                  mes.TypeDevice:= 2;
                  mes.Code:= R8_AP_RESTORE;
                  st:= '�� �'+inttostr(ptc^.ZoneVista)+'. ������������� ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= $01;
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  mes.Code:= R8_TERM_RESTORE;
                  st:= '�������� �'+inttostr(ptc^.ZoneVista)+'. ������������ ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
                  ptc^.State:= ptc^.State and $03;
                end;
                else Raise Exception.Create ('����������� ��� �� 468��-CDCB-4944-B013-C79901D70001:'+inttostr(ptc^.Kind));
              end;//case
            end;

            $8302: //+� ������������� ������������ ��. ������ ������� ������������ ��� �������� ������������, � ������� ������ ������ ��, � ���������, �� �������������� ���������� ���������������� ��.
            begin
              ptc^.State:= ptc^.State or $20{28}; //���.96
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  st:= '�� �' + inttostr(ptc^.ZoneVista)+'. ������������ ����������';
                  mes.Code:= R8_SH_HW_FAULT;
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  st:= '���� �' + inttostr(ptc^.ZoneVista)+'. ������������ ����������';
                  mes.Code:= R8_RELAY_HW_FAULT;
                end;
                6:
                begin
                  mes.SysDevice:= SYSTEM_SUD;
                  mes.TypeDevice:= 2;
                  st:= '�� �' + inttostr(ptc^.ZoneVista)+'. ������������ ����������';
                  mes.Code:= R8_AP_HW_FAULT;
                  mes.Code:= SUD_LOST_LINK_READER;
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  st:= '�������� �' + inttostr(ptc^.ZoneVista)+'. ������������ ����������';
                  mes.Code:= R8_TERM_HW_FAULT;
                end;
                else Raise Exception.Create ('����������� ��� �� 753009556-9901D70002:' + inttostr(ptc^.Kind));
              end;//case
            end;

            $8303: //-� �������������� ����������������� ������������ ��
            begin
              ptc^.State:= ptc^.State and $0f;
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  st:= '�� �' + inttostr(ptc^.ZoneVista)+'. ������������ � �����';
                  mes.Code:= R8_SH_HW_OK;
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  st:= '���� �' + inttostr(ptc^.ZoneVista)+'. ������������ � �����';
                  mes.Code:= R8_RELAY_HW_OK;
                end;
                6:
                begin
                  mes.TypeDevice:= 2;
                  st:= '�� �'+inttostr(ptc^.ZoneVista)+'. ������������ � �����';
                  mes.Code:= R8_AP_HW_OK;
                  mes.Code:= SUD_SET_LINK_READER;
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  st:= '�������� �' + inttostr(ptc^.ZoneVista)+'. ������������ � �����';
                  mes.Code:= R8_TERM_HW_OK;
                end;
                else Raise Exception.Create ('����������� ��� �� 18891D70003:' + inttostr(ptc^.Kind));
              end;//case
            end;

            $8304: // ��� ���� �� ���������� ��, �� �������� !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  mes.TypeDevice:= 5;
                  mes.Code:= R8_SH_NORIGTH;
                  st:= Format('�� �%d. ��� ���� ���������� � ������������ �%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                5:
                begin
                  mes.TypeDevice:= 7;
                  mes.Code:= R8_RELAY_NORIGTH;
                  st:= Format('���� �%d. ��� ���� ���������� � ������������ �%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                6:
                begin
                  mes.TypeDevice:= 2;
                  mes.Code:= R8_AP_NORIGTH;
                  mes.Code:= SUD_BAD_LEVEL;
                  st:= Format('�� �%d. ��� ���� ���������� � ������������ �%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                7:
                begin
                  mes.TypeDevice:= 8;
                  mes.Code:= R8_TERM_NORIGTH;
                  st:= Format('�������� �%d. ��� ���� ���������� � ������������ �%d', [ ptc^.ZoneVista, rbuf[16*i+12]+256*rbuf[16*i+13] ] );
                end;
                else Raise Exception.Create ('����������� ��� �� 6711AAEE-B013-C79901D70004:' + inttostr(ptc^.Kind));
              end;//case
            end;

            $8380: //������� ��
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
                  st:='������ �� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_SH_CREATE;
                end;
                5:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ����', ptc^.ZoneVista);
                  st:='������� ���� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_RELAY_CREATE;
                end;
                6:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
                  st:='������� �� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_AP_CREATE;
                end;
                7:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ���������', ptc^.ZoneVista);
                  st:='������ �������� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_TERM_CREATE;
                end;
                else Raise Exception.Create ('����������� ��� �� 880EEBB1301D70004:' + inttostr(ptc^.Kind));
              end;//case
              st:= st + ' ������������� �' + inttostr(ptc^.tempUser);
              mGetTC(256*rbuf[16*i+8]+rbuf[16*i+7], rbuf[16*i], rbuf[16*i+9], rbuf[16*i+12]);
              mGetStateTC(256*rbuf[16*i+8]+rbuf[16*i+7], 1);
            end;

            $8381: //������������� ��
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
                  st:= '������������ �� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_SH_CHANGE;
                end;
                5:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ����', ptc^.ZoneVista);
                  st:= '������������� ���� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_RELAY_CHANGE;
                end;
                6:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
                  st:= '������������� �� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_AP_CHANGE;
                end;
                7:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ���������', ptc^.ZoneVista);
                  st:= '������������ �������� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N='+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_TERM_CHANGE;
                end;
                else Raise Exception.Create ('����������� ��� �� 80100D-CDCB-4944-B013-C79901D70004:' + inttostr(ptc^.Kind));
              end;//case
              st:= st + ' ������������� �' + inttostr(ptc^.tempUser);
              mGetTC(256*rbuf[16*i+8]+rbuf[16*i+7], rbuf[16*i], rbuf[16*i+9], rbuf[16*i+12]);
              mGetStateTC(256*rbuf[16*i+8]+rbuf[16*i+7], 1);
            end;

            $8382: //������� ��
            begin
              ptc^.tempUser:= rbuf[16*i+12]+256*rbuf[16*i+13];
              case ptc^.Kind of
                1..4:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
                  if ptc^.ZoneVista>SH_MAX then DeleteR8c('��', inttostr(ptc^.ZoneVista)) else SaveR8c('��', inttostr(ptc^.ZoneVista), '');
                  st:= '������ �� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_SH_DELETE;
                end;
                5:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ����', ptc^.ZoneVista);
                  if ptc^.ZoneVista>RL_MAX then DeleteR8c('����', inttostr(ptc^.ZoneVista)) else SaveR8c('����', inttostr(ptc^.ZoneVista), '');
                  st:= '������� ���� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_RELAY_DELETE;
                end;
                6:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
                  if ptc^.ZoneVista>AP_MAX then DeleteR8c('��', inttostr(ptc^.ZoneVista)) else SaveR8c('��', inttostr(ptc^.ZoneVista), '');
                  st:= '������� �� ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_AP_DELETE;
                end;
                7:
                begin
                  TheKSBParam.WriteIntegerParam(mes, data, '����� ���������', ptc^.ZoneVista);
                  if ptc^.ZoneVista>TERM_MAX then DeleteR8c('��������', inttostr(ptc^.ZoneVista)) else SaveR8c('��������', inttostr(ptc^.ZoneVista), '');
                  st:= '������� TERM ['+inttostr(256*rbuf[16*i+8]+rbuf[16*i+7])+'] N'+inttostr(ptc^.ZoneVista);
                  mes.Code:= R8_TERM_DELETE;
                end;
                else Raise Exception.Create ('����������� ��� �� 33944D-CDCB-4944-B013-C79901D70004:' + inttostr(ptc^.Kind));
              end;//case
              st:= st + ' ������������� �' + inttostr(ptc^.tempUser);
              rub.TC.Remove(ptc);
              Dispose(ptc);
              GetStateZN(ptc^.PartVista); // ������ ��������� ��-�� ����
              rub.NeedSaveR8h:= True;
            end;

            ELSE
              st:=Format('����������� ������� %x �� ���� %d', [ rbuf[16*i+9]+256*rbuf[16*i+10], rbuf[16*i+4] ]);

          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of

          //---------------------------------------//
          // ������������� ������������ mes ��� �� //
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
                  Raise Exception.Create ('����������� ��� �� 344E80-CDCB-4944-B013-C79901220004:' + inttostr(ptc^.Kind));
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
              mes.TypeDevice:= 2; //�����������
              mes.SmallDevice:= ptc^.ZoneVista;
            end;
            $701..$799:
            begin
              mes.TypeDevice:= 8;
              mes.SmallDevice:= ptc^.ZoneVista;
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
            end;
            $8301..$8304:
            begin
              case ptc^.Kind of
                6:
                begin
                  mes.SysDevice:= SYSTEM_SUD;
                  mes.TypeDevice:= 2; //�����������
                end;
              end;//case
              mes.SmallDevice:= ptc^.ZoneVista;
            end;
            $8380..$8382:
            begin
              mes.TypeDevice:= 4;
              mes.SmallDevice:= 0;
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
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
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
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
                      TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', ptc^.tempUser);
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
              TheKSBParam.WriteIntegerParam(mes, data, '����� �����', rbuf[16*i+12]+256*rbuf[16*i+13]);
          end;

          case mes.Code of
            SUD_ACCESS_CHOOSE:
              TheKSBParam.WriteIntegerParam(mes, data, '����� �����', ptc^.tempUser);
          end;

          if option.Logged_OnReadBCPCalculateStateZone then
            aMain.Log('Logged_OnReadBCPCalculateStateZone: ������� ���� �'+inttostr(ptc^.PartVista)+ ', ������������ �'+ inttostr(ptc^.tempUser));

          case mes.Code of
            R8_SH_ALARM,
            R8_SH_RESTORE,
            R8_SH_ARMED,
            R8_SH_DISARMED,
            R8_SH_BYPASS,
            R8_SH_RESET:
            GetStateZN(ptc^.PartVista, ptc); //�������� ���� ��� ���������� ������������
          end;

        end; //2:��


        3://������������-������ (�� ��������� ������)
        begin
          //����������� pcu, mes.smalldevice, mes.user, NewMes
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
            1: //������������
            begin
              st:= '������������ �'+ inttostr(mes.User) +' ����� "�������" ��� �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_SH_HANDSHAKE);
            end;
            $101..$999:
            begin
              st:= Format('������� �������� [%d] �� [%s:%d], �� ���������� � ��', [ rbuf[16*i+9]+256*rbuf[16*i+10], HWTypeToStr(rbuf[16*i+5]), rbuf[16*i+6]+256*rbuf[16*i+7] ]);
              EventLogAndTrySend(pcu, st, 0);
            end;
            $2001:
            begin
              if (pcu<>nil) then
                pcu^.State:= pcu^.State and $FE;
              st:= '������ ����� � �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
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
              st:= '�������������� ����� � �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
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
              if pcu=nil then //������ �������???  BACK
              begin
                st:= '�������� ���';
                EventLogAndTrySend(pcu, st, R8_BCP_OPEN);
              end
              else
              begin
                st:= '�������� �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
                EventLogAndTrySend(pcu, st, R8_CU_OPEN);
              end;
            $2101:
            begin
              st:= '��������� ���';
              EventLogAndTrySend(pcu, st, R8_POWER_UP);
            end;
            $2102:
            begin
              st:= '���������� ���';
              EventLogAndTrySend(pcu, st, R8_POWER_DOWN);
            end;
            $2103:
            begin
              st:= '������ ������� ������ ��� ������������� �'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_USER_ENTER);
            end;
            $2104:
            begin
              st:= '����� ������� ������ ��� ������������� �'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_USER_EXIT);
            end;
            $2105:
            begin
              st:= '���� � ����� ���������������� ������������� �'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_ENTER_CONF);
            end;
            $2106:
            begin
              st:= '������ ����������� ���������';
              EventLogAndTrySend(pcu, st, R8_UNKNOWN_USER);
            end;
            $2107:
            begin
              st:= '���������� ���������� ��� ��� �����������';
              EventLogAndTrySend(pcu, st, R8_LOCK_KEYBOARD);
            end;
            $2108:
            begin
              st:= '��������� ������ ���. ������ �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]) + ' (' + HWTypeBCPError(rbuf[16*i+12]+256*rbuf[16*i+13])+')';
              rub.ErrorCode:= rbuf[16*i+12]+256*rbuf[16*i+13];
              mes.Level:= rub.ErrorCode;
              EventLogAndTrySend(pcu, st, R8_SYSERROR);
            end;
            $2109:
            begin
              st:= '�������� ������� ���';
              EventLogAndTrySend(pcu, st, R8_OPEN);
            end;
            $210A:
            begin
              st:= '��������� ����� ���';
              EventLogAndTrySend(pcu, st, R8_SETTIME);
            end;
            $210B:
            begin
              st:= '��������� ����� ���';
              EventLogAndTrySend(pcu, st, R8_SETTIME);
            end;
            $210D:
            begin
              st:= '���. ������� �� ��������� �������';
              EventLogAndTrySend(pcu, st, R8_RESERV_POWER);
            end;
            $210E:
            begin
              st:= '���. �������������� �������� �������';
              EventLogAndTrySend(pcu, st, R8_NORMAL_POWER);
            end;
            $210F:
            begin
              st:= '������ ��';
              EventLogAndTrySend(pcu, st, R8_BAT_LOW);
            end;
            $2110:
            begin
              st:= '�������������� ��';
              EventLogAndTrySend(pcu, st, R8_BAT_NORMAL);
            end;
            $2117:
            begin
              st:= '������� � ��������� ���������� ������������� �' + inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_WORKSETTINGS);
            end;
            $2118:
            begin
              st:= '������������� ����� ���';
              EventLogAndTrySend(pcu, st, R8_SYNC_TIME);
            end;
            $2126:
            begin
              st:= '����� ��� ������������� �' + inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_RESET);
            end;
            $2127://����������� �������
            begin
              st:= '��������� ������������';
              EventLogAndTrySend(pcu, st, R8_SELFTEST);
            end;
            $2128:
            begin
              st:= '����� ��������� ������ ��� ������������� �' + inttostr(mes.User);
              rub.ErrorCode:= $FF;
              EventLogAndTrySend(pcu, st, R8_OK);
            end;
            $211A:
            begin
              st:= '����� APB ���� �������������';
              EventLogAndTrySend(pcu, st, R8_BCP_ALLUSERSETSTATE);
            end;
            $2501:
            begin
              {
              mes.TypeDevice:= 9;
              mes.SmallDevice:= rbuf[16*i+6]+256*rbuf[16*i+7];
              mes.NumDevice:= mes.SmallDevice;
              st:= '�������� ������� ��� �'+inttostr(mes.SmallDevice);
              mes.Code:=R8_UPS_ACCESS;
              }
            end;
            $2502:
            begin
              st:= '������������� ������ 1 ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT1_BAD);
            end;
            $2503:
            begin
              st:= '�������������� ������ 1 ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT1_OK);
            end;                          
            $2504:
            begin
              st:= '������������� ������ 2 ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT2_BAD);
            end;
            $2505:
            begin
              st:= '�������������� ������ 2 ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_OUT2_OK);
            end;
            $2506:
            begin
              st:= '������������� ����� 220 ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_IN220_BAD);
            end;
            $2507:
            begin
              st:= '�������������� ����� 220 ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_IN220_OK);
            end;
            $2508:
            begin
              st:= '������ (�������������) �� ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_BAD);
            end;
            $2509:
            begin
              st:= '����� � ����� (��������������) �� ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_OK);
            end;
            $250A:
            begin
              st:= '������� �� ������ ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_RESERV_ON);
            end;
            $250B:
            begin
              st:= '�������������� ������� 220 ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_RESERV_OFF);
            end;
            $250C:
            begin
              st:= '���������� �� ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_DISCONNECT);
            end;
            $250D:
            begin
              st:= '����������� �� ��� ['+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_UPS_BAT_CONNECT);
            end;
            $320b:
            begin
              st:= '�������� �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] �'+inttostr(mes.SmallDevice);
              EventLogAndTrySend(pcu, st, R8_CU_OPEN);
            end;
            $8480:
            begin // ������� ��
              //��� NewMes � ������ �� ������� �� ��������� ��
              //������� ���� pcu=nil �� ��� ������ ������� ��� ������� ��������� ��
              if (pcu=nil)and NewMes then
                mes.Mode:= rub.FindEmpty_1001_IdCU;
              if (pcu<>nil) then
                mes.Mode:= pcu^.Number;

              st:= '������� �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] N='+inttostr(mes.Mode)+' ������������� �'+inttostr(mes.User);
              EventLogAndTrySend(pcu, st, R8_CU_CREATE);
              SaveR8c('��', inttostr(mes.Mode), HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7]) );
              if NewMes then
              begin
                mGetCU(rbuf[16*i+6]+256*rbuf[16*i+7], rbuf[16*i+5], mes.Mode);
                mGetStateCU(rbuf[16*i+5], rbuf[16*i+6]+256*rbuf[16*i+7]);
              end;
            end;

            $8481,
            $8381:
            begin // ������������� ��
              j:= pcu^.Number;
              mGetCU (rbuf[16*i+6]+256*rbuf[16*i+7], rbuf[16*i+5], j);
              mGetStateCU(rbuf[16*i+5], rbuf[16*i+6]+256*rbuf[16*i+7]);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ��', j);
              st:= '������������� �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] N='+inttostr(j)+' ������������� �'+inttostr(mes.User);
              mes.Code:= R8_CU_CHANGE;
            end;
            $8482:
            begin // ������� ��
              j:= pcu^.Number;
              rub.CU.Remove(pcu);
              Dispose(pcu);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ��', j);
              st:= '������� �� ['+ HWTypeToStr(rbuf[16*i+5]) +':'+inttostr(rbuf[16*i+6]+256*rbuf[16*i+7])+'] N='+inttostr(j)+' ������������� �'+inttostr(mes.User);
              mes.Code:= R8_CU_DELETE;
              if j>CU_MAX
                then DeleteR8c('��', inttostr(j))
                else SaveR8c('��', inttostr(j), '');
              rub.NeedSaveR8h:= True;
            end;



            Else
              case rbuf[16*i+9]+256*rbuf[16*i+10] of
                0,
                $101..$706,
                $8301:
                else
                begin
                  st:= Format('����������� ������� x%xh �� �� �� (��� %d)', [ rbuf[16*i+9]+256*rbuf[16*i+10], rbuf[16*i+4] ]);
                  Raise Exception.Create (st);
                end;
              end;

          end; // case ������� ��

          //����� ������� �� �� ������ ����
          if (pcu=nil)and NewMes then
            case rbuf[16*i+9]+256*rbuf[16*i+10] of
              $1, $2003,
              $2101..$211A,
              $8481..$8482:; // ���
              $8480:
              begin
                //���� ����� ������� < ������� ������,
                //�� ����������� �� 3 ���. ����������,
                //�.�. �� ����� ������� ��������
                continue;
                //���� ����� ������� >������� ������,
                //������� ����� ��
                //������ ������������ � ���������
                //�� ����������� �� 3 ���. ����������,
              end;
              else
              begin
                //���������� ������������ ��������
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
                aMain.Log('����������� ������! ������������ ����� 5 ���.');
                //����������� ������������
                continue;
              end;
            end;


        end; //3:


        4://������������
        begin
          pus:= rub.FindUS(rbuf[16*i+5]+rbuf[16*i+6]*256);
          if pus=nil then
          begin
            //������ ������� ��������������� ���������� ������
            continue;
          end;
          //
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8501:
            begin
              st:= '����� APB ������������ �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.Code:= R8_USER_APBRESET;
            end;
            $8502:
            begin
              st:= '������������ ������������ �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.Code:= R8_USER_BLOCKING;
            end;
            $8503:
            begin
              st:= '��������������� ������������ �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.Code:= R8_USER_DEBLOCKING;
            end;
            $8580:
            begin
              if pus^.Id<>(pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256) then
              begin
                st:= '������ ������������ �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:=R8_USER_CREATE;
              end
              else
              begin
                st:= '��������� ����� �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Level:= pus^.AL1;
                mes.Code:= SUD_ADDED_CARD;
              end;
              mGetUser(rbuf[16*i+5]+rbuf[16*i+6]*256);
            end;
            $8581:
            begin
              if pus^.Id<>(pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256) then
              begin
                st:= '������������ ������������ �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:= R8_USER_CHANGE;
              end
              else
              begin
                st:= '��������� ����� �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Level:= pus^.AL1;
                mes.Code:= SUD_ADDED_CARD;
              end;
              mGetUser(rbuf[16*i+5]+rbuf[16*i+6]*256);
            end;
            $8582:
            begin
              if pus^.Id<>(pus^.IdentifierCode[1] + pus^.IdentifierCode[2]*256) then
              begin
                st:= '������ ������������ �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:= R8_USER_DELETE;
              end
              else
              begin
                st:= ' ������� ����� �'+inttostr(rbuf[16*i+5]+rbuf[16*i+6]*256);
                mes.Code:= SUD_DELETED_CARD;
              end;
              rub.US.Remove(pus);
              Dispose(pus);
              rub.NeedSaveR8h:= True;
            end;

            else
              st:= '4: ����������� ������� ������������ = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of

          //-----------------------------------------//
          // ������������� ������������ mes ��� User //
          //-----------------------------------------//
          case mes.Code of
            R8_USER_CREATE,
            R8_USER_CHANGE,
            R8_USER_DELETE:
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+5]+rbuf[16*i+6]*256);
            SUD_ADDED_CARD,
            SUD_DELETED_CARD,
            R8_USER_APBRESET,
            R8_USER_BLOCKING,
            R8_USER_DEBLOCKING:
            begin
              TheKSBParam.WriteIntegerParam(mes, data, '����� �����', rbuf[16*i+5]+rbuf[16*i+6]*256);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+5]+rbuf[16*i+6]*256);
              mes.SysDevice:= SYSTEM_SUD;
              mes.TypeDevice:= 1; //���������� �������
            end;
          end;
          //
        end; //4:

        5://����
        begin
          st:= '5: ����';
        end;
        6://������ ���������
        begin
          st:= '6: ������ ���������';
        end;
        7://������ ����������
        begin
          st:= '7: ������ ����������';
        end;
        8:;//����

        9: //������
        begin
          {
          pgr:= rub.FindGR(rbuf[16*i+5]);
          if pgr=nil then
          begin
            //������ ������� ��������������� ���������� ������
            continue;
          end;
          //
          }
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8880:
            begin
              st:= '������� ������ �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������', rbuf[16*i+5]);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_GR_CREATE;
              mGetGR(rbuf[16*i+5]);
            end;
            $8881:
            begin
              st:= '������������� ������ �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������', rbuf[16*i+5]);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_GR_CHANGE;
              mGetGR(rbuf[16*i+5]);
            end;
            $8882:
            begin
              st:= '������� ������ �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������', rbuf[16*i+5]);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_GR_DELETE;
              pgr:= rub.FindGR(rbuf[16*i+5]);
              rub.GR.Remove(pgr);
              Dispose(pgr);
              rub.NeedSaveR8h:= True;
            end;
            else
              st:= '9: ����������� ������� ������ = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case
        end;

        10:// ��
        begin
          {
          pti:= rub.FindTI(rbuf[16*i+5], 1);
          if pti=nil then
          begin
            //������ ������� ��������������� ���������� ������
            continue;
          end;
          }
          //
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
          $8980:
          begin
            st:= '������� �� �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ��', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Code:= R8_TZ_CREATE;
          end;
          $8981:
          begin
            st:= '������������� �� �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ��', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Code:=R8_TZ_CHANGE;
          end;
          $8982:
          begin
            st:= '������� �� �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ��', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
            mes.Code:=R8_TZ_DELETE;
          end;
          else  st:= '10: �� = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of
        end; //10:

        11://��
        begin
          { !!!!!
            ��� ������ �������� ����� ���� ������������, �� �.�������
            � �� �������� ������������� ������� � ��������� �������������� � ��������

          ppr:= rub.FindPR(rbuf[16*i+5]);
          if pti=nil then
          begin
            //������ ������� ��������������� ���������� ������
            continue;
          end;
          }
          //
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
          $8A80:
          begin
            st:= '������ �� �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ��', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
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
            st:= '������������ �� �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ��', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
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
            st:= '������ �� �'+inttostr(rbuf[16*i+5]) + ' ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ��', rbuf[16*i+5]);
            TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', rbuf[16*i+12]+256*rbuf[16*i+13]);
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
          else  st:= '11: �� = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
          end; //case rbuf[16*i+9]+256*rbuf[16*i+10] of

        end; //11:


        12: //��������
        begin
          mes.TypeDevice:=4;
          case rbuf[16*i+9]+256*rbuf[16*i+10] of
            $8B81:
            begin
              st:= '������������� ��������� ������������� �' + inttostr(rbuf[16*i+12]+256*rbuf[16*i+13]);
              mes.Code:= R8_HOLIDAY_EDITED;
              rub.NeedSaveR8h:= True;
            end;
          end;//case
        end; //12:


        13:;//������ ����������
        14:;//�������� �������
        100:;//���
        else st:= inttohex(rbuf[16*i+4],2)+': ������� = '+inttohex(rbuf[16*i+9]+256*rbuf[16*i+10],2);
      end; //case rbuf[16*i+4] of //��� �������



      // ����� ������ � �������� �� ��
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
 //````` ������ �� ������ ���������� �� `````````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````

  $8e:
  case RetCode of
    0:;
    {1..65535: amain.DrvErrorReport(rbuf[11]+256*rbuf[12], 21, 0, 0);} //���.29 ������������� �� ������ ��������� R8_DRV_ANSWER
  end;


 //`````````````````````````````````````````````````````````````````````````````
 //````` ����������� �����``````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````
  $89:
  if rbuf[5]=$0B then
  begin
    st:='����/�����: ' + DateTimeToStr(UnPackTime(rbuf[13]));
    aMain.Log('SEND: ' + st);
    Init(mes);
    mes.SysDevice:=SYSTEM_OPS;
    mes.NetDevice:=rub.NetDevice;
    mes.BigDevice:=rub.BigDevice;
    mes.SmallDevice:=0;
    mes.TypeDevice:=4;
    TheKSBParam.WriteDoubleParam(mes, data, '�����', UnPackTime(rbuf[13]));
    mes.Code:=R8_GETTIME;
    aMain.send(mes);
  end;


 //`````````````````````````````````````````````````````````````````````````````
 //````` ���������������� ``````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````
  $84:
  case rbuf[13] of // ��� �������

    1: // ����-���
    if RetCode = 0 then
    case rbuf[14] of

      $1:;//��������
      $2:;//���������
      $3:;//��������
      $4:;//�������� ������ � ��������� ��
      $5: //�������� ����
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
        st:=DateTimeToStr(now) + ' ������� ��� ����';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:=SYSTEM_OPS;
        mes.NetDevice:=rub.NetDevice;
        mes.BigDevice:=rub.BigDevice;
        mes.TypeDevice:=4;
        mes.Code:= R8_ZONE_ALL_DELETE;
        aMain.send(mes);
        DeleteR8c('����', '');
        DeleteR8c('��', '');
        DeleteR8c('����', '');
        DeleteR8c('��', '');
        DeleteR8c('��������', '');
        rub.NeedSaveR8h:= True;
      end;

      $6: //������
      if (rub.Cmd.comd=1) then
      begin
        pzn:= rub.FindZN(rbuf[16], 0);
        if pzn=nil
          then rub.LoadZN(rbuf[15], rub.Cmd.zn.Number) //���������
          else move(rbuf[15], pzn^, sizeof(TZN)-3); //���������������
        SaveR8c('����', inttostr(rub.Cmd.zn.Number), ValToStr(rub.Cmd.zn.BCPNumber));
        rub.NeedSaveR8h:= True;
      end;

      $7: //������ ������
      begin
        rub.LoadZN(rbuf[15], 0); // ��������� �������� ����������
      end;

      else  aMain.Log('$84: ���� = '+inttostr(rbuf[14]));
    end;// case rbuf[14] of


    2: // ��-���
    if RetCode = 0 then
    case rbuf[14] of

      $1://��������
      if (rub.Cmd.comd=2) then
      begin
        move(rub.Cmd.tc, tt[15], sizeof(TTC)-8-4{newTTC});
        rub.LoadTC(tt[15], rub.Cmd.tc.ZoneVista, rub.Cmd.tc.PartVista);
        case rub.Cmd.tc.Kind of
          1..4: SaveR8c('��', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
          5:    SaveR8c('����', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
          6:    SaveR8c('��', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
          7:    SaveR8c('��������', inttostr(rub.Cmd.tc.ZoneVista), inttostr(rub.Cmd.tc.Sernum));
        end;
        rub.NeedSaveR8h:= True;
      end;
      $2:;//��������� ������������
      $3:;//��������
      $4://������ ������������
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
              SaveR8c('��', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' ������ �� ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
              mes.Code:= R8_SH_CREATE;
            end;
            5:
            begin
              ptc^.ZoneVista:= rub.SetIdTC(256*rbuf[18]+rbuf[17], 5);
              SaveR8c('����', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' ������� ���� ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ����', ptc^.ZoneVista);
              mes.Code:= R8_RELAY_CREATE;
            end;
            6:
            begin
              ptc^.ZoneVista:= rub.SetIdTC(256*rbuf[18]+rbuf[17], 6);
              SaveR8c('��', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' ������� �� ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ��', ptc^.ZoneVista);
              mes.Code:= R8_AP_CREATE;
            end;
            7:
            begin
              ptc^.ZoneVista:= rub.SetIdTC(256*rbuf[18]+rbuf[17], 7);
              SaveR8c('��������', inttostr(ptc^.ZoneVista), inttostr(256*rbuf[18]+rbuf[17]));
              st:= DateTimeToStr(UnPackTime(t[250])) + ' ������ �������� ['+inttostr(256*rbuf[18]+rbuf[17])+'] N='+inttostr(ptc^.ZoneVista);
              TheKSBParam.WriteIntegerParam(mes, data, '����� ���������', ptc^.ZoneVista);
              mes.Code:= R8_TERM_CREATE;
            end;
          end; //case
          if st  <>'' then
          begin
            st:= st  + ' ������������� �' + inttostr(ptc^.tempUser);
            aMain.Log('SEND: '+st);
          end;
          if mes.Code>0 then
          begin
            TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', ptc^.tempUser);
            aMain.Send(mes);
          end;
        end; //if
        rub.NeedSaveR8h:= True;
      end;//$4

      $6:// ������ ������
        rub.LoadTC(rbuf[15], 0, 0);

      else   aMain.Log('$84: �� = '+inttostr(rbuf[14]));
    end;


    3: // ��
    if RetCode = 0 then
    case rbuf[14] of

      $1://��������
      if (rub.Cmd.comd=5) then
      begin
        move(rub.Cmd.cu, tt, sizeof(TCU)-7);
        //�.����� � ���������� ��������� ����� pcu^.Number
        rub.LoadCU(tt, rub.Cmd.cu.Number);
      end;
      $2:;//���������
      $3:;//��������
      $4: //�������� ����
      begin
        if rub.CU.Count>0 then
        for i:= rub.CU.Count-1 downto 0 do
        begin
          pcu:= rub.CU.Items[i];
          Dispose(pcu);
          rub.CU.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' ������� ��� ��';
        aMain.Log('SEND: '+st);
        Init(mes);
        mes.SysDevice:=SYSTEM_OPS;
        mes.NetDevice:=rub.NetDevice;
        mes.BigDevice:=rub.BigDevice;
        mes.TypeDevice:=4;
        mes.Code:= R8_CU_ALL_DELETE;
        aMain.send(mes);
        DeleteR8c('��', '');
        rub.NeedSaveR8h:= True;
      end;
      $5: //������ ����.
      if (rub.Cmd.comd=5) then
      begin
        pcu:= rub.FindCU(256*rbuf[17]+rbuf[16]+65536*rbuf[15], 0);
        if pcu=nil
          then rub.LoadCU(rbuf[15], rub.Cmd.cu.Number)
          else move(rbuf[15], pcu^, sizeof(TCU)-7);
        rub.NeedSaveR8h:= True;
      end;
      $6: //������ ������
        rub.LoadCU(rbuf[15], 0);

      $0c:
      begin
        st:=DateTimeToStr(now) + ' ��: ���� � ����� ���������������� ���';
        aMain.Log(st);
      end;

      $0d:
      begin
        st:=DateTimeToStr(now) + ' ��: ����� �� ������ ���������������� ���';
        aMain.Log(st);
      end;

      else aMain.Log('$84: �� = '+inttostr(rbuf[14]));

    end;//case rbuf[14] of


    4: // User-���
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
         //������ � ����
          WriteScuUserMap('���-���', IntToStr(i), '');
          //�������� �� ��� ���-02
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
        st:=DateTimeToStr(now) + ' ������� ��� ������������';
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
                then aMain.Log('��������� ���� ������������� ���-02 !')
                else
                begin
                  rub.ScuUserMap[i]:= pus^.Id;                                        //������ � ScuUserMap
                  WriteScuUserMap('���-���', IntToStr(i), IntToStr(pus^.Id));         //������ � ����
                  rub.AddUserAllScu(                                                  //�������� �� ��� ���-02
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
              rub.ScuUserMap[i]:= 0;                                              //������ � ScuUserMap
              WriteScuUserMap('���-���', IntToStr(i), '');                        //������ � ����
              rub.DelUserAllScu(i);                                               //�������� �� ��� ���-02
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


    9: //������-���
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
        st:=DateTimeToStr(now)+ ' ������� ��� ������';
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
      $6: //������ ������
        rub.LoadGR(rbuf[15]);
      else aMain.Log('$84: ������ = '+inttostr(rbuf[14])); ;
    end; //case & 9


    10:// ��
    begin
      if Retcode = 0 then
      case rbuf[14] of
        $1,2:; //��������
        $3,4:; //���������
        $5:;   //��������
        $6:    //�������� ����
        begin
          if rub.TI.Count>0 then
          for i:= rub.TI.Count-1 downto 0 do
          begin
            pti:= rub.TI.Items[i];
            Dispose(pti);
            rub.TI.Delete(i);
          end;
          st:=DateTimeToStr(now) + ' ������� ��� ��';
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
        $7: //������ ������
        begin
          rub.LoadTI(rbuf[15]);
        end;
        else   aMain.Log('$84: �� = '+inttostr(rbuf[14])); ;
      end;//case rbuf[14] of

      if (Retcode<>0)and(rbuf[14]=7) then
        rub.NeedSaveR8h:= True;
    end;//10

    11:// ��
    begin
      if RetCode = 0 then
      case rbuf[14] of
        $1,2:; //��������
        $3,4:; //���������
        $5:;   //��������
        $6:    //�������� ����
        begin
          if rub.PR.Count>0 then
          for i:= rub.PR.Count-1 downto 0 do
          begin
            ppr:= rub.PR.Items[i];
            Dispose(ppr);
            rub.PR.Delete(i);
          end;
          st:=DateTimeToStr(now) + ' ������� ��� ��';
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
        else aMain.Log('$84: �� = '+inttostr(rbuf[14])); ;
      end;//case
    end; // 11


    12: // ���������
    if RetCode = 0 then
    case rbuf[14] of
      $1:; //�������������� ����
      $2: //������
        rub.LoadHD(rbuf[15]);
      else aMain.Log('$84: HD = '+inttostr(rbuf[14]));
    end;//case rbuf[14] of
      {
      st:=DateTimeToStr(now) + '  ���������';
      aMain.Log('SEND: '+st);
      mes.SysDevice:=SYSTEM_OPS;
      mes.NetDevice:=rub.NetDevice;
      mes.BigDevice:=rub.BigDevice;
      mes.TypeDevice:=4;
      mes.Code:= R8_HOLIDAY_SET;
      aMain.send(mes);
      rub.NeedSaveR8h:= True;
      }


    14: // ��������
    if RetCode = 0 then
    case rbuf[14] of
      $1:;//��������
      $2:;//���������
      $3:;//��������
      $4: //�������� ����
      begin
        if rub.RN.Count>0 then
        for i:= rub.RN.Count-1 downto 0 do
        begin
          prn:= rub.RN.Items[i];
          Dispose(prn);
          rub.RN.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' ������� ��� ��������';
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
      $5:; //������ ����.
      $6: //������ ������
        rub.LoadRN(rbuf[15]);

      else aMain.Log('$84: RN = '+inttostr(rbuf[14]));
    end;//case & 14


    6: // ���������
    if RetCode = 0 then
    case rbuf[14] of
      $1:;//��������
      $2:;//���������
      $3:;//��������
      $4: //�������� ����
      begin
        if rub.RP.Count>0 then
        for i:= rub.RP.Count-1 downto 0 do
        begin
          prp:= rub.RP.Items[i];
          Dispose(prp);
          rub.RP.Delete(i);
        end;
        st:=DateTimeToStr(now) + ' ������� ��� ���������';
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
      $5:; //������ ����.
      $6: //������ ������
        rub.LoadRP(rbuf[15]);
      else aMain.Log('$84: RP = '+inttostr(rbuf[14]));
    end;//case & 6


    13: // ����������
    if RetCode = 0 then
    case rbuf[14] of
      $1:;//��������
      $2: //������ ������
        rub.LoadRI(rbuf[15]);
      else aMain.Log('$84: RI = '+inttostr(rbuf[14]));
    end;//case & 13


    else
      if RetCode = 0 then
       aMain.Log('$84:'+inttostr(rbuf[13])+' = '+inttostr(rbuf[14]));

    end; // $84:



  //`````````````````````````````````````````````````````````````````````````````
 //````` ���������� ��    ``````````````````````````````````````````````````````
 //`````````````````````````````````````````````````````````````````````````````
  $87:
  begin
    aMain.Log('������ 0x87h. F6402E-BB45-EF2143E03C57');
  end;


 //`````````````````````````````````````````````````````````````````````````````
 //````` ���������� ������``````````````````````````````````````````````````````
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
    aMain.StatusBar1.Panels.Items[1].Text:= Format('��� �%d; ������ %d.%d.%d', [ rub.Addr, rbuf[13], rbuf[14], rbuf[17]+256*rbuf[18] ]);
    st:= '';
    for i:=0 to 31 do
      st:= st + Chr(rbuf[24+i]);
    st:= Format('������ ��� %d.%d.%d, ������ �� %d.%d', [ rbuf[13], rbuf[14], rbuf[17]+256*rbuf[18], rbuf[15], rbuf[16] ]);
    //st:= Format('������ ��� %d.%d.%d, ������ �� %d.%d; ����: %s. ��� ���: %d; ��������: %s', [ rbuf[13], rbuf[14], rbuf[17]+256*rbuf[18], rbuf[15], rbuf[16], DateTimeToStr(UnPackTime(rbuf[19])),  rbuf[23], st ]);
    aMain.Log(st);
  end;

  $96:
  if (rbuf[14]+256*rbuf[15])>0 then
  begin
    rub.ErrorCode:= rbuf[16+12]+256*rbuf[16+13];
    st:=DateTimeToStr(UnPackTime(rbuf[16]))+ ' ��������� ������ ���. ������ �' + inttostr(rub.ErrorCode) + ' (' + HWTypeBCPError(rub.ErrorCode)+')';
    aMain.Log(st);
  end
  else rub.ErrorCode:= $FF;

  else //case rbuf[10]
  Raise Exception.Create ('����������� ����� �� ���');

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

 //������� ��������� ����
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
       tState:= tState or (p^.State and $fc); // ����-�.��.-o-�-�
       if (p^.State and $52)=$00 then
         tState:= tState and $fd; // ����
       if (p^.State and $51)=$00 then
         tState:= tState and $fe; // �
       if (p^.State and $10)=$00 then
         IsAllShOff:= False;
     end;//1..3
     4:
     begin
       IsZnEmpty:= false;
       tState:= tState or (p^.State and $fc); // ����-�.��.-o-�-�
       if (p^.State and $10)=$00 then
         IsAllShOff:= False;
     end;//4
   end;//case
   //
   //�������� 0 �����. (��� �����-��)
   if User=0 then
   if p^.tempUser>0 then
     User:= p^.tempUser;
   //
 end;//for

 if IsZnEmpty then
   tState:= 1;
 if IsAllShOff then
   tState:= tState and $fd;

 //����� ���������
 st:= '';
 if pzn^.State<>tState then
 if option.Logged_OnReadBCPStateDebug then
   aMain.StateString(1, pzn, tState, st);
 if st<>'' then
 begin
   st:= '���� >>> ' + st;
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
 aMain.Log('Logged_OnReadBCPCalculateStateZone: �������� ���� �'+inttostr(zn)+': ��='+inttostr(pzn^.State)+' �����='+inttostr(tState)+' �����.='+inttostr(User)+' comd.='+inttostr(rub.comd));

 // ����������
 if (tState and $01)<>(pzn^.State and $01) then
 if rub.WorkTime then
 if (tState and $01)=0 then
 begin
   aMain.Log('SEND: ���� �'+inttostr(pzn^.Number)+ ' �� ������');
   mes.Code:= R8_ZONE_NOTREADY;
   aMain.Send(mes);
 end
 else
 begin
   aMain.Log('SEND: ���� �'+inttostr(pzn^.Number)+ ' ������');
   mes.Code:= R8_ZONE_READY;
   aMain.Send(mes);
 end;

 // ������
 if (tState and $02)<>(pzn^.State and $02) then
 if rub.WorkTime then
 if (tState and $02)=0 then
 begin
   aMain.Log('SEND: ������ � ������ ���� �'+inttostr(pzn^.Number)+ ' ������������� �'+ inttostr(User));
   mes.Code:= R8_ZONE_DISARMED;
   TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', User);
   aMain.Send(mes);
 end
 else
 begin
   aMain.Log('SEND: ���������� �� ������ ���� �'+inttostr(pzn^.Number)+ ' ������������� �'+ inttostr(User));
   mes.Code:= R8_ZONE_ARMED;
   TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', User);
   aMain.Send(mes);
 end;

 // ��������������
 if (tState and $2c)<>(pzn^.State and $2c) then
 if rub.WorkTime then
 if (tState and $2c)=0 then
 begin
   aMain.Log('SEND: ���� �'+inttostr(pzn^.Number)+ ' ������������� ������������� �'+ inttostr(User));
   mes.Code:= R8_ZONE_RESTORE;
   TheKSBParam.WriteIntegerParam(mes, data, '����� ������������', User);
   aMain.Send(mes);
 end;

 // �������
 if (tState and $04)<>(pzn^.State and $04) then
 if rub.WorkTime then
 if (tState and $04)>0 then
 begin
   aMain.Log('SEND: ���� �'+inttostr(pzn^.Number)+ ' � �������');
   mes.Code:= R8_ZONE_ALARM;
   aMain.Send(mes);
 end;

 // �������������
 if (tState and $08)<>(pzn^.State and $08) then
 if rub.WorkTime then
 if (tState and $08)>0 then
 begin
   aMain.Log('SEND: ���� �'+inttostr(pzn^.Number)+ ' ����������');
   mes.Code:= R8_ZONE_CHECK;
   aMain.Send(mes);
 end;

 // ����.
 if (tState and $10)<>(pzn^.State and $10) then
 if rub.WorkTime then
 if (tState and $10)>0 then
 begin
   aMain.Log('SEND: ���� �'+inttostr(pzn^.Number)+ ' �������� ����. ��');
   mes.Code:= R8_ZONE_SH_OFF;
   aMain.Send(mes);
 end
 else
 begin
   aMain.Log('SEND: ���� �'+inttostr(pzn^.Number)+ ' �� �������� ����. ��');
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
 // ��� ���.: 0-��� ��� �����, 1-��� � �����, 2-����� � ������� ���, 3-������� ���
 // �� ��� ����.: �����. - ����. - � - (3����: 1-�����, 2-����� �������, 3-����� �� �������, 4-�����, 5-�������������, 6-��������������, 7-���������)
 // Rostek �����: 0-�������, 1-�����, 2-��� ��� �����, 3-��� � �����, 4-�������, 5-��������, 6,7-������, 8-�� ��������
 Result:= 8;
 case (p^.ConfigDummy[0] shr 1) and $03 of
   0: Result:= 2; //��� ��� �����
   1: Result:= 3; //��� � �����
   2: Result:= 9; //����� � ������� ���
   3: Result:= 10; //������� ���
 end;
 case (p^.State and $0F) of
   5: Result:= 0; //�������������
   6: Result:= 4; //��������������
 end;
 if (p^.Flags and $08)=0 then
   Result:= 8; //�� �������
end;

function APStateToRostek(ptc: pointer): byte;
var
 p: PTTC;
begin
 p:= ptc;
 // �� ��� ����.: �����. - ����. - � - (3����: 1-�����, 2-����� �������, 3-����� �� �������, 4-�����, 5-�������������, 6-��������������, 7-���������)
 // Rostek ����.: 0-��� �����, 1-�����, 2-������ ��������, 3-������ ��������, 4-�������, 5-�������, 6-�������, 7-������������
 if (p^.State and $10)>0 then Result:= 0 //0-��� �����
   else if (p^.State and $28)>0 then Result:= 7 //0-�������������
     else case p^.State of
       $01: Result:= 1; //�����/����� +
       $02: Result:= 2; //����� �������/������ �������� +
       $03: Result:= 4; //���������/������� +
       $04: Result:= 4; //�����/������� +
       $05: Result:= 6; //�������������/������� +
       $06: Result:= 5; //��������������/������� +
       $07: Result:= 4; //���������/������� +
       else Result:= 7; //0-�������������
     end;
end;

//-----------------------------------------------------------------------------
END.





