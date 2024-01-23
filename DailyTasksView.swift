//
//  DailyTasksView.swift
//  Organize
//
//  Created by Colby Buchanan on 1/4/24.
//

import SwiftUI

// Task structure
struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var duration: Int
    var isCompleted: Bool
    var type: String
    
    var dictionaryRepresentation: [String: Any] {
        return ["id": id.uuidString, "title": title, "duration": duration, "isCompleted": isCompleted, "type": type]
    }
    
    static func from(dictionary: [String: Any]) -> Task? {
        guard let idString = dictionary["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = dictionary["title"] as? String,
              let duration = dictionary["duration"] as? Int,
              let isCompleted = dictionary["isCompleted"] as? Bool,
              let type = dictionary["type"] as? String else { return nil }
        return Task(id: id, title: title, duration: duration, isCompleted: isCompleted, type: type)
    }
}

// UserDefaults keys
let dailyTasksKey = "dailyTasks"
let weeklyTasksKeyPrefix = "weeklyTasks_" // appended with day of the week for weekly tasks

// Main View
struct DailyTasksView: View {
    @State private var newTaskTitle: String = ""
    @State private var newTaskDuration: String = ""
    @State private var tasks: [Task] = []
    @State private var isPresentingWeeklyTasks = false
    @State private var isPresentingTimerForTask: Task?
    
    var body: some View {
        NavigationStack {
            VStack {
                addTaskSection
                taskList
            }
            .navigationTitle("Daily Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Weekly") {
                        isPresentingWeeklyTasks = true
                    }
                }
            }
            .sheet(item: $isPresentingTimerForTask) { task in
                if let taskIndex = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    TimerView(task: self.$tasks[taskIndex],
                              secondsRemaining: self.tasks[taskIndex].duration * 60,
                              onSave: self.saveTasks) // No need for braces here
                    
                }
            }
            .navigationDestination(isPresented: $isPresentingWeeklyTasks) {
                WeeklyTasksSpreadView()
            }
            .onAppear {
                self.loadTasks()
            }
            .navigationDestination(isPresented: $isPresentingWeeklyTasks) {
                WeeklyTasksSpreadView()
            }
            .onAppear {
                self.loadTasks()
            }
        }
    }

    private var addTaskSection: some View {
        HStack {
            TextField("Task Title", text: $newTaskTitle)
            TextField("Duration in min", text: $newTaskDuration)
                .keyboardType(.numberPad)
            Button("Add") {
                addNewTask()
            }
        }
        .padding()
    }
    
    private var taskList: some View {
        List {
            ForEach($tasks) { $task in
                taskCell(task: $task)
            }
            .onDelete(perform: deleteTask)
        }
    }
    
    private func taskCell(task: Binding<Task>) -> some View {
        HStack {
            Text(task.wrappedValue.title)
            Spacer()
            if task.wrappedValue.isCompleted {
                Image(systemName: "checkmark").foregroundColor(.green)
            } else {
                Button("Start") {
                    for i in tasks.indices {
                        tasks[i].isCompleted = tasks[i].id == task.wrappedValue.id ? false : tasks[i].isCompleted
                    }
                    saveTasks()
                    isPresentingTimerForTask = task.wrappedValue
                }
            }
        }
    }
    
    private func addNewTask() {
        guard let duration = Int(newTaskDuration), !newTaskTitle.isEmpty else { return }
        let newTask = Task(title: newTaskTitle, duration: duration, isCompleted: false, type: "D")
        if newTask.type == "D" {
            tasks.append(newTask)
            saveTasks()
        }
        newTaskTitle = ""
        newTaskDuration = ""
    }
    
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            tasks.remove(at: index)
        }
        saveTasks()
    }
    
    private func loadTasks() {
        tasks = loadTodaysTasks()
    }
    
    private func updateTaskAndSave(updatedTask: Task) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            DispatchQueue.main.async {
                self.tasks[index].isCompleted = updatedTask.isCompleted
                self.saveTasks()
                print("Updated and saved task: \(updatedTask.title) with completion status: \(updatedTask.isCompleted)")
            }
        } else {
            print("Failed to find the task to update.")
        }
    }
    
    private func saveTasks() {
        let dailyTaskDictionaries = tasks.filter { $0.type == "D" }.map { $0.dictionaryRepresentation }
        UserDefaults.standard.set(dailyTaskDictionaries, forKey: dailyTasksKey)

        // Save weekly tasks for each day of the week
        for day in ["M", "T", "W", "Th", "F", "Sa", "Su"] {
            let weeklyTasksForDay = tasks.filter { $0.type == day }.map { $0.dictionaryRepresentation }
            let key = weeklyTasksKeyPrefix + day
            UserDefaults.standard.set(weeklyTasksForDay, forKey: key)
        }

        // Update last reset day
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Day of the week, full name
        let currentDayOfWeek = formatter.string(from: Date())
        UserDefaults.standard.set(currentDayOfWeek, forKey: "lastResetDay")

        print("All tasks saved. Last reset day: \(currentDayOfWeek)")
    }
    
    private func loadTodaysTasks() -> [Task] {
        var combinedTasks = [Task]()
        let dailyTasks = loadTasks(forKey: dailyTasksKey)
        combinedTasks.append(contentsOf: dailyTasks)

        let dayOfWeek = getDayOfWeekSuffix()
        let weeklyTasksKey = weeklyTasksKeyPrefix + dayOfWeek
        let weeklyTasks = loadTasks(forKey: weeklyTasksKey).filter { weeklyTask in
            !combinedTasks.contains(where: { $0.id == weeklyTask.id })
        }

        combinedTasks.append(contentsOf: weeklyTasks)

        return combinedTasks
    }
    
    private func loadTasks(forKey key: String) -> [Task] {
        guard let data = UserDefaults.standard.array(forKey: key) as? [[String: Any]] else { return [] }
        return data.compactMap { Task.from(dictionary: $0) }
    }
    
    private func getDayOfWeekSuffix() -> String {
        let weekdaySymbols = ["Su", "M", "T", "W", "Th", "F", "Sa"]
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: Date()) - 1 // Sunday is index 1
        return weekdaySymbols[weekdayIndex]
    }
}

struct DailyTasksView_Previews: PreviewProvider {
    static var previews: some View {
        DailyTasksView()
    }
}
