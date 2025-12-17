import Foundation

// MARK: - Datos Salariales por CCAA (Actualizados 2024-2025)

/// Datos específicos por cada Comunidad Autónoma basados en documentos oficiales 2024-2025

// MARK: - MIR Categories (valores reales 2024-2025)
private func createMIRCategorias(ccaa: ComunidadAutonoma) -> [CategoriaSalarial] {
    // Precios base según PDF - varían por CCAA
    let guardiaMultiplier: Double
    switch ccaa {
    case .paisVasco: guardiaMultiplier = 1.35
    case .navarra: guardiaMultiplier = 1.25
    case .cataluna: guardiaMultiplier = 1.20
    case .baleares: guardiaMultiplier = 1.15
    case .castillaMancha: guardiaMultiplier = 1.10
    case .castillaLeon: guardiaMultiplier = 1.05
    case .andalucia, .canarias: guardiaMultiplier = 1.00
    case .asturias, .cantabria, .galicia, .valencia: guardiaMultiplier = 0.98
    case .aragon, .murcia, .rioja, .extremadura: guardiaMultiplier = 0.95
    case .madrid: guardiaMultiplier = 0.90
    case .ceutaMelilla: guardiaMultiplier = 1.10
    }
    
    return [
        // MIR-1: ~1.301€ bruto/mes sin guardias
        CategoriaSalarial(
            nombre: .mir1,
            sueldoBaseMensual: 1301.00,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 0,
            precioGuardia: PrecioGuardia(
                laborable: 17.50 * guardiaMultiplier,
                festivo: 19.00 * guardiaMultiplier,
                noche: 21.00 * guardiaMultiplier
            )
        ),
        // MIR-2: ~1.400€ bruto/mes
        CategoriaSalarial(
            nombre: .mir2,
            sueldoBaseMensual: 1400.00,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 0,
            precioGuardia: PrecioGuardia(
                laborable: 19.50 * guardiaMultiplier,
                festivo: 21.50 * guardiaMultiplier,
                noche: 23.50 * guardiaMultiplier
            )
        ),
        // MIR-3: ~1.500€ bruto/mes
        CategoriaSalarial(
            nombre: .mir3,
            sueldoBaseMensual: 1500.00,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 0,
            precioGuardia: PrecioGuardia(
                laborable: 22.00 * guardiaMultiplier,
                festivo: 24.00 * guardiaMultiplier,
                noche: 26.00 * guardiaMultiplier
            )
        ),
        // MIR-4: ~1.650€ bruto/mes
        CategoriaSalarial(
            nombre: .mir4,
            sueldoBaseMensual: 1650.00,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 0,
            precioGuardia: PrecioGuardia(
                laborable: 24.50 * guardiaMultiplier,
                festivo: 27.00 * guardiaMultiplier,
                noche: 29.00 * guardiaMultiplier
            )
        ),
        // MIR-5: ~1.795€ bruto/mes
        CategoriaSalarial(
            nombre: .mir5,
            sueldoBaseMensual: 1795.00,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 0,
            precioGuardia: PrecioGuardia(
                laborable: 26.66 * guardiaMultiplier,
                festivo: 29.00 * guardiaMultiplier,
                noche: 31.00 * guardiaMultiplier
            )
        )
    ]
}

// MARK: - FEA/Adjuntos por CCAA (datos oficiales 2024-2025)

private func createAdjuntoCategorias(ccaa: ComunidadAutonoma) -> [CategoriaSalarial] {
    let (laborable, festivo, noche, cdestino, cespecifico): (Double, Double, Double, Double, Double)
    
    switch ccaa {
    case .andalucia:
        // Resolución 0039/2025 SAS
        laborable = 30.00; festivo = 34.00; noche = 38.00
        cdestino = 677.66; cespecifico = 850.00
    case .aragon:
        // Tablas agosto 2025
        laborable = 27.78; festivo = 29.77; noche = 32.00
        cdestino = 700.00; cespecifico = 375.00
    case .asturias:
        // Acuerdo SESPA 2024-2025
        laborable = 28.50; festivo = 32.00; noche = 35.00
        cdestino = 697.00; cespecifico = 920.00
    case .baleares:
        // IB-Salut 2025 + Plus residencia
        laborable = 32.00; festivo = 37.00; noche = 40.00
        cdestino = 710.00; cespecifico = 1100.00
    case .canarias:
        // SCS 2025 + Indemnización residencia
        laborable = 28.00; festivo = 32.00; noche = 35.00
        cdestino = 697.00; cespecifico = 950.00
    case .cantabria:
        // Acuerdo junio 2024 (+400€ progresivo)
        laborable = 30.00; festivo = 33.00; noche = 36.00
        cdestino = 697.00; cespecifico = 1050.00
    case .castillaLeon:
        // SACYL 2024/25
        laborable = 30.12; festivo = 33.58; noche = 36.00
        cdestino = 697.00; cespecifico = 920.00
    case .castillaMancha:
        // SESCAM tablas 2025 oficiales
        laborable = 31.63; festivo = 33.91; noche = 37.00
        cdestino = 697.00; cespecifico = 972.51
    case .cataluna:
        // ICS III Acord
        laborable = 37.00; festivo = 40.00; noche = 43.00
        cdestino = 720.00; cespecifico = 1200.00
    case .valencia:
        laborable = 28.00; festivo = 31.00; noche = 34.00
        cdestino = 697.00; cespecifico = 900.00
    case .extremadura:
        laborable = 27.00; festivo = 30.00; noche = 33.00
        cdestino = 677.00; cespecifico = 800.00
    case .galicia:
        // DOG 2023 + Factor acumulación 5ª guardia
        laborable = 28.00; festivo = 30.00; noche = 33.00
        cdestino = 697.00; cespecifico = 880.00
    case .madrid:
        // Sin peaje 232€ - tablas 2024
        laborable = 26.00; festivo = 30.00; noche = 33.00
        cdestino = 697.00; cespecifico = 950.00
    case .murcia:
        // SMS tablas 2025
        laborable = 28.00; festivo = 32.00; noche = 35.00
        cdestino = 697.00; cespecifico = 870.00
    case .navarra:
        // Osasunbidea - exclusividad factor clave
        laborable = 28.00; festivo = 35.00; noche = 40.00
        cdestino = 720.00; cespecifico = 1300.00
    case .paisVasco:
        // Osakidetza - líder retribución
        laborable = 35.00; festivo = 45.00; noche = 48.00
        cdestino = 750.00; cespecifico = 1400.00
    case .rioja:
        // SERIS tablas 2025
        laborable = 28.00; festivo = 32.00; noche = 35.00
        cdestino = 697.00; cespecifico = 850.00
    case .ceutaMelilla:
        // INGESA + Complemento residencia + 60% IRPF
        laborable = 30.00; festivo = 35.00; noche = 38.00
        cdestino = 720.00; cespecifico = 1500.00
    }
    
    let sueldoBase = 1333.40 // Base A1 nacional 2025
    
    return [
        CategoriaSalarial(
            nombre: .fea,
            sueldoBaseMensual: sueldoBase,
            complementoDestinoMensual: cdestino,
            complementoEspecificoMensual: cespecifico,
            precioGuardia: PrecioGuardia(laborable: laborable, festivo: festivo, noche: noche)
        ),
        CategoriaSalarial(
            nombre: .medFamilia,
            sueldoBaseMensual: sueldoBase,
            complementoDestinoMensual: cdestino,
            complementoEspecificoMensual: cespecifico + 70.00,
            precioGuardia: PrecioGuardia(laborable: laborable, festivo: festivo, noche: noche)
        ),
        CategoriaSalarial(
            nombre: .medUrgencias,
            sueldoBaseMensual: sueldoBase,
            complementoDestinoMensual: cdestino,
            complementoEspecificoMensual: cespecifico + 150.00,
            precioGuardia: PrecioGuardia(laborable: laborable + 1.5, festivo: festivo + 2.0, noche: noche + 2.0)
        )
    ]
}

/// Datasets completos por Comunidad Autónoma
let DATASETS_CCAA: [DatasetSalarial] = ComunidadAutonoma.allCases.map { ccaa in
    let mirCategorias = createMIRCategorias(ccaa: ccaa)
    let adjuntoCategorias = createAdjuntoCategorias(ccaa: ccaa)
    return DatasetSalarial(ccaa: ccaa, categorias: mirCategorias + adjuntoCategorias)
}

/// Obtener dataset para una CCAA
func getDataset(for ccaa: ComunidadAutonoma) -> DatasetSalarial? {
    DATASETS_CCAA.first { $0.ccaa == ccaa }
}

// MARK: - Tramos IRPF 2024

let TRAMOS_IRPF_2024: [TramoIRPF] = [
    TramoIRPF(hasta: 12450, tipo: 0.19),
    TramoIRPF(hasta: 20200, tipo: 0.24),
    TramoIRPF(hasta: 35200, tipo: 0.30),
    TramoIRPF(hasta: 60000, tipo: 0.37),
    TramoIRPF(hasta: 300000, tipo: 0.45),
    TramoIRPF(hasta: 999999999, tipo: 0.47)
]
