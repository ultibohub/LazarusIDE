unit FpWatchResultData;

{$mode objfpc}{$H+}
{$IFDEF INLINE_OFF}{$INLINE OFF}{$ENDIF}

interface

uses
  // DbgIntf
  LazDebuggerIntfFloatTypes, DbgIntfBaseTypes, LazDebuggerIntf,
  //
  FpDbgInfo, FpPascalBuilder, FpdMemoryTools, FpErrorMessages, FpDbgDwarf,
  FpDbgDwarfDataClasses, LazClasses, {$ifdef FORCE_LAZLOGGER_DUMMY} LazLoggerDummy {$else} LazLoggerBase {$endif}, fgl, Math,
  SysUtils;

type

  TDbgPtrList = specialize TFPGList<TDBGPtr>;

  { TFpWatchResultConvertor }

  TFpWatchResultConvertor = class
  private const
    MAX_RECURSE_LVL = 10;
    MAX_RECURSE_LVL_ARRAY = 5;
    MAX_RECURSE_LVL_PTR = 8; // max depth for a chain of pointers starting at the initial value
  private
    FContext: TFpDbgLocationContext;
    FExtraDepth: Boolean;
    FFirstIndexOffs: Integer;
    FRecurseCnt, FRecurseCntLow,
    FRecursePointerCnt,
    FRecurseInstanceCnt, FRecurseDynArray, FRecurseArray: integer;
    FRecurseAddrList: TDbgPtrList;
    FLastValueKind: TDbgSymbolKind;
    FHasEmbeddedPointer: Boolean;
    FOuterArrayIdx, FTotalArrayCnt: integer;
    FRepeatCount: Integer;
    FArrayTypeDone: Boolean;
    FEncounteredError: Boolean;
  protected
    function CheckError(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): boolean;

    procedure AddTypeNameToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf; ADeref: Boolean = False);

    function TypeToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function PointerToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;
    function NumToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function CharToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;
    function StringToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;
    function WideStringToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function BoolToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;
    function EnumToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;
    function SetToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function FloatToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function ArrayToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function StructToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function ProcToResData(AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf): Boolean;

    function DoValueToResData(AnFpValue: TFpValue;
                              AnResData: IDbgWatchDataIntf
                             ): Boolean; virtual;
    function DoWriteWatchResultData(AnFpValue: TFpValue;
                                  AnResData: IDbgWatchDataIntf
                                 ): Boolean;
    function DoWritePointerWatchResultData(AnFpValue: TFpValue;
                                  AnResData: IDbgWatchDataIntf;
                                  AnAddr: TDbgPtr
                                 ): Boolean;

    property RecurseCnt: Integer read FRecurseCnt;
    property RecurseCntLow: Integer read FRecurseCntLow;
  public
    constructor Create(AContext: TFpDbgLocationContext);
    destructor Destroy; override;

    function WriteWatchResultData(AnFpValue: TFpValue;
                                  AnResData: IDbgWatchDataIntf;
                                  ARepeatCount: Integer = 0
                                 ): Boolean;
    function WriteWatchResultMemDump(AnFpValue: TFpValue;
                                  AnResData: IDbgWatchDataIntf;
                                  ARepeatCount: Integer = 0
                                 ): Boolean;

    property Context: TFpDbgLocationContext read FContext write FContext;
    property ExtraDepth: Boolean read FExtraDepth write FExtraDepth;
    property FirstIndexOffs: Integer read FFirstIndexOffs write FFirstIndexOffs;
    //property RepeatCount: Integer read FRepeatCount write SetRepeatCount;
  end;



implementation

{ TFpWatchResultConvertor }

function TFpWatchResultConvertor.CheckError(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): boolean;
begin
  Result := AnFpValue = nil;
  if Result then
    exit;
  Result := IsError(AnFpValue.LastError);
  if Result then begin
    FEncounteredError := True;
    if AnResData <> nil then
      AnResData.CreateError(ErrorHandler.ErrorAsString(AnFpValue.LastError));
    AnFpValue.ResetError;
  end;
end;

procedure TFpWatchResultConvertor.AddTypeNameToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf; ADeref: Boolean);
var
  t: TFpSymbol;
  TpName: String;
begin
  if FArrayTypeDone then
    exit;
  t := AnFpValue.TypeInfo;
  if ADeref and (t <> nil) then
    t := t.TypeInfo;
  if (t <> nil) and
     GetTypeName(TpName, t, [tnfNoSubstitute]) and
     (TpName <> '')
  then
    AnResData.SetTypeName(TpName);
end;

function TFpWatchResultConvertor.TypeToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
var
  APrintedValue: String;
begin
  if GetTypeAsDeclaration(APrintedValue, AnFpValue.DbgSymbol) then
    AnResData.CreatePrePrinted('type '+APrintedValue)
  else
    AnResData.CreateError('Unknown type');
  Result := True;
end;

function TFpWatchResultConvertor.PointerToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
var
  DerefRes: IDbgWatchDataIntf;
  DerefVal: TFpValue;
  addr: QWord;
begin
  Result := True;
  addr := AnFpValue.AsCardinal;
  AnResData.CreatePointerValue(addr);
  AddTypeNameToResData(AnFpValue, AnResData);

  if CheckError(AnFpValue, AnResData) then
    exit;

  if addr = 0 then
    exit;

  if svfString in AnFpValue.FieldFlags then begin
    // PChar: Get zero-terminated string, rather than just one single char
    DerefRes := AnResData.SetDerefData;
    if DerefRes <> nil then begin
      DerefRes.CreateString(AnFpValue.AsString);
      AddTypeNameToResData(AnFpValue, DerefRes, True);
      CheckError(AnFpValue, DerefRes);
    end;
  end
  else
  if svfWideString in AnFpValue.FieldFlags then begin
    // PWideChar: Get zero-terminated string, rather than just one single char
    DerefRes := AnResData.SetDerefData;
    if DerefRes <> nil then begin
      DerefRes.CreateWideString(AnFpValue.AsWideString);
      AddTypeNameToResData(AnFpValue, DerefRes, True);
      CheckError(AnFpValue, DerefRes);
    end;
  end
  else begin
    DerefVal := AnFpValue.Member[0];
    if IsError(AnFpValue.LastError) then begin
      CheckError(AnFpValue, AnResData.SetDerefData);
    end
    else
    if (DerefVal <> nil) then begin
      DerefRes := nil;
      if (DerefVal.Kind in [skString, skAnsiString, skChar, skWideString,
          skInteger, skCardinal, skBoolean, skFloat, skCurrency, skEnum, skSet])
      then begin
        (* (Nested) Pointer to
           - Pascal-String type
           - Any basic type (any type that has no reference or internal pointer)
             (skChar should not happen: Should be PChar above)
           - Any other
        *)
        DerefRes := AnResData.SetDerefData;
        if DerefRes <> nil then begin
          // In case of nested pointer MAX_RECURSE_LVL may already be reached. Make an exception here, to allow one more.
          dec(FRecurseCnt);
          DoWritePointerWatchResultData(DerefVal, DerefRes, addr);
          inc(FRecurseCnt);
        end;
      end
      else
      if (DerefVal.Kind =skPointer) and (svfString in DerefVal.FieldFlags) then begin
        DerefRes := AnResData.SetDerefData;
        if DerefRes <> nil then begin
          DerefRes.CreateString(DerefVal.AsString);
          AddTypeNameToResData(DerefVal, DerefRes, True);
        end;
      end
      else
      if (DerefVal.Kind =skPointer) and (svfWideString in DerefVal.FieldFlags) then begin
        DerefRes := AnResData.SetDerefData;
        if DerefRes <> nil then begin
          DerefRes.CreateWideString(DerefVal.AsString);
          AddTypeNameToResData(DerefVal, DerefRes, True);
        end;
      end
      else begin
        DerefRes := AnResData.SetDerefData;
        if DerefRes <> nil then
          DoWritePointerWatchResultData(DerefVal, DerefRes, addr);
      end;

      CheckError(DerefVal, DerefRes);
      DerefVal.ReleaseReference;
    end;
  end;
end;

function TFpWatchResultConvertor.NumToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
begin
  Result := True;
  if AnFpValue.Kind = skCardinal then
    AnResData.CreateNumValue(AnFpValue.AsCardinal, False, SizeToFullBytes(AnFpValue.DataSize))
  else
    AnResData.CreateNumValue(QWord(AnFpValue.AsInteger), True, SizeToFullBytes(AnFpValue.DataSize));
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.CharToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
begin
  Result := True;
  AnResData.CreateCharValue(AnFpValue.AsCardinal, SizeToFullBytes(AnFpValue.DataSize));
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.StringToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
begin
  Result := True;
  AnResData.CreateString(AnFpValue.AsString);
  if svfDataAddress in AnFpValue.FieldFlags then
    AnResData.SetDataAddress(AnFpValue.DataAddress.Address);
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.WideStringToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
begin
  Result := True;
  AnResData.CreateWideString(AnFpValue.AsWideString);
  if svfDataAddress in AnFpValue.FieldFlags then
    AnResData.SetDataAddress(AnFpValue.DataAddress.Address);
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.BoolToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
begin
  Result := True;
  AnResData.CreateBoolValue(AnFpValue.AsCardinal, SizeToFullBytes(AnFpValue.DataSize));
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.EnumToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
var
  ValSize: TFpDbgValueSize;
begin
  Result := True;
  if not( (svfSize in AnFpValue.FieldFlags) and AnFpValue.GetSize(ValSize) ) then
    ValSize := ZeroSize;
  if IsError(AnFpValue.LastError) then
    ValSize := ZeroSize;
  AnFpValue.ResetError;

  AnResData.CreateEnumValue(AnFpValue.AsCardinal, AnFpValue.AsString, SizeToFullBytes(ValSize), AnFpValue.Kind=skEnumValue);
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.SetToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
var
  m: TFpValue;
  Names: array of String;
  i: Integer;
begin
  Result := True;
  SetLength(Names, AnFpValue.MemberCount);
  for i := 0 to AnFpValue.MemberCount-1 do begin
    m := AnFpValue.Member[i];
    if svfIdentifier in m.FieldFlags then
      Names[i] := m.AsString
    else
    if svfOrdinal in m.FieldFlags then // set of byte
      Names[i] := IntToStr(m.AsCardinal)
    else
      Names[i] := '';
    m.ReleaseReference;
  end;
  AnResData.CreateSetValue(Names);
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.FloatToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
begin
  Result := True;
  case AnFpValue.FloatPrecission of
    fpSingle:   AnResData.CreateFloatValue(AnFpValue.AsSingle);
    fpDouble:   AnResData.CreateFloatValue(AnFpValue.AsDouble);
    fpExtended: AnResData.CreateFloatValue(AnFpValue.AsExtended);
  end;
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.ArrayToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
const
  MAX_TOTAL_ARRAY_CNT = 5000;
  MAX_TOTAL_ARRAY_CNT_EXTRA_DEPTH = 3500; // reset
var
  Cnt, i, CurRecurseDynArray, OuterIdx, CacheCnt: Integer;
  LowBnd, StartIdx, CacheMax, CacheSize, j: Int64;
  Addr: TDBGPtr;
  ti: TFpSymbol;
  EntryRes: IDbgWatchDataIntf;
  MemberValue, TmpVal: TFpValue;
  Cache: TFpDbgMemCacheBase;
  Dummy: QWord;
  MLoc: TFpDbgMemLocation;
  ForceVariant: Boolean;
begin
  Result := True;

  Cnt := AnFpValue.MemberCount;
  if CheckError(AnFpValue, AnResData) then begin
    AddTypeNameToResData(AnFpValue, AnResData);
    exit;
  end;
  CurRecurseDynArray := FRecurseDynArray;
  OuterIdx := FOuterArrayIdx;

  if (AnFpValue.IndexTypeCount = 0) or (not AnFpValue.IndexType[0].GetValueLowBound(AnFpValue, LowBnd)) then
    LowBnd := 0;

  Addr := 0;
  ti := AnFpValue.TypeInfo;
  if (ti = nil) or (ti.Flags * [sfDynArray, sfStatArray] = []) then begin
    EntryRes := AnResData.CreateArrayValue(datUnknown, Cnt, LowBnd);
  end
  else
  if (sfDynArray in ti.Flags) and (LowBnd = 0) then begin // LowBnd = 0 => there is some bug, reporting some dyn arrays as stat.
    EntryRes := AnResData.CreateArrayValue(datDynArray, Cnt, 0);
    if AnFpValue.FieldFlags * [svfInteger, svfCardinal] <> [] then
      Addr := AnFpValue.AsCardinal
    else
    if svfDataAddress in AnFpValue.FieldFlags then
      Addr := AnFpValue.DataAddress.Address;
    AnResData.SetDataAddress(Addr);

    if FRecurseCnt >= 0 then
      inc(FRecurseDynArray);
  end
  else begin
    EntryRes := AnResData.CreateArrayValue(datStatArray, Cnt, LowBnd);
  end;

  AddTypeNameToResData(AnFpValue, AnResData);

  inc(FRecurseArray);
  Cache := nil;
  try
    if (Cnt <= 0) or
       (FHasEmbeddedPointer) or
       (FRecurseCnt > MAX_RECURSE_LVL_ARRAY) or
       ( (FRecurseCnt > 0) and (FTotalArrayCnt > MAX_TOTAL_ARRAY_CNT) )
    then
      exit;

    StartIdx := 0;
    If (FOuterArrayIdx < 0) and (FRecurseCnt = FRecurseCntLow) then
      StartIdx := FFirstIndexOffs;
    Cnt := max(1, Cnt - StartIdx);

    if (Context.MemManager.MemLimits.MaxArrayLen > 0) and (Cnt > Context.MemManager.MemLimits.MaxArrayLen) then
      Cnt := Context.MemManager.MemLimits.MaxArrayLen;

    If (FOuterArrayIdx < 0) and (FRecurseCnt = FRecurseCntLow) and (FRepeatCount > 0) then Cnt := FRepeatCount
    else if (FRecurseCnt > 1) and (FOuterArrayIdx >  10) and (Cnt >   10) then Cnt := 10
    else if (FRecurseCnt > 1) and (FOuterArrayIdx >   1) and (Cnt >   20) then Cnt := 20
    else if (FRecurseCnt > 0) and (FOuterArrayIdx > 100) and (Cnt >   10) then Cnt := 10
    else if (FRecurseCnt > 0) and (FOuterArrayIdx >   1) and (Cnt >   50) then Cnt := 50;

    /////////////////////
    // Bound types ??

    CacheMax  := StartIdx;
    CacheSize := 0;
    CacheCnt  := 200;
    //if (ti = nil) or (ti.Flags * [sfDynArray, sfStatArray] = []) then
    if (ti = nil) then
      MemberValue := nil  // could be mapped array slice, with non consecutive entries
    else
      MemberValue := AnFpValue.Member[StartIdx+LowBnd]; // // TODO : CheckError // ClearError for AnFpValue
    if (MemberValue = nil) or (not IsTargetNotNil(MemberValue.Address)) or
       (Context.MemManager.CacheManager = nil)
    then begin
      CacheMax := StartIdx + Cnt; // no caching possible
    end
    else begin
      repeat
        TmpVal := AnFpValue.Member[StartIdx + Min(CacheCnt, Cnt) + LowBnd]; // // TODO : CheckError // ClearError for AnFpValue
        if (TmpVal <> nil) and IsTargetNotNil(TmpVal.Address) then begin
          {$PUSH}{$R-}{$Q-}
          CacheSize := TmpVal.Address.Address - MemberValue.Address.Address;
          TmpVal.ReleaseReference;
          {$POP}
          if CacheSize > Context.MemManager.MemLimits.MaxMemReadSize then begin
            CacheSize := 0;
            CacheCnt := CacheCnt div 2;
            if CacheCnt <= 1 then
              break;
            continue;
          end;
        end;
        break;
      until false;
      if CacheSize = 0 then
        CacheMax := StartIdx + Cnt; // no caching possible
    end;
    MemberValue.ReleaseReference;

    ForceVariant := vfArrayOfVariant in AnFpValue.Flags;

    inc(FTotalArrayCnt, Cnt);
    for i := StartIdx to StartIdx + Cnt - 1 do begin
      if (FRecurseCnt < 0) and (FTotalArrayCnt > MAX_TOTAL_ARRAY_CNT_EXTRA_DEPTH) then
        FTotalArrayCnt := MAX_TOTAL_ARRAY_CNT_EXTRA_DEPTH;
      if i > FOuterArrayIdx then
        FOuterArrayIdx := i;

      MemberValue := AnFpValue.Member[i+LowBnd]; // // TODO : CheckError // ClearError for AnFpValue
      if (i >= CacheMax) and (CacheSize > 0) and (MemberValue <> nil) then begin
        if Cache <> nil then
          Context.MemManager.CacheManager.RemoveCache(Cache);
        Cache := nil;

        if IsTargetNotNil(MemberValue.Address) then begin
          CacheMax := Min(i + CacheCnt, StartIdx + Cnt);
          if (CacheMax > i + 1) then begin
            j := CacheMax - i;
            if j < CacheCnt then
              CacheSize := (CacheSize div CacheCnt) * j + j div 2;

            if CacheSize > 0 then
              Cache := Context.MemManager.CacheManager.AddCache(MemberValue.Address.Address, CacheSize)
          end;
        end
        else
          CacheMax := StartIdx + Cnt; // no caching possible
      end;

      EntryRes := AnResData.SetNextArrayData;
      if MemberValue = nil then begin
        EntryRes.CreateError('Error: Could not get member');
      end
      else begin
        if ForceVariant and not (vfVariant in MemberValue.Flags) then // vfVariant => variant will be created
          EntryRes := EntryRes.CreateVariantValue;
        DoWritePointerWatchResultData(MemberValue, EntryRes, Addr);
      end;

      if (i = StartIdx) and (MemberValue <> nil) and FEncounteredError and
         (ti <> nil) and (ti.Flags * [sfDynArray, sfStatArray] <> [])
      then begin
        FEncounteredError := False;
        MLoc := MemberValue.Address;
        if IsValidLoc(MLoc) then
          Context.ReadMemory(MLoc, SizeVal(1), @Dummy);
        if ( IsError(Context.LastMemError) or (not IsValidLoc(MLoc)) ) and
           (MLoc <> AnFpValue.DataAddress) and (IsValidLoc(AnFpValue.DataAddress))
        then
          Context.ReadMemory(AnFpValue.DataAddress, SizeVal(1), @Dummy);
        if IsError(Context.LastMemError) then begin
          // array is in unreadable memory
          AnResData.CreateError(ErrorHandler.ErrorAsString(Context.LastMemError));
          MemberValue.ReleaseReference;
          exit;
        end;
      end;

      MemberValue.ReleaseReference;
      if FRecurseArray = 1 then
        FArrayTypeDone := True;
    end;
    DebugLn(IsError(AnFpValue.LastError), ['!!! ArrayToResData() unexpected error in array value', ErrorHandler.ErrorAsString(AnFpValue.LastError)]);
    AnFpValue.ResetError;

  finally
    if FRecurseArray = 1 then
      FArrayTypeDone := False;
    FRecurseDynArray := CurRecurseDynArray;
    FOuterArrayIdx := OuterIdx;
    dec(FRecurseArray);
    if Cache <> nil then
      Context.MemManager.CacheManager.RemoveCache(Cache);
  end
end;

function TFpWatchResultConvertor.StructToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;

  procedure AddVariantMembers(VariantPart: TFpValue; ResAnch: IDbgWatchDataIntf);
  var
    VariantContainer, VMember: TFpValue;
    i, j, CurRecurseArray: Integer;
    ResField, ResList: IDbgWatchDataIntf;
    discr: QWord;
    hasDiscr, FoundDiscr, UseDefault, CurArrayTypeDone: Boolean;
    MBVis: TLzDbgFieldVisibility;
    n: String;
  begin
    VariantContainer := VariantPart.Member[-1];
    if VariantContainer = nil then
      exit;

    CurRecurseArray := FRecurseArray;
    CurArrayTypeDone := FArrayTypeDone;
    FArrayTypeDone := False;
    FRecurseArray := 0; // Allow an inside array to optimize
    try

    ResList := ResAnch.AddField('', dfvUnknown, [dffVariant]);
    ResList.CreateArrayValue(datUnknown);

    hasDiscr := (VariantContainer <> nil) and
      (VariantContainer.FieldFlags * [svfInteger, svfCardinal, svfOrdinal] <> []);
    if hasDiscr then begin
      discr := VariantContainer.AsCardinal;

      n := '';
      MBVis := dfvUnknown;
      if (VariantContainer.DbgSymbol <> nil) then begin
        n := VariantContainer.DbgSymbol.Name;
        case VariantContainer.DbgSymbol.MemberVisibility of
          svPrivate:   MBVis := dfvPrivate;
          svProtected: MBVis := dfvProtected;
          svPublic:    MBVis := dfvPublic;
          else         MBVis := dfvUnknown;
        end;
      end;

      if n <> '' then begin
        ResField := ResList.SetNextArrayData;
        ResField := ResField.CreateVariantValue(n, MBVis);
        if not DoWritePointerWatchResultData(VariantContainer, ResField, 0) then // addr
          ResField.CreateError('Unknown');
      end;
    end;
    VariantContainer.ReleaseReference;

    FoundDiscr := False;
    For UseDefault := (not hasDiscr) to True do begin
      for i := 0 to VariantPart.MemberCount - 1 do begin
        VariantContainer := VariantPart.Member[i];
        if (VariantContainer.DbgSymbol <> nil) and
           (VariantContainer.DbgSymbol is TFpSymbolDwarfTypeVariant) and
           ( ( (not UseDefault) and
               (TFpSymbolDwarfTypeVariant(VariantContainer.DbgSymbol).MatchesDiscr(discr))
             ) or
             ( (UseDefault) and
               (TFpSymbolDwarfTypeVariant(VariantContainer.DbgSymbol).IsDefaultDiscr)
             )
           )
        then begin
          FoundDiscr := True;
          for j := 0 to VariantContainer.MemberCount - 1 do begin
            VMember := VariantContainer.Member[j];
            n := '';
            MBVis := dfvUnknown;
            if (VMember.DbgSymbol <> nil) then begin
              n := VMember.DbgSymbol.Name;
              case VariantContainer.DbgSymbol.MemberVisibility of
                svPrivate:   MBVis := dfvPrivate;
                svProtected: MBVis := dfvProtected;
                svPublic:    MBVis := dfvPublic;
                else         MBVis := dfvUnknown;
              end;
            end;

// TODO visibility
            ResField := ResList.SetNextArrayData;
            ResField := ResField.CreateVariantValue(n, MBVis);
            if not DoWritePointerWatchResultData(VMember, ResField, 0) then // addr
              ResField.CreateError('Unknown');
            VMember.ReleaseReference;
          end;
        end;

        VariantContainer.ReleaseReference;
      end;
      if FoundDiscr then
        break;
    end;
    finally
      FRecurseArray := CurRecurseArray;
      FArrayTypeDone := CurArrayTypeDone;
    end;
  end;

type
  TAnchestorMap = specialize TFPGMap<PtrUInt, IDbgWatchDataIntf>;
var
  vt: TLzDbgStructType;
  Cache: TFpDbgMemCacheBase;
  AnchestorMap: TAnchestorMap;
  i, j, WasRecurseInstanceCnt: Integer;
  MemberValue: TFpValue;
  ti, sym: TFpSymbol;
  ResAnch, ResField, TopAnch, UnkAnch: IDbgWatchDataIntf;
  MbName: String;
  MBVis: TLzDbgFieldVisibility;
  Addr: TDBGPtr;
  Dummy: QWord;
  MLoc: TFpDbgMemLocation;
begin
  Result := True;

  case AnFpValue.Kind of
    skRecord:    vt := dstRecord;
    skObject:    vt := dstObject;
    skClass:     vt := dstClass;
    skInterface: vt := dstInterface;
    else         vt := dstUnknown;
  end;

  if not Context.MemManager.CheckDataSize(SizeToFullBytes(AnFpValue.DataSize)) then begin
    AnResData.CreateError(ErrorHandler.ErrorAsString(Context.LastMemError));
    exit;
  end;

  Addr := 0;
  if (AnFpValue.Kind in [skClass, skInterface]) then begin
    if AnFpValue.FieldFlags * [svfInteger, svfCardinal, svfOrdinal] <> [] then
      Addr := AnFpValue.AsCardinal
    else
    if svfDataAddress in AnFpValue.FieldFlags then
      Addr := AnFpValue.DataAddress.Address;
  end;

  AnResData.CreateStructure(vt, Addr);
  AddTypeNameToResData(AnFpValue, AnResData);

  if (AnFpValue.Kind in [skClass, skInterface]) and
     ( (Addr = 0) or
       (FRecurseInstanceCnt >= 1) or (FRecurseDynArray >= 2)
     )
  then
    exit;
  if FHasEmbeddedPointer then
    exit;

  if Context.MemManager.CacheManager <> nil then
    Cache := Context.MemManager.CacheManager.AddCache(AnFpValue.DataAddress.Address, SizeToFullBytes(AnFpValue.DataSize))
  else
    Cache := nil;

  AnchestorMap := TAnchestorMap.Create;
  WasRecurseInstanceCnt := FRecurseInstanceCnt;
  if (AnFpValue.Kind in [skClass, skInterface]) and (FRecurseCnt >= 0) then
    inc(FRecurseInstanceCnt);
  try
    TopAnch := AnResData;
    UnkAnch := nil;
    ti := AnFpValue.TypeInfo;
    if ti <> nil then
      ti := ti.InternalTypeInfo;

    if ti <> nil then begin
      AnchestorMap.Add(PtrUInt(ti), AnResData);

      if (AnFpValue.Kind in [skObject, skClass, skInterface]) then begin
        ti := ti.TypeInfo;
        ResAnch := AnResData;
        while ti <> nil do begin
          ResAnch := ResAnch.SetAnchestor(ti.Name);
          AnchestorMap.Add(PtrUInt(ti), ResAnch);
          ti := ti.TypeInfo;
        end;
        TopAnch := ResAnch;
      end;
    end;

    for i := 0 to AnFpValue.MemberCount-1 do begin
      MemberValue := AnFpValue.Member[i];
      if (MemberValue = nil) or (MemberValue.Kind in [skProcedure, skFunction]) then begin
        MemberValue.ReleaseReference;
        (* Has Field
           - $vmt => Constructor or Destructor
           - $vmt_aftercontstruction_local => Constructor
        *)
        continue;
      end;

      ResAnch := nil;
      ti := MemberValue.ParentTypeInfo; // TODO: variant returens nil, membervalue.sturcturevalue.parenttypesymbol
      if ti <> nil then
        ti := ti.InternalTypeInfo;
      j := AnchestorMap.IndexOf(PtrUInt(ti));
      if j >= 0 then begin
        ResAnch := AnchestorMap.Data[j];
      end
      else
      if UnkAnch <> nil then begin
        ResAnch := UnkAnch;
      end
      else begin
        UnkAnch := TopAnch.SetAnchestor('');
        ResAnch := UnkAnch;
      end;

      if MemberValue.Kind = skVariantPart then begin
        AddVariantMembers(MemberValue, ResAnch);
        MemberValue.ReleaseReference;
        continue;
      end;

      sym := MemberValue.DbgSymbol;
      MbName := MemberValue.Name;
      if sym <> nil then begin
        case sym.MemberVisibility of
          svPrivate:   MBVis := dfvPrivate;
          svProtected: MBVis := dfvProtected;
          svPublic:    MBVis := dfvPublic;
          else         MBVis := dfvUnknown;
        end;
      end
      else begin
        MBVis := dfvUnknown;
      end;

      ResField := ResAnch.AddField(MbName, MBVis, []);
      if not DoWritePointerWatchResultData(MemberValue, ResField, Addr) then
        ResField.CreateError('Unknown');

      if (i = 0) and (MemberValue <> nil) and FEncounteredError then begin
        MLoc := MemberValue.Address;
        if IsValidLoc(MLoc) then
          Context.ReadMemory(MemberValue.Address, SizeVal(1), @Dummy);
        if ( IsError(Context.LastMemError) or (not IsValidLoc(MLoc)) ) and
           (MLoc <> AnFpValue.DataAddress) and (IsValidLoc(AnFpValue.DataAddress))
        then
          Context.ReadMemory(AnFpValue.DataAddress, SizeVal(1), @Dummy);
        if IsError(Context.LastMemError) then begin
          // struct is in unreadable memory
          AnResData.CreateError(ErrorHandler.ErrorAsString(Context.LastMemError));
          MemberValue.ReleaseReference;
          exit;
        end;
      end;

      MemberValue.ReleaseReference;
    end;
  finally
    FRecurseInstanceCnt := WasRecurseInstanceCnt;
    AnchestorMap.Free;
    if Cache <> nil then
      Context.MemManager.CacheManager.RemoveCache(Cache)
  end;
end;

function TFpWatchResultConvertor.ProcToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
var
  addr: TDBGPtr;
  s, LocName: String;
  t, sym: TFpSymbol;
  proc: TFpSymbolDwarf;
  par: TFpValueDwarf;
begin
  Result := True;
  addr := AnFpValue.DataAddress.Address;

  LocName := '';
  if AnFpValue.Kind in [skFunctionRef, skProcedureRef] then begin
    t := AnFpValue.TypeInfo;
    sym := AnFpValue.DbgSymbol;
    proc := nil;
    if (sym <> nil) and (sym is TFpSymbolDwarfDataProc) then
      proc := TFpSymbolDwarf(sym)
    else
    if t <> nil then
      proc := TFpSymbolDwarf(TDbgDwarfSymbolBase(t).CompilationUnit.Owner.FindProcSymbol(addr));

    if proc <> nil then begin
      LocName := proc.Name;
      if (proc is TFpSymbolDwarfDataProc) then begin
        par := TFpSymbolDwarfDataProc(proc).GetSelfParameter; // Has no Context set, but we only need TypeInfo.Name
        if (par <> nil) and (par.TypeInfo <> nil) then
          LocName := par.TypeInfo.Name + '.' + LocName;
        par.ReleaseReference;
      end;
      ReleaseRefAndNil(proc);
    end;
  end
  else
    t := AnFpValue.DbgSymbol;

  GetTypeAsDeclaration(s, t);

  case AnFpValue.Kind of
    skProcedure:    AnResData.CreateProcedure(addr, False, LocName, s);
    skFunction:     AnResData.CreateProcedure(addr, True, LocName, s);
    skProcedureRef: AnResData.CreateProcedureRef(addr, False, LocName, s);
    skFunctionRef:  AnResData.CreateProcedureRef(addr, True, LocName, s);
  end;
  AddTypeNameToResData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.DoValueToResData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
var
  PrettyPrinter: TFpPascalPrettyPrinter;
  s: String;
begin
  Result := False;
  FEncounteredError := False;
  case AnFpValue.Kind of
    skPointer:  Result := PointerToResData(AnFpValue, AnResData);
    skInteger,
    skCardinal: Result := NumToResData(AnFpValue, AnResData);
    skFloat:    Result := FloatToResData(AnFpValue, AnResData);

    skChar:       Result := CharToResData(AnFpValue, AnResData);
    skString,
    skAnsiString: Result := StringToResData(AnFpValue, AnResData);
    skWideString: Result := WideStringToResData(AnFpValue, AnResData);

    skRecord,
    skObject,
    skClass,
    skInterface: Result := StructToResData(AnFpValue, AnResData);

    //skNone: ;
    //skInstance: ;
    skUnit: begin
        AnResData.CreatePrePrinted('Unit: '+AnFpValue.DbgSymbol.Name);
        Result := True;
      end;
    skType: Result := TypeToResData(AnFpValue, AnResData);
    skProcedure,
    skFunction,
    skProcedureRef,
    skFunctionRef: Result := ProcToResData(AnFpValue, AnResData);
    skSimple: ;
    skBoolean:   Result := BoolToResData(AnFpValue, AnResData);
    skCurrency: ;
    skVariant: ;
    skEnum,
    skEnumValue: Result := EnumToResData(AnFpValue, AnResData);
    skSet:       Result := SetToResData(AnFpValue, AnResData);
    skArray:     Result := ArrayToResData(AnFpValue, AnResData);
    //skRegister: ;
    //skAddress: ;
    else begin
        if not IsError(AnFpValue.LastError) then  // will be handled after the case
          AnResData.CreateError('Unknown data');
        Result := True;
      end;
  end;
  if Result then
    CheckError(AnFpValue, AnResData)
  else
  if FRecurseCnt > 0 then begin
    PrettyPrinter := TFpPascalPrettyPrinter.Create(Context.SizeOfAddress);
    PrettyPrinter.Context := Context;
    PrettyPrinter.PrintValue(s, AnFpValue, ddfDefault, 1, [], [ppvSkipClassBody]);
    AnResData.CreatePrePrinted(s);
    PrettyPrinter.Free;
    Result := True;
  end;

end;

function TFpWatchResultConvertor.DoWriteWatchResultData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf): Boolean;
var
  DidHaveEmbeddedPointer: Boolean;
begin
  // FRecurseCnt should be handled by the caller
  Result := (FRecurseCnt > MAX_RECURSE_LVL) or (AnFpValue = nil);
  if Result then
    exit;

  Result := False;

  DidHaveEmbeddedPointer := FHasEmbeddedPointer;
  if (FRecurseCnt <= 0) and
     ( (FLastValueKind = skPointer) or (FRecurseCnt=-1) ) and
     (AnFpValue.Kind = skPointer) and
     (FRecursePointerCnt < MAX_RECURSE_LVL_PTR)
  then begin
    inc(FRecursePointerCnt);
  end
  else begin
    inc(FRecurseCnt);
    if (AnFpValue.Kind = skPointer) then
      FHasEmbeddedPointer := True
    else
    if FHasEmbeddedPointer and (FLastValueKind <> skPointer) then // TODO: create a value as marker // also arrays cannot store the absence of a value
      exit(True); // not an error
      // Allow only one level, after an embedded pointer (pointer nested in other data-type)
  end;
  FLastValueKind := AnFpValue.Kind;
  try
    if vfVariant in AnFpValue.Flags then
      AnResData := AnResData.CreateVariantValue;

    Result := DoValueToResData(AnFpValue, AnResData);
  finally
    if FRecursePointerCnt > 0 then
      dec(FRecursePointerCnt)
    else
      dec(FRecurseCnt);
    FHasEmbeddedPointer := DidHaveEmbeddedPointer;
  end;
end;

function TFpWatchResultConvertor.DoWritePointerWatchResultData(
  AnFpValue: TFpValue; AnResData: IDbgWatchDataIntf; AnAddr: TDbgPtr
  ): Boolean;
begin
  if FRecurseAddrList.IndexOf(AnAddr) >= 0 then begin
    AnResData.CreateError('Recursive Value at '+HexStr(AnAddr, 16)); // TOOD: correct size // TODO: dedicated entry
    exit(True);
  end;
  if AnAddr <> 0 then
    FRecurseAddrList.Add(AnAddr);
  Result := DoWriteWatchResultData(AnFpValue, AnResData);
  if AnAddr <> 0 then
    FRecurseAddrList.Remove(AnAddr);
end;

constructor TFpWatchResultConvertor.Create(AContext: TFpDbgLocationContext);
begin
  inherited Create;
  FRecurseAddrList := TDbgPtrList.Create;
  FContext := AContext;
end;

destructor TFpWatchResultConvertor.Destroy;
begin
  inherited Destroy;
  FRecurseAddrList.Free;
end;

function TFpWatchResultConvertor.WriteWatchResultData(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf; ARepeatCount: Integer): Boolean;
begin
  Result := False;
  if AnResData = nil then
    exit;
  if AnFpValue = nil then begin
    AnResData.CreateError('No Data');
    exit;
  end;
  if CheckError(AnFpValue, AnResData) then begin
    Result := True;
    exit;
  end;

  FRecurseAddrList.Clear;
  FRepeatCount := ARepeatCount;
  FRecurseCnt         := -1;
  if FExtraDepth then
    FRecurseCnt         := -2;
  FRecurseInstanceCnt :=  0;
  FRecurseDynArray    :=  0;
  FRecurseArray       := 0;
  FRecursePointerCnt := 0;
  FRecurseCntLow := FRecurseCnt+1;
  FOuterArrayIdx := -1;
  FTotalArrayCnt :=  0;
  FArrayTypeDone := False;

  FLastValueKind := AnFpValue.Kind;
  FHasEmbeddedPointer := False;
  Result := DoWriteWatchResultData(AnFpValue, AnResData);
end;

function TFpWatchResultConvertor.WriteWatchResultMemDump(AnFpValue: TFpValue;
  AnResData: IDbgWatchDataIntf; ARepeatCount: Integer): Boolean;
var
  MemAddr: TFpDbgMemLocation;
  MemSize: Integer;
  ValSize: TFpDbgValueSize;
  MemDest: RawByteString;
begin
  Result := True;

  MemAddr := UnInitializedLoc;
  if svfDataAddress in AnFpValue.FieldFlags then begin
    MemAddr := AnFpValue.DataAddress;
    MemSize := SizeToFullBytes(AnFpValue.DataSize);
  end
  else
  if svfAddress in AnFpValue.FieldFlags then begin
    MemAddr := AnFpValue.Address;
    if not AnFpValue.GetSize(ValSize) then
      ValSize := SizeVal(256);
    MemSize := SizeToFullBytes(ValSize);
  end
  else if AnFpValue is TFpValueConstNumber then begin
    MemAddr := TargetLoc(AnFpValue.AsCardinal);
    MemSize := 256;
  end;
  if MemSize < ARepeatCount then MemSize := ARepeatCount;
  if MemSize <= 0 then MemSize := 256;

  if not IsTargetAddr(MemAddr) then begin
    AnResData.CreateError('Value not in memory');
    exit;
  end;

  if not Context.MemManager.SetLength(MemDest, MemSize) then begin
    AnResData.CreateError(ErrorHandler.ErrorAsString(Context.MemManager.LastError));
    exit;
  end;

  if not FContext.ReadMemory(MemAddr, SizeVal(MemSize), @MemDest[1]) then begin
    AnResData.CreateError(ErrorHandler.ErrorAsString(Context.MemManager.LastError));
    exit;
  end;

  AnResData.CreateMemDump(MemDest);
  AnResData.SetDataAddress(MemAddr.Address);
end;

end.

