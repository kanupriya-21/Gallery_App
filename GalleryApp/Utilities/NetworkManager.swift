//
//  NetworkManager.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 06/09/25.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = NetworkManager()
    
    // MARK: - Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    // MARK: - Initialization
    private init() {
        startMonitoring()
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? false
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                
                if path.status == .satisfied {
                    print("Network connected via: \(path.availableInterfaces.first?.type.description ?? "Unknown")")
                } else {
                    print("Network disconnected")
                }
                
                // Post notification if connection status changed
                if wasConnected != (path.status == .satisfied) {
                    NotificationCenter.default.post(name: .init("NetworkStatusChanged"), object: nil)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        stopMonitoring()
    }
}

// MARK: - NWInterface.InterfaceType Extension
extension NWInterface.InterfaceType {
    var description: String {
        switch self {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Ethernet"
        case .loopback:
            return "Loopback"
        case .other:
            return "Other"
        @unknown default:
            return "Unknown"
        }
    }
}
