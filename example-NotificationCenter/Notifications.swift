struct Notifications: Equatable {

  enum Node: Equatable, Identifiable {

    enum Identifier: Hashable {
      case single(Content.ID)
      case group(Group.ID)
    }

    var id: Identifier {
      switch self {
      case let .single(notification):
        return .single(notification.id)
      case let .group(group):
        return .group(group.id)
      }
    }

    case single(Content)
    case group(Group)
  }

  struct Content: Equatable, Identifiable {
    var id: String
    var title: String
    var message: String
  }

  struct Group: Equatable, Identifiable {
    var id: String
    let contents: [Content]
  }

  var nodes: [Node]

  init() {
    self.nodes = []
  }

}

#if DEBUG

  import Foundation.NSUUID

  extension Notifications {

    consuming func addSingle() -> Self {
      self.nodes.append(
        .single(
          .init(
            id: UUID().uuidString,
            title: "New Message",
            message: "You have received a new message from Haru."
          ))
      )
      return self
    }

    consuming func addGroup() -> Self {
      nodes.append(
        .group(
          .init(
            id: UUID().uuidString,
            contents: [
              .init(
                id: UUID().uuidString,
                title: "Promotion",
                message: "Get 20% off on your next purchase."
              ),
              .init(
                id: UUID().uuidString,
                title: "News Alert",
                message: "Breaking news: Major updates in the tech world!"
              ),
              .init(
                id: UUID().uuidString,
                title: "Event Invitation",
                message: "You are invited to the annual company gala."
              ),
              .init(
                id: UUID().uuidString,
                title: "Promotion",
                message: "Get 20% off on your next purchase."
              ),
              .init(
                id: UUID().uuidString,
                title: "News Alert",
                message: "Breaking news: Major updates in the tech world!"
              ),
              .init(
                id: UUID().uuidString,
                title: "Event Invitation",
                message: "You are invited to the annual company gala."
              ),
            ]
          )
        )
      )

      return self
    }

    consuming func loadDemo() -> Self {

      self.nodes = [
        .single(
          .init(
            id: UUID().uuidString,
            title: "New Message",
            message: "You have received a new message from Haru."
          )),
        .single(
          .init(
            id: UUID().uuidString,
            title: "System Update",
            message: "Your iPhone has a new software update available."
          )),
        .group(
          .init(
            id: UUID().uuidString,
            contents: [
              .init(
                id: UUID().uuidString,
                title: "Friend Request",
                message: "Alex sent you a friend request."
              ),
              .init(
                id: UUID().uuidString,
                title: "Meeting Reminder",
                message: "Don't forget your meeting with the design team at 3 PM."
              ),
            ]
          )),
        .group(
          .init(
            id: UUID().uuidString,
            contents: [
              .init(
                id: UUID().uuidString,
                title: "Promotion",
                message: "Get 20% off on your next purchase."
              ),
              .init(
                id: UUID().uuidString,
                title: "News Alert",
                message: "Breaking news: Major updates in the tech world!"
              ),
              .init(
                id: UUID().uuidString,
                title: "Event Invitation",
                message: "You are invited to the annual company gala."
              ),
            ]
          )
        ),
        .group(
          .init(
            id: UUID().uuidString,
            contents: [
              .init(
                id: UUID().uuidString,
                title: "Promotion",
                message: "Get 20% off on your next purchase."
              ),
              .init(
                id: UUID().uuidString,
                title: "News Alert",
                message: "Breaking news: Major updates in the tech world!"
              ),
              .init(
                id: UUID().uuidString,
                title: "Event Invitation",
                message: "You are invited to the annual company gala."
              ),
              .init(
                id: UUID().uuidString,
                title: "Promotion",
                message: "Get 20% off on your next purchase."
              ),
              .init(
                id: UUID().uuidString,
                title: "News Alert",
                message: "Breaking news: Major updates in the tech world!"
              ),
              .init(
                id: UUID().uuidString,
                title: "Event Invitation",
                message: "You are invited to the annual company gala."
              ),
            ]
          )
        ),
      ]

      return self
    }
  }
#endif
