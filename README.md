
<div align="center" width="100%">
    <img src="https://raw.githubusercontent.com/spilehx/rfid-trigger-manager/main/docs/assets/text-logo.png" width="900" alt="" />
</div>



RFID Trigger Manager lets you turn ordinary RFID cards into (or hidden RFID tags) into  real-world shortcuts. Tap a card to start music, launch a playlist, start a home automation, or trigger a custom action. Just run it on a system connected to an RFID reader and use the a simple web interface to setup what your triggers do! 




### Table of Contents
 - **[Features](#features)**
 - **[Setup](#setup)**
   - **[Quick Start](#quick-start)**
   - **[RFID Readers and tags](#rfid-readers-and-tags)**
   - **[Web admin](#web-admin)**
   - **[Actions](#actions)**
   - **[Config and Files](#config-and-files)**
   - **[CLI](#cli)**
 - **[Extra Notes](#extra-notes)**
   - **[What could I use this for](#what-could-i-use-this-for)**
   - **[FAQ](#faq)**
 - **[Building from source](#building-from-source)**
 - **[Bugs issues and pull requests](bugs-issues-and-pull-requests)**
 

# Features
lorium ipsum

# Setup
lorium ipsum

## Quick Start
asdasd

## RFID Readers and tags
asdasd

## Web admin
asdasd

## Actions
asdasd

## Config and files
asdasdasd

## CLI
asdasdasd

# Extra Notes
asdadas

## What could I use this for
asdasd

## FAQ
asdasd

- Why make this silly thing
asdasd

- What is a haxe?
asdasd

# Building from source
asdasd

# Bugs issues and pull requests?
- known issues




####   Use old physical media such as old cassette tapes to play digital music
By placing small rfid tags in old cassette tapes, and running The Trigger manager on a small pc with reader in a box you can have a rack of cassets that actilly play music - beep to start, beep again to go to next track! You can even have 'Cassets' play internet radio or if you have a smart home setup why not get that barry white cassette to dim the lights before it starts playing.

#### Custom phyical triggers for a PC
- Got a passion for retro games? why not buy some old floppy disks and hide the RFID tags inside and then set them up to trigger games to start! - Wanna play Monkey Island, just pull out the floppy and beep it.
- Have regular automations or tasks you frequently do? Put a tag in a physical object and have them on your desk ready to go! Working from home? Put a tag on your beer can cooler - beep it, Teams and Outlook close and Steam opens.
- Do Table top games? put at tag in the base of that space marine!

#### Home automations
  If you have a system such as [Home Assistant](https://www.home-assistant.io/) Why not use physical objects to trigger things? Want the lights in the house to come on as its evening, just put [whatever random object with tag inside] on a shelf. 


### Just some random suggestions - Please let me know if you come up with a cool use cases


### Features 
 - Detect and use USB RFID readers
 - Web admin on port 1337
 - Looks for any connected RFID readers connected and allows you to choose one,
 - designed for a headless machine connected to a speaker,
 - when you scan a RFID you can assign an action (eg. play a youtube playlist, play a spotify playlist, web radio or call an endpoint),
 - When you add a youtube playlist it caches the files locally so play back is instant,
 - you can add your own spotify api credentials etc.
 - when you read the RFID again when its playing it will go to the next track,
 - you can upload cover art (in the web admin), which is served on a 'now playing' url http://localhost:1337/getimage
 - A minimal "currently playing" web page is available at http://localhost:1337/currentlyplaying if you want to show on a secondary display (this updates automatically without reloading).





# USAGE AND OPTIONS

    RFIDTriggerServer [OPTIONS] 


## General Options:
    --help  Display this help message and exit.
        -d      Runs in debug mode, so does not require sudo device detection deactivated.
        -p      [PATH] Sets the path to the datafolder, if not there will be created.




# USAGE AND OPTIONS

    RFIDTriggerServer [OPTIONS] 


## General Options:
    --help  Display this help message and exit.
        -d      Runs in debug mode, so does not require sudo device detection deactivated.
        -p      [PATH] Sets the path to the datafolder, if not there will be created.


### To run
*Requires Hashlink to run currently*
*Knowledge of haxe required*
*Currently depends on mpv an yt-dlp but if you use the docker compose in the project, i handle this - but then you need to map your own audio, this should normally work fine, with blutooth speakers YMMV*

Either:

[Download the latest release](https://github.com/spilehx/rfid-trigger-manager/releases) 


Or build from source:
- Pull repo and build with ``haxe build.hxml``
- Enter the dist folder and run ``hl RFIDTriggerServer.hl``
- command line options avalible ``hl RFIDTriggerServer.hl --help``
- Open a browser to http://localhost:1337

If you want to build a binary so you dont have to use hashlink
    - run ``docker compose -f docker-compose-build-release.yml up --build``
    - When this is complete you will find a 'release' folder with the output.




---
### Inspired by the fantastic https://github.com/MiczFlor/RPi-Jukebox-RFID but fully reimagined in [haxe](https://haxe.org/)
