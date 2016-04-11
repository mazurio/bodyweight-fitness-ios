import Foundation
import RealmSwift

class RepositoryRoutineHelper {
    let repositoryRoutine: RepositoryRoutine
    
    init(repositoryRoutine: RepositoryRoutine) {
        self.repositoryRoutine = repositoryRoutine
    }
    
    func getDate() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, d MMMM YYYY"
        
        return formatter.stringFromDate(repositoryRoutine.startTime)
    }
    
    func getStartTime(longFormat: Bool = false) -> String {
        if longFormat {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEEE, d MMMM YYYY - HH:mm"
            
            return formatter.stringFromDate(repositoryRoutine.startTime)
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.stringFromDate(repositoryRoutine.startTime)
    }
    
    func getLastUpdatedTime() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.stringFromDate(repositoryRoutine.lastUpdatedTime)
    }
    
    func getWorkoutLength() -> String {
        let interval = repositoryRoutine.lastUpdatedTime.timeIntervalSinceDate(repositoryRoutine.startTime)
        
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
    
    private func stringFromTimeInterval(interval: NSTimeInterval) -> (Int, Int) {
        let interval = Int(interval)
        
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        return (hours, minutes)
    }
}

class RepositoryRoutine: Object {
    dynamic var id = "Routine-" + NSUUID().UUIDString
    dynamic var routineId = "routine0"
    dynamic var title = "Bodyweight Fitness"
    dynamic var subtitle = "Recommended Routine"
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