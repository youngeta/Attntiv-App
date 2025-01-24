import SwiftUI

struct CognitiveFeedView: View {
    @StateObject private var viewModel = CognitiveFeedViewModel()
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            TabView(selection: $viewModel.currentIndex) {
                ForEach(viewModel.feedItems) { item in
                    FeedItemView(item: item)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .onAppear {
            viewModel.loadFeedItems()
        }
    }
}

struct FeedItemView: View {
    let item: FeedItem
    @State private var isLiked = false
    @State private var showingDetails = false
    
    private let gradient = LinearGradient(
        colors: [.black.opacity(0.7), .clear],
        startPoint: .bottom,
        endPoint: .center
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Content
                VStack {
                    Text(item.content)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(item.backgroundColor)
                }
                
                // Overlay gradient
                Rectangle()
                    .fill(gradient)
                    .frame(height: geometry.size.height * 0.4)
                
                // Interactive elements
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title)
                                .font(.headline)
                            
                            Text(item.category)
                                .font(.subheadline)
                                .opacity(0.7)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingDetails.toggle()
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                        }
                    }
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            withAnimation {
                                isLiked.toggle()
                            }
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.title)
                                .foregroundColor(isLiked ? .red : .white)
                        }
                        
                        Button(action: {
                            // Share functionality
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title)
                        }
                        
                        Button(action: {
                            // Save functionality
                        }) {
                            Image(systemName: "bookmark")
                                .font(.title)
                        }
                    }
                }
                .foregroundColor(.white)
                .padding()
            }
        }
        .sheet(isPresented: $showingDetails) {
            FeedItemDetailView(item: item)
        }
    }
}

struct FeedItemDetailView: View {
    let item: FeedItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(item.content)
                        .font(.body)
                    
                    if let additionalContent = item.additionalContent {
                        Text("Learn More")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(additionalContent)
                            .font(.body)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - View Model
class CognitiveFeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var currentIndex: UUID = UUID()
    @Published var isLoading = false
    
    func loadFeedItems() {
        isLoading = true
        
        // Simulate loading feed items
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.feedItems = [
                FeedItem(
                    title: "The Power of Neuroplasticity",
                    content: "Your brain can form new neural connections throughout your life. This ability is called neuroplasticity.",
                    category: "Neuroscience",
                    backgroundColor: .purple.opacity(0.3)
                ),
                FeedItem(
                    title: "Memory Enhancement",
                    content: "The hippocampus plays a crucial role in forming, organizing, and storing memories.",
                    category: "Brain Function",
                    backgroundColor: .blue.opacity(0.3)
                ),
                FeedItem(
                    title: "Cognitive Exercise",
                    content: "Regular mental exercises can improve memory, focus, and problem-solving abilities.",
                    category: "Mental Fitness",
                    backgroundColor: .green.opacity(0.3)
                )
            ]
            self.currentIndex = self.feedItems.first?.id ?? UUID()
            self.isLoading = false
        }
    }
}

// MARK: - Models
struct FeedItem: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let category: String
    let backgroundColor: Color
    var additionalContent: String?
}

// MARK: - Preview
struct CognitiveFeedView_Previews: PreviewProvider {
    static var previews: some View {
        CognitiveFeedView()
            .preferredColorScheme(.dark)
    }
} 