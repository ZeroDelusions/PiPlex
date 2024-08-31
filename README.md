# PiPlex: Real-Time Japanese Text Translation for iOS
PiPlex is an innovative iOS application designed to enhance Japanese language learning through real-time dictionary lookups. Utilizing Picture-in-Picture (PiP) technology, the app provides instant translations for Japanese text displayed on your screen.

## Key Features

-   Screen capture via broadcast upload extension
-   PiP window detection using ArUco markers
-   Real-time Japanese text recognition
-   Japanese tokenization with MeCab (IPADic or UNIDic)
-   Dictionary lookups using JMDict (SQLite-based)
-   Overlay of original text and translations on PiP content
-   Color-coded display for parts of speech
-   Simulated transparency effect for PiP window

## Future Enhancements

-   Multi-language support using Apple's Translation API
-   Performance optimization
-   Context-aware translation improvements
-   Customizable PiP window settings
-   Japanese learning features:
    -   Translation saving with screen frames
    -   Anki card creation from PiP content

## Current Limitations

-   Japanese-only text recognition
-   Context-unaware dictionary lookups
-   Prototype-stage performance

## Dependencies

-   JMDict (SQLite conversion)
-   [Mecab-Swift](https://github.com/shinjukunian/Mecab-Swift)
-   [SQLite.swift](https://github.com/stephencelis/SQLite.swift)
-   [OpenCV](https://github.com/yeatse/opencv-spm)
-   [UIPiPView](https://github.com/uakihir0/UIPiPView/tree/main)

## Important Notes

Due to GitHub file size limitations, UNIDic and JMDict are not included in this repository. Please refer to the following resources:

-   [JMDict to SQLite conversion](https://github.com/Top-Ranger/jmdict-to-sqlite3/tree/master)
-   [UniDic download](https://clrd.ninjal.ac.jp/unidic/en/download_en.html)

When importing UniDic, ensure you add the folder as a reference with the name `unidic_dictionary`.
