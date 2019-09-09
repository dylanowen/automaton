//
//  IntentActionStore.swift
//  automaton
//
//  Created by Dylan Owen on 9/8/19.
//  Copyright © 2019 Dylan Owen. All rights reserved.
//

import SwiftUI
import Combine
import os

enum URLError: Error {
  case invalidURL
  case unfollowableURL
}

private let SupportedSchemes: Set<String> = Set(Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] ?? [String]())

struct IntentAction: Comparable, Identifiable {

  let key: String
  var url: String
  
  init(_ key: String, _ url: String = "") {
    self.key = key
    self.url = url
  }
  
  var id: String {
    get {
      key
    }
  }
  
  func isURLValid() -> Result<URL, URLError> {
    switch URL(string: url) {
      case .some(let validURL):
        return .success(validURL)
      case .none:
        return .failure(.invalidURL)
    }
  }
  
  func canFollowURL() -> Result<URL, URLError> {
    isURLValid()
      .flatMap( { url in
        // if we don't have a scheme our url is probably invalid, if we do have one, see if we defined it in our plist
        let hasValidScheme = url.scheme.map(SupportedSchemes.contains) ?? false
        
        if (hasValidScheme && UIApplication.shared.canOpenURL(url)) {
          return .success(url)
        }
        else {
          return .failure(.unfollowableURL)
        }
      } )
  }
  
  func followRedirectURL() -> Result<URL, URLError> {
    let result = canFollowURL()

    switch result {
      case .success(let url):
        UIApplication.shared.open(url)
      default:
        break
    }
    
    return result
  }
  
  static func < (left: IntentAction, right: IntentAction) -> Bool {
    return left.key < left.key
  }
}


final class IntentActionStore: ObservableObject {
  private static let SettingsKey: String = "IntentActions"
  
  @Published var actions: [IntentAction] = load()
  
  func load() {
    actions = Self.load()
  }
  
  func save() {
    let underlying = actions
      .reduce(into: [String: String]()) { dictionary, action in
        let urlString = String(describing: action.url)
        if (!action.key.isEmpty && !urlString.isEmpty) {
          dictionary[action.key] = urlString
        }
      }
    
    Self.saveUnderlying(underlying: underlying)
  }
  
  private static func load() -> [IntentAction] {
    loadUnderlying()
      .compactMap({ key, url in
        if (URL(string: url) == nil) {
          os_log("Found an invalid URL in our datastore: %@", type: .error, url)
          
          return nil
        }
        
        return IntentAction(key, url)
      })
      .sorted()
  }
  
  private static func loadUnderlying() -> [String: String] {
    UserDefaults.standard.object(forKey: Self.SettingsKey) as? [String: String] ?? [String: String]()
  }
  
  private static func saveUnderlying(underlying: [String: String]) {
    UserDefaults.standard.set(underlying, forKey: Self.SettingsKey)
  }
}
