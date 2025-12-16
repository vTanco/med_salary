import Foundation

// MARK: - Categoría Profesional
enum CategoriaId: String, Codable, CaseIterable {
    case mir1 = "MIR-1"
    case mir2 = "MIR-2"
    case mir3 = "MIR-3"
    case mir4 = "MIR-4"
    case mir5 = "MIR-5"
    case fea = "Facultativo Especialista (FEA)"
    case medFamilia = "Médico de Familia (EAP)"
    case medUrgencias = "Médico Urgencias / SUMMA"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Tipo de Guardia
enum TipoGuardia: String, Codable, CaseIterable {
    case laborable = "laborable"
    case festivo = "festivo"
    case noche = "noche"
    
    var displayName: String {
        switch self {
        case .laborable: return "Laborable"
        case .festivo: return "Festivo"
        case .noche: return "Noche"
        }
    }
    
    var icon: String {
        switch self {
        case .laborable: return "sun.max.fill"
        case .festivo: return "calendar"
        case .noche: return "moon.fill"
        }
    }
}

// MARK: - Estado Familiar
enum EstadoFamiliar: String, Codable, CaseIterable {
    case general = "general"
    case conHijos = "con_hijos"
    
    var displayName: String {
        switch self {
        case .general: return "Sin hijos a cargo"
        case .conHijos: return "Con hijos a cargo"
        }
    }
}

// MARK: - Comunidades Autónomas
enum ComunidadAutonoma: String, Codable, CaseIterable {
    case andalucia = "Andalucía"
    case aragon = "Aragón"
    case asturias = "Principado de Asturias"
    case baleares = "Illes Balears"
    case canarias = "Canarias"
    case cantabria = "Cantabria"
    case castillaLeon = "Castilla y León"
    case castillaMancha = "Castilla-La Mancha"
    case cataluna = "Cataluña"
    case valencia = "Comunitat Valenciana"
    case extremadura = "Extremadura"
    case galicia = "Galicia"
    case madrid = "Madrid"
    case murcia = "Región de Murcia"
    case navarra = "Comunidad Foral de Navarra"
    case paisVasco = "País Vasco"
    case rioja = "La Rioja"
    case ceutaMelilla = "Ceuta y Melilla (INGESA)"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Precio Guardia
struct PrecioGuardia: Codable {
    let laborable: Double
    let festivo: Double
    let noche: Double
    
    func precio(para tipo: TipoGuardia) -> Double {
        switch tipo {
        case .laborable: return laborable
        case .festivo: return festivo
        case .noche: return noche
        }
    }
}

// MARK: - Categoría Salarial
struct CategoriaSalarial: Codable {
    let nombre: CategoriaId
    let sueldoBaseMensual: Double
    let complementoDestinoMensual: Double
    let complementoEspecificoMensual: Double
    let precioGuardia: PrecioGuardia
    
    var brutoFijoMensual: Double {
        sueldoBaseMensual + complementoDestinoMensual + complementoEspecificoMensual
    }
}

// MARK: - Dataset Salarial
struct DatasetSalarial {
    let ccaa: ComunidadAutonoma
    let categorias: [CategoriaSalarial]
    
    func categoria(para id: CategoriaId) -> CategoriaSalarial? {
        categorias.first { $0.nombre == id }
    }
}

// MARK: - Resultado Salario
struct ResultadoSalario {
    let brutoFijoMensual: Double
    let brutoGuardias: Double
    let brutoTotalMensual: Double
    let brutoFijoAnual: Double
    let brutoGuardiasAnualEstimado: Double
    let brutoTotalAnualEstimado: Double
}

// MARK: - Resultado IRPF
struct ResultadoIRPF {
    let tipoRecomendado: Double
    let retencionMensualEstimada: Double
    let netoMensualEstimado: Double
}

// MARK: - Tramo IRPF
struct TramoIRPF {
    let hasta: Double
    let tipo: Double
}
