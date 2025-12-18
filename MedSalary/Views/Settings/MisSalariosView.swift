import SwiftUI
import SwiftData

/// Vista de solo lectura para mostrar los parámetros salariales del usuario
struct MisSalariosView: View {
    let perfil: PerfilUsuario
    
    private var usaPersonalizados: Bool {
        perfil.usarComplementosPersonalizados
    }
    
    private var datosOficiales: CategoriaSalarial? {
        SalaryEngine.getConfig(ccaa: perfil.ccaa, categoria: perfil.categoria)
    }
    
    var body: some View {
        List {
            // Header con resumen
            Section {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(perfil.categoria.displayName)
                                .font(.headline)
                            Text(perfil.ccaa.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(formatCurrency(brutoFijoMensual))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.teal)
                            Text("Bruto fijo/mes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Fuente de datos
            Section {
                HStack(spacing: 12) {
                    Image(systemName: usaPersonalizados ? "person.fill" : "building.columns.fill")
                        .foregroundStyle(usaPersonalizados ? .orange : .teal)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(usaPersonalizados ? "Datos Personalizados" : "Datos Oficiales")
                            .fontWeight(.medium)
                        Text(usaPersonalizados ? "Estás usando valores personalizados de tu nómina" : "Usando datos oficiales de \(perfil.ccaa.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Desglose de retribuciones
            Section("Retribuciones Mensuales") {
                SalaryRow(
                    icon: "eurosign.circle.fill",
                    label: "Sueldo Base",
                    value: sueldoBase
                )
                
                SalaryRow(
                    icon: "briefcase.fill",
                    label: "Complemento Destino",
                    value: complementoDestino
                )
                
                SalaryRow(
                    icon: "star.fill",
                    label: "Complemento Específico",
                    value: complementoEspecifico
                )
                
                if complementoProductividad > 0 {
                    SalaryRow(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Complemento Productividad",
                        value: complementoProductividad
                    )
                }
                
                if complementoCarrera > 0 {
                    SalaryRow(
                        icon: "graduationcap.fill",
                        label: "Complemento Carrera",
                        value: complementoCarrera
                    )
                }
                
                if otrosComplementos > 0 {
                    SalaryRow(
                        icon: "plus.circle.fill",
                        label: "Otros Complementos",
                        value: otrosComplementos
                    )
                }
            }
            
            // Total
            Section {
                HStack {
                    Label("Total Bruto Fijo Mensual", systemImage: "sum")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(formatCurrency(brutoFijoMensual))
                        .font(.headline)
                        .foregroundStyle(.teal)
                }
                
                HStack {
                    Label("Total Bruto Fijo Anual (14 pagas)", systemImage: "calendar")
                        .font(.subheadline)
                    Spacer()
                    Text(formatCurrency(brutoFijoAnual))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Precios de guardia
            Section("Precio Hora Guardia") {
                GuardiaPriceRow(
                    icon: "sun.max.fill",
                    label: "Laborable",
                    value: precioGuardiaLaborable
                )
                
                GuardiaPriceRow(
                    icon: "calendar",
                    label: "Festivo",
                    value: precioGuardiaFestivo
                )
                
                GuardiaPriceRow(
                    icon: "moon.fill",
                    label: "Noche",
                    value: precioGuardiaNoche
                )
            }
            
            // Nota informativa
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    
                    Text("Para modificar estos valores, ve a 'Mis Complementos' en la sección de Configuración.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Mis Parámetros Salariales")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Computed Properties
    
    private var sueldoBase: Double {
        if usaPersonalizados, let valor = perfil.sueldoBaseMensual {
            return valor
        }
        return datosOficiales?.sueldoBaseMensual ?? 0
    }
    
    private var complementoDestino: Double {
        if usaPersonalizados, let valor = perfil.complementoDestinoMensual {
            return valor
        }
        return datosOficiales?.complementoDestinoMensual ?? 0
    }
    
    private var complementoEspecifico: Double {
        if usaPersonalizados, let valor = perfil.complementoEspecificoMensual {
            return valor
        }
        return datosOficiales?.complementoEspecificoMensual ?? 0
    }
    
    private var complementoProductividad: Double {
        perfil.complementoProductividadMensual ?? 0
    }
    
    private var complementoCarrera: Double {
        perfil.complementoCarreraMensual ?? 0
    }
    
    private var otrosComplementos: Double {
        perfil.otrosComplementosMensual ?? 0
    }
    
    private var brutoFijoMensual: Double {
        sueldoBase + complementoDestino + complementoEspecifico + complementoProductividad + complementoCarrera + otrosComplementos
    }
    
    private var brutoFijoAnual: Double {
        // Base, destino y específico: 14 pagas. Resto: 12 pagas
        (sueldoBase + complementoDestino + complementoEspecifico) * 14 +
        (complementoProductividad + complementoCarrera + otrosComplementos) * 12
    }
    
    private var precioGuardiaLaborable: Double {
        if usaPersonalizados, let valor = perfil.precioGuardiaLaborable {
            return valor
        }
        return datosOficiales?.precioGuardia.laborable ?? 0
    }
    
    private var precioGuardiaFestivo: Double {
        if usaPersonalizados, let valor = perfil.precioGuardiaFestivo {
            return valor
        }
        return datosOficiales?.precioGuardia.festivo ?? 0
    }
    
    private var precioGuardiaNoche: Double {
        if usaPersonalizados, let valor = perfil.precioGuardiaNoche {
            return valor
        }
        return datosOficiales?.precioGuardia.noche ?? 0
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return String(format: "%.2f€", value)
    }
}

// MARK: - Components

struct SalaryRow: View {
    let icon: String
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(String(format: "%.2f€", value))
                .foregroundStyle(.secondary)
        }
    }
}

struct GuardiaPriceRow: View {
    let icon: String
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(String(format: "%.2f€/h", value))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, PerfilUsuario.self, configurations: config)
    
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .fea)
    container.mainContext.insert(perfil)
    
    return NavigationStack {
        MisSalariosView(perfil: perfil)
    }
    .modelContainer(container)
}
