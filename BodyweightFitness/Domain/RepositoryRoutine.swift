import Foundation
import RealmSwift

class RepositoryRoutineHelper {
    let repositoryRoutine: RepositoryRoutine
    
    init(repositoryRoutine: RepositoryRoutine) {
        self.repositoryRoutine = repositoryRoutine
    }
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM YYYY"
        
        return formatter.string(from: repositoryRoutine.startTime)
    }
    
    func getStartTime(_ longFormat: Bool = false) -> String {
        if longFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM YYYY - HH:mm"
            
            return formatter.string(from: repositoryRoutine.startTime)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: repositoryRoutine.startTime)
    }
    
    func getLastUpdatedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: repositoryRoutine.lastUpdatedTime)
    }
    
    func getWorkoutLength() -> String {
        let interval = repositoryRoutine.lastUpdatedTime.timeIntervalSince(repositoryRoutine.startTime)
        
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

    class func getCompletionRate(_ repositoryRoutine: RepositoryRoutine) -> CompletionRate {
        if (numberOfExercises(repositoryRoutine) == 0) {
            return CompletionRate(percentage: 0, label: "0%")
        }

        let percentage = numberOfCompletedExercises(repositoryRoutine) * 100 / numberOfExercises(repositoryRoutine)

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

    class func numberOfCompletedExercises(_ repositoryRoutine: RepositoryRoutine) -> Int {
        return repositoryRoutine.exercises.filter({
            $0.visible && isCompleted($0)
        }).count
    }

    class func numberOfExercises(_ repositoryRoutine: RepositoryRoutine) -> Int {
        return repositoryRoutine.exercises.filter({
            $0.visible
        }).count
    }
    
    func completedExercises() -> Int {
        var completed = 0
        for exercise in repositoryRoutine.exercises {
            if exercise.visible {
                let firstSet = exercise.sets[0]
                
                if firstSet.isTimed {
                    if firstSet.seconds > 0 {
                        completed += 1
                    }
                } else {
                    if firstSet.reps > 0 {
                        completed += 1
                    }
                }
            }
        }
        
        return completed
    }
    
    func totalExercises() -> Int {
        return repositoryRoutine.exercises.filter({
            $0.visible == true
        }).count
    }
    
    func exercisesLeft() -> Int {
        return totalExercises() - completedExercises()
    }
    
    func isCompleted() -> Bool {
        return exercisesLeft() == 0
    }
    
    fileprivate func stringFromTimeInterval(_ interval: TimeInterval) -> (Int, Int) {
        let interval = Int(interval)
        
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        return (hours, minutes)
    }
}

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
