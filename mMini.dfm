object aMini: TaMini
  Left = 280
  Top = 214
  AlphaBlend = True
  AlphaBlendValue = 180
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  BorderWidth = 3
  Caption = 'aMini'
  ClientHeight = 102
  ClientWidth = 129
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 0
    Width = 129
    Height = 17
    Hint = #1057#1074#1103#1079#1100' '#1089' '#1041#1062#1055
    Align = alTop
    Panels = <
      item
        Alignment = taCenter
        Width = 200
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object StatusBar3: TStatusBar
    Left = 0
    Top = 34
    Width = 129
    Height = 17
    Hint = #1057#1086#1089#1090#1086#1103#1085#1080#1077' '#1076#1088#1072#1081#1074#1077#1088#1072
    Align = alTop
    Panels = <
      item
        Alignment = taCenter
        Width = 200
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object StatusBar2: TStatusBar
    Left = 0
    Top = 17
    Width = 129
    Height = 17
    Hint = #1057#1086#1089#1090#1086#1103#1085#1080#1077' '#1041#1062#1055
    Align = alTop
    Panels = <
      item
        Alignment = taCenter
        Width = 200
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object StatusBar4: TStatusBar
    Left = 0
    Top = 51
    Width = 129
    Height = 17
    Hint = #1055#1077#1088#1077#1076#1072#1085#1086' '#1074' '#1041#1062#1055
    Align = alTop
    Panels = <
      item
        Alignment = taCenter
        Width = 200
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object StatusBar5: TStatusBar
    Left = 0
    Top = 68
    Width = 129
    Height = 17
    Hint = #1055#1088#1080#1085#1103#1090#1086' '#1086#1090' '#1041#1062#1055
    Align = alTop
    Panels = <
      item
        Alignment = taCenter
        Width = 200
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object StatusBar6: TStatusBar
    Left = 0
    Top = 85
    Width = 129
    Height = 17
    Hint = #1054#1073#1098#1077#1082#1090' '#1086#1093#1088#1072#1085#1099
    Align = alTop
    Panels = <
      item
        Alignment = taCenter
        Width = 200
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 56
    Top = 40
  end
end
