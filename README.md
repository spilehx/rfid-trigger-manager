
<div align="center" width="100%">
    <img src="https://raw.githubusercontent.com/spilehx/rfid-trigger-manager/main/docs/assets/text-logo.png" width="900" alt="" />
</div>


## Summary
An application to trigger playing music or any other action from RFID tags

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

Still very much work in progress.


### To run
*Requires Hashlink to run currently*
*Knowledge of haxe required*
*Currently depends on mpv an yt-dlp but if you use the docker compose in the project, i handle this - but then you need to map your own audio, this should normally work fine, with blutooth speakers YMMV*

- Pull repo and build with ``haxe build.hxml``
- Enter the dist folder and run ``hl RFIDTriggerServer.hl``
- command line options avalible ``hl RFIDTriggerServer.hl --help``
- Open a browser to http://localhost:1337




---
### Inspired by the fantastic https://github.com/MiczFlor/RPi-Jukebox-RFID but fully reimagined in [haxe](https://haxe.org/)
