//
//  ContentView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/3/24.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @ObservedObject var imageViewModel: ImageViewModel = ImageViewModel()
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @State private var path: [ViewType] = []
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20){
                Button {
                    imageLoader.imageList = [UIImage?](repeating: nil, count: 10)
                } label: {
                    Text("Remove Image data")
                        .foregroundStyle(Color.white)
                        .padding(5)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.red)
                        }
                }
                ForEach(ViewType.allCases, id: \.self) { type in
                    
                    Button {
                        path.append(type)
                    } label: {
                        Text("\(type.rawValue) View")
                            .foregroundStyle(Color.white)
                            .padding(10)
                            .background{
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 200, height: 50)
                            }
                    }
                }
                
            }
            .navigationDestination(for: ViewType.self, destination: { type in
                switch type {
                case ViewType.original:
                    //가장 느린 UI 업데이트 속도
                    AsyncImageView(imageViewModel: imageViewModel)
                case ViewType.first:
                    //처음 다운로드는 느리지만 두번째 접속부터는 빠른 뷰 업데이트를 보여줌
                    //ViewModel에 캐쉬 대용의 배열을 생성해서 사용
                    LazyScrollView(imageViewModel: imageViewModel, imageLoader: imageLoader)
                case ViewType.second:
                    ResizedImageView(imageViewModel: imageViewModel, imageLoader: imageLoader)
                case ViewType.third:
                    ResizeInBgView(imageViewModel: imageViewModel, imageLoader: imageLoader)
                case ViewType.fourth:
                    ThumbnailView(imageViewModel: imageViewModel, imageLoader: imageLoader)
                }
            })
        }
        .onAppear{
                imageViewModel.getImageList()
        }
    }
}

private enum ViewType:String, CaseIterable{
    case original = "Original"
    case first = "Saved Image"
    case second = "Resized Image"
    case third = "Resizing In\n Background"
    case fourth = "Thumbnail Resizing"
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
