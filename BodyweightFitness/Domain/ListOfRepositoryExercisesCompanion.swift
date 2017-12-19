import Foundation
import RealmSwift

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

    func notCompletedExercises() -> [RepositoryExercise] {
        let filtered = Array(self.repositoryExercises).filter({
            $0.visible && !RepositoryExerciseCompanion($0).isCompleted()
        })

        return filtered
    }

    func visibleExercises() -> [RepositoryExercise] {
        let filtered = Array(self.repositoryExercises).filter({
            $0.visible
        })

        return filtered
    }

    func visibleOrCompletedExercises() -> [RepositoryExercise] {
        let filtered = Array(self.repositoryExercises).filter({
            $0.visible || RepositoryExerciseCompanion($0).isCompleted()
        })

        return filtered
    }
}
