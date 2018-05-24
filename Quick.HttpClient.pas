unit Quick.HttpClient;

{$i QuickLib.inc}

interface

uses
  Classes,
  {$IFDEF DELPHIXE8_UP}
  System.Net.HttpClient,
  System.Net.URLClient,
  System.NetConsts,
  System.JSON;
  {$ELSE}
  IdHTTP,
    {$IFDEF FPC}
    fpjson;
    {$ELSE}
    Data.DBXJSON;
    {$ENDIF}
  {$ENDIF}

type

  IHttpRequestResponse = interface
  ['{64DC58F7-B551-4619-85E9-D13E781529CD}']
    function StatusCode : Integer;
    function StatusText : string;
    function Response : TJSONObject;
  end;
  THttpRequestResponse = class(TInterfacedObject,IHttpRequestResponse)
  private
    fStatusCode : Integer;
    fStatusText : string;
    fResponse : TJSONObject;
  public
    {$IFDEF DELPHIXE8_UP}
    constructor Create(aResponse : IHTTPResponse; const aContent : string);
    {$ELSE}
    constructor Create(aResponse : TIdHTTPResponse; const aContent : string);
    {$ENDIF}
    destructor Destroy; override;
    function StatusCode : Integer;
    function StatusText : string;
    function Response : TJSONObject;
  end;

  TJsonHttpClient = class
  private
    {$IFDEF DELPHIXE8_UP}
    fHTTPClient : System.Net.HttpClient.THTTPClient;
    {$ELSE}
    fHTTPClient : TIdHTTP;
    {$ENDIF}
    fUserAgent : string;
    fContentType : string;
    fResponseTimeout : Integer;
    fConnectionTimeout : Integer;
    fHandleRedirects : Boolean;
    procedure SetContentType(const aValue: string);
    procedure SetUserAgent(const aValue: string);
    procedure SetResponseTimeout(const aValue: Integer);
    procedure SetConnectionTimeout(const aValue: Integer);
    procedure SetHandleRedirects(const aValue: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    property UserAgent : string read fUserAgent write SetUserAgent;
    property ContentType : string read fContentType write SetContentType;
    property ResponseTimeout : Integer read fResponseTimeout write SetResponseTimeout;
    property ConnectionTimeout : Integer read fConnectionTimeout write SetConnectionTimeout;
    property HandleRedirects : Boolean read fHandleRedirects write SetHandleRedirects;
    function Get(const aURL : string) : IHttpRequestResponse;
    function Post(const aURL, aInContent : string) : IHttpRequestResponse; overload;
    function Post(const aURL : string; aJsonContent : TJsonObject) : IHttpRequestResponse; overload;
  end;

implementation

const
  DEF_USER_AGENT = 'XLHttpClient';


constructor TJsonHttpClient.Create;
begin
  {$IFDEF DELPHIXE8_UP}
  fHTTPClient := THTTPClient.Create;
  fHTTPClient.ContentType := 'application/json';
  fHTTPClient.UserAgent := DEF_USER_AGENT;
  {$ELSE}
  fHTTPClient := TIdHTTP.Create(nil);
  fHTTPClient.Request.ContentType := 'application/json';
  fHTTPClient.Request.UserAgent := DEF_USER_AGENT;
  {$ENDIF}
end;

destructor TJsonHttpClient.Destroy;
begin
  fHTTPClient.Free;
  inherited;
end;

function TJsonHttpClient.Get(const aURL : string) : IHttpRequestResponse;
var
  {$IFDEF DELPHIXE8_UP}
  resp : IHTTPResponse;
  {$ELSE}
  resp : TIdHTTPResponse;
  {$ENDIF}
  bodycontent : TStringStream;
  responsecontent : TStringStream;
begin
  bodycontent := TStringStream.Create;
  try
    responsecontent := TStringStream.Create;
    try
      {$IFDEF DELPHIXE8_UP}
      resp := fHTTPClient.Get(aURL,responsecontent,nil);
      {$ELSE}
        {$IFDEF FPC}
        fHTTPClient.Get(aURL,responsecontent);
        {$ELSE}
        fHTTPClient.Get(aURL,responsecontent,nil);
        {$ENDIF}
      resp := fHTTPClient.Response;
      {$ENDIF}
      Result := THttpRequestResponse.Create(resp,responsecontent.DataString);
    finally
      responsecontent.Free;
    end;
  finally
    bodycontent.Free;
  end;
end;

function TJsonHttpClient.Post(const aURL, aInContent : string) : IHttpRequestResponse;
var
  {$IFDEF DELPHIXE8_UP}
  resp : IHTTPResponse;
  {$ELSE}
  resp : TIdHTTPResponse;
  {$ENDIF}
  responsecontent : TStringStream;
  postcontent : TStringStream;
begin
  postcontent := TStringStream.Create;
  try
    postcontent.WriteString(aInContent);
    responsecontent := TStringStream.Create;
    try
      {$IFDEF DELPHIXE8_UP}
      resp := fHTTPClient.Post(aURL,postcontent,nil);
      {$ELSE}
        {$IFDEF FPC}
        fHTTPClient.Post(aURL,postcontent,responsecontent);
        {$ELSE}
        fHTTPClient.Post(aURL,postcontent,nil);
        {$ENDIF}
      resp := fHTTPClient.Response;
      {$ENDIF}
      Result := THttpRequestResponse.Create(resp,responsecontent.DataString);
    finally
      responsecontent.Free;
    end;
  finally
    postcontent.Free;
  end;
end;

function TJsonHttpClient.Post(const aURL : string; aJsonContent : TJsonObject) : IHttpRequestResponse;
begin
  {$IFDEF DELPHIXE8_UP}
   Result := Self.Post(aURL,aJsonContent.ToJson);
  {$ELSE}
    {$IFDEF FPC}
     Result := Self.Post(aURL,aJsonContent.AsJson);
    {$ELSE}
     Result := Self.Post(aURL,aJsonContent.ToString);
    {$ENDIF}
  {$ENDIF}
end;

procedure TJsonHttpClient.SetConnectionTimeout(const aValue: Integer);
begin
  fConnectionTimeout := aValue;
  {$IFDEF DELPHIXE8_UP}
  fHTTPClient.ConnectionTimeout := aValue;
  {$ELSE}
  fHTTPClient.ConnectTimeout := aValue;
  {$ENDIF}
end;

procedure TJsonHttpClient.SetContentType(const aValue: string);
begin
  fContentType := aValue;
  {$IFDEF DELPHIXE8_UP}
  fHTTPClient.ContentType := aValue;
  {$ELSE}
  fHTTPClient.Request.ContentType := aValue;
  {$ENDIF}
end;

procedure TJsonHttpClient.SetHandleRedirects(const aValue: Boolean);
begin
  fHandleRedirects := aValue;
  {$IFDEF DELPHIXE8_UP}
  fHTTPClient.HandleRedirects := aValue;
  {$ELSE}
  fHTTPClient.HandleRedirects := aValue;
  {$ENDIF}
end;

procedure TJsonHttpClient.SetResponseTimeout(const aValue: Integer);
begin
  fResponseTimeout := aValue;
  {$IFDEF DELPHIXE8_UP}
  fHTTPClient.ResponseTimeout := aValue;
  {$ELSE}
  fHTTPClient.ReadTimeout := aValue;
  {$ENDIF}
end;

procedure TJsonHttpClient.SetUserAgent(const aValue: string);
begin
  fUserAgent := aValue;
  {$IFDEF DELPHIXE8_UP}
  fHTTPClient.UserAgent := aValue;
  {$ELSE}
  fHTTPClient.Request.UserAgent := aValue;
  {$ENDIF}
end;

{ THttpRequestResponse }

{$IFDEF DELPHIXE8_UP}
constructor THttpRequestResponse.Create(aResponse: IHTTPResponse; const aContent : string);
begin
  fStatusCode := aResponse.StatusCode;
  fStatusText := aResponse.StatusText;
  if aContent <> '' then fResponse := TJSONObject.ParseJSONValue(aContent) as TJSONObject;
end;
{$ELSE}
constructor THttpRequestResponse.Create(aResponse : TIdHTTPResponse; const aContent : string);
begin
  fStatusCode := aResponse.ResponseCode;
  fStatusText := aResponse.ResponseText;
  fResponse := GetJSON(aContent) as TJsonObject;
end;
{$ENDIF}


destructor THttpRequestResponse.Destroy;
begin
  if Assigned(fResponse) then fResponse.Free;
  inherited;
end;

function THttpRequestResponse.Response: TJSONObject;
begin
  Result := fResponse;
end;

function THttpRequestResponse.StatusCode: Integer;
begin
  Result := fStatusCode;
end;

function THttpRequestResponse.StatusText: string;
begin
  Result := fStatusText;
end;

end.
