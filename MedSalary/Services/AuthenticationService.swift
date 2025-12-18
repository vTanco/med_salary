import Foundation
import SwiftData
import AuthenticationServices
import LocalAuthentication

/// Errores de autenticación
enum AuthenticationError: LocalizedError {
    case userCancelled
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case biometricNotAvailable
    case biometricFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Autenticación cancelada"
        case .invalidCredentials:
            return "Credenciales inválidas"
        case .userNotFound:
            return "Usuario no encontrado"
        case .emailAlreadyExists:
            return "Ya existe una cuenta con este email"
        case .biometricNotAvailable:
            return "Face ID/Touch ID no disponible"
        case .biometricFailed:
            return "Autenticación biométrica fallida"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

/// Resultado de autenticación social
struct SocialAuthResult {
    let email: String
    let name: String
    let socialId: String
    let provider: AuthProvider
}

/// Servicio centralizado de autenticación
@MainActor
class AuthenticationService: NSObject, ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticating = false
    @Published var biometricType: LABiometryType = .none
    
    private var appleSignInContinuation: CheckedContinuation<SocialAuthResult, Error>?
    
    private override init() {
        super.init()
        checkBiometricType()
    }
    
    // MARK: - Biometric Authentication (Face ID / Touch ID)
    
    /// Verifica qué tipo de biometría está disponible
    func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }
    
    /// Nombre amigable del tipo de biometría
    var biometricTypeName: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        @unknown default:
            return "Biometría"
        }
    }
    
    /// Icono SF Symbol para el tipo de biometría
    var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        @unknown default:
            return "lock.fill"
        }
    }
    
    /// Verifica si la biometría está disponible
    var isBiometricAvailable: Bool {
        return biometricType != .none
    }
    
    /// Autentica usando Face ID o Touch ID
    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthenticationError.biometricNotAvailable
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Inicia sesión en MedSalary"
            )
            return success
        } catch let authError as LAError {
            switch authError.code {
            case .userCancel, .appCancel:
                throw AuthenticationError.userCancelled
            case .biometryNotAvailable, .biometryNotEnrolled:
                throw AuthenticationError.biometricNotAvailable
            default:
                throw AuthenticationError.biometricFailed
            }
        }
    }
    
    // MARK: - Sign in with Apple
    
    /// Inicia el flujo de Sign in with Apple
    func signInWithApple() async throws -> SocialAuthResult {
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
    }
    
    // MARK: - Google Sign-In (Placeholder)
    
    /// Inicia el flujo de Google Sign-In
    /// Nota: Requiere GoogleSignIn SDK configurado
    func signInWithGoogle() async throws -> SocialAuthResult {
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        // TODO: Implementar cuando se añada GoogleSignIn SDK
        // import GoogleSignIn
        // let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        // return SocialAuthResult(
        //     email: result.user.profile?.email ?? "",
        //     name: result.user.profile?.name ?? "",
        //     socialId: result.user.userID ?? "",
        //     provider: .google
        // )
        
        throw AuthenticationError.unknown(NSError(domain: "GoogleSignIn", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Google Sign-In requiere configuración adicional. Añade GoogleSignIn SDK via SPM."
        ]))
    }
    
    // MARK: - Facebook Login (Placeholder)
    
    /// Inicia el flujo de Facebook Login
    /// Nota: Requiere FacebookLogin SDK configurado
    func signInWithFacebook() async throws -> SocialAuthResult {
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        // TODO: Implementar cuando se añada FacebookLogin SDK
        // import FacebookLogin
        // let loginManager = LoginManager()
        // loginManager.logIn(permissions: ["email", "public_profile"], from: nil) { result, error in ... }
        
        throw AuthenticationError.unknown(NSError(domain: "FacebookLogin", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Facebook Login requiere configuración adicional. Añade FacebookLogin SDK via SPM."
        ]))
    }
    
    // MARK: - User Management
    
    /// Busca o crea un usuario desde autenticación social
    func findOrCreateUser(from result: SocialAuthResult, in context: ModelContext) throws -> User {
        // Buscar usuario existente por socialId
        let socialId = result.socialId
        let providerRaw = result.provider.rawValue
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.socialId == socialId && $0.authProviderRaw == providerRaw }
        )
        
        if let existingUser = try context.fetch(descriptor).first {
            return existingUser
        }
        
        // Buscar por email (podría existir con otro provider)
        let email = result.email.lowercased()
        let emailDescriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == email }
        )
        
        if let existingEmailUser = try context.fetch(emailDescriptor).first {
            // Actualizar usuario existente con nuevo provider social
            existingEmailUser.socialId = result.socialId
            existingEmailUser.authProviderRaw = result.provider.rawValue
            try context.save()
            return existingEmailUser
        }
        
        // Crear nuevo usuario
        let newUser = User(
            email: result.email,
            name: result.name,
            provider: result.provider,
            socialId: result.socialId
        )
        
        context.insert(newUser)
        try context.save()
        
        return newUser
    }
    
    /// Busca usuario para autenticación biométrica (último usuario logueado)
    func findLastLoggedInUser(in context: ModelContext) throws -> User? {
        let descriptor = FetchDescriptor<User>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthenticationService: ASAuthorizationControllerDelegate {
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                appleSignInContinuation?.resume(throwing: AuthenticationError.invalidCredentials)
                appleSignInContinuation = nil
                return
            }
            
            let userId = appleIDCredential.user
            let email = appleIDCredential.email ?? "\(userId)@privaterelay.appleid.com"
            let fullName = [
                appleIDCredential.fullName?.givenName,
                appleIDCredential.fullName?.familyName
            ].compactMap { $0 }.joined(separator: " ")
            
            let result = SocialAuthResult(
                email: email,
                name: fullName.isEmpty ? "Usuario Apple" : fullName,
                socialId: userId,
                provider: .apple
            )
            
            appleSignInContinuation?.resume(returning: result)
            appleSignInContinuation = nil
        }
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    appleSignInContinuation?.resume(throwing: AuthenticationError.userCancelled)
                default:
                    appleSignInContinuation?.resume(throwing: AuthenticationError.unknown(error))
                }
            } else {
                appleSignInContinuation?.resume(throwing: AuthenticationError.unknown(error))
            }
            appleSignInContinuation = nil
        }
    }
}
