# HyperFrames 安裝與設定說明

本文件記錄本專案使用 HyperFrames 製作影片所需的安裝、設定、檢查、啟動與渲染流程。

適用專案：

```powershell
D:\VIbeCoding\workplace-bullying-prevention-toolkit
```

主要 HyperFrames 影片專案：

```powershell
D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos
```

## 1. 必要環境

HyperFrames 本機預覽與渲染需要下列工具：

- Node.js 22 以上
- npm / npx
- FFmpeg
- FFprobe
- HyperFrames CLI
- HyperFrames 使用的固定版本 Chrome Headless Shell

可用下列指令檢查：

```powershell
node --version
npm --version
npx --version
ffmpeg -version
ffprobe -version
```

本機已驗證可用版本：

```text
Node.js v24.16.0
npm 11.13.0
npx 11.13.0
FFmpeg 8.1.2
FFprobe 8.1.2
```

## 2. 安裝 Node.js

如果沒有 Node.js，建議安裝 LTS 或更新版本。HyperFrames 要求 Node.js 22 以上。

使用 winget 安裝：

```powershell
winget install OpenJS.NodeJS.LTS
```

安裝後重新開啟 PowerShell，再檢查：

```powershell
node --version
npm --version
npx --version
```

## 3. 安裝 FFmpeg

如果沒有 FFmpeg / FFprobe，可用 winget 安裝：

```powershell
winget install Gyan.FFmpeg
```

安裝後重新開啟 PowerShell，再檢查：

```powershell
ffmpeg -version
ffprobe -version
```

## 4. 安裝與檢查 HyperFrames CLI

HyperFrames 透過 npx 執行，不需要另外在專案內安裝套件。

檢查環境：

```powershell
npx hyperframes doctor --json
```

如果要使用本專案固定版本，可在影片專案資料夾使用：

```powershell
cd D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos
npx --yes hyperframes@0.7.22 doctor --json
```

注意：

- `doctor --json` 即使有選用項目缺少，也可能回報 `"ok": false`。
- 一般 HTML 影片預覽與本機渲染，必要項目是 Node.js、FFmpeg、FFprobe、Chrome。
- Docker、whisper-cpp、Kokoro、MusicGen 是選用項目。

## 5. 更新 HyperFrames 技能包

如果 HyperFrames 技能包過期或缺少，先檢查：

```powershell
npx hyperframes skills check --json
```

更新：

```powershell
npx hyperframes skills update
```

確認結果應該類似：

```text
current: 20
outdated: 0
missing: 0
```

## 6. 安裝 Chrome Headless Shell

HyperFrames 本機渲染需要它指定版本的 Chrome Headless Shell。

一般情況可直接執行：

```powershell
npx hyperframes browser ensure
```

檢查路徑：

```powershell
npx hyperframes browser path
```

本機已設定成功的路徑：

```text
C:\Users\user\.cache\hyperframes\chrome\chrome-headless-shell\win64-131.0.6778.85\chrome-headless-shell-win64\chrome-headless-shell.exe
```

## 7. 修復 Chrome 快取壞掉的情況

如果看到類似錯誤：

```text
Cached binary missing ...
Run `hyperframes browser ensure --force` to re-download.
```

先嘗試：

```powershell
npx hyperframes browser clear
npx hyperframes browser ensure
```

如果一般下載逾時或只下載到不完整 zip，可以改用 Windows BITS 下載：

```powershell
$base = 'C:\Users\user\.cache\hyperframes\chrome\chrome-headless-shell'
$zip = Join-Path $base '131.0.6778.85-chrome-headless-shell-win64.zip'
$url = 'https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.85/win64/chrome-headless-shell-win64.zip'

New-Item -ItemType Directory -Force -Path $base | Out-Null
Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $zip -TransferType Download -Priority Foreground
```

下載完成後解壓到 HyperFrames 預期位置：

```powershell
$versionDir = Join-Path $base 'win64-131.0.6778.85'
if (Test-Path $versionDir) {
  Remove-Item -LiteralPath $versionDir -Recurse -Force
}

Expand-Archive -LiteralPath $zip -DestinationPath $versionDir -Force

$exe = Join-Path $versionDir 'chrome-headless-shell-win64\chrome-headless-shell.exe'
if (-not (Test-Path $exe)) {
  throw "Chrome executable missing after manual install: $exe"
}

Get-Item $exe
```

再次確認：

```powershell
npx hyperframes browser path
npx hyperframes doctor --json
```

## 8. 檢查本專案影片是否可用

進入主要影片專案：

```powershell
cd D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos
```

執行完整檢查：

```powershell
npm run check
```

等同於：

```powershell
npx --yes hyperframes@0.7.22 lint
npx --yes hyperframes@0.7.22 validate
npx --yes hyperframes@0.7.22 inspect
```

目前本專案已驗證：

```text
0 errors
0 layout issues
```

仍可能看到 warning，例如：

- `studio_missing_editable_id`
- `google_fonts_import`
- `timeline_track_too_dense`

這些是品質警告，不會阻擋一般預覽或渲染。

## 9. 啟動 HyperFrames Studio

### 方法 A：使用一鍵啟動批次檔

專案根目錄已建立：

```powershell
D:\VIbeCoding\workplace-bullying-prevention-toolkit\start-hyperframes-studio.bat
```

直接雙擊即可啟動 Studio。

預設網址：

```text
http://127.0.0.1:3002
```

注意：啟動後會開一個命令視窗，編輯期間請保持視窗開啟；關閉視窗會停止 Studio。

### 方法 B：手動啟動

```powershell
cd D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos
npx --yes hyperframes@0.7.22 preview --port 3002 --open
```

如果 3002 被占用，可改用其他埠：

```powershell
npx --yes hyperframes@0.7.22 preview --port 3003 --open
```

查看目前 Studio 服務：

```powershell
npx --yes hyperframes@0.7.22 preview --list
```

## 10. 渲染單支影片

進入影片專案：

```powershell
cd D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos
```

渲染第一支草稿影片：

```powershell
npx --yes hyperframes@0.7.22 render --composition compositions/01_what_is_bullying.html --quality draft --workers 1 --output renders/01-what-is-bullying-draft.mp4
```

正式品質可用：

```powershell
npx --yes hyperframes@0.7.22 render --composition compositions/01_what_is_bullying.html --quality high --workers 1 --output renders/01-what-is-bullying.mp4
```

渲染完成後確認輸出檔存在且大小合理：

```powershell
Get-Item renders/01-what-is-bullying.mp4
```

## 11. 批次渲染全部影片

本專案提供：

```powershell
D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos\render-all.ps1
```

執行完整批次渲染：

```powershell
cd D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos
powershell -ExecutionPolicy Bypass -File .\render-all.ps1
```

先跑草稿品質：

```powershell
powershell -ExecutionPolicy Bypass -File .\render-all.ps1 -Quality draft
```

只測第一支：

```powershell
powershell -ExecutionPolicy Bypass -File .\render-all.ps1 -Quality draft -Workers 1 -Limit 1
```

不暫停，適合自動測試：

```powershell
powershell -ExecutionPolicy Bypass -File .\render-all.ps1 -Quality draft -Workers 1 -Limit 1 -NoPause
```

預設輸出資料夾：

```powershell
D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos\output
```

## 12. 常見問題

### `doctor` 顯示 Docker 缺少

Docker 是選用項目。只有使用：

```powershell
npx hyperframes render --docker
```

或需要跨環境嚴格重現渲染結果時才需要。

一般本機預覽與渲染不需要 Docker。

### `doctor` 顯示 whisper-cpp 缺少

whisper-cpp 是選用項目。只有需要本機轉錄音訊或影片字幕時才需要。

### `doctor` 顯示 Kokoro 或 MusicGen 缺少

這兩個是選用項目：

- Kokoro：本機語音 fallback
- MusicGen：本機配樂 fallback

本專案目前一般 HTML 影片渲染不需要它們。

### PowerShell 腳本中文變亂碼

Windows PowerShell 5.1 對無 BOM UTF-8 腳本可能會用錯編碼讀取。為避免批次渲染腳本被破壞，`render-all.ps1` 內部訊息與輸出檔名採用 ASCII。

文件與網頁內容仍可使用繁體中文。

### HyperFrames Studio 服務卡住或埠被占用

先查看目前服務：

```powershell
npx --yes hyperframes@0.7.22 preview --list
```

必要時可關閉所有 HyperFrames preview：

```powershell
npx --yes hyperframes@0.7.22 preview --kill-all
```

再重新啟動：

```powershell
npx --yes hyperframes@0.7.22 preview --port 3002 --open
```

## 13. 建議日常流程

每次修改影片後：

```powershell
cd D:\VIbeCoding\workplace-bullying-prevention-toolkit\video\workplace-bullying-videos
npm run check
```

確認無 error 後再開 Studio：

```powershell
npx --yes hyperframes@0.7.22 preview --port 3002 --open
```

要輸出影片時先用 draft：

```powershell
powershell -ExecutionPolicy Bypass -File .\render-all.ps1 -Quality draft
```

確認畫面沒問題後再用 standard 或 high：

```powershell
powershell -ExecutionPolicy Bypass -File .\render-all.ps1 -Quality high
```
