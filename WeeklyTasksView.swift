//
//  WeeklyTasksView.swift
//  Organize
//
//  Created by Colby Buchanan on 1/4/24.
//

import SwiftUI

struct WeeklyTasksView: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        NavigationView {
            TabView {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    DayTasksView(taskManager: taskManager, day: day)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .navigationBarTitle("Weekly Tasks")
        }
    }
}

struct DayTasksView: View {
    @ObservedObject var taskManager: TaskManager
    var day: DayOfWeek
    @State private var newTaskTitle = ""
    @State private var newTaskDuration = ""
    
    var body: some View {
        List {
            ForEach(taskManager.dailyTasks.indices, id: \.self) { index in
                                TaskRow(task: $taskManager.dailyTasks[index])
            }
            .onDelete(perform: delete)

            
            HStack {
                TextField("Task Title", text: $newTaskTitle)
                TextField("Duration in minutes", text: $newTaskDuration)
                    .keyboardType(.numberPad)
                Button("Add") {
                    addTask()
                }
            }
        }
    }
    
    private func addTask() {
        guard let duration = Int(newTaskDuration), !newTaskTitle.isEmpty else { return }
        taskManager.addWeeklyTask(title: newTaskTitle, duration: duration, dayOfWeek: day)
        newTaskTitle = ""
        newTaskDuration = ""
    }
    
    private func delete(at offsets: IndexSet) {
        taskManager.weeklyTasks[day]?.remove(atOffsets: offsets)
        taskManager.saveTasks()
    }
}

