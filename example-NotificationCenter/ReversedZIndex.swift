import SwiftUI
import IndexedCollection

public struct ReversedZIndex<Content: View>: View {
  
  private let content: Content
  
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  public var body: some View {    
    Group(
      subviews: content,
      transform: { collection in
        ForEach(IndexedCollection.init(collection)) { e in
          e.value
            .zIndex(Double(collection.count - e.index))
        }
      }
    )
  }
}
