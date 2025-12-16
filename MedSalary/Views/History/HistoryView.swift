import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    
    @State private var guardiaToDelete: Guardia?
    @State private var showDeleteConfirmation = false
    
    private var guardias: [Guardia] {
        (user.guardias ?? []).sorted { $0.fecha > $1.fecha }
    }
    
    private var guardiasByMonth: [(String, [Guardia])] {
        let grouped = Dictionary(grouping: guardias) { guardia -> String in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: guardia.fecha).capitalized
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if guardias.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(guardiasByMonth, id: \.0) { month, monthGuardias in
                            Section(header: Text(month)) {
                                ForEach(monthGuardias, id: \.id) { guardia in
                                    guardiaRow(guardia)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                guardiaToDelete = guardia
                                                showDeleteConfirmation = true
                                            } label: {
                                                Label("Eliminar", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Historial")
            .alert("Eliminar Guardia", isPresented: $showDeleteConfirmation) {
                Button("Cancelar", role: .cancel) {
                    guardiaToDelete = nil
                }
                Button("Eliminar", role: .destructive) {
                    if let guardia = guardiaToDelete {
                        deleteGuardia(guardia)
                    }
                }
            } message: {
                if let guardia = guardiaToDelete {
                    Text("¿Eliminar la guardia del \(guardia.fechaFormateada)?")
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Sin guardias registradas")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Añade tu primera guardia para ver el historial")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func guardiaRow(_ guardia: Guardia) -> some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: guardia.tipo.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(colorForTipo(guardia.tipo))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(guardia.fechaFormateada)
                        .font(.headline)
                    
                    if guardia.hospital != nil {
                        Image(systemName: "building.2.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text("\(guardia.tipo.displayName) • \(guardia.horas)h")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Show hospital and notes
                if let hospital = guardia.hospital, !hospital.isEmpty {
                    Text(hospital)
                        .font(.caption)
                        .foregroundStyle(.teal)
                }
                
                if let notas = guardia.notas, !notas.isEmpty {
                    Text(notas)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Estimated earnings
            if let perfil = user.perfil,
               let config = SalaryEngine.getConfig(ccaa: perfil.ccaa, categoria: perfil.categoria) {
                let earnings = Double(guardia.horas) * config.precioGuardia.precio(para: guardia.tipo)
                Text("+\(Int(earnings))€")
                    .font(.headline)
                    .foregroundStyle(.teal)
            }
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
    
    private func deleteGuardia(_ guardia: Guardia) {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Remove from user's guardias array
        user.guardias?.removeAll { $0.id == guardia.id }
        
        // Delete from context
        modelContext.delete(guardia)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting guardia: \(error)")
        }
        
        guardiaToDelete = nil
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, PerfilUsuario.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Test", password: "1234")
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3, user: user)
    perfil.onboardingCompleto = true
    user.perfil = perfil
    
    // Add some sample guardias
    let g1 = Guardia(fecha: Date(), tipo: .laborable, horas: 12, notas: "Turno tranquilo", hospital: "Hospital La Paz", user: user)
    let g2 = Guardia(fecha: Date().addingTimeInterval(-86400), tipo: .noche, horas: 17, user: user)
    user.guardias = [g1, g2]
    
    container.mainContext.insert(user)
    
    return HistoryView(user: user)
        .modelContainer(container)
}

