{%MainUnit gtkproc.pp}{%MainUnit gtkint.pp}
{ $Id$ }

{******************************************************************************
  Centralized includefile for some common gtk defines
 ******************************************************************************}


// TODO: Test on all platforms
{$IFNDEF DisableAsyncProcess}
  {$IFDEF Linux}
    {$IFDEF CPUI386}
      {off $DEFINE UseAsyncProcess}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{off $DEFINE GDK_ERROR_TRAP_FLUSH}

{$DEFINE REPORT_GDK_ERRORS}

{off $DEFINE VerboseAccelerator}

{off $define VerboseModifiermap}

{off $DEFINE VerboseTimer}

{off $DEFINE VerboseMouseBugfix}

{off $DEFINE RaiseExceptionOnNilPointers}

{off $Define DisableCriticalSections}

{off $Define Disable_GC_SysColors}

{$define HideKeyTableWarnings}

{$define RawimageConsistencyChecks}

(*
 Gtk1 uses a GTK_MODULES environment variable that causes it to load modules
 at startup, however this variable is also used by Gtk2 and Gtk3, meaning
 that if a referenced module is not part of the available Gtk1 modules the
 program will display a warning at startup time.  Since as of 2023 pretty much
 no distribution comes with Gtk1 this is always a bogus warning and to avoid
 this, the GTK_MODULES environment variable will be cleaned during startup and
 reset after the toolkit has been initialized to allow for Gtk2 and later child
 processes.
*)
{$define ClearGtkModulesEnvVar}

(*
 keep track of keystates instead of using OS
 This is the old mode and might be removed
*)
{$DEFINE Use_KeyStateList}

(*
 Since some platforms (Darwin) can have X but also have a native gtk
 implementation, the following defines are used

 HasX -> X can be used for accessing functions not implented in gtk/gdk
         (this does not mean that gdkx functions can be used)
 HasGdk2X -> gdk2x can be used (gdk2x is defined for fpc 2.1+)
 UseX -> Use the X version of gtk instead of a native version
*)

{off $define UseX}

{$ifdef Unix}
  {$ifdef Gtk1}
    {$define HasX}
  {$else}
    // on darwin we try to use native gtk
    {$ifdef Darwin}
      {$ifdef UseX} // it can be overridden
        {$info Compiling with gtk2 for X}
        {$define HasX}
      {$else}
        {$IFDEF VerboseGtkToDos}{$note On darwin the native gtk2 widgetset is used. }{$ENDIF}
        {$IFDEF VerboseGtkToDos}{$note If you want to use gtk2 for X, define UseX }{$ENDIF}
      {$endif}
    {$else}
      {$define HasX}
    {$endif}
    {$if defined(HasX)}
      {$define HasGdk2X}
    {$endif}
  {$endif}
{$else}
  {$ifdef Gtk1}
    // not supported
    {$fatal X is required for GTK1}
  {$endif}
  {$define GTK_2_10}
{$endif}

{$ifdef HasX}
  (*
   GTK or GNOME has problems reporting ssAlt and ssAltGr when different
   keyboardlayouts are used. With UseOwnShiftState we keep track of the shiftate
   ourself
  *)
  {$define UseOwnShiftState}
{$endif}

{$IFDEF Gtk2}
// see http://bugs.freepascal.org/view.php?id=12145. 
// Turn it off if something happens.
{$DEFINE EnabledGtkThreading}
{$define GTK_2_8}
{$ENDIF}
