import Foundation
import SwiftData

@Model
final class Guardia {
    @Attribute(.unique) var id: UUID
    var fecha: Date
    var tipoRaw: String
    var horas: Int
    
    var user: User?
    
    var tipo: TipoGuardia {
        get { TipoGuardia(rawValue: tipoRaw) ?? .laborable }
        set { tipoRaw = newValue.rawValue }
    }
    
    init(fecha: Date, tipo: TipoGuardia, horas: Int, user: User? = nil) {
        self.id = UUID()
        self.fecha = fecha
        self.tipoRaw = tipo.rawValue
        self.horas = horas
        self.user = user
    }
    
    var fechaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: fecha)
    }
}
