import Foundation
import RealmSwift

class RepositoryRoutine: Object {
    dynamic var id = "Routine-" + NSUUID().UUIDString
    dynamic var routineId = "routine0"
    dynamic var startTime = NSDate()
    dynamic var lastUpdatedTime = NSDate()
    
    let categories = List<RepositoryCategory>()
    let sections = List<RepositorySection>()
    let exercises = List<RepositoryExercise>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["routineId"]
    }
    
    func getDate() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, d MMMM YYYY"
        
        return formatter.stringFromDate(startTime)
    }
    
    func getStartTime(longFormat: Bool = false) -> String {
        if longFormat {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEEE, d MMMM YYYY - HH:mm"
            
            return formatter.stringFromDate(startTime)
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.stringFromDate(startTime)
    }
    
    func getLastUpdatedTime() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.stringFromDate(lastUpdatedTime)
    }
    
    func getWorkoutLength() -> String {
        let interval = lastUpdatedTime.timeIntervalSinceDate(startTime)
        
        let (hours, minutes) = stringFromTimeInterval(interval)
        
        if (hours > 0 || minutes > 10) {
            if (hours > 0) {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes) minutes"
            }
        } else {
            return "--"
        }

    }
}