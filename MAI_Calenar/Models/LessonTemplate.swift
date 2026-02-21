//
//  LessonTemplate.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 18.2.2026.
//

import Foundation

enum Repeating {
    case onceAWeek
    case everyOtherWeek(Date)
    case once(Date)
    case custom([Date])
}

enum DayOfWeek: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var name: String {
        switch self {
        case .sunday:
            return "Воскресенье"
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        }
    }
}

struct Time {
    let hour: Int
    let minute: Int
}

struct LessonTemplate: Identifiable {

    var id: String {
        "\(title)-\(teacher)-\(dayOfWeek.rawValue)-\(building)-\(room)"
    }

    var title: String = ""
    var teacher: String = ""

    var startDate: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    var endDate: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!.addingTimeInterval(5400)
    var repeating: Repeating = .onceAWeek
    var dayOfWeek: DayOfWeek = .monday

    private var startTime: Time {
        let startDateComponent = Calendar.current.dateComponents(
            [.hour, .minute],
            from: startDate
        )
        return Time(
            hour: startDateComponent.hour ?? 0,
            minute: startDateComponent.minute ?? 0
        )
    }

    private var endTime: Time {
        let endDateComponent = Calendar.current.dateComponents(
            [.hour, .minute],
            from: endDate
        )
        return Time(
            hour: endDateComponent.hour ?? 0,
            minute: endDateComponent.minute ?? 0
        )
    }

    var building: String = ""
    var room: String = ""

    var notes: String? {
        let teacher = self.teacher.trimmingCharacters(in: .whitespaces)
        let building = self.building.trimmingCharacters(in: .whitespaces)
        let room = self.room.trimmingCharacters(in: .whitespaces)
        if teacher.isEmpty && building.isEmpty && room.isEmpty {
            return nil
        }
        return "\(teacher): \(building)-\(room)"
    }

    static let semester = Semester()

    private func generateDateForEveryWeek(startDate: Date? = nil) -> [Date] {
        var current: Date
        var multiplier: Int = 1

        if let startDate = startDate {
            current = startDate
            multiplier = 2
        } else {
            (current, _) = findFirstTwoDates()
        }

        var generatedDates: [Date] = []

        while current <= LessonTemplate.semester.endDate {
            generatedDates.append(current)
            guard
                let next = Calendar.current.date(
                    byAdding: .weekOfYear,
                    value: multiplier,
                    to: current
                )
            else { break }
            current = next
        }
        return generatedDates
    }

    func findFirstTwoDates() -> (Date, Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todaysWeekday = calendar.component(.weekday, from: today)
        let daysToAdd = (dayOfWeek.rawValue - todaysWeekday + 7) % 7

        if let first = calendar.date(
            byAdding: .day,
            value: daysToAdd,
            to: today
        ),
            let second = calendar.date(
                byAdding: .day,
                value: daysToAdd + 7,
                to: today
            )
        {
            return (first, second)
        } else {
            return (today, today)
        }
    }

    private func convertDateToRightFormat(_ date: Date) -> (Date, Date) {
        guard
            let startDate = Calendar.current.date(
                bySettingHour: self.startTime.hour,
                minute: self.startTime.minute,
                second: 0,
                of: date
            ),
            let endDate = Calendar.current.date(
                bySettingHour: self.endTime.hour,
                minute: self.endTime.minute,
                second: 0,
                of: date
            )
        else { return (date, date) }
        return (startDate, endDate)

    }

    func createEventsFromTemplate(calendarManager: CalendarManager) {
        switch repeating {
        case .onceAWeek:
            let dates = generateDateForEveryWeek()
            for date in dates {
                let (startDate, endDate) = convertDateToRightFormat(date)
                let _ = calendarManager.createEvent(
                    title: self.title,
                    startDate: startDate,
                    endDate: endDate,
                    notes: self.notes
                )
            }
        case .everyOtherWeek(let firstDate):
            let dates = generateDateForEveryWeek(startDate: firstDate)
            for date in dates {
                let (startDate, endDate) = convertDateToRightFormat(date)
                let _ = calendarManager.createEvent(
                    title: self.title,
                    startDate: startDate,
                    endDate: endDate,
                    notes: self.notes
                )
            }
        case .once(let date):
            let (startDate, endDate) = convertDateToRightFormat(date)
            let _ = calendarManager.createEvent(
                title: self.title,
                startDate: startDate,
                endDate: endDate,
                notes: self.notes
            )
        case .custom(let dates):
            for date in dates {
                let (startDate, endDate) = convertDateToRightFormat(date)
                print(startDate)
                print(endDate)
                let _ = calendarManager.createEvent(
                    title: self.title,
                    startDate: startDate,
                    endDate: endDate,
                    notes: self.notes
                )
            }
        }
    }
}
