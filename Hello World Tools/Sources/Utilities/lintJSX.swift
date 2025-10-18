//
//  LintJsx.swift
//  Hello World Tools
//
//  Created by Felix Hageloh on 25/08/2025.
//

import Foundation

func lintJSX(source: String) -> String? {
    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = [
        "-lc",
        "npx eslint --quiet --stdin -c '/Users/mike/Documents/hwt/Hello World Tools/eslint.config.mjs",
    ]

    let inPipe = Pipe()
    let outPipe = Pipe()
    task.standardInput = inPipe
    task.standardOutput = outPipe
    task.standardError = outPipe

    task.launch()

    // Feed code into stdin
    if let data = source.data(using: .utf8) {
        inPipe.fileHandleForWriting.write(data)
    }
    inPipe.fileHandleForWriting.closeFile()

    task.waitUntilExit()

    let output = outPipe.fileHandleForReading.readDataToEndOfFile()
    
    return output.isEmpty
        ? nil
        : String(data: output, encoding: .utf8)
}
