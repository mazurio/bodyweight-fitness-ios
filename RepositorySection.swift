import Foundation
import RealmSwift

class RepositorySection: Object {
    dynamic var id = "Section-" + NSUUID().UUIDString
    dynamic var sectionId = ""
    dynamic var title = ""
    dynamic var mode = ""
    dynamic var routine: RepositoryRoutine?
    dynamic var category: RepositoryCategory?
    
    let exercises = List<RepositoryExercise>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["sectionId"]
    }
}