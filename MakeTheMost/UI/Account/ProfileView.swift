import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAuthSheet: Bool = false
    @State private var showFeedbackSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var deletePasswordInput: String = ""
    @State private var backendConnected: Bool? = nil
    @State private var isCheckingBackend: Bool = false
    @State private var deleteErrorMessage: String? = nil
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header Card
                    if let account = appState.userAccount {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Theme.elevatedSlate)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.title)
                                        .foregroundColor(Theme.electricEmerald)
                                )
                            
                            VStack(spacing: 4) {
                                Text(account.fullName)
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                
                                Text(account.email)
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .frostedCardStyle()
                    } else {
                        // Sign In Prompt Card
                        VStack(spacing: 12) {
                            Text("Sign In or Register")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Save your focus windows and 30-day trial progress to the cloud.")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { showAuthSheet = true }) {
                                Text("Sign In / Sign Up")
                                    .primaryButtonStyle()
                            }
                        }
                        .padding(20)
                        .frostedCardStyle()
                    }
                    
                    // Membership Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(Theme.electricEmerald)
                            Text("Membership")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            Text("100% Free")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.electricEmerald)
                        }
                        
                        Text("All Breakout Challenges, App Swap modes, and cloud backup are free to use.")
                            .font(.caption2)
                            .foregroundColor(Theme.textMuted)
                    }
                    .padding(18)
                    .frostedCardStyle()
                    
                    // Cloud & Backend Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cloud & Backend Sync")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        HStack {
                            Text("Neon Serverless Postgres")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            Spacer()
                            if isCheckingBackend {
                                ProgressView().scaleEffect(0.8)
                            } else if backendConnected == true {
                                HStack(spacing: 4) {
                                    Circle().fill(Theme.electricEmerald).frame(width: 8, height: 8)
                                    Text("Connected").font(.caption2).foregroundColor(Theme.electricEmerald)
                                }
                            } else {
                                Text("Checking...").font(.caption2).foregroundColor(Theme.textMuted)
                            }
                        }
                    }
                    .padding(18)
                    .frostedCardStyle()
                    
                    // App Actions
                    VStack(spacing: 12) {
                        Button(action: { showFeedbackSheet = true }) {
                            HStack {
                                Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                                Text("Send Feedback & Feature Requests")
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(Theme.textPrimary)
                            .padding(16)
                            .frostedCardStyle()
                        }
                        
                        if appState.userAccount != nil {
                            Button(action: {
                                AppGroupStorage.shared.clearUserAccount()
                                appState.userAccount = nil
                            }) {
                                Text("Sign Out")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.crimsonPulse)
                            }
                            .padding(.top, 8)
                            
                            Button(action: { showDeleteAlert = true }) {
                                Text("Delete Account & Cloud Data")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationTitle("Account")
            .sheet(isPresented: $showAuthSheet) {
                AuthView()
            }
            .sheet(isPresented: $showFeedbackSheet) {
                FeedbackSheet()
            }
            .alert("Delete Account?", isPresented: $showDeleteAlert) {
                SecureField("Enter password to confirm", text: $deletePasswordInput)
                Button("Delete Permanently", role: .destructive) {
                    confirmAccountDeletion()
                }
                Button("Cancel", role: .cancel) {
                    deletePasswordInput = ""
                }
            } message: {
                Text("This permanently deletes your MakeTheMost account and all cloud synced data from Neon Postgres. This action cannot be undone.")
            }
            .task {
                checkBackend()
            }
        }
    }
    
    private func checkBackend() {
        isCheckingBackend = true
        Task {
            let ok = (try? await NeonAPIClient.shared.checkHealth()) ?? false
            await MainActor.run {
                self.backendConnected = ok
                self.isCheckingBackend = false
            }
        }
    }
    
    private func confirmAccountDeletion() {
        guard let account = appState.userAccount, !deletePasswordInput.isEmpty else { return }
        Task {
            let deleted = (try? await NeonAPIClient.shared.deleteAccount(email: account.email, password: deletePasswordInput)) ?? false
            await MainActor.run {
                if deleted {
                    appState.userAccount = nil
                    deletePasswordInput = ""
                } else {
                    deleteErrorMessage = "Incorrect password or network error."
                }
            }
        }
    }
}

struct FeedbackSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var message: String = ""
    @State private var rating: Int = 5
    @State private var isSubmitting: Bool = false
    @State private var statusMessage: String? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Info")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Message")) {
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                }
                
                Section {
                    Button(action: send) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit Feedback")
                                .foregroundColor(Theme.electricEmerald)
                        }
                    }
                    .disabled(email.isEmpty || message.isEmpty || isSubmitting)
                }
                
                if let status = statusMessage {
                    Section {
                        Text(status).font(.caption).foregroundColor(Theme.electricEmerald)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func send() {
        isSubmitting = true
        Task {
            do {
                let res = try await NeonAPIClient.shared.sendFeedback(
                    email: email,
                    name: name,
                    category: "iOS Beta Feedback",
                    rating: rating,
                    message: message
                )
                await MainActor.run {
                    self.statusMessage = res.message
                    self.isSubmitting = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    self.statusMessage = error.localizedDescription
                    self.isSubmitting = false
                }
            }
        }
    }
}
