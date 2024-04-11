
import Foundation

struct ChatBotResponseDTO: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let systemFingerprint: String
    let choices: [ChoiceDTO]
    let usage: UsageDTO

    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

struct ChoiceDTO: Decodable {
    let index: Int
    let message: MessageDTO
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct MessageDTO: Codable {
    let role: String
    let content: String
}

struct UsageDTO: Decodable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

extension ChatBotResponseDTO {
    func toMessages() -> [Message] {
        return self.choices.map { $0.message.toModel() }
    }
}

extension MessageDTO {
    init(from model: Message) {
        self.role = model.role.rawValue
        self.content = model.content
    }
    
    func toModel() -> Message {
        return .init(id: UUID(),
                     role: Role(rawValue: self.role),
                     content: self.content)
    }
}
