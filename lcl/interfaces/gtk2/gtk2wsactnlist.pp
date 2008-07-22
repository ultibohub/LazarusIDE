{ $Id$}
{
 *****************************************************************************
 *                             Gtk2WSActnList.pp                             * 
 *                             -----------------                             * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,        *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit Gtk2WSActnList;

{$mode objfpc}{$H+}

interface

uses
////////////////////////////////////////////////////
// I M P O R T A N T                                
////////////////////////////////////////////////////
// To get as little as posible circles,
// uncomment only when needed for registration
////////////////////////////////////////////////////
//  ActnList,
////////////////////////////////////////////////////
  WSActnList, WSLCLClasses;

type

  { TGtk2WSCustomActionList }

  TGtk2WSCustomActionList = class(TWSCustomActionList)
  private
  protected
  public
  end;

  { TGtk2WSActionList }

  TGtk2WSActionList = class(TWSActionList)
  private
  protected
  public
  end;


implementation

initialization

////////////////////////////////////////////////////
// I M P O R T A N T
////////////////////////////////////////////////////
// To improve speed, register only classes
// which actually implement something
////////////////////////////////////////////////////
//  RegisterWSComponent(TCustomActionList, TGtk2WSCustomActionList);
//  RegisterWSComponent(TActionList, TGtk2WSActionList);
////////////////////////////////////////////////////
end.