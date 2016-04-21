import Foundation
import XCTest

@testable import Bodyweight_Fitness

class TestRoutine {
    var id = "Routine-" + NSUUID().UUIDString
    var routineId = "routine0"
    var title = "Bodyweight Fitness"
    var subtitle = "Recommended Routine"
    var startTime = NSDate()
    var lastUpdatedTime = NSDate()
    
    var categories = [TestCategory]()
    var sections = [TestSection]()
    var exercises = [TestExercise]()
}

class TestCategory {
    var id = "Category-" + NSUUID().UUIDString
    var categoryId = ""
    var title = ""
    var routine: TestRoutine? = nil
    
    var sections = [TestSection]()
    var exercises = [TestExercise]()
}

class TestExercise {
    var id = "Exercise-" + NSUUID().UUIDString
    var exerciseId = ""
    var title = ""
    var desc = ""
    var defaultSet = ""
    var visible = true
    
    var routine: TestRoutine? = nil
    var category: TestCategory? = nil
    var section: TestSection? = nil
    
    var sets = [TestSet]()
}

class TestSection {
    var id = "Section-" + NSUUID().UUIDString
    var sectionId = ""
    var title = ""
    var mode = ""
    var routine: TestRoutine? = nil
    var category: TestCategory? = nil
    
    var exercises = [TestExercise]()
}

class TestSet {
    var id = "Set-" + NSUUID().UUIDString
    var isTimed = false
    var weight = 0.0
    var reps = 0
    var seconds = 0
    var exercise: TestExercise? = nil
}

class BodyweightFitnessTests: XCTestCase {
    var oldSchema = Routine()
    var newSchema = Routine()
    
    override func setUp() {
        super.setUp()

        oldSchema = Routine(fileName: "TestRoutine")
        newSchema = Routine(fileName: "Routine")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testIsValidSchemaShouldEqualTrue() {
        let testRoutine = buildRoutine(oldSchema)
        
        XCTAssertTrue(isValidSchema(oldSchema, currentSchema: testRoutine))
    }
    
    func testIsValidSchemaShouldEqualFalse() {
        let testRoutine = buildRoutine(oldSchema)
        
        XCTAssertFalse(isValidSchema(newSchema, currentSchema: testRoutine))
    }
    
    func testDifferentSchemaMigrationShouldSucceed() {
        let newRoutine = Routine(fileName: "Routine")
        let currentRoutine = Routine(fileName: "TestRoutine")
        
        let currentSchema = buildRoutine(currentRoutine)
        
        currentSchema.exercises[0].sets[0].reps = 5
        currentSchema.exercises[0].sets[0].seconds = 25
        currentSchema.exercises[1].sets[0].reps = 2
        currentSchema.exercises[2].sets[0].reps = 3
        currentSchema.exercises[3].sets[0].reps = 2
        currentSchema.exercises[3].sets[0].seconds = 12
        currentSchema.exercises[4].sets[0].reps = 10
        
        let migratedSchema = migrateDatabaseIfNeeded(newRoutine, currentSchema: currentSchema)
        
        let fakeSchema = buildRoutine(newRoutine)
        fakeSchema.startTime = currentSchema.startTime
        fakeSchema.lastUpdatedTime = currentSchema.lastUpdatedTime
        
        XCTAssert(migratedSchema.startTime == fakeSchema.startTime)
        XCTAssert(migratedSchema.lastUpdatedTime == fakeSchema.lastUpdatedTime)
        
        for (_, exercise) in migratedSchema.exercises.enumerate() {
            for (_, set) in exercise.sets.enumerate() {
                if let oldExercise = currentSchema.exercises.filter({
                    $0.exerciseId == exercise.exerciseId
                }).first {
                    XCTAssertEqual(set.reps, oldExercise.sets[0].reps)
                    XCTAssertEqual(set.seconds, oldExercise.sets[0].seconds)
                }
            }
        }
    }
    
    func migrateDatabaseIfNeeded(routine: Routine, currentSchema: TestRoutine) -> TestRoutine {
        if (!isValidSchema(routine, currentSchema: currentSchema)) {
            let newSchema = buildRoutine(routine)
            
            newSchema.startTime = currentSchema.startTime
            newSchema.lastUpdatedTime = currentSchema.lastUpdatedTime
            
            for exercise in newSchema.exercises {
                if let currentExercise = currentSchema.exercises.filter({
                    $0.exerciseId == exercise.exerciseId
                }).first {
                    exercise.sets = currentExercise.sets
                }
            }
            
            return newSchema
        }
        
        return currentSchema
    }
    
    func isValidSchema(routine: Routine, currentSchema: TestRoutine) -> Bool {
        for exercise in routine.exercises {
            if let exercise = exercise as? Exercise {
                let containsExercise = currentSchema.exercises.contains({
                    $0.exerciseId == exercise.exerciseId
                })
                
                if (!containsExercise) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func buildRoutine(routine: Routine) -> TestRoutine {
        let testRoutine = TestRoutine()
        testRoutine.routineId = "routine0"
        testRoutine.startTime = NSDate()
        testRoutine.lastUpdatedTime = NSDate()
        
        var testCategory: TestCategory?
        var testSection: TestSection?
        
        for exercise in routine.exercises {
            if let exercise = exercise as? Exercise {
                
                let testExercise = TestExercise()
                testExercise.exerciseId = exercise.exerciseId
                testExercise.title = exercise.title
                testExercise.desc = exercise.desc
                testExercise.defaultSet = exercise.defaultSet
                
                let testSet = TestSet()
                testSet.exercise = testExercise
                
                if(testExercise.defaultSet == "weighted") {
                    testSet.isTimed = false
                } else {
                    testSet.isTimed = true
                }
                
                testExercise.sets.append(testSet)
                
                if((testCategory == nil) || !(testCategory?.categoryId == exercise.category?.categoryId)) {
                    let category = exercise.category!
                    
                    testCategory = TestCategory()
                    testCategory?.categoryId = category.categoryId
                    testCategory?.title = category.title
                    testCategory?.routine = testRoutine
                    
                    testRoutine.categories.append(testCategory!)
                }
                
                if((testSection == nil) || !(testSection?.sectionId == exercise.section?.sectionId)) {
                    let section = exercise.section!
                    
                    testSection = TestSection()
                    testSection?.sectionId = section.sectionId
                    testSection?.title = section.title
                    
                    if (section.mode == SectionMode.All) {
                        testSection?.mode = "all"
                    } else if (section.mode == SectionMode.Pick) {
                        testSection?.mode = "pick"
                    } else {
                        testSection?.mode = "levels"
                    }
                    
                    testSection?.routine = testRoutine
                    testSection?.category = testCategory!
                    
                    testRoutine.sections.append(testSection!)
                    testCategory?.sections.append(testSection!)
                }
                
                testExercise.routine = testRoutine
                testExercise.category = testCategory!
                testExercise.section = testSection!
                
                if(exercise.section?.mode == SectionMode.All) {
                    testExercise.visible = true
                } else {
                    if let currentExercise = exercise.section?.currentExercise {
                        if exercise === currentExercise {
                            testExercise.visible = true
                        } else {
                            testExercise.visible = false
                        }
                    } else {
                        testExercise.visible = false
                    }
                }
                
                testRoutine.exercises.append(testExercise)
                testCategory?.exercises.append(testExercise)
                testSection?.exercises.append(testExercise)
            }
        }
        
        return testRoutine
    }
}
