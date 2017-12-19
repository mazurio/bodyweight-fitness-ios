import Foundation
import RealmSwift

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

    func setSummaryLabel() -> String {
        let defaultLabel = "Not Completed"
        let totalNumberOfSets = self.repositoryExercise.sets.count
        let setLabel = (totalNumberOfSets > 1) ? "Sets" : "Set"

        if let firstSet = self.repositoryExercise.sets.first as RepositorySet? {
            if (firstSet.isTimed) {
                let totalTime = self.repositoryExercise.sets.map({ $0.seconds }).reduce(0, +)

                let (_, minutes, seconds) = secondsToHoursMinutesSeconds(totalTime)

                let minutesLabel = (minutes == 1) ? "Minute" : "Minutes"
                let secondsLabel = (seconds == 1) ? "Second" : "Seconds"

                if (totalTime == 0) {
                    return defaultLabel
                } else if (minutes == 0) {
                    return "\(totalNumberOfSets) \(setLabel), \(seconds) \(secondsLabel)"
                } else if (seconds == 0) {
                    return "\(totalNumberOfSets) \(setLabel), \(minutes) \(minutesLabel)"
                } else {
                    return "\(totalNumberOfSets) \(setLabel), \(minutes) \(minutesLabel), \(seconds) \(secondsLabel)"
                }
            } else {
                let totalNumberOfReps = self.repositoryExercise.sets.map({ $0.reps }).reduce(0, +)

                let repLabel = (totalNumberOfReps > 1) ? "Reps" : "Rep"

                if (totalNumberOfReps == 0) {
                    return defaultLabel
                } else {
                    return "\(totalNumberOfSets) \(setLabel), \(totalNumberOfReps) \(repLabel)"
                }
            }
        }

        return defaultLabel
    }
}
