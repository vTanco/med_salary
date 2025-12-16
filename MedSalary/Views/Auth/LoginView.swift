import SwiftUI
import SwiftData

struct LoginView: View {
    @Query private var users: [User]
    
    let onLogin: (User) -> Void
    let onGoToRegister: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
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
                .padding(.bottom, 32)
                
                // Form
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
                }
                
                // Login Button
                Button(action: attemptLogin) {
                    Text("Iniciar Sesión")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.teal)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
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
}

#Preview {
    LoginView(
        onLogin: { _ in },
        onGoToRegister: { }
    )
    .modelContainer(for: User.self, inMemory: true)
}
