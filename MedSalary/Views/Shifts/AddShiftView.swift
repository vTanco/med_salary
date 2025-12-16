import SwiftUI
import SwiftData

struct AddShiftView: View {
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    let onSaved: () -> Void
    
    @State private var fecha = Date()
    @State private var tipoGuardia: TipoGuardia = .laborable
    @State private var horas: Int = 12
    @State private var showConfirmation = false
    
    private let horasOptions = [6, 8, 10, 12, 14, 16, 17, 24]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Icon
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.teal)
                        
                        Text("Nueva Guardia")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 20)
                    
                    // Date Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Fecha", systemImage: "calendar")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        DatePicker(
                            "",
                            selection: $fecha,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(.teal)
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Tipo de Guardia
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tipo de Guardia", systemImage: "tag.fill")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            ForEach(TipoGuardia.allCases, id: \.self) { tipo in
                                Button {
                                    tipoGuardia = tipo
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: tipo.icon)
                                            .font(.title2)
                                        Text(tipo.displayName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(tipoGuardia == tipo ? Color.teal : Color(.systemGray6))
                                    .foregroundStyle(tipoGuardia == tipo ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Horas
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Duración", systemImage: "clock.fill")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(horasOptions, id: \.self) { h in
                                Button {
                                    horas = h
                                } label: {
                                    Text("\(h)h")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(horas == h ? Color.teal : Color(.systemGray6))
                                        .foregroundStyle(horas == h ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Save Button
                    Button(action: saveGuardia) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Guardar Guardia")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.teal)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Añadir Guardia")
            .navigationBarTitleDisplayMode(.inline)
            .alert("¡Guardia Guardada!", isPresented: $showConfirmation) {
                Button("OK") {
                    onSaved()
                }
            } message: {
                Text("La guardia se ha añadido correctamente.")
            }
        }
    }
    
    private func saveGuardia() {
        let guardia = Guardia(
            fecha: fecha,
            tipo: tipoGuardia,
            horas: horas,
            user: user
        )
        
        modelContext.insert(guardia)
        
        // Add to user's guardias
        if user.guardias == nil {
            user.guardias = []
        }
        user.guardias?.append(guardia)
        
        do {
            try modelContext.save()
            showConfirmation = true
        } catch {
            print("Error saving guardia: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, configurations: config)
    let user = User(email: "test@test.com", name: "Test", password: "1234")
    container.mainContext.insert(user)
    
    return AddShiftView(user: user) { }
        .modelContainer(container)
}
