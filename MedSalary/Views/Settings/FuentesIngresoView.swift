import SwiftUI
import SwiftData

/// Vista para gestionar las fuentes de ingreso adicionales del usuario
struct FuentesIngresoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allFuentes: [FuenteIngreso]
    
    let perfil: PerfilUsuario
    
    @State private var showAddSheet = false
    @State private var fuenteToEdit: FuenteIngreso?
    
    private var fuentes: [FuenteIngreso] {
        allFuentes.filter { $0.perfilId == perfil.id }
    }
    
    private var totalAnual: Double {
        fuentes.reduce(0) { $0 + $1.importeAnual }
    }
    
    var body: some View {
        List {
            if fuentes.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray.opacity(0.5))
                        
                        Text("No tienes fuentes de ingreso adicionales")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Añade aquí ingresos como consultas privadas, docencia, guardias en privado, etc.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showAddSheet = true
                        } label: {
                            Label("Añadir fuente", systemImage: "plus")
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
            } else {
                Section {
                    ForEach(fuentes) { fuente in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fuente.nombre)
                                    .fontWeight(.medium)
                                Text(formatCurrency(fuente.importeAnual) + "/año")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                fuenteToEdit = fuente
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundStyle(.teal)
                            }
                        }
                    }
                    .onDelete(perform: deleteFuentes)
                } header: {
                    Text("Mis Fuentes de Ingreso")
                } footer: {
                    HStack {
                        Text("Total ingresos adicionales:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(formatCurrency(totalAnual) + "/año")
                            .fontWeight(.bold)
                            .foregroundStyle(.teal)
                    }
                    .padding(.top, 8)
                }
            }
            
            Section("Información") {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("¿Por qué es importante?")
                            .fontWeight(.medium)
                        Text("Añadir tus fuentes de ingreso adicionales permite calcular con mayor precisión el IRPF óptimo que deberías tener.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Fuentes de Ingreso")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddFuenteSheet(perfilId: perfil.id)
        }
        .sheet(item: $fuenteToEdit) { fuente in
            EditFuenteSheet(fuente: fuente)
        }
    }
    
    private func deleteFuentes(at offsets: IndexSet) {
        for index in offsets {
            let fuente = fuentes[index]
            modelContext.delete(fuente)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting fuente: \(error)")
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return String(format: "%.0f€", value)
    }
}

// MARK: - Add Fuente Sheet
struct AddFuenteSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let perfilId: UUID
    
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
                    Text("Ejemplos: consultas privadas, docencia universitaria, guardias en hospitales privados, peritajes...")
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
                        addFuente()
                    }
                    .fontWeight(.semibold)
                    .disabled(nombre.isEmpty || Double(importe) == nil)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func addFuente() {
        guard let importeDouble = Double(importe), !nombre.isEmpty else { return }
        
        let fuente = FuenteIngreso(
            nombre: nombre,
            importeAnual: importeDouble,
            perfilId: perfilId
        )
        
        modelContext.insert(fuente)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error adding fuente: \(error)")
        }
    }
}

// MARK: - Edit Fuente Sheet
struct EditFuenteSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let fuente: FuenteIngreso
    
    @State private var nombre: String
    @State private var importe: String
    
    init(fuente: FuenteIngreso) {
        self.fuente = fuente
        _nombre = State(initialValue: fuente.nombre)
        _importe = State(initialValue: String(format: "%.0f", fuente.importeAnual))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles") {
                    TextField("Nombre", text: $nombre)
                    
                    HStack {
                        TextField("Importe anual bruto", text: $importe)
                            .keyboardType(.numberPad)
                        Text("€/año")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Editar Fuente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveFuente()
                    }
                    .fontWeight(.semibold)
                    .disabled(nombre.isEmpty || Double(importe) == nil)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveFuente() {
        guard let importeDouble = Double(importe), !nombre.isEmpty else { return }
        
        fuente.nombre = nombre
        fuente.importeAnual = importeDouble
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving fuente: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, PerfilUsuario.self, FuenteIngreso.self, configurations: config)
    
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .fea)
    container.mainContext.insert(perfil)
    
    // Add some sample data
    let fuente1 = FuenteIngreso(nombre: "Consulta privada", importeAnual: 12000, perfilId: perfil.id)
    let fuente2 = FuenteIngreso(nombre: "Docencia universidad", importeAnual: 5000, perfilId: perfil.id)
    container.mainContext.insert(fuente1)
    container.mainContext.insert(fuente2)
    
    return NavigationStack {
        FuentesIngresoView(perfil: perfil)
    }
    .modelContainer(container)
}
