import Foundation

class ChatRoomViewModel: ViewModel {
    struct Input {
        var send: (Message)->Void
    }
    struct Output {
        var didChangeMessages: (([Message])->Void)?
        var didOccurError: ((String)->Void)?
    }
    
    private let chatBotService: ChatBotService
    private var output: Output?
    private var messages: [Message] = [] {
        didSet {
            output?.didChangeMessages?(messages)
        }
    }
    private var errorMessage: String = "" {
        didSet {
            output?.didOccurError?(errorMessage)
        }
    }
    @MainActor lazy var input = Input { [weak self] message in
        self?.messages += [message]
        self?.postChat(message: message)
    }
    
    init(chatBotService: ChatBotService) {
        self.chatBotService = chatBotService
    }
}

extension ChatRoomViewModel {
    @MainActor private func postChat(message: Message) {
        Task {
            do {
                messages = try await chatBotService.post(messages: messages + [message])
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func bindOutput(output: Output) {
        self.output = output
    }
}
