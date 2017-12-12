import Foundation
import RealmSwift

class RepositorySetCompanion {
    let repositorySet: RepositorySet

    init(_ repositorySet: RepositorySet) {
        self.repositorySet = repositorySet
    }

    func setSummaryLabel() -> String {
        let defaultLabel = "Not Completed"

        if (self.repositorySet.isTimed) {
            let (_, minutes, seconds) = secondsToHoursMinutesSeconds(self.repositorySet.seconds)

            let minutesLabel = (minutes == 1) ? "Minute" : "Minutes"
            let secondsLabel = (seconds == 1) ? "Second" : "Seconds"

            if (self.repositorySet.seconds == 0) {
                return defaultLabel
            } else if (minutes == 0) {
                return "\(seconds) \(secondsLabel)"
            } else if (seconds == 0) {
                return "\(minutes) \(minutesLabel)"
            } else {
                return "\(minutes) \(minutesLabel), \(seconds) \(secondsLabel)"
            }
        } else {
            let totalNumberOfReps = self.repositorySet.reps
            let repLabel = (totalNumberOfReps > 1) ? "Reps" : "Rep"

            if (totalNumberOfReps == 0) {
                return defaultLabel
            } else {
                return "\(totalNumberOfReps) \(repLabel)"
            }
        }
    }
}
