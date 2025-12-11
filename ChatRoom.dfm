object ChatRoomForm: TChatRoomForm
  Left = 0
  Top = 0
  Caption = #52292#54021#48169
  ClientHeight = 515
  ClientWidth = 366
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 366
    Height = 41
    Align = alTop
    Color = 14470072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object btnMore: TSpeedButton
      Left = 342
      Top = 1
      Width = 23
      Height = 39
      Align = alRight
      OnClick = btnMoreClick
      ExplicitLeft = 160
      ExplicitTop = 8
      ExplicitHeight = 22
    end
    object lblRoomName: TLabel
      Left = 40
      Top = 3
      Width = 3
      Height = 13
    end
    object lblUserCount: TLabel
      Left = 40
      Top = 22
      Width = 3
      Height = 13
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 431
    Width = 366
    Height = 84
    Align = alBottom
    Caption = 'Panel1'
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object pnlRight: TPanel
      Left = 295
      Top = 1
      Width = 70
      Height = 82
      Align = alRight
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblTextCount: TLabel
        Left = 0
        Top = 69
        Width = 28
        Height = 13
        Align = alBottom
        Alignment = taCenter
        Caption = '0/255'
        StyleElements = [seClient, seBorder]
      end
      object btnSend: TButton
        Left = 0
        Top = 0
        Width = 70
        Height = 69
        Align = alClient
        Caption = #51204#49569
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btnSendClick
      end
    end
    object pnlLeft: TPanel
      Left = 1
      Top = 1
      Width = 294
      Height = 82
      Align = alClient
      Caption = 'pnlLeft'
      TabOrder = 1
      object MemoMessage: TMemo
        Left = 1
        Top = 1
        Width = 292
        Height = 80
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnChange = MemoMessageChange
        OnKeyDown = MemoMessageKeyDown
        OnKeyPress = MemoMessageKeyPress
      end
    end
  end
  object ScrollBoxMessages: TScrollBox
    Left = 0
    Top = 41
    Width = 366
    Height = 390
    Align = alClient
    Color = 14470072
    ParentColor = False
    TabOrder = 2
  end
  object PopupMenu1: TPopupMenu
    Left = 312
    object MenuInvite: TMenuItem
      Caption = #52488#45824#54616#44592
      OnClick = MenuInviteClick
    end
    object MenuExit: TMenuItem
      Caption = #53748#51109
      OnClick = MenuExitClick
    end
    object MenuLeave: TMenuItem
      Caption = #45208#44032#44592
      OnClick = MenuLeaveClick
    end
  end
end
