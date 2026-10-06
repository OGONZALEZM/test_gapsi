import Foundation

struct AppConfiguration: Sendable {
    private static let infoKey = "RapidAPIKey"
    private static let placeholderKey = "your-rapidapi-key-here"

    let rapidAPIKey: String

    init(infoDictionary: [String: Any]? = Bundle.main.infoDictionary) throws(AppConfigurationError) {
        let key = (infoDictionary?[Self.infoKey] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !key.isEmpty, key != Self.placeholderKey else {
            throw .missingRapidAPIKey
        }
        rapidAPIKey = key
    }
}

enum AppConfigurationError: LocalizedError {
    case missingRapidAPIKey

    var errorDescription: String? {
        switch self {
        case .missingRapidAPIKey:
            "RapidAPIKey is not configured. Copy Config/Secrets.example.xcconfig to Config/Secrets.xcconfig and replace the placeholder with your RapidAPI key."
        }
    }
}
