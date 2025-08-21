//
//  HomeView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: MainViewModel
    @StateObject private var generator = GenerateViewModel()
    
    @Query private var users: [User]
    @Query private var chats: [Chat]
    @Query private var messages: [Message]
    
//    @State private var chatsDev: [Chat] = [
//        Chat(title: "Friend1", lastTime: Date(), lastMessage: "Hello"),
//        Chat(title: "Friend 2", lastTime: Date()),
//        Chat(title: "Friend 3", lastTime: Date()),
//        Chat(title: "Friend4", lastTime: Date()),
//        Chat(title: "Friend 78", lastTime: Date())
//    ]
    
    @FocusState private var focusedField: Field?
    @State private var name = ""
    @State private var typeEvent = ""
    @State private var context = ""
    @State private var gender = ""
    @State private var selectedGender: Gender = .none
    @State private var selectedChat: Chat? = nil
    @State private var styleEvent: MessageStyle = .official
    @State private var sortedTypes: [String] = []
    @State private var openChats = false
    
    @State private var image: UIImage? = nil
    @State private var typeView: TypeForm = .form
    @State private var errorMessage: String? = nil
    @State private var giftText: String? = nil
    @State private var showNameAlert = false
    @State private var myName = ""
    @State private var chatId = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(.home)
                    .resizable()
                    .opacity(0.4)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 15) {
                        headerView
                        
                        switch typeView {
                        case .form:
                            formBodyView
    //                            .padding(.top)
                        case .generation:
                            generationView
                                .padding(.top, 150)
                        case .result:
                            resultView
                                .padding(.vertical)
                        }
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    } // VStack in ScrollView
                    .onTapGesture {
                        self.focusedField = nil
                    }
                }
            }
//            .navigationTitle(getTitle())
        }
        .alert("Do you want to specify your name?", isPresented: $showNameAlert, actions: {
            TextField("Name", text: $myName)
            Button("OK") {
                viewModel.user?.name = self.myName
                users[0].name = self.myName
                alertAction()
            }
            .bold()
            
            Button("Skip for now") {
                alertAction()
            }
            
            Button("Never ask") {
                viewModel.user?.name = ""
                users[0].name = ""
                alertAction()
            }
        })
        .onAppear {
            self.sortedTypes = viewModel.typeGift
        }
        .onChange(of: typeEvent) { _, _ in
            sortTypes()
        }
        .onChange(of: viewModel.newGift) { _, newValue in
            if let newValue {
                DispatchQueue.main.async {
                    clear()
                    self.name = newValue.name
                    self.selectedChat = newValue.chat
                    viewModel.newGift = nil
                }
            }
        }
    }
    
    func alertAction() {
        showNameAlert = false

        if viewModel.checkLimitsForText() {
            generateText()
        } else {
            errorMessage = NSLocalizedString("You have reached the limit of text gifts", comment: "Home View")
        }
    }
    
    func generateImage() {
        self.errorMessage = nil
        
        guard viewModel.checkLimitsForImage() else {
            DispatchQueue.main.async {
                self.errorMessage = NSLocalizedString("You have reached the limit of images per day", comment: "Home View")
            }
            return
        }
        
        withAnimation {
            self.typeView = .generation
        }
        
        Task {
            await generator.generateImage() { result in // result is base64Encoded Image
                guard let result else {
                    print("error result")
                    withAnimation {
                        self.typeView = .result
                        self.errorMessage = NSLocalizedString("An error occurred while processing your request. Please try again later.", comment: "Home View")
                    }
                    return
                }
                
                withAnimation {
                    self.typeView = .result
                }
                
                viewModel.setLimitForImage()
                
                print("result in Home View: \(result)")
                self.image = viewModel.imageFromBase64(result)
                guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
                    print("error image data")
                    withAnimation {
                        self.typeView = .result
                    }
                    return
                }
                
                var sex: String? {
                    if selectedGender == Gender.none {
                        return nil
                    } else if selectedGender == Gender.other {
                        return gender
                    } else {
                        return selectedGender.rawValue
                    }
                }
                
                let userText = "\(NSLocalizedString("Gift creation request", comment: "Home View")): \n\n\(NSLocalizedString("For name", comment: "Home View")): \(name) \n\(NSLocalizedString("In connection with the", comment: "Home View")): \(typeEvent) \n\(NSLocalizedString("Gift Style", comment: "Home View")): \(styleEvent.rawValue) \n\(selectedGender != .none ? NSLocalizedString("Selected Gender:", comment: "Home View") : "") \(sex ?? NSLocalizedString("", comment: "Home View"))"
                
                Task { @MainActor in
                    // existing chat
                    if let selectedChat,
                       let index = chats.firstIndex(where: { $0.id == selectedChat.id }) {
                        chats[index].lastId = "system"
                        chats[index].lastTime = Date()
                        chats[index].lastMessage = "🌠 Gift Image"
                        if !context.isEmpty {
                            chats[index].context += ". \(context)"
                        }
                        
                        modelContext.insert(Message(userId: "user", chatId: selectedChat.id, text: userText, image: nil, type: nil, style: nil))
                        modelContext.insert(Message(userId: "system", chatId: selectedChat.id, text: "Gift for \(name)", image: imageData, type: typeEvent, style: styleEvent))
                    } else { // new chat
                        let newChat = Chat(title: name, lastTime: Date(), lastMessage: "🌠 Gift Image", lastId: "system", context: context)
                        modelContext.insert(newChat)
                        modelContext.insert(Message(userId: "user", chatId: newChat.id, text: userText, image: nil, type: nil, style: nil))
                        modelContext.insert(Message(userId: "system", chatId: newChat.id, text: "Gift for \(name)", image: imageData, type: typeEvent, style: styleEvent))
                    }
                }
            }
        }
    }
    
    func generateText() {
        self.errorMessage = nil
        
        guard !name.isEmpty else {
            self.name = NSLocalizedString("It's required", comment: "Home View")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.name = ""
            }
            return
        }
        
        guard !typeEvent.isEmpty else {
            self.typeEvent = NSLocalizedString("It's required", comment: "Home View")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.typeEvent = ""
            }
            return
        }
        
        withAnimation {
            self.typeView = .generation
        }
        
        var sex: String? {
            if selectedGender == Gender.none {
                return nil
            } else if selectedGender == Gender.other {
                return gender
            } else {
                return selectedGender.rawValue
            }
        }
        
        var messages: [Message]? {
            if let selectedChat {
                return self.messages.filter { $0.chatId == selectedChat.id }
            }
            
            return nil
        }
        
        Task {
            await generator.initGenerator(myName: viewModel.user?.name, name: name, type: typeEvent, style: styleEvent.rawValue, gender: sex, context: context, messages: messages) { result in
                
                guard let result else {
                    print("error")
    
                    withAnimation {
                        self.typeView = .form
                        self.errorMessage = NSLocalizedString("An error occurred while processing your request. Please try again later.", comment: "Home View")
                    }
                    return
                }
                
                viewModel.setLimitForText()
                
                withAnimation {
                    self.typeView = .result
                }
                print("result in Home View: \(result)")
                self.giftText = result
                
                let userText = "\(NSLocalizedString("Gift creation request", comment: "Home View")): \n\n\(NSLocalizedString("For name", comment: "Home View")): \(name) \n\(NSLocalizedString("In connection with the", comment: "Home View")): \(typeEvent) \n\(NSLocalizedString("Gift Style", comment: "Home View")): \(styleEvent.rawValue) \n\(selectedGender != .none ? NSLocalizedString("Selected Gender:", comment: "Home View") : "") \(sex ?? NSLocalizedString("", comment: "Home View"))"
                
                Task { @MainActor in
                    // existing chat
                    if let selectedChat,
                       let index = chats.firstIndex(where: { $0.id == selectedChat.id }) {
                        chats[index].lastId = "system"
                        chats[index].lastTime = Date()
                        chats[index].lastMessage = result
                        modelContext.insert(Message(userId: "user", chatId: selectedChat.id, text: userText, image: nil, type: nil, style: nil))
                        modelContext.insert(Message(userId: "system", chatId: selectedChat.id, text: result, image: nil, type: typeEvent, style: styleEvent))
                        chatId = selectedChat.id
                    } else { // new chat
                        let newChat = Chat(title: name, lastTime: Date(), lastMessage: result, lastId: "system", context: context)
                        modelContext.insert(newChat)
                        modelContext.insert(Message(userId: "user", chatId: newChat.id, text: userText, image: nil, type: nil, style: nil))
                        modelContext.insert(Message(userId: "system", chatId: newChat.id, text: result, image: nil, type: typeEvent, style: styleEvent))
                        chatId = newChat.id
                    }
                }
            }
        }
    }
    
    func regenerateText() {
        guard viewModel.checkLimitsForRegenerate(chatId) else {
            errorMessage = NSLocalizedString("You have reached the limit of text regeneration per day", comment: "Home View")
            return
        }
        
        withAnimation {
            self.typeView = .form
        }
        
        generateText()
        viewModel.setLimitForRegenerate(chatId)
    }
    
    func clear() {
        name = ""
        typeEvent = ""
        context = ""
        gender = ""
        selectedGender = .none
        selectedChat = nil
        styleEvent = .official
        openChats = false
        sortedTypes = viewModel.typeGift
        
        image = nil
        typeView = .form
        errorMessage = nil
        giftText = nil
        
        generator.clear()
    }
    
    var resultView: some View {
        VStack(alignment: .leading) {
            Text("Your gift is ready!")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                    
                    HStack {
                        AppButton(text: "Download", systemImage: "arrow.down.circle", onClickText: "Saved", backgroundColor: Color.gray.opacity(0.7)) {
                            ContentHelper.saveToPhotos(image) { result in
                                print(result)
                            }
                        }
                        
                        if let shared = SharedImage(uiImage: image, filename: "photo.png", asPNG: true) {
                            ShareLink(
                                item: shared,
                                message: Text(giftText ?? "Your gift:"),
                                preview: SharePreview("Your Gift", image: Image(uiImage: image))
                            ) {
                                ButtonLabel(systemImage: "square.and.arrow.up", text: "Share Image",  backgroundColor: Color.pink.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            
            if let giftText {
                HStack(spacing: 0) {
                    VStack {
                        Rectangle()
                            .fill(Color.pink.opacity(0.7))
                    }
                    .frame(width: 20)
                    
                    VStack {
                        Text(giftText)
                            .multilineTextAlignment(.leading)
                            .padding(10)
                            .background(Color.pink.opacity(0.1))
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical)
                
                HStack {
                    AppButton(text: "Copy Gift", systemImage: "document.on.document", onClickText: "Copied", backgroundColor: Color.gray.opacity(0.7)) {
                        UIPasteboard.general.string = giftText
                    }
                    
                    ShareLink(item: giftText, subject: Text("Share your gift"), message: Text("Congratulations!")) {
                        ButtonLabel(systemImage: "square.and.arrow.up", text: "Share Gift",  backgroundColor: Color.pink.opacity(0.7))
                    }
                }
                .padding(.horizontal, 15)
            }
            
            Divider()
                .padding(15)
            
            HStack {
                AppButton(text: "Regenerate", systemImage: "arrow.clockwise", backgroundColor: Color.pink.opacity(0.6)) {
                    regenerateText()
                }
                
                AppButton(text: "New Gift", systemImage: "plus.circle", backgroundColor: Color.pink.opacity(0.9)) {
                    clear()
                }
            }
            .padding(.horizontal, 15)
            
            AppButton(text: "Generate Image Gift", systemImage: "photo.artframe.circle", backgroundColor: Color.blue.opacity(0.9)) {
                generateImage()
            }
            .padding(.horizontal, 15)
        } // end of main VStack
    }
    
    //MARK: - Generation Loading View
    var generationView: some View {
        VStack {
            GiftBoxLoadingView()
                .frame(width: 100, height: 100)
                .padding()
            
            Text("We are generating your gift...")
                .font(.title2)
                .bold()
                .padding()
        }
    }
    
    //MARK: - All fields View
    var formBodyView: some View {
        VStack(spacing: 15) {
            nameFieldView
            typeFieldView
            styleFieldView
            genderFieldView
            
            if selectedChat == nil {
                contextFieldView
            }
            
            if !context.isEmpty && styleEvent != .byContext {
                Label("Context will not be applied", systemImage: "exclamationmark.circle")
                    .font(.caption)
            }
            
            if !chats.isEmpty {
                chatsFieldView
            }
            
            AppButton(text: "Generate Gift") {
                if viewModel.user?.name == nil {
                    showNameAlert = true
                } else if viewModel.checkLimitsForText() {
                    generateText()
                } else {
                    errorMessage = NSLocalizedString("You have reached the limit of text gifts", comment: "Home View")
                }
            }
            .padding(.horizontal)
        }
    }
    
    //MARK: - Chat Selection
    var chatsFieldView: some View {
        FieldView(focused: $focusedField, focus: .chat, nextFocus: nil) {
            Button {
                self.openChats = true
            } label: {
                HStack {
                    if let title = selectedChat?.title {
                        Text("Chat: \(title)")
                    } else {
                        Text("Select chat for context")
                    }
                    
                    Spacer()
                    
                    if selectedChat == nil {
                        Image(systemName: "arrow.forward")
                    } else {
                        Button {
                            selectedChat = nil
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .padding(5)
            }
        }
        .sheet(isPresented: $openChats) {
            ChatsSelectView(chats: chats, selectedChat: $selectedChat)
        }
        .onChange(of: selectedChat) { _, newValue in
            if let selectedChat {
                self.name = selectedChat.title
            }
        }
    }
    
    //MARK: - Context Field
    var contextFieldView: some View {
        FieldView(focused: $focusedField, focus: .context, nextFocus: nil) {
            TextField("", text: $context,
                      prompt: Text("You can write context (e.g. last congratulations from your friend)")
                            .font(.headline)
                            .foregroundStyle(Color.dark.opacity(0.7)),
                      axis: .vertical
            )
            .lineLimit(3, reservesSpace: true)
            .textFieldStyle(.plain)
            .submitLabel(.return)
            .onChange(of: context) { _, newValue in
                guard styleEvent != .byContext else { return }
                
                if !newValue.isEmpty {
                    styleEvent = .byContext
                }
            }
        }
    }
    
    //MARK: - Gender Field
    var genderFieldView: some View {
        FieldView(focused: $focusedField, focus: .gender, nextFocus: nil) {
            VStack(alignment: .leading) {
                Text("You can choose gender (optional)")
                    .foregroundStyle(Color.dark.opacity(0.7))
                    .padding(5)
                
                Picker(selection: $selectedGender) {
                    ForEach(Gender.allCases, id: \.self) { g in
                        Text(NSLocalizedString(g.rawValue, comment: "Home View"))
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
    
    //MARK: - Style Field
    var styleFieldView: some View {
        FieldView(focused: $focusedField, focus: .style, nextFocus: nil) {
            ZStack(alignment: .top) {
                Text("Select message style")
                    .foregroundStyle(Color.dark.opacity(0.7))
                    .padding(5)
                
                Picker(selection: $styleEvent) {
                    ForEach(MessageStyle.allCases, id: \.self) { s in
                        Text(NSLocalizedString(s.rawValue, comment: "Home View"))
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
    
    //MARK: - Type Field
    var typeFieldView: some View {
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
                                Text(NSLocalizedString(gift, comment: "Home View"))
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
    
    //MARK: - Name Field
    var nameFieldView: some View {
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
    
    //MARK: - Header
    var headerView: some View {
        Group {
            HStack {
                Text(getTitle())
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            HStack {
                Text("Let's create some gifts!")
                    .font(.title3)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    //MARK: - Appear - sort types
    func sortTypes() {
        if typeEvent.isEmpty {
            self.sortedTypes = viewModel.typeGift
        } else {
            self.sortedTypes = viewModel.typeGift.filter { $0.lowercased().contains(typeEvent.lowercased()) }
        }
    }
    
    //MARK: - Get Title for Header
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
