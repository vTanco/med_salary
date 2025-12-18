import SwiftUI
import SwiftData

struct PlantillasView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPlantillas: [PlantillaGuardia]
    
    let user: User
    
    @State private var showAddSheet = false
    @State private var plantillaToDelete: PlantillaGuardia?
    @State private var showDeleteConfirmation = false
    
    private var plantillas: [PlantillaGuardia] {
        allPlantillas.filter { $0.userId == user.id }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if plantillas.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(plantillas, id: \.id) { plantilla in
                            plantillaRow(plantilla)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        plantillaToDelete = plantilla
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Plantillas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPlantillaView(user: user)
            }
            .alert("Eliminar Plantilla", isPresented: $showDeleteConfirmation) {
                Button("Cancelar", role: .cancel) {
                    plantillaToDelete = nil
                }
                Button("Eliminar", role: .destructive) {
                    if let plantilla = plantillaToDelete {
                        deletePlantilla(plantilla)
                    }
                }
            } message: {
                if let plantilla = plantillaToDelete {
                    Text("¿Eliminar la plantilla \"\(plantilla.nombre)\"?")
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Sin plantillas")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Crea plantillas para añadir guardias frecuentes con un solo tap")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showAddSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Crear Plantilla")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.teal)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    private func plantillaRow(_ plantilla: PlantillaGuardia) -> some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: plantilla.tipo.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(colorForTipo(plantilla.tipo))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(plantilla.nombre)
                    .font(.headline)
                
                Text("\(plantilla.tipo.displayName) • \(plantilla.horas)h")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let hospital = plantilla.hospital, !hospital.isEmpty {
                    Text(hospital)
                        .font(.caption)
                        .foregroundStyle(.teal)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func colorForTipo(_ tipo: TipoGuardia) -> Color {
        switch tipo {
        case .laborable: return .orange
        case .festivo: return .purple
        case .noche: return .indigo
        }
    }
    
    private func deletePlantilla(_ plantilla: PlantillaGuardia) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        modelContext.delete(plantilla)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting plantilla: \(error)")
        }
        
        plantillaToDelete = nil
    }
}

// MARK: - Add Plantilla View
struct AddPlantillaView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let user: User
    
    @State private var nombre = ""
    @State private var tipoGuardia: TipoGuardia = .laborable
    @State private var horas: Int = 12
    @State private var hospital = ""
    
    private let horasOptions = [6, 8, 10, 12, 14, 16, 17, 24]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Nombre de la plantilla") {
                    TextField("Ej: Guardia UCI Viernes", text: $nombre)
                }
                
                Section("Tipo de guardia") {
                    Picker("Tipo", selection: $tipoGuardia) {
                        ForEach(TipoGuardia.allCases, id: \.self) { tipo in
                            Label(tipo.displayName, systemImage: tipo.icon).tag(tipo)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Duración") {
                    Picker("Horas", selection: $horas) {
                        ForEach(horasOptions, id: \.self) { h in
                            Text("\(h) horas").tag(h)
                        }
                    }
                }
                
                Section("Hospital (opcional)") {
                    TextField("Ej: Hospital La Paz", text: $hospital)
                }
            }
            .navigationTitle("Nueva Plantilla")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        savePlantilla()
                    }
                    .disabled(nombre.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func savePlantilla() {
        let plantilla = PlantillaGuardia(
            nombre: nombre,
            tipo: tipoGuardia,
            horas: horas,
            hospital: hospital.isEmpty ? nil : hospital,
            userId: user.id
        )
        
        modelContext.insert(plantilla)
        
        do {
            try modelContext.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            print("Error saving plantilla: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, PlantillaGuardia.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Dr. García", password: "1234")
    container.mainContext.insert(user)
    
    return PlantillasView(user: user)
        .modelContainer(container)
}
