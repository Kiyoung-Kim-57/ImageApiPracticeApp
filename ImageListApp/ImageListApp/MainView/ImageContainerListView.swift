//
//  ImageContainerListView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/23/24.
//

import SwiftUI

struct ImageContainerListView: View {
    @ObservedObject var imageViewModel: ImageViewModel = ImageViewModel()
    @State private var isShowSheet = false
    var body: some View {
        VStack {
            //상단 라벨
            HStack {
                Text("Ramdom Image List")
                    .fontWeight(.bold)
                    .font(.system(size: 25))
                    .padding(.leading, 10)
                Spacer()
                Button {
                    ImageCacheManager.shared.deleteAllImageCache()
                } label: {
                    Text("Delete Cache")
                        .foregroundStyle(Color.white)
                        .padding(5)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.red)
                        }
                }
                .padding(.trailing, 10)

            }
            Divider()
            //Container List
            ContainerListView(imageViewModel: imageViewModel, isShowSheet: $isShowSheet)
        }
    }
}

private struct ContainerListView: View {
    @ObservedObject var imageViewModel: ImageViewModel
    @Binding var isShowSheet: Bool
    @State private var sheetImgModel: ImageModel?
    var body: some View {
        VStack {
            ScrollView {
                ForEach(imageViewModel.imageList, id: \.id) { imgData in
                    //ContainerView
                    Button {
                        isShowSheet.toggle()
                        sheetImgModel = imgData
                    } label: {
                        ContainerView(imageViewModel: imageViewModel, imgData: imgData)
                    }
                    .sheet(isPresented: $isShowSheet, content: {
                        if let data = sheetImgModel {
                            ImageSheetView(imgData: data)
                                .onDisappear {
                                    didDismiss(data)
                                }
                        }
                    })
                }
            }
        }
    }
}

private struct ContainerView: View {
    @ObservedObject var imageViewModel: ImageViewModel
    @State var imgData: ImageModel
    @State var image: UIImage?
    var body: some View {
        HStack {
            if let img = image {
                //로딩된 이미지
                Image(uiImage: img)
                    .resizable()
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.leading, 10)
            } else {
                //로딩대기 이미지
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 80, height: 100)
                        .foregroundStyle(Color.gray)
                    Text("Loading")
                }
                .padding(.leading, 10)
            }
            Spacer()
            Text("\(imgData.altDescription)")
            Spacer()
        }
        .onAppear {
            if let img = ImageCacheManager.shared.loadImageCache(key: imgData.id) {
                image = img
            } else {
                //ContainerView를 불러오고 바로 이미지 데이터 불러옴, Result type 반환
                guard let imgUrl = URL(string: imgData.urls.raw) else { return }
                imageViewModel.loadImage(from: imgUrl ) { result in
                    switch result {
                    case .success(let data):
                        //이미지 데이터를 불러오는데 성공하면 다운샘플링해서 섬네일 딕셔너리에 id와 함께 저장
                        guard let thumb = imageViewModel.resizeInThumb(data: data, size: CGSize(width: 80, height: 100)) else { break }
                        //뷰모델의 딕셔너리에 저장하는 방법
                        //                    imageViewModel.savedThumbnails.updateValue(thumb, forKey: imgData.id)
                        //코어데이터를 이용한 캐시매니저 클래스를 이용하는 방법
                        ImageCacheManager.shared.saveImageCache(image: thumb, forkey: imgData.id)
                        //현재 컨테이너의 이미지 변수에 변환한 이미지를 할당
//                        image = thumb
                        break
                    case .failure(_ ):
                        print("error thumbnail")
                        break
                    }
                }
            }
            
            
        }
    }
}

extension ContainerListView {
    //시트가 내려갈때 섬네일 캐시를 다시 저장하는 함수
    func didDismiss(_ imgData: ImageModel) {
        if let data = ImageCacheManager.shared.loadImageCache(key: imgData.id) {
            //이미 섬네일 캐시가 있다면 리턴
            return
        } else {
            guard let imgUrl = URL(string: imgData.urls.raw) else { return }
            imageViewModel.loadImage(from: imgUrl ) { result in
                switch result {
                case .success(let data):
                    //이미지 데이터를 불러오는데 성공하면 다운샘플링해서 섬네일 딕셔너리에 id와 함께 저장
                    guard let thumb = imageViewModel.resizeInThumb(data: data, size: CGSize(width: 80, height: 100)) else { break }
                    //코어데이터를 이용한 캐시매니저 클래스를 이용하는 방법
                    ImageCacheManager.shared.saveImageCache(image: thumb, forkey: imgData.id)
                    //현재 컨테이너의 이미지 변수에 변환한 이미지를 할당
//                        image = thumb
                    break
                case .failure(_ ):
                    print("error thumbnail")
                    break
                }
            }
        }
    }
}

#Preview {
    ImageContainerListView()
}
