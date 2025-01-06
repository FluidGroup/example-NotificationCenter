import SwiftUI

struct ExampleMatchedGeometry: View, PreviewProvider {
  var body: some View {
    ContentView()
  }
  
  static var previews: some View {
    Self()
      .previewDisplayName(nil)
  }
  
  private struct ContentView: View {
    
    @State var flag = false
    @Namespace var namespace
    
    var body: some View {
      VStack {
        Button("Toggle") {
          withAnimation {
            flag.toggle()
          }
        }
        if flag {
          ZStack {
            Color.blue
            VStack {
              Text("Hello")              
            }
          }
          .matchedGeometryEffect(id: "text", in: namespace)
          .padding()

        } else {
          Color.blue
            .matchedGeometryEffect(id: "text", in: namespace)
            .frame(width: 100, height: 100)
            
        }        
      }
    }
  }
}
