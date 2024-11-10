//
//  CharacterCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

class CharacterCreationViewModel: ObservableObject {
    @Published var selectedClass: CharacterClass = .knight {
        didSet {
            updateAvailableWeapons()
        }
    }
    @Published var availableWeapons: [Weapon] = []
    @Published var selectedWeapon: Weapon = .swordBroad

    @AppStorage("isCharacterCreated") private var isCharacterCreated: Bool = false
    @AppStorage("selectedCharacterClass") private var selectedCharacterClass: String = ""
    @AppStorage("selectedWeapon") private var selectedWeaponStorage: String = ""
    
    private let weapons: [CharacterClass: [Weapon]] = [
        .knight: [.swordBroad, .swordLong, .swordDouble],
        .assassin: [.daggerGolden, .daggerLong, .daggerDouble],
        .archer: [.bow, .crossbow],
        .wizard: [.staff, .spellbook]
    ]
    
    init() {
        updateAvailableWeapons()
    }
    
    private func updateAvailableWeapons() {
        availableWeapons = weapons[selectedClass] ?? []
        selectedWeapon = availableWeapons.first ?? .swordBroad // Set to the first available weapon
    }
    
    var previousClass: CharacterClass? {
        guard let index = CharacterClass.allCases.firstIndex(of: selectedClass), index > 0 else { return nil }
        return CharacterClass.allCases[index - 1]
    }
    
    var nextClass: CharacterClass? {
        guard let index = CharacterClass.allCases.firstIndex(of: selectedClass), index < CharacterClass.allCases.count - 1 else { return nil }
        return CharacterClass.allCases[index + 1]
    }
    
    func previousWeapon(for weapon: Weapon) -> Weapon? {
        guard let index = availableWeapons.firstIndex(of: weapon), index > 0 else { return nil }
        return availableWeapons[index - 1]
    }
    
    func nextWeapon(for weapon: Weapon) -> Weapon? {
        guard let index = availableWeapons.firstIndex(of: weapon), index < availableWeapons.count - 1 else { return nil }
        return availableWeapons[index + 1]
    }

    func confirmSelection() {
        selectedCharacterClass = selectedClass.rawValue
        selectedWeaponStorage = selectedWeapon.rawValue
        isCharacterCreated = true
    }
    
    func handleClassSwipe(_ value: CGSize) {
        if value.width < -100, let next = nextClass {
            selectedClass = next
        } else if value.width > 100, let previous = previousClass {
            selectedClass = previous
        }
    }
    
    func handleWeaponSwipe(_ value: CGSize) {
        if value.width < -100, let next = nextWeapon(for: selectedWeapon) {
            selectedWeapon = next
        } else if value.width > 100, let previous = previousWeapon(for: selectedWeapon) {
            selectedWeapon = previous
        }
    }
}
