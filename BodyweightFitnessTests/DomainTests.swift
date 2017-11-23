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
        }
    }
}
