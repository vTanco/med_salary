import SwiftUI
import SwiftData

struct ExportPDFView: View {
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    
    @State private var selectedPeriod: PeriodOption = .currentMonth
    @State private var pdfData: Data?
    @State private var isGenerating = false
    @State private var showShareSheet = false
    
    enum PeriodOption: String, CaseIterable {
        case currentMonth = "Este mes"
        case lastMonth = "Mes anterior"
        case currentYear = "Este año"
        case all = "Todo el historial"
    }
    
    private var guardias: [Guardia] {
        user.guardias ?? []
    }
    
    private var filteredGuardias: [Guardia] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .currentMonth:
            let month = calendar.component(.month, from: now)
            let year = calendar.component(.year, from: now)
            return guardias.filter {
                calendar.component(.month, from: $0.fecha) == month &&
                calendar.component(.year, from: $0.fecha) == year
            }
            
        case .lastMonth:
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
            let month = calendar.component(.month, from: lastMonth)
            let year = calendar.component(.year, from: lastMonth)
            return guardias.filter {
                calendar.component(.month, from: $0.fecha) == month &&
                calendar.component(.year, from: $0.fecha) == year
            }
            
        case .currentYear:
            let year = calendar.component(.year, from: now)
            return guardias.filter {
                calendar.component(.year, from: $0.fecha) == year
            }
            
        case .all:
            return guardias
        }
    }
    
    private var exportPeriod: PDFExportService.ExportPeriod {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .currentMonth:
            return .month(now)
        case .lastMonth:
            return .month(calendar.date(byAdding: .month, value: -1, to: now) ?? now)
        case .currentYear:
            return .year(calendar.component(.year, from: now))
        case .all:
            return .all
        }
    }
    
    private var totalHoras: Int {
        filteredGuardias.reduce(0) { $0 + $1.horas }
    }
    
    private var totalBruto: Double {
        guard let perfil = user.perfil,
              let config = SalaryEngine.getConfig(ccaa: perfil.ccaa, categoria: perfil.categoria) else {
            return 0
        }
        
        return filteredGuardias.reduce(0.0) { total, guardia in
            total + Double(guardia.horas) * config.precioGuardia.precio(para: guardia.tipo)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.teal)
                    
                    Text("Exportar Informe")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Genera un PDF con tu historial de guardias")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Period Selector
                VStack(alignment: .leading, spacing: 12) {
                    Label("Periodo", systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Periodo", selection: $selectedPeriod) {
                        ForEach(PeriodOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Preview Stats
                VStack(alignment: .leading, spacing: 16) {
                    Label("Vista previa", systemImage: "eye")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 20) {
                        StatPreview(title: "Guardias", value: "\(filteredGuardias.count)")
                        StatPreview(title: "Horas", value: "\(totalHoras)h")
                        StatPreview(title: "Bruto", value: "\(Int(totalBruto))€")
                    }
                    
                    if filteredGuardias.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("No hay guardias en este periodo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Export Button
                Button {
                    generateAndSharePDF()
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "square.and.arrow.up.fill")
                        }
                        Text(isGenerating ? "Generando..." : "Generar y Compartir PDF")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(filteredGuardias.isEmpty ? Color.gray : Color.teal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(filteredGuardias.isEmpty || isGenerating)
                
                // Info
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    
                    Text("El PDF incluirá un listado de todas las guardias del periodo seleccionado con fecha, tipo, horas, hospital e importe estimado.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Exportar PDF")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(items: [pdfData])
            }
        }
    }
    
    private func generateAndSharePDF() {
        isGenerating = true
        let generator = UINotificationFeedbackGenerator()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let data = PDFExportService.generatePDF(
                user: user,
                period: exportPeriod,
                guardias: filteredGuardias
            )
            
            DispatchQueue.main.async {
                isGenerating = false
                
                if data != nil {
                    self.pdfData = data
                    generator.notificationOccurred(.success)
                    showShareSheet = true
                } else {
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
}

// MARK: - Stat Preview
struct StatPreview: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, PerfilUsuario.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Dr. García", password: "1234")
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3, user: user)
    perfil.onboardingCompleto = true
    user.perfil = perfil
    
    // Add sample guardias
    let g1 = Guardia(fecha: Date(), tipo: .laborable, horas: 12, hospital: "Hospital La Paz", user: user)
    let g2 = Guardia(fecha: Date().addingTimeInterval(-86400 * 3), tipo: .noche, horas: 17, user: user)
    user.guardias = [g1, g2]
    
    container.mainContext.insert(user)
    
    return NavigationStack {
        ExportPDFView(user: user)
    }
    .modelContainer(container)
}
