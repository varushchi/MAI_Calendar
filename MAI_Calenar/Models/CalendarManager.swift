//
//  CalendarManager.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 12.2.2026.
//

import EventKit
import Observation

@Observable
@MainActor
final class CalendarManager {
    private let eventStore = EKEventStore()

    private(set) var events: [EKEvent] = []
    private(set) var authorizationSatatus: EKAuthorizationStatus = .notDetermined

    var errorMsg: String?

    func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()

            if granted {
                authorizationSatatus = .fullAccess
            } else {
                errorMsg = "Calendar access denied. Enable in Settings"
            }
        } catch {
            errorMsg = "Failed to request access \(error.localizedDescription)"
        }
    }

    func checkAuthStatus() {
        authorizationSatatus = EKEventStore.authorizationStatus(for: .event)
    }

    func fetchEvents() {
        let startDate = Date()
        guard
            let endDate = Calendar.current.date(
                byAdding: .day,
                value: 7,
                to: startDate
            )
        else { return }

        let calendars = eventStore.calendars(for: .event)

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars.filter {$0.type == .local}
        )

        let fetchedEvents = eventStore.events(matching: predicate)
        events = fetchedEvents.sorted { $0.startDate < $1.startDate }
    }

    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String? = nil
    ) -> Bool {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.notes = notes

        newEvent.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
            fetchEvents()
            return true
        } catch {
            errorMsg = "Failed to save event \(error.localizedDescription)"
            return false
        }
    }

    func updateEvent(
        event: EKEvent,
        newTitle: String?,
        newStartDate: Date?,
        newEndDate: Date?,
        newNotes: String? = nil
    ) -> Bool {
        if let title = newTitle { event.title = title }
        if let startDate = newStartDate { event.startDate = startDate }
        if let endDate = newEndDate { event.endDate = endDate }
        if let notes = newNotes { event.notes = notes }

        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            fetchEvents()
            return true
        } catch {
            errorMsg = "Failed to update event \(error.localizedDescription)"
            return false
        }
    }

    func deleteEvent(event: EKEvent) -> Bool {
        do {
            try eventStore.remove(event, span: .thisEvent, commit: true)
            fetchEvents()
            return true
        } catch {
            errorMsg = "Failed to delete event \(error.localizedDescription)"
            return false
        }
    }
}
