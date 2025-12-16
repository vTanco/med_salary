import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var email: String
    var name: String
    var passwordHash: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Guardia.user)
    var guardias: [Guardia]?
    
    @Relationship(deleteRule: .cascade, inverse: \PerfilUsuario.user)
    var perfil: PerfilUsuario?
    
    init(email: String, name: String, password: String) {
        self.id = UUID()
        self.email = email.lowercased()
        self.name = name
        self.passwordHash = password // En producción usar hash real
        self.createdAt = Date()
    }
    
    func verificarPassword(_ password: String) -> Bool {
        return self.passwordHash == password
    }
}
