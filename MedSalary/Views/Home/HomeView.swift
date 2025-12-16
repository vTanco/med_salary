import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    
    @State private var salario: ResultadoSalario?
    @State private var irpf: ResultadoIRPF?
    
    private var perfil: PerfilUsuario? {
        user.perfil
    }
    
    private var guardiasMes: [Guardia] {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        return (user.guardias ?? []).filter { guardia in
            let month = calendar.component(.month, from: guardia.fecha)
            let year = calendar.component(.year, from: guardia.fecha)
            return month == currentMonth && year == currentYear
        }
    }
    
    private var guardiasAnio: [Guardia] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        return (user.guardias ?? []).filter { guardia in
            let year = calendar.component(.year, from: guardia.fecha)
            return year == currentYear
        }
    }
    
    private var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date()).capitalized
    }
    
    private var totalHoras: Int {
        guardiasMes.reduce(0) { $0 + $1.horas }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Main Card - Net Salary
                    netSalaryCard
                    
                    // Stats Grid
                    statsGrid
                    
                    // Breakdown Card
                    breakdownCard
                }
                .padding()
            }
            .refreshable {
                calculateSalary()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                calculateSalary()
            }
            .onChange(of: user.guardias?.count) { _, _ in
                calculateSalary()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Resumen \(monthName)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Hola, \(user.name)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let perfil = perfil {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                    Text(perfil.ccaa.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
            }
        }
    }
    
    private var netSalaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Neto Estimado (Mensual)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(irpf?.netoMensualEstimado ?? 0))")
                        .font(.system(size: 40, weight: .bold))
                    Text("€")
                        .font(.title)
                }
                .foregroundStyle(.white)
            }
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bruto Total")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(Int(salario?.brutoTotalMensual ?? 0))€")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("IRPF (\(String(format: "%.1f", (irpf?.tipoRecomendado ?? 0) * 100))%)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("-\(Int(irpf?.retencionMensualEstimada ?? 0))€")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            }
            .padding()
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.teal, Color.teal.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .teal.opacity(0.3), radius: 10, y: 5)
    }
    
    private var statsGrid: some View {
        HStack(spacing: 16) {
            // Horas Guardia
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.secondary)
                    Text("HORAS GUARDIA")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                Text("\(totalHoras)h")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Este mes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5)
            
            // Bruto Guardias
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(.secondary)
                    Text("BRUTO GUARDIAS")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                Text("\(Int(salario?.brutoGuardias ?? 0))€")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Extra este mes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
    
    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundStyle(.teal)
                Text("Desglose Nómina")
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Sueldo Base + Compl.")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formatCurrency(salario?.brutoFijoMensual ?? 0))
                }
                .font(.subheadline)
                
                HStack {
                    Text("Guardias (\(guardiasMes.count))")
                        .fontWeight(.medium)
                        .foregroundStyle(.teal)
                    Spacer()
                    Text("+" + formatCurrency(salario?.brutoGuardias ?? 0))
                        .fontWeight(.medium)
                        .foregroundStyle(.teal)
                }
                .font(.subheadline)
                .padding(10)
                .background(Color.teal.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Divider()
                
                HStack {
                    Text("Total Bruto")
                        .fontWeight(.bold)
                    Spacer()
                    Text(formatCurrency(salario?.brutoTotalMensual ?? 0))
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    // MARK: - Helpers
    
    private func calculateSalary() {
        guard let perfil = perfil else { return }
        
        salario = SalaryEngine.calcularSalario(
            ccaa: perfil.ccaa,
            categoria: perfil.categoria,
            guardiasMes: guardiasMes,
            guardiasAnio: guardiasAnio
        )
        
        if let salario = salario {
            irpf = IRPFEngine.calcularIRPF(
                brutoAnualEstimado: salario.brutoTotalAnualEstimado,
                brutoMensualActual: salario.brutoTotalMensual,
                estadoFamiliar: perfil.estadoFamiliar
            )
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return String(format: "%.2f €", value)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, PerfilUsuario.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Dr. García", password: "1234")
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3, estadoFamiliar: .general, user: user)
    perfil.onboardingCompleto = true
    user.perfil = perfil
    
    container.mainContext.insert(user)
    container.mainContext.insert(perfil)
    
    return HomeView(user: user)
        .modelContainer(container)
}
