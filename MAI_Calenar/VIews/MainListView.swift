//
//  MainListView.swift
//  MAI_Calenar
//
//  Created by Vadimaty Shchigol on 15.2.2026.
//

import EventKit
import SwiftUI

struct MainListView: View {
    @State private var calendarManager = CalendarManager()

    var body: some View {
        NavigationStack {
            Group {
                if calendarManager.authorizationSatatus == .fullAccess {
                    EventListView(calendarManager: calendarManager)
                } else {
                    PermissionView(calendarManager: calendarManager)
                }
            }
            .navigationTitle("События")
            .toolbar {
                if calendarManager.authorizationSatatus == .fullAccess {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            NavigationLink {
                                NewCustomEventView()
                            } label: {
                                Text("Создать новую пару")
                            }
                            NavigationLink {
                                ImportLMSView()
                            } label: {
                                Text("Импортировать пары из ЛМС")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                }
            }
        }
        .task {
            calendarManager.checkAuthStatus()
            if calendarManager.authorizationSatatus == .notDetermined {
                await calendarManager.requestAccess()
            } else if calendarManager.authorizationSatatus == .fullAccess {
                calendarManager.fetchEvents()
            }
        }
    }
}

#Preview {
    MainListView()
}
