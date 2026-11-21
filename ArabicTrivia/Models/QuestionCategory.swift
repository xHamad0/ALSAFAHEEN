import Foundation
import SwiftUI

/// التصنيفات الـ 26 المعتمدة للعبة مسابقات «سجال»
public enum QuestionCategory: String, Codable, CaseIterable, Identifiable {
    case football = "football"
    case worldCup = "world_cup"
    case saudiFootball = "saudi_football"
    case championsLeague = "champions_league"
    case islamicHistory = "islamic_history"
    case worldHistory = "world_history"
    case geography = "geography"
    case flags = "flags"
    case science = "science"
    case physicsChemistry = "physics_chemistry"
    case mathematics = "mathematics"
    case generalCulture = "general_culture"
    case cinemaMovies = "cinema_movies"
    case series = "series"
    case musicArts = "music_arts"
    case technology = "technology"
    case cars = "cars"
    case animalsNature = "animals_nature"
    case literatureBooks = "literature_books"
    case famousPeople = "famous_people"
    case riddlesIq = "riddles_iq"
    case islamicGeneral = "islamic_general"
    case saudiArabia = "saudi_arabia"
    case arabWorld = "arab_world"
    case miscellaneous = "miscellaneous"
    case letters = "letters"
    
    public var id: String { rawValue }
    
    public var titleArabic: String {
        switch self {
        case .football: return "كرة القدم"
        case .worldCup: return "كأس العالم لكرة القدم"
        case .saudiFootball: return "كرة القدم السعودية"
        case .championsLeague: return "دوري أبطال أوروبا"
        case .islamicHistory: return "التاريخ الإسلامي"
        case .worldHistory: return "التاريخ العالمي"
        case .geography: return "الجغرافيا والدول والعواصم"
        case .flags: return "أعلام الدول"
        case .science: return "العلوم"
        case .physicsChemistry: return "الفيزياء والكيمياء"
        case .mathematics: return "الرياضيات"
        case .generalCulture: return "الثقافة العامة"
        case .cinemaMovies: return "السينما والأفلام"
        case .series: return "المسلسلات"
        case .musicArts: return "الموسيقى والفنون"
        case .technology: return "التكنولوجيا والاختراعات"
        case .cars: return "السيارات"
        case .animalsNature: return "الحيوانات والطبيعة"
        case .literatureBooks: return "الأدب والكتب"
        case .famousPeople: return "الشخصيات المشهورة"
        case .riddlesIq: return "الألغاز والذكاء"
        case .islamicGeneral: return "المعلومات الدينية العامة"
        case .saudiArabia: return "المملكة العربية السعودية"
        case .arabWorld: return "العالم العربي"
        case .miscellaneous: return "المعلومات المتنوعة"
        case .letters: return "الحروف"
        }
    }
    
    public var iconName: String {
        switch self {
        case .football: return "soccerball"
        case .worldCup: return "trophy.fill"
        case .saudiFootball: return "sportscourt.fill"
        case .championsLeague: return "star.circle.fill"
        case .islamicHistory: return "moon.stars.fill"
        case .worldHistory: return "hourglass"
        case .geography: return "globe.europe.africa.fill"
        case .flags: return "flag.fill"
        case .science: return "atom"
        case .physicsChemistry: return "flask.fill"
        case .mathematics: return "function"
        case .generalCulture: return "lightbulb.fill"
        case .cinemaMovies: return "film.fill"
        case .series: return "tv.fill"
        case .musicArts: return "music.note"
        case .technology: return "cpu.fill"
        case .cars: return "car.fill"
        case .animalsNature: return "leaf.fill"
        case .literatureBooks: return "books.vertical.fill"
        case .famousPeople: return "person.2.fill"
        case .riddlesIq: return "brain.head.profile"
        case .islamicGeneral: return "book.closed.fill"
        case .saudiArabia: return "building.columns.fill"
        case .arabWorld: return "map.fill"
        case .miscellaneous: return "square.grid.2x2.fill"
        case .letters: return "character.book.closed.fill"
        }
    }
    
    public var jsonFileName: String {
        return self.rawValue
    }
    
    public var themeColor: Color {
        switch self {
        case .football, .saudiFootball, .saudiArabia:
            return Color(hex: "#10B981")
        case .worldCup, .championsLeague:
            return Color(hex: "#F59E0B")
        case .islamicHistory, .islamicGeneral:
            return Color(hex: "#065F46")
        case .worldHistory, .geography, .arabWorld:
            return Color(hex: "#0284C7")
        case .flags:
            return Color(hex: "#EF4444")
        case .science, .physicsChemistry, .mathematics:
            return Color(hex: "#6366F1")
        case .generalCulture, .miscellaneous:
            return Color(hex: "#EAB308")
        case .cinemaMovies, .series, .musicArts:
            return Color(hex: "#EC4899")
        case .technology, .cars:
            return Color(hex: "#14B8A6")
        case .animalsNature:
            return Color(hex: "#84CC16")
        case .literatureBooks, .famousPeople:
            return Color(hex: "#8B5CF6")
        case .riddlesIq:
            return Color(hex: "#F97316")
        case .letters:
            return Color(hex: "#D946EF")
        }
    }
}
