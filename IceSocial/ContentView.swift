import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    let username: String
    let handle: String
    let profileImage: String
    let content: String
    let timestamp: Date
    var likes: Int
    var comments: Int
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var posts: [Post] = []
    @State private var currentPage = 1
    @State private var isLoading = false
    @State private var selectedSidebarItem: SidebarItem? = .forYou
    
    enum SidebarItem: Hashable {
        case forYou
        case following
        case profile
        case settings
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSidebarItem) {
                Section(header: Text("Feeds")) {
                    NavigationLink(value: SidebarItem.forYou) {
                        Label("For You", systemImage: "star")
                    }
                    
                    NavigationLink(value: SidebarItem.following) {
                        Label("Following", systemImage: "person.2")
                    }
                }
                
                Section(header: Text("Account")) {
                    NavigationLink(value: SidebarItem.profile) {
                        Label("Profile", systemImage: "person")
                    }
                    
                    NavigationLink(value: SidebarItem.settings) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .listStyle(SidebarListStyle())
        } detail: {
            VStack {
                if selectedSidebarItem == .profile {
                    VStack(spacing: 0) {
                        Color.blue.opacity(0.5)
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                                    .offset(x: -150, y: 50)
                            )
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
                
                if selectedSidebarItem == .settings {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Settings")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            SettingsGroup(title: "Account") {
                                SettingsRow(title: "Edit Profile", systemImage: "person.crop.circle")
                                SettingsRow(title: "Change Password", systemImage: "lock")
                                SettingsRow(title: "Privacy", systemImage: "hand.raised")
                            }
                            
                            SettingsGroup(title: "Preferences") {
                                SettingsToggle(title: "Dark Mode", systemImage: "moon", isOn: .constant(false))
                                SettingsToggle(title: "Notifications", systemImage: "bell", isOn: .constant(true))
                            }
                            
                            SettingsGroup(title: "Support") {
                                SettingsRow(title: "Help Center", systemImage: "questionmark.circle")
                                SettingsRow(title: "Contact Support", systemImage: "envelope")
                            }
                        }
                        .padding()
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
                
                if selectedSidebarItem == .forYou || selectedSidebarItem == .following {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(posts) { post in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: post.profileImage)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading) {
                                            Text(post.username)
                                                .font(.headline)
                                            Text(post.handle)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Text(post.content)
                                        .padding(.vertical, 4)
                                    
                                    HStack(spacing: 20) {
                                        PostInteractionButton(systemImage: "heart", count: post.likes)
                                        PostInteractionButton(systemImage: "message", count: post.comments)
                                        PostInteractionButton(systemImage: "bookmark")
                                        PostInteractionButton(systemImage: "ellipsis")
                                    }
                                    .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            if isLoading {
                                ProgressView()
                            }
                        }
                        .onAppear {
                            loadMorePosts()
                        }
                        .padding(.horizontal)
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedSidebarItem)
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    func loadMorePosts() {
        guard !isLoading else { return }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newPosts = [
                Post(
                    username: "IceSocial User",
                    handle: "user.icesocial.net", 
                    profileImage: "person.circle.fill", 
                    content: "Welcome to IceSocial! This is a sample post to showcase the platform.", 
                    timestamp: Date(),
                    likes: 42,
                    comments: 5
                )
            ]
            
            posts.append(contentsOf: newPosts)
            currentPage += 1
            isLoading = false
        }
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct SettingsToggle: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                Text(title)
            }
        }
        .padding()
    }
}

struct PostInteractionButton: View {
    let systemImage: String
    var count: Int? = nil
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
            if let count = count {
                Text("\(count)")
            }
        }
    }
}

#Preview {
    ContentView()
}
