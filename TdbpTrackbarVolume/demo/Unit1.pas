unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, XPMan, dbpTrackbarVolume, ExtCtrls;

type
  TRangeVal = 2..65535;
  TFormDemo = class(TForm)
    rgVolumes: TRadioGroup;
    gbTBV: TGroupBox;
    dbpTrackbarVolume: TdbpTrackbarVolume;
    lbVolume: TLabel;
    cbMute: TCheckBox;
    cbSilence: TCheckBox;
    XPManifest1: TXPManifest;
    sBar: TStatusBar;
    gbMixers: TGroupBox;
    lbMixers: TListBox;
    cbPrecision: TComboBox;
    lbPrecision: TLabel;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure cbSilenceClick(Sender: TObject);
    procedure lbMixersClick(Sender: TObject);
    procedure dbpTrackbarVolumeChange(Sender: TObject);
    procedure rgVolumesClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure cbPrecisionChange(Sender: TObject);
  private
    procedure SetBarText;
  public
    { Déclarations publiques }
  end;

var
  FormDemo: TFormDemo;

implementation

{$R *.dfm}
procedure TFormDemo.SetBarText;
var STemp: string;
begin
  STemp:= dbpTrackbarVolume.tsDescriptions.Strings[lbMixers.ItemIndex];
  STemp:= UpperCase(STemp[5])+LowerCase(Copy(STemp, Pos('_', STemp)+2, Length(STemp)));
  sBar.Simpletext:= ' ' + STemp +
                    ' : ' + lbVolume.Caption;
  Timer.Enabled:= False;
  Timer.Enabled:= True;
  gbTBV.Caption:= ' ' + STemp + ' : '
end;

procedure TFormDemo.FormCreate(Sender: TObject);
begin
  lbMixers.Items:= dbpTrackbarVolume.tsDescriptions;
  lbMixers.ItemIndex:= 4;
  SetBarText;
  dbpTrackbarVolumeChange(nil);
end;

procedure TFormDemo.cbSilenceClick(Sender: TObject);
begin
  dbpTrackbarVolume.SetSilence(cbSilence.Checked);
end;

procedure TFormDemo.lbMixersClick(Sender: TObject);
begin
  dbpTrackbarVolume.MixerLineType:= TMixerLineComponentType(lbMixers.ItemIndex);
  SetBarText;
end;

procedure TFormDemo.dbpTrackbarVolumeChange(Sender: TObject);
begin
  SetBarText;
  rgVolumes.ItemIndex:= 10 - dbpTrackbarVolume.Pourcent div 10;
end;

procedure TFormDemo.rgVolumesClick(Sender: TObject);
begin
  dbpTrackbarVolume.SetVolumePourcent(rgVolumes.ItemIndex * 10);
end;

procedure TFormDemo.TimerTimer(Sender: TObject);
begin
  sBar.SimpleText:= '';
end;

procedure TFormDemo.cbPrecisionChange(Sender: TObject);
begin
  if cbPrecision.ItemIndex<>4 then
       dbpTrackbarVolume.Precision:= TPrecision(cbPrecision.ItemIndex)
  else
  begin
    dbpTrackbarVolume.Precision:= pzPerso;
    dbpTrackbarVolume.Max:= StrToIntDef(InputBox('Quelle précision ?','Entrez un chiffre entre 1 et 65535', IntToStr(dbpTrackbarVolume.Max)), dbpTrackbarVolume.Max);
  end;
end;

end.
