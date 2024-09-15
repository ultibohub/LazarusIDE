{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

 Abstract:
   Interface for the package IdeDebugger
}
unit IdeDebuggerValueFormatterIntf;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses fgl, SysUtils, IdeDebuggerWatchValueIntf,
  DbgIntfDebuggerBase, Laz2_XMLCfg;

type

  ILazDbgIdeValueFormatterConfigStorageIntf = interface ['{FCB5F11D-47EF-4701-AEE2-7E22A2B2601C}']
    procedure LoadDataFromXMLConfig(const AConfig: TRttiXMLConfig; const APath: string);
    procedure SaveDataToXMLConfig(const AConfig: TRttiXMLConfig; const APath: string);
  end;

  TLazDbgIdeValFormatterFeature = (
    vffFormatValue,     // FormatValue() for IWatchResultDataIntf
    vffFormatOldValue,  //   Deprecated: FormatValue() for older backends TDBGType
    vffValueData,       // Normal data
    vffValueMemDump,    // MemDump (Experimental)

    vffPreventOrigValue, // Does not support having the orig value shown with the translated result
    vffSkipOnRecursion   // The formatter may match during printing the value => skip it in this case
  );
  TLazDbgIdeValFormatterFeatures = set of TLazDbgIdeValFormatterFeature;

  ILazDbgIdeValueFormatterIntf = interface
    ['{AE8A0E22-E052-4C77-AD88-8812D27F3180}']
    function FormatValue(AWatchValue: IWatchResultDataIntf;
                         const ADisplayFormat: TWatchDisplayFormat;
                         AWatchResultPrinter: IWatchResultPrinter;
                         out APrintedValue: String
                        ): Boolean;

    function FormatValue(aDBGType: TDBGType;
                         aValue: string;
                         const ADisplayFormat: TWatchDisplayFormat;
                         out APrintedValue: String
                        ): boolean; experimental; deprecated 'For values from older backends only - to be removed as backends are upgraded';

    function SupportedFeatures: TLazDbgIdeValFormatterFeatures;
    function SupportedDataKinds: TWatchResultDataKinds;

    // Config
    function  GetObject: TObject;  // for TXmlConfig.WriteObject / must have all config in published fields
    function  GetDefaultsObject: TObject;  // for TXmlConfig.WriteObject / all published fields with DEFAULT values
    function CreateCopy: ILazDbgIdeValueFormatterIntf;
    procedure Free;
    function GetInterface(const iidstr : shortstring;out obj) : boolean; // provided by TObject
  end;

  (* ILazDbgIdeValueFormatterSettingsFrameIntf
     interface that must be implemented by the TFrame class returned by GetSettingsFrameClass
  *)

  ILazDbgIdeValueFormatterSettingsFrameIntf = interface
    ['{83CDB4A1-6B32-44F0-B225-7F591AE06497}']
    procedure ReadFrom(AFormatter: ILazDbgIdeValueFormatterIntf);
    function  WriteTo(AFormatter: ILazDbgIdeValueFormatterIntf): Boolean;
  end;

  (* TLazDbgIdeValueFormatterRegistryEntry
     Class of a value formatter.
     The user can create any amount of configurable formatters from this.
  *)

  TLazDbgIdeValueFormatterRegistryEntry = class
  public
    class function CreateValueFormatter: ILazDbgIdeValueFormatterIntf; virtual; abstract;
    class function GetSettingsFrameClass: TClass; virtual; // class(TFrame, ILazDbgIdeValueFormatterSettingsFrameIntf)
    class function GetDisplayName: String; virtual; abstract;
    class function GetClassName: String; virtual; abstract; // Used in XmlConfig
  end;
  TLazDbgIdeValueFormatterRegistryEntryClass = class of TLazDbgIdeValueFormatterRegistryEntry;

  (* TLazDbgIdeValueFormatterRegistry
     List of create-able value formatter classes.
  *)

  TLazDbgIdeValueFormatterRegistry = class(specialize TFPGList<TLazDbgIdeValueFormatterRegistryEntryClass>)
  public
    function FindByFormatterClassName(AName: String): TLazDbgIdeValueFormatterRegistryEntryClass;
  end;

  { TLazDbgIdeValueFormatterGeneric }

  generic TLazDbgIdeValueFormatterGeneric<_BASE: TObject> = class(_BASE, ILazDbgIdeValueFormatterIntf)
  private type
    TLazDbgIdeValueFormatterGenericClass = class of TLazDbgIdeValueFormatterGeneric;
  protected
    function GetNewInstance: TLazDbgIdeValueFormatterGeneric; virtual;
    procedure Init; virtual;
    function GetObject: TObject; virtual;
    function GetDefaultsObject: TObject; virtual;
    function CreateCopy: ILazDbgIdeValueFormatterIntf;
    procedure Assign(AnOther: TObject); virtual;
    procedure DoFree; virtual;
    procedure ILazDbgIdeValueFormatterIntf.Free = DoFree;
  public
    constructor Create; // inherited Create may not be called => use init
    function FormatValue(AWatchValue: IWatchResultDataIntf;
                         const ADisplayFormat: TWatchDisplayFormat;
                         AWatchResultPrinter: IWatchResultPrinter;
                         out APrintedValue: String
                        ): Boolean; virtual;

    function FormatValue(aDBGType: TDBGType;
                         aValue: string;
                         const ADisplayFormat: TWatchDisplayFormat;
                         out APrintedValue: String
                        ): boolean; virtual; experimental; deprecated 'For values from older backends only - to be removed as backends are upgraded';

    function SupportedFeatures: TLazDbgIdeValFormatterFeatures; virtual;
    function SupportedDataKinds: TWatchResultDataKinds; virtual;
  end;

  { TLazDbgIdeValueFormatterRegistryEntryGeneric }

  generic TLazDbgIdeValueFormatterRegistryEntryGeneric<_Formatter> = class(TLazDbgIdeValueFormatterRegistryEntry)
  public
    class function CreateValueFormatter: ILazDbgIdeValueFormatterIntf; override;
    class function GetClassName: String; override;
    class function GetDisplayName: String; override; // calls GetRegisteredDisplayName on the _Formatter
  end;

  { TLazDbgIdeValueFormatterFrameRegistryEntryGeneric }

  generic TLazDbgIdeValueFormatterFrameRegistryEntryGeneric<_Formatter, _Frame> = class(specialize TLazDbgIdeValueFormatterRegistryEntryGeneric<_Formatter>)
    class function GetSettingsFrameClass: TClass; override;
  end;


function ValueFormatterRegistry: TLazDbgIdeValueFormatterRegistry;

implementation

var
  TheValueFormatterRegistry: TLazDbgIdeValueFormatterRegistry;

function ValueFormatterRegistry: TLazDbgIdeValueFormatterRegistry;
begin
  if TheValueFormatterRegistry = nil then
    TheValueFormatterRegistry := TLazDbgIdeValueFormatterRegistry.Create;
  Result := TheValueFormatterRegistry;
end;

{ TLazDbgIdeValueFormatterRegistryEntry }

class function TLazDbgIdeValueFormatterRegistryEntry.GetSettingsFrameClass: TClass;
begin
  Result := nil;
end;

{ TLazDbgIdeValueFormatterRegistry }

function TLazDbgIdeValueFormatterRegistry.FindByFormatterClassName(AName: String
  ): TLazDbgIdeValueFormatterRegistryEntryClass;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if Items[i].GetClassName = AName then
      exit(Items[i]);
end;

{ TLazDbgIdeValueFormatterGeneric }

function TLazDbgIdeValueFormatterGeneric.GetNewInstance: TLazDbgIdeValueFormatterGeneric;
begin
  Result := TLazDbgIdeValueFormatterGenericClass(ClassType).Create;
end;

procedure TLazDbgIdeValueFormatterGeneric.Init;
begin
  //
end;

function TLazDbgIdeValueFormatterGeneric.GetObject: TObject;
begin
  Result := Self;
end;

function TLazDbgIdeValueFormatterGeneric.GetDefaultsObject: TObject;
begin
  Result := GetNewInstance;
end;

procedure TLazDbgIdeValueFormatterGeneric.Assign(AnOther: TObject);
begin
  //
end;

function TLazDbgIdeValueFormatterGeneric.CreateCopy: ILazDbgIdeValueFormatterIntf;
var
  r: TLazDbgIdeValueFormatterGeneric;
begin
  r := GetNewInstance;
  r.Assign(Self);
  Result := r;
end;

procedure TLazDbgIdeValueFormatterGeneric.DoFree;
begin
  Destroy;
end;

constructor TLazDbgIdeValueFormatterGeneric.Create;
begin
  Init;
end;

function TLazDbgIdeValueFormatterGeneric.FormatValue(
  AWatchValue: IWatchResultDataIntf; const ADisplayFormat: TWatchDisplayFormat;
  AWatchResultPrinter: IWatchResultPrinter; out APrintedValue: String): Boolean;
begin
  Result := False;
end;

function TLazDbgIdeValueFormatterGeneric.FormatValue(aDBGType: TDBGType;
  aValue: string; const ADisplayFormat: TWatchDisplayFormat; out APrintedValue: String
  ): boolean;
begin
  Result := False;
end;

function TLazDbgIdeValueFormatterGeneric.SupportedFeatures: TLazDbgIdeValFormatterFeatures;
begin
  Result := [vffValueData];
end;

function TLazDbgIdeValueFormatterGeneric.SupportedDataKinds: TWatchResultDataKinds;
begin
  Result := [low(TWatchResultDataKind)..high(TWatchResultDataKind)];
end;

{ TLazDbgIdeValueFormatterRegistryEntryGeneric }

class function TLazDbgIdeValueFormatterRegistryEntryGeneric.CreateValueFormatter: ILazDbgIdeValueFormatterIntf;
begin
  Result := _Formatter.Create;
end;

class function TLazDbgIdeValueFormatterRegistryEntryGeneric.GetClassName: String;
begin
  Result := _Formatter.ClassName;
end;

class function TLazDbgIdeValueFormatterRegistryEntryGeneric.GetDisplayName: String;
begin
  Result := _Formatter.GetRegisteredDisplayName;
end;

{ TLazDbgIdeValueFormatterFrameRegistryEntryGeneric }

class function TLazDbgIdeValueFormatterFrameRegistryEntryGeneric.GetSettingsFrameClass: TClass;
begin
  Result := _Frame;
end;


finalization
  FreeAndNil(TheValueFormatterRegistry);
end.

