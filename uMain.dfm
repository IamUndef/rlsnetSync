object MainForm: TMainForm
  Left = 0
  Top = 0
  ActiveControl = editDB
  BorderStyle = bsToolWindow
  Caption = 'www.rlsnet.ru'
  ClientHeight = 326
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object bStart: TButton
    Left = 162
    Top = 128
    Width = 120
    Height = 25
    Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100#1089#1103
    TabOrder = 0
    OnClick = bStartClick
  end
  object gbLog: TGroupBox
    Left = 0
    Top = 156
    Width = 444
    Height = 170
    Align = alBottom
    Caption = #1042#1099#1074#1086#1076
    TabOrder = 1
    object mLog: TMemo
      Left = 2
      Top = 15
      Width = 440
      Height = 153
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object gbDBConnect: TGroupBox
    Left = 0
    Top = 0
    Width = 444
    Height = 120
    Align = alTop
    Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077' '#1082' '#1041#1044
    TabOrder = 2
    object lbDB: TLabel
      Left = 49
      Top = 22
      Width = 80
      Height = 13
      Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbComment: TLabel
      Left = 192
      Top = 42
      Width = 60
      Height = 11
      Caption = '('#1089#1077#1088#1074#1077#1088':'#1087#1091#1090#1100')'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lbUser: TLabel
      Left = 42
      Top = 60
      Width = 87
      Height = 13
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbPassword: TLabel
      Left = 83
      Top = 92
      Width = 46
      Height = 13
      Caption = #1055#1072#1088#1086#1083#1100':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object editDB: TEdit
      Left = 132
      Top = 18
      Width = 180
      Height = 21
      TabOrder = 0
      Text = 'localhost:d:\db\udc.fdb'
    end
    object editUser: TEdit
      Left = 132
      Top = 56
      Width = 180
      Height = 21
      TabOrder = 1
      Text = 'sysdba'
    end
    object editPassword: TEdit
      Left = 132
      Top = 88
      Width = 180
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
      Text = '1'
    end
  end
end
