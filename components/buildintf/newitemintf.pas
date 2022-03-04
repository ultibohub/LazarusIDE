{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract:
    IDE interface to the items in the new dialog.
}
unit NewItemIntf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  // Flags/Options for the items
  TNewIDEItemFlag = (
    niifCopy,       // default
    niifInherited,
    niifUse
    );
  TNewIDEItemFlags = set of TNewIDEItemFlag;

  // Attributes for the items
  TNewIDEItemAttribute = ( //Ultibo
     niiaIsModule,         // Item is a module
     niiaIsProject,        // Item is a project
     niiaRequireForms      // Item requires form support
    ); //Ultibo
  TNewIDEItemAttributes = set of TNewIDEItemAttribute; //Ultibo

  TNewIDEItemTemplate = class;


  { TNewIDEItemCategory }

  TNewIDEItemCategory = class
  private
    FVisibleInNewDialog: boolean;
  protected
    FName: string;
    FItems: TFPList;
    FIsModule: boolean; //Ultibo
    FIsProject: boolean; //Ultibo
    function GetCount: integer; virtual;
    function GetItems(Index: integer): TNewIDEItemTemplate; virtual;
    procedure InitDefaults;  virtual; //Ultibo
  public
    constructor Create(const AName: string); virtual;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Add(ATemplate: TNewIDEItemTemplate); virtual;
    function LocalizedName: string;  virtual;
    function Description: string;  virtual;
    function IndexOfTemplate(const TemplateName: string): integer; virtual;
    function FindTemplateByName(const TemplateName: string): TNewIDEItemTemplate; virtual;
    function IndexOfCategory(const {%H-}CategoryName: string): integer; virtual;
    function FindCategoryByName(const CategoryName: string): TNewIDEItemCategory; virtual;
  public
    property Count: integer read GetCount;
    property Items[Index: integer]: TNewIDEItemTemplate read GetItems; default;
    property Name: string read FName;
    property IsModule: boolean read FIsModule; //Ultibo
    property IsProject: boolean read FIsProject; //Ultibo
    property VisibleInNewDialog: boolean read FVisibleInNewDialog write FVisibleInNewDialog;
  end;


  { TNewIDEItemCategories }

  TNewIDEItemCategories = class
  protected
    function GetItems(Index: integer): TNewIDEItemCategory; virtual; abstract;
    procedure SetItems(Index: integer; const AValue: TNewIDEItemCategory); virtual; abstract;
  public
    procedure Clear; virtual; abstract;
    procedure Add(ACategory: TNewIDEItemCategory); virtual; abstract;
    function Count: integer; virtual; abstract;
    function IndexOf(const CategoryName: string): integer; virtual; abstract;
    function FindByName(const CategoryName: string): TNewIDEItemCategory; virtual; abstract;
    procedure RegisterItem(const Paths: string; NewItem: TNewIDEItemTemplate); virtual; abstract;
    procedure UnregisterItem(NewItem: TNewIDEItemTemplate); virtual; abstract;
    function FindCategoryByPath(const Path: string;
                                ErrorOnNotFound: boolean): TNewIDEItemCategory; virtual; abstract;
  public
    property Items[Index: integer]: TNewIDEItemCategory
                                          read GetItems write SetItems; default;
  end;

  { TNewIDEItemTemplate }

  TNewIDEItemTemplate = class(TPersistent)
  private
    fCategory: TNewIDEItemCategory;
    FVisibleInNewDialog: boolean;
    FIsInherited: boolean;
  protected
    FAllowedFlags: TNewIDEItemFlags;
    FDefaultFlag: TNewIDEItemFlag;
    FItemAttributes: TNewIDEItemAttributes; //Ultibo
    FName: string;
    function GetIsModule: Boolean; //Ultibo
    function GetIsProject: Boolean; //Ultibo
    function GetRequireForms: Boolean; //Ultibo
    procedure InitDefaults; virtual; //Ultibo
  public
    constructor Create(const AName: string;
                       ADefaultFlag: TNewIDEItemFlag = niifCopy;
                       TheAllowedFlags: TNewIDEItemFlags = [niifCopy];
                       TheItemAttributes: TNewIDEItemAttributes = []); //Ultibo
    function LocalizedName: string; virtual;
    function Description: string; virtual;
    function CreateCopy: TNewIDEItemTemplate; virtual;
    procedure Assign(Source: TPersistent); override;
  public
    property DefaultFlag: TNewIDEItemFlag read FDefaultFlag;
    property AllowedFlags: TNewIDEItemFlags read FAllowedFlags;
    property ItemAttributes: TNewIDEItemAttributes read FItemAttributes; //Ultibo
    property Name: string read FName;
    property Category: TNewIDEItemCategory read fCategory write fCategory; // main category
    property IsModule: boolean read GetIsModule; //Ultibo
    property IsProject: boolean read GetIsProject; //Ultibo
    property RequireForms: boolean read GetRequireForms; //Ultibo
    property VisibleInNewDialog: boolean read FVisibleInNewDialog write FVisibleInNewDialog;
    property IsInheritedItem: boolean read FIsInherited write FIsInherited;
  end;
  TNewIDEItemTemplateClass = class of TNewIDEItemTemplate;
  
var
  NewIDEItems: TNewIDEItemCategories;// will be set by the IDE

procedure RegisterNewDialogItem(const Paths: string;
  NewItem: TNewIDEItemTemplate);
procedure UnregisterNewDialogItem(NewItem: TNewIDEItemTemplate);

procedure RegisterNewItemCategory(ACategory: TNewIDEItemCategory);


implementation


procedure RegisterNewItemCategory(ACategory: TNewIDEItemCategory);
begin
  NewIdeItems.Add(ACategory);
end;

procedure RegisterNewDialogItem(const Paths: string; NewItem: TNewIDEItemTemplate);
begin
  if NewIDEItems=nil then
    raise Exception.Create('RegisterNewDialogItem NewIDEItems=nil');
  NewIDEItems.RegisterItem(Paths,NewItem);
end;

procedure UnregisterNewDialogItem(NewItem: TNewIDEItemTemplate);
begin
  if NewIDEItems=nil then
    raise Exception.Create('RegisterNewDialogItem NewIDEItems=nil');
  NewIDEItems.UnregisterItem(NewItem);
end;

{ TNewIDEItemCategory }

function TNewIDEItemCategory.GetCount: integer;
begin
  Result:=FItems.Count;
end;

function TNewIDEItemCategory.GetItems(Index: integer): TNewIDEItemTemplate;
begin
  Result:=TNewIDEItemTemplate(FItems[Index]);
end;

procedure TNewIDEItemCategory.InitDefaults; //Ultibo
begin
  // Nothing
end; //Ultibo

constructor TNewIDEItemCategory.Create(const AName: string);
begin
  FVisibleInNewDialog:=true;
  FItems := TFPList.Create;
  FName  := AName;
  
  InitDefaults; //Ultibo
end;

destructor TNewIDEItemCategory.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TNewIDEItemCategory.Clear;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    Items[i].Free;
  FItems.Clear;
end;

procedure TNewIDEItemCategory.Add(ATemplate: TNewIDEItemTemplate);
begin
  FItems.Add(ATemplate);
  ATemplate.Category := Self;
end;

function TNewIDEItemCategory.LocalizedName: string;
begin
  Result:=Name;
end;

function TNewIDEItemCategory.Description: string;
begin
  Result:='';
end;

function TNewIDEItemCategory.IndexOfTemplate(const TemplateName: string): integer;
begin
  Result:=FItems.Count-1;
  while (Result>=0) and (SysUtils.CompareText(Items[Result].Name,TemplateName)<>0) do
    dec(Result);
end;

function TNewIDEItemCategory.FindTemplateByName(const TemplateName: string): TNewIDEItemTemplate;
var
  i: LongInt;
begin
  i := IndexOfTemplate(TemplateName);
  if i >= 0 then
    Result := Items[i]
  else
    Result := nil;
end;

function TNewIDEItemCategory.IndexOfCategory(const CategoryName: string): integer;
begin
  Result:=-1; // ToDo
end;

function TNewIDEItemCategory.FindCategoryByName(const CategoryName: string): TNewIDEItemCategory;
var
  i: LongInt;
begin
  i := IndexOfCategory(CategoryName);
  if i >= 0 then
    Result := nil // ToDo
  else
    Result := nil;
end;

{ TNewIDEItemTemplate }

function TNewIDEItemTemplate.GetIsModule: Boolean; //Ultibo
begin
  Result := (niiaIsModule in FItemAttributes);
end; //Ultibo

function TNewIDEItemTemplate.GetIsProject: Boolean; //Ultibo
begin
  Result := (niiaIsProject in FItemAttributes);
end; //Ultibo

function TNewIDEItemTemplate.GetRequireForms: Boolean; //Ultibo
begin
  Result := (niiaRequireForms in FItemAttributes);
end; //Ultibo

procedure TNewIDEItemTemplate.InitDefaults; //Ultibo
begin
  // Nothing
end; //Ultibo

constructor TNewIDEItemTemplate.Create(const AName: string;
  ADefaultFlag: TNewIDEItemFlag; TheAllowedFlags: TNewIDEItemFlags; TheItemAttributes: TNewIDEItemAttributes); //Ultibo
begin
  FName:=AName;
  FDefaultFlag:=ADefaultFlag;
  FAllowedFlags:=TheAllowedFlags;
  FItemAttributes:=TheItemAttributes; //Ultibo
  FVisibleInNewDialog:=true;
  FIsInherited := False;
  Include(FAllowedFlags,FDefaultFlag);
  
  InitDefaults; //Ultibo
end;

function TNewIDEItemTemplate.LocalizedName: string;
begin
  Result:=Name;
end;

function TNewIDEItemTemplate.Description: string;
begin
  Result:='<Description not set>';
end;

function TNewIDEItemTemplate.CreateCopy: TNewIDEItemTemplate;
begin
  Result:=TNewIDEItemTemplateClass(ClassType).Create(Name,DefaultFlag,AllowedFlags);
  Result.Assign(Self);
end;

procedure TNewIDEItemTemplate.Assign(Source: TPersistent);
var
  Src: TNewIDEItemTemplate;
begin
  if Source is TNewIDEItemTemplate then begin
    Src:=TNewIDEItemTemplate(Source);
    FName:=Src.Name;
    FDefaultFlag:=Src.DefaultFlag;
    FAllowedFlags:=Src.AllowedFlags;
  end else
    inherited Assign(Source);
end;

end.


