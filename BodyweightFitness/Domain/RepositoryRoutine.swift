import Foundation
import RealmSwift

class RepositoryRoutineCompanion {
    let repositoryRoutine: RepositoryRoutine
    
    init(_ repositoryRoutine: RepositoryRoutine) {
        self.repositoryRoutine = repositoryRoutine
    }

    func date() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM YYYY"

        return formatter.string(from: self.repositoryRoutine.startTime)
    }

    func dateWithTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM YYYY - HH:mm"

        return formatter.string(from: self.repositoryRoutine.startTime)
    }

    func startTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return formatter.string(from: self.repositoryRoutine.startTime)
    }

    func lastUpdatedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return formatter.string(from: self.repositoryRoutine.lastUpdatedTime)
    }

    func lastUpdatedTimeLabel() -> String {
        let companion = ListOfRepositoryExercisesCompanion(self.repositoryRoutine.exercises)

        if (companion.allExercisesCompleted()) {
            return "End Time"
        } else {
            return "Last Updated Time"
        }
    }

    func workoutLength() -> String {
        let interval = self.repositoryRoutine.lastUpdatedTime.timeIntervalSince(repositoryRoutine.startTime)

        let (hours, minutes) = self.stringFromTimeInterval(interval)

        if (hours > 0 || minutes > 10) {
            if (hours > 0 && minutes == 0) {
                return "\(hours)h"
            } else if (hours > 0) {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        } else {
            return "--"
        }
    }

    fileprivate func stringFromTimeInterval(_ interval: TimeInterval) -> (Int, Int) {
        let interval = Int(interval)

        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)

        return (hours, minutes)
    }
}

class ListOfRepositoryExercisesCompanion {
    let repositoryExercises: List<RepositoryExercise>
    
    init(_ repositoryExercises: List<RepositoryExercise>) {
        self.repositoryExercises = repositoryExercises
    }

    func numberOfExercises() -> Int {
        let filtered = self.repositoryExercises.filter({
            $0.visible
        })
        
        return filtered.count
    }

    func numberOfCompletedExercises() -> Int {
        let filtered = self.repositoryExercises.filter({
            $0.visible && RepositoryExerciseCompanion($0).isCompleted()
        })
        
        return filtered.count
    }

    func allExercisesCompleted() -> Bool {
        return numberOfCompletedExercises() == numberOfExercises()
    }

    func completionRate() -> CompletionRate {
        let numberOfExercises = self.numberOfExercises()
        let numberOfCompletedExercises = self.numberOfCompletedExercises()

        if (numberOfExercises == 0 || numberOfCompletedExercises == 0) {
            return CompletionRate(percentage: 0, label: "0%")
        }

        let value = numberOfCompletedExercises * 100 / numberOfExercises

        return CompletionRate(percentage: value, label: "\(value)%")
    }
}

class RepositoryExerciseCompanion {
    let repositoryExercise: RepositoryExercise
    
    init(_ repositoryExercise: RepositoryExercise) {
        self.repositoryExercise = repositoryExercise
    }
    
    func isCompleted() -> Bool {
        if let firstSet = self.repositoryExercise.sets.first as RepositorySet? {
            if (firstSet.isTimed) {
                let totalTime = self.repositoryExercise.sets.map({ $0.seconds }).reduce(0, +)

                return (totalTime > 0)
            } else {
                let totalNumberOfReps = self.repositoryExercise.sets.map({ $0.reps }).reduce(0, +)

                return (totalNumberOfReps > 0)
            }
        }

        return false
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
