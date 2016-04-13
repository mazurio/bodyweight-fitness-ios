import Foundation
import RealmSwift

class RepositoryExercise: Object {
    dynamic var id = "Exercise-" + NSUUID().UUIDString
    dynamic var exerciseId = ""
    dynamic var title = ""
    dynamic var desc = ""
    dynamic var defaultSet = ""
    dynamic var visible = true
    dynamic var routine: RepositoryRoutine?
    dynamic var category: RepositoryCategory?
    dynamic var section: RepositorySection?
    
    let sets = List<RepositorySet>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["exerciseId"]
    }
}