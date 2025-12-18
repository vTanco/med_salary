import WidgetKit
import SwiftUI

// MARK: - Widget Data

struct WidgetData {
    let netoMensual: Int
    let horasGuardiaMes: Int
    let brutoGuardiasMes: Int
    let proximaGuardia: Date?
    let ccaa: String
    let categoria: String
    
    static let placeholder = WidgetData(
        netoMensual: 2450,
        horasGuardiaMes: 48,
        brutoGuardiasMes: 720,
        proximaGuardia: Date().addingTimeInterval(86400 * 2),
        ccaa: "Madrid",
        categoria: "MIR-3"
    )
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: .placeholder)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), data: loadWidgetData())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: Date(), data: loadWidgetData())
        
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadWidgetData() -> WidgetData {
        // Load data from shared UserDefaults (App Group required)
        let defaults = UserDefaults(suiteName: "group.com.medsalary.shared") ?? .standard
        
        return WidgetData(
            netoMensual: defaults.integer(forKey: "widget_neto_mensual"),
            horasGuardiaMes: defaults.integer(forKey: "widget_horas_guardia_mes"),
            brutoGuardiasMes: defaults.integer(forKey: "widget_bruto_guardias_mes"),
            proximaGuardia: defaults.object(forKey: "widget_proxima_guardia") as? Date,
            ccaa: defaults.string(forKey: "widget_ccaa") ?? "No configurado",
            categoria: defaults.string(forKey: "widget_categoria") ?? "-"
        )
    }
}

// MARK: - Timeline Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Widget Views

struct MedSalaryWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .systemLarge:
            LargeWidgetView(data: entry.data)
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "stethoscope")
                    .font(.caption)
                Text("MedSalary")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.teal)
            
            Spacer()
            
            Text("\(data.netoMensual)€")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("Neto mensual")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Main salary info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "stethoscope")
                        .font(.caption)
                    Text("MedSalary")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.teal)
                
                Spacer()
                
                Text("\(data.netoMensual)€")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Neto mensual estimado")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Right: Stats
            VStack(alignment: .leading, spacing: 12) {
                StatRow(icon: "clock.fill", title: "Horas guardia", value: "\(data.horasGuardiaMes)h")
                StatRow(icon: "eurosign.circle.fill", title: "Bruto guardias", value: "+\(data.brutoGuardiasMes)€")
                
                if let proxima = data.proximaGuardia {
                    StatRow(icon: "calendar", title: "Próxima", value: formatProxima(proxima))
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func formatProxima(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEE d"
        return formatter.string(from: date)
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.teal)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.caption)
                        Text("MedSalary")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.teal)
                    
                    Text(data.ccaa)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(data.categoria)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.teal.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            // Main Amount
            VStack(alignment: .leading, spacing: 4) {
                Text("\(data.netoMensual)€")
                    .font(.system(size: 40, weight: .bold))
                
                Text("Neto mensual estimado")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Stats Grid
            HStack(spacing: 16) {
                LargeStatCard(icon: "clock.fill", title: "Horas", value: "\(data.horasGuardiaMes)h", color: .orange)
                LargeStatCard(icon: "eurosign.circle.fill", title: "Bruto", value: "+\(data.brutoGuardiasMes)€", color: .green)
            }
            
            // Next shift
            if let proxima = data.proximaGuardia {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.teal)
                    
                    VStack(alignment: .leading) {
                        Text("Próxima guardia")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatProximaFull(proxima))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func formatProximaFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter.string(from: date).capitalized
    }
}

struct LargeStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Widget Configuration

struct MedSalaryWidget: Widget {
    let kind: String = "MedSalaryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MedSalaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MedSalary")
        .description("Consulta tu salario neto estimado y guardias del mes.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    MedSalaryWidget()
} timeline: {
    SimpleEntry(date: .now, data: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    MedSalaryWidget()
} timeline: {
    SimpleEntry(date: .now, data: .placeholder)
}

#Preview("Large", as: .systemLarge) {
    MedSalaryWidget()
} timeline: {
    SimpleEntry(date: .now, data: .placeholder)
}
