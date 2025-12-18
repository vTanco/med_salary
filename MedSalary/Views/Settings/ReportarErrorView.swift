import SwiftUI
import SwiftData

/// Vista para que los usuarios reporten errores en las cifras salariales
struct ReportarErrorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let user: User
    
    @State private var selectedCCAA: ComunidadAutonoma
    @State private var selectedCategoria: CategoriaId
    @State private var descripcion = ""
    @State private var valorIncorrecto = ""
    @State private var valorCorrecto = ""
    @State private var showConfirmation = false
    @State private var showThankYou = false
    
    init(user: User) {
        self.user = user
        _selectedCCAA = State(initialValue: user.perfil?.ccaa ?? .madrid)
        _selectedCategoria = State(initialValue: user.perfil?.categoria ?? .mir1)
    }
    
    var body: some View {
        Form {
            // Información del error
            Section("¿Dónde está el error?") {
                Picker("Comunidad Autónoma", selection: $selectedCCAA) {
                    ForEach(ComunidadAutonoma.allCases, id: \.self) { ccaa in
                        Text(ccaa.displayName).tag(ccaa)
                    }
                }
                
                Picker("Categoría", selection: $selectedCategoria) {
                    ForEach(CategoriaId.allCases, id: \.self) { cat in
                        Text(cat.displayName).tag(cat)
                    }
                }
            }
            
            // Descripción
            Section {
                TextEditor(text: $descripcion)
                    .frame(minHeight: 100)
            } header: {
                Text("Descripción del error")
            } footer: {
                Text("Describe qué cifra es incorrecta y dónde la has encontrado (ej: 'El sueldo base de MIR-3 en Madrid no es correcto')")
            }
            
            // Valores (opcional)
            Section("Valores (opcional)") {
                HStack {
                    Text("Valor incorrecto")
                    Spacer()
                    TextField("Ej: 1500€", text: $valorIncorrecto)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    Text("Valor correcto")
                    Spacer()
                    TextField("Ej: 1650€", text: $valorCorrecto)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                }
            }
            
            // Información adicional
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.teal)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fuentes oficiales")
                            .fontWeight(.medium)
                        Text("Los datos de esta app provienen de documentos oficiales de cada CCAA. Si encuentras una discrepancia, agradecemos tu reporte.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Botón enviar
            Section {
                Button {
                    showConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Enviar Reporte", systemImage: "paperplane.fill")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Reportar Error")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Enviar Reporte", isPresented: $showConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Enviar") {
                submitReport()
            }
        } message: {
            Text("¿Confirmas que deseas enviar este reporte de error?")
        }
        .alert("¡Gracias!", isPresented: $showThankYou) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Tu reporte ha sido recibido. Revisaremos la información y actualizaremos los datos si es necesario.")
        }
    }
    
    private func submitReport() {
        let reporte = ReporteError(
            ccaa: selectedCCAA.displayName,
            categoria: selectedCategoria.displayName,
            descripcion: descripcion,
            valorIncorrecto: valorIncorrecto.isEmpty ? nil : valorIncorrecto,
            valorCorrecto: valorCorrecto.isEmpty ? nil : valorCorrecto
        )
        
        modelContext.insert(reporte)
        
        do {
            try modelContext.save()
            showThankYou = true
        } catch {
            print("Error saving report: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, PerfilUsuario.self, ReporteError.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Dr. García", password: "1234")
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3, user: user)
    user.perfil = perfil
    container.mainContext.insert(user)
    
    return NavigationStack {
        ReportarErrorView(user: user)
    }
    .modelContainer(container)
}
