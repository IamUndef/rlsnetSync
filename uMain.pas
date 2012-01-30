unit uMain;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, OleCtrls, ComCtrls, uLinksTable;

type
  TMainForm = class(TForm)
    bStart: TButton;
    gbLog: TGroupBox;
    mLog: TMemo;
    gbDBConnect: TGroupBox;
    editDB: TEdit;
    editUser: TEdit;
    editPassword: TEdit;
    lbDB: TLabel;
    lbComment: TLabel;
    lbUser: TLabel;
    lbPassword: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bStartClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
    Catalog_ : TLinksTable;
    Results_ : TStringList;
    TotalCount_ : Integer;
    LatinCount_ : Integer;
    WriteCount_ : Integer;
    EndedThreadCount_ : Integer;

    procedure Start();
    procedure RunCatalogProcess();
    procedure ThreadWrite( Sender : TObject; Data : TStringList;
      var WriteCount : Integer );
    procedure ThreadLogging( Sender : TObject; TotalCount : Integer;
      LatinCount : Integer; WriteCount : Integer );
    procedure ThreadTerminate( Sender : TObject );

  public
    { Public declarations }
    
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses  IB_Components, IB_Constants, uMainDM, uDownloader, uCatalogProcess;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Results_ := TStringList.Create();
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ( mrNo = MessageDlg( 'Вы действительно хотите выйти?',  mtConfirmation,
      [mbYes, mbNo], 0 ) ) then
    Action := caNone
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned( Results_ ) then
    Results_.Clear();
  if Assigned( Catalog_ ) then
    Catalog_.Free();
end;

procedure TMainForm.bStartClick(Sender: TObject);
begin
  if not MainDM.IBC.Connected then
  begin
    try
      MainDM.IBC.Database := editDB.Text;
      MainDM.IBC.Username := editUser.Text;
      MainDM.IBC.Password := editPassword.Text;
      MainDM.IBC.Connect;
    except
      on E : Exception do
      begin
        MessageDlg(Format ( 'Ошибка: %s', [E.Message] ), mtError, [mbOK], 0 );
        Exit;
      end;
    end;
    editDB.Enabled := false;
    editUser.Enabled := false;
    editPassword.Enabled := false;
    bStart.Caption := 'Загрузить';
    MessageDlg( 'База данных подключена!', mtInformation, [mbOk], 0 );
  end else
    Start();
end;

procedure TMainForm.Start();
const
  THREAD_COUNT = 10;
  RSLNET_CATALOG_URL = TCatalogProcess.RSLNET_URL + 'tn_alf.htm';
var
  i : Integer;
begin
  Results_.Clear();
  if Assigned( Catalog_ ) then
    FreeAndNil( Catalog_ );
  Catalog_ := TLinksTable.Create( TDownloader.Get( RSLNET_CATALOG_URL ).body,
    'look_pads mini' );
  bStart.Enabled := false;
  TotalCount_ := 0;
  LatinCount_ := 0;
  WriteCount_ := 0;
  EndedThreadCount_ := 0;
  i := 0;
  repeat
    Inc( i );
    RunCatalogProcess();
  until  not ( ( i <= THREAD_COUNT ) and Catalog_.Next() );
end;

procedure TMainForm.RunCatalogProcess();
var
  Thread : TCatalogProcess;
begin
  try
    Thread := TCatalogProcess.Create( Catalog_.Url[TCatalogProcess.RSLNET_URL] );
    Thread.Tag := Catalog_.Index;
    Thread.FreeOnTerminate := true;
    Thread.OnWrite := ThreadWrite;
    Thread.OnLogging := ThreadLogging;
    Thread.OnTerminate := ThreadTerminate;
    Thread.Resume();
  except
    MessageDlg( 'Критическая ошибка! Приложение будет закрыто!',
      mtError, [mbOk], 0 );
    Application.Terminate();
    raise;
  end;
end;

procedure TMainForm.ThreadWrite( Sender : TObject; Data : TStringList;
  var WriteCount : Integer );
var
  i : Integer;
begin
  i := 0;
  while ( i < Data.Count ) do
  begin
    MainDM.DrugQ.ParamByName( 'LSNAME' ).AsString := Data[i];
    MainDM.DrugQ.Open;
    if MainDM.DrugQ.IsEmpty then
    begin
      MainDM.DrugQ.Insert();
      try
        MainDM.DrugQ.FieldByName( 'LSNAME' ).AsString := Data[i];
        MainDM.DrugQ.FieldByName( 'LSLATINNAME' ).AsString := Data[i + 1];
        MainDM.DrugQ.Post;
        Inc( WriteCount );
      except
        MainDM.DrugQ.Cancel();
        raise;
      end;
    end;
    Inc( i, 2 );
  end;
end;

procedure TMainForm.ThreadLogging( Sender : TObject; TotalCount : Integer;
  LatinCount : Integer; WriteCount : Integer );
var
  i : Integer;
  ErrorCount : Integer;
  SuccesCount : Integer;
begin
  Inc( TotalCount_, TotalCount );
  Inc( LatinCount_, LatinCount );
  Inc( WriteCount_, WriteCount );
  mLog.Lines.BeginUpdate();
  try
    mLog.Clear();
    ErrorCount := 0;
    SuccesCount := 0;
    for i := 0 to Results_.Count - 1 do
    begin
      mLog.Lines.Add( Results_[i] );
      if Assigned( Results_.Objects[i] ) then
        Inc( ErrorCount )
      else
        Inc( SuccesCount );
    end;
    mLog.Lines.Add( '' );
    mLog.Lines.Add( Format( '%s : %d из %d', ['Закончено разделов',
      EndedThreadCount_, Catalog_.Count] ) );
    mLog.Lines.Add( Format( '    %s : %d ', ['успешно', SuccesCount] ) );
    mLog.Lines.Add( Format( '    %s : %d ', ['с ошибкой', ErrorCount] ) );
    mLog.Lines.Add( '' );
    mLog.Lines.Add( Format( '%s : %d',
      ['Получено наименований', TotalCount_] ) );
    mLog.Lines.Add( Format( '    %s : %d',
      ['с латинским наименованием', LatinCount_] ) );
    mLog.Lines.Add( Format( '%s : %d',
      ['Записано наименований', WriteCount_] ) );
  finally
    mLog.Lines.EndUpdate();
    mLog.Perform( EM_SCROLLCARET, 0, 0 );
  end;
end;

procedure TMainForm.ThreadTerminate( Sender: TObject );
var
  Thread : TCatalogProcess;
begin
  Inc( EndedThreadCount_ );
  Thread := Sender as TCatalogProcess;
  if Assigned( Thread.FatalException ) then
    Results_.AddObject(
      Format( 'Раздел %s : Ошибка - %s',
        [Catalog_.TextOfIndex[Thread.Tag],
        ( Thread.FatalException as Exception ).Message] ),
      TObject( true ) )
  else
    Results_.Add( Format( 'Раздел %s : Завершено',
      [Catalog_.TextOfIndex[Thread.Tag]] ) );
  Thread.OnLogging( Thread, 0, 0, 0 );
  if ( EndedThreadCount_ = Catalog_.Count ) then
  begin
    bStart.Enabled := true;
    MessageDlg( 'Загрузка данных закончена!', mtInformation, [mbOk], 0 );
  end else
  if Catalog_.Next() then
    RunCatalogProcess();
end;

end.
