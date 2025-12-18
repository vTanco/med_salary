import Foundation
import SwiftData

@Model
final class PlantillaGuardia {
    @Attribute(.unique) var id: UUID
    var nombre: String
    var tipoRaw: String
    var horas: Int
    var hospital: String?
    var userId: UUID
    var createdAt: Date
    
    var tipo: TipoGuardia {
        get { TipoGuardia(rawValue: tipoRaw) ?? .laborable }
        set { tipoRaw = newValue.rawValue }
    }
    
    init(nombre: String, tipo: TipoGuardia, horas: Int, hospital: String? = nil, userId: UUID) {
        self.id = UUID()
        self.nombre = nombre
        self.tipoRaw = tipo.rawValue
        self.horas = horas
        self.hospital = hospital
        self.userId = userId
        self.createdAt = Date()
    }
}
