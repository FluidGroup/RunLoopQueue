
@MainActor
public func withBeforeCATransaction(_ block: @escaping @MainActor () -> Void) {
  CATransactionQueue.shared.enqueue(work: block)
}
