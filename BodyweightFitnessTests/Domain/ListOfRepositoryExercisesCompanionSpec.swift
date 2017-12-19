import Quick
import Nimble
import RealmSwift

@testable import Bodyweight_Fitness

class ListOfRepositoryExercisesCompanionSpec: QuickSpec {
    override func spec() {
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

            context("allExercisesCompleted()") {
                it("should return false if number of visible exercises is bigger than number of completed exercises") {
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
                    expect(companion.allExercisesCompleted()).to(equal(false))
                }

                it("should return true if number of visible exercises is equal to number of completed exercises") {
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
                    thirdExercise.sets.append(completedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    expect(companion.allExercisesCompleted()).to(equal(true))
                }
            }

            context("getCompletionRate()") {
                it("should return 0% if number of exercises is 0") {
                    let repositoryExercises = List<RepositoryExercise>()
                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let completionRate = companion.completionRate()

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
                    let completionRate = companion.completionRate()

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
                    let completionRate = companion.completionRate()

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
                    let completionRate = companion.completionRate()

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
                    let completionRate = companion.completionRate()

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

                    let completionRate = companion.completionRate()

                    expect(completionRate.percentage).to(equal(66))
                    expect(completionRate.label).to(equal("66%"))
                }
            }

            context("notCompletedExercises()") {
                it("should return not completed and visible exercises") {
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

                    let fourthExercise = RepositoryExercise()
                    fourthExercise.visible = false
                    fourthExercise.sets.append(completedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)
                    repositoryExercises.append(fourthExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let notCompletedExercises = companion.notCompletedExercises()

                    expect(notCompletedExercises.count).to(equal(1))
                }
            }

            context("visibleOrCompletedExercises()") {
                it("should return visible or completed exercises") {
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

                    let fourthExercise = RepositoryExercise()
                    fourthExercise.visible = false
                    fourthExercise.sets.append(completedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)
                    repositoryExercises.append(fourthExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let visibleOrCompletedExercises = companion.visibleOrCompletedExercises()

                    expect(visibleOrCompletedExercises.count).to(equal(4))
                }

                it("should return visible exercises") {
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
                    secondExercise.sets.append(notCompletedSet)

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = true
                    thirdExercise.sets.append(notCompletedSet)

                    let fourthExercise = RepositoryExercise()
                    fourthExercise.visible = false
                    fourthExercise.sets.append(completedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)
                    repositoryExercises.append(fourthExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let visibleOrCompletedExercises = companion.visibleOrCompletedExercises()

                    expect(visibleOrCompletedExercises.count).to(equal(4))
                }

                it("should return completed exercises") {
                    let completedSet = RepositorySet()
                    completedSet.isTimed = true
                    completedSet.seconds = 30

                    let notCompletedSet = RepositorySet()
                    notCompletedSet.isTimed = true
                    notCompletedSet.seconds = 0

                    let firstExercise = RepositoryExercise()
                    firstExercise.visible = false
                    firstExercise.sets.append(completedSet)

                    let secondExercise = RepositoryExercise()
                    secondExercise.visible = false
                    secondExercise.sets.append(completedSet)

                    let thirdExercise = RepositoryExercise()
                    thirdExercise.visible = true
                    thirdExercise.sets.append(notCompletedSet)

                    let fourthExercise = RepositoryExercise()
                    fourthExercise.visible = false
                    fourthExercise.sets.append(completedSet)

                    let repositoryExercises = List<RepositoryExercise>()
                    repositoryExercises.append(firstExercise)
                    repositoryExercises.append(secondExercise)
                    repositoryExercises.append(thirdExercise)
                    repositoryExercises.append(fourthExercise)

                    let companion = ListOfRepositoryExercisesCompanion(repositoryExercises)
                    let visibleOrCompletedExercises = companion.visibleOrCompletedExercises()

                    expect(visibleOrCompletedExercises.count).to(equal(4))
                }
            }
        }
    }
}
