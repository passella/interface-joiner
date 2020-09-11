**

## Interface Joiner

**

Class responsible for joining several interfaces in a single object / interface.

**Example of use**


Interface declaration:

       IMyInterface1 = interface(IInvokable)
          ['{6A6CB426-9921-4B9C-9EB0-EDDE613FA6D7}']
          procedure DoMethod;
       end;
    
       IMyInterface2 = interface(IInvokable)
          ['{FC96C2FD-9B22-47E5-AE29-B3066ECBB12E}']
          procedure DoMethod;
       end;

   
   

    procedure DoMethod(const intF: IInvokable);
    begin
       if Supports(intF, IMyInterface1) then
          (intF as IMyInterface1).DoMethod;
    
       if Supports(intF, IMyInterface2) then
          (intF as IMyInterface2).DoMethod;
    end;

    procedure btnTestClick(Sender: TObject);
    begin
       DoMethod(TInterfaceJoinerFactory
          .CreateJoinerBuilder()
          .Join<IMyInterface1>(TMyInterface1Imp.Create)
          .Join<IMyInterface2>(TMyInterface2Imp.Create)
          .Build());
    end;
