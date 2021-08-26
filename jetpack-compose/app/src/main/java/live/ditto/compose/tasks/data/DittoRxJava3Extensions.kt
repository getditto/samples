package live.ditto.compose.tasks

import io.reactivex.rxjava3.core.Observable
import live.ditto.*;

/**
 * This allows you to turn a `DittoPendingCursorOperation` into a `DittoLiveQuery` observable
 *
 * Example:
 * ```kotlin
 * val docs: Observable<List<DittoDocument>> = ditto.store["cars"].findAll().asObservable()
 *
 * docs.observe { }
 *
 * ```
 *
 * @return Observable<List<DittoDocument>>
 */
fun DittoPendingCursorOperation.asObservable(): Observable<List<DittoDocument>> {
    return Observable.create<List<DittoDocument>> { sub ->
        val liveQuery = this.observe { docs, e ->
            sub.onNext(docs)
        }
        sub.setCancellable {
            liveQuery.stop()
        }
    }
}