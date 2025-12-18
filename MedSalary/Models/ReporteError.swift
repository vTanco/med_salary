import Foundation
import SwiftData

/// Modelo para reportes de errores en cifras salariales
@Model
final class ReporteError {
    @Attribute(.unique) var id: UUID
    var fecha: Date
    var ccaa: String
    var categoria: String
    var descripcion: String
    var valorIncorrecto: String?
    var valorCorrecto: String?
    var enviado: Bool
    
    init(ccaa: String, categoria: String, descripcion: String, valorIncorrecto: String? = nil, valorCorrecto: String? = nil) {
        self.id = UUID()
        self.fecha = Date()
        self.ccaa = ccaa
        self.categoria = categoria
        self.descripcion = descripcion
        self.valorIncorrecto = valorIncorrecto
        self.valorCorrecto = valorCorrecto
        self.enviado = false
    }
}
