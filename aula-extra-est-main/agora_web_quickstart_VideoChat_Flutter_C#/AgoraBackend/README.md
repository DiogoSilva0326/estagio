# AgoraBackend (C#)

Backend em C# equivalente ao `server.go` (Go), expondo:
- `POST /fetch_rtc_token`
- `POST /fetch_whiteboard_token`

## Config

Cria um `.env` nesta pasta (há um `.env.example`):

- `AGORA_APP_ID`
- `AGORA_APP_CERTIFICATE`
- `NETLESS_SDK_TOKEN`
- `NETLESS_REGION` (default: `us-sv`)
- `PORT` (opcional, default: `8082`)

## Run

```zsh
cd /Users/tiago2synget/ProjetosGitHub/agoraAPI/agora_web_quickstart_VideoChat_Flutter_C#/AgoraBackend
dotnet restore
dotnet run
```

## Teste rápido (curl)

```zsh
curl -s -X POST http://localhost:8082/fetch_rtc_token \
  -H 'Content-Type: application/json' \
  -d '{"uid":0,"channelName":"teste","role":1}'

curl -s -X POST http://localhost:8082/fetch_whiteboard_token \
  -H 'Content-Type: application/json' \
  -d '{"channelName":"teste","uid":"0"}'
```
