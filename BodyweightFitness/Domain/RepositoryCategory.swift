import Foundation
import RealmSwift

class CompletionRate {
    let percentage: Int
    let label: String

    init(percentage: Int, label: String) {
        self.percentage = percentage
        self.label = label
    }
}

class RepositoryCategoryHelper {
    class func getCompletionRate(_ repositoryCategory: RepositoryCategory) -> CompletionRate {
        if (numberOfExercises(repositoryCategory) == 0) {
            return CompletionRate(percentage: 0, label: "0%")
        }

        let percentage = numberOfCompletedExercises(repositoryCategory) * 100 / numberOfExercises(repositoryCategory)

        return CompletionRate(percentage: percentage, label: String(percentage) + "%")
    }

    class func isCompleted(_ repositoryExercise: RepositoryExercise) -> Bool {
        let size = repositoryExercise.sets.count

        if (size == 0) {
            return false
        }

        let firstSet = repositoryExercise.sets[0] as RepositorySet

        if (size == 1 && firstSet.seconds == 0 && firstSet.reps == 0) {
            return false
        }

        return true
    }

    class func numberOfCompletedExercises(_ repositoryCategory: RepositoryCategory) -> Int {
        let filtered = repositoryCategory.exercises.filter({
            $0.visible && isCompleted($0)
        })
        
        return filtered.count
    }

    class func numberOfExercises(_ repositoryCategory: RepositoryCategory) -> Int {
        let filtered = repositoryCategory.exercises.filter({
            $0.visible
        })
        
        return filtered.count
    }
}

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
