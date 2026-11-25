import SwiftUI

public struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSignUp: Bool = false
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var partnerEmail: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "hourglass.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.electricEmerald)
                        
                        Text(isSignUp ? "Create Free Account" : "Welcome Back")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text("Sync your schedules and settings seamlessly across devices.")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)
                    
                    // Mode Picker
                    Picker("Mode", selection: $isSignUp) {
                        Text("Sign In").tag(false)
                        Text("Sign Up").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    // Form Fields
                    VStack(spacing: 14) {
                        if isSignUp {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Full Name").font(.caption).foregroundColor(Theme.textMuted)
                                TextField("Your Name", text: $fullName)
                                    .textFieldStyle(CustomInputFieldStyle())
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address").font(.caption).foregroundColor(Theme.textMuted)
                            TextField("you@example.com", text: $email)
                                .textFieldStyle(CustomInputFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        
                        if isSignUp {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Accountability Partner Email (Optional)").font(.caption).foregroundColor(Theme.textMuted)
                                TextField("partner@example.com", text: $partnerEmail)
                                    .textFieldStyle(CustomInputFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password").font(.caption).foregroundColor(Theme.textMuted)
                            SecureField("••••••••", text: $password)
                                .textFieldStyle(CustomInputFieldStyle())
                        }
                    }
                    .padding(20)
                    .frostedCardStyle()
                    
                    if let err = errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(Theme.crimsonPulse)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Action Button
                    Button(action: handleAuth) {
                        if isLoading {
                            ProgressView()
                                .tint(Color(hex: 0x032218))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.electricEmerald)
                                .cornerRadius(12)
                        } else {
                            Text(isSignUp ? "Create Free Account" : "Sign In")
                                .primaryButtonStyle(isEnabled: !email.isEmpty && !password.isEmpty)
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                }
                .padding(20)
            }
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignUp {
                    let newAccount = UserAccount(
                        fullName: fullName.isEmpty ? "Member" : fullName,
                        email: email,
                        partnerEmail: partnerEmail,
                        passwordHash: NeonAPIClient.sha256(password)
                    )
                    _ = try await NeonAPIClient.shared.syncUser(account: newAccount)
                    await MainActor.run {
                        AppGroupStorage.shared.saveUserAccount(newAccount)
                        appState.userAccount = newAccount
                        isLoading = false
                        dismiss()
                    }
                } else {
                    let loggedIn = try await NeonAPIClient.shared.login(email: email, password: password)
                    await MainActor.run {
                        appState.userAccount = loggedIn
                        appState.loadData()
                        isLoading = false
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct CustomInputFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Theme.elevatedSlate)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.subtleBorder, lineWidth: 1)
            )
            .foregroundColor(Theme.textPrimary)
    }
}
