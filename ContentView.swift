//
//  ContentView.swift
//  Organize
//
//  Created by Colby Buchanan on 12/24/23.

import SwiftUI

struct ContentView: View {
    @StateObject var taskManager = TaskManager()
    @State var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            DailyTasksView(taskManager: taskManager)
                .tag(0)
                .tabItem { Image(systemName: "sun.max") }
            WeeklyTasksView(taskManager: taskManager)
                .tag(1)
                .tabItem { Image(systemName: "calendar") }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear {
            taskManager.resetDailyTasksIfNeeded()
        }
    }
}
extension TaskManager {
    // Resets daily tasks if the current day has changed since last launch
    func resetDailyTasksIfNeeded() {
        let lastResetDay = UserDefaults.standard.string(forKey: "lastResetDay") ?? ""
        let todayString = currentDayOfWeek().rawValue
        
        if lastResetDay != todayString {
            // Reset daily tasks
            for i in 0..<dailyTasks.count {
                dailyTasks[i].isCompleted = false
            }
            saveTasks()

            // Update last reset day
            UserDefaults.standard.set(todayString, forKey: "lastResetDay")
        }
        
        // Reload tasks to include today's weekly tasks
        loadTasks()
    }
}
