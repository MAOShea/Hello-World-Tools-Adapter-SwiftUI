import Foundation

struct DataSource {
    let command: String
    let description: String
}

struct DataSourcesConfig {
    static let sources: [String: DataSource] = [
        "currentTime": DataSource(
            command: "date '+%H:%M:%S'",
            description: "Returns the current time in HH:MM:SS format"
        )
    ]
}
