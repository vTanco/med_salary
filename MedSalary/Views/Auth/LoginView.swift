import SwiftUI
import SwiftData
import AuthenticationServices

struct LoginView: View {
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    let onLogin: (User) -> Void
    let onGoToRegister: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // Logo
                    VStack(spacing: 8) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 60))
                            .foregroundStyle(.teal)
                        
                        Text("MedSalary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Calcula tu salario médico")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 24)
                    
                    // Social Login Buttons
                    VStack(spacing: 12) {
                        // Sign in with Apple
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 50)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                        Text("o")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    
                    // Email/Password Form
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Contraseña", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                    }
                    .padding(.horizontal, 24)
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    // Login Button
                    Button(action: attemptLogin) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Iniciar Sesión")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.teal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .disabled(isLoading)
                    
                    Spacer(minLength: 40)
                    
                    // Register link
                    HStack {
                        Text("¿No tienes cuenta?")
                            .foregroundStyle(.secondary)
                        Button("Regístrate") {
                            onGoToRegister()
                        }
                        .foregroundStyle(.teal)
                        .fontWeight(.semibold)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    private func attemptLogin() {
        showError = false
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, completa todos los campos"
            showError = true
            return
        }
        
        if let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) {
            if user.verificarPassword(password) {
                onLogin(user)
            } else {
                errorMessage = "Contraseña incorrecta"
                showError = true
            }
        } else {
            errorMessage = "Usuario no encontrado"
            showError = true
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return
            }
            
            let userId = appleIDCredential.user
            let email = appleIDCredential.email ?? "\(userId)@privaterelay.appleid.com"
            let fullName = [
                appleIDCredential.fullName?.givenName,
                appleIDCredential.fullName?.familyName
            ].compactMap { $0 }.joined(separator: " ")
            
            let socialResult = SocialAuthResult(
                email: email,
                name: fullName.isEmpty ? "Usuario Apple" : fullName,
                socialId: userId,
                provider: .apple
            )
            
            do {
                let user = try authService.findOrCreateUser(from: socialResult, in: modelContext)
                onLogin(user)
            } catch {
                errorMessage = "Error al iniciar sesión con Apple"
                showError = true
            }
            
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code != .canceled {
                errorMessage = "Error: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

#Preview {
    LoginView(
        onLogin: { _ in },
        onGoToRegister: { }
    )
    .modelContainer(for: User.self, inMemory: true)
}

