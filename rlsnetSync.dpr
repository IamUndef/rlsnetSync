program rlsnetSync;

uses
  Forms,
  uMain in 'uMain.pas' {MainForm},
  uMainDM in 'uMainDM.pas' {MainDM: TDataModule},
  uLinksTable in 'uLinksTable.pas',
  uDownloader in 'uDownloader.pas',
  uLatinName in 'uLatinName.pas',
  uCatalogProcess in 'uCatalogProcess.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TMainDM, MainDM);
  Application.Run;
end.
