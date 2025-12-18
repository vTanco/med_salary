import Foundation

/// Resultado de comparación IRPF
struct ComparacionIRPF {
    let irpfOptimo: Double           // Porcentaje recomendado (ej: 0.18 = 18%)
    let irpfActual: Double?          // Porcentaje actual del usuario
    let diferencia: Double           // Diferencia (positivo = debe subir)
    let necesitaSubir: Bool          // Solo true si debe subirlo
    let mensajeRecomendacion: String // Descripción para usuario
    
    var diferenciaAbsoluta: Double {
        abs(diferencia)
    }
    
    var porcentajeOptimoFormateado: String {
        String(format: "%.1f%%", irpfOptimo * 100)
    }
    
    var porcentajeActualFormateado: String {
        guard let actual = irpfActual else { return "No configurado" }
        return String(format: "%.1f%%", actual * 100)
    }
}

/// Motor de cálculo de IRPF
struct IRPFEngine {
    
    /// Calcula el tipo de IRPF efectivo basado en un bruto anual progresivo
    static func calcularTipoBase(brutoAnual: Double) -> Double {
        guard brutoAnual > 0 else { return 0 }
        
        var cuotaTotal: Double = 0
        var ultimoLimite: Double = 0
        
        for tramo in TRAMOS_IRPF_2024 {
            if brutoAnual > ultimoLimite {
                let baseTramo = min(brutoAnual, tramo.hasta) - ultimoLimite
                cuotaTotal += baseTramo * tramo.tipo
                ultimoLimite = tramo.hasta
            } else {
                break
            }
        }
        
        // Tipo medio efectivo
        return cuotaTotal / brutoAnual
    }
    
    /// Calcula retención final aplicando situación familiar
    static func calcularIRPF(
        brutoAnualEstimado: Double,
        brutoMensualActual: Double,
        estadoFamiliar: EstadoFamiliar
    ) -> ResultadoIRPF {
        // 1. Obtener tipo base según tabla progresiva
        var tipoCalculado = calcularTipoBase(brutoAnual: brutoAnualEstimado)
        
        // 2. Aplicar correcciones familiares (Simplificación MVP)
        // Si tiene hijos, reducimos 1.5 puntos porcentuales (0.015)
        if estadoFamiliar == .conHijos {
            tipoCalculado -= 0.015
        }
        
        // Normalizar (no puede ser negativo)
        tipoCalculado = max(0, tipoCalculado)
        
        // 3. Calcular montos mensuales
        let retencionMensual = brutoMensualActual * tipoCalculado
        let netoMensual = brutoMensualActual - retencionMensual
        
        return ResultadoIRPF(
            tipoRecomendado: tipoCalculado,
            retencionMensualEstimada: retencionMensual,
            netoMensualEstimado: netoMensual
        )
    }
    
    /// Calcula IRPF incluyendo fuentes de ingreso adicionales
    static func calcularIRPFConFuentesAdicionales(
        brutoAnualEstimado: Double,
        brutoMensualActual: Double,
        estadoFamiliar: EstadoFamiliar,
        ingresoAdicionalAnual: Double = 0
    ) -> ResultadoIRPF {
        let brutoTotalAnual = brutoAnualEstimado + ingresoAdicionalAnual
        
        return calcularIRPF(
            brutoAnualEstimado: brutoTotalAnual,
            brutoMensualActual: brutoMensualActual,
            estadoFamiliar: estadoFamiliar
        )
    }
    
    /// Compara IRPF actual vs óptimo y genera recomendación
    static func compararIRPF(
        brutoAnualTotal: Double,
        estadoFamiliar: EstadoFamiliar,
        irpfActualUsuario: Double?,
        ingresoAdicionalAnual: Double = 0
    ) -> ComparacionIRPF {
        let brutoTotalConAdicionales = brutoAnualTotal + ingresoAdicionalAnual
        
        // Calcular tipo óptimo
        var tipoOptimo = calcularTipoBase(brutoAnual: brutoTotalConAdicionales)
        
        // Aplicar corrección familiar
        if estadoFamiliar == .conHijos {
            tipoOptimo -= 0.015
        }
        tipoOptimo = max(0, tipoOptimo)
        
        // Calcular diferencia
        let diferencia: Double
        let necesitaSubir: Bool
        let mensaje: String
        
        if let actual = irpfActualUsuario {
            diferencia = tipoOptimo - actual
            // Solo notificamos si debe SUBIR (diferencia positiva significativa)
            necesitaSubir = diferencia > 0.005 // Más de 0.5 puntos porcentuales
            
            if diferencia > 0.02 {
                mensaje = "⚠️ Tu IRPF actual está bajo. Considera subirlo para evitar pagar de más en la declaración."
            } else if diferencia > 0.005 {
                mensaje = "📊 Tu IRPF podría ajustarse ligeramente al alza."
            } else if diferencia < -0.02 {
                mensaje = "✅ Tu IRPF actual es superior al óptimo. Podrías cobrar más neto mensual."
            } else {
                mensaje = "✅ Tu IRPF está bien ajustado."
            }
        } else {
            diferencia = 0
            necesitaSubir = false
            mensaje = "Configura tu % de IRPF actual para ver recomendaciones."
        }
        
        return ComparacionIRPF(
            irpfOptimo: tipoOptimo,
            irpfActual: irpfActualUsuario,
            diferencia: diferencia,
            necesitaSubir: necesitaSubir,
            mensajeRecomendacion: mensaje
        )
    }
}

