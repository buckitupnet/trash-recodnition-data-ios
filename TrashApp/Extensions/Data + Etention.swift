//
//  Data + Etention.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 08.07.2022.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: String? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else { return nil }

        return prettyPrintedString
    }
}
