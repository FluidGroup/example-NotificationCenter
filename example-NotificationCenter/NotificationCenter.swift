import IndexedCollection
import SwiftUI
import WithPrerender

@available(iOS 17.0, *)
struct BookNotificationCenter: View, PreviewProvider {
    
  @State private var notifications: Notifications = .init()
  
  private var controls: some View {
    ControlGroup {
      Button("Add single content") {
        notifications = notifications.addSingle()
      }
      Button("Add group content") {
        notifications = notifications.addGroup()
      }
      Button("Clear content") {
        notifications.nodes = []
      }
    }
  }
  
  var body: some View {
    VStack {
      controls
      ScrollableContainer(notifications: notifications)
    }
  }

  static var previews: some View {
    ZStack {
      Color.purple
        .ignoresSafeArea()
      Self()
    }
  }

  private struct ScrollableContainer: View {
    
    let notifications: Notifications

    var body: some View {
      ScrollView {
        VStack(spacing: 12) {
          BodyContentView(notifications: notifications)
        }
        .padding(.horizontal, 20)
      }
    }

  }

  private struct BodyContentView: View {

    let notifications: Notifications
    @Namespace var namespace

    var body: some View {

      Group {

        ForEach(notifications.nodes) { notification in
          switch notification {
          case let .single(notification):
            NotificationCell(title: notification.title, message: notification.message)
          case let .group(group):
            NotificationGroupCell(notificationGroup: group, namespace: namespace)
          }          
        }      
        .transition(.opacity.animation(.spring))
        .scrollTransition(
          topLeading: .identity,
          bottomTrailing: .interactive,
          transition: { content, phase in
            content
              .offset(y: phase.isIdentity ? 0 : -100)
              .scaleEffect(phase.isIdentity ? 1 : 0.75)
              .opacity(phase.isIdentity ? 1 : 0)
          }
        )

      }     
      .animation(.spring, value: notifications)

    }
  }

}

private struct NotificationCell: View {

  private let title: String
  private let message: String

  init(title: String, message: String) {
    self.title = title
    self.message = message
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(title)
          .font(.headline)
        Text(message)
          .font(.subheadline)
      }
      Spacer()
    }
    .padding()
    .background(Color(.secondarySystemBackground))   
    .cornerRadius(16)
    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
    .contextMenu(menuItems: { 
      Button("TODO") {
        
      }
    })
  
  }

}

private struct NotificationGroupCell: View {

  @State var isFolded: Bool = true

  private let notificationGroup: Notifications.Group
  private let namespace: Namespace.ID

  private let stackingID: String?
  @State var useStackingID: Bool = true

  init(
    notificationGroup: Notifications.Group,
    namespace: Namespace.ID
  ) {
    self.notificationGroup = notificationGroup
    self.namespace = namespace
    self.stackingID = notificationGroup.contents.dropFirst(2).first?.id
  }

  var body: some View {

    FolderGroup(
      isFolded: isFolded,
      header: {
        FolderCell(
          notificationGroup: notificationGroup,
          namespace: namespace
        )       
      },
      content: {        
        ForEach(IndexedCollection(notificationGroup.contents), id: \.id) { e in
          let notification = e.value

          NotificationCell(title: notification.title, message: notification.message)
            .matchedGeometryEffect(
              id: { () -> String? in
                // use same identifier to group cells for expanding animation
                if useStackingID, e.index >= 2 {
                  return stackingID
                }

                return e.id
              }(),
              in: namespace,
              isSource: {
                if e.index >= 3 {
                  return false
                } else {
                  return true
                }
              }()
            )
        }       
        Spacer(minLength: 44).fixedSize()
      },
      onOpen: {
        withAnimation(.spring) {
          isFolded = false
        }

        withPrerender {
          withAnimation(.spring()) {
            useStackingID = false
          }
        }

      },
      onClose: {
        withAnimation(.spring()) {
          useStackingID = true
        }

        withPrerender {
          withAnimation(.spring) {
            isFolded = true
          }
        }
      }
    )
    .sensoryFeedback(.selection, trigger: isFolded)

  }

  // MARK: - generic patterns
  private struct FolderCell: View {

    private let title: String
    private let message: String

    private let namespace: Namespace.ID

    private let firstID: String?
    private let secondID: String?
    private let thirdID: String?

    init(notificationGroup: Notifications.Group, namespace: Namespace.ID) {

      self.namespace = namespace

      var iterator = notificationGroup.contents.makeIterator()

      guard let first = iterator.next() else {
        fatalError("The group is empty.")
      }

      self.title = first.title
      self.message = first.message

      self.firstID = first.id

      if let second = iterator.next() {
        self.secondID = second.id
      } else {
        self.secondID = nil
      }

      if let third = iterator.next() {
        self.thirdID = third.id
      } else {
        self.thirdID = nil
      }

    }

    init(
      title: String,
      message: String,
      namespace: Namespace.ID,
      firstID: String?,
      secondID: String?,
      thirdID: String?,
      otherIDs: [String]
    ) {
      self.title = title
      self.message = message
      self.namespace = namespace

      self.firstID = firstID
      self.secondID = secondID
      self.thirdID = thirdID
    }

    var body: some View {

      let space: CGFloat = 12

      ZStack(alignment: .top) {

        if let thirdID = thirdID {
          RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground))
            .opacity(0.4)
            .offset(y: 24)
            .compositingGroup()
            .padding(.horizontal, 16)
            .matchedGeometryEffect(id: Optional(thirdID), in: namespace)
        }

        if let secondID = secondID {
          RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground))
            .opacity(0.6)
            .offset(y: 12)
            .compositingGroup()
            .matchedGeometryEffect(id: Optional(secondID), in: namespace, isSource: true)
            .padding(.horizontal, 8)
        }
        
        NotificationCell(title: title, message: message)
        .matchedGeometryEffect(id: firstID, in: namespace, isSource: true)       
      }
      .padding(
        .bottom,
        {
          if thirdID != nil {
            return space * 2
          }

          if secondID != nil {
            return space
          }

          return 0
        }())
    }
  }

  private struct FolderGroup<Header: View, Content: View>: View {

    private let header: Header
    private let content: () -> Content

    private let isFolded: Bool
    private let onOpen: () -> Void
    private let onClose: () -> Void

    init(
      isFolded: Bool,
      @ViewBuilder header: () -> Header,
      @ViewBuilder content: @escaping () -> Content,
      onOpen: @escaping () -> Void,
      onClose: @escaping () -> Void
    ) {
      self.isFolded = isFolded
      self.header = header()
      self.content = content
      self.onOpen = onOpen
      self.onClose = onClose
    }

    var body: some View {
      if isFolded {
        header
          ._onButtonGesture(
            pressing: { _ in },
            perform: {
              onOpen()
            }
          )
      } else {

        HStack {
          Button(
            action: {
              onClose()
            },
            label: {
              Text("Close")
            }
          )
        }

        content()
      }
    }

  }

}
