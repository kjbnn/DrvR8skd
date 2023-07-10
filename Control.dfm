inherited RbControl: TRbControl
  Left = 597
  Top = 228
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsToolWindow
  Caption = 'Панель управления (Рубеж-08)'
  ClientHeight = 413
  ClientWidth = 333
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object RadioGroup1: TRadioGroup [0]
    Left = 5
    Top = 335
    Width = 68
    Height = 74
    Caption = ' Прибор : '
    ItemIndex = 0
    Items.Strings = (
      '№1'
      '№2')
    TabOrder = 0
  end
  object PageControl1: TPageControl [1]
    Left = 5
    Top = 6
    Width = 323
    Height = 323
    ActivePage = TabSheet1
    TabOrder = 1
    object TabSheet4: TTabSheet
      Caption = 'Общие'
      object Label9: TLabel
        Left = 36
        Top = 257
        Width = 86
        Height = 13
        Caption = 'Номер события :'
      end
      object Button24: TButton
        Left = 199
        Top = 12
        Width = 111
        Height = 25
        Caption = 'Версия прибора'
        TabOrder = 0
        OnClick = Button24Click
      end
      object Button1: TButton
        Left = 199
        Top = 104
        Width = 111
        Height = 25
        Caption = 'Уст. Время'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Button25: TButton
        Left = 199
        Top = 42
        Width = 111
        Height = 25
        Caption = 'Слово-состояние'
        TabOrder = 2
        OnClick = Button25Click
      end
      object Button4: TButton
        Left = 199
        Top = 222
        Width = 111
        Height = 25
        Caption = 'Запрос лицензий'
        TabOrder = 3
        OnClick = Button4Click
      end
      object Button18: TButton
        Left = 199
        Top = 252
        Width = 111
        Height = 25
        Caption = 'Чтение событий'
        TabOrder = 4
        OnClick = Button18Click
      end
      object Edit4: TEdit
        Left = 128
        Top = 254
        Width = 53
        Height = 21
        TabOrder = 5
        Text = 'FFFF'
      end
      object Button19: TButton
        Left = 199
        Top = 73
        Width = 111
        Height = 25
        Caption = 'Читать время'
        TabOrder = 6
        OnClick = Button19Click
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Зона'
      object Label6: TLabel
        Left = 10
        Top = 18
        Width = 57
        Height = 13
        Caption = 'Имя зоны :'
      end
      object Label4: TLabel
        Left = 10
        Top = 269
        Width = 40
        Height = 13
        Caption = 'Статус :'
      end
      object Label3: TLabel
        Left = 237
        Top = 250
        Width = 64
        Height = 13
        Caption = 'Список зон :'
      end
      object Edit1: TEdit
        Left = 72
        Top = 14
        Width = 65
        Height = 21
        MaxLength = 8
        TabOrder = 0
        Text = '77AAAA00'
      end
      object Button8: TButton
        Left = 199
        Top = 12
        Width = 111
        Height = 25
        Caption = 'Создать'
        TabOrder = 1
        OnClick = Button8Click
      end
      object Button12: TButton
        Left = 199
        Top = 72
        Width = 111
        Height = 25
        Caption = 'Удалить'
        TabOrder = 2
        OnClick = Button12Click
      end
      object RadioGroup2: TRadioGroup
        Left = 16
        Top = 44
        Width = 121
        Height = 109
        Caption = ' Представление '
        ItemIndex = 0
        Items.Strings = (
          'Имя-номер'
          'Номер-имя'
          'Имя'
          'Номер')
        TabOrder = 3
      end
      object SpinEdit1: TSpinEdit
        Left = 55
        Top = 266
        Width = 49
        Height = 22
        MaxValue = 255
        MinValue = 0
        TabOrder = 4
        Value = 0
      end
      object Button2: TButton
        Left = 199
        Top = 132
        Width = 111
        Height = 25
        Caption = 'Снять'
        TabOrder = 5
        OnClick = Button2Click
      end
      object Button3: TButton
        Left = 199
        Top = 102
        Width = 111
        Height = 25
        Caption = 'Взять'
        TabOrder = 6
        OnClick = Button3Click
      end
      object GroupBox1: TGroupBox
        Left = 16
        Top = 163
        Width = 121
        Height = 77
        Caption = ' Оператор : '
        TabOrder = 7
        object Label5: TLabel
          Left = 12
          Top = 26
          Width = 40
          Height = 13
          Caption = 'Номер :'
        end
        object SpinEdit2: TSpinEdit
          Left = 56
          Top = 25
          Width = 49
          Height = 22
          MaxValue = 65535
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object CheckBox1: TCheckBox
          Left = 10
          Top = 50
          Width = 93
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Проверять'
          TabOrder = 1
        end
      end
      object Button9: TButton
        Left = 199
        Top = 192
        Width = 111
        Height = 25
        Caption = 'Сбосить'
        TabOrder = 8
        OnClick = Button9Click
      end
      object Button10: TButton
        Left = 199
        Top = 162
        Width = 111
        Height = 25
        Caption = 'Обойти'
        TabOrder = 9
        OnClick = Button10Click
      end
      object ComboBox2: TComboBox
        Left = 191
        Top = 265
        Width = 111
        Height = 21
        ItemHeight = 13
        TabOrder = 10
      end
      object Button17: TButton
        Left = 173
        Top = 266
        Width = 20
        Height = 20
        Caption = '>>'
        TabOrder = 11
      end
      object Edit3: TEdit
        Left = 112
        Top = 266
        Width = 55
        Height = 21
        TabOrder = 12
        Text = 'ffff'
      end
      object CheckBox4: TCheckBox
        Left = 16
        Top = 248
        Width = 169
        Height = 17
        Caption = 'Взятие при готовых всех ТС'
        Checked = True
        State = cbChecked
        TabOrder = 13
      end
      object Button34: TButton
        Left = 199
        Top = 41
        Width = 111
        Height = 25
        Caption = 'Редактировать'
        TabOrder = 14
        OnClick = Button34Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'ТС'
      ImageIndex = 1
      object Label10: TLabel
        Left = 10
        Top = 66
        Width = 45
        Height = 13
        Caption = 'Имя ТС :'
      end
      object Label11: TLabel
        Left = 3
        Top = 41
        Width = 52
        Height = 13
        Caption = 'Род.зона :'
      end
      object Label15: TLabel
        Left = 21
        Top = 18
        Width = 34
        Height = 13
        Caption = 'ID ТС :'
      end
      object Label16: TLabel
        Left = 12
        Top = 249
        Width = 86
        Height = 13
        Caption = 'Номер события :'
      end
      object Button15: TButton
        Left = 199
        Top = 12
        Width = 111
        Height = 25
        Caption = 'Создать'
        TabOrder = 0
        OnClick = Button15Click
      end
      object Button16: TButton
        Left = 199
        Top = 72
        Width = 111
        Height = 25
        Caption = 'Удалить'
        TabOrder = 1
        OnClick = Button16Click
      end
      object Edit5: TEdit
        Left = 72
        Top = 38
        Width = 65
        Height = 21
        MaxLength = 8
        TabOrder = 2
        Text = '77AAAA00'
      end
      object Edit6: TEdit
        Left = 72
        Top = 62
        Width = 65
        Height = 21
        MaxLength = 8
        TabOrder = 3
        Text = 'AAAAAA00'
      end
      object SpinEdit6: TSpinEdit
        Left = 72
        Top = 14
        Width = 65
        Height = 22
        MaxValue = 65535
        MinValue = 0
        TabOrder = 4
        Value = 8
      end
      object Panel2: TPanel
        Left = 8
        Top = 96
        Width = 177
        Height = 117
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 5
        object Label13: TLabel
          Left = 21
          Top = 39
          Width = 42
          Height = 13
          Caption = 'ID  HID :'
        end
        object Label12: TLabel
          Left = 10
          Top = 15
          Width = 53
          Height = 13
          Caption = 'Тип устр. :'
        end
        object Label14: TLabel
          Left = 13
          Top = 61
          Width = 50
          Height = 13
          Caption = 'Элемент :'
        end
        object Label19: TLabel
          Left = 20
          Top = 84
          Width = 44
          Height = 13
          Caption = 'Тип ШС :'
        end
        object ComboBox4: TComboBox
          Left = 72
          Top = 12
          Width = 97
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            '01 > БЦП'
            '04 > СКШС-01'
            '09 > СКШС-02'
            '16 > СКШС-03'
            '17 > СКШС-04'
            '08 > СКИУ-01')
        end
        object SpinEdit4: TSpinEdit
          Left = 72
          Top = 35
          Width = 97
          Height = 22
          MaxValue = 65535
          MinValue = 0
          TabOrder = 1
          Value = 797
        end
        object SpinEdit5: TSpinEdit
          Left = 72
          Top = 59
          Width = 49
          Height = 22
          MaxValue = 255
          MinValue = 1
          TabOrder = 2
          Value = 9
        end
        object ComboBox5: TComboBox
          Left = 72
          Top = 84
          Width = 97
          Height = 21
          ItemHeight = 13
          TabOrder = 3
          Items.Strings = (
            '01 > Охранный'
            '02 > Тревожный'
            '03 > Пожарный')
        end
      end
      object Button20: TButton
        Left = 199
        Top = 102
        Width = 111
        Height = 25
        Caption = 'Список'
        TabOrder = 6
        OnClick = Button20Click
      end
      object Edit7: TEdit
        Left = 104
        Top = 246
        Width = 53
        Height = 21
        TabOrder = 7
        Text = 'FFFF'
      end
      object Button21: TButton
        Left = 199
        Top = 132
        Width = 111
        Height = 25
        Caption = 'Взять'
        TabOrder = 8
        OnClick = Button21Click
      end
      object Button22: TButton
        Left = 199
        Top = 162
        Width = 111
        Height = 25
        Caption = 'Снять'
        TabOrder = 9
        OnClick = Button22Click
      end
      object Button28: TButton
        Left = 199
        Top = 191
        Width = 111
        Height = 25
        Caption = 'Сбросить'
        TabOrder = 10
        OnClick = Button28Click
      end
      object Button30: TButton
        Left = 199
        Top = 42
        Width = 111
        Height = 25
        Caption = 'Изменить'
        TabOrder = 11
        OnClick = Button30Click
      end
      object CheckBox5: TCheckBox
        Left = 8
        Top = 224
        Width = 41
        Height = 17
        Caption = 'Вкл.'
        TabOrder = 12
      end
      object GroupBox2: TGroupBox
        Left = 178
        Top = 224
        Width = 121
        Height = 63
        Caption = ' Оператор : '
        TabOrder = 13
        object Label29: TLabel
          Left = 12
          Top = 23
          Width = 40
          Height = 13
          Caption = 'Номер :'
        end
        object SpinEdit11: TSpinEdit
          Left = 56
          Top = 14
          Width = 49
          Height = 22
          MaxValue = 65535
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object CheckBox7: TCheckBox
          Left = 10
          Top = 39
          Width = 93
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Проверять'
          TabOrder = 1
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'СУ'
      ImageIndex = 2
      object Label2: TLabel
        Left = 25
        Top = 18
        Width = 25
        Height = 13
        Caption = 'Тип :'
      end
      object Label1: TLabel
        Left = 32
        Top = 46
        Width = 17
        Height = 13
        Caption = '№ :'
      end
      object Label7: TLabel
        Left = 11
        Top = 81
        Width = 38
        Height = 13
        Caption = 'Линия :'
      end
      object Label8: TLabel
        Left = 21
        Top = 104
        Width = 28
        Height = 13
        Caption = 'Вкл. :'
      end
      object SpinEdit7: TSpinEdit
        Left = 56
        Top = 42
        Width = 57
        Height = 22
        MaxValue = 65535
        MinValue = 0
        TabOrder = 0
        Value = 38
      end
      object Button13: TButton
        Left = 199
        Top = 12
        Width = 111
        Height = 25
        Caption = 'Создать'
        TabOrder = 1
        OnClick = Button13Click
      end
      object Button14: TButton
        Left = 199
        Top = 72
        Width = 111
        Height = 25
        Caption = 'Удалить'
        TabOrder = 2
        OnClick = Button14Click
      end
      object ComboBox3: TComboBox
        Left = 56
        Top = 16
        Width = 97
        Height = 21
        ItemHeight = 13
        TabOrder = 3
        Items.Strings = (
          '04 > СКШС-01'
          '09 > СКШС-02'
          '16 > СКШС-03'
          '17 > СКШС-04'
          '08 > СКИУ-01')
      end
      object SpinEdit3: TSpinEdit
        Left = 56
        Top = 79
        Width = 57
        Height = 22
        MaxValue = 2
        MinValue = 1
        TabOrder = 4
        Value = 1
      end
      object CheckBox2: TCheckBox
        Left = 56
        Top = 104
        Width = 13
        Height = 17
        Alignment = taLeftJustify
        BiDiMode = bdRightToLeftNoAlign
        ParentBiDiMode = False
        TabOrder = 5
      end
      object Button11: TButton
        Left = 199
        Top = 42
        Width = 111
        Height = 25
        Caption = 'Изменить'
        TabOrder = 6
        OnClick = Button11Click
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'ИУ'
      ImageIndex = 4
      object Button5: TButton
        Left = 199
        Top = 12
        Width = 111
        Height = 25
        Caption = 'Включить'
        TabOrder = 0
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 199
        Top = 42
        Width = 111
        Height = 25
        Caption = 'Выключить'
        TabOrder = 1
        OnClick = Button6Click
      end
      object Button7: TButton
        Left = 199
        Top = 72
        Width = 111
        Height = 25
        Caption = 'Состояние'
        TabOrder = 2
        OnClick = Button7Click
      end
    end
    object TabSheet7: TTabSheet
      Caption = 'Люди'
      ImageIndex = 6
      object Label21: TLabel
        Left = 24
        Top = 18
        Width = 42
        Height = 13
        Caption = 'ID User :'
      end
      object Label22: TLabel
        Left = 22
        Top = 42
        Width = 44
        Height = 13
        Caption = 'Пинкод :'
      end
      object Label23: TLabel
        Left = 41
        Top = 113
        Width = 25
        Height = 13
        Caption = 'AL1 :'
      end
      object Label24: TLabel
        Left = 41
        Top = 137
        Width = 25
        Height = 13
        Caption = 'AL2 :'
      end
      object Label25: TLabel
        Left = 20
        Top = 162
        Width = 46
        Height = 13
        Caption = 'ВЗ БЦП :'
      end
      object Label26: TLabel
        Left = 12
        Top = 90
        Width = 54
        Height = 13
        Caption = 'Актив. до :'
      end
      object Label20: TLabel
        Left = 9
        Top = 66
        Width = 57
        Height = 13
        Caption = 'Имя зоны :'
      end
      object Label27: TLabel
        Left = 153
        Top = 162
        Width = 118
        Height = 13
        Caption = '(0-никогда, 255-всегда)'
      end
      object Label28: TLabel
        Left = 153
        Top = 138
        Width = 118
        Height = 13
        Caption = '(0-никогда, 255-всегда)'
      end
      object Shape1: TShape
        Left = 144
        Top = 112
        Width = 1
        Height = 41
      end
      object Shape2: TShape
        Left = 144
        Top = 160
        Width = 1
        Height = 41
      end
      object Label30: TLabel
        Left = 4
        Top = 186
        Width = 62
        Height = 13
        Caption = 'ВЗ Охраны :'
      end
      object Button31: TButton
        Left = 199
        Top = 12
        Width = 111
        Height = 25
        Caption = 'Создать'
        TabOrder = 0
        OnClick = Button31Click
      end
      object Button32: TButton
        Left = 199
        Top = 42
        Width = 111
        Height = 25
        Caption = 'Редактировать'
        TabOrder = 2
        OnClick = Button32Click
      end
      object Button33: TButton
        Left = 199
        Top = 102
        Width = 111
        Height = 25
        Caption = 'Удалить'
        TabOrder = 3
        OnClick = Button33Click
      end
      object CheckBox6: TCheckBox
        Left = 16
        Top = 256
        Width = 97
        Height = 17
        Caption = 'Заблокирван'
        TabOrder = 4
      end
      object Edit8: TEdit
        Left = 72
        Top = 62
        Width = 65
        Height = 21
        MaxLength = 8
        TabOrder = 5
        Text = '77AAAA00'
      end
      object SpinEdit10: TSpinEdit
        Left = 72
        Top = 14
        Width = 65
        Height = 22
        MaxValue = 65535
        MinValue = 1
        TabOrder = 1
        Value = 1
      end
      object SpinEdit12: TSpinEdit
        Left = 72
        Top = 110
        Width = 65
        Height = 22
        MaxValue = 255
        MinValue = 0
        TabOrder = 6
        Value = 0
      end
      object SpinEdit13: TSpinEdit
        Left = 72
        Top = 134
        Width = 65
        Height = 22
        MaxValue = 255
        MinValue = 0
        TabOrder = 7
        Value = 0
      end
      object SpinEdit14: TSpinEdit
        Left = 72
        Top = 158
        Width = 65
        Height = 22
        MaxValue = 255
        MinValue = 0
        TabOrder = 8
        Value = 255
      end
      object DateEdit1: TDateEdit
        Left = 72
        Top = 86
        Width = 88
        Height = 21
        NumGlyphs = 2
        TabOrder = 9
        Text = '01.01.2010'
      end
      object Button27: TButton
        Left = 199
        Top = 72
        Width = 111
        Height = 25
        Caption = 'Запрос'
        TabOrder = 10
        OnClick = Button27Click
      end
      object Edit9: TEdit
        Left = 72
        Top = 38
        Width = 65
        Height = 21
        MaxLength = 8
        TabOrder = 11
        Text = '0'
      end
      object SpinEdit15: TSpinEdit
        Left = 72
        Top = 182
        Width = 65
        Height = 22
        MaxValue = 255
        MinValue = 0
        TabOrder = 12
        Value = 255
      end
    end
    object TabSheet8: TTabSheet
      Caption = 'ВЗ'
      ImageIndex = 7
      object Button26: TButton
        Left = 199
        Top = 12
        Width = 111
        Height = 25
        Caption = 'Создать'
        TabOrder = 0
      end
      object Button35: TButton
        Left = 199
        Top = 42
        Width = 111
        Height = 25
        Caption = 'Редактировать'
        TabOrder = 1
      end
      object Button36: TButton
        Left = 199
        Top = 72
        Width = 111
        Height = 25
        Caption = 'Запрос'
        TabOrder = 2
      end
      object Button37: TButton
        Left = 199
        Top = 102
        Width = 111
        Height = 25
        Caption = 'Удалить'
        TabOrder = 3
      end
      object StringGrid2: TStringGrid
        Left = 8
        Top = 8
        Width = 185
        Height = 73
        ColCount = 3
        DefaultColWidth = 60
        DefaultRowHeight = 16
        FixedCols = 0
        RowCount = 4
        FixedRows = 0
        ScrollBars = ssNone
        TabOrder = 4
      end
    end
    object TabSheet6: TTabSheet
      Caption = 'Эмитатор'
      ImageIndex = 5
      object Label17: TLabel
        Left = 162
        Top = 27
        Width = 31
        Height = 13
        Caption = 'Зона :'
      end
      object Label18: TLabel
        Left = 151
        Top = 49
        Width = 43
        Height = 13
        Caption = 'Раздел :'
      end
      object ListBox1: TListBox
        Left = 5
        Top = 3
        Width = 140
        Height = 70
        ItemHeight = 13
        Items.Strings = (
          'Зона взятa'
          'Зона снята'
          'Зона обойдена'
          'Зона без обхода'
          'Зона неготова'
          'Зона готова'
          'Зона в тревоге'
          'Сброс тревоги зоны'
          'Раздел взят'
          'Раздел снят')
        TabOrder = 0
      end
      object Button29: TButton
        Left = 263
        Top = 24
        Width = 41
        Height = 38
        Caption = '>>'
        TabOrder = 1
        OnClick = Button29Click
      end
      object SpinEdit8: TSpinEdit
        Left = 199
        Top = 21
        Width = 57
        Height = 22
        MaxValue = 1024
        MinValue = 0
        TabOrder = 2
        Value = 0
      end
      object SpinEdit9: TSpinEdit
        Left = 199
        Top = 45
        Width = 57
        Height = 22
        MaxValue = 1024
        MinValue = 0
        TabOrder = 3
        Value = 0
      end
      object StringGrid1: TStringGrid
        Left = 5
        Top = 80
        Width = 301
        Height = 209
        ColCount = 11
        DefaultColWidth = 24
        DefaultRowHeight = 16
        RowCount = 104
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Serif'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected]
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 4
        OnSelectCell = StringGrid1SelectCell
      end
      object CheckBox3: TCheckBox
        Left = 160
        Top = 0
        Width = 89
        Height = 17
        Caption = 'Работа с БЦП'
        TabOrder = 5
      end
    end
  end
  object Panel1: TPanel [2]
    Left = 80
    Top = 340
    Width = 249
    Height = 68
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object ComboBox1: TComboBox
      Left = 8
      Top = 6
      Width = 233
      Height = 21
      ImeMode = imClose
      ItemHeight = 13
      TabOrder = 0
      Text = 'B6-49-01-1D-03-01-81-'
    end
    object Edit2: TEdit
      Left = 8
      Top = 38
      Width = 57
      Height = 21
      TabOrder = 1
    end
    object Button23: TButton
      Left = 103
      Top = 37
      Width = 137
      Height = 25
      Caption = 'Send telegram'
      TabOrder = 2
      OnClick = Button23Click
    end
  end
  object TimerRefrehGrid: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerRefrehGridTimer
    Left = 188
    Top = 168
  end
end
