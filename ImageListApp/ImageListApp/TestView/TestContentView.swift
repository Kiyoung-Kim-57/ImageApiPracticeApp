//
//  ContentView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/3/24.
//

import SwiftUI
import CoreData


struct TestContentView: View {
    @ObservedObject var imageViewModel: ImageViewModel = ImageViewModel()
    @State private var path: [ViewType] = []
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20){
                Button {
                    ImageCacheManager.shared.deleteAllImageCache()
                } label: {
                    Text("Remove Image cache in Core Data")
                        .foregroundStyle(Color.white)
                        .padding(5)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.red)
                        }
                }
                Button {
                    imageViewModel.savedImageList = [UIImage?](repeating: nil, count: 10)
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
                    //두번째 접근부터 다운샘플링된 저용량 이미지 사용
                    //ViewModel에 캐쉬 대용의 배열을 생성해서 사용
                    ImageScrollView(imageViewModel: imageViewModel)
                case ViewType.second:
                    //이미지 데이터 이미지로 변환하고 리사이징한 후에 리스트
                    ResizedImageView(imageViewModel: imageViewModel)
                case ViewType.third:
                    //리사이징 작업을 따로 백그라운드로 보내서 작업
                    ResizeInBgView(imageViewModel: imageViewModel)
                case ViewType.fourth:
                    //이미지를 섬네일 사이즈로 다운샘플링해서 사용
                    ThumbnailView(imageViewModel: imageViewModel)
                }
            })
        }
        .onAppear{
            //이미지 캐시를 앱이 시작될 때마다 리셋
            ImageCacheManager.shared.deleteAllImageCache()
//                imageViewModel.getImageList()
        }
    }
}

private enum ViewType:String, CaseIterable{
    case original = "Original"
    case first = "Saved Cache Image"
    case second = "Resized Image"
    case third = "Resizing In\n Background"
    case fourth = "Thumbnail Resizing"
}

#Preview {
    TestContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
