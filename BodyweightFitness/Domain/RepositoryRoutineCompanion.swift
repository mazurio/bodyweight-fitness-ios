import Foundation
import RealmSwift

class RepositoryRoutineCompanion {
    let repositoryRoutine: RepositoryRoutine

    init(_ repositoryRoutine: RepositoryRoutine) {
        self.repositoryRoutine = repositoryRoutine
    }

    func date() -> String {
        return self.repositoryRoutine.startTime.description
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

    func workoutLengthInMinutes() -> Double {
        let interval = self.repositoryRoutine.lastUpdatedTime.timeIntervalSince(repositoryRoutine.startTime)

        return Double(Int(interval) / 60)
    }

    fileprivate func stringFromTimeInterval(_ interval: TimeInterval) -> (Int, Int) {
        let interval = Int(interval)

        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)

        return (hours, minutes)
    }
}
