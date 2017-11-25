import Quick
import Nimble
import RealmSwift

@testable import Bodyweight_Fitness

class RepositoryExerciseCompanionSpec: QuickSpec {
    override func spec() {
        describe("RepositoryExerciseCompanion") {
            context("isCompleted()") {
                it("is not completed when number of sets is 0") {
                    let repositoryExercise = RepositoryExercise()
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }
                
                it("is not completed when first set is timed and time is set to 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 0
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }

                it("is not completed when multiple sets are timed and time is set to 0") {
                    let firstSet = RepositorySet()
                    firstSet.isTimed = true
                    firstSet.seconds = 0

                    let secondSet = RepositorySet()
                    secondSet.isTimed = true
                    secondSet.seconds = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(firstSet)
                    repositoryExercise.sets.append(secondSet)

                    let companion = RepositoryExerciseCompanion(repositoryExercise)

                    expect(companion.isCompleted()).to(equal(false))
                }

                it("is not completed when first set is weighted and repetitions are set to 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = false
                    repositorySet.reps = 0
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }

                it("is not completed when multiple sets are weighted and repetitions are set to 0") {
                    let firstSet = RepositorySet()
                    firstSet.isTimed = false
                    firstSet.reps = 0

                    let secondSet = RepositorySet()
                    secondSet.isTimed = false
                    secondSet.reps = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(firstSet)
                    repositoryExercise.sets.append(secondSet)

                    let companion = RepositoryExerciseCompanion(repositoryExercise)

                    expect(companion.isCompleted()).to(equal(false))
                }
                
                it("is completed when first set is timed and time is bigger than 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 10
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(true))
                }

                it("is completed when first set is weighted and repetitions are bigger than 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = false
                    repositorySet.reps = 1

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)

                    let companion = RepositoryExerciseCompanion(repositoryExercise)

                    expect(companion.isCompleted()).to(equal(true))
                }
            }

            context("setSummaryLabel()") {
                context("timed set") {
                    it("returns --") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 0

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("Not Completed"))
                    }

                    it("returns 1 Set, 1 Second") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 1

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 1 Second"))
                    }

                    it("returns 1 Set, 59 Seconds") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 59

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 59 Seconds"))
                    }

                    it("returns 1 Set, 1 Minute") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 60

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 1 Minute"))
                    }

                    it("returns 1 Set, 1 Minute, 1 Second") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 61

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 1 Minute, 1 Second"))
                    }

                    it("returns 1 Set, 1 Minute, 2 Seconds") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 62

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 1 Minute, 2 Seconds"))
                    }

                    it("returns 1 Set, 2 Minutes, 40 Seconds") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = true
                        firstSet.seconds = 160

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 2 Minutes, 40 Seconds"))
                    }
                }

                context("weighted set") {
                    it("returns --") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 0

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("Not Completed"))
                    }

                    it("returns 1 Set, 1 Rep") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 1

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("1 Set, 1 Rep"))
                    }

                    it("returns 2 Sets, 3 Reps") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 1

                        let secondSet = RepositorySet()
                        secondSet.isTimed = false
                        secondSet.reps = 2

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)
                        repositoryExercise.sets.append(secondSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("2 Sets, 3 Reps"))
                    }

                    it("returns 3 Sets, 5 Reps") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 1

                        let secondSet = RepositorySet()
                        secondSet.isTimed = false
                        secondSet.reps = 2

                        let thirdSet = RepositorySet()
                        thirdSet.isTimed = false
                        thirdSet.reps = 2

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)
                        repositoryExercise.sets.append(secondSet)
                        repositoryExercise.sets.append(thirdSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("3 Sets, 5 Reps"))
                    }

                    it("returns 3 Sets, 16 Reps") {
                        let firstSet = RepositorySet()
                        firstSet.isTimed = false
                        firstSet.reps = 3

                        let secondSet = RepositorySet()
                        secondSet.isTimed = false
                        secondSet.reps = 3

                        let thirdSet = RepositorySet()
                        thirdSet.isTimed = false
                        thirdSet.reps = 10

                        let repositoryExercise = RepositoryExercise()
                        repositoryExercise.sets.append(firstSet)
                        repositoryExercise.sets.append(secondSet)
                        repositoryExercise.sets.append(thirdSet)

                        let companion = RepositoryExerciseCompanion(repositoryExercise)

                        expect(companion.setSummaryLabel()).to(equal("3 Sets, 16 Reps"))
                    }
                }
            }
        }
    }
}
