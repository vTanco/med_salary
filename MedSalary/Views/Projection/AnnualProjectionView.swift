import SwiftUI
import SwiftData

struct AnnualProjectionView: View {
    let user: User
    
    private var perfil: PerfilUsuario? {
        user.perfil
    }
    
    private var annualData: (brutoFijo: Double, brutoGuardias: Double, irpf: Double, neto: Double) {
        guard let perfil = perfil else {
            return (0, 0, 0, 0)
        }
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // Get all guardias this year
        let guardiasAnio = (user.guardias ?? []).filter {
            calendar.component(.year, from: $0.fecha) == currentYear
        }
        
        // Calculate with SalaryEngine
        let salario = SalaryEngine.calcularSalario(
            ccaa: perfil.ccaa,
            categoria: perfil.categoria,
            guardiasMes: guardiasAnio, // Using annual for projection
            guardiasAnio: guardiasAnio
        )
        
        let irpfResult = IRPFEngine.calcularIRPF(
            brutoAnualEstimado: salario.brutoTotalAnualEstimado,
            brutoMensualActual: salario.brutoTotalMensual,
            estadoFamiliar: perfil.estadoFamiliar
        )
        
        let brutoAnual = salario.brutoTotalAnualEstimado
        let irpfAnual = brutoAnual * irpfResult.tipoRecomendado
        let netoAnual = brutoAnual - irpfAnual
        
        return (salario.brutoFijoAnual, salario.brutoGuardiasAnualEstimado, irpfAnual, netoAnual)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Main Card
                    VStack(spacing: 16) {
                        Text("Proyección Anual \(Calendar.current.component(.year, from: Date()))")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("\(Int(annualData.neto))€")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.teal)
                        
                        Text("Neto Estimado")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .background(
                        LinearGradient(
                            colors: [Color.teal.opacity(0.1), Color.teal.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Breakdown
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .foregroundStyle(.teal)
                            Text("Desglose Anual")
                                .font(.headline)
                            Spacer()
                        }
                        
                        ProjectionRow(title: "Salario Fijo (14 pagas)", value: annualData.brutoFijo, isPositive: true)
                        ProjectionRow(title: "Guardias (estimado)", value: annualData.brutoGuardias, isPositive: true)
                        
                        Divider()
                        
                        ProjectionRow(title: "Bruto Total", value: annualData.brutoGuardias + annualData.brutoFijo, isPositive: true, isBold: true)
                        ProjectionRow(title: "IRPF Estimado", value: annualData.irpf, isPositive: false)
                        
                        Divider()
                        
                        HStack {
                            Text("Neto Anual")
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(Int(annualData.neto))€")
                                .fontWeight(.bold)
                                .foregroundStyle(.teal)
                        }
                        .font(.title3)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Monthly Equivalent
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.orange)
                            Text("Equivalente Mensual")
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Neto/mes (12 meses)")
                            Spacer()
                            Text("\(Int(annualData.neto / 12))€")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Neto/mes (14 pagas)")
                            Spacer()
                            Text("\(Int(annualData.neto / 14))€")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Disclaimer
                    Text("* Proyección basada en guardias actuales. El resultado real puede variar.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Proyección Anual")
        }
    }
}

struct ProjectionRow: View {
    let title: String
    let value: Double
    var isPositive: Bool = true
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(isBold ? .semibold : .regular)
            Spacer()
            Text("\(isPositive ? "" : "-")\(Int(abs(value)))€")
                .foregroundColor(isPositive ? .primary : .red)
                .fontWeight(isBold ? .semibold : .regular)
        }
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
    
    return AnnualProjectionView(user: user)
        .modelContainer(container)
}
