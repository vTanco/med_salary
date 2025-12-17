import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    let onComplete: () -> Void
    
    @State private var currentStep = 0
    @State private var selectedCCAA: ComunidadAutonoma = .madrid
    @State private var selectedCategoria: CategoriaId = .mir1
    @State private var selectedEstadoFamiliar: EstadoFamiliar = .general
    
    private let totalSteps = 3 // CCAA, Categoria, Familiar
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Progress
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.teal : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Content
                switch currentStep {
                case 0:
                    stepCCAA
                case 1:
                    stepCategoria
                case 2:
                    stepFamiliar
                default:
                    EmptyView()
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button("Atrás") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if currentStep < totalSteps - 1 {
                        Button("Siguiente") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .fontWeight(.semibold)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(.teal)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Button("Finalizar") {
                            completeOnboarding()
                        }
                        .fontWeight(.semibold)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(.teal)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("Configuración Inicial")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Steps
    
    private var stepCCAA: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.fill")
                .font(.system(size: 50))
                .foregroundStyle(.teal)
            
            Text("¿En qué Comunidad Autónoma trabajas?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Los salarios varían según la CCAA")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Picker("Comunidad Autónoma", selection: $selectedCCAA) {
                ForEach(ComunidadAutonoma.allCases, id: \.self) { ccaa in
                    Text(ccaa.displayName).tag(ccaa)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
        .padding(.horizontal, 24)
    }
    
    private var stepCategoria: some View {
        VStack(spacing: 16) {
            Image(systemName: "stethoscope")
                .font(.system(size: 50))
                .foregroundStyle(.teal)
            
            Text("¿Cuál es tu categoría profesional?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Picker("Categoría", selection: $selectedCategoria) {
                ForEach(CategoriaId.allCases, id: \.self) { cat in
                    Text(cat.displayName).tag(cat)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
        .padding(.horizontal, 24)
    }
    
    private var stepFamiliar: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 50))
                .foregroundStyle(.teal)
            
            Text("¿Cuál es tu situación familiar?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Esto afecta al cálculo del IRPF")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                ForEach(EstadoFamiliar.allCases, id: \.self) { estado in
                    Button {
                        selectedEstadoFamiliar = estado
                    } label: {
                        HStack {
                            Text(estado.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedEstadoFamiliar == estado {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.teal)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedEstadoFamiliar == estado ? Color.teal.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedEstadoFamiliar == estado ? Color.teal : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Actions
    
    private func completeOnboarding() {
        let _ = createPerfil()
        onComplete()
    }
    
    private func createPerfil() -> PerfilUsuario {
        let perfil = PerfilUsuario(
            ccaa: selectedCCAA,
            categoria: selectedCategoria,
            estadoFamiliar: selectedEstadoFamiliar,
            user: user
        )
        perfil.onboardingCompleto = true
        
        modelContext.insert(perfil)
        user.perfil = perfil
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving perfil: \(error)")
        }
        
        return perfil
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, PerfilUsuario.self, configurations: config)
    let user = User(email: "test@test.com", name: "Test", password: "1234")
    container.mainContext.insert(user)
    
    return OnboardingView(user: user) { }
        .modelContainer(container)
}
