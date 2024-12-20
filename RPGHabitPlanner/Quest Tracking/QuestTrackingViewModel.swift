//
//  QuestTrackingViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import Combine

enum QuestStatusFilter: String, CaseIterable {
    case all
    case active
    case inactive
}

final class QuestTrackingViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var errorMessage: String?
    @Published var selectedTab: QuestTab = .main
    @Published var selectedStatus: QuestStatusFilter = .all
    
    private let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    
    init(questDataService: QuestDataServiceProtocol, userManager: UserManager) {
        self.questDataService = questDataService
        self.userManager = userManager
    }
    
    func fetchQuests() {
        questDataService.fetchNonCompletedQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.quests = quests.reversed()
                }
            }
        }
    }

    func markQuestAsCompleted(id: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == id }) else { return }
        withAnimation {
            quests[index].isCompleted = true
        }
        
        questDataService.updateQuestCompletion(forId: id, to: true) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.userManager.updateUserExperience(additionalExp: Int16(10 * self.quests[index].difficulty)) { expError in
                        if let expError = expError {
                            self.errorMessage = expError.localizedDescription
                        }
                    }
                }
            }
        }
    }

    func updateQuest(_ quest: Quest) {
        questDataService.updateQuest(
            withId: quest.id,
            title: quest.title,
            isMainQuest: quest.isMainQuest,
            info: quest.info,
            difficulty: quest.difficulty,
            dueDate: quest.dueDate,
            isActive: quest.isActive,
            progress: quest.progress
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchQuests()
                }
            }
        }
    }

    func updateQuestProgress(id: UUID, by change: Int) {
        guard let index = quests.firstIndex(where: { $0.id == id }) else { return }
        var quest = quests[index]
        quest.progress = max(0, min(100, quest.progress + change)) // Ensure progress stays between 0 and 100
        quests[index] = quest

        questDataService.updateQuest(
            withId: quest.id,
            title: quest.title,
            isMainQuest: quest.isMainQuest,
            info: quest.info,
            difficulty: quest.difficulty,
            dueDate: quest.dueDate,
            isActive: quest.isActive,
            progress: quest.progress
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    var mainQuests: [Quest] {
        filteredQuests(for: quests.filter { $0.isMainQuest })
    }
    
    var sideQuests: [Quest] {
        filteredQuests(for: quests.filter { !$0.isMainQuest })
    }
    
    private func filteredQuests(for quests: [Quest]) -> [Quest] {
        switch selectedStatus {
        case .all:
            return quests
        case .active:
            return quests.filter { $0.isActive }
        case .inactive:
            return quests.filter { !$0.isActive }
        }
    }
}
