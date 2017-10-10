import Foundation
import RxSwift

final class RoutineStream {
    static let sharedInstance = RoutineStream()
    
    var routine: Routine

    let routineSubject = PublishSubject<Routine>()
    let repositorySubject = PublishSubject<Bool>()

    private init() {
        routine = PersistenceManager.getRoutine("routine0")
        routineSubject.onNext(routine)
    }
    
    func setRoutine(_ id: String) {
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
