//
//  StartView.swift
//  ImageListApp
//
//  Created by 김기영 on 12/23/24.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack {
            testViewButton
            mainViewButton
        }
    }
    
    private var testViewButton: some View {
        Button {
            // TODO: Push TestView
        } label: {
            Text("Test View")
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .padding(.horizontal, 30)
                }
        }
    }
    
    private var mainViewButton: some View {
        Button {
            // TODO: Push MainView
        } label: {
            Text("Main View")
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .padding(.horizontal, 30)
                }
        }
    }
}

#Preview {
    StartView()
}
