//
//  TimerView.swift
//  Organize
//
//  Created by Colby Buchanan on 1/5/24.
//

import Foundation
// Provides a timer view with pause and reset functionality
import SwiftUI

struct TimerView: View {
    @Binding var task: Task
    @State private var secondsRemaining: Int
    @State private var timerActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(task: Binding<Task>) {
        _task = task
        _secondsRemaining = State(initialValue: task.wrappedValue.duration * 60)
    }

    var body: some View {
        VStack {
            Text(task.title)
                .font(.headline)
            Text("\(secondsRemaining) seconds")
                .font(.title)
            HStack {
                Button(timerActive ? "Pause" : "Start") {
                    timerActive.toggle()
                }
                Button("Reset") {
                    resetTimer()
                }
            }
        }
        .onReceive(timer) { _ in
            if timerActive && secondsRemaining > 0 {
                secondsRemaining -= 1
            }
            if secondsRemaining == 0 {
                timerActive = false
                task.isCompleted = true
            }
        }
    }

    private func resetTimer() {
        secondsRemaining = task.duration * 60
        timerActive = false
    }
}
