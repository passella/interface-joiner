unit untPrincipal;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
   System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
   Vcl.StdCtrls;

type
   TfrmPrincipal = class(TForm)
      btnTest: TButton;
      procedure btnTestClick(Sender: TObject);
   private
      { Private declarations }
      procedure DoMethod(const intF: IInvokable);
   public
      { Public declarations }
   end;

   IMyInterface1 = interface(IInvokable)
      ['{6A6CB426-9921-4B9C-9EB0-EDDE613FA6D7}']
      procedure DoMethod;
   end;

   IMyInterface2 = interface(IInvokable)
      ['{FC96C2FD-9B22-47E5-AE29-B3066ECBB12E}']
      procedure DoMethod;
   end;

var
   frmPrincipal: TfrmPrincipal;

implementation

uses
  untInterfaceJoiner;

{$R *.dfm}


type
   TMyInterface1Imp = class(TInterfacedObject, IMyInterface1)
   public
      procedure DoMethod;
   end;

   TMyInterface2Imp = class(TInterfacedObject, IMyInterface2)
   public
      procedure DoMethod;
   end;

procedure TfrmPrincipal.btnTestClick(Sender: TObject);
begin
   DoMethod(TInterfaceJoinerFactory
      .CreateJoinerBuilder()
      .Join<IMyInterface1>(TMyInterface1Imp.Create)
      .Join<IMyInterface2>(TMyInterface2Imp.Create)
      .Build());
end;

{ TMyInterface1Imp }

procedure TMyInterface1Imp.DoMethod;
begin
   ShowMessage('procedure TMyInterface1Imp.DoMethod');
end;

{ TMyInterface2Imp }

procedure TMyInterface2Imp.DoMethod;
begin
   ShowMessage('procedure TMyInterface2Imp.DoMethod');
end;

procedure TfrmPrincipal.DoMethod(const intF: IInvokable);
begin
   if Supports(intF, IMyInterface1) then
      (intF as IMyInterface1).DoMethod;

   if Supports(intF, IMyInterface2) then
      (intF as IMyInterface2).DoMethod;
end;

end.
