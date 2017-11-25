import Foundation
import RealmSwift

class RepositoryCategory: Object {
    dynamic var id = "Category-" + UUID().uuidString
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
