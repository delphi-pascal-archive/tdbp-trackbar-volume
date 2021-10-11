{
################################################################################
# DBPTRACKBARVOLUME                                                            #
################################################################################
#                                                                              #
# VERSION       : 0.1                                                          #
# FICHIERS      : dbpTrackBarVolume.pas,.dcu,.dcr,.bmp,ReadMe.htm              #
# AUTEUR        : Julio P. (Diabloporc)                                        #
# CREATION      : 29 aou 2008                                                  #
# MODIFIEE      : 05 sep 2008                                                  #
# SITE WEB      : http://diabloporc.free.fr                                    #
# MAIL          : juliobosk@gmail.com                                          #
# LEGAL         : Free sous Licence GNU/GPL                                    #
# INFOS         : Retrouvez moi sur www.delphifr.com : "JulioDelphi"           #
#                 Lisez le ReadMe.htm !                                        #
#                                                                              #
################################################################################
}
unit dbpTrackbarVolume;

interface

uses
  dialogs, Windows, Messages, SysUtils, Classes, Controls, ComCtrls, StdCtrls, MMSystem, ExtCtrls;

type
  TPrecision = (
                prGrande,     //65353 ticks
                prNormale,    //100 ticks (1% le tick)
                prPetite,     //10 ticks (10% le tick)
                prTresPetite, //4 ticks (25% le tick)
                pzPerso
               );
  TMixerLineComponentType = ( mlct_DST_UNDEFINED,   //
                              mlct_DST_DIGITAL,     //
                              mlct_DST_LINE,        //
                              mlct_DST_MONITOR,     //
                              mlct_DST_SPEAKERS,    // Volume Principal
                              mlct_DST_HEADPHONES,  //
                              mlct_DST_TELEPHONE,   //
                              mlct_DST_WAVEIN,      //
                              mlct_DST_VOICEIN,     //
                              mlct_SRC_UNDEFINED,   //
                              mlct_SRC_DIGITAL,     // Entree
                              mlct_SRC_LINE,        // Entree ligne
                              mlct_SRC_MICROPHONE,  // Microphone
                              mlct_SRC_SYNTHESIZER, // Synthé
                              mlct_SRC_COMPACTDISC, // Lecteur CD
                              mlct_SRC_TELEPHONE ,  //
                              mlct_SRC_PCSPEAKER ,  //
                              mlct_SRC_WAVEOUT ,    // Wave
                              mlct_SRC_AUXILIARY,   //
                              mlct_SRC_ANALOG       // Auxiliaire
                             );  {testé sur carte son XiFi.
                                  Merci de remplir les autres champs,
                                  en ajouter et me les renvoyer à
                                  juliobox@free.fr
                                  }
  TdbpTrackbarVolume = class(TTrackBar)
  private
    hMix: HMIXER;
    mxlc: MIXERLINECONTROLS;
    mxcd: TMIXERCONTROLDETAILS;
    vol: TMIXERCONTROLDETAILS_UNSIGNED;
    mcdMute: MIXERCONTROLDETAILS_BOOLEAN;
    mxc: MIXERCONTROL;
    mxl: TMIXERLINE;
    intRet, nMixerDevs: Integer;
    FMute: Boolean;
    FMlct: TMixerLineComponentType;
    FTimer: TTimer;
    FSilence: Boolean;
    FOldOnClickMute: TNotifyEvent;
    FCheckboxMute : TCheckbox;
    FLabel: TLabel;
    FCBState, FPourcent, FMin, FMax: Integer;
    FPrecision: TPrecision;
    FDesc, FAbout: string;
    procedure SetCheckboxMute(Value: TCheckbox);
    procedure SetVolumeF(Value: Integer);
    procedure SetVolumePourcent(Value: Integer; Recalcul: Boolean); Overload;
    procedure SetLabel(Value: TLabel);
    procedure SetMlct(Value: TMixerLineComponentType);
    procedure SetPrecision(Value: TPrecision);
    procedure ProcOnCheckboxMute(Sender: TObject);
    procedure ProcOnTimer(Sender: TObject);
    function GetDescription: string;
    function GetVolume: Integer;
    function GetVolumeF(Value: Integer): Integer;
    function GetVolumeM(Value: Integer): Integer;
    function GetVolumeMute: Boolean;
  protected
    procedure Changed; override;
  public
    tsDescriptions: TStringList;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    procedure SetVolumePourcent(Value: Integer); Overload;
    procedure SetVolumeMute(Value: Boolean);
    procedure SetSilence(Value: Boolean);
    property About:         string read                  FAbout   write      FAbout;
    property Description:   string read                  GetDescription;
    property Pourcent:      Integer read                 FPourcent;
    property Min:           Integer read                 FMin;
    property MixerLineType: TMixerLineComponentType read FMlct write         SetMlct;
    property Mute:          Boolean read                 GetVolumeMute write SetVolumeMute;
    property Precision:     TPrecision read              FPrecision write    SetPrecision default prGrande;
    property TCheckboxMute: TCheckbox read               FCheckboxMute write SetCheckboxMute;
    property TLabel:        TLabel read                  FLabel write        SetLabel;
  end;

procedure Register;

implementation

procedure TdbpTrackbarVolume.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (aComponent = FLabel) and (Operation = opRemove) then
    FLabel := nil;
  if (aComponent = FCheckboxMute) and (Operation = opRemove) then
    FCheckboxMute := nil;
end;

Procedure TdbpTrackbarVolume.SetVolumeMute(Value: Boolean);
var RealOrd: Integer;
Begin
  nMixerDevs := mixerGetNumDevs();
  If ((nMixerDevs < 1)) Then Exit;
  intRet := mixerOpen(@hMix, 0, 0, 0, 0);
  If (intRet = MMSYSERR_NOERROR) Then
  Begin
    RealOrd:= Ord(FMlct);
    if RealOrd>=9 then Inc(RealOrd, 4087);
    mxl.dwComponentType := RealOrd;
    mxl.cbStruct := SizeOf(mxl);
    intRet := mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE);
    If (intRet = MMSYSERR_NOERROR) Then
    Begin
      FillChar(mxlc, SizeOf(mxlc), 0);
      mxlc.cbStruct := SizeOf(mxlc);
      mxlc.dwLineID := mxl.dwLineID;
      mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_MUTE;
      mxlc.cControls := 1;
      mxlc.cbmxctrl := SizeOf(mxc);
      mxlc.pamxctrl := @mxc;
      intRet := mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE);
      If (intRet = MMSYSERR_NOERROR) Then
      Begin
        FillChar(mxcd, SizeOf(mxcd), 0);
        mxcd.cbStruct := SizeOf(TMIXERCONTROLDETAILS);
        mxcd.dwControlID := mxc.dwControlID;
        mxcd.cChannels := 1;
        mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN);
        mxcd.paDetails := @mcdMute;
        mcdMute.fValue := Ord(Value);
        intRet := mixerSetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE);
      End;
    End;
    intRet := mixerClose(hMix);
  End;
End;

Procedure TdbpTrackbarVolume.SetVolumeF(Value: Integer);
var RealOrd: Integer;
Begin
  nMixerDevs := mixerGetNumDevs();
  If ((nMixerDevs < 1)) Then Exit;
  intRet := mixerOpen(@hMix, 0, 0, 0, 0);
  If (intRet = MMSYSERR_NOERROR) Then
  Begin
    RealOrd:= Ord(FMlct);
    if RealOrd>=9 then Inc(RealOrd, 4087);
    mxl.dwComponentType := RealOrd;
    mxl.cbStruct := SizeOf(mxl);
    intRet := mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE);
    If (intRet = MMSYSERR_NOERROR) Then
    Begin
      FillChar(mxlc, SizeOf(mxlc), 0);
      mxlc.cbStruct := SizeOf(mxlc);
      mxlc.dwLineID := mxl.dwLineID;
      mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_VOLUME;
      mxlc.cControls := 1;
      mxlc.cbmxctrl := SizeOf(mxc);
      mxlc.pamxctrl := @mxc;
      intRet := mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE);
      If (intRet = MMSYSERR_NOERROR) Then
      Begin
        FillChar(mxcd, SizeOf(mxcd), 0);
        mxcd.dwControlID := mxc.dwControlID;
        mxcd.cbStruct := SizeOf(mxcd);
        mxcd.cMultipleItems := 0;
        mxcd.cbDetails := SizeOf(Vol);
        mxcd.paDetails := @vol;
        mxcd.cChannels := 1;
        vol.dwValue := Value;
        intRet := mixerSetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE);
      End;
    End;
    intRet := mixerClose(hMix);
  End;
End;

Function TdbpTrackbarVolume.GetVolumeMute: Boolean;
var RealOrd: Integer;
Begin
  Result:= True;
  FCBState:= 1;
  nMixerDevs := mixerGetNumDevs();
  If ((nMixerDevs < 1)) Then Exit;
  intRet := mixerOpen(@hMix, 0, 0, 0, 0);
  If (intRet = MMSYSERR_NOERROR) Then
  Begin
    RealOrd:= Ord(FMlct);
    if RealOrd>=9 then Inc(RealOrd, 4087);
    mxl.dwComponentType := RealOrd;
    mxl.cbStruct := SizeOf(mxl);
    intRet := mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE);
    If (intRet = MMSYSERR_NOERROR) Then
    Begin
      FillChar(mxlc, SizeOf(mxlc), 0);
      mxlc.cbStruct := SizeOf(mxlc);
      mxlc.dwLineID := mxl.dwLineID;
      mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_MUTE;
      mxlc.cControls := 1;
      mxlc.cbmxctrl := SizeOf(mxc);
      mxlc.pamxctrl := @mxc;
      intRet := mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE);
      If (intRet = MMSYSERR_NOERROR) Then
      Begin
        FillChar(mxcd, SizeOf(mxcd), 0);
        mxcd.cbStruct  := SizeOf(TMIXERCONTROLDETAILS);
        mxcd.dwControlID := mxc.dwControlID;
        mxcd.cChannels := 1;
        mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN);
        mxcd.paDetails := @mcdMute;
        intRet         := mixerGetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE);
        Result         := not (mcdMute.fValue = 0);
        if Result then FCBState:= 1 else FCBState:= 0;
      End;
        End;
    if (intRet <> MMSYSERR_NOERROR) and Assigned(FCheckboxMute) then
          FCBState:= 2;
    intRet := mixerClose(hMix);
  End;
  if Assigned(FCheckboxMute) then
    FCheckboxMute.State:= TCheckboxState(FCBState);
End;

Function TdbpTrackbarVolume.GetVolume: Integer;
var RealOrd: Integer;
Begin
  Result:= 0;
  nMixerDevs := mixerGetNumDevs();
  If ((nMixerDevs < 1)) Then Exit;
  intRet := mixerOpen(@hMix, 0, 0, 0, 0);
  If (intRet = MMSYSERR_NOERROR) Then
  Begin
    RealOrd:= Ord(FMlct);
    if RealOrd>=9 then Inc(RealOrd, 4087);
    mxl.dwComponentType := RealOrd;
    mxl.cbStruct := SizeOf(mxl);
    intRet := mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE);
    If (intRet = MMSYSERR_NOERROR) Then
    Begin
      FillChar(mxlc, SizeOf(mxlc), 0);
      mxlc.cbStruct := SizeOf(mxlc);
      mxlc.dwLineID := mxl.dwLineID;
      mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_VOLUME;
      mxlc.cControls := 1;
      mxlc.cbmxctrl := SizeOf(mxc);
      mxlc.pamxctrl := @mxc;
      intRet := mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE);
      If (intRet = MMSYSERR_NOERROR) Then
      Begin
        FillChar(mxcd, SizeOf(mxcd), 0);
        mxcd.dwControlID := mxc.dwControlID;
        mxcd.cbStruct := SizeOf(mxcd);
        mxcd.cMultipleItems := 0;
        mxcd.cbDetails := SizeOf(Vol);
        mxcd.paDetails := @vol;
        mxcd.cChannels := 1;
        intRet := mixerGetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE);
        Result := vol.dwValue;
      End;
    End;
    SliderVisible:= (intRet = MMSYSERR_NOERROR);
    intRet := mixerClose(hMix);
  End;
End;

procedure Register;
begin
  RegisterComponents('Diabloporc', [TdbpTrackbarVolume]);
end;

constructor TdbpTrackbarVolume.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAbout:= 'v0.2 par Julio P. (Diabloporc)';
  Max:= 65535;
  FMin:= 0;
  Orientation:= trVertical;
  FSilence:= False;
  Position:= Max;
  FPrecision:= prGrande;
  TickMarks:= tmBoth;
  FMlct:= mlct_DST_SPEAKERS;
  FDesc:= 'DST_SPEAKERS';
  ThumbLength:= 15;
  Width:= 33;
  FTimer:= TTimer.Create(Self);
  FTimer.Interval:= 100;
  FTimer.Enabled:= True;
  FTimer.OnTimer:= ProcOnTimer;
  tsDescriptions:= TStringList.Create;
  tsDescriptions.CommaText:= 'DST_UNDEFINED,DST_DIGITAL,DST_LINE,DST_MONITOR,DST_SPEAKERS,DST_HEADPHONES,DST_TELEPHONE,DST_WAVEIN,DST_VOICEIN,SRC_UNDEFINED,SRC_DIGITAL,SRC_LINE,SRC_MICRO,SRC_SYNTHETIZER,SRC_COMPACTDISC,SRC_TELEPHONE,SRC_PCSPEAKER,SRC_WAVEOUT,SRC_AUXILIARY,SRC_ANALOG';
end;

procedure TdbpTrackbarVolume.ProcOnTimer(Sender: TObject);
begin
  if Orientation = trVertical then
       Position:= Max - GetVolumeM(GetVolume)
  else Position:= GetVolumeM(GetVolume);
  FMute:= GetVolumeMute;
end;

destructor TdbpTrackbarVolume.Destroy;
begin
  tsDescriptions.Free;
  FTimer.Free;
  inherited;
end;

procedure TdbpTrackbarVolume.Changed;
begin
  if Orientation = trVertical then
       SetVolumePourcent(Max - Position, True)
  else SetVolumePourcent(Position, True);
  if Assigned(FLabel) then
    FLabel.Caption:= IntToStr(100 - GetVolumeF(Position))+' %';
  inherited;
end;

procedure TdbpTrackbarVolume.SetVolumePourcent(Value: Integer);
begin
  SetVolumePourcent(Value, False);
end;

procedure TdbpTrackbarVolume.SetVolumePourcent(Value: Integer; Recalcul: Boolean);
begin
  if Recalcul then
    SetVolumeF(Round(GetVolumeF(Value) * 65535 / 100))
  else
    SetVolumeF(Round(Value * 65535 / 100));
end;

function TdbpTrackbarVolume.GetVolumeF(Value: Integer): Integer;
begin
  Result:= Round(Value / Max * 100);
  FPourcent:= Result;
end;

function TdbpTrackbarVolume.GetVolumeM(Value: Integer): Integer;
begin
  Result:= Round(Value / 65535 * Max);
end;

procedure TdbpTrackbarVolume.SetPrecision(Value: TPrecision);
var OldPourcent, RealPos: Integer;
begin
  if Value<>FPrecision then
  begin
    if Orientation=trVertical then
         Realpos:= Max - Position
    else Realpos:= Position;
    FPrecision:= Value;
    OldPourcent:= GetVolumeF(RealPos);
    case FPrecision of
      prGrande :     FMax:= 65535;
      prNormale :    FMax:= 100;
      prPetite :     FMax:= 10;
      prTresPetite : FMax:= 4;
      pzPerso:       FMax:= Max;
    end;
  Max:= FMax;
  SetVolumePourcent(OldPourcent, False);
  end;
end;

procedure TdbpTrackbarVolume.ProcOnCheckboxMute(Sender: TObject);
begin
  if Assigned(FOldOnClickMute) then
    FOldOnClickMute(Sender);
  SetVolumeMute(FCheckboxMute.Checked);
end;

procedure TdbpTrackbarVolume.SetCheckboxMute(Value: TCheckbox);
begin
  if (Value<>FCheckboxMute) then
    FCheckboxMute:= Value;
  if Assigned(FCheckboxMute) then
  begin
    FCheckboxMute.Checked:= FMute;
    FOldOnClickMute:= FCheckboxMute.OnClick;
    FCheckboxMute.OnClick:= ProcOnCheckboxMute;
  end
  else
    FCheckboxMute.OnClick:= nil;
end;

procedure TdbpTrackbarVolume.SetLabel(Value: TLabel);
begin
  if (Value<>FLabel) then
    FLabel:= Value;
  if Assigned(FLabel) then
     FLabel.Caption:= IntToStr(100 - GetVolumeF(Position))+' %';
end;

function TdbpTrackbarVolume.GetDescription: string;
begin
  Result:= FDesc;
end;

procedure TdbpTrackbarVolume.SetMlct(Value: TMixerLineComponentType);
begin
  if Value<>FMlct then
  begin
    FMlct:= Value;
    FDesc:= tsDescriptions.Strings[Ord(FMlct)];
  end;
end;

procedure TdbpTrackbarVolume.SetSilence(Value: Boolean);
var RealPos: Integer;
begin
  if Value<>FSilence then
  begin
    if Orientation=trVertical then
    begin
      Realpos:= Max - Position;
      if Value then
           Position:= Max - Round(Realpos / 2)
      else Position:= Max - Realpos * 2;
    end
    else
    begin
      if Value then
           Position:= Round(Realpos / 2)
      else Position:= Realpos * 2;
    end;
  FSilence:= Value;
  end;
end;

end.
