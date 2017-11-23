import Quick
import Nimble

@testable import Bodyweight_Fitness

class DomainTests: QuickSpec {
    override func spec() {
        describe("Repository Routine Companion") {
            it("does stuff kurwa") {
                let repositoryRoutine = RepositoryRoutine()
                let companion = RepositoryRoutineCompanion(repositoryRoutine)
                
                expect(companion.repositoryRoutine).to(equal(repositoryRoutine))
            }
        }
        
        describe("Repository Category Companion") {
            it("initializes") {
                let repositoryCategory = RepositoryCategory()
                let companion = RepositoryCategoryCompanion(repositoryCategory)

                expect(companion.repositoryCategory).to(equal(repositoryCategory))
            }
        }

        describe("Repository Exercise Companion") {
            it("initializes") {
                let repositoryExercise = RepositoryExercise()
                let companion = RepositoryExerciseCompanion(repositoryExercise)

                expect(companion.repositoryExercise).to(equal(repositoryExercise))
            }
            
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
                
                it("is not completed when first set is weighted and repetitions are set to 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = false
                    repositorySet.reps = 0
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }
                
                it("is not completed when first set is timed and time is bigger than 0") {
                    let repositorySet = RepositorySet()
                    repositorySet.isTimed = true
                    repositorySet.seconds = 10
                    
                    let repositoryExercise = RepositoryExercise()
                    repositoryExercise.sets.append(repositorySet)
                    
                    let companion = RepositoryExerciseCompanion(repositoryExercise)
                    
                    expect(companion.isCompleted()).to(equal(false))
                }
            }
        }
    }
}
