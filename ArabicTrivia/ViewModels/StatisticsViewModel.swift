import Foundation
import SwiftUI

/// مدير واجهات الإحصائيات وسجل المباريات
public final class StatisticsViewModel: ObservableObject {
    public let dataManager = DataManager.shared
    
    public init() {}
    
    public var stats: OverallStatistics {
        dataManager.statistics
    }
    
    public var matches: [MatchRecord] {
        dataManager.matchesHistory
    }
}
