unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  LMessages, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnExport: TButton;
    btnImport: TButton;
    tvTodos: TTreeView;
    procedure btnExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShortCut(var Msg: TLMKey; var Handled: boolean);
    procedure tvTodosEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: boolean);
    procedure tvTodosEditingEnd(Sender: TObject; Node: TTreeNode; Cancel: boolean);
    procedure tvTodosSelectionChanged(Sender: TObject);
  private
    procedure Delete(ANode: TTreeNode);
    function ExportTodos(ANode: TTreeNode; ALevel: integer): string;
  public
    FCurr: TTreeNode;
    FEditingMode: boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FCurr := tvTodos.Items.Add(nil, 'Todo');
end;

procedure TForm1.btnExportClick(Sender: TObject);
var
  AFStream: TFileStream;
  Todos: string;
begin
  AFStream := TFileStream.Create('todos.md', fmCreate);
  Todos := ExportTodos(tvTodos.Items.GetFirstNode, -1);
  AFStream.Write(Todos[1], Length(Todos));
  AFStream.Free;
end;

procedure TForm1.FormShortCut(var Msg: TLMKey; var Handled: boolean);
var
  ANode: TTreeNode;
begin
  Handled := False;
  if (not FEditingMode) then
  begin
    Handled := True;
    if (Msg.CharCode = Ord('I')) or (Msg.CharCode = Ord('i')) then
    begin
      ANode := tvTodos.Items.AddChild(FCurr, '');
      ANode.Focused := True;
      ANode.EditText;
    end
    else if (Msg.CharCode = Ord('D')) or (Msg.CharCode = Ord('d')) then
    begin
      if FCurr.HasChildren then
        if messagedlg('Delete node and all children ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
          exit;
      ANode := FCurr;
      FCurr := FCurr.Parent;
      Delete(ANode);
    end;
  end;
end;

procedure TForm1.tvTodosEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: boolean);
begin
  AllowEdit := True;
  FEditingMode := True;
end;

procedure TForm1.tvTodosEditingEnd(Sender: TObject; Node: TTreeNode; Cancel: boolean);
begin
  FEditingMode := False;
end;

procedure TForm1.tvTodosSelectionChanged(Sender: TObject);
begin
  FCurr := tvTodos.Selected;
  if (FCurr = nil) then
  begin
    FCurr := tvTodos.Items.GetFirstNode;
  end;
end;

procedure TForm1.Delete(ANode: TTreeNode);
begin
  while (ANode.HasChildren) do
    Delete(ANode.GetLastChild);
  if (ANode = tvTodos.Items.GetFirstNode) then
    exit;
  tvTodos.Items.Delete(ANode);
end;

function TForm1.ExportTodos(ANode: TTreeNode; ALevel: integer): string;
var
  Child: TTreeNode;
  I: integer;
begin
  Result := '';
  if (ALevel > -1) then
  begin
    for I := 1 to ALevel do
    begin
      Result += #9;
    end;
    Result += '- [ ] ' + ANode.Text + #13;
  end
  else
  begin
    Result += '# ' + ANode.Text + #13;
  end;
  Child := ANode.GetFirstChild;
  while Child <> nil do
  begin
    Result += ExportTodos(Child, ALevel + 1);
    Child := Child.GetNextSibling;
  end;
end;

end.
