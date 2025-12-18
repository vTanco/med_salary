import Foundation
import SwiftData

/// Modelo para fuentes de ingreso adicionales (consultas privadas, docencia, etc.)
@Model
final class FuenteIngreso {
    @Attribute(.unique) var id: UUID
    var nombre: String        // Ej: "Consulta privada", "Docencia"
    var importeAnual: Double  // Bruto anual estimado
    var perfilId: UUID        // ID del perfil asociado
    
    init(nombre: String, importeAnual: Double, perfilId: UUID) {
        self.id = UUID()
        self.nombre = nombre
        self.importeAnual = importeAnual
        self.perfilId = perfilId
    }
}

