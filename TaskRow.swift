//
//  TaskRow.swift
//  Organize
//
//  Created by Colby Buchanan on 1/5/24.
//

import Foundation
// Represents a single task row with a timer functionality
// TaskRow.swift (assuming it exists and is correct)
import SwiftUI

struct TaskRow: View {
    @Binding var task: Task
    @State private var showingTimer = false

    var body: some View {
        HStack {
            Text(task.title)
            Spacer()
            if task.isCompleted {
                Image(systemName: "checkmark").foregroundColor(.green)
            } else {
                Button("Start Timer") {
                    showingTimer = true
                }
                .sheet(isPresented: $showingTimer) {
                    TimerView(task: $task)
                }
            }
        }
    }
}
