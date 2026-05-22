import SwiftUI
import Combine

// MARK: - App View Model
@MainActor
class AppViewModel: ObservableObject {
    // Navigation state
    @Published var navigationPath = NavigationPath()
    @Published var selectedApplication: LoanApplication?
    @Published var showSideMenu: Bool = false
    @Published var searchText: String = ""
    @Published var selectedBranch: String = "Mumbai Central"

    // Data
    @Published var officerProfile = SampleData.officerProfile
    @Published var kpiData = SampleData.kpiData
    @Published var quickActions = SampleData.quickActions
    @Published var recentApplications = SampleData.recentApplications
    @Published var activityFeed = SampleData.activityFeed
    @Published var notifications = SampleData.notifications
    @Published var overdueBorrowers = SampleData.overdueBorrowers
    //@Published var fieldVisits = SampleData.fieldVisits
    @Published var conversations = SampleData.conversations
    @Published var digitalDocuments = SampleData.digitalDocuments
    @Published var documents = SampleData.sampleDocuments
    @Published var collateral = SampleData.sampleCollateral
    @Published var selectedConversation: BorrowerConversation?

    // UI State
    @Published var showApproveConfirmation = false
    @Published var showRejectConfirmation = false
    @Published var showEscalateSheet = false
    @Published var showDocumentRequest = false
    @Published var showSearchBar = false
    @Published var showBranchSelector = false

    // Computed
    var unreadNotifications: Int {
        notifications.filter { !$0.isRead }.count
    }

    var totalPendingTasks: Int {
        kpiData.reduce(0) { $0 + $1.value }
    }

    var branches: [String] {
        ["Mumbai Central", "Mumbai South", "Delhi NCR", "Pune West", "Bangalore East", "Chennai Central"]
    }

    var filteredApplications: [LoanApplication] {
        if searchText.isEmpty {
            return recentApplications
        }
        return recentApplications.filter { app in
            app.borrowerName.localizedCaseInsensitiveContains(searchText) ||
            app.loanType.localizedCaseInsensitiveContains(searchText) ||
            app.status.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Actions
    func approveApplication(_ app: LoanApplication) {
        if let index = recentApplications.firstIndex(where: { $0.id == app.id }) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                recentApplications[index].status = .approved
            }
        }
    }

    func rejectApplication(_ app: LoanApplication) {
        if let index = recentApplications.firstIndex(where: { $0.id == app.id }) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                recentApplications[index].status = .rejected
            }
        }
    }

    func escalateApplication(_ app: LoanApplication) {
        if let index = recentApplications.firstIndex(where: { $0.id == app.id }) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                recentApplications[index].status = .escalated
            }
        }
    }

    func markNotificationRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    func markBorrowerContacted(_ borrower: OverdueBorrower) {
        if let index = overdueBorrowers.firstIndex(where: { $0.id == borrower.id }) {
            overdueBorrowers[index].lastContactDate = Date()
            overdueBorrowers[index].contactAttempts += 1
        }
    }

    // Greeting
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
}
