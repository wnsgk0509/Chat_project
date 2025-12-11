object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'ChatRooms'
  ClientHeight = 600
  ClientWidth = 400
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnCreate: TButton
      Left = 300
      Top = 0
      Width = 100
      Height = 50
      Align = alRight
      Caption = #48169#49373#49457
      TabOrder = 0
      OnClick = btnCreateClick
    end
    object btnlogout: TButton
      Left = 0
      Top = 0
      Width = 57
      Height = 50
      Align = alLeft
      Caption = #47196#44536#50500#50883
      TabOrder = 1
      OnClick = btnlogoutClick
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 50
    Width = 400
    Height = 550
    Align = alClient
    TabOrder = 1
  end
end
