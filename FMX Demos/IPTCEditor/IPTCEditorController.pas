{**************************************************************************************************}
{                                                                                                  }
{ CCR Exif                                                                                         }
{ https://github.com/Wolfcast/ccr-exif                                                             }
{ Copyright (c) 2009-2014 Chris Rolliston. All Rights Reserved.                                    }
{                                                                                                  }
{ This file is part of CCR Exif which is released under the terms of the Mozilla Public License,   }
{ v. 2.0. See file LICENSE.txt or go to https://mozilla.org/MPL/2.0/ for full license details.     }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ IPTC tag editor FireMonkey demo (require Delphi XE3 to compile).                                 }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Version:       1.5.2 beta                                                                        }
{ Last modified: 2013-10-22                                                                        }
{ Contributors:  Chris Rolliston                                                                   }
{                                                                                                  }
{**************************************************************************************************}

unit IPTCEditorController;

interface

uses
  System.Types, System.UITypes, System.SysUtils, System.Classes, System.Generics.Collections, System.Rtti,
  System.Actions, FMX.ActnList, FMX.StdActns, FMX.Forms, FMX.Types, FMX.Dialogs, FMX.Platform, FMX.Menus,
  CCR.Exif.FMXUtils;

type
  IIPTCRepeatingPairControl = interface
  ['{47357898-203B-4280-8FA9-5FE256A321A3}']
    procedure AddNew;
    function CanRemoveSelected: Boolean;
    procedure RemoveSelected;
  end;

  IIPTCDocumentForm = interface
  ['{54404B2D-E31A-401A-8187-DF2AC1380E29}']
    function GetFileName: string;
    procedure ClearAll;
    procedure GotoNextTab;
    procedure GotoPreviousTab;
    function FileIsModified: Boolean;
    procedure OpenFile(const AFileName: string);
    procedure SaveFile;
    property FileName: string read GetFileName;
  end;

  TdtmController = class(TDataModule)
    ActionList: TActionList;
    actOpen: TAction;
    actClose: TWindowClose;
    dlgOpen: TOpenDialog;
    MacMenu: TMainMenu;
    itmFile: TMenuItem;
    itmFileOpen: TMenuItem;
    MenuItem3: TMenuItem;
    itmClearAll: TMenuItem;
    itmApp: TMenuItem;
    itmHideMe: TMenuItem;
    actAppQuit: TFileExit;
    actAppHide: TFileHideApp;
    actAppHideOthers: TFileHideAppOthers;
    itmHideOtherApps: TMenuItem;
    itmAppQuit: TMenuItem;
    itmDiv: TMenuItem;
    itmFileClose: TMenuItem;
    actNextTab: TAction;
    actPreviousTab: TAction;
    itmWindow: TMenuItem;
    itmMinimize: TMenuItem;
    actZoomWindow: TAction;
    MenuItem1: TMenuItem;
    itmShowAll: TMenuItem;
    actAppShowAll: TAction;
    actBringAllToFront: TAction;
    MenuItem2: TMenuItem;
    itmBringAllToFront: TMenuItem;
    actAppAbout: TAction;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    actToggleFullScreen: TAction;
    actMinimizeWindow: TAction;
    actSave: TAction;
    actReload: TAction;
    actClearAll: TAction;
    itmFileReload: TMenuItem;
    mnuRepeatingValue: TPopupMenu;
    itmAddItem: TMenuItem;
    itmRemoveItem: TMenuItem;
    actAddNewItem: TAction;
    actRemoveSelectedItem: TAction;
    MenuItem4: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    procedure actOpenExecute(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure actPreviousTabExecute(Sender: TObject);
    procedure actNextTabExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actReloadExecute(Sender: TObject);
    procedure actReloadOrSaveUpdate(Sender: TObject);
    procedure actClearAllExecute(Sender: TObject);
    procedure actAddNewItemExecute(Sender: TObject);
    procedure actRemoveSelectedItemExecute(Sender: TObject);
    procedure actAddNewItemUpdate(Sender: TObject);
    procedure actRemoveSelectedItemUpdate(Sender: TObject);
  strict private
    class var FDocumentFormClass: TFormClass;
    class var FSDIForm: TForm;
    class constructor Create;
  protected
    FClipboardService: IFMXClipboardService;
    procedure OpenFile(const AFileName: string);
  end;

var
  dtmController: TdtmController;

implementation

{%CLASSGROUP 'FMX.Types.TFmxObject'}

{$R *.dfm}

uses FMX.Grid;

resourcestring
  SConfirmReload = 'Are you sure you want to reload? Any changes made will be lost if you do.';

{ TdtmController }

class constructor TdtmController.Create;
begin
  if not LookupImplementingClass(IIPTCDocumentForm, TForm, FDocumentFormClass) then
    raise EProgrammerNotFound.Create('IIPTCDocumentForm implementor missing');
  if TOSVersion.Platform = pfMacOS then
    TFileManager.DocumentMode := dmOnePerForm
  else
  begin
    TFileManager.DocumentMode := dmOnePerAppInst;
    Application.CreateForm(FDocumentFormClass, FSDIForm);
  end;
end;

procedure TdtmController.DataModuleCreate(Sender: TObject);
begin
  { Initialize the menu bar if targetting macOS }
  if TOSVersion.Platform = pfMacOS then
  begin
    TMacCommands.InitializeAboutAction(actAppAbout);
    TMacCommands.InitializeShowAllAction(actAppShowAll);
    TMacCommands.InitializeToggleFullScreenAction(actToggleFullScreen);
    TMacCommands.InitializeMinimizeAction(actMinimizeWindow);
    TMacCommands.InitializeZoomAction(actZoomWindow);
    TMacCommands.InitializeBringAllToFrontAction(actBringAllToFront);
    MacMenu.Activate;
    TMacCommands.InitializeWindowMenu(itmWindow);
  end
  else
    ConvertCommandToCtrlShortcuts(ActionList);
  TFileManager.OnOpenFile := OpenFile;
end;

procedure TdtmController.OpenFile(const AFileName: string);
var
  DocForm: TForm;
begin
  if TFileManager.DocumentMode = dmOnePerAppInst then
    DocForm := FSDIForm
  else
    DocForm := FDocumentFormClass.Create(Self);
  try
    (DocForm as IIPTCDocumentForm).OpenFile(AFileName);
  except
    if DocForm <> FSDIForm then DocForm.Free;
    raise;
  end;
  TFileManager.AssociateWithForm(AFileName, DocForm);
  DocForm.Show;
end;

procedure TdtmController.actOpenExecute(Sender: TObject);
begin
  if dlgOpen.Execute then OpenFile(dlgOpen.FileName);
end;

procedure TdtmController.actAddNewItemExecute(Sender: TObject);
begin
  (Screen.FocusControl as IIPTCRepeatingPairControl).AddNew;
end;

procedure TdtmController.actAddNewItemUpdate(Sender: TObject);
begin
  actAddNewItem.Enabled := Supports(Screen.FocusControl, IIPTCRepeatingPairControl);
end;

procedure TdtmController.actClearAllExecute(Sender: TObject);
begin
  (Screen.ActiveForm as IIPTCDocumentForm).ClearAll;
end;

procedure TdtmController.actNextTabExecute(Sender: TObject);
var
  DocForm: IIPTCDocumentForm;
begin
  if Supports(Screen.ActiveForm, IIPTCDocumentForm, DocForm) then
    DocForm.GotoNextTab;
end;

procedure TdtmController.actPreviousTabExecute(Sender: TObject);
var
  DocForm: IIPTCDocumentForm;
begin
  if Supports(Screen.ActiveForm, IIPTCDocumentForm, DocForm) then
    DocForm.GotoPreviousTab;
end;

procedure TdtmController.actReloadExecute(Sender: TObject);
var
  DocForm: IIPTCDocumentForm;
begin
  DocForm := Screen.ActiveForm as IIPTCDocumentForm;
  if IsPositiveResult(MessageDlg(SConfirmReload, TMsgDlgType.mtConfirmation, mbYesNo, 0)) then
    DocForm.OpenFile(DocForm.FileName);
end;

procedure TdtmController.actReloadOrSaveUpdate(Sender: TObject);
var
  DocForm: IIPTCDocumentForm;
begin
  (Sender as TAction).Enabled := Supports(Screen.ActiveForm, IIPTCDocumentForm, DocForm) and
    DocForm.FileIsModified;
end;

procedure TdtmController.actRemoveSelectedItemExecute(Sender: TObject);
begin
  (Screen.FocusControl as IIPTCRepeatingPairControl).RemoveSelected;
end;

procedure TdtmController.actRemoveSelectedItemUpdate(Sender: TObject);
var
  Control: IIPTCRepeatingPairControl;
begin
  actRemoveSelectedItem.Enabled := Supports(Screen.FocusControl, IIPTCRepeatingPairControl, Control) and
    Control.CanRemoveSelected;
end;

procedure TdtmController.actSaveExecute(Sender: TObject);
begin
  (Screen.ActiveForm as IIPTCDocumentForm).SaveFile;
end;

end.
