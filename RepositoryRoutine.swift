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
}