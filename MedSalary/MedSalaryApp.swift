import SwiftUI
import SwiftData

@main
struct MedSalaryApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Guardia.self,
            PerfilUsuario.self,
            FuenteIngreso.self,
            ReporteError.self,
            PlantillaGuardia.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Request notification permissions
        Task {
            _ = await IRPFNotificationService.shared.requestPermission()
        }
        
        // Seed demo user on first launch
        seedDemoUserIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func seedDemoUserIfNeeded() {
        let context = sharedModelContainer.mainContext
        
        // Check if demo user already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == "vicente.tanco@edu.uah.es" }
        )
        
        do {
            let existingUsers = try context.fetch(descriptor)
            if existingUsers.isEmpty {
                // Create demo user
                let demoUser = User(
                    email: "vicente.tanco@edu.uah.es",
                    name: "Vicente Tanco",
                    password: "admin123"
                )
                
                // Create profile for demo user
                let perfil = PerfilUsuario(
                    ccaa: .madrid,
                    categoria: .mir3,
                    estadoFamiliar: .general,
                    user: demoUser
                )
                perfil.onboardingCompleto = true
                perfil.irpfActualPorcentaje = 0.15 // 15% por defecto
                demoUser.perfil = perfil
                
                context.insert(demoUser)
                context.insert(perfil)
                
                try context.save()
                print("✅ Demo user created: vicente.tanco@edu.uah.es")
            }
        } catch {
            print("Error seeding demo user: \(error)")
        }
    }
}

