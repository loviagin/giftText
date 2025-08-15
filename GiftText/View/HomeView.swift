//
//  HomeView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @Query private var chats: [Chat]
    
    @FocusState private var focusedField: Field?
    @State private var name = "Any Name"
    @State private var typeEvent = ""
    @State private var gender = ""
    @State private var selectedGender: Gender = .none
    @State private var styleEvent: MessageStyle = .official
    @State private var sortedTypes: [String] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(.home)
                    .resizable()
                    .opacity(0.4)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 15) {
                        header
                        
                        nameField
                            .padding(.top)
                        
                        typeField
                        styleField
                        genderField
                    } // VStack in ScrollView
                    .onTapGesture {
                        self.focusedField = nil
                    }
                }
            }
        }
        .onAppear {
            self.sortedTypes = viewModel.typeGift
        }
        .onChange(of: typeEvent) { _, _ in
            sortTypes()
        }
    }
    
    func sortTypes() {
        if typeEvent.isEmpty {
            self.sortedTypes = viewModel.typeGift
        } else {
            self.sortedTypes = viewModel.typeGift.filter { $0.lowercased().contains(typeEvent.lowercased()) }
        }
    }
    
    var genderField: some View {
        FieldView(focused: $focusedField, focus: .gender, nextFocus: nil) {
            VStack(alignment: .leading) {
                Text("You can choose gender (optional)")
                    .foregroundStyle(Color.dark.opacity(0.7))
                    .padding(5)
                
                Picker(selection: $selectedGender) {
                    ForEach(Gender.allCases, id: \.self) { g in
                        Text(g.rawValue)
                            .padding(.vertical, 5)
                            .tag(g)
                    }
                } label: {
                    Text(selectedGender.rawValue)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedGender) { _, newValue in
                    if newValue == .other {
                        focusedField = .gender
                    }
                }
                
                if selectedGender == .other {
                    TextField("Enter the gender", text: $gender)
                        .padding(5)
                        .focused($focusedField, equals: .gender)
                        .onSubmit {
                            self.focusedField = nil
                        }
                }
            }
        }
    }
    
    var styleField: some View {
        FieldView(focused: $focusedField, focus: .style, nextFocus: nil) {
            ZStack(alignment: .top) {
                Text("Select message style")
                    .foregroundStyle(Color.dark.opacity(0.7))
                    .padding(5)
                
                Picker(selection: $styleEvent) {
                    ForEach(MessageStyle.allCases, id: \.self) { s in
                        Text(s.rawValue)
                            .padding(.vertical, 5)
                            .tag(s)
                    }
                } label: {
                    Text(styleEvent.rawValue)
                }
                .pickerStyle(.wheel)
            }
        }
    }
    
    var typeField: some View {
        FieldView(focused: $focusedField, focus: .typeEvent, nextFocus: nil) {
            TextField("", text: $typeEvent,
                      prompt: Text("A reason for congratulations")
                .foregroundStyle(Color.dark.opacity(0.7))
                .font(.headline)
            )
            .textFieldStyle(.plain)
            .submitLabel(.continue)
        }
        .overlay(alignment: .top, content: {
            if focusedField == .typeEvent {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(sortedTypes, id: \.self) { gift in
                            HStack {
                                Text(gift)
                                    .padding(.vertical, 5)
                                
                                Spacer()
                            }
                            .background(Color.light)
                            .onTapGesture {
                                self.typeEvent = gift
                                self.focusedField = nil
                            }
                        }
                    }
                    .padding(10)
                    
                    Spacer()
                }
                .background(Color.light)
                .foregroundStyle(Color.dark)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
                .padding(.top, 30)
            } else {
                EmptyView()
            }
        })
        .zIndex(10)
    }
    
    var nameField: some View {
        FieldView(focused: $focusedField, focus: .name, nextFocus: .typeEvent) {
            TextField("", text: $name,
                      prompt: Text("Who are we going to congratulate?")
                .foregroundStyle(Color.dark.opacity(0.7))
                .font(.headline)
            )
            .textFieldStyle(.plain)
            .submitLabel(.continue)
        }
    }
    
    var header: some View {
        Group {
            HStack {
                Text(getTitle())
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack {
                Text("Let's create some gifts!")
                    .font(.title3)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    func getTitle() -> String {
        if let name = viewModel.user?.name, !name.isEmpty {
            return NSLocalizedString("Hello, \(name)", comment: "HomeView")
        } else {
            return NSLocalizedString("You're welcome!", comment: "HomeView")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MainViewModel.mock)
}
