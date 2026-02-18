//
//  NewCustomTemplateViewModel.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 18.2.2026.
//

import Foundation

enum RepeatingPicker: String, CaseIterable {
    case onceAWeek = "Раз в неделю"
    case everyOtherWeek = "Раз в 2 недели"
    case once = "Один раз"
    case custom = "Свои даты"
}

@Observable
@MainActor
final class NewCustomTemplateViewModel {
    var lessonTemplate: LessonTemplate

    var repeatingPicker: RepeatingPicker {
        get {
            switch lessonTemplate.repeating {
            case .onceAWeek:
                return .onceAWeek
            case .everyOtherWeek:
                return .everyOtherWeek
            case .once:
                return .once
            case .custom:
                return .custom
            }
        }
        set {
            switch newValue {
            case .onceAWeek:
                lessonTemplate.repeating = .onceAWeek
            case .everyOtherWeek:
                lessonTemplate.repeating = .everyOtherWeek(startDate)
            case .once:
                lessonTemplate.repeating = .once(startDate)
            case .custom:
                lessonTemplate.repeating = .custom(customDates)
            }
        }
    }

    var startDate: Date {
        get {
            switch lessonTemplate.repeating {
            case .onceAWeek:
                return Calendar.current.startOfDay(for: Date())
            case .everyOtherWeek(let date):
                return date
            case .once(let date):
                return date
            case .custom(_):
                return Calendar.current.startOfDay(for: Date())
            }
        }
        set {
            switch lessonTemplate.repeating {
            case .onceAWeek:
               break
            case .everyOtherWeek(_):
                lessonTemplate.repeating = .everyOtherWeek(newValue)
            case .once(_):
                lessonTemplate.repeating = .once(newValue)
            case .custom(_):
                break
            }
            
        }
    }

    var customDates: [Date] {
        get {
            switch lessonTemplate.repeating {
            case .onceAWeek:
                return []
            case .everyOtherWeek(_):
                return []
            case .once(_):
                return []
            case .custom(let dates):
                return dates
            }
        }
        set {
            switch lessonTemplate.repeating {
            case .onceAWeek:
                break
            case .everyOtherWeek(_):
                break
            case .once(_):
                break
            case .custom(_):
                lessonTemplate.repeating = .custom(newValue)
            }
        }
    }

    init(lessonTemplate: LessonTemplate) {
        self.lessonTemplate = lessonTemplate
    }

    convenience init() {
        self.init(lessonTemplate: LessonTemplate())
    }
    
    func save() {
        startDate = Calendar.current.startOfDay(for: Date())
        customDates = []
        repeatingPicker = .onceAWeek
        
        lessonTemplate.title = ""
        lessonTemplate.teacher = ""
        lessonTemplate.dayOfWeek = .monday
        lessonTemplate.building = ""
        lessonTemplate.room = ""
    }
}
