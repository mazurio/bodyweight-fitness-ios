import Foundation
import XCTest

@testable import Bodyweight_Fitness

class RepositoryRoutineCompanionTests: XCTestCase {
    func testIsValidSchemaShouldEqualTrue() {
        let repositoryRoutine = RepositoryRoutine()
        let companion = RepositoryRoutineCompanion(repositoryRoutine)
        
        XCTAssertEqual(companion.repositoryRoutine, repositoryRoutine)
    }
}
