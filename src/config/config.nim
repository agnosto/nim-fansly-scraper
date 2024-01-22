import os, osproc, std/strutils

proc handleConfigFile*(configPath: string) =
  let exampleConfigPath = "./example-config.json"
  let repoUrl = "https://github.com/agnosto/fansly-scraper/blob/master/example-config.json" # Replace with actual repo URL

  # Check if the config file exists
  if not fileExists(configPath):
    # Check if the example config file exists in the project root or the current directory
    if fileExists(exampleConfigPath):
      # Copy the example config file to the config path
      copyFile(exampleConfigPath, configPath)
    else:
      # Download the example config file from the repo
      discard execCmd("curl -L -o $1 $2" % [$exampleConfigPath, repoUrl])
      # Copy the downloaded file to the config path
      copyFile(exampleConfigPath, configPath)

  # Open the config file in the default editor or vim if no default editor is set
  let editor = getEnv("EDITOR")
  if editor.isEmptyOrWhitespace:
    discard execCmd("vim $1" % configPath)
  else:
    discard execCmd("$1 $2" % [editor, configPath])

