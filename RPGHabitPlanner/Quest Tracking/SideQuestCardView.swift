//
//  SideQuestCardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct SideQuestCardView: View {
    let quest: Quest
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(quest.title)
                .font(.headline)
            
            Spacer()
            
            HStack {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 12, height: 12) // Small star size
                            .foregroundColor(index <= quest.difficulty ? .yellow : .gray)
                    }
                }
                Spacer()
                Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
