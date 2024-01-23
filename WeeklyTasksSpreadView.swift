//
//  WeeklyTasksSpreadView.swift
//  Organize
//
//  Created by Colby Buchanan on 1/12/24.
//
import Foundation
import SwiftUI

struct IdentifiableString: Identifiable {
    let value: String
    var id: String { value }
}

struct WeeklyTasksSpreadView: View {
    let daysOfWeek = ["M", "T", "W", "Th", "F", "Sa", "Su"]
    
    @State private var selectedDay: IdentifiableString? = nil
    @State private var tasks: [Task] = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Button(action: {
                            self.selectedDay = IdentifiableString(value: day)
                        }) {
                            Text(day)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(width: max(geometry.size.width, geometry.size.height),
                       height: min(geometry.size.width, geometry.size.height))
                .navigationTitle("Weekly Tasks")
                .navigationBarItems(trailing: Button("Today") {
                    self.selectedDay = IdentifiableString(value: self.getToday())
                })
            }
            .onAppear {
                // Load tasks for the current day when the view appears
                let today = self.getToday()
                self.tasks = self.loadTasks(forDay: today)
            }
        }
        .fullScreenCover(item: $selectedDay) { identifiableString in
            let tasksForDay = Binding(
                get: {
                    self.loadTasks(forDay: identifiableString.value)
                },
                set: { updatedTasks in
                    print("Updated tasks for \(identifiableString.value): \(updatedTasks)")
                    self.tasks = updatedTasks
                    self.saveTasks(forDay: identifiableString.value)
                }
            )
            
            WeeklyTasksView(dayOfWeek: identifiableString.value, tasks: tasksForDay, saveAction: {
                self.saveTasks(forDay: identifiableString.value)
            })
        }
    }
    
    func saveTasks(forDay day: String) {
        let tasksForDay = tasks.filter { $0.type == day }
        print("Saving tasks for \(day): \(tasksForDay)")
        let tasksData = tasksForDay.map { $0.dictionaryRepresentation }
        let key = weeklyTasksKeyPrefix + day
        UserDefaults.standard.set(tasksData, forKey: key)
    }
    
    func loadTasks(forDay day: String) -> [Task] {
        let key = weeklyTasksKeyPrefix + day
        guard let data = UserDefaults.standard.array(forKey: key) as? [[String: Any]] else { return [] }
        return data.compactMap { Task.from(dictionary: $0) }
    }
    
    private func getToday() -> String {
        let weekdaySymbols = ["Su", "M", "T", "W", "Th", "F", "Sa"]
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: Date()) - 1 // Sunday is index 1
        return weekdaySymbols[weekdayIndex]
    }
}
