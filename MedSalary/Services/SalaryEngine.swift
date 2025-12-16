import Foundation

/// Motor de cálculo salarial
struct SalaryEngine {
    
    /// Obtiene la configuración salarial para una CCAA y categoría
    static func getConfig(ccaa: ComunidadAutonoma, categoria: CategoriaId) -> CategoriaSalarial? {
        guard let dataset = getDataset(for: ccaa) else { return nil }
        return dataset.categoria(para: categoria)
    }
    
    /// Calcula el bruto anual y mensual basado en guardias
    static func calcularSalario(
        ccaa: ComunidadAutonoma,
        categoria: CategoriaId,
        guardiasMes: [Guardia],
        guardiasAnio: [Guardia]
    ) -> ResultadoSalario {
        // Obtener configuración o usar fallback
        let config = getConfig(ccaa: ccaa, categoria: categoria) 
            ?? getConfig(ccaa: .madrid, categoria: categoria)
            ?? DATASETS_CCAA[0].categorias[0]
        
        // 1. Bruto Fijo Anual (Base + Destino + Especifico) * 14 pagas
        let sueldoBaseAnual = config.sueldoBaseMensual * 14
        let destinoAnual = config.complementoDestinoMensual * 14
        let especificoAnual = config.complementoEspecificoMensual * 14
        
        let brutoFijoAnual = sueldoBaseAnual + destinoAnual + especificoAnual
        let brutoFijoMensual = config.brutoFijoMensual
        
        // 2. Bruto Guardias Mes Actual
        var brutoGuardiasMes: Double = 0
        for guardia in guardiasMes {
            let precioHora = config.precioGuardia.precio(para: guardia.tipo)
            brutoGuardiasMes += Double(guardia.horas) * precioHora
        }
        
        // 3. Bruto Guardias Año (Real acumulado) - para referencia
        var brutoGuardiasAnioReal: Double = 0
        for guardia in guardiasAnio {
            let precioHora = config.precioGuardia.precio(para: guardia.tipo)
            brutoGuardiasAnioReal += Double(guardia.horas) * precioHora
        }
        
        // 4. Proyección Anual para IRPF
        let brutoGuardiasAnualEstimado = brutoGuardiasMes * 12
        let brutoTotalAnualEstimado = brutoFijoAnual + brutoGuardiasAnualEstimado
        
        return ResultadoSalario(
            brutoFijoMensual: brutoFijoMensual,
            brutoGuardias: brutoGuardiasMes,
            brutoTotalMensual: brutoFijoMensual + brutoGuardiasMes,
            brutoFijoAnual: brutoFijoAnual,
            brutoGuardiasAnualEstimado: brutoGuardiasAnualEstimado,
            brutoTotalAnualEstimado: brutoTotalAnualEstimado
        )
    }
}
