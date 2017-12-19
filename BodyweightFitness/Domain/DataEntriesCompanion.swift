import Foundation

class DataEntriesCompanion {

    func getDataEntries(fromDate: Date,
                        numberOfDays: Int,
                        repositoryRoutines: [RepositoryRoutine],
                        workoutChartType: WorkoutChartType
    ) -> [WorkoutDataEntry] {
        var dataEntries: [WorkoutDataEntry] = []

        let baseLineDay: Date = (Calendar.current as NSCalendar).date(
                byAdding: .day,
                value: -numberOfDays,
                to: fromDate,
                options: []
        )!

        for index in 0...numberOfDays {
            let date = (Calendar.current as NSCalendar).date(
                    byAdding: .day,
                    value: index,
                    to: baseLineDay,
                    options: []
            )!

            let routinesForDay = repositoryRoutines.filter({
                return $0.startTime.commonDescription == date.commonDescription
            })

            if let repositoryRoutine = routinesForDay.first {
                dataEntries.append(
                        WorkoutDataEntry(
                                x: Double(index),
                                y: self.getValue(repositoryRoutine: repositoryRoutine, workoutChartType: workoutChartType),
                                title: self.getTitle(repositoryRoutine: repositoryRoutine),
                                label: self.getLabel(repositoryRoutine: repositoryRoutine, workoutChartType: workoutChartType)
                        )
                )
            } else {
                dataEntries.append(
                        WorkoutDataEntry(
                                x: Double(index),
                                y: 0,
                                title: date.description,
                                label: "No Data"
                        )
                )
            }
        }

        return dataEntries
    }

    private func getValue(repositoryRoutine: RepositoryRoutine, workoutChartType: WorkoutChartType) -> Double {
        switch workoutChartType {
        case .WorkoutLength:
            return RepositoryRoutineCompanion(repositoryRoutine).workoutLengthInMinutes()
        case .CompletionRate:
            return Double(ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises).completionRate().percentage)
        }
    }

    private func getTitle(repositoryRoutine: RepositoryRoutine) -> String {
        return RepositoryRoutineCompanion(repositoryRoutine).date()
    }

    private func getLabel(repositoryRoutine: RepositoryRoutine, workoutChartType: WorkoutChartType) -> String {
        switch workoutChartType {
        case .WorkoutLength:
            return RepositoryRoutineCompanion(repositoryRoutine).workoutLength()
        case .CompletionRate:
            return ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises).completionRate().label
        }
    }
}
