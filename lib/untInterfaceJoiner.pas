unit untInterfaceJoiner;

interface

uses
   System.Rtti, System.TypInfo, System.Generics.Collections;

type
   TInterfaceJoinerBuilder = class;

   TInterfaceJoinerFactory = class
   public
      class function CreateJoinerBuilder(): TInterfaceJoinerBuilder;
   end;

   TInterfaceJoinerBuilder = class
   private
      lstIntF: TList<TPair<IInvokable, PTypeInfo>>;
   public
      constructor Create();
      destructor Destroy; override;
      function Join<I: IInvokable>(const intF: I): TInterfaceJoinerBuilder;
      function Build(): IInvokable;
   end;

implementation

uses
  System.SysUtils;


type
   TVirtualInterfaceJoiner = class(TVirtualInterface, IInvokable)
   private
      builder: TInterfaceJoinerBuilder;
      dicMap: TDictionary<TGUID, IInvokable>;
   public
      constructor Create(const builder: TInterfaceJoinerBuilder);
      destructor Destroy; override;
      function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
   end;

{ TInterfaceJoinerFactory }

class function TInterfaceJoinerFactory.CreateJoinerBuilder: TInterfaceJoinerBuilder;
begin
   Result := TInterfaceJoinerBuilder.Create;
end;

{ TInterfaceJoinerBuilder }

function TInterfaceJoinerBuilder.Build: IInvokable;
begin
   Result := TVirtualInterfaceJoiner.Create(Self);
end;

constructor TInterfaceJoinerBuilder.Create;
begin
   inherited Create();
   lstIntF := TList<TPair<IInvokable, PTypeInfo>>.Create;
end;

destructor TInterfaceJoinerBuilder.Destroy;
begin
   if Assigned(lstIntF) then FreeAndNil(lstIntF);
   inherited Destroy;
end;

function TInterfaceJoinerBuilder.Join<I>(
  const intF: I): TInterfaceJoinerBuilder;
begin
   Result := Self;
   lstIntF.Add(TPair<IInvokable,PTypeInfo>.Create(intF, TypeInfo(I)));
end;

{ TVirtualInterfaceJoiner }

constructor TVirtualInterfaceJoiner.Create(
  const builder: TInterfaceJoinerBuilder);
begin
   inherited Create(builder.lstIntF[0].Value);
   Self.builder := builder;
   Self.dicMap := TDictionary<TGUID, IInvokable>.Create;

   for var i := 0 to builder.lstIntF.Count - 1 do
   begin
      dicMap.AddOrSetValue(GetTypeData(builder.lstIntF[i].Value)^.GUID, builder.lstIntF[i].Key);
   end;

   Self.OnInvoke := procedure(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue)
      begin
         Result := Method.Invoke(TValue.From(dicMap[Args[0].TypeData^.GUID]), Copy(Args, 1, Length(Args) - 1));
      end;
end;

destructor TVirtualInterfaceJoiner.Destroy;
begin
   if Assigned(builder) then FreeAndNil(builder);
   if Assigned(dicMap) then FreeAndNil(dicMap);
   inherited Destroy;
end;

function TVirtualInterfaceJoiner.QueryInterface(const IID: TGUID;
  out Obj): HRESULT;
begin
   Result := inherited QueryInterface(IID, Obj);
   if Result = S_OK then
      Exit;

   var intF: IInvokable := nil;
   if dicMap.TryGetValue(IID, intF) then
      Result := intF.QueryInterface(IID, Obj);

   if Result = S_OK then
      Exit;

   if Result <> S_OK then
   begin
      for var i := 0 to builder.lstIntF.Count - 1 do
      begin
         Result := builder.lstIntF[i].Key.QueryInterface(IID, Obj);
         if Result = S_OK then
            Exit;
      end;
   end;
end;

end.

