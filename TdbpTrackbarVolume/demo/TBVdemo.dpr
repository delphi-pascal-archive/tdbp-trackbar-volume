program TBVdemo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {FormDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormDemo, FormDemo);
  Application.Run;
end.
