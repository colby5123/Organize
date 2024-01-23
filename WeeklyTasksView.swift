import SwiftUI

struct WeeklyTasksView: View {
    @Environment(\.presentationMode) var presentationMode
    let dayOfWeek: String // The day of the week for the current view
    @State private var newTaskTitle: String = ""
    @State private var newTaskDuration: String = ""
    @Binding var tasks: [Task] // The list of tasks passed from the parent view
    let saveAction: () -> Void // The save action passed from the parent view

    var body: some View {
            VStack {
                // Custom header with day of the week and "Tasks"
                Text(dayOfWeek + " Tasks")
                    .font(.headline)
                    .padding()

                // List of tasks
                List {
                    ForEach(tasks.filter { $0.type == dayOfWeek }, id: \.id) { task in
                        HStack {
                            Text(task.title)
                            Spacer()
                            Text("\(task.duration) min")
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(PlainListStyle())

                // Section to add a new task
                HStack {
                    TextField("Task Title", text: $newTaskTitle)
                    TextField("Duration in min", text: $newTaskDuration)
                        .keyboardType(.numberPad)
                    Button("Add") {
                        addNewTask()
                    }
                }
                .padding()

                Spacer()

                // Calendar button to dismiss the view
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
                .padding(.bottom)
            }
        }

    // Function to add a new task
    private func addNewTask() {
        // Ensure the duration is a number and the title is not empty
        guard let duration = Int(newTaskDuration), !newTaskTitle.isEmpty else { return }
        // Create a new task with the given title, duration, and set the type to the current dayOfWeek
        let newTask = Task(id: UUID(), title: newTaskTitle, duration: duration, isCompleted: false, type: dayOfWeek)
        // Insert the new task at the beginning of the tasks list
        tasks.insert(newTask, at: 0)
        // Call the save action to persist the new task
        saveAction()
        // Reset the fields
        newTaskTitle = ""
        newTaskDuration = ""
    }

    // Function to delete a task
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            tasks.remove(at: index)
        }
        // Call the save action to update the persisted tasks
        saveAction()
    }
}

// Preview for the view
struct WeeklyTasksView_Previews: PreviewProvider {
    @State static var tasks = [Task(title: "Example", duration: 30, isCompleted: false, type: "F")]

    static var previews: some View {
        WeeklyTasksView(dayOfWeek: "F", tasks: $tasks, saveAction: {})
    }
}
