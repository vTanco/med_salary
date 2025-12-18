import SwiftUI

/// Tarjeta KPI que muestra la comparación entre IRPF actual y óptimo
struct IRPFKPICard: View {
    let comparacion: ComparacionIRPF
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "percent")
                        .foregroundStyle(.teal)
                    Text("IRPF Óptimo vs Actual")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Status indicator
                    statusBadge
                }
                
                // Comparison
                HStack(spacing: 0) {
                    // IRPF Actual
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Actual")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(comparacion.porcentajeActualFormateado)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(actualColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Arrow
                    Image(systemName: arrowIcon)
                        .font(.title3)
                        .foregroundStyle(arrowColor)
                        .padding(.horizontal, 8)
                    
                    // IRPF Óptimo
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Óptimo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(comparacion.porcentajeOptimoFormateado)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.teal)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .background(backgroundGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Message
                HStack {
                    Text(comparacion.mensajeRecomendacion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if onTap != nil {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .primary.opacity(0.05), radius: 5)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            if comparacion.irpfActual == nil {
                Text("Configurar")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
            } else if comparacion.necesitaSubir {
                Text("Ajustar")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            } else {
                Text("OK")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
        }
    }
    
    private var actualColor: Color {
        guard comparacion.irpfActual != nil else { return .secondary }
        
        if comparacion.diferencia > 0.02 {
            return .orange
        } else if comparacion.diferencia < -0.02 {
            return .blue
        }
        return .green
    }
    
    private var arrowIcon: String {
        if comparacion.diferencia > 0.005 {
            return "arrow.up.circle.fill"
        } else if comparacion.diferencia < -0.005 {
            return "arrow.down.circle.fill"
        }
        return "checkmark.circle.fill"
    }
    
    private var arrowColor: Color {
        if comparacion.diferencia > 0.02 {
            return .orange
        } else if comparacion.diferencia < -0.02 {
            return .blue
        }
        return .green
    }
    
    private var backgroundGradient: some ShapeStyle {
        if comparacion.necesitaSubir {
            return Color.orange.opacity(0.1)
        }
        return Color.teal.opacity(0.1)
    }
}

#Preview("Necesita subir") {
    let comparacion = ComparacionIRPF(
        irpfOptimo: 0.22,
        irpfActual: 0.15,
        diferencia: 0.07,
        necesitaSubir: true,
        mensajeRecomendacion: "⚠️ Tu IRPF actual está bajo. Considera subirlo para evitar pagar de más en la declaración."
    )
    
    return IRPFKPICard(comparacion: comparacion)
        .padding()
}

#Preview("Bien ajustado") {
    let comparacion = ComparacionIRPF(
        irpfOptimo: 0.18,
        irpfActual: 0.18,
        diferencia: 0,
        necesitaSubir: false,
        mensajeRecomendacion: "✅ Tu IRPF está bien ajustado."
    )
    
    return IRPFKPICard(comparacion: comparacion)
        .padding()
}

#Preview("Sin configurar") {
    let comparacion = ComparacionIRPF(
        irpfOptimo: 0.18,
        irpfActual: nil,
        diferencia: 0,
        necesitaSubir: false,
        mensajeRecomendacion: "Configura tu % de IRPF actual para ver recomendaciones."
    )
    
    return IRPFKPICard(comparacion: comparacion)
        .padding()
}
