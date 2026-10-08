# PiPlex: Real-Time Japanese Text Translation for iOS
PiPlex is iOS application designed to enhance Japanese language learning through real-time dictionary lookups via PiP (Picture-in-Picture) window as an on-screen translation lense

https://github.com/user-attachments/assets/2a63f4ab-a2b9-42fb-a0a1-178d0f066c0b
***

## Key Features

-   Screen capture via broadcast upload extension
-   PiP window detection using ArUco markers
-   Real-time Japanese text recognition
-   Overlay of original text and translations on PiP content
-   Japanese tokenization with MeCab (IPADic or UNIDic)
-   Dictionary lookups using JMDict (SQLite-based)
-   Simulated transparency effect for PiP window

## For Future

-   Multi-language support using Apple's Translation API
-   Performance optimization
-   Context-aware translation improvements
-   Customizable PiP window settings
-   Japanese learning features:
    -   Translation saving with screen frames
    -   Anki card creation from PiP content

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
