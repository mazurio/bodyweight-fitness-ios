import Foundation
import RealmSwift

class RepositorySet: Object {
    dynamic var id = "Set-" + UUID().uuidString
    dynamic var isTimed = false
    dynamic var weight = 0.0
    dynamic var reps = 0
    dynamic var seconds = 0
    dynamic var exercise: RepositoryExercise?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
