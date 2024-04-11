import Foundation

extension Bundle {
    var chatBotAPIKey: String {
        guard let key = self.infoDictionary?["ChatBotAPIKey"] as? String else {
            fatalError("API Key를 찾을 수 없습니다.")
        }
        return key
    }
}
