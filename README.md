# Neternels Builder

![codequality](https://api.codiga.io/project/23638/score/svg)
![codescore](https://api.codiga.io/project/23638/status/svg)
![codefactor](https://www.codefactor.io/repository/github/grm34/neternels-builder/badge)

## Usage

1. `git clone https://github.com/grm34/Neternels-Builder.git`
2. `cd Neternels-Builder`
3. Edit [config](https://github.com/grm34/Neternels-Builder/blob/main/config) to set your settings (optional)
4. ` bash Neternels-Builder`

## Options

    Usage: bash Neternels-Builder [OPTION] [ARGUMENT]

    Options
        -h, --help                     show this message and exit
        -u, --update                   update script and toolchains
        -m, --msg     [message]        send message on Telegram
        -f, --file    [file]           send file on Telegram
        -z, --zip     [Image.gz-dtb]   create flashable zip

## Working structure

    Neternels-Builder/
    |
    |---- builds/               # Flashable kernel zips
    |     |---- DEVICE1/
    |     |---- DEVICE2/
    |
    |---- logs/                 # Compilation build logs
    |     |---- DEVICE1/
    |     |---- DEVICE2/
    |
    |---- out/                  # Kernel working directories
    |     |---- DEVICE1/
    |     |---- DEVICE2/

## Staying Up-To-Date


1. Fork Neternels-Builder repo on GitHub

2. `git clone https://github.com/<yourname>/Neternels-Builder`

3. `git remote add upstream https://github.com/grm34/Neternels-Builder`

4. `git checkout -b <devicename>`

5. Set up your <devicename> [config](https://github.com/grm34/Neternels-Builder/blob/main/config) then commit those changes

6. `git push --set-upstream origin <devicename>`

7. `git checkout main` then repeat steps 4-6 for any other devices you support

Then you should be able to `git pull upstream main` from your main branch and either merge or cherry-pick the new Neternels-Builder commits into your device branches as needed.
