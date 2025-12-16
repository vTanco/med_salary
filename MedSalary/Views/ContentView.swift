import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var currentUser: User?
    @State private var needsOnboarding = false
    @State private var showLogin = true
    
    var body: some View {
        Group {
            if let user = currentUser {
                if needsOnboarding {
                    OnboardingView(user: user) {
                        needsOnboarding = false
                    }
                } else {
                    MainTabView(user: user) {
                        logout()
                    }
                }
            } else {
                if showLogin {
                    LoginView(
                        onLogin: { user in
                            login(user: user)
                        },
                        onGoToRegister: {
                            showLogin = false
                        }
                    )
                } else {
                    RegisterView(
                        modelContext: modelContext,
                        onRegister: { user in
                            login(user: user)
                        },
                        onGoToLogin: {
                            showLogin = true
                        }
                    )
                }
            }
        }
    }
    
    private func login(user: User) {
        currentUser = user
        if user.perfil == nil || user.perfil?.onboardingCompleto == false {
            needsOnboarding = true
        } else {
            needsOnboarding = false
        }
    }
    
    private func logout() {
        currentUser = nil
        showLogin = true
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    let user: User
    let onLogout: () -> Void
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(user: user)
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)
            
            AddShiftView(user: user) {
                selectedTab = 0
            }
                .tabItem {
                    Label("Añadir", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            HistoryView(user: user)
                .tabItem {
                    Label("Historial", systemImage: "clock.fill")
                }
                .tag(2)
            
            ChartsView(user: user)
                .tabItem {
                    Label("Gráficas", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView(user: user, onLogout: onLogout)
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.teal)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Guardia.self, PerfilUsuario.self], inMemory: true)
}
