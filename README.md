## Changes from upstream
- Remove library Then and SwiftShield
... Obfuscation doesn't make sense on the open source version
... Then was broken when compiled in Xcode 13, this involved lots of rewriting and there may be some bugs
- Disabled Bitcode which will give far smaller IPA size
- Remove Network import to allow building for iOS 10+
- Images have been optimised and are slightly smaller
---
# FlappyBird

## Notes
* This is only the public source with missing features.
* The main repo will remain closed source because of Google Sign-In

This is an extremely close clone to the original FlappyBird by Dong Nguyen.

## Demo
<img src="demo/demo.gif" width="200">

## Compatibility
FlappyBird is compatible with the iPhone 6s and above on iOS 13 and later.
Compatible with watchOS 6.0 and above.

## Installation
The '.ipa' and '.deb' files for FlappyBird can be found on the [release page](https://github.com/brandonplank/flappybird/releases).

## License
- [MIT](https://choosealicense.com/licenses/mit/)
- Copyright (c) 2020 Brandon Plank
- Copyright (c) 2020 ThatcherDev

## Notice
We do not own most of the Flappy Bird assets, or the Flappy Bird name, some of the assets
were extracted straight from the game. They are the work and copyright of original 
creator Dong Nguyen and .GEARS games (http://www.dotgears.com/).

I took this Tweet (https://twitter.com/dongatory/status/431060041009856512 /
http://i.imgur.com/AcyWyqf.png) by Dong Nguyen, the creator of the game, as an open 
invitation to reuse the game concept and assets in an open source project. 
There is no intention to steal the game, or claim the Flappy Bird name as my own.

If the copyright holder would like for the assets to be removed, please open an 
issue to start the conversation.
