//
//  QuestCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

final class QuestCreationViewModel: ObservableObject {
    private let questDataService: QuestDataServiceProtocol

    @Published var didSaveQuest = false
    @Published var errorMessage: String?
    @Published var isSaving = false
    @Published var questTitle: String = ""
    @Published var questDescription: String = ""
    @Published var questDueDate = Date()
    @Published var isMainQuest: Bool = true
    @Published var difficulty: Int = 3
    @Published var isActiveQuest: Bool = true
    @Published var tasks: [String] = []
    @Published var notifyMe = true

    // New properties for notification scheduling
    @Published var repeatType: QuestRepeatType = .oneTime
    @Published var repeatIntervalWeeks: Int = 1 // Used if repeatType == .everyXWeeks

    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }

    func validateInputs() -> Bool {
        if questTitle.isEmpty {
            errorMessage = "Quest title cannot be empty."
            return false
        }
        return true
    }

    func saveQuest() {
        guard validateInputs() else { return }

        isSaving = true

        let newQuest = Quest(
            title: questTitle,
            isMainQuest: isMainQuest,
            info: questDescription,
            difficulty: difficulty,
            creationDate: Date(),
            dueDate: questDueDate,
            isActive: isActiveQuest,
            progress: 0,
            repeatType: repeatType,
            repeatIntervalWeeks: repeatType == .everyXWeeks ? repeatIntervalWeeks : nil
        )

        let taskTitles = tasks.map { $0.trimmingCharacters(in: .whitespaces) }
                              .filter { !$0.isEmpty }

        questDataService.saveQuest(newQuest, withTasks: taskTitles) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    self.didSaveQuest = false
                } else {
                    if self.notifyMe {
                        NotificationManager.shared.handleNotificationForQuest(newQuest, enabled: true)
                    }
                    self.didSaveQuest = true
                }
            }
        }
    }

    func resetInputs() {
        questTitle = ""
        questDescription = ""
        questDueDate = Date()
        isMainQuest = false
        difficulty = 3
        isActiveQuest = false
        repeatType = .oneTime
        repeatIntervalWeeks = 1
        notifyMe = true
    }
}
