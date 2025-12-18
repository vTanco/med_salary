import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    
    let user: User
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showAddShift = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var guardias: [Guardia] {
        user.guardias ?? []
    }
    
    private var monthString: String {
        dateFormatter.string(from: currentMonth).capitalized
    }
    
    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }
    }
    
    private var firstWeekdayOfMonth: Int {
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let weekday = calendar.component(.weekday, from: firstDay)
        // Adjust for Monday start (Spain)
        return (weekday + 5) % 7
    }
    
    private var selectedDateGuardias: [Guardia] {
        guardias.filter { calendar.isDate($0.fecha, inSameDayAs: selectedDate) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Header
                calendarHeader
                
                // Weekday Headers
                weekdayHeaders
                
                // Calendar Grid
                calendarGrid
                
                Divider()
                    .padding(.top, 8)
                
                // Selected Day Detail
                selectedDayDetail
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calendario")
            .sheet(isPresented: $showAddShift) {
                AddShiftView(user: user) {
                    showAddShift = false
                }
            }
        }
    }
    
    // MARK: - Calendar Header
    
    private var calendarHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.teal)
            }
            
            Spacer()
            
            Text(monthString)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.teal)
            }
        }
        .padding()
    }
    
    // MARK: - Weekday Headers
    
    private var weekdayHeaders: some View {
        let weekdays = ["L", "M", "X", "J", "V", "S", "D"]
        
        return HStack {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            // Empty cells for offset
            ForEach(0..<firstWeekdayOfMonth, id: \.self) { _ in
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
            
            // Days of month
            ForEach(daysInMonth, id: \.self) { date in
                dayCell(for: date)
            }
        }
        .padding(.horizontal)
    }
    
    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let dayGuardias = guardias.filter { calendar.isDate($0.fecha, inSameDayAs: date) }
        let hasGuardia = !dayGuardias.isEmpty
        
        return Button {
            withAnimation(.spring(response: 0.2)) {
                selectedDate = date
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : (isToday ? .teal : .primary))
                
                if hasGuardia {
                    HStack(spacing: 2) {
                        ForEach(dayGuardias.prefix(3), id: \.id) { guardia in
                            Circle()
                                .fill(colorForTipo(guardia.tipo))
                                .frame(width: 5, height: 5)
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.teal : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Selected Day Detail
    
    private var selectedDayDetail: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(formatSelectedDate())
                        .font(.headline)
                    Text(selectedDateGuardias.isEmpty ? "Sin guardias" : "\(selectedDateGuardias.count) guardia(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    selectedDate = selectedDate // Keep the selected date
                    showAddShift = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.teal)
                }
            }
            
            if !selectedDateGuardias.isEmpty {
                ForEach(selectedDateGuardias, id: \.id) { guardia in
                    HStack(spacing: 12) {
                        Image(systemName: guardia.tipo.icon)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(colorForTipo(guardia.tipo))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(guardia.tipo.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("\(guardia.horas) horas")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if let perfil = user.perfil,
                           let config = SalaryEngine.getConfig(ccaa: perfil.ccaa, categoria: perfil.categoria) {
                            let earnings = Double(guardia.horas) * config.precioGuardia.precio(para: guardia.tipo)
                            Text("+\(Int(earnings))€")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.teal)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    private func colorForTipo(_ tipo: TipoGuardia) -> Color {
        switch tipo {
        case .laborable: return .orange
        case .festivo: return .purple
        case .noche: return .indigo
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter.string(from: selectedDate).capitalized
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Guardia.self, PerfilUsuario.self, configurations: config)
    
    let user = User(email: "test@test.com", name: "Dr. García", password: "1234")
    let perfil = PerfilUsuario(ccaa: .madrid, categoria: .mir3, user: user)
    perfil.onboardingCompleto = true
    user.perfil = perfil
    
    // Add sample guardias
    let g1 = Guardia(fecha: Date(), tipo: .laborable, horas: 12, user: user)
    let g2 = Guardia(fecha: Date().addingTimeInterval(-86400 * 3), tipo: .noche, horas: 17, user: user)
    user.guardias = [g1, g2]
    
    container.mainContext.insert(user)
    
    return CalendarView(user: user)
        .modelContainer(container)
}
