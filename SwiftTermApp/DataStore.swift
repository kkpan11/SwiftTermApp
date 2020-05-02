//
//  DataStore.swift
//  testMasterDetail
//
//  Created by Miguel de Icaza on 4/26/20.
//  Copyright © 2020 Miguel de Icaza. All rights reserved.
//

import Foundation
import Combine


struct Key: Codable, Identifiable {
    let id = UUID()
    var type: String = ""
    var name: String = ""
    var privateKey: String = ""
    var publicKey: String = ""
    var passphrase: String = ""
}

struct Host: Codable, Identifiable {
    let id = UUID()
    var alias: String = ""
    var hostname: String = ""
    var backspaceAsControlH: Bool = false
    var port: Int = 22
    var usePassword: Bool = true
    var username: String = ""
    var password: String = ""
    
    // This is the UUID of the key registered with the app
    var sshKey: UUID?
    var style: String = ""
    var lastUsed: Date = Date.distantPast

}

class DataStore: ObservableObject {
    static let testKey1 = Key (type: "RSA/1024", name: "Legacy Key", privateKey: "", publicKey: "", passphrase: "")
    static let testKey2 = Key (type: "RSA/4098", name: "2020 iPhone Key", privateKey: "", publicKey: "", passphrase: "")

    static let testUuid2 = UUID ()
    
    @Published var hosts: [Host] = [
        Host(alias: "MacPro",         hostname: "mac.tirania.org", lastUsed: Date ()),
        Host(alias: "Raspberri Pi",   hostname: "raspberry.tirania.org", lastUsed: Date ()),
        Host(alias: "MacBook",        hostname: "road.tirania.org", usePassword: false, sshKey: DataStore.testKey1.id),
        Host(alias: "Old Vax",        hostname: "oldvax.tirania.org",usePassword: false, sshKey: DataStore.testKey2.id),
        Host(alias: "Old DECStation", hostname: "decstation.tirania.org"),
    ]
    
    @Published var keys: [Key] = [
        testKey1, testKey2
    ]
    
    func save (host: Host)
    {
        if let idx = hosts.firstIndex (where: { $0.alias == host.alias }) {
            hosts.remove(at: idx)
            hosts.insert(host, at: idx)
        } else {
            hosts.append(host)
        }
    }
    
    func hasHost (withAlias: String) -> Bool
    {
        hosts.contains { $0.alias == withAlias }
    }
    
    func hostHasValidKey (host: Host) -> Bool {
        keys.contains { $0.id == host.sshKey }
    }
    
    // This for now returns the name, but if it is ambiguous, it could return a hash or something else
    func getSshDisplayName (forHost: Host) -> String {
        if let k = keys.first(where: { $0.id == forHost.sshKey }) {
            return k.name
        }
        return "none"
    }
    // Returns the most recent 3 values
    func recentIndices () -> Range<Int>
    {
        hosts.sorted(by: {a, b in a.lastUsed > b.lastUsed }).prefix(3).indices
    }
    static var shared: DataStore = DataStore()
}