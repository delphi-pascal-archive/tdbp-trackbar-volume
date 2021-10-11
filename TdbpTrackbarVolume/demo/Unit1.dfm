object FormDemo: TFormDemo
  Left = 269
  Top = 136
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'TdbpTrackbarVolume - Demo'
  ClientHeight = 358
  ClientWidth = 523
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    523
    358)
  PixelsPerInch = 120
  TextHeight = 16
  object rgVolumes: TRadioGroup
    Left = 167
    Top = 10
    Width = 149
    Height = 319
    Anchors = [akLeft, akTop, akBottom]
    Caption = ' Volumes : '
    Columns = 2
    ItemIndex = 10
    Items.Strings = (
      '0 %'
      '10 %'
      '20 %'
      '30 %'
      '40 %'
      '50 %'
      '60 %'
      '70 %'
      '80 %'
      '90 %'
      '100 %')
    TabOrder = 0
    OnClick = rgVolumesClick
  end
  object gbTBV: TGroupBox
    Left = 10
    Top = 10
    Width = 149
    Height = 319
    Anchors = [akLeft, akTop, akBottom]
    Caption = ' Speakers : '
    TabOrder = 1
    DesignSize = (
      149
      319)
    object lbVolume: TLabel
      Left = 10
      Top = 30
      Width = 29
      Height = 16
      Caption = '10 %'
    end
    object lbPrecision: TLabel
      Left = 10
      Top = 207
      Width = 62
      Height = 16
      Caption = 'Precision :'
    end
    object dbpTrackbarVolume: TdbpTrackbarVolume
      Left = 59
      Top = 20
      Width = 41
      Height = 184
      Max = 65535
      Orientation = trVertical
      Position = 58981
      TabOrder = 0
      ThumbLength = 15
      TickMarks = tmBoth
      OnChange = dbpTrackbarVolumeChange
      About = 'v0.2 par Julio P. (Diabloporc)'
      MixerLineType = mlct_DST_SPEAKERS
      Mute = False
      TCheckboxMute = cbMute
      TLabel = lbVolume
    end
    object cbMute: TCheckBox
      Left = 10
      Top = 258
      Width = 119
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = 'Mute'
      TabOrder = 1
    end
    object cbSilence: TCheckBox
      Left = 10
      Top = 288
      Width = 119
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = 'Attenuer'
      TabOrder = 2
      OnClick = cbSilenceClick
    end
    object cbPrecision: TComboBox
      Left = 10
      Top = 229
      Width = 129
      Height = 24
      Style = csDropDownList
      Anchors = [akLeft, akBottom]
      ItemHeight = 16
      ItemIndex = 0
      TabOrder = 3
      Text = 'Grande'
      OnChange = cbPrecisionChange
      Items.Strings = (
        'Grande'
        'Normale'
        'Petite'
        'Tres petite'
        'Perso')
    end
  end
  object sBar: TStatusBar
    Left = 0
    Top = 339
    Width = 523
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = ' SPEAKERS : 0 %'
  end
  object gbMixers: TGroupBox
    Left = 325
    Top = 10
    Width = 188
    Height = 319
    Anchors = [akLeft, akTop, akBottom]
    Caption = ' Mixers : '
    TabOrder = 3
    DesignSize = (
      188
      319)
    object lbMixers: TListBox
      Left = 10
      Top = 20
      Width = 168
      Height = 289
      Anchors = [akLeft, akTop, akBottom]
      ItemHeight = 16
      TabOrder = 0
      OnClick = lbMixersClick
    end
  end
  object XPManifest1: TXPManifest
    Left = 112
    Top = 24
  end
  object Timer: TTimer
    Enabled = False
    Interval = 2500
    OnTimer = TimerTimer
    Left = 120
    Top = 64
  end
end
