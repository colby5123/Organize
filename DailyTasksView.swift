//
//  DailyTasksView.swift
//  Organize
//
//  Created by Colby Buchanan on 1/4/24.
//

// DailyTasksView.swift
import SwiftUI

struct DailyTasksView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var newTaskTitle = ""
    @State private var newTaskDuration = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(taskManager.dailyTasks.indices, id: \.self) { index in
                                    TaskRow(task: $taskManager.dailyTasks[index])
                }
                .onDelete(perform: delete)

                HStack {
                    TextField("Task Title", text: $newTaskTitle)
                    TextField("Duration in minutes", text: $newTaskDuration)
                        .keyboardType(.numberPad)
                    Button("Add", action: addTask)
                }
            }
            .navigationBarTitle("Daily Tasks")
        }
    }

    private func addTask() {
        guard let duration = Int(newTaskDuration), !newTaskTitle.isEmpty else { return }
        let newTask = Task(title: newTaskTitle, duration: duration, isCompleted: false)
        taskManager.dailyTasks.append(newTask)
        taskManager.saveTasks()
        newTaskTitle = ""
        newTaskDuration = ""
    }

    private func delete(at offsets: IndexSet) {
        taskManager.dailyTasks.remove(atOffsets: offsets)
        taskManager.saveTasks()
    }
}
