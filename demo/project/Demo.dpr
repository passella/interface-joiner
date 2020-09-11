program Demo;

uses
  Vcl.Forms,
  untPrincipal in '..\src\untPrincipal.pas' {frmPrincipal},
  untInterfaceJoiner in '..\..\lib\untInterfaceJoiner.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
