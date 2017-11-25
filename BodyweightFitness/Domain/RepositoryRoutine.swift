import Foundation
import RealmSwift

class RepositoryRoutine: Object {
    dynamic var id = "Routine-" + UUID().uuidString
    dynamic var routineId = ""
    dynamic var title = ""
    dynamic var subtitle = ""
    dynamic var startTime = Date()
    dynamic var lastUpdatedTime = Date()
    
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
