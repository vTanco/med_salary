import SwiftUI
import SwiftData

struct AddShiftView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allPlantillas: [PlantillaGuardia]
    
    let user: User
    let onSaved: () -> Void
    
    @State private var fecha = Date()
    @State private var tipoGuardia: TipoGuardia = .laborable
    @State private var horas: Int = 12
    @State private var notas: String = ""
    @State private var hospital: String = ""
    @State private var showConfirmation = false
    @State private var showDuplicateWarning = false
    @State private var recordatorioActivo = true
    
    private let horasOptions = [6, 8, 10, 12, 14, 16, 17, 24]
    
    private var plantillas: [PlantillaGuardia] {
        allPlantillas.filter { $0.userId == user.id }
    }
    
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
                    
                    // Quick Templates
                    if !plantillas.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Plantillas rápidas", systemImage: "bolt.fill")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(plantillas, id: \.id) { plantilla in
                                        Button {
                                            aplicarPlantilla(plantilla)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Image(systemName: plantilla.tipo.icon)
                                                        .font(.caption)
                                                    Text(plantilla.nombre)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                }
                                                Text("\(plantilla.horas)h")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    
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
                    .background(Color(.systemBackground))
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
                                    withAnimation(.spring(response: 0.3)) {
                                        tipoGuardia = tipo
                                    }
                                    triggerHaptic(.light)
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
                                    .scaleEffect(tipoGuardia == tipo ? 1.02 : 1.0)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
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
                                    withAnimation(.spring(response: 0.3)) {
                                        horas = h
                                    }
                                    triggerHaptic(.light)
                                } label: {
                                    Text("\(h)h")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(horas == h ? Color.teal : Color(.systemGray6))
                                        .foregroundStyle(horas == h ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .scaleEffect(horas == h ? 1.05 : 1.0)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Hospital (Optional)
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Hospital (opcional)", systemImage: "building.2.fill")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Ej: Hospital La Paz", text: $hospital)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Notas (Optional)
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Notas (opcional)", systemImage: "note.text")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Ej: Urgencias, turno tranquilo...", text: $notas, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Recordatorio
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $recordatorioActivo) {
                            Label("Recordar día antes", systemImage: "bell.fill")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        .tint(.teal)
                        
                        if recordatorioActivo {
                            Text("Recibirás una notificación a las 20:00 del día anterior")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Save Button
                    Button(action: attemptSave) {
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
            .alert("Guardia Duplicada", isPresented: $showDuplicateWarning) {
                Button("Cancelar", role: .cancel) { }
                Button("Guardar Igualmente", role: .destructive) {
                    saveGuardia()
                }
            } message: {
                Text("Ya existe una guardia registrada para esta fecha. ¿Quieres añadir otra?")
            }
        }
    }
    
    private func attemptSave() {
        // Check for duplicate
        if Guardia.existsOnDate(fecha, for: user) {
            triggerHaptic(.warning)
            showDuplicateWarning = true
        } else {
            saveGuardia()
        }
    }
    
    private func saveGuardia() {
        let guardia = Guardia(
            fecha: fecha,
            tipo: tipoGuardia,
            horas: horas,
            notas: notas.isEmpty ? nil : notas,
            hospital: hospital.isEmpty ? nil : hospital,
            recordatorioActivo: recordatorioActivo,
            user: user
        )
        
        modelContext.insert(guardia)
        
        // Add to user's guardias
        if user.guardias == nil {
            user.guardias = []
        }
        user.guardias?.append(guardia)
        
        // Schedule reminder if enabled
        if recordatorioActivo {
            Task {
                if let notificationId = await NotificationService.shared.scheduleShiftReminder(for: guardia) {
                    guardia.recordatorioId = notificationId
                    try? modelContext.save()
                }
            }
        }
        
        do {
            try modelContext.save()
            triggerHaptic(.success)
            showConfirmation = true
        } catch {
            triggerHaptic(.error)
            print("Error saving guardia: \(error)")
        }
    }
    
    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func aplicarPlantilla(_ plantilla: PlantillaGuardia) {
        withAnimation(.spring(response: 0.3)) {
            tipoGuardia = plantilla.tipo
            horas = plantilla.horas
            hospital = plantilla.hospital ?? ""
        }
        triggerHaptic(.medium)
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

