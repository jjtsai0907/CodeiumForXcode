import Client
import ComposableArchitecture
import Foundation

#if canImport(LicenseManagement)
import LicenseManagement
#endif

struct HostApp: ReducerProtocol {
    struct State: Equatable {
        var general = General.State()
    }

    enum Action: Equatable {
        case appear
        case informExtensionServiceAboutLicenseKeyChange
        case general(General.Action)
    }

    @Dependency(\.toast) var toast

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.general, action: /Action.general) {
            General()
        }

        Reduce { _, action in
            switch action {
            case .appear:
                return .none
            case .informExtensionServiceAboutLicenseKeyChange:
                return .run { _ in
                    #if canImport(LicenseManagement)
                    let service = try getService()
                    do {
                        try await service
                            .postNotification(name: Notification.Name.licenseKeyChanged.rawValue)
                    } catch {
                        toast(error.localizedDescription, .error)
                    }
                    #endif
                }
            case .general:
                return .none
            }
        }
    }
}

