//
//  Semester.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 18.2.2026.
//

import Foundation

struct Semester {
    let startDate: Date
    let endDate: Date
    
    init() {
        let today = Date()
        let calendar = Calendar.current
        
        let todayDateComponets = calendar.dateComponents([.year, .month, .day], from: today)
        
        var fallSemesterStartDateComponents = DateComponents()
        (fallSemesterStartDateComponents.month, fallSemesterStartDateComponents.day) = (9, 1)
        var fallSemesterEndDateComponents = DateComponents()
        (fallSemesterEndDateComponents.month, fallSemesterEndDateComponents.day) = (1, 31)
        
        var springSemesterStartDateComponents = DateComponents()
        (springSemesterStartDateComponents.month, springSemesterStartDateComponents.day) = (2, 10)
        var springSemesterEndDateComponents = DateComponents()
        (springSemesterEndDateComponents.month, springSemesterEndDateComponents.day) = (6, 30)
        
        
        if let month = todayDateComponets.month, month > 6 {
            fallSemesterStartDateComponents.year = todayDateComponets.year
            fallSemesterEndDateComponents.year = (todayDateComponets.year ?? 2026) + 1
            
            if let fallSemesterStartDate = calendar.date(from: fallSemesterStartDateComponents),
               let fallSemesterEndDate = calendar.date(from: fallSemesterEndDateComponents) {
                self.startDate = fallSemesterStartDate
                self.endDate = fallSemesterEndDate
            } else {
                self.startDate = today
                self.endDate = today
            }
        } else {
            springSemesterStartDateComponents.year = todayDateComponets.year
            springSemesterEndDateComponents.year = todayDateComponets.year
            
            if let springSemesterStartDate = calendar.date(from: springSemesterStartDateComponents),
               let springSemesterEndDate = calendar.date(from: springSemesterEndDateComponents) {
                self.startDate = springSemesterStartDate
                self.endDate = springSemesterEndDate
            } else {
                self.startDate = today
                self.endDate = today
            }
        }
    }
}
