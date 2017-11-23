import Quick
import Nimble
import RealmSwift

@testable import Bodyweight_Fitness

class RepositoryRoutineCompanionSpec: QuickSpec {
    func mockDate(from: String) -> Date {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")

        return dateFormatter.date(from: from)!
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
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T12:13:00Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.dateWithTime()).to(equal("Monday, 7 August 2017 - 13:13"))
                }
            }

            context("startTime()") {
                it("should return start time in HH:mm format") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.startTime = self.mockDate(from: "2017-08-07T12:13:21Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.startTime()).to(equal("13:13"))
                }
            }

            context("lastUpdatedTime()") {
                it("should return last updated time in HH:mm format") {
                    let repositoryRoutine = RepositoryRoutine()
                    repositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-08-07T13:13:21Z")

                    let companion = RepositoryRoutineCompanion(repositoryRoutine)

                    expect(companion.lastUpdatedTime()).to(equal("14:13"))
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
        }
    }
}
