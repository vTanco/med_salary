import Foundation
import SwiftData

/// Proveedores de autenticación soportados
enum AuthProvider: String, Codable {
    case email = "email"
    case apple = "apple"
    case google = "google"
    case facebook = "facebook"
}

@Model
final class User {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var email: String
    var name: String
    var passwordHash: String?  // Opcional para usuarios sociales
    var createdAt: Date
    
    /// Proveedor de autenticación utilizado
    var authProviderRaw: String
    var authProvider: AuthProvider {
        get { AuthProvider(rawValue: authProviderRaw) ?? .email }
        set { authProviderRaw = newValue.rawValue }
    }
    
    /// ID único del proveedor social (Apple User ID, Google ID, Facebook ID)
    var socialId: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Guardia.user)
    var guardias: [Guardia]?
    
    @Relationship(deleteRule: .cascade, inverse: \PerfilUsuario.user)
    var perfil: PerfilUsuario?
    
    /// Inicializador para registro con email/contraseña
    init(email: String, name: String, password: String) {
        self.id = UUID()
        self.email = email.lowercased()
        self.name = name
        self.passwordHash = password // En producción usar hash real
        self.createdAt = Date()
        self.authProviderRaw = AuthProvider.email.rawValue
        self.socialId = nil
    }
    
    /// Inicializador para registro con proveedor social
    init(email: String, name: String, provider: AuthProvider, socialId: String) {
        self.id = UUID()
        self.email = email.lowercased()
        self.name = name
        self.passwordHash = nil  // Sin contraseña para usuarios sociales
        self.createdAt = Date()
        self.authProviderRaw = provider.rawValue
        self.socialId = socialId
    }
    
    func verificarPassword(_ password: String) -> Bool {
        guard let hash = self.passwordHash else { return false }
        return hash == password
    }
    
    /// Verifica si el usuario usa autenticación social
    var isSocialUser: Bool {
        return authProvider != .email
    }
}
