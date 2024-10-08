unit FpDbgCommon;

{$mode objfpc}{$H+}
{$IFDEF INLINE_OFF}{$INLINE OFF}{$ENDIF}

interface

uses Classes;

type
// Target information, could be different from host debugger
  TMachineType = (mtNone, mtSPARC, mt386, mt68K, mtPPC, mtPPC64, mtARM, mtARM64,
                  mtOLD_ALPHA, mtIA_64, mtX86_64, mtAVR8, mtALPHA,
                  mtMIPS, mtMIPSEL,mtLA64, mtXTENSA, mtRISCV);
  TBitness = (bNone, b32, b64);
  TByteOrder = (boNone, boLSB, boMSB);
  TOperatingSystem = (osNone, osBSD, osDarwin, osEmbedded, osLinux, osUnix, osMac, osWindows);

  TTargetDescriptor = record
    machineType: TMachineType;
    bitness: TBitness;
    byteOrder: TByteOrder;
    OS: TOperatingSystem;
  end;

// This function returns the host descriptor
// Use when target information not yet loaded - assumes that debug target is the same as host
function hostDescriptor: TTargetDescriptor;

function TargetFormatDescriptor(const aTargetDescriptor: TTargetDescriptor): String;

function dbgs(AMachineType: TMachineType): String; overload;
function dbgs(ABitness: TBitness): String; overload;
function dbgs(AByteOrder: TByteOrder): String; overload;
function dbgs(AOperatingSystem: TOperatingSystem): String; overload;

{$IFDEF FPDEBUG_THREAD_CHECK}
procedure AssertFpDebugThreadId(const AName: String);
procedure AssertFpDebugThreadIdNotMain(const AName: String);
procedure SetCurrentFpDebugThreadIdForAssert(AnId: TThreadID);
procedure ClearCurrentFpDebugThreadIdForAssert;
property CurrentFpDebugThreadIdForAssert: TThreadID write SetCurrentFpDebugThreadIdForAssert;
{$ENDIF}

implementation

function hostDescriptor: TTargetDescriptor;
begin
  with Result do
  begin
    // TODO: Expand list when debugger support updated for other targets
    machineType := {$if defined(CPU386) or defined(CPUI386)} mt386
                   {$elseif defined(CPUX86_64) or defined(CPUAMD64) or defined(CPUX64)} mtX86_64
                   {$elseif defined(CPUAARCH64)} mtARM64
                   {$elseif defined(CPUARM)} mtARM
                   {$elseif defined(CPUPOWERPC)} mtPPC
                   {$elseif defined(CPUMIPS)} mtMIPS
                   {$elseif defined(CPUMIPSEL)} mtMIPSEL
                   {$elseif defined(CPU68K)} mt68K
                   {$elseif defined(CPULOONGARCH64)} mtLA64
                   {$else} mtNone
                   {$endif};
    bitness     := {$if defined(CPU64)} b64 {$elseif defined(CPU32)} b32 {$else} bNone {$endif};

    byteorder   := {$ifdef ENDIAN_LITTLE} boLSB {$else} boMSB {$endif};

    OS          := {$if defined(DARWIN)} osDarwin
                   {$elseif defined(EMBEDDED)} osEmbedded
                   {$elseif defined(LINUX)} osLinux
                   {$elseif defined(BSD)} osBSD
                   {$elseif defined(UNIX)} osUnix
                   {$elseif defined(MSWINDOWS)} osWindows {$endif};
  end;
end;

function TargetFormatDescriptor(const aTargetDescriptor: TTargetDescriptor): String;
const
  machineNames: array[TMachineType] of string = (
    'none', 'sparc', 'i386', 'm68K', 'ppc', 'ppc64', 'arm', 'aarch64',
    'old-alpha', 'ia_64', 'x86_64', 'avr', 'alpha',
    'mips', 'mipsel', 'loongarch64', 'xtensa', 'riscv');
  OSname: array[TOperatingSystem] of string = (
    'none', 'bsd', 'darwin', 'embedded', 'linux', 'unix', 'mac', 'win');
begin
  Result := machineNames[aTargetDescriptor.machineType] + '-' +
            OSname[aTargetDescriptor.OS];
  if aTargetDescriptor.OS = osWindows then
    case aTargetDescriptor.bitness of
      b32: Result := Result + '32';
      b64: Result := Result + '64';
    end;
end;

function dbgs(AMachineType: TMachineType): String;
begin
  writestr(Result{%H-}, AMachineType);
end;

function dbgs(ABitness: TBitness): String;
begin
  writestr(Result{%H-}, ABitness);
end;

function dbgs(AByteOrder: TByteOrder): String;
begin
  writestr(Result{%H-}, AByteOrder);
end;

function dbgs(AOperatingSystem: TOperatingSystem): String;
begin
  writestr(Result{%H-}, AOperatingSystem);
end;

{$IFDEF FPDEBUG_THREAD_CHECK}
var
  FCurrentFpDebugThreadIdForAssert: TThreadID;
  FCurrentFpDebugThreadIdValidForAssert: Boolean;

procedure AssertFpDebugThreadId(const AName: String);
begin
{$IFnDEF LINUX}
  if FCurrentFpDebugThreadIdValidForAssert then
    assert(GetCurrentThreadId = FCurrentFpDebugThreadIdForAssert, AName);
{$ENDIF}
end;

procedure AssertFpDebugThreadIdNotMain(const AName: String);
begin
  AssertFpDebugThreadId(AName);
  assert(GetCurrentThreadId<>MainThreadID, AName + ' runnig outside main thread');
end;

procedure SetCurrentFpDebugThreadIdForAssert(AnId: TThreadID);
begin
  FCurrentFpDebugThreadIdForAssert := AnId;
  FCurrentFpDebugThreadIdValidForAssert := True;
end;

procedure ClearCurrentFpDebugThreadIdForAssert;
begin
  FCurrentFpDebugThreadIdValidForAssert := False;
end;

{$ENDIF}

end.

