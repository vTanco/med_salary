import Foundation

/// Motor de cálculo salarial
struct SalaryEngine {
    
    /// Obtiene la configuración salarial para una CCAA y categoría
    static func getConfig(ccaa: ComunidadAutonoma, categoria: CategoriaId) -> CategoriaSalarial? {
        guard let dataset = getDataset(for: ccaa) else { return nil }
        return dataset.categoria(para: categoria)
    }
    
    /// Calcula el bruto anual y mensual basado en guardias
    /// Si el perfil tiene complementos personalizados activos, los usa en lugar de los datos por defecto
    static func calcularSalario(
        ccaa: ComunidadAutonoma,
        categoria: CategoriaId,
        guardiasMes: [Guardia],
        guardiasAnio: [Guardia],
        perfil: PerfilUsuario? = nil
    ) -> ResultadoSalario {
        
        // Si hay complementos personalizados activos, usarlos
        if let perfil = perfil, perfil.usarComplementosPersonalizados {
            return calcularConComplementosPersonalizados(
                perfil: perfil,
                guardiasMes: guardiasMes,
                guardiasAnio: guardiasAnio,
                ccaa: ccaa,
                categoria: categoria
            )
        }
        
        // Obtener configuración por defecto o usar fallback
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
    
    /// Calcula el salario usando los complementos personalizados del usuario
    private static func calcularConComplementosPersonalizados(
        perfil: PerfilUsuario,
        guardiasMes: [Guardia],
        guardiasAnio: [Guardia],
        ccaa: ComunidadAutonoma,
        categoria: CategoriaId
    ) -> ResultadoSalario {
        
        // Obtener config por defecto como fallback para valores no personalizados
        let configDefault = getConfig(ccaa: ccaa, categoria: categoria) 
            ?? DATASETS_CCAA[0].categorias[0]
        
        // 1. Calcular bruto fijo mensual personalizado
        let sueldoBase = perfil.sueldoBaseMensual ?? configDefault.sueldoBaseMensual
        let complementoDestino = perfil.complementoDestinoMensual ?? configDefault.complementoDestinoMensual
        let complementoEspecifico = perfil.complementoEspecificoMensual ?? configDefault.complementoEspecificoMensual
        let complementoProductividad = perfil.complementoProductividadMensual ?? 0
        let complementoCarrera = perfil.complementoCarreraMensual ?? 0
        let otrosComplementos = perfil.otrosComplementosMensual ?? 0
        
        let brutoFijoMensual = sueldoBase + complementoDestino + complementoEspecifico + 
                               complementoProductividad + complementoCarrera + otrosComplementos
        
        // 2. Bruto Fijo Anual (14 pagas para base, destino, especifico; 12 para el resto)
        let brutoFijoAnual = (sueldoBase + complementoDestino + complementoEspecifico) * 14 +
                             (complementoProductividad + complementoCarrera + otrosComplementos) * 12
        
        // 3. Precios de guardia personalizados
        let precioLaborable = perfil.precioGuardiaLaborable ?? configDefault.precioGuardia.laborable
        let precioFestivo = perfil.precioGuardiaFestivo ?? configDefault.precioGuardia.festivo
        let precioNoche = perfil.precioGuardiaNoche ?? configDefault.precioGuardia.noche
        
        func precioParaTipo(_ tipo: TipoGuardia) -> Double {
            switch tipo {
            case .laborable: return precioLaborable
            case .festivo: return precioFestivo
            case .noche: return precioNoche
            }
        }
        
        // 4. Bruto Guardias Mes Actual
        var brutoGuardiasMes: Double = 0
        for guardia in guardiasMes {
            brutoGuardiasMes += Double(guardia.horas) * precioParaTipo(guardia.tipo)
        }
        
        // 5. Proyección Anual
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
