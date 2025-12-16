import Foundation
import SwiftData

@Model
final class PerfilUsuario {
    @Attribute(.unique) var id: UUID
    var ccaaRaw: String
    var categoriaRaw: String
    var estadoFamiliarRaw: String
    var onboardingCompleto: Bool
    
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
    
    init(ccaa: ComunidadAutonoma = .madrid, 
         categoria: CategoriaId = .mir1, 
         estadoFamiliar: EstadoFamiliar = .general,
         user: User? = nil) {
        self.id = UUID()
        self.ccaaRaw = ccaa.rawValue
        self.categoriaRaw = categoria.rawValue
        self.estadoFamiliarRaw = estadoFamiliar.rawValue
        self.onboardingCompleto = false
        self.user = user
    }
}
