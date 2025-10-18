//
//  Examples.swift
//  Hello World
//
//  Created by mike on 04/07/2025.
//

import Foundation

struct Examples {
    static let structuredPrompts = [
        "JSON": "Create a JSON object with user information including name, age, and email",
        "XML": "Generate an XML structure for a book with title, author, and publication year",
        "CSV": "Create a CSV format for a list of products with name, price, and category",
        "Code": "Write a Swift function that calculates the factorial of a number"
    ]
    
    static func getExamplePrompt(for type: String) -> String {
        return structuredPrompts[type] ?? "Generate some structured content"
    }
} 