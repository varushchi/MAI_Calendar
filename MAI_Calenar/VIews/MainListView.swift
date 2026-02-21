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
                    EventListView()
                } else {
                    PermissionView()
                }
            }
            .navigationTitle("Расписание")
            .toolbar {
                if calendarManager.authorizationSatatus == .fullAccess {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            NavigationLink {
                                NewCustomTemplateView()
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
        .environment(calendarManager)
    }
}

#Preview {
    MainListView()
}
