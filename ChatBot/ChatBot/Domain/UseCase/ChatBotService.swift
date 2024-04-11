import Foundation

final class ChatBotService {
    private let networkService: NetworkService
    private let decorder: JSONDecoder = JSONDecoder()
    
    init(networkService: NetworkService)
    {
        self.networkService = networkService
    }
    
    func post(messages: [Message]) async throws-> [Message] {
        let data = try await networkService.request(.chat(messages: messages))
        return try messages + decorder.decode(ChatBotResponseDTO.self, from: data).toMessages()
    }
}

