import Foundation
import SwiftData

@Model
final class Guardia {
    @Attribute(.unique) var id: UUID
    var fecha: Date
    var tipoRaw: String
    var horas: Int
    var notas: String?
    var hospital: String?
    var recordatorioActivo: Bool
    var recordatorioId: String?
    
    var user: User?
    
    var tipo: TipoGuardia {
        get { TipoGuardia(rawValue: tipoRaw) ?? .laborable }
        set { tipoRaw = newValue.rawValue }
    }
    
    init(fecha: Date, tipo: TipoGuardia, horas: Int, notas: String? = nil, hospital: String? = nil, recordatorioActivo: Bool = false, user: User? = nil) {
        self.id = UUID()
        self.fecha = fecha
        self.tipoRaw = tipo.rawValue
        self.horas = horas
        self.notas = notas
        self.hospital = hospital
        self.recordatorioActivo = recordatorioActivo
        self.recordatorioId = nil
        self.user = user
    }
    
    var fechaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: fecha)
    }
    
    /// Check if same date already has a shift
    static func existsOnDate(_ date: Date, for user: User) -> Bool {
        let calendar = Calendar.current
        return (user.guardias ?? []).contains { guardia in
            calendar.isDate(guardia.fecha, inSameDayAs: date)
        }
    }
}

