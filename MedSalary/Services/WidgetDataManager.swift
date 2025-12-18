import Foundation
import WidgetKit

/// Manager for sharing data between the main app and widgets via App Groups
class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let suiteName = "group.com.medsalary.shared"
    
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    private init() {}
    
    // MARK: - Keys
    
    private enum Keys {
        static let netoMensual = "widget_neto_mensual"
        static let horasGuardiaMes = "widget_horas_guardia_mes"
        static let brutoGuardiasMes = "widget_bruto_guardias_mes"
        static let proximaGuardia = "widget_proxima_guardia"
        static let ccaa = "widget_ccaa"
        static let categoria = "widget_categoria"
    }
    
    // MARK: - Update Widget Data
    
    /// Updates widget data from the current user session
    func updateWidgetData(
        netoMensual: Int,
        horasGuardiaMes: Int,
        brutoGuardiasMes: Int,
        proximaGuardia: Date?,
        ccaa: String,
        categoria: String
    ) {
        guard let defaults = defaults else {
            print("⚠️ App Groups not configured. Widget data not saved.")
            return
        }
        
        defaults.set(netoMensual, forKey: Keys.netoMensual)
        defaults.set(horasGuardiaMes, forKey: Keys.horasGuardiaMes)
        defaults.set(brutoGuardiasMes, forKey: Keys.brutoGuardiasMes)
        defaults.set(proximaGuardia, forKey: Keys.proximaGuardia)
        defaults.set(ccaa, forKey: Keys.ccaa)
        defaults.set(categoria, forKey: Keys.categoria)
        
        // Tell WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Updates widget data from user model and calculated salary
    func updateFromUser(
        user: User,
        netoMensual: Double,
        brutoGuardias: Double,
        totalHorasMes: Int
    ) {
        guard let perfil = user.perfil else { return }
        
        // Find next upcoming guardia
        let now = Date()
        let proximaGuardia = (user.guardias ?? [])
            .filter { $0.fecha > now }
            .sorted { $0.fecha < $1.fecha }
            .first?.fecha
        
        updateWidgetData(
            netoMensual: Int(netoMensual),
            horasGuardiaMes: totalHorasMes,
            brutoGuardiasMes: Int(brutoGuardias),
            proximaGuardia: proximaGuardia,
            ccaa: perfil.ccaa.displayName,
            categoria: perfil.categoria.displayName
        )
    }
    
    /// Clears all widget data (use on logout)
    func clearWidgetData() {
        guard let defaults = defaults else { return }
        
        defaults.removeObject(forKey: Keys.netoMensual)
        defaults.removeObject(forKey: Keys.horasGuardiaMes)
        defaults.removeObject(forKey: Keys.brutoGuardiasMes)
        defaults.removeObject(forKey: Keys.proximaGuardia)
        defaults.removeObject(forKey: Keys.ccaa)
        defaults.removeObject(forKey: Keys.categoria)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}
