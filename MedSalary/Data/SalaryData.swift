import Foundation

// MARK: - Datos Salariales por CCAA

/// Helper para crear categorías basado en multiplicadores
private func createCategorias(
    baseSueldo: Double,
    baseGuardia: Double,
    extraSupplement: Double = 0
) -> [CategoriaSalarial] {
    return [
        CategoriaSalarial(
            nombre: .mir1,
            sueldoBaseMensual: 1166.67,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 145.00 * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 10.00 * baseGuardia,
                festivo: 12.00 * baseGuardia,
                noche: 14.00 * baseGuardia
            )
        ),
        CategoriaSalarial(
            nombre: .mir2,
            sueldoBaseMensual: 1166.67,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 240.00 * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 11.50 * baseGuardia,
                festivo: 14.00 * baseGuardia,
                noche: 16.00 * baseGuardia
            )
        ),
        CategoriaSalarial(
            nombre: .mir3,
            sueldoBaseMensual: 1166.67,
            complementoDestinoMensual: 0,
            complementoEspecificoMensual: 460.00 * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 13.00 * baseGuardia,
                festivo: 16.50 * baseGuardia,
                noche: 18.00 * baseGuardia
            )
        ),
        CategoriaSalarial(
            nombre: .mir4,
            sueldoBaseMensual: 1166.67,
            complementoDestinoMensual: 423.50,
            complementoEspecificoMensual: 685.00 * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 14.00 * baseGuardia,
                festivo: 18.50 * baseGuardia,
                noche: 20.00 * baseGuardia
            )
        ),
        CategoriaSalarial(
            nombre: .mir5,
            sueldoBaseMensual: 1166.67,
            complementoDestinoMensual: 423.50,
            complementoEspecificoMensual: 750.00 * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 15.50 * baseGuardia,
                festivo: 20.00 * baseGuardia,
                noche: 22.00 * baseGuardia
            )
        ),
        CategoriaSalarial(
            nombre: .fea,
            sueldoBaseMensual: 1567.37,
            complementoDestinoMensual: 647.48,
            complementoEspecificoMensual: (1380.00 + extraSupplement) * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 23.00 * baseGuardia,
                festivo: 29.00 * baseGuardia,
                noche: 34.00 * baseGuardia
            )
        ),
        CategoriaSalarial(
            nombre: .medFamilia,
            sueldoBaseMensual: 1567.37,
            complementoDestinoMensual: 647.48,
            complementoEspecificoMensual: (1450.00 + extraSupplement) * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 23.00 * baseGuardia,
                festivo: 29.00 * baseGuardia,
                noche: 34.00 * baseGuardia
            )
        ),
        CategoriaSalarial(
            nombre: .medUrgencias,
            sueldoBaseMensual: 1567.37,
            complementoDestinoMensual: 647.48,
            complementoEspecificoMensual: (1600.00 + extraSupplement) * baseSueldo,
            precioGuardia: PrecioGuardia(
                laborable: 24.50 * baseGuardia,
                festivo: 31.00 * baseGuardia,
                noche: 36.00 * baseGuardia
            )
        )
    ]
}

// Grupos salariales por territorio
private let CAT_MADRID = createCategorias(baseSueldo: 1.0, baseGuardia: 1.0, extraSupplement: 0)
private let CAT_ANDALUCIA = createCategorias(baseSueldo: 0.95, baseGuardia: 0.95, extraSupplement: -50)
private let CAT_NORTE_ALTA = createCategorias(baseSueldo: 1.10, baseGuardia: 1.15, extraSupplement: 100)
private let CAT_INSULAR = createCategorias(baseSueldo: 1.05, baseGuardia: 1.0, extraSupplement: 300)
private let CAT_MEDIO = createCategorias(baseSueldo: 0.98, baseGuardia: 0.98, extraSupplement: 0)
private let CAT_CEUTA = createCategorias(baseSueldo: 1.2, baseGuardia: 1.1, extraSupplement: 700)

/// Datasets completos por Comunidad Autónoma
let DATASETS_CCAA: [DatasetSalarial] = [
    DatasetSalarial(ccaa: .andalucia, categorias: CAT_ANDALUCIA),
    DatasetSalarial(ccaa: .aragon, categorias: CAT_MEDIO),
    DatasetSalarial(ccaa: .asturias, categorias: CAT_MEDIO),
    DatasetSalarial(ccaa: .baleares, categorias: CAT_INSULAR),
    DatasetSalarial(ccaa: .canarias, categorias: CAT_INSULAR),
    DatasetSalarial(ccaa: .cantabria, categorias: CAT_MEDIO),
    DatasetSalarial(ccaa: .castillaLeon, categorias: CAT_ANDALUCIA),
    DatasetSalarial(ccaa: .castillaMancha, categorias: CAT_ANDALUCIA),
    DatasetSalarial(ccaa: .cataluna, categorias: CAT_MADRID),
    DatasetSalarial(ccaa: .valencia, categorias: CAT_MEDIO),
    DatasetSalarial(ccaa: .extremadura, categorias: CAT_ANDALUCIA),
    DatasetSalarial(ccaa: .galicia, categorias: CAT_MEDIO),
    DatasetSalarial(ccaa: .madrid, categorias: CAT_MADRID),
    DatasetSalarial(ccaa: .murcia, categorias: CAT_ANDALUCIA),
    DatasetSalarial(ccaa: .navarra, categorias: CAT_NORTE_ALTA),
    DatasetSalarial(ccaa: .paisVasco, categorias: CAT_NORTE_ALTA),
    DatasetSalarial(ccaa: .rioja, categorias: CAT_MEDIO),
    DatasetSalarial(ccaa: .ceutaMelilla, categorias: CAT_CEUTA),
]

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
