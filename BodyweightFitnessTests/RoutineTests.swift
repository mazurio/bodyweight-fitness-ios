import XCTest

class RoutineTests: XCTestCase {
    var routine: Routine = Routine()
    
    func testLoadRoutineFromJSONFile() {
        XCTAssertEqual(routine.loadRoutineFromFile().length, 7548)
    }
    
    func testLinkedRoutineLoaded() {
        XCTAssertEqual(routine.linkedRoutine.count, 65)
    }
    
    func testCategoriesLoaded() {
        XCTAssertEqual(routine.categories.count, 3)
    }
    
    func testSectionsLoaded() {
        XCTAssertEqual(routine.sections.count, 11)
    }
    
    func testExercisesLoaded() {
        XCTAssertEqual(routine.exercises.count, 51)
    }

    func testFirstExercise() {
        XCTAssertEqual(routine.getFirstExercise().title, "Wall Extensions")
    }

    func testExercisesAreLinkedTogether() {
        var exercise: Exercise = routine.getFirstExercise()
        
        XCTAssertOptionIsNil(exercise.previous)
        
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Band Dislocates")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Cat/Camel Bends")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Scapular Shrugs")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Full Body Circles")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Front and Side Leg Swings")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Wrist Mobility Exercises")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Plank")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Side Plank (Do both sides)")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Reverse Plank")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Hollow Hold")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Arch")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Squat Jumps")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Wall Plank")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Parallel Bar support")
        
        exercise = exercise.next!
        
        XCTAssertOptionIsSet(exercise.previous)
        XCTAssertOptionIsSet(exercise.next)
        XCTAssertEqual(exercise.next!.title, "Negative Pullups")
    }
    
    func testExercisesAreLoadedWithAllValues() {
        let exercise: Exercise = routine.getFirstExercise()
        
        XCTAssertEqual(exercise.id, "wall_extensions")
        XCTAssertEqual(exercise.title, "Wall Extensions")
        XCTAssertEqual(exercise.desc, "5-10 reps")
        XCTAssertEqual(exercise.type, RoutineType.Exercise)
        
        XCTAssertOptionIsSet(exercise.category)
        XCTAssertOptionIsSet(exercise.section)
        
        XCTAssertEqual(exercise.category!.title, "Warmup")
        XCTAssertEqual(exercise.section!.title, "Dynamic Stretches")
    }
    
    func testModeFromString() {
        XCTAssertEqual(routine.getMode("pick"), SectionMode.Pick)
        XCTAssertEqual(routine.getMode("levels"), SectionMode.Levels)
        XCTAssertEqual(routine.getMode("all"), SectionMode.All)
        XCTAssertEqual(routine.getMode("*&@£$&*"), SectionMode.All)
    }
    
    func XCTAssertOptionIsNil(op: AnyObject?) {
        if let _ = op {
            XCTFail()
        } else {
            XCTAssertTrue(true)
        }
    }
    
    func XCTAssertOptionIsSet(op: AnyObject?) {
        if let _ = op {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
}
