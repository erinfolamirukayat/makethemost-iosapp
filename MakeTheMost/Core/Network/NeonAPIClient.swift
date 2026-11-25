import Foundation
import CryptoKit

/// Network client connecting directly to the Vercel + Neon Postgres serverless backend.
/// Live endpoint: https://makethemost-backend.vercel.app
public final class NeonAPIClient {
    public static let shared = NeonAPIClient()
    
    public var baseUrl = "https://makethemost-backend.vercel.app"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Helper: SHA256 hashing matching backend & Android
    public static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Health Check
    public func checkHealth() async throws -> Bool {
        guard let url = URL(string: "\(baseUrl)/api/health") else { return false }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let status = json["status"] as? String {
            return status == "ok"
        }
        return false
    }
    
    // MARK: - User Authentication: Sign In
    public func login(email: String, password: String) async throws -> UserAccount {
        guard let url = URL(string: "\(baseUrl)/api/users/login") else {
            throw URLError(.badURL)
        }
        
        let passwordHash = Self.sha256(password)
        let payload: [String: Any] = [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "passwordHash": passwordHash,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorObj["error"] as? String {
                throw NSError(domain: "MakeTheMostAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
            throw NSError(domain: "MakeTheMostAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Authentication failed."])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let userDict = json["user"] as? [String: Any] else {
            throw NSError(domain: "MakeTheMostAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Malformed response from server."])
        }
        
        let id = userDict["deviceIdHash"] as? String ?? userDict["id"] as? String ?? UUID().uuidString
        let fullName = userDict["fullName"] as? String ?? "Member"
        let returnedEmail = userDict["email"] as? String ?? email
        let partnerEmail = userDict["partnerEmail"] as? String ?? ""
        let createdAtMs = (userDict["createdAtMs"] as? NSNumber)?.int64Value ?? Int64(Date().timeIntervalSince1970 * 1000)
        let schedulesJson = userDict["schedulesJson"] as? String
        let motivationCardsJson = userDict["motivationCardsJson"] as? String
        
        let account = UserAccount(
            id: id,
            fullName: fullName,
            email: returnedEmail,
            partnerEmail: partnerEmail,
            passwordHash: passwordHash,
            createdAtMs: createdAtMs,
            schedulesJson: schedulesJson,
            motivationCardsJson: motivationCardsJson
        )
        
        AppGroupStorage.shared.saveUserAccount(account)
        return account
    }
    
    // MARK: - User Registration / Sync Profile
    public func syncUser(account: UserAccount) async throws -> Bool {
        guard let url = URL(string: "\(baseUrl)/api/users/sync") else {
            throw URLError(.badURL)
        }
        
        let payload: [String: Any?] = [
            "deviceIdHash": account.id,
            "fullName": account.fullName,
            "email": account.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "partnerEmail": account.partnerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "passwordHash": account.passwordHash,
            "schedulesJson": account.schedulesJson,
            "motivationCardsJson": account.motivationCardsJson
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload.compactMapValues { $0 })
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let synced = json["synced"] as? Bool {
            return synced
        }
        return true
    }
    
    // MARK: - Sync Schedules & Motivation Cards Cloud Backup
    public func syncSchedules(account: UserAccount, schedules: [MakeTheMostSchedule]) async throws -> Bool {
        guard let url = URL(string: "\(baseUrl)/api/users/sync-schedules") else {
            throw URLError(.badURL)
        }
        
        let encoder = JSONEncoder()
        let schedulesData = try encoder.encode(schedules)
        let schedulesJson = String(data: schedulesData, encoding: .utf8) ?? "[]"
        
        let payload: [String: Any] = [
            "deviceIdHash": account.id,
            "email": account.email.lowercased(),
            "schedulesJson": schedulesJson,
            "motivationCardsJson": account.motivationCardsJson ?? "[]"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        return true
    }
    
    // MARK: - Daily Compliance Sync
    public func syncCompliance(summary: DailyComplianceSummary, account: UserAccount) async throws -> Bool {
        guard let url = URL(string: "\(baseUrl)/api/compliance/sync") else {
            throw URLError(.badURL)
        }
        
        let payload: [String: Any] = [
            "deviceIdHash": account.id,
            "email": account.email.lowercased(),
            "dateIso": summary.dateIso,
            "makeTheMostScheduledMinutes": summary.makeTheMostScheduledMinutes,
            "makeTheMostBypassedMinutes": summary.makeTheMostBypassedMinutes,
            "brutalFastScheduledMinutes": summary.brutalFastScheduledMinutes,
            "brutalFastBrokenMinutes": summary.brutalFastBrokenMinutes
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        return true
    }
    
    // MARK: - Send Tester Feedback
    public func sendFeedback(
        email: String,
        name: String,
        category: String,
        rating: Int,
        message: String
    ) async throws -> (success: Bool, message: String) {
        guard let url = URL(string: "\(baseUrl)/api/feedback") else {
            throw URLError(.badURL)
        }
        
        let payload: [String: Any] = [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "name": name,
            "category": category,
            "rating": rating,
            "message": message,
            "deviceInfo": "iOS Device",
            "appVersion": "1.0.0"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "MakeTheMostFeedback", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to send feedback."])
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let success = json["success"] as? Bool,
           let msg = json["message"] as? String {
            return (success, msg)
        }
        return (true, "Feedback received!")
    }
    
    // MARK: - Delete Account (Permanent Data Deletion)
    public func deleteAccount(email: String, password: String) async throws -> Bool {
        guard let url = URL(string: "\(baseUrl)/api/users/delete-account") else {
            throw URLError(.badURL)
        }
        
        let payload: [String: Any] = [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "password": password,
            "passwordHash": Self.sha256(password)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        AppGroupStorage.shared.clearUserAccount()
        return true
    }
}
