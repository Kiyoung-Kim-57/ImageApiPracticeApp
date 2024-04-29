//
//  ImageSheetView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/25/24.
//

import SwiftUI

struct ImageSheetView: View {
    @State var imgData: ImageModel
    var body: some View {
        VStack {
            if let url = URL(string: imgData.urls.raw) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                        .frame(width: 300, height: 500)
                } placeholder: {
                    if let thumb = ImageCacheManager.shared.loadImageCache(key: imgData.id) {
                        //섬네일 이미지가 있을 경우
                        Image(uiImage: thumb)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 10)
                            .frame(width: 300, height: 500)
                    } else {
                        //캐쉬가 없을때
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .shadow(radius: 10)
                                .foregroundStyle(Color.gray)
                                .frame(width: 300, height: 500)
                            Text("Loading")
                                .font(.system(size: 40))
                        }
                    }
                }
            }
            Text("\(imgData.altDescription)")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding(10)
        }
        .onAppear{
            print("Appear!")
        }
    }
}

extension ImageSheetView {
    struct MyButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label.foregroundStyle(Color.black)
        }
    }
}
#Preview {
    ImageSheetView(imgData: ImageModel(id: "2", altDescription: "Test Image No.2", urls: Urls(raw: "https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")))
}
