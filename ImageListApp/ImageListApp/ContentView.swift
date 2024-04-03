//
//  ContentView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/3/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        Text("dd")
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
