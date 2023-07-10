
program DrvRubej;

{%ToDo 'DrvRubej.todo'}

uses
  Forms,
  cMainKsb in '..\..\1\Ksb\CMAINKSB.pas' {aMainKsb},
  connection in '..\..\1\Ksb\connection.pas',
  SharedBuffer in '..\..\1\Ksb\SharedBuffer.pas',
  NetService in '..\..\1\Ksb\NetService.pas',
  cAppKsb in '..\..\1\Ksb\cAppKsb.pas',
  R8Unit in 'R8Unit.pas',
  R8OnRecive in 'R8OnRecive.pas',
  cRights in '..\..\1\Ksb\cRights.pas',
  cBuilderAppKsb in '..\..\1\Ksb\cBuilderAppKsb.pas',
  mMain in 'mMain.pas' {aMain},
  Comm in 'Comm.pas',
  KSBParam in 'KSBParam.pas',
  SCUunit in 'SCUunit.pas',
  constants in 'constants.pas',
  mCheckZoneOperation in 'mCheckZoneOperation.pas',
  mBCPConf in 'mBCPConf.pas' {BCPConf},
  mCheckDrv in 'mCheckDrv.pas';

{$R *.RES}

begin
 Application.Initialize;
 Application.CreateForm(TaMain, aMain);
  Application.Run;
end.
