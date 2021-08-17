import Foundation
import SwiftUIRedux

struct AppState: ReduxState, Equatable {

  var authState = AuthState(signedInUser: nil)

  var contactsState = ContactsState(
    categories: ContactCategory.allCases,
    contacts: .notRequested,
    officialAccounts: .notRequested
  )

  var discoverState = DiscoverState(discoverSections: DiscoverSection.allCases)

  var rootState = RootState(selectedTab: .chats)

  var systemState = SystemState(errorMessage: nil)

  init() {
    guard let data = AppEnvironment.current.userDefaults.data(forKey: Self.appStateStorageKey),
          let dataObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
          }

    for key in ArchiveKeys.allCases {
      let json = dataObj[key.rawValue] as? [String: Any] ?? [:]
      switch key {
      case .authState:
        if let state: AuthState = tryDecode(json) {
          authState = state
        }
      }
    }
  }

  // MARK: - Archive

  func archive() {
    var dataObj: [String: Any] = [:]

    for key in ArchiveKeys.allCases {
      switch key {
      case .authState:
        dataObj[key.rawValue] = authState.dictionaryRepresentation
      }
    }

    AppEnvironment.current.userDefaults.set(dataObj.data, forKey: Self.appStateStorageKey)
    _ = AppEnvironment.current.userDefaults.synchronize()
  }

  func archivePropertiesEqualTo(_ another: AppState) -> Bool {
    var isEqual = true

    // swiftlint:disable force_cast
    for key in ArchiveKeys.allCases {
      switch key {
      case .authState:
        isEqual = (self[key] as! AuthState) == (another[key] as! AuthState)
      }
      if isEqual == false {
        break
      }
    }

    return isEqual
  }

  subscript(key: ArchiveKeys) -> Any {
    switch key {
    case .authState:
      return authState
    }
  }

#if DEBUG
  init(
    authState: AuthState,
    contactsState: ContactsState,
    discoverState: DiscoverState,
    rootState: RootState,
    systemState: SystemState
  ) {
    self.authState = authState
    self.contactsState = contactsState
    self.discoverState = discoverState
    self.rootState = rootState
    self.systemState = systemState
  }
#endif
}

extension AppState {
  static let appStateStorageKey = "com.WeChat-SwiftUI.AppState"

  enum ArchiveKeys: String, CaseIterable {
    case authState
  }
}

#if DEBUG
extension AppState {
  static var preview: AppState {
    AppState(
      authState: .preview,
      contactsState: .preview,
      discoverState: .preview,
      rootState: .preview,
      systemState: .preview
    )
  }
}
#endif
