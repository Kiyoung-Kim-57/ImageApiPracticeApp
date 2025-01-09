# ImageApiPracticeApp
# 프로젝트 개요
이미지 URL에서 고용량 이미지를 불러오고 렌더링해서 UI에 업데이트하는 것은 꽤나 고비용의 작업이다. 이런 이미지들을 리스트로 여러 개 표시한다고 하면 필연적으로 앱은 버벅이게 된다. 또한 고용량 이미지를 리스트로 표현하게 되면 메모리 자원을 많이 사용하게 되어 최적화가 필요하다. 
그러면 어떻게 이미지를 관리하고 리스트로 표현하는 것이 효율적일까? 그 부분에 대한 스스로의 결론을 내고 싶어 해당 프로젝트를 진행해봤다. 
**TestView** 폴더에 들어간 View들을 각각 이미지 다루는 방식에따라 나눠진 뷰이다. 어떤 것은 `AsyncImage`를 사용하고 어떤 것은 `UIGraphicsImageRenderer`로 리사이징하는 등 최적화 방식이 조금씩 다르다. 
**MainView**에는 테스트 결과를 토대로 내가 생각하는 이상적인 이미지 리스트 샘플을 작성해봤다. 

UI는 **SwiftUI**를 이용했고 이미지 캐싱에는 **Core Data**를 이용한 캐시 매니저를 생성하여 구현해봤다. 

더불어 이 프로젝트를 통해 URLSession을 이용한 API 통신을 연습하고 Core Data에 대해 학습해볼 수 있도록 다양한 기술을 활용해봤다.

# 테스트
## 테스트 환경
테스트를 진행하기 위해 선정한 API는 Unsplash API이다. 랜덤한 이미지들을 여러 개 받아올 수 있고 이미지의 크기도 내가 지정해서 요청할 수 있다. 
1. 이미지 사이즈 - 이미지 리스트의 최적화를 제대로 해보려면 크기가 큰 이미지가 필요하다고 생각해 원본 사이즈를 사용했다. 
2. VStack 사용 - LazyVStack을 사용하면 불필요한 이미지 로드가 되지 않아 최적화엔 좋지만 이번 테스트에선 Lazy 방식을 이용한 최적화가 중점이 아니기 때문에 일반 VStack을 사용했다. 
3. 테스트 결과 - 테스트 결과는 자원 소모량을 기준으로 판단했다. 최대 CPU 사용량과 메모리 사용량, 그리고 최적화 이후 메모리 사용량 등을 고려하여 판단했다.

## 테스트 케이스
1. AsyncImage - SwiftUI에서 가장 간단하게 비동기적으로 이미지 뷰를 표현할 수 있는 방식이라 선정
2. Image Resizing - `UIGraphicsImageRenderer`를 이용한 UIImage 단계에서 리사이징 방식 사용
3. Resizing Concurrently - 2번 방식이지만 여러 이미지의 리사이징을 백그라운드에서 병렬적으로 진행
4. Downsampling - CGImage 단계에서 다운 샘플링을 진행

## 테스트 결과
### AsyncImage
- 일반적으로 이미지 리스트를 생성할 때 불러온 이미지 그대로 이미지 리스트에 띄우는 방식이다. 다만 AsyncImage는 SwiftUI에서 비동기적으로 이미지 뷰를 표시하기 쉽게 추상화된 객체여서 사용이 매우 간편하다. 가장 기본적인 리스트 표현 방식이기 때문에 이후 나올 케이스들과 비교용으로 사용한다.


![](https://i.imgur.com/74W2MY9.gif)

| CPU(최대 89%)                          | Memory(최대 448.9MB)                   |
| ------------------------------------ | ------------------------------------ |
| ![](https://i.imgur.com/1DkICn7.png) | ![](https://i.imgur.com/nD0ZJcA.png) |

**장점**
- 코드 가독성이 좋다
- 로딩 중에 띄울 ProgressView() 설정이 쉽다

**단점**
- 재접근 시에 따로 캐싱이 없다면 매번 긴 로딩시간을 써야한다
- 원본 이미지가 사이즈가 크면 메모리 사용량이 많이 늘어난다

### Image Resizing(UIGraphicsImageRenderer)
```swift
extension UIImage { 
	func resize(ratio: CGFloat) -> UIImage { 
		let newWidth = self.size.width * ratio 
		let newHeight = self.size.height * ratio 
		let newSize = CGSize(width: newWidth, height: newHeight) 
		let render = UIGraphicsImageRenderer(size: newSize) 
		let renderedImage = render.image { _ in 
					self.draw(in: CGRect(origin: .zero, size: newSize)) 
					} 
		return renderedImage 
	} 
}
```
- `UIGraphicsImageRenderer`를 이용한 리사이징 방식이다. UIImage 단계에서 리사이징이 진행되기 때문에 꽤나 CPU 자원 사용량이 큰 고비용 작업이다. 영상을 보면 동작은 AsyncImage와 크게 다를바 없어 보이지만 CPU 사용량과 메모리 사용량에서 차이를 보인다. CPU 사용량은 AsyncImage에 비해 다소 높고 메모리 최대 사용량은 비슷하지만 리사이징이 끝난 이후에는 기존 메모리 사용량의 20% 정도의 메모리 사용량을 보인다.(454 -> 93)


![](https://i.imgur.com/aXgvL62.gif)

| CPU(최대 사용량 102%)                   | Memory(454MB -> 93MB)                |
| ------------------------------------ | ------------------------------------ |
| ![](https://i.imgur.com/XEaZJFh.png) | ![](https://i.imgur.com/8YlbND0.png) |

**장점**
- 리사이징 후에 메모리 사용량이 확 줄어듦(AsyncImage만 사용했을 때는 400MB를 넘어감)

**단점**
- 리사이징이 CPU 자원을 많이 사용해서 순간적인 사용량이 증가함

### Resizing Concurrently
```swift
static func resizeImage(image: UIImage) async throws -> UIImage {
        let resized = image.resize(ratio: 0.5)
        
        return resized
}
```
- 2번 방식에서 각 이미지의 리사이징이 동기적으로 이루어지고 있었다. 그래서 이를 비동기적, 병렬적으로 처리하면 이미지 리스트 처리 자원 관리를 효율적으로 할 수 있지 않을까하여 사용해봤다. 기존에 동기적으로 동작하던 리사이징 함수를 Swift Concurrency를 활용해 비동기 함수로 한 번 더 감싸주어 사용했다. 결과는 그리 좋지 못했다. 백그라운드에서 병렬적으로 리사이징하는 것은 좋았지만 리사이징 함수 자체가 한 번 호출될 때 굉장히 CPU 사용을 많이 해서 병렬적으로 처리하니 CPU 자원 소모가 어마무시하게 커졌다. 그리고 고용량 이미지를 동시에 여러 개를 처리하다보니 메모리 사용량도 급증했다.

![](https://i.imgur.com/b35Ehhb.gif)

| CPU(최대222%)                          | Memory(최대 868MB)                     |
| ------------------------------------ | ------------------------------------ |
| ![](https://i.imgur.com/Q47z2nK.png) | ![](https://i.imgur.com/utVWmxG.png) |

**단점**
- 용량이 큰 원본 이미지와 CPU 자원 소모량이 큰 리사이징 작업이 백그라운드에서 병렬적으로 진행되다보니 메모리 사용량과 CPU 자원 소모량이 엄청나게 늘었다

### Downsampling
```swift
func resizeInThumb(data: Data ,size: CGSize) -> UIImage? { 
	let options: [CFString: Any] = [ 
			kCGImageSourceShouldCache: false,
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
			kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height), 
			kCGImageSourceCreateThumbnailWithTransform: true ] 
			
	guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
		  let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) 
		  else { return nil }  
	let resizedImage = UIImage(cgImage: cgImage) 
	return resizedImage 
}
```
- UIImage 단계에서 이미지 리사이징은 CPU 사용량이 커서 이미지 리스트를 최적화하기엔 적합하지 않다고 판단됐다. WWDC18의 [iOS Memory Deep Dive](https://developer.apple.com/videos/play/wwdc2018/416/)을 보니 CGImage 단계에서 다운샘플링하는 방식이 있다는 것을 알게됐고 이 방식을 적용해봤다. 해당 방식은 이미지가 UIImage로 렌더링 되기 이전 비트맵 형식에서 다운샘플링 되는 것이기 때문에 CPU 사용량이 적었다. 또한 실제 사용에서도 가장 부드러운 스크롤 성능을 보였다. 

![](https://i.imgur.com/or2U7Le.gif)

| CPU(최대41%)                           | Memory(최대 106MB)                     |
| ------------------------------------ | ------------------------------------ |
| ![](https://i.imgur.com/bRfJgiI.png) | ![](https://i.imgur.com/xD5oxBz.png) |

**장점**
- CPU & Memory 사용량이 압도적으로 적음
- 스크롤 성능이 가장 좋음

**단점**
- 이미지를 썸네일용으로 다운샘플링한거라 확대하면 화질이 굉장히 좋지 않음

## 테스트 결론
### 테스트 요약
1. AsyncImage가 가장 가독성 좋고 간단하게 코드를 쓰기 좋음
2. 이미지 리사이징을 하면 메모리 사용량이 많이 줄지만 CPU 자원 소모가 큼
3. 이미지 리사이징을 병렬적으로 처리하면 CPU와 메모리 전부 사용량이 너무 늘어남
4. 이미지 다운샘플링을 하면 CPU와 메모리 사용량이 많이 줄어들어 많은 이미지가 들어간 리스트에서 좋은 성능을 보여줬다. 하지만 다운샘플링된 이미지 화질이 매우 안좋아져서 모든 곳에 사용할 수는 없다
### 이미지 리스트 개선 방안
- 이미지 리스트 성능을 향상을 위해선 적절한 곳에 다운샘플링된 이미지를 썸네일로 사용하고 원본 이미지 또는 고화질 이미지는 필요할 때만 불러올 필요가 있다고 느꼈다. 

# 개선한 이미지 리스트 샘플
테스트 결과를 통해 이미지 리스트를 표현할 때는 이미지 다운샘플링을 통해 이미지 처리가 효율적이라고 판단했다. 하지만 다운샘플링된 이미지는 화질이 좋지 않기 때문에 리스트의 썸네일 표현에는 적합하지만 이미지를 상세하게 볼 땐 적절하지 않다는 생각이 들었다. 그래서 썸네일 이미지와 고화질 이미지를 적절한 곳에 활용한다면 더 좋은 성능, 좋은 사용자 경험을 제공하는 이미지 리스트를 만들 수 있다는 생각이 들었다. 그리고 이미지를 적절하게 재사용하기 위해 캐싱을 도입해봤다. 캐싱은 Core Data를 이용한 디스크 캐싱이다. NSCache를 사용하지 않고 Core Data를 사용한 이유는 단순히 Core Data의 구조를 이번 기회에 같이 학습해보고 직접 CRUD를 구현해보기 위해서였다. 
(사용해 본 결과 간단한 캐싱은 NSCache를 이용하는게 좋아보인다...!)

## 개선 이미지 리스트 특징
### 리스트에 다운 샘플링 적용
- 이미지 리스트를 보여주는 부분에서는 각 고용량 이미지를 다운샘플링해서 섬네일로 사용했다. 각 리스트 요소의 섬네일 이미지는 고용량일 필요가 없기 때문이다. 
### 이미지 캐싱 적용
- 이미지 리스트를 불러올 때 다운샘플링 된 이미지는 캐싱된다. 해당 캐싱 이미지는 필요할 때마다 재사용되어 불필요한 이미지 요청을 방지한다. 원본 이미지를 캐싱하는 것은 메모리 효율상 좋지 않다고 판단해 저용량의 섬네일 이미지를 사용했다.(원본 이미지는 하나 당 몇십 MB 정도의 크기이기 때문에 다수의 이미지를 캐싱하기에 좋지 않다.)
### PlaceHolder로 캐싱된 이미지 적용
- 보통 고용량 이미지는 로딩될 때까지 다소 시간이 걸린다. 그래서 이미지를 보여주는 앱들은 PlaceHolder를 이용해 이미지가 로딩 중이라고 표시한다. 나는 이 PlaceHolder를 미리 캐싱된 섬네일 이미지로 표시했다. 그러면 이미지가 완전 로딩되기 전에 저화질 이미지가 먼저 보여져 사용자가 먼저 저화질 이미지를 확인하고 고화질 이미지를 확인할 수 있도록 했다. 해당 방식을 이용하니 사용자 경험이 더 좋게 느껴졌다. 

## 사용 영상

![](https://i.imgur.com/lF3XapA.gif)

- 처음에는 고용량 이미지를 다운샘플링하여 표시하는데 시간이 존재하기 때문에 섬네일 표시에 시간이 조금 걸린다. 그리고 각 셀을 터치하면 고화질 원본 이미지를 확인할 수 있다. 원래 바로 고화질 이미지를 보여주면 로딩에 시간이 걸리기 때문에 완전히 표시되기 까지 사용자가 기다려야한다. 이 때 캐싱된 섬네일 이미지를 보여주면서 로딩 체감 시간을 줄여줬다. 

# 느낀 점
이번 프로젝트는 원래 이미지 API를 이용해 URLSession을 학습하는 것에서 시작했다. 처음에 단순하게 하나 씩 이미지를 불러오면서 끝마치려고 했으나 다수의 이미지를 리스트로 표시할 때 버벅이는 것을 발견했고 이를 최적화하고 싶다는 생각이 들어 진행했다. 
이미지를 최적화하기 위해 이미지 타입에 대해 공부해보고 다양한 비동기 프로그래밍 방식, 캐싱을 처음으로 시도하고 도입해봤다. 다 처음 접했던 개념이라 어렵긴 했지만 테스트를 통해 성과를 보였을 때 성취감이 매우 좋았다.
다만 아쉬운 점은 테스트에 치중하여 UI 코드를 너무 가독성 좋지 않게 작성했다는 것이다. 코드를 작성할 때는 SwiftUI에 대한 지식도 부족하고 하여 들여쓰기 깊이가 너무 깊어지는 코드가 많았다.... 대표로 `ImageScrollView`를 리팩토링 해봤지만 목표는 다른 뷰도 리팩토링하는 것이다. 리팩토링하는 과정에서도 `some` 키워드와 `ViewBuilder`키워드에 대해 공부해 볼 수 있어 좋은 기회였다. 정리 내용도 첨부해본다.
- [some & any](https://defiant-crime-b26.notion.site/some-any-1660c1bbc2a680b390edeeb297131c07?pvs=4)
- [ViewBuilder](https://defiant-crime-b26.notion.site/ViewBuilder-feat-resultBuilder-1660c1bbc2a680a08a99fce01e0e8dce?pvs=4)

해당 프로젝트는 API 활용 연습으로 시작했지만 여러모로 다양한 기술을 접해보고 학습해볼 수 있는 프로젝트였다. 완결된 앱은 아니지만 많은 것을 학습해볼 수 있는 재밌는 경험이었다.


