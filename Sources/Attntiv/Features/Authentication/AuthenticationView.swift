import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var authMode: AuthMode = .signIn
    
    private let gradient = LinearGradient(
        colors: [Color("Primary").opacity(0.8), Color("Primary").opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundStyle(gradient)
                    
                    Text("Attntiv")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 50)
                
                // Auth Mode Picker
                Picker("Authentication Mode", selection: $authMode) {
                    Text("Sign In").tag(AuthMode.signIn)
                    Text("Sign Up").tag(AuthMode.signUp)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 50)
                
                // Auth Fields
                VStack(spacing: 20) {
                    if authMode == .signUp {
                        CustomTextField(text: $viewModel.username, placeholder: "Username", systemImage: "person")
                    }
                    
                    CustomTextField(text: $viewModel.email, placeholder: "Email", systemImage: "envelope")
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    CustomSecureField(text: $viewModel.password, placeholder: "Password", systemImage: "lock")
                }
                .padding(.horizontal, 30)
                
                // Action Button
                Button(action: {
                    Task {
                        await viewModel.authenticate(mode: authMode)
                    }
                }) {
                    Text(authMode == .signIn ? "Sign In" : "Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(gradient)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Custom Views
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(Color("Primary"))
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(Color("Primary"))
            SecureField(placeholder, text: $text)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - View Model
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var isLoading = false
    @Published var error: String?
    
    func authenticate(mode: AuthMode) async {
        isLoading = true
        error = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implement actual authentication
        isLoading = false
    }
}

// MARK: - Supporting Types
enum AuthMode {
    case signIn
    case signUp
}

// MARK: - Preview
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
} 