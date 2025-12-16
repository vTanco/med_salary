import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    let onLogout: () -> Void
    
    @State private var showLogoutAlert = false
    @State private var showResetAlert = false
    
    private var perfil: PerfilUsuario? {
        user.perfil
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section("Tu Perfil") {
                    HStack(spacing: 14) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.teal)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Configuration Section
                if let perfil = perfil {
                    Section("Configuración") {
                        NavigationLink {
                            EditConfigView(user: user, perfil: perfil)
                        } label: {
                            HStack {
                                Label("Comunidad Autónoma", systemImage: "map.fill")
                                Spacer()
                                Text(perfil.ccaa.displayName)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        NavigationLink {
                            EditConfigView(user: user, perfil: perfil)
                        } label: {
                            HStack {
                                Label("Categoría", systemImage: "stethoscope")
                                Spacer()
                                Text(perfil.categoria.displayName)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        NavigationLink {
                            EditConfigView(user: user, perfil: perfil)
                        } label: {
                            HStack {
                                Label("Situación Familiar", systemImage: "person.2.fill")
                                Spacer()
                                Text(perfil.estadoFamiliar.displayName)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // Stats Section
                Section("Estadísticas") {
                    HStack {
                        Label("Guardias registradas", systemImage: "calendar.badge.plus")
                        Spacer()
                        Text("\(user.guardias?.count ?? 0)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Miembro desde", systemImage: "clock.fill")
                        Spacer()
                        Text(user.createdAt, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Borrar todos mis datos", systemImage: "trash.fill")
                    }
                    
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                // App Info
                Section {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("MedSalary - Calculadora de salarios para médicos en España")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                }
            }
            .navigationTitle("Ajustes")
            .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar Sesión", role: .destructive) {
                    onLogout()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
            .alert("Borrar Datos", isPresented: $showResetAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Borrar Todo", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("Esto borrará todas tus guardias. Esta acción no se puede deshacer.")
            }
        }
    }
    
    private func resetData() {
        // Delete all guardias
        for guardia in user.guardias ?? [] {
            modelContext.delete(guardia)
        }
        user.guardias = []
        
        do {
            try modelContext.save()
        } catch {
            print("Error resetting data: \(error)")
        }
    }
}

// MARK: - Edit Config View
struct EditConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let user: User
    let perfil: PerfilUsuario
    
    @State private var selectedCCAA: ComunidadAutonoma
    @State private var selectedCategoria: CategoriaId
    @State private var selectedEstadoFamiliar: EstadoFamiliar
    
    init(user: User, perfil: PerfilUsuario) {
        self.user = user
        self.perfil = perfil
        _selectedCCAA = State(initialValue: perfil.ccaa)
        _selectedCategoria = State(initialValue: perfil.categoria)
        _selectedEstadoFamiliar = State(initialValue: perfil.estadoFamiliar)
    }
    
    var body: some View {
        Form {
            Section("Comunidad Autónoma") {
                Picker("CCAA", selection: $selectedCCAA) {
                    ForEach(ComunidadAutonoma.allCases, id: \.self) { ccaa in
                        Text(ccaa.displayName).tag(ccaa)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            
            Section("Categoría Profesional") {
                Picker("Categoría", selection: $selectedCategoria) {
                    ForEach(CategoriaId.allCases, id: \.self) { cat in
                        Text(cat.displayName).tag(cat)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            
            Section("Situación Familiar") {
                Picker("Estado", selection: $selectedEstadoFamiliar) {
                    ForEach(EstadoFamiliar.allCases, id: \.self) { estado in
                        Text(estado.displayName).tag(estado)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
        .navigationTitle("Editar Configuración")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    saveChanges()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func saveChanges() {
        perfil.ccaa = selectedCCAA
        perfil.categoria = selectedCategoria
        perfil.estadoFamiliar = selectedEstadoFamiliar
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving config: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, PerfilUsuario.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Dr. García", password: "1234")
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3, user: user)
    user.perfil = perfil
    container.mainContext.insert(user)
    
    return SettingsView(user: user) { }
        .modelContainer(container)
}
