//
//  File.swift
//  File
//
//  Created by waynezhang on 2021/08/23.
//

import Foundation
import ArgumentParser
import SafeInCloudSwift

struct SIC: ParsableCommand {

    @Argument(help: "SafeInCloud database file") var file: String
    @Argument(help: "Keyword to search") var keyword: String?

    func run() throws {
        let password = String(cString: getpass("Input password: "))
        let db = try SafeInCloudDatabase(filePath: file, password: password)

        guard let keyword = keyword?.lowercased() else {
            db.allCards.forEach(printCard(_:))
            return
        }

        db.allCards
            .filter { card in
                card.title.lowercased().contains(keyword) ||
                card.fields.first { field in
                    [Card.Field.FieldType.login, Card.Field.FieldType.website].contains(field.type) &&
                    field.name.lowercased().contains(keyword)
                } != nil
            }
            .forEach(printCard(_:))
    }

    private func printCard(_ card: Card) {
        print("\(card.title) (\(card.id))")
        card.fields.forEach { field in
            print("    - \(field.name): \(field.value)")
        }
    }
}

SIC.main()
