//
//  ContentView.swift
//  automaton
//
//  Created by Dylan Owen on 9/7/19.
//  Copyright © 2019 Dylan Owen. All rights reserved.
//

import SwiftUI
import os

struct ContentView: View {
  
  @EnvironmentObject private var actionStore: IntentActionStore
  @State private var newKey: String = ""
  
  var body: some View {
    VStack {
      HStack {
        TextField("New Action Key", text: $newKey)
          .disableAutocorrection(true)
          .autocapitalization(.none)
          .lineLimit(nil)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
        
        Button(action: addAction) {
            Text("Create Action")
        }
          .disabled(newKey.isEmpty || actionStore.actions.contains(where: { $0.key == newKey } ))
          .padding(10)
          
      }
      
      List {
        ForEach(actionStore.actions.indexed(), id: \.element.id) { index, action in
          RedirectionRow(action: self.$actionStore.actions[index])
        }
          .onDelete(perform: deleteAction)
      }
    }
  }
  
  func addAction() {
    actionStore.actions.append(IntentAction(newKey))
    actionStore.save()
  }
  
  func deleteAction(at offsets: IndexSet) {
    // TODO enable this again once this bug is fixed
    // Bug description: SwiftUI doesn't seem to understand binding the inner views
    // to our array, when the array changes it causes an index out of bound exception,
    // so for now, no deleting, unless you wanna do it implicitly
    
    //actionStore.actions.remove(atOffsets: offsets)
    //actionStore.save()
  }
}

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)

    let base: Base

    var startIndex: Index { base.startIndex }

    var endIndex: Index { base.endIndex }

    func index(after i: Index) -> Index {
        base.index(after: i)
    }

    func index(before i: Index) -> Index {
        base.index(before: i)
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
