import Foundation

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
}
