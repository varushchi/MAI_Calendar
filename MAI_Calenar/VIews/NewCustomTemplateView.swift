//
//  NewCustomTemplateView.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 15.2.2026.
//

import SwiftUI

struct NewCustomTemplateView: View {
    @State private var vm = NewCustomTemplateViewModel()
    @State private var repeatingPicker: RepeatingPicker = .onceAWeek
    @Environment(CalendarManager.self) var calendarManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            NameSection
            BuildingSection
            TimeSection
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Создать") {
                    vm.lessonTemplate.createEventsFromTemplate(
                        calendarManager: calendarManager
                    )
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isFormValid)
            }
        }
    }

    // MARK: Form Section for displaying Names
    private var NameSection: some View {
        Section("Название") {
            TextField("Имя предмета", text: $vm.lessonTemplate.title)
            TextField("ФИО преподавателя", text: $vm.lessonTemplate.teacher)
                .autocorrectionDisabled()
        }
    }

    // MARK: Form Section for displaying Time
    private var TimeSection: some View {
        Section("Время") {
            RangedTimePickerView(
                title: "Время начала",
                selection: $vm.lessonTemplate.startDate
            )
            .onChange(of: vm.lessonTemplate.startDate) { _, newValue in
                vm.lessonTemplate.endDate = newValue.addingTimeInterval(5400)
            }
            RangedTimePickerView(
                title: "Время окончания",
                selection: $vm.lessonTemplate.endDate,
                startTime: vm.lessonTemplate.startDate
            )
            if ![.once, .custom].contains(vm.repeatingPicker) {
                Picker(
                    "День недели",
                    selection: $vm.lessonTemplate.dayOfWeek
                ) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        Text(day.name).tag(day)
                    }
                }
            }
            Picker("Повторение", selection: $vm.repeatingPicker) {
                ForEach(RepeatingPicker.allCases, id: \.self) { repeating in
                    Text(repeating.rawValue).tag(repeating)
                }
            }
            if case .everyOtherWeek = vm.repeatingPicker {
                PickDatesView(
                    date: $vm.startDate,
                    lessonTemplate: vm.lessonTemplate
                )
            } else if case .once = vm.repeatingPicker {
                PickOnceDateView(date: $vm.startDate)
            } else if case .custom = vm.repeatingPicker {
                PickCustomDatesView(dates: $vm.customDates)
            }
        }
    }

    // MARK: Form Section for displaying Building
    private var BuildingSection: some View {
        Section("Помещение") {
            HStack(spacing: 12) {
                TextField("Корпус", text: $vm.lessonTemplate.building)
                TextField("Кабинет", text: $vm.lessonTemplate.room)
            }
        }
    }
}

// MARK: Custom date picker for ranged date picking
struct RangedDatePickerView: View {
    var title: String
    @Binding var selection: Date

    var range: ClosedRange<Date> {
        let start: Date = Calendar.current.startOfDay(for: Date())
        let endDate = Semester().endDate
        let end: Date? = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: endDate
        )
        if let end = end {
            return start...end
        } else {
            return start...endDate
        }
    }

    var body: some View {
        DatePicker(
            title,
            selection: $selection,
            in: range,
            displayedComponents: .date
        )
    }
}

// MARK: Custom date picker for ranged date(hour, minute) picking
struct RangedTimePickerView: View {
    var title: String
    @Binding var selection: Date
    var startTime: Date? = nil

    var range: ClosedRange<Date> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let defaultStart = calendar.date(
            bySettingHour: 8,
            minute: 0,
            second: 0,
            of: startOfDay
        )!
        let max = calendar.date(
            bySettingHour: 22,
            minute: 0,
            second: 0,
            of: startOfDay
        )!

        var min: Date

        if let startTime = startTime {
            min = startTime.addingTimeInterval(5400)
        } else {
            min = defaultStart
        }

        return min...max
    }

    var body: some View {
        DatePicker(
            title,
            selection: $selection,
            in: range,
            displayedComponents: .hourAndMinute
        )
    }
}

// MARK: Picker for .once case
struct PickOnceDateView: View {
    @Binding var date: Date

    var body: some View {
        RangedDatePickerView(title: "Укажите дату", selection: $date)
    }
}

// MARK: Picker for .everyOtherWeek case
struct PickDatesView: View {
    @Binding var date: Date
    var lessonTemplate: LessonTemplate

    private var first: Date {
        lessonTemplate.findFirstTwoDates().0
    }
    private var second: Date {
        lessonTemplate.findFirstTwoDates().1
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Выбрерите дату первой пары")
            Picker("", selection: $date) {
                Text(first, format: .dateTime.day().month(.narrow)).tag(first)
                Text(second, format: .dateTime.day().month(.narrow)).tag(second)
            }
            .pickerStyle(.segmented)
        }
        .onAppear {
            date = first
        }
        .onChange(of: first) { _, newValue in
            date = newValue
        }

    }
}

// MARK: Picker for .custom case
struct PickCustomDatesView: View {
    @Binding var dates: [Date]
    @State private var selectedDate: Date = Date()

    var body: some View {
        RangedDatePickerView(
            title: "Укажите новую дату",
            selection: $selectedDate
        )
        .onChange(of: selectedDate) { _, newValue in
            dates.append(selectedDate)
        }
        List {
            Section("Выбранные даты:") {
                ForEach(dates.indices, id: \.self) { index in
                    Text(
                        dates[index],
                        format: .dateTime.day().month(.twoDigits)
                    )
                }
                .onDelete { indexSet in
                    dates.remove(atOffsets: indexSet)
                }
            }
        }
    }
}
