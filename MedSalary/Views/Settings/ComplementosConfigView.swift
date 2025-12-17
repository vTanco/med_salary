import SwiftUI
import SwiftData

struct ComplementosConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let perfil: PerfilUsuario
    
    @State private var usarPersonalizados: Bool
    @State private var sueldoBase: String
    @State private var complementoDestino: String
    @State private var complementoEspecifico: String
    @State private var complementoProductividad: String
    @State private var complementoCarrera: String
    @State private var otrosComplementos: String
    @State private var precioGuardiaLaborable: String
    @State private var precioGuardiaFestivo: String
    @State private var precioGuardiaNoche: String
    
    @State private var showSaveConfirmation = false
    
    private var brutoCalculado: Double {
        let base = Double(sueldoBase) ?? 0
        let destino = Double(complementoDestino) ?? 0
        let especifico = Double(complementoEspecifico) ?? 0
        let productividad = Double(complementoProductividad) ?? 0
        let carrera = Double(complementoCarrera) ?? 0
        let otros = Double(otrosComplementos) ?? 0
        return base + destino + especifico + productividad + carrera + otros
    }
    
    init(perfil: PerfilUsuario) {
        self.perfil = perfil
        _usarPersonalizados = State(initialValue: perfil.usarComplementosPersonalizados)
        _sueldoBase = State(initialValue: perfil.sueldoBaseMensual.map { String(format: "%.2f", $0) } ?? "")
        _complementoDestino = State(initialValue: perfil.complementoDestinoMensual.map { String(format: "%.2f", $0) } ?? "")
        _complementoEspecifico = State(initialValue: perfil.complementoEspecificoMensual.map { String(format: "%.2f", $0) } ?? "")
        _complementoProductividad = State(initialValue: perfil.complementoProductividadMensual.map { String(format: "%.2f", $0) } ?? "")
        _complementoCarrera = State(initialValue: perfil.complementoCarreraMensual.map { String(format: "%.2f", $0) } ?? "")
        _otrosComplementos = State(initialValue: perfil.otrosComplementosMensual.map { String(format: "%.2f", $0) } ?? "")
        _precioGuardiaLaborable = State(initialValue: perfil.precioGuardiaLaborable.map { String(format: "%.2f", $0) } ?? "")
        _precioGuardiaFestivo = State(initialValue: perfil.precioGuardiaFestivo.map { String(format: "%.2f", $0) } ?? "")
        _precioGuardiaNoche = State(initialValue: perfil.precioGuardiaNoche.map { String(format: "%.2f", $0) } ?? "")
    }
    
    var body: some View {
        Form {
            // Toggle principal
            Section {
                Toggle(isOn: $usarPersonalizados) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Usar valores personalizados")
                            .fontWeight(.medium)
                        Text("Desactiva para usar valores por defecto de tu CCAA")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.teal)
            }
            
            if usarPersonalizados {
                // Sección de salario fijo
                Section {
                    CurrencyField(label: "Sueldo Base", value: $sueldoBase, icon: "eurosign")
                    CurrencyField(label: "Compl. Destino", value: $complementoDestino, icon: "briefcase.fill")
                    CurrencyField(label: "Compl. Específico", value: $complementoEspecifico, icon: "star.fill")
                    CurrencyField(label: "Compl. Productividad", value: $complementoProductividad, icon: "chart.line.uptrend.xyaxis")
                    CurrencyField(label: "Compl. Carrera", value: $complementoCarrera, icon: "graduationcap.fill")
                    CurrencyField(label: "Otros Complementos", value: $otrosComplementos, icon: "plus.circle.fill")
                } header: {
                    Text("Retribuciones Mensuales")
                } footer: {
                    HStack {
                        Text("Total Bruto Fijo:")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(brutoCalculado))€/mes")
                            .fontWeight(.bold)
                            .foregroundStyle(.teal)
                    }
                    .padding(.top, 8)
                }
                
                // Sección de guardias
                Section("Precio Hora Guardia") {
                    CurrencyField(label: "Laborable", value: $precioGuardiaLaborable, icon: "sun.max.fill", suffix: "€/hora")
                    CurrencyField(label: "Festivo", value: $precioGuardiaFestivo, icon: "calendar", suffix: "€/hora")
                    CurrencyField(label: "Noche", value: $precioGuardiaNoche, icon: "moon.fill", suffix: "€/hora")
                }
                
                // Información
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                        
                        Text("Estos valores se usarán en lugar de los datos oficiales de tu CCAA para calcular tu salario.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } else {
                // Info cuando está desactivado
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "building.columns.fill")
                            .foregroundStyle(.teal)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Usando datos oficiales")
                                .fontWeight(.medium)
                            Text("Se usarán los valores estándar de \(perfil.ccaa.displayName) para tu categoría \(perfil.categoria.displayName).")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Mis Complementos")
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
            Text("Tus complementos se han actualizado correctamente.")
        }
    }
    
    private func saveChanges() {
        perfil.usarComplementosPersonalizados = usarPersonalizados
        
        if usarPersonalizados {
            perfil.sueldoBaseMensual = Double(sueldoBase)
            perfil.complementoDestinoMensual = Double(complementoDestino)
            perfil.complementoEspecificoMensual = Double(complementoEspecifico)
            perfil.complementoProductividadMensual = Double(complementoProductividad)
            perfil.complementoCarreraMensual = Double(complementoCarrera)
            perfil.otrosComplementosMensual = Double(otrosComplementos)
            perfil.precioGuardiaLaborable = Double(precioGuardiaLaborable)
            perfil.precioGuardiaFestivo = Double(precioGuardiaFestivo)
            perfil.precioGuardiaNoche = Double(precioGuardiaNoche)
        }
        
        do {
            try modelContext.save()
            showSaveConfirmation = true
        } catch {
            print("Error saving complementos: \(error)")
        }
    }
}

// MARK: - Currency Field Component
struct CurrencyField: View {
    let label: String
    @Binding var value: String
    let icon: String
    var suffix: String = "€/mes"
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                TextField("0", text: $value)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                
                Text(suffix)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, PerfilUsuario.self, configurations: config)
    
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3)
    container.mainContext.insert(perfil)
    
    return NavigationStack {
        ComplementosConfigView(perfil: perfil)
    }
    .modelContainer(container)
}
