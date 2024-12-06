import Foundation
import CoreFoundation

// from Texture(AsyncDisplayKit)
// https://github.com/TextureGroup/Texture/blob/master/Source/ASRunLoopQueue.mm
@MainActor
public final class CATransactionQueue {
  
  public static let shared = CATransactionQueue()
  
  private var subscription: RunLoopActivityObserver.Subscription!
  
  private var source: CFRunLoopSource?
  
  private var queue: [() -> Void] = []
  private var batchQueue: [() -> Void] = []
  
  private init() {
    
    // CoreAnimation commit order is 2000000, the goal of this is to process shortly beforehand
    // but after most other scheduled work on the runloop has processed.
    subscription = RunLoopActivityObserver.addObserver(
      acitivity: .beforeWaiting,
      order: 1_000_000
    ) { [weak self] in
      self?.processQueue()
    }
    
    // It is not guaranteed that the runloop will turn if it has no scheduled work, and this causes processing of
    // the queue to stop. Attaching a custom loop source to the run loop and signal it if new work needs to be done
    do {
      var context = CFRunLoopSourceContext.init()
      context.perform = { _ in
        // NO OP
      }
      
      self.source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context)
      
      CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
    }
    
  }
  
  private func processQueue() {
    
    guard !queue.isEmpty else {
      return
    }
    
    swap(&queue, &batchQueue)
    
    for work in batchQueue {
      work()
    }
    
    batchQueue.removeAll()
    
  }
  
  public func enqueue(work: @escaping @MainActor () -> Void) {
    
    queue.append(work)
    
    if queue.count == 1 {
      CFRunLoopSourceSignal(self.source)
      CFRunLoopWakeUp(CFRunLoopGetMain())
    }
  }
  
  deinit {
    // nop because of singleton
  }
  
}

private enum RunLoopActivityObserver {
  
  struct Subscription {
    let observer: CFRunLoopObserver?
  }
  
  static func addObserver(
    acitivity: CFRunLoopActivity,
    order: Int,
    callback: @escaping () -> Void
  ) -> Subscription {
    
    let o = CFRunLoopObserverCreateWithHandler(
      kCFAllocatorDefault, acitivity.rawValue, true, order,
      { observer, activity in
        callback()
      })
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), o, CFRunLoopMode.commonModes)
    
    return .init(observer: o)
  }
  
  static func remove(_ subscription: Subscription) {
    subscription.observer.map {
      CFRunLoopRemoveObserver(CFRunLoopGetMain(), $0, CFRunLoopMode.commonModes)
    }
  }
  
}
