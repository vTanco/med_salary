import SwiftUI
import SwiftData

/// Vista para configurar y ver el porcentaje de IRPF actual del usuario
struct IRPFConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let perfil: PerfilUsuario
    
    @State private var irpfPorcentaje: Double
    @State private var showSaveConfirmation = false
    
    init(perfil: PerfilUsuario) {
        self.perfil = perfil
        _irpfPorcentaje = State(initialValue: (perfil.irpfActualPorcentaje ?? 0.15) * 100)
    }
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Text("\(Int(irpfPorcentaje))%")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.teal)
                    
                    Slider(value: $irpfPorcentaje, in: 0...47, step: 1)
                        .tint(.teal)
                    
                    HStack {
                        Text("0%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("47%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Tu IRPF Actual")
            } footer: {
                Text("Este es el porcentaje de IRPF que tienes configurado en tu nómina actual. Lo puedes encontrar en la parte de retenciones de tu última nómina.")
            }
            
            Section("Información") {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("¿Por qué es importante?")
                            .fontWeight(.medium)
                        Text("Conocer tu IRPF actual nos permite compararlo con el óptimo según tus ingresos totales y darte recomendaciones.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Consejo")
                            .fontWeight(.medium)
                        Text("Si tu IRPF actual es menor que el óptimo, podrías tener que pagar en la declaración de la renta. Si es mayor, recibirás devolución pero cobrarás menos neto mensualmente.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Mi % IRPF")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    saveChanges()
                }
                .fontWeight(.semibold)
            }
        }
        .alert("¡Guardado!", isPresented: $showSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Tu porcentaje de IRPF se ha actualizado correctamente.")
        }
    }
    
    private func saveChanges() {
        perfil.irpfActualPorcentaje = irpfPorcentaje / 100.0
        
        do {
            try modelContext.save()
            showSaveConfirmation = true
        } catch {
            print("Error saving IRPF: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, PerfilUsuario.self, configurations: config)
    
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3)
    perfil.irpfActualPorcentaje = 0.18
    container.mainContext.insert(perfil)
    
    return NavigationStack {
        IRPFConfigView(perfil: perfil)
    }
    .modelContainer(container)
}
