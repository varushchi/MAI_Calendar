//
//  EventListView.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 15.2.2026.
//

import EventKit
import SwiftUI

struct EventListView: View {
    @Environment(CalendarManager.self) var calendarManager
    var body: some View {
        List {
            if !calendarManager.events.isEmpty {
                ForEach(calendarManager.events, id: \.eventIdentifier) { event in
                    Text(event.title)
                }
                .task {
                    calendarManager.fetchEvents()
                }
            } else {
                ContentUnavailableView {
                    Label(
                        "Нет пар в расписании",
                        systemImage: "calendar.badge.minus"
                    )
                } description: {
                    Text("Пары за следющие 7 дней пояятся здесь")
                }
            }
        }
        .refreshable {
            calendarManager.fetchEvents()
        }
    }
}

#Preview {
    EventListView()
}
