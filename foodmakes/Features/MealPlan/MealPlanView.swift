import SwiftUI

struct MealPlanView: View {
    @State private var viewModel: MealPlanViewModel
    @State private var showPast = false
    private var lm: LanguageManager { LanguageManager.shared }

    init(repository: MealRepository) {
        _viewModel = State(initialValue: MealPlanViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Inline Month Calendar ─────────────────────────────
                    MonthCalendarView(
                        plans: viewModel.plans,
                        selectedDate: $viewModel.selectedDate
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                    // ── Divider ───────────────────────────────────────────
                    Rectangle()
                        .fill(Color(.separator).opacity(0.4))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    // ── Content ───────────────────────────────────────────
                    if let date = viewModel.selectedDate {
                        dayDetailSection(date: date)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    } else if viewModel.plans.isEmpty {
                        emptyState
                    } else {
                        allPlansSection
                    }

                    Color.clear.frame(height: 100)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(lm.t.mealPlanTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.plans.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            viewModel.showClearConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.red.opacity(0.8))
                        }
                    }
                }
            }
            .confirmationDialog(lm.t.clearMealPlanConfirm,
                                isPresented: $viewModel.showClearConfirm,
                                titleVisibility: .visible) {
                Button(lm.t.clearAll, role: .destructive) {
                    withAnimation { viewModel.clearAll() }
                }
            }
            .onAppear { viewModel.refresh() }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.selectedDate == nil)
        }
    }

    // MARK: - Day Detail Section
    @ViewBuilder
    private func dayDetailSection(date: Date) -> some View {
        let dayPlans = viewModel.plansForDate(date)

        VStack(alignment: .leading, spacing: 8) {
            // Header row: date label + dismiss
            HStack(alignment: .center) {
                dateLabel(date)
                    .padding(.horizontal, 16)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                        viewModel.selectedDate = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.trailing, 16)
            }
            .padding(.bottom, 4)

            if dayPlans.isEmpty {
                // Empty day state
                HStack(spacing: 14) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundStyle(Color.warmOrange.opacity(0.5))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(lm.t.noMealsPlanned)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                        Text(lm.t.noMealsPlannedHint)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(dayPlans, id: \.planId) { plan in
                        PlanMealCard(plan: plan) {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.delete(plan: plan)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - All Plans Section (no date filter)
    private var allPlansSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Upcoming
            if !viewModel.upcomingGroups.isEmpty {
                sectionHeader(lm.t.upcomingPlans, icon: "calendar")
                    .padding(.horizontal, 16)
                ForEach(viewModel.upcomingGroups, id: \.date) { group in
                    dateSectionContent(group: group)
                }
            }

            // Past (collapsible)
            if !viewModel.pastGroups.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3)) { showPast.toggle() }
                } label: {
                    sectionHeader(
                        lm.t.pastPlans + " (\(viewModel.pastGroups.flatMap(\.plans).count))",
                        icon: "clock",
                        chevron: showPast ? "chevron.up" : "chevron.down"
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if showPast {
                    ForEach(viewModel.pastGroups, id: \.date) { group in
                        dateSectionContent(group: group)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Date Section Content
    private func dateSectionContent(group: (date: Date, plans: [PersistedMealPlan])) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            dateLabel(group.date)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            VStack(spacing: 8) {
                ForEach(group.plans, id: \.planId) { plan in
                    PlanMealCard(plan: plan) {
                        withAnimation(.spring(response: 0.3)) { viewModel.delete(plan: plan) }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 4)
        }
    }

    // MARK: - Date Label
    private func dateLabel(_ date: Date) -> some View {
        let cal      = Calendar.current
        let today    = cal.startOfDay(for: Date())
        let isToday  = cal.isDate(date, inSameDayAs: today)

        let dayFormatter: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: LanguageManager.shared.current.rawValue)
            f.dateFormat = "d MMMM"
            return f
        }()
        let weekdayFormatter: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: LanguageManager.shared.current.rawValue)
            f.dateFormat = "EEEE"
            return f
        }()

        let weekday = weekdayFormatter.string(from: date).capitalized
        let dayStr  = dayFormatter.string(from: date)

        return HStack(spacing: 6) {
            if isToday {
                Circle().fill(Color.warmOrange).frame(width: 8, height: 8)
            }
            Text(weekday + "  ·  " + dayStr)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isToday ? Color.warmOrange : Color.textSecondary)
                .tracking(0.3)
                .textCase(.uppercase)
        }
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String, icon: String, chevron: String? = nil) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.warmOrange)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .tracking(0.5)
            if let ch = chevron {
                Image(systemName: ch)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
        }
        .padding(.leading, 4)
        .padding(.vertical, 6)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(Color.warmOrange.opacity(0.6))
            Text(lm.t.noMealsPlanned)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            Text(lm.t.noMealsPlannedHint)
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }
}

// MARK: - Month Calendar View
private struct MonthCalendarView: View {
    let plans: [PersistedMealPlan]
    @Binding var selectedDate: Date?

    @State private var displayMonth: Date = {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
    }()

    private let cal = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 14) {

            // ── Month navigation ──────────────────────────────────────
            HStack {
                Button { shiftMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                Spacer()
                Text(monthTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .contentTransition(.numericText())
                Spacer()
                Button { shiftMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
            }

            // ── Day grid ──────────────────────────────────────────────
            LazyVGrid(columns: columns, spacing: 4) {
                // Weekday headers
                ForEach(Array(weekdayHeaders.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 22)
                }

                // Day cells
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date {
                        CalendarDayCell(
                            date: date,
                            isSelected: selectedDate.map { cal.isDate($0, inSameDayAs: date) } ?? false,
                            isToday: cal.isDateInToday(date),
                            hasPlan: plannedDaySet.contains(cal.startOfDay(for: date))
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if let sel = selectedDate, cal.isDate(sel, inSameDayAs: date) {
                                    selectedDate = nil
                                } else {
                                    selectedDate = date
                                }
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Helpers

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: LanguageManager.shared.current.rawValue)
        f.dateFormat = "MMMM yyyy"
        return f.string(from: displayMonth).capitalized
    }

    private var weekdayHeaders: [String] {
        let f = DateFormatter()
        f.locale = Locale(identifier: LanguageManager.shared.current.rawValue)
        let all    = f.veryShortWeekdaySymbols ?? f.shortWeekdaySymbols ?? []
        let offset = cal.firstWeekday - 1         // 0 = Sunday, 1 = Monday
        guard all.count == 7 else { return all }
        return Array(all[offset...] + all[..<offset])
    }

    private var monthStart: Date {
        cal.date(from: cal.dateComponents([.year, .month], from: displayMonth))!
    }

    /// Sparse array: nil = leading/trailing empty cell, Date = real day.
    private var daysInMonth: [Date?] {
        guard let range = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
        let firstWeekday  = cal.component(.weekday, from: monthStart)
        let leadingEmpties = (firstWeekday - cal.firstWeekday + 7) % 7
        var days: [Date?]  = Array(repeating: nil, count: leadingEmpties)
        for d in range {
            days.append(cal.date(byAdding: .day, value: d - 1, to: monthStart))
        }
        return days
    }

    private var plannedDaySet: Set<Date> {
        Set(plans.map { cal.startOfDay(for: $0.plannedDate) })
    }

    private func shiftMonth(_ by: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            displayMonth = cal.date(byAdding: .month, value: by, to: displayMonth) ?? displayMonth
        }
    }
}

// MARK: - Calendar Day Cell
private struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasPlan: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                ZStack {
                    // Background circle
                    if isSelected {
                        Circle()
                            .fill(Color.warmOrange)
                            .frame(width: 34, height: 34)
                    } else if isToday {
                        Circle()
                            .strokeBorder(Color.warmOrange, lineWidth: 1.5)
                            .frame(width: 34, height: 34)
                    }

                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(
                            size: 14,
                            weight: isSelected || isToday ? .bold : .regular
                        ))
                        .foregroundStyle(
                            isSelected ? .white
                            : isToday  ? Color.warmOrange
                            : Color.textPrimary
                        )
                }
                .frame(width: 34, height: 34)

                // Plan indicator dot
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.85) : Color.warmOrange)
                    .frame(width: 4, height: 4)
                    .opacity(hasPlan ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Plan Meal Card
private struct PlanMealCard: View {
    let plan: PersistedMealPlan
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            AsyncMealImage(url: plan.thumbnailURL.flatMap(URL.init))
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(plan.mealName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.warmOrange)
                    Text(notifTimeLabel)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.red.opacity(0.7))
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Parse encoded times from notif IDs
    // IDs follow format: fm_plan_m_{mealId}_t{h}x{m}_{stamp}
    private var notifTimeLabel: String {
        let t1 = parseTime(from: plan.morningNotifId)
        let t2 = plan.eveningNotifId.isEmpty ? nil : parseTime(from: plan.eveningNotifId)
        if let t1 {
            return t2.map { "\(t1)  ·  \($0)" } ?? t1
        }
        return "– : –"
    }

    private func parseTime(from id: String) -> String? {
        // Find "_t{h}x{m}_" segment
        let parts = id.components(separatedBy: "_")
        guard let tPart = parts.first(where: { $0.hasPrefix("t") && $0.contains("x") }) else { return nil }
        let inner = tPart.dropFirst()            // drop "t"
        let sub   = inner.components(separatedBy: "x")
        guard sub.count == 2,
              let h = Int(sub[0]), (0..<24).contains(h),
              let m = Int(sub[1]), (0..<60).contains(m) else { return nil }
        return String(format: "%02d:%02d", h, m)
    }
}
