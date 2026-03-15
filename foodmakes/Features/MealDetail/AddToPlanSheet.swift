import SwiftUI

struct AddToPlanSheet: View {
    let mealName: String
    let onConfirm: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("fm_plan_notif_hour_m") private var planMorningHour: Int = 8
    @AppStorage("fm_plan_notif_hour_e") private var planEveningHour: Int = 18
    @State private var selectedDate: Date = {
        // Default to tomorrow
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }()
    private var lm: LanguageManager { LanguageManager.shared }

    private var minDate: Date { Calendar.current.startOfDay(for: Date()) }
    private var maxDate: Date { Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date() }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 24) {
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

                    // Date Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text(lm.t.selectDate.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                            .tracking(0.5)
                            .padding(.leading, 4)

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

                    // Reminder note
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.warmOrange)
                        Text("\(lm.t.morningReminder) \(String(format: "%02d:00", planMorningHour))  ·  \(lm.t.eveningReminder) \(String(format: "%02d:00", planEveningHour))")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Spacer()

                    // Confirm button
                    Button {
                        onConfirm(selectedDate)
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
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
}
