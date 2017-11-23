import Quick
import Nimble
import RealmSwift

@testable import Bodyweight_Fitness

class DomainTests: QuickSpec {
    override func spec() {
        describe("Repository Routine Companion") {
            it("initializes") {
                let repositoryRoutine = RepositoryRoutine()
                let companion = RepositoryRoutineCompanion(repositoryRoutine)
                
                expect(companion.repositoryRoutine).to(equal(repositoryRoutine))
            }
        }
        
        describe("ListOfRepositoryExercisesCompanion") {
            context("numberOfExercises()") {
                it("does not count invisible exercises") {
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = false

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(repositoryExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    expect(companion.numberOfExercises()).to(equal(0))
                }

                it("counts visible exercises") {
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = true

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(repositoryExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    expect(companion.numberOfExercises()).to(equal(1))
                }

                it("counts multiple visible exercises") {
                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = false

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    expect(companion.numberOfExercises()).to(equal(2))
                }
            }

            context("numberOfCompletedExercises()") {
                it("does not count invisible exercises") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = false
                    repositoryExercise.sets.append(repositorySet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(repositoryExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    expect(companion.numberOfCompletedExercises()).to(equal(0))
                }

                it("does not count incomplete exercises") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 0

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = true
                    repositoryExercise.sets.append(repositorySet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(repositoryExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    expect(companion.numberOfCompletedExercises()).to(equal(0))
                }

                it("counts visible and completed exercises") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 10

                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.visible = true
                    repositoryExercise.sets.append(repositorySet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(repositoryExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    expect(companion.numberOfCompletedExercises()).to(equal(1))
                }

                it("counts multiple visible and completed exercises") {
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

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    expect(companion.numberOfCompletedExercises()).to(equal(2))
                }
            }

            context("getCompletionRate()") {
                it("should return 0% if number of exercises is 0") {
                    let repositoryExercises = List<RepositoryExercise>()
                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(0))
                    expect(completionRate.label).to(equal("0%"))
                }

                it("should return 0% if number of completed exercises is 0") {
                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(notCompletedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(0))
                    expect(completionRate.label).to(equal("0%"))
                }

                it("should return 50% if number of completed exercises is 1 out of 2") {
                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(notCompletedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(completedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(50))
                    expect(completionRate.label).to(equal("50%"))
                }

                it("should return 100% if number of completed exercises is 2 out of 2") {
                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(completedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(100))
                    expect(completionRate.label).to(equal("100%"))
                }

                it("should return 33% if number of completed exercises is 1 out of 3") {
                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = true
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = true
                    secondExercise.sets.append(notCompletedSet)

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = true
                    thirdExercise.sets.append(notCompletedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(33))
                    expect(completionRate.label).to(equal("33%"))
                }

                it("should return 66% if number of completed exercises is 2 out of 3") {
                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

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

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)

                    let completionRate = companion.getCompletionRate()

                    expect(completionRate.percentage).to(equal(66))
                    expect(completionRate.label).to(equal("66%"))
                }
            }
        }

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
        }
    }
}
