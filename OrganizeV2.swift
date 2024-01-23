//
//  OrganizeV2.swift
//  Organize
//
//  Created by Colby Buchanan on 1/12/24.
//

//
//  OrganizeApp.swift
//  Organize
//
//  Created by Colby Buchanan on 12/24/23.
//

import SwiftUI

@main
struct OrganizeApp: App {
    var body: some Scene {
        WindowGroup {
            DailyTasksView()
                .onAppear {
                    if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Preferences") {
                        print("UserDefaults directory: \(url.path)")
                    }
                }
        }
    }
}
