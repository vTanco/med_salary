import SwiftUI
import SwiftData

struct RegisterView: View {
    let modelContext: ModelContext
    let onRegister: (User) -> Void
    let onGoToLogin: () -> Void
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
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
                .padding(.bottom, 24)
                
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
                
                Spacer()
                
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
