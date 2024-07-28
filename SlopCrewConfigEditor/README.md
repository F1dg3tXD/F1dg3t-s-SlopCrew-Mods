# SlopCrewConfigEditor
A simple configuration editor for the SlopCrew BRC Multiplayer mod.

## How to install:
Install [SlopCrew](https://github.com/SlopCrew/SlopCrew/blob/main/docs/Install%20Guide.md#gogmanual-installs) via manual installation first.
Ensure the SlopCrew config file is at
`\BepInEx\config\SlopCrew.Plugin.cfg`.
This is where the config editor expects to find it by default.
Launch the game with SlopCrew installed to make sure that it is working.
Place EditSlopCrewConfig.exe from the releases tab next to Bomb Rush Cyberfunk.exe in your game folder.
Launch it and set up SlopCrew as you want.

## Building from source:
Download the source code using the green button on this repository.
Open Windows Powershell and CD into the repo directory.
Install PS2EXE by typing:
`Install-Module -Name PS2EXE -Scope CurrentUser`
Then use 
`ps2exe -inputFile EditSlopCrewConfig.ps1 -outputFile EditSlopCrewConfig.exe -iconFile slopcrewconfig.ico -noConsole`
to build the exe file.

## Editing
You can edit `EditSlopCrewConfig.ps1` to change where it looks for the config file, or change the look of the program.
you can test your program without building by running 
`.\EditSlopCrewConfig.ps1`
in PowerShell.
