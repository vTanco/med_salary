import SwiftUI
import SwiftData
import AuthenticationServices

struct RegisterView: View {
    let modelContext: ModelContext
    let onRegister: (User) -> Void
    let onGoToLogin: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundStyle(.teal)
                        
                        Text("Crear Cuenta")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Empieza a calcular tu salario")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 16)
                    
                    // Social Login Buttons
                    VStack(spacing: 12) {
                        // Sign in with Apple
                        SignInWithAppleButton(.signUp) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 50)
                        .cornerRadius(12)
                        
                        // Google Sign-In Button
                        Button(action: signInWithGoogle) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                                Text("Continuar con Google")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Facebook Login Button
                        Button(action: signInWithFacebook) {
                            HStack {
                                Image(systemName: "f.circle.fill")
                                    .font(.title2)
                                Text("Continuar con Facebook")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.23, green: 0.35, blue: 0.60))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
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
                    
                    // Form
                    VStack(spacing: 16) {
                        TextField("Nombre", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Contraseña", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
                        
                        SecureField("Confirmar Contraseña", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
                    }
                    .padding(.horizontal, 24)
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    // Register Button
                    Button(action: attemptRegister) {
                        Text("Crear Cuenta")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.teal)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Login link
                    HStack {
                        Text("¿Ya tienes cuenta?")
                            .foregroundStyle(.secondary)
                        Button("Inicia Sesión") {
                            onGoToLogin()
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
    
    private func attemptRegister() {
        showError = false
        
        // Validaciones
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, completa todos los campos"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            showError = true
            return
        }
        
        guard password.count >= 4 else {
            errorMessage = "La contraseña debe tener al menos 4 caracteres"
            showError = true
            return
        }
        
        // Crear usuario
        let newUser = User(email: email, name: name, password: password)
        modelContext.insert(newUser)
        
        do {
            try modelContext.save()
            onRegister(newUser)
        } catch {
            errorMessage = "Error al crear la cuenta"
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
                onRegister(user)
            } catch {
                errorMessage = "Error al registrarse con Apple"
                showError = true
            }
            
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code != .canceled {
                errorMessage = "Error: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func signInWithGoogle() {
        Task {
            do {
                let result = try await authService.signInWithGoogle()
                let user = try authService.findOrCreateUser(from: result, in: modelContext)
                await MainActor.run {
                    onRegister(user)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func signInWithFacebook() {
        Task {
            do {
                let result = try await authService.signInWithFacebook()
                let user = try authService.findOrCreateUser(from: result, in: modelContext)
                await MainActor.run {
                    onRegister(user)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, configurations: config)
    
    return RegisterView(
        modelContext: container.mainContext,
        onRegister: { _ in },
        onGoToLogin: { }
    )
}

