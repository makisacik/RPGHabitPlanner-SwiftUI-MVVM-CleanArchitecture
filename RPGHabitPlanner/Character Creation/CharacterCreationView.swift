//
//  CharacterCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct CharacterCreationView: View {
    @StateObject private var viewModel = CharacterCreationViewModel()
    @GestureState private var weaponDragOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Class!")
                .font(.title2)
                .bold()
            
            ZStack {
                GeometryReader { _ in
                    TabView(selection: $viewModel.selectedClass) {
                        ForEach(CharacterClass.allCases, id: \.self) { characterClass in
                            VStack {
                                if let image = UIImage(named: characterClass.iconName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .padding()
                                }
                                Text(characterClass.rawValue)
                                    .font(.title3)
                                    .bold()
                            }
                            .tag(characterClass)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 200)
                    .gesture(
                        DragGesture().updating($weaponDragOffset) { value, state, _ in
                            state = value.translation
                        }
                    )
                }
                
                HStack {
                    if let previousClass = viewModel.previousClass {
                        Image(uiImage: UIImage(named: previousClass.iconName)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                            .offset(x: weaponDragOffset.width * 0.3)
                            .animation(.easeInOut(duration: 0.3), value: weaponDragOffset)
                    } else {
                        Color.clear.frame(width: 80, height: 80)
                    }
                    
                    Spacer()
                    
                    if let nextClass = viewModel.nextClass {
                        Image(uiImage: UIImage(named: nextClass.iconName)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                            .offset(x: -weaponDragOffset.width * 0.3)
                            .animation(.easeInOut(duration: 0.3), value: weaponDragOffset)
                    } else {
                        Color.clear.frame(width: 80, height: 80)
                    }
                }
                .frame(height: 200)
            }
            
            Text("Choose Your Starter Weapon!")
                .font(.title2)
                .bold()
            
            ZStack {
                GeometryReader { _ in
                    TabView(selection: $viewModel.selectedWeapon) {
                        ForEach(viewModel.availableWeapons, id: \.self) { weapon in
                            VStack {
                                if let image = UIImage(named: weapon) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .padding()
                                }
                                Text(weapon)
                                    .font(.title3)
                                    .bold()
                            }
                            .tag(weapon)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 200)
                    .gesture(
                        DragGesture().updating($weaponDragOffset) { value, state, _ in
                            state = value.translation
                        }
                    )
                }
                
                HStack {
                    if let previousWeapon = viewModel.previousWeaponName(for: viewModel.selectedWeapon) {
                        Image(uiImage: UIImage(named: previousWeapon)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                            .offset(x: weaponDragOffset.width * 0.3)
                            .animation(.easeInOut(duration: 0.3), value: weaponDragOffset)
                    } else {
                        Color.clear.frame(width: 80, height: 80)
                    }
                    
                    Spacer()
                    
                    if let nextWeapon = viewModel.nextWeaponName(for: viewModel.selectedWeapon) {
                        Image(uiImage: UIImage(named: nextWeapon)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                            .offset(x: -weaponDragOffset.width * 0.3)
                            .animation(.easeInOut(duration: 0.3), value: weaponDragOffset)
                    } else {
                        Color.clear.frame(width: 80, height: 80)
                    }
                }
                .frame(height: 200)
            }
            
            Spacer()
            
            Button(action: {
                // Handle confirmation logic
            }) {
                Text("Confirm Selection")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    CharacterCreationView()
}
