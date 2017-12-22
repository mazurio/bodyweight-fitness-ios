import Quick
import Nimble
import RealmSwift

@testable import Bodyweight_Fitness

class RepositoryRoutineCompanionSpec: QuickSpec {
    func mockDate(from: String) -> Date {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        return dateFormatter.date(from: from)!
    }

    var routineCompleted: RepositoryRoutine {
        let completedSet = RepositorySet()
        completedSet.isTimed = true
        completedSet.seconds = 10

        let firstExercise = RepositoryExercise()
        firstExercise.visible = true
        firstExercise.sets.append(completedSet)

        let secondExercise = RepositoryExercise()
        secondExercise.visible = true
        secondExercise.sets.append(completedSet)

        let thirdExercise = RepositoryExercise()
        thirdExercise.visible = true
        thirdExercise.sets.append(completedSet)

        let repositoryRoutine = RepositoryRoutine()
        repositoryRoutine.exercises.append(firstExercise)
        repositoryRoutine.exercises.append(secondExercise)
        repositoryRoutine.exercises.append(thirdExercise)

        repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:13:00Z")
        repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T15:13:21Z")

        repositoryRoutine.title = "Bodyweight Fitness"
        repositoryRoutine.subtitle = "Recommended Routine"

        return repositoryRoutine
    }

    override func spec() {
        describe("RepositoryRoutineCompanion") {
            context("date()") {
                it("should return start date in EEE, d MMMM YYYY format") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T00:00:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.date()).to(equal("Monday, 7 August 2017"))
                }
            }

            context("dateWithTime()") {
                it("should return start date and time in EEE, d MMMM YYYY - HH:mm format") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T15:13:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.dateWithTime()).to(equal("Monday, 7 August 2017 - 15:13"))
                }
            }

            context("startTime()") {
                it("should return start time in HH:mm format") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:13:21Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.startTime()).to(equal("13:13"))
                }
            }

            context("lastUpdatedTime()") {
                it("should return last updated time in HH:mm format") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T14:13:21Z")
                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.lastUpdatedTime()).to(equal("14:13"))
                }
            }

            context("lastUpdatedTimeLabel()") {
                it("should return 'End Time' if all exercises are completed") {
                    let companion = RepositoryRoutineCompanion(self.routineCompleted)
                    expect(companion.lastUpdatedTimeLabel()).to(equal("End Time"))
                }

                it("should return 'Last Updated Time' if not all exercises are completed") {
                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 10

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(completedSet)

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = true
                    thirdExercise.sets.append(notCompletedSet)

                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.exercises.append(firstExercise)
                    repositoryRoutine.exercises.append(secondExercise)
                    repositoryRoutine.exercises.append(thirdExercise)

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.lastUpdatedTimeLabel()).to(equal("Last Updated Time"))
                }
            }

            context("workoutLength()") {
                it("should return 50m") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T13:50:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLength()).to(equal("50m"))
                }

                it("should return 1h") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T14:00:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLength()).to(equal("1h"))
                }

                it("should return 1h 10m") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T14:10:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLength()).to(equal("1h 10m"))
                }

                it("should return 3h 35m") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T16:35:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLength()).to(equal("3h 35m"))
                }

                it("should return -- for workout length less than 10m") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T13:09:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLength()).to(equal("--"))
                }
            }

            context("workoutLengthInMinutes()") {
                it("should return 50") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T13:50:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLengthInMinutes()).to(equal(50))
                }

                it("should return 60") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T14:00:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLengthInMinutes()).to(equal(60))
                }

                it("should return 70") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T14:10:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLengthInMinutes()).to(equal(70))
                }

                it("should return 215") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T13:00:00Z")
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T16:35:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.workoutLengthInMinutes()).to(equal(215))
                }
            }

            context("email") {
                let unit = "kg"

                it("exercisesAsCSV should return empty string") {
                    let companion = RepositoryRoutineCompanion(RepositoryRoutine())
                    let csv = companion.csv(weightUnit: unit)
                    expect(csv).to(beNil())
                }

                it("exercisesAsCSV should return correct CSV") {
                    let companion = RepositoryRoutineCompanion(self.routineCompleted)
                    let csv = companion.csv(weightUnit: unit)

                    let expectedStr =
                    """
Date, Start Time, End Time, Workout Length, Routine, Exercise, Set Order, Weight, Weight Units, Reps, Minutes, Seconds
Monday, 7 August 2017,13:13,15:13,2h,Bodyweight Fitness - Recommended Routine,,1,0.000000,kg,0,0,10
Monday, 7 August 2017,13:13,15:13,2h,Bodyweight Fitness - Recommended Routine,,1,0.000000,kg,0,0,10
Monday, 7 August 2017,13:13,15:13,2h,Bodyweight Fitness - Recommended Routine,,1,0.000000,kg,0,0,10

"""
                    let expected = expectedStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    expect(csv).to(equal(expected))
                }

                it("csvName should return correct filename") {
                    let companion = RepositoryRoutineCompanion(self.routineCompleted)
                    let csvName = companion.csvName()

                    let expected = "Workout-Bodyweight Fitness-Monday, 7 August 2017 - 13:13.csv"
                    expect(csvName).to(equal(expected))
                }

                it("emailSubject should be correct") {
                    let companion = RepositoryRoutineCompanion(self.routineCompleted)
                    let subject = companion.emailSubject()

                    let expected = "Bodyweight Fitness workout for Monday, 7 August 2017 - 13:13"

                    expect(subject).to(equal(expected))
                }

                it("emailBody should return correct body text") {
                    let companion = RepositoryRoutineCompanion(self.routineCompleted)
                    let body = companion.emailBody(weightUnit: unit)

                    let expected =
                    """
Hello,
The following is your workout in Text/HTML format (CSV attached).

Workout on Monday, 7 August 2017 - 13:13.
Last Updated at 15:13
Workout length: 2h

Bodyweight Fitness
Recommended Routine


Set 1, Seconds: 10


Set 1, Seconds: 10


Set 1, Seconds: 10
"""

                    expect(body).to(equal(expected))
                }
            }
        }
    }
}
