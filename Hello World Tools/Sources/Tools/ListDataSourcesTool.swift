import Foundation
import FoundationModels
import ChatCore

final class ListDataSourcesTool: Tool {
    let name = "ListDataSources"
    let description = "Lists available data sources that can be used for widgets"
    
    @Generable
    struct Arguments: Codable {}

    func call(arguments: Arguments) -> String {
        print("DEBUG: reteriving tools")
        
        return DataSourcesConfig.sources
            .map { key, info in "\(key): \(info.description)" }
            .joined(separator: "\n\n")
    }
}
