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
    @State private var irpfActual: Double = 15.0
    @State private var fuentesIngreso: [TempFuenteIngreso] = []
    @State private var showAddFuente = false
    
    private let totalSteps = 5 // CCAA, Categoria, Familiar, IRPF, Fuentes
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Progress
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { step in
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
                case 3:
                    stepIRPF
                case 4:
                    stepFuentesIngreso
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
            .sheet(isPresented: $showAddFuente) {
                AddFuenteIngresoSheet(onAdd: { nombre, importe in
                    fuentesIngreso.append(TempFuenteIngreso(nombre: nombre, importeAnual: importe))
                })
            }
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
    
    private var stepIRPF: some View {
        VStack(spacing: 16) {
            Image(systemName: "percent")
                .font(.system(size: 50))
                .foregroundStyle(.teal)
            
            Text("¿Qué porcentaje de IRPF tienes puesto?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Lo encontrarás en tu nómina actual")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("\(Int(irpfActual))%")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.teal)
                
                Slider(value: $irpfActual, in: 0...47, step: 1)
                    .tint(.teal)
                    .padding(.horizontal, 20)
                
                HStack {
                    Text("0%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("47%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 24)
            
            Text("Esto nos permitirá compararlo con el IRPF óptimo")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }
    
    private var stepFuentesIngreso: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.teal)
            
            Text("¿Tienes otras fuentes de ingreso?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Consultas privadas, docencia, guardias en privado...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if fuentesIngreso.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.5))
                    
                    Text("No has añadido ninguna fuente adicional")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Esto es opcional, puedes añadirlas después")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 24)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(fuentesIngreso) { fuente in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(fuente.nombre)
                                        .fontWeight(.medium)
                                    Text("\(Int(fuente.importeAnual))€/año")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    fuentesIngreso.removeAll { $0.id == fuente.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
            
            Button {
                showAddFuente = true
            } label: {
                Label("Añadir fuente de ingreso", systemImage: "plus")
                    .fontWeight(.medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.teal.opacity(0.1))
                    .foregroundStyle(.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
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
        perfil.irpfActualPorcentaje = irpfActual / 100.0 // Convertir a decimal
        
        modelContext.insert(perfil)
        user.perfil = perfil
        
        // Crear fuentes de ingreso
        for tempFuente in fuentesIngreso {
            let fuente = FuenteIngreso(
                nombre: tempFuente.nombre,
                importeAnual: tempFuente.importeAnual,
                perfilId: perfil.id
            )
            modelContext.insert(fuente)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving perfil: \(error)")
        }
        
        return perfil
    }
}

// MARK: - Temporary Model for Onboarding
struct TempFuenteIngreso: Identifiable {
    let id = UUID()
    let nombre: String
    let importeAnual: Double
}

// MARK: - Add Fuente Sheet
struct AddFuenteIngresoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onAdd: (String, Double) -> Void
    
    @State private var nombre = ""
    @State private var importe = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles") {
                    TextField("Nombre (ej: Consulta privada)", text: $nombre)
                    
                    HStack {
                        TextField("Importe anual bruto", text: $importe)
                            .keyboardType(.numberPad)
                        Text("€/año")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Text("Añade aquí ingresos adicionales como consultas privadas, docencia, guardias en hospitales privados, etc.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Nueva Fuente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Añadir") {
                        if let importeDouble = Double(importe), !nombre.isEmpty {
                            onAdd(nombre, importeDouble)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(nombre.isEmpty || Double(importe) == nil)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, PerfilUsuario.self, FuenteIngreso.self, configurations: config)
    let user = User(email: "test@test.com", name: "Test", password: "1234")
    container.mainContext.insert(user)
    
    return OnboardingView(user: user) { }
        .modelContainer(container)
}

