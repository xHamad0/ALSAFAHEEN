import Foundation
import Combine

/// مدير البيانات المحلي والتخزين الدائم للعبة
public final class DataManager: ObservableObject {
    public static let shared = DataManager()
    
    private let matchesFileName = "sijal_matches_history.json"
    private let statsFileName = "sijal_overall_stats.json"
    private let activeSessionFileName = "sijal_active_session.json"
    private let settingsFileName = "sijal_settings.json"
    
    @Published public var matchesHistory: [MatchRecord] = []
    @Published public var statistics: OverallStatistics = OverallStatistics()
    @Published public var savedActiveSession: GameSession? = nil
    
    // إعدادات التطبيق
    @Published public var isSoundEnabled: Bool = true
    @Published public var soundVolume: Float = 0.8
    @Published public var isHapticsEnabled: Bool = true
    @Published public var defaultTeam1Name: String = "فرسان الحكمة"
    @Published public var defaultTeam2Name: String = "صقور التحدي"
    @Published public var defaultTeam1Color: String = AppTheme.defaultTeam1Color
    @Published public var defaultTeam2Color: String = AppTheme.defaultTeam2Color
    
    private init() {
        loadAllData()
    }
    
    private func getDocumentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public func loadAllData() {
        loadSettings()
        loadMatchesHistory()
        loadStatistics()
        loadActiveSession()
    }
    
    // MARK: - Matches History
    public func loadMatchesHistory() {
        let url = getDocumentsURL().appendingPathComponent(matchesFileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            self.matchesHistory = try JSONDecoder().decode([MatchRecord].self, from: data)
        } catch {
            print("Error loading matches history: \(error)")
        }
    }
    
    public func saveMatchRecord(_ record: MatchRecord) {
        matchesHistory.insert(record, at: 0)
        let url = getDocumentsURL().appendingPathComponent(matchesFileName)
        do {
            let data = try JSONEncoder().encode(matchesHistory)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error saving match record: \(error)")
        }
        
        // تحديث الإحصائيات تلقائياً
        updateStatistics(with: record)
    }
    
    // MARK: - Overall Statistics
    public func loadStatistics() {
        let url = getDocumentsURL().appendingPathComponent(statsFileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            self.statistics = try JSONDecoder().decode(OverallStatistics.self, from: data)
        } catch {
            print("Error loading statistics: \(error)")
        }
    }
    
    private func updateStatistics(with match: MatchRecord) {
        statistics.totalMatchesPlayed += 1
        statistics.totalPointsScored += (match.team1Score + match.team2Score)
        statistics.totalCorrectAnswers += (match.team1Correct + match.team2Correct)
        statistics.totalWrongAnswers += (match.team1Wrong + match.team2Wrong)
        
        if let winner = match.winnerName {
            statistics.teamWins[winner, default: 0] += 1
        }
        
        let maxScoreInMatch = max(match.team1Score, match.team2Score)
        if maxScoreInMatch > statistics.highestScoreRecord {
            statistics.highestScoreRecord = maxScoreInMatch
        }
        
        // سجل المواجهات المباشرة
        let h2hKey = "\(match.team1Name) vs \(match.team2Name)"
        var h2hDict = statistics.headToHeadRecords[h2hKey, default: [:]]
        if let winner = match.winnerName {
            h2hDict[winner, default: 0] += 1
        } else {
            h2hDict["تعادل", default: 0] += 1
        }
        statistics.headToHeadRecords[h2hKey] = h2hDict
        
        saveStatistics()
    }
    
    public func saveStatistics() {
        let url = getDocumentsURL().appendingPathComponent(statsFileName)
        do {
            let data = try JSONEncoder().encode(statistics)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error saving statistics: \(error)")
        }
    }
    
    // MARK: - Active Session Persistence (استكمال المباراة)
    public func saveActiveSession(_ session: GameSession) {
        self.savedActiveSession = session
        let url = getDocumentsURL().appendingPathComponent(activeSessionFileName)
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error saving active session: \(error)")
        }
    }
    
    public func loadActiveSession() {
        let url = getDocumentsURL().appendingPathComponent(activeSessionFileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            self.savedActiveSession = try JSONDecoder().decode(GameSession.self, from: data)
        } catch {
            print("Error loading active session: \(error)")
        }
    }
    
    public func clearActiveSession() {
        self.savedActiveSession = nil
        let url = getDocumentsURL().appendingPathComponent(activeSessionFileName)
        try? FileManager.default.removeItem(at: url)
    }
    
    // MARK: - App Settings
    private struct SavedSettings: Codable {
        var isSoundEnabled: Bool
        var soundVolume: Float
        var isHapticsEnabled: Bool
        var defaultTeam1Name: String
        var defaultTeam2Name: String
        var defaultTeam1Color: String
        var defaultTeam2Color: String
    }
    
    public func saveSettings() {
        let settings = SavedSettings(
            isSoundEnabled: isSoundEnabled,
            soundVolume: soundVolume,
            isHapticsEnabled: isHapticsEnabled,
            defaultTeam1Name: defaultTeam1Name,
            defaultTeam2Name: defaultTeam2Name,
            defaultTeam1Color: defaultTeam1Color,
            defaultTeam2Color: defaultTeam2Color
        )
        let url = getDocumentsURL().appendingPathComponent(settingsFileName)
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error saving settings: \(error)")
        }
    }
    
    public func loadSettings() {
        let url = getDocumentsURL().appendingPathComponent(settingsFileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let s = try JSONDecoder().decode(SavedSettings.self, from: data)
            self.isSoundEnabled = s.isSoundEnabled
            self.soundVolume = s.soundVolume
            self.isHapticsEnabled = s.isHapticsEnabled
            self.defaultTeam1Name = s.defaultTeam1Name
            self.defaultTeam2Name = s.defaultTeam2Name
            self.defaultTeam1Color = s.defaultTeam1Color
            self.defaultTeam2Color = s.defaultTeam2Color
        } catch {
            print("Error loading settings: \(error)")
        }
    }
}
