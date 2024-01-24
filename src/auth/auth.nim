import httpclient, json, os, osproc, std/strutils


proc checkForConfig*(configPath: string) =
  let exampleConfigPath = "./example-config.json"
  let repoUrl = "https://github.com/agnosto/fansly-scraper/blob/master/example-config.json" 

  # Check if the config file exists
  if not fileExists(configPath):
    # Check if the example config file exists in the current directory
    if fileExists(exampleConfigPath):
      # Copy the example config file to the config path
      copyFile(exampleConfigPath, configPath)
    else:
      # Download the example config file from the repo
      discard execCmd("curl -L -o $1 $2" % [$exampleConfigPath, repoUrl])
      # Copy the downloaded file to the config path
      copyFile(exampleConfigPath, configPath)


type AuthConfig* = tuple[authToken: string, userAgent: string]

# Define a procedure to read the auth token and user agent from the config
proc readAuthConfig*(configPath: string): AuthConfig =
  if not fileExists(configPath):
    raise newException(IOError, "Config file not found: " & configPath)

  let configFileContent = readFile(configPath)
  let configJson = parseJson(configFileContent)

  if not configJson.hasKey("auth-token") or not configJson.hasKey("user-agent"):
    raise newException(ValueError, "Config file is missing required fields.")

  return (
    authToken: configJson["auth-token"].getStr,
    userAgent: configJson["user-agent"].getStr
  )


type
  UserInfo* = object
    id*: string
    username*: string
    displayName*: string

proc getUserInfo*(authConfig: AuthConfig): UserInfo =
  let client = newHttpClient()
  client.headers = newHttpHeaders({
    "Authorization": authConfig.authToken,
    "User-Agent": authConfig.userAgent
  })

  let response = client.getContent("https://apiv3.fansly.com/api/v1/account/me?ngsw-bypass=true")
  let jsonResponse = parseJson(response)
  let account = jsonResponse["response"]["account"]

  return UserInfo(
    id: account["id"].getStr,
    username: account["username"].getStr,
    displayName: account["displayName"].getStr
  )

type
 FollowedModel* = object
    id*: string
    username*: string
    displayName*: string
    imageCount*: int
    videoCount*: int

proc getFollowedModels*(authConfig: AuthConfig, userId: string): seq[FollowedModel] =
 let client = newHttpClient()
 client.headers = newHttpHeaders({
    "Authorization": authConfig.authToken,
    "User-Agent": authConfig.userAgent
 })

 let response = client.getContent("https://apiv3.fansly.com/api/v1/account/" & userId & "/following?before=0&after=0&limit=200&offset=0")
 let jsonResponse = parseJson(response)

 var followedModels: seq[FollowedModel] = @[]
 var ids: seq[string] = @[]

 for account in jsonResponse["response"]:
    ids.add(account["accountId"].getStr)

 var attempts = 0
 const maxAttempts = 5
 while attempts < maxAttempts:
  try:
    let creatorResponse = client.getContent("https://apiv3.fansly.com/api/v1/account?ids=" & ids.join(",") & "&ngsw-bypass=true")
    let creatorsJsonResponse = parseJson(creatorResponse)

    for creator in creatorsJsonResponse["response"]:
       let model = FollowedModel(
         id: creator["id"].getStr,
         username: creator["username"].getStr,
         displayName: creator["displayName"].getStr,
         imageCount: creator["timelineStats"]["imageCount"].getInt,
         videoCount: creator["timelineStats"]["videoCount"].getInt
       )

       followedModels.add(model)
    break
  except HttpRequestError:
    attempts += 1
    sleep(5000)

 return followedModels