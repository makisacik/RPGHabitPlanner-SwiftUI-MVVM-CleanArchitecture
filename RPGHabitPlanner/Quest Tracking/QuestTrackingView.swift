//
//  QuestTrackingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import Lottie

struct QuestTrackingView: View {
    @StateObject var viewModel: QuestTrackingViewModel
    @State private var showAlert: Bool = false
    @State private var showSuccessAnimation: Bool = false
    @State private var lastScrollPosition: UUID?
    @State private var selectedQuestForEditing: Quest?

    var body: some View {
        ZStack {
            mainContent
            SuccessAnimationOverlay(isVisible: $showSuccessAnimation)
        }
    }

    private var mainContent: some View {
        VStack(alignment: .center, spacing: 5) {
            questTypePicker.padding(.top, 5)
            questList
        }
        .padding()
        .background(
            Image("panel_brown")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                           resizingMode: .stretch)
                .cornerRadius(12)
        )
        .padding(.horizontal)
        .onChange(of: viewModel.errorMessage) { errorMessage in
            showAlert = errorMessage != nil
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error").font(.appFont(size: 16, weight: .black)),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred")
                    .font(.appFont(size: 14)),
                dismissButton: .default(Text("OK").font(.appFont(size: 14, weight: .black))) {
                    viewModel.errorMessage = nil
                }
            )
        }
        .sheet(item: $selectedQuestForEditing) { quest in
            editQuestSheet(quest)
        }
        .onAppear {
            viewModel.fetchQuests()
        }
    }

    private var questList: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(questsToDisplay) { quest in
                        if !quest.isCompleted {
                            questCard(for: quest)
                                .id(quest.id)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.quests) { _ in
                if let lastScrollPosition = lastScrollPosition {
                    scrollViewProxy.scrollTo(lastScrollPosition, anchor: .center)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func questCard(for quest: Quest) -> some View {
        QuestCardView(
            quest: quest,
            onMarkComplete: { id in
                withAnimation {
                    viewModel.markQuestAsCompleted(id: id)
                    showSuccessAnimation = true
                    lastScrollPosition = id
                }
            },
            onEditQuest: { selectedQuestForEditing = $0 },
            onUpdateProgress: { id, change in
                viewModel.updateQuestProgress(id: id, by: change)
            },
            onToggleTaskCompletion: { taskId, isCompleted in
                viewModel.toggleTaskCompletion(
                    questId: quest.id,
                    taskId: taskId,
                    currentValue: isCompleted
                )
            }
        )
    }

    private func editQuestSheet(_ quest: Quest) -> some View {
        EditQuestView(
            quest: Binding(
                get: { quest },
                set: { updatedQuest in
                    if let index = viewModel.quests.firstIndex(where: { $0.id == updatedQuest.id }) {
                        viewModel.quests[index] = updatedQuest
                    }
                    selectedQuestForEditing = nil
                }
            ),
            onSave: { updatedQuest in
                viewModel.updateQuest(updatedQuest)
                selectedQuestForEditing = nil
            },
            onCancel: {
                selectedQuestForEditing = nil
            }
        )
    }

    private var questTypePicker: some View {
        VStack(alignment: .leading) {
            CustomSegmentedControl(
                selected: $viewModel.selectedTab,
                options: QuestTab.allCases,
                titleForOption: { $0.rawValue.capitalized },
                backgroundColor: Color.brown.opacity(0.2),
                selectedColor: Color.brown,
                textColor: .black,
                selectedTextColor: .white
            )
            .padding(.horizontal)
        }
    }

    private var questsToDisplay: [Quest] {
        switch viewModel.selectedTab {
        case .all:
            return viewModel.allQuests
        case .main:
            return viewModel.mainQuests
        case .side:
            return viewModel.sideQuests
        }
    }
}

enum QuestTab: String, CaseIterable {
    case all
    case main
    case side
}

#Preview {
    let questDataService = QuestCoreDataService()
    let userManager = UserManager(container: PersistenceController.shared.container)
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService, userManager: userManager))
}
