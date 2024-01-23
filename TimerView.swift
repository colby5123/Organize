//
//  TimerView.swift
//  Organize
//
//  Created by Colby Buchanan on 1/12/24.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var task: Task // This is now a Binding
    @State private var secondsRemaining: Int
    @State private var timerActive = false
    
    var onSave: (() -> Void)? // Closure to call when saving is needed
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init(task: Binding<Task>, secondsRemaining: Int, onSave: (() -> Void)? = nil) {
        self._task = task
        self._secondsRemaining = State(initialValue: secondsRemaining)
        self.onSave = onSave
    }
    
    var body: some View {
        VStack {
            Text(task.title)
                .font(.headline)
            Text("\(secondsRemaining) seconds")
                .font(.title)
            HStack {
                Button("Pause") {
                    timerActive.toggle()
                }
                Button("Reset") {
                    resetTimer()
                }
            }
        }
        .onReceive(timer) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else if secondsRemaining == 0 {
                task.isCompleted = true
                presentationMode.wrappedValue.dismiss()
                onSave?() // Call the closure to save the changes
                print("Timer finished for task: \(task.title) with completion status: \(task.isCompleted)")
            }
        }
    }

    private func resetTimer() {
        secondsRemaining = task.duration * 60
        task.isCompleted = false
        // There's no need for onSave since the changes are directly bound to the tasks array
        print("Timer reset for task: \(task.title) with completion status: \(task.isCompleted)")
    }
}
