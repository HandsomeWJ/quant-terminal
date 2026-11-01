# Setup prompt

Open Claude Code or Codex in the folder where you want the app, then paste everything in the box below. The same prompt updates an existing copy and keeps your saved data.

```text
Install Quant Terminal on this computer for me. It's a trading terminal that runs locally: charts, 87 built-in indicators with no limit per chart, drawing tools, alerts, a screener, a heatmap, seasonals, calendars, news, company financials, a strategy tester with quant checks, bar replay and paper trading. It downloads from GitHub: https://github.com/HandsomeWJ/quant-terminal. It needs Node.js 18 or newer and nothing else: no API keys, no accounts, no npm install.

HOW TO WORK WITH ME
- Talk to me like a friendly, patient helper. Assume I've never done this before. Use short sentences and everyday words, no jargon. If you have to use a technical word like "terminal" or "Node.js", explain it in a few plain words the first time.
- Keep each update to a line or two. Tell me what's happening and what it means for me, not the technical detail.
- Before each step, tell me in one short line what you're about to do. Show where we are as "Step 2 of 5".
- Run every command yourself. Only hand me a command if it needs my password or admin rights.
- If a command fails, read the error, fix the cause and run it again. Try up to three fixes per step, then tell me in plain words what's wrong and what you tried.
- This needs internet access: github.com and codeload.github.com for the download, nodejs.org only if Node.js is missing, and the public market data sites (Binance, Coinbase, Kraken, Nasdaq, Yahoo and Forex Factory). If your sandbox blocks network access, ask me to approve it.
- If a safety check blocks you from downloading or running these files (for example Claude Code's auto mode), don't try to change your own permission settings. Tell me in one line, then give me one command at a time to run myself (in Claude Code I type ! followed by the command). At the end, tell me I can skip this next time by allowing `Bash(node scripts/*)` for this folder (/permissions in Claude Code).
- Never ask me for passwords, API keys, exchange keys or broker logins. Nothing here needs them.
- Don't use sudo or admin rights yourself, and don't install anything except Node.js, and only after I say yes.
- Don't change the app's code during the install unless a check fails and the fix is clearly in the code.
- If you can't ask me questions (for example you're running non-interactively), use the defaults and keep going.

STEP 1 OF 5: CHECK THIS COMPUTER
Work out the operating system and shell (macOS, Linux, or Windows with PowerShell, cmd or Git Bash). Run `node -v`.
- 18 or newer: carry on.
- Missing or older: tell me, offer the simplest install for my system, and wait for my yes:
  - macOS: `brew install node` if Homebrew is installed. Otherwise the LTS installer from https://nodejs.org, which asks for my Mac password, so I run it myself.
  - Windows: `winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements`. Windows may ask me to approve an admin prompt; that's fine. The new node isn't on this terminal's PATH yet, so open a new terminal or call it by its full path: `& "C:\Program Files\nodejs\node.exe"` in PowerShell, `"C:\Program Files\nodejs\node.exe"` in cmd, `"/c/Program Files/nodejs/node.exe"` in Git Bash.
  - Linux: the distribution's package if it's 18 or newer (it needs sudo, so hand me that command), otherwise nvm (https://github.com/nvm-sh/nvm), which doesn't.
  Then run `node -v` again to confirm.

STEP 2 OF 5: DOWNLOAD
Install into a folder called quant-terminal inside the folder you're running in now. The commands below create that folder and unpack the app straight into it, so run them from the folder you're in now.
- If ./quant-terminal already has server.js in it, this is an update. Run `node scripts/stop.js` inside it first, then run the same commands from the folder above it. They replace the app's files and leave the data folder alone: that's my saved charts, alerts and watchlists, and the download never contains one.
- If ./quant-terminal exists, has no server.js and isn't empty, ask me before using it.
- macOS, Linux or Git Bash:
    mkdir -p quant-terminal && curl -fsSL -o quant-terminal.tar.gz https://github.com/HandsomeWJ/quant-terminal/archive/refs/heads/main.tar.gz && tar -xzf quant-terminal.tar.gz --strip-components=1 -C quant-terminal && rm quant-terminal.tar.gz
- Windows PowerShell:
    New-Item -ItemType Directory -Force quant-terminal | Out-Null
    curl.exe -fsSL -o "$env:TEMP\quant-terminal.zip" https://github.com/HandsomeWJ/quant-terminal/archive/refs/heads/main.zip
    & "$env:SystemRoot\System32\tar.exe" -xf "$env:TEMP\quant-terminal.zip" --strip-components=1 -C quant-terminal
- Windows cmd:
    if not exist quant-terminal mkdir quant-terminal
    curl.exe -fsSL -o "%TEMP%\quant-terminal.zip" https://github.com/HandsomeWJ/quant-terminal/archive/refs/heads/main.zip
    "%SystemRoot%\System32\tar.exe" -xf "%TEMP%\quant-terminal.zip" --strip-components=1 -C quant-terminal
- On Windows, call Windows' own tar.exe by its full path as shown: it reads zip files, and the tar that comes with Git doesn't. Windows 10 (version 1803 or later) and 11 come with curl.exe and tar.exe.
- In Windows PowerShell 5, chain commands with ; not &&, and `curl` means Invoke-WebRequest (use curl.exe for real curl).
- You now have a quant-terminal folder. Check it has server.js and package.json, and run every command below from inside it.

STEP 3 OF 5: TEST IT
Run `node scripts/check.js`. It runs the offline tests, checks which public data sources this connection can reach, starts the app briefly and loads live data, then ends with a Summary and one last line: READY or NOT READY. Only that last line counts; the data-source check in the middle prints its own READY line and an npm hint, so ignore those.
- READY: tell me in one line which sources work, from the line that says "crypto via ..., stocks via ...", for example "Binance live, US stocks through Nasdaq". If Binance is blocked or Yahoo is rate limiting, say in one line that the app falls back to other sources automatically.
- NOT READY: find the FAIL step in the Summary, read that step's output above it, fix the cause and run it again.
- Use `node scripts/...` rather than `npm run ...` throughout. On Windows, PowerShell's execution policy can block npm; node works everywhere.

STEP 4 OF 5: MAKE IT MINE
If this was an update, skip this step: my watchlist and charts are already saved. Go straight to step 5.
Ask me these one at a time:
1. "What do you mostly trade: crypto, US stocks, forex, or a mix?"
2. "Which symbols do you want on your watchlist? Say 'you pick' and I'll choose."
Defaults (use them if I say "you pick" or you can't ask):
- crypto: BTCUSDT, ETHUSDT, SOLUSDT, XRPUSDT, BNBUSDT, DOGEUSDT, LINKUSDT, AVAXUSDT
- US stocks: SPY, QQQ, AAPL, NVDA, MSFT, TSLA, AMZN, META
- forex: EURUSD, GBPUSD, USDJPY, AUDUSD, USDCAD, USDCHF
- a mix, or no answer: BTCUSDT, ETHUSDT, SOLUSDT, SPY, QQQ, NVDA, AAPL, EURUSD
If I name coins, add USDT to each (BTC becomes BTCUSDT), so a coin isn't mistaken for a US stock with the same ticker. Then run:
node scripts/setup.js --watchlist "<the symbols, comma separated>" --symbol <the first symbol> --tf <4h for crypto or forex, 1D for stocks or a mix>
Keep the quotes around the list, and write the timeframe exactly as 4h or 1D: capitals matter. It skips any symbol the public data sources don't have and says so. Tell me if it skipped any, and if it skipped the first one, run it again with the first symbol that worked as --symbol. If it skipped every symbol, that's a network problem, not my list: fix it and run setup again, so I don't end up with an empty watchlist.

STEP 5 OF 5: OPEN IT
Run `node scripts/launch.js`. It starts the terminal in the background, so it keeps running after this chat ends, and opens my browser. If your commands run inside a sandbox, run this one outside it or hand it to me, so the app doesn't keep the sandbox's limits after this chat ends. Give me the address it prints as a link. If no browser opened (a server, a container or WSL), tell me to open that address myself.

Finish with one short, friendly message in plain words, covering only this:
- It's running at <address>.
- Try first: start typing any symbol to switch chart, add as many indicators as you like, switch the layout to 4 charts, press Replay, then open the Strategy tester tab at the bottom.
- Next time: run `node scripts/launch.js` in the quant-terminal folder; it reuses a copy that's already running. Double-clicking start.command (Mac) or start.bat (Windows) also works, but it runs in a window you keep open, so only use it when the app isn't already running. Stop it with `node scripts/stop.js`.
- My charts, watchlists, alerts and paper account live in the data folder inside quant-terminal, and indicators I make live in the custom folder. To update the app later, paste this same prompt again; it keeps both.
- Want something it doesn't do? Ask me in this chat, for example "mark the London open on my charts", "email me when an alert fires", or "add an indicator that marks three green candles in a row". Custom indicators go in the custom folder.
- What it can't do: alerts only run while this computer is on and the app is running, intraday US stock history is short on the public data sources, and it never trades real money: paper trading only, with no broker connection.
```
