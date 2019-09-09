//
//  ActionRow.swift
//  automaton
//
//  Created by Dylan Owen on 9/7/19.
//  Copyright © 2019 Dylan Owen. All rights reserved.
//

import SwiftUI

struct RedirectionRow: View {

  @EnvironmentObject var actionStore: IntentActionStore
  @Binding var action: IntentAction
  @State var errorState: URLError? = nil

  var body: some View {
    VStack {
      TextField(
        "Redirect URL",
        text: self.$action.url,
        onEditingChanged: { changed in
          self.actionStore.save()
        }
      )
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .lineLimit(nil)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()

      HStack {
        Text(action.key)

        Button(action: {
          switch self.action.followRedirectURL() {
            case .failure(let error):
              self.errorState = error
            default:
              self.errorState = nil
          }
        }) {
            Text("Test!")
        }
          .foregroundColor(Color.white)
          .padding(10)
          .background(Color.blue)
          .cornerRadius(10)
      }
      
      if errorState != nil {
        getError()
      }
    }
  }
  
  func getError() -> Text {
    var text: Text
    switch errorState {
    case .some(.invalidURL):
      text = Text("Bad URL")
    case .some(.unfollowableURL):
      text = Text("Can't Follow This URL")
    default:
      text = Text("We should never get here")
    }
    
    return text
      .foregroundColor(.red)
  }
  
}
