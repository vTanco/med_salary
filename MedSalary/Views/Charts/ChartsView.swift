import SwiftUI
import Charts
import SwiftData

struct ChartsView: View {
    let user: User
    
    private var last6MonthsData: [(month: String, earnings: Double)] {
        let calendar = Calendar.current
        let now = Date()
        
        var data: [(String, Double)] = []
        
        for i in (0..<6).reversed() {
            guard let date = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            
            // Get guardias for this month
            let monthGuardias = (user.guardias ?? []).filter { guardia in
                let gMonth = calendar.component(.month, from: guardia.fecha)
                let gYear = calendar.component(.year, from: guardia.fecha)
                return gMonth == month && gYear == year
            }
            
            // Calculate earnings
            var earnings: Double = 0
            if let perfil = user.perfil,
               let config = SalaryEngine.getConfig(ccaa: perfil.ccaa, categoria: perfil.categoria) {
                earnings = config.brutoFijoMensual
                for guardia in monthGuardias {
                    earnings += Double(guardia.horas) * config.precioGuardia.precio(para: guardia.tipo)
                }
            }
            
            // Format month name
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateFormat = "MMM"
            let monthName = formatter.string(from: date).capitalized
            
            data.append((monthName, earnings))
        }
        
        return data
    }
    
    private var totalGuardias: Int {
        user.guardias?.count ?? 0
    }
    
    private var totalHorasAnio: Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return (user.guardias ?? [])
            .filter { calendar.component(.year, from: $0.fecha) == currentYear }
            .reduce(0) { $0 + $1.horas }
    }
    
    private var promedioMensual: Double {
        let data = last6MonthsData
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0.0) { $0 + $1.earnings }
        return total / Double(data.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Chart Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundStyle(.teal)
                            Text("Evolución Mensual")
                                .font(.headline)
                        }
                        
                        Chart(last6MonthsData, id: \.month) { item in
                            BarMark(
                                x: .value("Mes", item.month),
                                y: .value("Ingresos", item.earnings)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.teal, .teal.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(6)
                        }
                        .frame(height: 200)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let intValue = value.as(Int.self) {
                                        Text("\(intValue / 1000)k€")
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Stats Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Promedio Mensual",
                            value: "\(Int(promedioMensual))€",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .teal
                        )
                        
                        StatCard(
                            title: "Total Guardias",
                            value: "\(totalGuardias)",
                            icon: "calendar.badge.plus",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Horas Este Año",
                            value: "\(totalHorasAnio)h",
                            icon: "clock.fill",
                            color: .purple
                        )
                        
                        StatCard(
                            title: "Meses Analizados",
                            value: "6",
                            icon: "calendar",
                            color: .blue
                        )
                    }
                    
                    // Monthly Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundStyle(.teal)
                            Text("Desglose por Mes")
                                .font(.headline)
                        }
                        
                        ForEach(last6MonthsData, id: \.month) { item in
                            HStack {
                                Text(item.month)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(item.earnings))€")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            
                            if item.month != last6MonthsData.last?.month {
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Estadísticas")
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, PerfilUsuario.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Dr. García", password: "1234")
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3, user: user)
    perfil.onboardingCompleto = true
    user.perfil = perfil
    
    container.mainContext.insert(user)
    
    return ChartsView(user: user)
        .modelContainer(container)
}
