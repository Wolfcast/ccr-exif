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
{ XMP browser VCL demo.                                                                            }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Version:       1.5.4                                                                             }
{ Last modified: 2024-01-13                                                                        }
{ Contributors:  Chris Rolliston                                                                   }
{                                                                                                  }
{**************************************************************************************************}

unit XMPBrowserForm;
{
  Not much to this one really. Note that according to both Adobe's XMP specification and Microsoft's
  XMP implementation, a schema's properties may be placed at various places in the XML structure. As
  presented by TXMPPacket, however, they are collated under the same Schema property.
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtDlgs,
  ActnList, StdCtrls, ExtCtrls, ComCtrls, Buttons, CCR.Exif.Demos, XMPBrowserFrame,
  Menus;

type
  TfrmXMPBrowser = class(TForm, IOutputFrameOwner)
    panFooter: TPanel;
    dlgOpen: TOpenPictureDialog;
    btnOpen: TBitBtn;
    btnExit: TBitBtn;
    PageControl: TPageControl;
    tabOriginal: TTabSheet;
    tabResaved: TTabSheet;
    ActionList: TActionList;
    actOpen: TAction;
    lblURI: TLabel;
    mnuURI: TPopupMenu;
    itmCopyURI: TMenuItem;
    procedure actOpenExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure itmCopyURIClick(Sender: TObject);
    procedure lblURIContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
    FOriginalFrame, FResavedFrame: TOutputFrame;
  protected
    procedure ActiveURIChanged(const NewURI: string);
    procedure DoFileOpen(const FileName1, FileName2: string); override;
  end;

var
  frmXMPBrowser: TfrmXMPBrowser;

implementation

uses ClipBrd;

{$R *.dfm}

procedure TfrmXMPBrowser.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  PageControl.Visible := TestMode;
  FOriginalFrame := TOutputFrame.Create(Self);
  FOriginalFrame.Align := alClient;
  FOriginalFrame.Name := '';
  if not TestMode then
  begin
    FOriginalFrame.Parent := Self;
    panFooter.Height := panFooter.Height - btnOpen.Top;
    btnOpen.Top := 0;
    btnExit.Top := 0;
  end
  else
  begin
    actOpen.Enabled := False;
    actOpen.Visible := False;
    ActiveControl := PageControl;
    FOriginalFrame.Parent := tabOriginal;
    FResavedFrame := TOutputFrame.Create(Self);
    FResavedFrame.Align := alClient;
    FResavedFrame.Parent := tabResaved;
  end;
  SupportOpeningFiles := True;
end;

procedure TfrmXMPBrowser.ActiveURIChanged(const NewURI: string);
begin
  lblURI.Caption := NewURI;
end;

procedure TfrmXMPBrowser.DoFileOpen(const FileName1, FileName2: string);
begin
  FOriginalFrame.LoadFromFile(FileName1);
  if FileName2 = '' then Exit;
  FResavedFrame.LoadFromFile(FileName2);
  tabOriginal.Caption := ExtractFileName(FileName1);
  tabResaved.Caption := ExtractFileName(FileName2);
end;

procedure TfrmXMPBrowser.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmXMPBrowser.actOpenExecute(Sender: TObject);
begin
  if dlgOpen.Execute then OpenFile(dlgOpen.FileName);
end;

procedure TfrmXMPBrowser.itmCopyURIClick(Sender: TObject);
begin
  Clipboard.AsText := lblURI.Caption;
end;

procedure TfrmXMPBrowser.lblURIContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  if lblURI.GetTextLen = 0 then Handled := True; //suppress if nothing to copy
end;

end.
