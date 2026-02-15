//
//  PermissionView.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 15.2.2026.
//

import EventKit
import SwiftUI

struct PermissionView: View {
    @Bindable var calendarManager: CalendarManager
    var body: some View {
        ContentUnavailableView {
            Label(
                "Необходим доступ к календарю",
                systemImage: "calendar.badge.exclamationmark"
            )
        } description: {
            Text(
                "Для управления расписанием приложению необходим доступ к календарю"
            )
        } actions: {
            if calendarManager.authorizationSatatus == .notDetermined {
                Button("Дать доступ к календарю") {
                    Task {
                        print(calendarManager.authorizationSatatus.rawValue)
                        await calendarManager.requestAccess()
                        print(calendarManager.authorizationSatatus.rawValue)
                    }
                }
            } else {
                Button("Открыть настройки") {
                    if let url = URL(
                        string: UIApplication.openSettingsURLString
                    ) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}

#Preview {
    PermissionView(calendarManager: CalendarManager())
}
