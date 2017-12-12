import Quick
import Nimble
import RealmSwift

@testable import Bodyweight_Fitness

class RepositorySetCompanionSpec: QuickSpec {
    override func spec() {
        describe("RepositorySetCompanion") {
            context("setSummaryLabel()") {
                context("timed set") {
                    it("returns Not Completed") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 0

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("Not Completed"))
                    }

                    it("returns 1 Second") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 1

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("1 Second"))
                    }

                    it("returns 59 Seconds") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 59

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("59 Seconds"))
                    }

                    it("returns 1 Minute") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 60

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 1 Minute"))
                    }

                    it("returns 1 Minute, 1 Second") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 61

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("1 Minute, 1 Second"))
                    }

                    it("returns 1 Minute, 2 Seconds") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 62

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("1 Minute, 2 Seconds"))
                    }

                    it("returns 2 Minutes, 40 Seconds") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 160

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("2 Minutes, 40 Seconds"))
                    }
                }

                context("weighted set") {
                    it("returns Not Completed") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 0

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("Not Completed"))
                    }

                    it("returns 1 Rep") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 1

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("1 Rep"))
                    }

                    it("returns 3 Reps") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 3

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("3 Reps"))
                    }

                    it("returns 5 Reps") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 5

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("5 Reps"))
                    }

                    it("returns 3 Sets, 16 Reps") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 16

                        let companion = RepositorySetCompanion(firstSet)

                        expect(companion.setSummaryLabel()).to(equal("16 Reps"))
                    }
                }
            }
        }
    }
}
