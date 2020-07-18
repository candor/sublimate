import class Dispatch.DispatchQueue
import NIO

public extension DispatchQueue {
    func async<Value>(on eventLoop: EventLoop, use closure: @escaping () throws -> Value) -> EventLoopFuture<Value> {
        let promise = eventLoop.makePromise(of: Value.self)
        async {
            do {
                promise.succeed(try closure())
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
}

extension Collection {
    /// Waits on a `Collection` of `EventLoopFuture` returning `Array<EventLoopFuture.Value>`
    /// - Note: the order of the results will match the order of the EventLoopFutures in the input `Collection`.
    /// - Note: They must be the same type, a strategy for waiting on mixed futures is to `Void` them all and then work with the original futures
    public func flatten<Value>(on db: CO₂DB) throws -> [Value] where Element == EventLoopFuture<Value> {
        return try EventLoopFuture.whenAllSucceed(Array(self), on: db.eventLoop).wait()
    }
}

extension Collection where Element == EventLoopFuture<Void> {
    /// Waits on a `Collection` of `EventLoopFuture<Void>`
    public func flatten(on db: CO₂DB) throws {
        _ = try EventLoopFuture.whenAllSucceed(Array(self), on: db.eventLoop).wait()
    }
}
