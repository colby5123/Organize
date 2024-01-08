//
//  TaskManager.swift
//  Organize
//
//  Created by Colby Buchanan on 1/4/24.
//

// TaskManager.swift
import Foundation

enum DayOfWeek: String, Codable, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

// Define the Task structure
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var duration: Int // Duration in minutes
    var isCompleted: Bool

    init(title: String, duration: Int, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.duration = duration
        self.isCompleted = isCompleted
    }
}

class TaskManager: ObservableObject {
    @Published var dailyTasks: [Task] = []
    @Published var weeklyTasks: [DayOfWeek: [Task]] = [:]
    
    // Initialize the task manager and load tasks from storage
    init() {
        loadTasks()
    }
    
    // Load tasks from persistent storage
    func loadTasks() {
        // Load daily tasks
        if let dailyData = UserDefaults.standard.data(forKey: "dailyTasks"),
           let loadedDailyTasks = try? JSONDecoder().decode([Task].self, from: dailyData) {
            dailyTasks = loadedDailyTasks
        }
        
        // Load weekly tasks
        DayOfWeek.allCases.forEach { day in
            if let weeklyData = UserDefaults.standard.data(forKey: "weeklyTasks_\(day.rawValue)"),
               let loadedWeeklyTasks = try? JSONDecoder().decode([Task].self, from: weeklyData) {
                weeklyTasks[day] = loadedWeeklyTasks
            } else {
                weeklyTasks[day] = []
            }
        }
        
        // Merge today's weekly tasks into daily tasks
        mergeWeeklyTasksIntoDaily()
    }
    
    // Save tasks to persistent storage
    func saveTasks() {
        // Save daily tasks
        if let dailyData = try? JSONEncoder().encode(dailyTasks) {
            UserDefaults.standard.set(dailyData, forKey: "dailyTasks")
        }
        
        // Save weekly tasks
        for (day, tasks) in weeklyTasks {
            if let weeklyData = try? JSONEncoder().encode(tasks) {
                UserDefaults.standard.set(weeklyData, forKey: "weeklyTasks_\(day.rawValue)")
            }
        }
    }
    
    // Reset daily tasks at the end of the day
    func resetDailyTasks() {
        let today = currentDayOfWeek()
        let lastResetDay = UserDefaults.standard.string(forKey: "lastResetDay") ?? ""
        if lastResetDay != today.rawValue {
            for i in dailyTasks.indices {
                dailyTasks[i].isCompleted = false
            }
            saveTasks()
            UserDefaults.standard.set(today.rawValue, forKey: "lastResetDay")
        }
    }
    
    // Merge today's weekly tasks into the list of daily tasks
    func mergeWeeklyTasksIntoDaily() {
        let today = currentDayOfWeek()
        if let todayTasks = weeklyTasks[today] {
            dailyTasks.append(contentsOf: todayTasks)
        }
    }
    
    // Add new daily task
    func addDailyTask(title: String, duration: Int) {
        let newTask = Task(title: title, duration: duration)
        dailyTasks.append(newTask)
        saveTasks()
    }
    
    // Add new weekly task
    func addWeeklyTask(title: String, duration: Int, dayOfWeek: DayOfWeek) {
        let newTask = Task(title: title, duration: duration)
        weeklyTasks[dayOfWeek]?.append(newTask)
        saveTasks()
    }
    
    // Call this method when a task is completed to update its status
    func completeTask(taskId: UUID) {
        if let index = dailyTasks.firstIndex(where: { $0.id == taskId }) {
            dailyTasks[index].isCompleted = true
            saveTasks()
        } else {
            for (day, tasks) in weeklyTasks {
                if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                    weeklyTasks[day]?[index].isCompleted = true
                    saveTasks()
                    break
                }
            }
        }
    }
    
    // Helper function to determine the current day of the week
    func currentDayOfWeek() -> DayOfWeek {
        let weekDay = Calendar.current.component(.weekday, from: Date())
        let adjustedIndex = weekDay == 1 ? 6 : weekDay - 2 // Adjust index to match DayOfWeek enum
        return DayOfWeek.allCases[adjustedIndex]
    }
}
