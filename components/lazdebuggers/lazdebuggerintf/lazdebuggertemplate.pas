{***************************************************************************
 *                                                                         *
 * This unit is distributed under the LGPL version 2                       *
 *                                                                         *
 * Additionally this unit can be used under any newer version (3 or up)    *
 * of the LGPL                                                             *
 *                                                                         *
 * Users are also granted the same "linknig exception" as defined          *
 * for the LCL.                                                            *
 * See the LCL license for details                                         *
 *                                                                         *
 *                                                                         *
 ***************************************************************************
 @author(Martin Friebe)
}
unit LazDebuggerTemplate;

{$mode objfpc}{$H+}
{$INTERFACES CORBA} // no ref counting needed

interface

uses
  Classes, SysUtils, fgl, LazDebuggerIntf;

type

  { TInternalDbgMonitorBase }

  generic TInternalDbgMonitorBase<
    _BASE: TObject;
    _MONITOR_INTF: TInternalDbgMonitorIntfType;
    _SUPPLIER_INTF//: TInternalDbgSupplierIntfType
    >
    = class(_BASE)
  strict private
    FSupplier: _SUPPLIER_INTF;
  private
    procedure SetSupplier(ASupplier: _SUPPLIER_INTF);
    procedure RemoveSupplier(ASupplier: _SUPPLIER_INTF);
  protected
    procedure DoNewSupplier; virtual;

    procedure DoDestroy; // FPC can not compile "destructor Destroy; override;"
  public
    property Supplier: _SUPPLIER_INTF read FSupplier write SetSupplier;
  end;

  { TInternalDbgSupplierBase }

  generic TInternalDbgSupplierBase<
    _BASE: TObject;
    _SUPPLIER_INTF: TInternalDbgSupplierIntfType;
    _MONITOR_INTF //: TInternalDbgMonitorIntfType
    >
    = class(_BASE)
  strict private
    FMonitor: _MONITOR_INTF;
  private
    procedure SetMonitor(AMonitor: _MONITOR_INTF);
  protected
    procedure DoNewMonitor; virtual;

    procedure DoDestroy; // FPC can not compile "destructor Destroy; override;"

    property Monitor: _MONITOR_INTF read FMonitor;
  end;


type

  { TWatchesMonitorClassTemplate }

  generic TWatchesMonitorClassTemplate<_BASE: TObject> = class(
    specialize TInternalDbgMonitorBase<_BASE, TWatchesMonitorIntf, TWatchesSupplierIntf>,
    TWatchesMonitorIntf
  )
  protected
    procedure InvalidateWatchValues; virtual;
    procedure DoStateChange(const AOldState, ANewState: TDBGState); virtual; // deprecated;
  end;

  { TWatchesSupplierClassTemplate }

  generic TWatchesSupplierClassTemplate<_BASE: TObject> = class(
    specialize TInternalDbgSupplierBase<_BASE, TWatchesSupplierIntf, TWatchesMonitorIntf>,
    TWatchesSupplierIntf
  )
  protected
  public
    procedure RequestData(AWatchValue: TWatchValueIntf); virtual;
    procedure TriggerInvalidateWatchValues; virtual;
  end;

implementation

{ TInternalDbgMonitorBase }

procedure TInternalDbgMonitorBase.SetSupplier(ASupplier: _SUPPLIER_INTF);
begin
  if FSupplier = ASupplier then exit;
  assert((FSupplier=nil) or (ASupplier=nil), 'TInternalDbgMonitorBase.SetSupplier: (FSupplier=nil) or (ASupplier=nil)');

  if FSupplier <> nil then FSupplier.SetMonitor(nil);
  FSupplier := ASupplier;
  if FSupplier <> nil then FSupplier.SetMonitor(Self as _MONITOR_INTF);

  DoNewSupplier;
end;

procedure TInternalDbgMonitorBase.RemoveSupplier(ASupplier: _SUPPLIER_INTF);
begin
  if Supplier = ASupplier then
    Supplier := nil;
end;

procedure TInternalDbgMonitorBase.DoNewSupplier;
begin
  //
end;

procedure TInternalDbgMonitorBase.DoDestroy;
begin
  Supplier := nil;
end;

{ TInternalDbgSupplierBase }

procedure TInternalDbgSupplierBase.SetMonitor(AMonitor: _MONITOR_INTF);
begin
  if FMonitor = AMonitor then exit;
  assert((FMonitor=nil) or (AMonitor=nil), 'TInternalDbgSupplierBase.SetMonitor: (FMonitor=nil) or (AMonitor=nil)');
  FMonitor := AMonitor;

  DoNewMonitor;
end;

procedure TInternalDbgSupplierBase.DoNewMonitor;
begin
  //
end;

procedure TInternalDbgSupplierBase.DoDestroy;
begin
  if FMonitor <> nil then
    FMonitor.RemoveSupplier(Self as _SUPPLIER_INTF);
end;

{ TWatchesMonitorClassTemplate }

procedure TWatchesMonitorClassTemplate.InvalidateWatchValues;
begin
  //
end;

procedure TWatchesMonitorClassTemplate.DoStateChange(const AOldState,
  ANewState: TDBGState);
begin
  //
end;

{ TWatchesSupplierClassTemplate }

procedure TWatchesSupplierClassTemplate.RequestData(AWatchValue: TWatchValueIntf);
begin
  AWatchValue.Validity := ddsError;
end;

procedure TWatchesSupplierClassTemplate.TriggerInvalidateWatchValues;
begin
  if (Self <> nil) and (Monitor <> nil) then
    Monitor.InvalidateWatchValues;
end;


end.

