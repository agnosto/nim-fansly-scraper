# fansly-scraper

⚠ This is currently under active development, everything is still being planned out and tested. Feel free to create issues/pr's to assist in the creation of this project.

### A simple all in one fansly interaction tool.

The program will automatically move/download an example config into the config path from either the current directory or the github repo respectively, you will need to edit the config to run the program.

[todo](/docs/todo.md) will hold a list of things to do for the project, as well as act as a kind of roadmap. 

## Running the program

Running and building the program locally will require you to have the following installed:

- [nim](https://nim-lang.org/install.html)
- a C compiler such as [gcc](https://gcc.gnu.org/install/index.html) or [MinGW](https://sourceforge.net/projects/mingw/) (note: installing nim should ask if you want to install a compiler if you don't already have one.)

### Dependencies

- [illwill](https://github.com/johnnovak/illwill) - a crossplatform console library

### Running the program

To run the program after downloading the source code, run the following in the projects root:

```bash
nim r -d:ssl src/scraper.nim
```
> note: -d:ssl enables ssl support for the program allowing for requests to be handled

### Building the program

To compile the program into an executable, run the following in the projects root:

```bash
nim c -d:ssl src/scraper.nim
```

The initial run of the program will create a config file in the config directory, you will need to edit this file to run the program. Need are your fansly auth token and user-agent, you can get these from the browser after logging in to fansly.

## Get fansly account token
### Method 1:
1. Go to [fansly](https://fansly.com) and login and open devtools (ctrl+shift+i / F12)
2. In network request, type `method:GET api` and click one of the requests
3. Look under `Reques Headers` and look for `Authorization` and copy the value

### Method 2: 
1. Go to [fansly](https://fansly.com) and login and open devtools (ctrl+shift+i / F12)
2. Click on `Storage` and then `Local Storage`
3. Look for `session_active_session` and copy the `token` value

(images at a later date)

## Currently known issues

- Program can't run w/o the config present and configured
- Resizing window messes with the program display
- No actual features implimented yet 🤡
- The use of a.i. in writing the program 🤖 