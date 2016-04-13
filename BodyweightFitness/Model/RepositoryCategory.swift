import Foundation
import RealmSwift

class RepositoryCategory: Object {
    dynamic var id = "Category-" + NSUUID().UUIDString
    dynamic var categoryId = ""
    dynamic var title = ""
    dynamic var routine: RepositoryRoutine?
    
    let sections = List<RepositorySection>()
    let exercises = List<RepositoryExercise>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["categoryId"]
    }
}