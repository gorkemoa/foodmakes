import SwiftUI

struct AddToPlanSheet: View {
    let mealName: String
    let onConfirm: (Date, Date, Date?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date
    @State private var time1: Date
    @State private var time2: Date
    @State private var showTime2 = false

    private var lm: LanguageManager { LanguageManager.shared }
    private var minDate: Date { Calendar.current.startOfDay(for: Date()) }
    private var maxDate: Date { Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date() }

    init(mealName: String, onConfirm: @escaping (Date, Date, Date?) -> Void) {
        self.mealName  = mealName
        self.onConfirm = onConfirm

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        _selectedDate = State(initialValue: tomorrow)

        // Seed pickers from stored defaults (Settings page writes these)
        let h1 = UserDefaults.standard.integer(forKey: "fm_plan_notif_hour_m")
        let h2 = UserDefaults.standard.integer(forKey: "fm_plan_notif_hour_e")
        var c1 = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c1.hour = h1 == 0 ? 8 : h1; c1.minute = 0
        var c2 = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c2.hour = h2 == 0 ? 18 : h2; c2.minute = 0
        _time1 = State(initialValue: Calendar.current.date(from: c1) ?? Date())
        _time2 = State(initialValue: Calendar.current.date(from: c2) ?? Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Meal name pill
                    HStack(spacing: 8) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.warmOrange)
                        Text(mealName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.warmOrange.opacity(0.10))
                    .clipShape(Capsule())

                    // ── Date Picker ───────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        sectionLabel(lm.t.selectDate, icon: "calendar")

                        DatePicker(
                            "",
                            selection: $selectedDate,
                            in: minDate...maxDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .accentColor(Color.warmOrange)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    // ── Reminder Pickers ──────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        sectionLabel(lm.t.planReminders, icon: "bell.fill")

                        VStack(spacing: 0) {

                            // Time 1 — always shown
                            timePicker(
                                label: "1.",
                                systemImage: "bell.fill",
                                iconColor: .warmOrange,
                                binding: $time1
                            )

                            Divider().padding(.leading, 52)

                            if showTime2 {
                                // Time 2 picker
                                timePicker(
                                    label: "2.",
                                    systemImage: "bell.badge.fill",
                                    iconColor: .indigo,
                                    binding: $time2
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))

                                Divider().padding(.leading, 52)

                                // Remove second
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showTime2 = false
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Label(lm.t.removeSecondReminder, systemImage: "minus.circle.fill")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.red.opacity(0.75))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 13)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .move(edge: .top)))

                            } else {
                                // Add second
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showTime2 = true
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Label(lm.t.addSecondReminder, systemImage: "plus.circle.fill")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.warmOrange)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 13)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showTime2)
                    }

                    // ── Confirm ───────────────────────────────────────────
                    Button {
                        onConfirm(selectedDate, time1, showTime2 ? time2 : nil)
                        dismiss()
                    } label: {
                        Label(lm.t.confirmPlan, systemImage: "calendar.badge.plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.warmOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(lm.t.addToPlan)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Components

    private func timePicker(label: String, systemImage: String, iconColor: Color, binding: Binding<Date>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .clipShape(Circle())
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            DatePicker("", selection: binding, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .accentColor(Color.warmOrange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.warmOrange)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .tracking(0.5)
        }
        .padding(.leading, 4)
    }
}
