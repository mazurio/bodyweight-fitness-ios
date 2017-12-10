import Quick
import Nimble
import RealmSwift

@testable import Bodyweight_Fitness

class DataEntriesCompanionSpec: QuickSpec {
    func mockDate(from: String) -> Date {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")

        return dateFormatter.date(from: from)!
    }

    override func spec() {
        describe("DataEntriesCompanion") {
            context("getDataEntries()") {
                it("returns data entries for last 7 days") {
                    let fromDate = self.mockDate(from: "2017-12-10T13:00:00Z")

                    let dataEntriesCompanion = DataEntriesCompanion()
                    let dataEntries = dataEntriesCompanion.getDataEntries(
                            fromDate: fromDate,
                            numberOfDays: 7,
                            repositoryRoutines: [],
                            workoutChartType: .WorkoutLength
                    )

                    expect(dataEntries.count).to(equal(8))

                    expect(dataEntries[0].x).to(equal(0))
                    expect(dataEntries[0].y).to(equal(0))

                    expect(dataEntries[1].x).to(equal(1))
                    expect(dataEntries[1].y).to(equal(0))

                    expect(dataEntries[6].x).to(equal(6))
                    expect(dataEntries[6].y).to(equal(0))
                }

                it("returns data entries for last 30 days") {
                    let fromDate = self.mockDate(from: "2017-12-10T13:00:00Z")

                    let dataEntriesCompanion = DataEntriesCompanion()
                    let dataEntries = dataEntriesCompanion.getDataEntries(
                            fromDate: fromDate,
                            numberOfDays: 30,
                            repositoryRoutines: [],
                            workoutChartType: .WorkoutLength
                    )

                    expect(dataEntries.count).to(equal(31))

                    expect(dataEntries[0].x).to(equal(0))
                    expect(dataEntries[0].y).to(equal(0))

                    expect(dataEntries[1].x).to(equal(1))
                    expect(dataEntries[1].y).to(equal(0))

                    expect(dataEntries[29].x).to(equal(29))
                    expect(dataEntries[29].y).to(equal(0))
                }

                it("returns data entries for last 7 days with logged workouts") {
                    let fromDate = self.mockDate(from: "2017-12-10T13:00:00Z")

                    let firstRepositoryRoutine = RepositoryRoutine()
                    firstRepositoryRoutine.startTime = self.mockDate(from: "2017-12-09T12:00:00")
                    firstRepositoryRoutine.lastUpdatedTime = self.mockDate(from: "2017-12-09T12:50:00")

                    let dataEntriesCompanion = DataEntriesCompanion()
                    let dataEntries = dataEntriesCompanion.getDataEntries(
                            fromDate: fromDate,
                            numberOfDays: 7,
                            repositoryRoutines: [
                                firstRepositoryRoutine
                            ],
                            workoutChartType: .WorkoutLength
                    )

                    expect(dataEntries.count).to(equal(8))

                    expect(dataEntries[0].x).to(equal(0))
                    expect(dataEntries[0].y).to(equal(0))

                    expect(dataEntries[5].x).to(equal(5))
                    expect(dataEntries[5].y).to(equal(0))

                    expect(dataEntries[6].x).to(equal(6))
                    expect(dataEntries[6].y).to(equal(50))

                    expect(dataEntries[7].x).to(equal(7))
                    expect(dataEntries[7].y).to(equal(0))
                }
            }
        }
    }
}
