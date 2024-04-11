//
//  ContentView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/3/24.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @StateObject var imageViewModel: ImageViewModel = ImageViewModel()
    @State private var path: [ViewType] = []
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20){
                ForEach(ViewType.allCases, id: \.self) { type in
                    Button {
                        path.append(type)
                    } label: {
                        Text("\(type.rawValue) View")
                            .foregroundStyle(Color.white)
                            .padding(10)
                            .background{
                                RoundedRectangle(cornerRadius: 10)
                            }
                    }
                    .navigationDestination(for: ViewType.self, destination: { type in
                        switch type {
                        case ViewType.original:
                            //가장 느린 UI 업데이트 속도
                            AsyncImageView(imageViewModel: imageViewModel)
                        case ViewType.first:
                            //여전히 느리지만 AsyncImage를 사용하지 않은 View
                            FirstScrollView(imageViewModel: imageViewModel)
                        case ViewType.second:
                            FirstScrollView(imageViewModel: imageViewModel)
                        case ViewType.third:
                            FirstScrollView(imageViewModel: imageViewModel)
                        }
                    })
                }
                
            }
        }
    }
}

private enum ViewType:String, CaseIterable{
    case original = "Original"
    case first = "First"
    case second = "Second"
    case third = "Third"
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
