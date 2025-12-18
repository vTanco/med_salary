import Foundation
import UserNotifications

/// Servicio para gestionar notificaciones locales (IRPF y Guardias)
class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Permission
    
    /// Solicita permiso para enviar notificaciones
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Verifica si tenemos permiso para notificaciones
    func checkPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Shift Reminders
    
    /// Programa un recordatorio para una guardia (1 día antes a las 20:00)
    /// - Returns: El ID de la notificación programada, o nil si falla
    func scheduleShiftReminder(for guardia: Guardia) async -> String? {
        guard await checkPermission() else { return nil }
        
        let calendar = Calendar.current
        
        // Calcular fecha: 1 día antes a las 20:00
        guard let reminderDate = calendar.date(byAdding: .day, value: -1, to: guardia.fecha) else {
            return nil
        }
        
        // Si la fecha de recordatorio ya pasó, no programar
        if reminderDate < Date() {
            return nil
        }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        // Crear contenido
        let content = UNMutableNotificationContent()
        content.title = "🏥 Guardia mañana"
        
        let tipoText = guardia.tipo.displayName.lowercased()
        let horasText = "\(guardia.horas) horas"
        
        if let hospital = guardia.hospital, !hospital.isEmpty {
            content.body = "Tienes una guardia \(tipoText) de \(horasText) en \(hospital)"
        } else {
            content.body = "Tienes una guardia \(tipoText) de \(horasText)"
        }
        
        content.sound = .default
        content.categoryIdentifier = "SHIFT_REMINDER"
        
        // Crear trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // ID único para esta notificación
        let notificationId = "shift-reminder-\(guardia.id.uuidString)"
        
        let request = UNNotificationRequest(
            identifier: notificationId,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            return notificationId
        } catch {
            print("Error scheduling shift reminder: \(error)")
            return nil
        }
    }
    
    /// Cancela el recordatorio de una guardia
    func cancelShiftReminder(notificationId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationId]
        )
    }
    
    /// Cancela el recordatorio usando el ID de la guardia
    func cancelShiftReminder(for guardia: Guardia) {
        if let notificationId = guardia.recordatorioId {
            cancelShiftReminder(notificationId: notificationId)
        }
    }
    
    // MARK: - IRPF Notifications
    
    /// Programa una notificación si el usuario debe subir su IRPF
    /// Solo notifica si debe SUBIR (no si debe bajar)
    func scheduleIRPFNotificationIfNeeded(comparacion: ComparacionIRPF) {
        // Solo notificamos si necesita subir
        guard comparacion.necesitaSubir else {
            // Cancelar notificaciones pendientes si ya no es necesario
            cancelIRPFNotifications()
            return
        }
        
        Task {
            guard await checkPermission() else { return }
            
            // Crear contenido de la notificación
            let content = UNMutableNotificationContent()
            content.title = "📊 Revisa tu IRPF"
            content.body = "Tu IRPF actual (\(comparacion.porcentajeActualFormateado)) es menor que el óptimo (\(comparacion.porcentajeOptimoFormateado)). Considera ajustarlo para evitar sorpresas en la declaración."
            content.sound = .default
            
            // Programar para mañana a las 10:00
            var dateComponents = DateComponents()
            dateComponents.hour = 10
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "irpf-adjustment-reminder",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    /// Programa una notificación mensual para revisar IRPF
    func scheduleMonthlyIRPFReview() {
        Task {
            guard await checkPermission() else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "📅 Revisión mensual"
            content.body = "Es un buen momento para revisar si tu IRPF sigue siendo óptimo según tus guardias."
            content.sound = .default
            
            // Programar para el día 1 de cada mes a las 9:00
            var dateComponents = DateComponents()
            dateComponents.day = 1
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "monthly-irpf-review",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error scheduling monthly review: \(error)")
            }
        }
    }
    
    /// Cancela notificaciones de IRPF pendientes
    func cancelIRPFNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["irpf-adjustment-reminder"]
        )
    }
    
    /// Cancela todas las notificaciones
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Legacy alias for backward compatibility
typealias IRPFNotificationService = NotificationService

