//
//  JMDictionary.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 28/08/2024.
//

import SQLite
import Foundation

struct JMDictionaryEntry {
    let id: Int
    let kanji: [String]
    let readings: [String]
    let meanings: [String]
    let position: [String]
}

class JMDictionary {
    
    private var db: Connection?
    private let entriesTable = Table("entry")

    private let id = Expression<Int>("id")
    private let kanji = Expression<String>("kanji")
    private let reading = Expression<String>("reading")
    private let gloss = Expression<String>("gloss")
    private let position = Expression<String>("position")

    init() {
        /// Load the database from the app bundle
        if let dbPath = Bundle.main.path(forResource: "JMDict", ofType: "db") {
            do {
                db = try Connection(dbPath)
            } catch {
                print("Unable to open database: \(error)")
            }
        } else {
            print("Database file not found in bundle.")
        }
    }

    func lookup(_ word: String) -> [JMDictionaryEntry] {
        guard let db = db else { return [] }
        var results: [JMDictionaryEntry] = []

        do {
            let query = entriesTable.filter(
                kanji.like("\(word)") ||
                /// For cases when kanji in a word has multiple forms. Example: 食べる, 喰べる
                (kanji.like(" %\(word),%")) ||
                /// For cases when input word is written with kana. Example: おおきい (input) - 大きい
                reading.like("\(word)") ||
                /// For cases when input word is written with kana and has multiple forms (with ",").  Example: にゃんこ, ニャンコ
                /// Check if kani is empty. We don't want to grab input word as reading of any word, but as word that doesn't have kanji.
                (kanji.length == 0 && (
                    reading.like("\(word)") || 
                    reading.like("\(word),%") ||
                    reading.like("%, \(word)") ||
                    reading.like("%, \(word),%")
                ))
            )
            
            for entry in try db.prepare(query) {
                let entryID = entry[id]
                let kanjiList = entry[kanji].components(separatedBy: ", ")
                let readingsList = entry[reading].components(separatedBy: ", ")
                let meaningsList = entry[gloss].components(separatedBy: ", ")
                let positionList = entry[position].components(separatedBy: ", ")

                results.append(JMDictionaryEntry(id: entryID, kanji: kanjiList, readings: readingsList, meanings: meaningsList, position: positionList))
            }
        } catch {
            print("Query failed: \(error)")
        }

        return results
    }
}

