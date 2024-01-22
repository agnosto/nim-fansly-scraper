import std/terminal, std/strutils, std/strformat, os, pathnorm
import config/config

var choices = ["Download all a user's post", "Monitor a user's live" , "Like all a user's post", "Unlike all a user's post", "Edit config.json file", "Quit"]
var selected = 0
let versionNumber = "0.0.1"
let maintainersRepo = "https://github.com/agnosto/fansly-scraper"

proc styledEcho(text: string, fgColor: ForegroundColor, bgColor: BackgroundColor, highlighted: bool) =
 setForegroundColor(fgColor)
 setBackgroundColor(bgColor)
 if highlighted:
   echo ">", text
 else:
  echo text
 resetAttributes()

proc getConfigPath(): string =
  let homeDir = getHomeDir()
  var configPath: string
  case hostOs:
    of "windows":
     configPath = joinPath(homeDir, ".config", "fansly-scraper", "config.json")
    else:
     configPath = joinPath(homeDir, ".config", "fansly-scraper", "config.json")
  return configPath

let configPath = getConfigPath()


while true:
 eraseScreen()
 setCursorPos(0, 0)
 styledEcho(&"Config Path: {configPath}\nWelcome to scraper Version {versionNumber}\n", fgGreen, bgDefault, false)
 styledEcho(&"Maintainers repo: {maintainersRepo}\n\n", fgMagenta, bgDefault, false)
 echo "What would you like to do?"
 for i in 0..<choices.len:
    if i == selected:
      styledEcho(choices[i], fgCyan, bgDefault, true)
    else:
      styledEcho(choices[i], fgDefault, bgDefault, false)

 let key = getch().ord
 var seqBytes = @[key]
 if key == '\x1B'.ord:
    let nextChar = getch().ord
    if nextChar == '\x5B'.ord:
      let thirdChar = getch().ord
      seqBytes = @[key, nextChar, thirdChar]
      if seqBytes == @['\x1B'.ord, '\x5B'.ord, '\x41'.ord]:
        dec(selected)
        if selected < 0:
          selected = choices.high
      elif seqBytes == @['\x1B'.ord, '\x5B'.ord, '\x42'.ord]:
        inc(selected)
        if selected > choices.high:
          selected = 0
      elif seqBytes == @['\x1B'.ord, '\x5B'.ord, '\x43'.ord]:
        # Handle right arrow key press here if needed
        discard
      elif seqBytes == @['\x1B'.ord, '\x5B'.ord, '\x44'.ord]:
        # Handle left arrow key press here if needed
        discard
 elif seqBytes == @['\x0D'.ord]: # ASCII code for Enter key
    case choices[selected]:
      of "Edit config.json file":
        handleConfigFile(configPath)
      of "Quit":
        echo "Exiting the program."
        break
      else:
        echo "You selected: ", choices[selected]
    #break
