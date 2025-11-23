

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
   - **[CLI](#cli)**
 - **[Extra Notes](#extra-notes)**
   - **[What could I use this for](#what-could-i-use-this-for)**
   - **[FAQ](#faq)**
 - **[Building from source](#building-from-source)**
 - **[Bugs issues and pull requests](#bugs-issues-and-pull-requests)**
 
<br>
<br>

# Features
 - Detect and use USB RFID readers
 - **[Web admin](#web-admin)** on port 1337
 - Looks for any connected RFID readers connected and allows you to choose one,
 - designed for a headless machine connected to a speaker,
 - when you scan a RFID you can assign an action (eg. play a youtube playlist, play a spotify playlist, web radio or call an endpoint),
 - When you add a youtube playlist it caches the files locally so play back is instant,
 - you can add your own spotify api credentials etc.
 - when you read the RFID again when its playing it will go to the next track,
 - you can upload cover art (in the web admin), which is served on a 'now playing' url http://localhost:1337/getimage
 - A minimal "currently playing" web page is available at http://localhost:1337/currentlyplaying if you want to show on a secondary display (this updates automatically without reloading).

---
<br>
<br>

# Setup
*The aim of this project was to make setup and use as easy as possible, if you find it a challenge or have suggestions to make it easier, please [raise a bug!](#bugs-issues-and-pull-requests)*

## Quick Start
 - Ensure you have your [RFID reader connected and some tags ready](#rfid-readers-and-tags)
 - Go to the [releases section of this repo and download](https://github.com/spilehx/rfid-trigger-manager/releases/latest) the newest release executable for your OS and system
 - Locate the downloaded file in your downloads folder on your system and move to a nice location *(Suggestion: Make a nice new folder in your user files for it. It will be saving files and making config files, so lets keep things neat!)* 
 - Run the executable *(Note: For linux users, you may need to do a `chmod +x [FILE NAME]` to make it executable)*
 - Open a browser to http://localhost:1337 where you will see the **[Web admin](#web-admin)** panel and be directed to select your RFID device
 - Scan your first tag!
   - If scanning is successful you will see a new entry appear in the interface, if not check you have chosen the correct device and try again.
   - The first time a tag is scanned it will automatically be added to the system
   - For each tag in the system you can set a name, choose and **[action](#actions)**, add your command and upload an image if you want.
   - Click the play icon to test the trigger.
   - When you are happy, activate the tag with the tick box on the left.
   - Now every time you scan this tag it will trigger this **[action](#actions)**.

## RFID Readers and tags

RFID readers are very cheap and easy to buy, as are the tags, [have a look on amazon](https://amzn.eu/d/f5meZi6)

**Note: There IS a difference between RFID and NFC you want RFID**
I am planning to look at NFC tags soon, if you want that, [give me a nudge] (#bugs-issues-and-pull-requests)

This system just looks for raw data from input devices so *should* work on most normal devices - if you have any issues please [raise a bug!](#bugs-issues-and-pull-requests)

## Web admin
You found at http://localhost:1337, use this to setup your RFID device and your tag actions


## Actions
WIP - will update soon - have a play about!

## CLI

### USAGE AND OPTIONS

    RFIDTriggerServer [OPTIONS] 


### General Options:
    --help  Display this help message and exit.
        -d      Runs in debug mode, so does not require sudo device detection deactivated.
        -p      [PATH] Sets the path to the datafolder, if not there will be created.
---
---
<br>

# Extra Notes

## What could I use this for
**Use old physical media such as old cassette tapes to play digital music**

By placing small rfid tags in old cassette tapes, and running The Trigger manager on a small pc with reader in a box you can have a rack of cassettes that actually play music - beep to start, beep again to go to next track! You can even have 'cassettes' play internet radio or if you have a smart home setup why not get that Barry white cassette to dim the lights before it starts playing.

**Custom physical triggers for a PC**
 - Got a passion for retro games? why not buy some old floppy disks and hide the RFID tags inside and then set them up to trigger games to start! - Wanna play Monkey Island, just pull out the floppy and beep it.
 - Have regular automation or tasks you frequently do? Put a tag in a physical object and have them on your desk ready to go! Working from home? Put a tag on your beer can cooler - beep it, Teams and Outlook close and Steam opens.
 - Do Table top games? put at tag in the base of that space marine!

**Home automation**
  If you have a system such as [Home Assistant](https://www.home-assistant.io/) Why not use physical objects to trigger things? Want the lights in the house to come on as its evening, just put [whatever random object with tag inside] on a shelf. 


**Just some random suggestions - Please let me know if you come up with a cool use cases!**


## FAQ
**Q: Why make this silly thing**

**A:** I wanted to control my music and home automation with tags old cassettes and originally found the fantastic [RPi-Jukebox-RFID ](https://github.com/MiczFlor/RPi-Jukebox-RFID) but that solution didn't work for me: I didn't have a raspberry-pi to hand and wanted to run on an X86 machine I had and honestly it seemed over complicated - all that python venv stuff for such a simple thing, do I decided to create my own project that just had one executable file. Plus i want to extend it to do much more!

**Q: What is a haxe?**

**A:** Wonderful language that can output multiple targets, that's how i can code html and a C app in one code base! Very fun and powerful and the community is great! [Check it out for yourself](https://haxe.org/) 

---
---
<br>
<br>

# Building from source
- Pull repo and build with ``haxe build.hxml``
- Enter the dist folder and run ``hl RFIDTriggerServer.hl``
- command line options available ``hl RFIDTriggerServer.hl --help``
- Open a browser to http://localhost:1337

If you want to build a binary so you dont have to use hashlink
    - run ``docker compose -f docker-compose-build-release.yml up --build``
    - When this is complete you will find a 'release' folder with the output.


---
---
<br>
<br>

# Bugs issues and pull requests?
**YES PLEASE!!**

