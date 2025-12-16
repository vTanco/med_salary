import SwiftUI
import SwiftData

struct CCAAComparatorView: View {
    let user: User
    
    @State private var selectedCategoria: CategoriaId
    
    init(user: User) {
        self.user = user
        _selectedCategoria = State(initialValue: user.perfil?.categoria ?? .mir3)
    }
    
    private var comparisonData: [(ccaa: ComunidadAutonoma, salary: Double)] {
        ComunidadAutonoma.allCases.compactMap { ccaa in
            guard let config = SalaryEngine.getConfig(ccaa: ccaa, categoria: selectedCategoria) else {
                return nil
            }
            return (ccaa, config.brutoFijoMensual)
        }
        .sorted { $0.salary > $1.salary }
    }
    
    private var maxSalary: Double {
        comparisonData.first?.salary ?? 1
    }
    
    private var userCCAA: ComunidadAutonoma? {
        user.perfil?.ccaa
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Category Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Categoría a comparar", systemImage: "person.fill")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Picker("Categoría", selection: $selectedCategoria) {
                            ForEach(CategoriaId.allCases, id: \.self) { cat in
                                Text(cat.displayName).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.teal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Comparison List
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .foregroundStyle(.teal)
                            Text("Comparativa por CCAA")
                                .font(.headline)
                        }
                        
                        ForEach(comparisonData, id: \.ccaa) { item in
                            VStack(spacing: 8) {
                                HStack {
                                    HStack(spacing: 8) {
                                        if item.ccaa == userCCAA {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                                .font(.caption)
                                        }
                                        Text(item.ccaa.displayName)
                                            .fontWeight(item.ccaa == userCCAA ? .bold : .regular)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(item.salary))€")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(item.ccaa == userCCAA ? .teal : .primary)
                                }
                                
                                // Progress bar
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(item.ccaa == userCCAA ? Color.teal : Color.gray.opacity(0.5))
                                            .frame(width: geo.size.width * (item.salary / maxSalary), height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Legend
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                            Text("Tu CCAA actual")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Comparador CCAA")
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
    
    return CCAAComparatorView(user: user)
        .modelContainer(container)
}
