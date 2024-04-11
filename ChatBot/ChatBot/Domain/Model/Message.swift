import Foundation

struct Message: Hashable {
    let id: UUID
    let role: Role
    let content: String
}

