program Delphi_Chat_0901;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  Connect in 'Connect.pas' {ConnectForm},
  Controls,
  Data in 'Data.pas',
  Main in 'Main.pas' {MainForm},
  ChatRoom in 'ChatRoom.pas' {ChatRoomForm},
  UserInfo in 'UserInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  // ================= ConnectForm 실행 =================
  ConnectForm := TConnectForm.Create(nil);
  try
    if ConnectForm.ShowModal = mrOK then
    begin
      // ConnectForm에서 Con 객체를 전역으로 할당했다고 가정
      if not Assigned(Con) then
      begin
        ShowMessage('Con이 생성되지 않았습니다.');
        Application.Terminate;
        Exit;
      end;

      // ================= MainForm 생성 =================
      Application.CreateForm(TConnectForm, ConnectForm);
  // ================= 메시지 루프 시작 =================
      Application.Run;
    end
    else
      Application.Terminate;
  finally
    ConnectForm.Free;
  end;
end.

