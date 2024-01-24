import os, strformat
import illwill
import auth/auth

type
  AppState = enum
    MainMenu, UserActionMenu

var
  userInfo: UserInfo
  newSelected = 0 


var choices = ["Download all a user's post", "Monitor a user's live" , "Like all a user's post", "Unlike all a user's post"]
var selected = 0
var state = MainMenu
var actionChosen: string
let versionNumber = "0.0.1"
let maintainersRepo = "https://github.com/agnosto/fansly-scraper"

proc getConfigPath(): string =
  let homeDir = getHomeDir()
  var configPath: string
  configPath = joinPath(homeDir, ".config", "fansly-scraper", "config.json")
  return configPath

let configPath = getConfigPath()

proc loadUserInfo(configPath: string): UserInfo =
  try:
    let authConfig = readAuthConfig(configPath)
    return getUserInfo(authConfig)
  except IOError, ValueError:
    echo fmt"Failed to load user information. Please check your config file. {configPath}"
    quit(1)

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc main() =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()

  checkForConfig(configPath)

  userInfo = loadUserInfo(configPath)
  let authConfig = readAuthConfig(configPath)
  let followedModels = getFollowedModels(authConfig, userInfo.id)

  var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
  while true:
    tb.clear()

    case state
    of MainMenu:

      tb.setForegroundColor(fgYellow)
      tb.drawRect(0, 0, tb.width-1, tb.height-1)

      tb.setForegroundColor(fgGreen, bright=true)
      tb.write(1, 1, "Config Path: " & configPath)
      tb.write(1, 2, fmt"Fansly scraper Version {versionNumber}")
      tb.setForegroundColor(fgMagenta, bright=true)
      tb.write(1, 3, fmt"Maintainers repo:  {maintainersRepo}")
      tb.setForegroundColor(fgBlue, bright=true)
      tb.write(1, 5, fmt"Welcome {userInfo.displayName} | {userInfo.username}")
      tb.write(1, 6, fmt"What would you like to do? {choices[selected]}")

      for i in 0 ..< len(choices):
        let choice = choices[i]
        if i == selected:
          tb.setForegroundColor(fgYellow, bright=true)
          tb.write(1, 8 + i, "> " & choice)  
        else:
          tb.setForegroundColor(fgWhite)
          tb.write(1, 8 + i, "  " & choice) 

      tb.resetAttributes()
      tb.write(1, tb.height - 1, "Press Esc or Ctrl-C to quit")
      tb.display()
  
      let key = getKey()
      case key
      of Key.Up:
        dec(selected)
        if selected < 0:
          selected = choices.high
      of Key.Down:
        inc(selected)
        if selected > choices.high:
          selected = 0
      of Key.Enter:
        case choices[selected]:
          of "Download all a user's post":
            actionChosen = choices[selected]
            state = UserActionMenu  # Change state to display the new menu
      of Key.Escape:
        exitProc()
      else:
        discard

    of UserActionMenu:
      # Display the new menu or update the display for user input
      
      tb.setForegroundColor(fgYellow)
      tb.drawRect(0, 0, tb.width-1, tb.height-1)
      tb.setForegroundColor(fgBlue, bright=true)
      tb.write(1, 1, fmt"Welcome {userInfo.displayName} | {userInfo.username}")
      tb.write(1, 2, fmt"Who would you like to scrape? {followedModels[newSelected].username}")


  
      # Calculate the start index for the list of models
      var startIndex = newSelected - (tb.height div 2)
      if startIndex < 0:
        startIndex = 0
      elif startIndex > followedModels.high - (tb.height - 7):
        startIndex = max(0, followedModels.high - (tb.height - 7))

      # Display the models starting from the start index
      for i, model in followedModels:
        if i >= startIndex and i < startIndex + (tb.height - 6):
          if i == newSelected:
            tb.setForegroundColor(fgYellow, bright=true)
            tb.write(1, 4 + i - startIndex, "> " & fmt"{model.username} | images: {model.imageCount} | videos: {model.videoCount}")
          else:
            tb.setForegroundColor(fgWhite)
            tb.write(1, 4 + i - startIndex, fmt"  {model.username} | images: {model.imageCount} | videos: {model.videoCount}")

      tb.resetAttributes()
      tb.write(1, tb.height - 1, "Press Esc or Ctrl-C to quit")
      tb.display()

      let key = getKey()
      case key
      of Key.Up:
        dec(newSelected)
        if newSelected < 0:
          newSelected = followedModels.high
      of Key.Down:
        inc(newSelected)
        if newSelected > followedModels.high:
          newSelected = 0
      of Key.Enter:
        # Temp print statement for testing
        echo "You selected: " & followedModels[newSelected].username
      of Key.Escape:
        exitProc()
      else:
        discard

   

    

    sleep(20)

main()
