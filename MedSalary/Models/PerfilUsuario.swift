import Foundation
import SwiftData

@Model
final class PerfilUsuario {
    @Attribute(.unique) var id: UUID
    var ccaaRaw: String
    var categoriaRaw: String
    var estadoFamiliarRaw: String
    var onboardingCompleto: Bool
    
    // Complementos personalizados
    var usarComplementosPersonalizados: Bool
    var sueldoBaseMensual: Double?
    var complementoDestinoMensual: Double?
    var complementoEspecificoMensual: Double?
    var complementoProductividadMensual: Double?
    var complementoCarreraMensual: Double?
    var otrosComplementosMensual: Double?
    
    // Precios de guardia personalizados
    var precioGuardiaLaborable: Double?
    var precioGuardiaFestivo: Double?
    var precioGuardiaNoche: Double?
    
    // IRPF actual del usuario
    var irpfActualPorcentaje: Double?  // Porcentaje actual configurado por el usuario (ej: 0.15 = 15%)
    
    var user: User?
    
    var ccaa: ComunidadAutonoma {
        get { ComunidadAutonoma(rawValue: ccaaRaw) ?? .madrid }
        set { ccaaRaw = newValue.rawValue }
    }
    
    var categoria: CategoriaId {
        get { CategoriaId(rawValue: categoriaRaw) ?? .mir1 }
        set { categoriaRaw = newValue.rawValue }
    }
    
    var estadoFamiliar: EstadoFamiliar {
        get { EstadoFamiliar(rawValue: estadoFamiliarRaw) ?? .general }
        set { estadoFamiliarRaw = newValue.rawValue }
    }
    
    // Computed: Total bruto fijo mensual personalizado
    var brutoFijoMensualPersonalizado: Double {
        let base = sueldoBaseMensual ?? 0
        let destino = complementoDestinoMensual ?? 0
        let especifico = complementoEspecificoMensual ?? 0
        let productividad = complementoProductividadMensual ?? 0
        let carrera = complementoCarreraMensual ?? 0
        let otros = otrosComplementosMensual ?? 0
        return base + destino + especifico + productividad + carrera + otros
    }
    
    // Computed: Precio guardia personalizado
    func precioGuardiaPersonalizado(para tipo: TipoGuardia) -> Double? {
        guard usarComplementosPersonalizados else { return nil }
        switch tipo {
        case .laborable: return precioGuardiaLaborable
        case .festivo: return precioGuardiaFestivo
        case .noche: return precioGuardiaNoche
        }
    }
    
    init(ccaa: ComunidadAutonoma = .madrid, 
         categoria: CategoriaId = .mir1, 
         estadoFamiliar: EstadoFamiliar = .general,
         user: User? = nil) {
        self.id = UUID()
        self.ccaaRaw = ccaa.rawValue
        self.categoriaRaw = categoria.rawValue
        self.estadoFamiliarRaw = estadoFamiliar.rawValue
        self.onboardingCompleto = false
        self.usarComplementosPersonalizados = false
        self.user = user
    }
}
