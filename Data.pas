unit Data;
{
- TCon 클래스
서버 연결/전송/수신 처리의 중심 객체 (클라이언트의 핵심 통신 관리 클래스)

-TReceiveThread 클래스
서버에서 오는 메시지를 백그라운드에서 계속 받는 스레드

-SafeGetValue 함수
JSON에서 값이 없을 때 Access Violation 방지용 안전 추출 함수

-이벤트 구조
OnChatMessage, OnLoginResponse 등으로 폼에 연결되어 메시지를 UI로 전달

-코드 흐름
1.클라이언트 실행 → TCon.Create()
2.Con.ConnectToServer() → 서버 연결 + 수신 스레드 실행
3.사용자가 로그인 클릭 → SendJson("LOGIN", [...])
4서버 → 로그인 결과 JSON 전송
5.수신 스레드 ReadLn() → HandleMessage() 호출
6.HandleMessage → OnLoginResponse 이벤트 실행
7.ConnectForm.HandleLoginResponse() → 로그인 결과 표시

}

interface

uses
   Classes, SysUtils, IdTCPClient, Vcl.Dialogs, WinAPI.Windows, Data.DBXJSON,IdException, IdStack;

//서버에서 값을 보내지 않을때 에러 방지(Access Violation)
function SafeGetValue(JSON: TJSONObject; const Key: string; const Default: string = ''): string;

type
   // 수신 스레드
   TReceiveThread = class(TThread)  //서버로 부터 오는 메시지를 실시간으로 받기 위해 스레드 선언
   private
      FClient        : TIdTCPClient;
      FCon           : TObject; // TCon 참조
   protected
      procedure Execute; override;
   public
      constructor CreateWithClient(AClient: TIdTCPClient; ACon: TObject);
   end;

   // 메시지 이벤트 타입 정의
   TMessageEvent = procedure(Sender: TObject; const Msg: string) of object;


   // 서버 연결 객체
   TCon = class

   private
      FClient                 : TIdTCPClient;
      FRecvThread             : TReceiveThread;

   public
      OnLoginResponse         : TMessageEvent;
      OnSignUpResponse        : TMessageEvent;
      OnCreateRoom            : TMessageEvent;
      OnChatMessage           : TMessageEvent;   //ChatRoom 에 HandleChatMessage 할당
      OnChatHistory           : TMessageEvent;
      OnExitRoom              : TMessageEvent;
      OnUserList              : TMessageEvent;
      OnInviteUser            : TMessageEvent;
      OnInviteAvailableUsers  : TMessageEvent;
      OnError                 : TMessageEvent;
      OnRestoreRooms          : TMessageEvent;

      constructor Create;
      destructor  Destroy; override;

      procedure ConnectToServer;
      procedure SendJson         (const command: string; const params: array of string); //중앙 메시지 처리(클라 -> 서버)
      procedure HandleMessage    (const MsgText: string);                   // 중앙 메시지 처리(서버 -> 클라)
      procedure DisconnectFromServer;  // 로그아웃 기능

      function ExtractRoomNameFromJson(const Msg: string): string;  //안전하게 서버가 보내준 값 추출

      property Client: TIdTCPClient read FClient;

   end;

var
   Con: TCon;

implementation

uses
   Connect, Main, ChatRoom;

{ TCon }

//=======중앙 처리 장치 생성=======//
constructor TCon.Create;
begin
   inherited;       //TCon 의 부모클래스 실행
   //FClient 역할 = 서버 접속, 데이터 전송, 데이터 수신, 접속 종료
   FClient := TIdTCPClient.Create(nil);       //통신에 사용할 TIdTCPClient 객체를 생성
end;

//=======서버와 연결=======
procedure TCon.ConnectToServer;
begin
   if FClient.Connected then Exit;     //이미 열결 되었으면 종료

   try
      FClient.Host            := '127.0.0.1';
      FClient.Port            := 8000;
      FClient.ConnectTimeout  := 3000;
      FClient.Connect;                 //연결 시도

      // 수신 스레드 시작
      if not Assigned(FRecvThread) then                                    //스레드가 만들어지지 않았다면 생성
         FRecvThread := TReceiveThread.CreateWithClient(FClient, Self);    //수신 스레드 생성
   except
      on E: Exception do
         ShowMessage('Connection failed: ' + E.Message);
   end;
end;

// -----------------------------
//서버에서 받은 방 이름 안전하게 추출
// -----------------------------
function TCon.ExtractRoomNameFromJson(const Msg: string): string;
var
   JSONObject: TJSONObject;
begin
   Result := '';
   JSONObject := TJSONObject.ParseJSONValue(Msg) as TJSONObject;
   try
      if JSONObject <> nil then
         Result := JSONObject.GetValue('room').Value;
   finally
      JSONObject.Free;
   end;
end;

destructor TCon.Destroy;
begin
   FClient.Free;                //통신객체를 해제하고
   inherited;                   //TCon 부모 클래스 해제
end;

//서버와 연결 해제
procedure TCon.DisconnectFromServer;
begin
   // 수신 스레드 종료
   if Assigned(FRecvThread) then
   begin
      FRecvThread.Terminate;        //수신스레드 종료 요청

      // 먼저 소켓 닫기 -> 스레드가 ReadLn에서 대기 중이라면 여기서 종료
      if Assigned(FClient) and FClient.Connected then
      begin
         try
            FClient.IOHandler.Close;    //강제로 소켓 종료후
            FClient.Disconnect;          //확실하게 종료
         except
         // 무시(에러가 났으면 이미 끊긴상태)
         end;
      end;

      FRecvThread.WaitFor; // 스레드 종료 대기
      FreeAndNil(FRecvThread); // 메모리 해제 및 nil로 초기화
   end
   else
   begin
      // 스레드가 없더라도 소켓은 닫음
      if Assigned(FClient) and FClient.Connected then
      begin
         try
            FClient.IOHandler.Close;
            FClient.Disconnect;
         except
      // 무시
         end;
      end;
   end;
end;

// =================== 메시지 중앙 처리(송신) ===================
procedure TCon.SendJson(const command: string; const params: array of string);
var
   JSONObject: TJSONObject;
   i         : Integer;
   begin
   //유효성 검사
   if not Assigned(FClient) or not FClient.Connected then
      raise Exception.Create('Not connected');

   JSONObject := TJSONObject.Create;  //객체 생성
   try

      JSONObject.AddPair('command', TJSONString.Create(command.ToUpper));     //   command 키+명령어르 대문저로 변환 시킨뒤  값에 저장

      //command 명령 제외한 데이터 전달
      i := 0;
      while i < Length(params) - 1 do                                        //파라미터 길이만큼 반복
      begin
         JSONObject.AddPair(params[i], params[i + 1]);                       //객체에 파라미터 키 와 값을 추가
         Inc(i, 2);                                                          //i 에 2씩 추가
      end;

      FClient.IOHandler.WriteLn(JSONObject.ToString);                        //객체를 문자열로 변환후 서버에 전송
   finally
      JSONObject.Free;
   end;
end;


// =================== 메시지 중앙 처리(수신) ===================
procedure TCon.HandleMessage(const MsgText: string);
var
   JSONObject  : TJSONObject;
   Cmd, Status : string;
begin
   JSONObject := TJSONObject.ParseJSONValue(MsgText) as TJSONObject;      //서버에서 받은 데이터를 객체로 변경후 저장
   try
      if JSONObject = nil then Exit;

      Cmd      := SafeGetValue(JSONObject, 'command');                    //Cmd에 command 값 저장
      Status   := SafeGetValue(JSONObject, 'status');

      // 이벤트 호출 (Cmd 값 비교 + 이벤트 연결 여부 확인)
      if SameText(Cmd, 'LOGIN')                       and Assigned(OnLoginResponse) then
         OnLoginResponse(Self, MsgText)
      else if SameText(Cmd, 'CREATE')                 and Assigned(OnCreateRoom) then
         OnCreateRoom(Self, MsgText)
      else if SameText(Cmd, 'CHAT')                   and Assigned(OnChatMessage) then
         OnChatMessage(Self, MsgText)
      else if SameText(Cmd, 'EXIT_OK')                and Assigned(OnExitRoom) then
         OnExitRoom(Self, MsgText)
      else if SameText(Cmd, 'INDEX')                  and Assigned(OnChatHistory) then
         OnChatHistory(Self, MsgText)
      else if SameText(Cmd, 'USER_LIST')              and Assigned(OnUserList) then
         OnUserList(Self, MsgText)
      else if SameText(Cmd, 'INVITE')                 and Assigned(OnInviteUser)then
         OnInviteUser(Self, MsgText)
      else if SameText(Cmd, 'INVITE_AVAILABLE_USERS') and Assigned(OnInviteUser)then
         OnInviteAvailableUsers(Self, MsgText)
      else if SameText(Cmd, 'RESTORE_ROOMS')          and Assigned(OnRestoreRooms) then
         OnRestoreRooms(Self, MsgText)
      else if SameText(Status, 'ERROR') then
      begin
         if Assigned(OnError) then
            OnError(Self, MsgText); // 공통 에러 핸들러
      end

      else
         OutputDebugString(PChar('Unknown command received: ' + Cmd));

   finally

      JSONObject.Free;
   end;
end;


{ TReceiveThread }

constructor TReceiveThread.CreateWithClient(AClient: TIdTCPClient; ACon: TObject);
begin
   inherited Create(True);      //스레드를 일시정지 상태로 생성
   FClient := AClient;          //통신객체 할당
   FCon := ACon;                //중앙 처리 장치 할당
   FreeOnTerminate := False;     //스레드가 끝나면 자동으로 메모리 해제    10/24 True => False 로 수정 ,스레드가 멋대로 종료 => TCon이 직접 관리

   // 생성 로그
   OutputDebugString(PChar('TReceiveThread created! ThreadID=' + IntToStr(Self.ThreadID)));

   Resume; //스레드 실행
end;

procedure TReceiveThread.Execute;
var
   MsgText : string; // MsgCopy는 필요 없습니다.
   MyCon   : TCon;
begin
   MyCon := TCon(FCon);
  // 스레드 종료 신호가 올 때까지 무한 반복
  while not Terminated do
  begin
    try
      // 1. [Blocking I/O] 서버 메시지가 올 때까지 여기서 대기 (UI 멈춤 없음)
      if (FClient <> nil) and FClient.Connected then
        MsgText := FClient.IOHandler.ReadLn;

      if MsgText <> '' then
      begin
        // 2. [Thread-Safe] UI 스레드와의 충돌을 막기 위해 동기화 수행
        Synchronize(procedure
        begin
           // 안전하게 메인 스레드로 데이터 전달
           if Assigned(MyCon) then
             MyCon.HandleMessage(MsgText);
        end);
      end;

    except
      Break; // 연결 종료나 에러 발생 시 루프 탈출
    end;
  end;
end;

//========== 에러 방지(Access Violation) ================
function SafeGetValue(JSON: TJSONObject; const Key: string; const Default: string = ''): string;
var
   Val: TJSONValue;
begin
   Result := Default;         //빈값으로 설정
   if JSON = nil then
      Exit;
   Val := JSON.GetValue(Key); //키의 값을 Val에 저장
   if Assigned(Val) then
      Result := Val.Value;   //키의 값 반환
end;

end.

