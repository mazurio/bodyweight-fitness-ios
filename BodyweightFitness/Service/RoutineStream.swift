import Foundation
import RxSwift

class RoutineStream {
    class var sharedInstance: RoutineStream {
        struct Static {
            static var instance: RoutineStream?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RoutineStream()
        }
        
        return Static.instance!
    }
    
    var routine: Routine

    let routineSubject = PublishSubject<Routine>()
    let repositorySubject = PublishSubject<Bool>()

    init() {
        routine = PersistenceManager.getRoutine("routine0")
        routineSubject.onNext(routine)
    }
    
    func setRoutine(id: String) {
        routine = PersistenceManager.getRoutine(id)
        routineSubject.onNext(routine)
    }

    func setRepository() {
        repositorySubject.onNext(true)
    }
    
    func routineObservable() -> Observable<Routine> {
        return Observable.of(Observable.just(routine).publish().refCount(), routineSubject)
            .merge()
            .publish()
            .refCount()
    }

    func repositoryObservable() -> Observable<Bool> {
        return repositorySubject
            .publish()
            .refCount()
    }
}