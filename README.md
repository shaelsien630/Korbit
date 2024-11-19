
# Korbit
> 실시간 암호화폐 시세 정보 조회 앱  

<br>

## 1. 프로젝트 소개

개발환경 : Xcode 16.1, iOS 18.1  
개발기간 : 2024.11.13 - 2024.11.14  
사용 API : [Korbit Open API](https://docs.korbit.co.kr/ "korbit")   

<br>

## 2. 기술 스택

- `MVVM` 패턴을 채택하여, 데이터 소스와 비즈니스 로직을 명확히 분리하였습니다.
- `SwiftUI`로 UI 구성하고 화면 로직을 구현했습니다.
- 비동기 데이터 흐름 관리를 위하여 `Combine` 을 사용했습니다.
- 즐겨찾기 데이터를 `UserDefaults` 를 통해 저장했습니다.  

<br>

## 3. 주요 기능

- 시세 조회 : 가상자산명, 현재가, 변동률, 변동가격, 거래대금 정보 표시
- 검색 기능 : 가상자산명 또는 심볼을 검색하여 목록 출력(`일부 키워드`만으로도 검색 가능)
- 정렬 기능 : 가상자산명, 현재가, 변동률, 거래대금을 기준으로 `내림차순/오름차순 정렬` 가능
- 즐겨찾기 기능 : 선택한 암호화폐를 즐겨찾기에 추가하거나 제거 가능하며, 설정은 앱 `종료 후에도 유지`됨
- 실시간 시세 업데이트 : `1초`마다 서버로부터 데이터를 갱신하여 최신 암호화폐 시세를 표시

<br>

## 4. 추가 기능

- 마켓/즐겨찾기 화면 전환 : `Swipe Gesture`를 통해 탭 간 이동 가능
- 전체 즐겨찾기 해제 : 상단 우측 아이콘으로 즐겨찾기 목록 `전체 삭제`
- 검색어 입력 지원 : 입력 중에도 `실시간 검색 결과 표시` 및 X 버튼을 통해 `검색어 지우기` 기능
- 즐겨찾기 알림 : 즐겨찾기 추가/해제 시 `토스트 알림` 표시

<br>

## 5. 프로젝트 구조

```
korbit  
├── App  
│   └── korbitApp.swift             # 앱의 진입점 및 초기 설정 관리  
├── Model                           # 모델 계층, 데이터 구조 및 데이터 관리  
│   ├── Model.swift                 # Ticker 및 Currency 모델 정의  
│   ├── DataSource.swift            # 네트워크 요청을 통한 데이터 소스 관리  
│   ├── Repository.swift            # 데이터 소스를 비즈니스 로직에 맞게 가공하여 제공  
│   ├── BookmarkManager.swift       # 즐겨찾기 관리 및 UserDefaults와 연동  
│   └── FormatterHelper.swift       # 데이터 형식화 기능, TickerView에 표시할 데이터 포맷 관리  
├── ViewModel                       # 뷰 모델 계층, UI에 제공할 데이터와 비즈니스 로직 중개  
│   └── ViewModel.swift             # 데이터 처리 로직, 정렬 및 검색 기능 등 포함  
├── View                            # 사용자 인터페이스 계층, 화면 구성  
│   ├── MainView.swift              # 앱의 메인 화면 및 네비게이션 구조 설정  
│   ├── TabView.swift               # 마켓 및 즐겨찾기 탭 네비게이션 관리  
│   ├── MarketView.swift            # 마켓 화면, 암호화폐 시세 목록 표시  
│   ├── BookmarkView.swift          # 즐겨찾기 화면, 사용자가 즐겨찾기 한 암호화폐 표시  
│   ├── SortView.swift              # 정렬 옵션을 선택할 수 있는 화면  
│   ├── TickerView.swift            # 각 암호화폐 항목을 표시하는 개별 셀  
│   └── ToastView.swift             # 즐겨찾기 추가/삭제 시 나타나는 토스트 메시지  
└── Assets                          # 앱의 이미지 및 기타 Color 리소스  
```

## 📂 Model

### 1) Model.swift 
> Ticker와 Currency 모델 정의

### 2) DataSource.swift 
> API로부터 데이터를 주기적으로 혹은 단발적으로 요청하는 역할을 담당

<details>
<summary> 더보기 </summary>

#### DataSource 클래스
- `DataSource`는 `DataSourceProtocol`을 구현하는 `final class`로, 실제 API 호출을 수행하여 데이터를 가져오는 기능을 담당합니다.
- `cancellables`: Combine의 `AnyCancellable` 객체를 저장하는 `Set`으로, 메모리 관리를 위해 구독을 저장해 두고, 클래스가 해제될 때 자동으로 구독을 취소합니다.
    
#### fetchTickersPeriodically 메서드
- `fetchTickersPeriodically` 메서드는 1초마다 시세 데이터를 요청하는 주기적인 데이터 요청 메서드입니다.
- `Timer.publish(every: 1, on: .main, in: .default).autoconnect()`를 사용하여 1초마다 이벤트를 발생시키고, `flatMap`을 통해 매번 API 요청을 수행합니다.
- `URLSession.shared.dataTaskPublisher`를 사용하여 비동기로 데이터를 가져오고, `catch` 연산자를 통해 오류가 발생했을 경우 빈 Publisher를 반환하여 스트림을 중단하지 않습니다.
- `eraseToAnyPublisher()`를 사용해 `AnyPublisher<Data, URLError>`로 타입을 지워 반환합니다.
    
#### fetchTickers 메서드, fetchCurrencies 메서드
- `fetchTickers`와 `fetchCurrencies` 메서드는 단발성으로 시세 데이터를 요청하는 메서드입니다.
- `URLSession`의 `dataTaskPublisher`를 사용하여 주어진 URL로 네트워크 요청을 보내고, `map` 연산자로 데이터를 추출하여 반환합니다.
- `handleEvents`에서 `cancellables`에 구독을 저장하여 메모리 관리가 자동으로 되도록 합니다.
- `eraseToAnyPublisher()`를 통해 `AnyPublisher<Data, URLError>` 타입으로 반환합니다.

</details>    


### 3) Repository.swift 
> 데이터를 가공하여 ViewModel에 제공하는 역할 담당

<details>
<summary> 더보기 </summary>

#### Repository 클래스
- `Repository`는 `RepositoryProtocol`을 구현하는 클래스이며, `DataSource`를 통해 데이터를 받아 비즈니스 로직에 맞게 가공하여 제공합니다.
- `cancellables`: Combine의 `AnyCancellable` 객체를 저장하는 `Set`으로, 메모리 관리를 위해 구독을 저장하고 클래스가 해제될 때 자동으로 구독을 취소합니다.

#### fetchTickersPeriodically 메서드
- `fetchTickersPeriodically` 메서드는 `DataSource`의 주기적인 데이터 요청 기능을 활용하여 1초마다 시세 데이터를 요청하고, JSON 데이터를 `Ticker` 모델로 디코딩하여 반환합니다.
- `tryMap`을 통해 JSON 데이터를 디코딩하며, 디코딩이 실패할 경우 오류를 반환합니다.
- `eraseToAnyPublisher()`로 타입을 `AnyPublisher<[Ticker], Error>`로 변환해 반환합니다.

#### fetchTickers 메서드, fetchCurrencies 메서드
- `fetchTickers`와 `fetchCurrencies` 메서드는 단발성으로 시세 데이터와 암호화폐 목록 데이터를 요청하고, 데이터를 JSON에서 `Ticker`와 `Currency` 모델로 각각 디코딩하여 반환합니다.
- `tryMap`을 사용해 데이터를 디코딩하며, `handleEvents`를 통해 구독을 `cancellables`에 저장해 메모리 관리가 가능하게 합니다.
- `eraseToAnyPublisher()`로 `AnyPublisher<[Ticker], Error>` 타입으로 반환합니다.

#### fetchTickersWithCurrencies 메서드
- `fetchTickersWithCurrencies` 메서드는 `fetchTickers`와 `fetchCurrencies`를 병합하여 각 `Ticker`에 해당 `Currency`의 전체 이름(`fullName`)을 추가하는 기능을 제공합니다.
- `Publishers.Zip`을 사용해 두 데이터를 병렬로 가져오며, `map`을 통해 `Ticker` 데이터에 `Currency`의 `fullName`을 병합하여 `Ticker` 모델을 보강합니다.
- 병합된 결과는 `AnyPublisher<[Ticker], Error>`로 반환되어, 최종적으로 필요한 데이터를 제공할 수 있습니다.

</details> 

### 4) BookmarkManager.swift 
> 즐겨찾기 기능을 관리하며, `UserDefaults`를 통해 즐겨찾기 목록을 저장 및 로드

<details>
<summary> 더보기 </summary>

#### BookmarkManager 클래스
- `BookmarkManager`는 사용자가 추가한 즐겨찾기 데이터를 `UserDefaults`에 저장하고 관리하는 기능을 제공합니다.
- `userDefaultsKey`: `UserDefaults`에 저장될 즐겨찾기 항목의 키로, `bookmarkedItems`라는 키를 사용합니다.
- `cancellables`: Combine의 `AnyCancellable` 객체를 저장하는 `Set`으로, 구독을 저장하여 클래스가 해제될 때 자동으로 구독을 취소합니다.

#### bookmarks 프로퍼티
- `bookmarks`는 현재 즐겨찾기에 저장된 항목들을 `Set<String>`으로 관리하는 프로퍼티입니다.
- `UserDefaults`에서 배열 형태로 즐겨찾기를 불러와 `Set`으로 변환하여 관리하며, 새 값을 설정할 때는 `UserDefaults`에 저장합니다.

#### addBookmark 메서드
- `addBookmark` 메서드는 특정 항목을 즐겨찾기에 추가하는 비동기 메서드입니다.
- 비동기 `Future`를 사용하여 백그라운드 스레드에서 업데이트를 처리하고, 성공 여부를 `AnyPublisher<Bool, Never>`로 반환하여 Combine 스트림으로 관리할 수 있도록 합니다.

#### removeBookmark 메서드
- `removeBookmark` 메서드는 특정 항목을 즐겨찾기에서 제거하는 비동기 메서드입니다.
- `addBookmark`와 유사하게 `Future`를 사용하여 비동기로 `UserDefaults`를 업데이트하며, 결과는 `AnyPublisher<Bool, Never>`로 반환됩니다.

#### toggleBookmark 메서드
- `toggleBookmark` 메서드는 특정 항목이 이미 즐겨찾기에 존재하는지 확인하고, 존재하면 `removeBookmark`를, 존재하지 않으면 `addBookmark`를 호출하여 즐겨찾기 상태를 전환합니다.
- 이를 통해 하나의 메서드로 즐겨찾기 상태를 관리할 수 있습니다.

#### isBookmarked 메서드
- `isBookmarked` 메서드는 특정 항목이 현재 즐겨찾기에 추가되어 있는지 여부를 `Bool`로 반환합니다.
  
#### clearAllBookmarks 메서드
- `clearAllBookmarks` 메서드는 모든 즐겨찾기 항목을 삭제하는 메서드로, 비동기로 `UserDefaults`에서 데이터를 제거하고 `AnyPublisher<Void, Never>` 타입으로 반환합니다.

#### getBookmarkCount 메서드
- `getBookmarkCount` 메서드는 현재 즐겨찾기 항목의 개수를 반환합니다.

</details> 

### 5) FormatterHelper.swift 
> `TickerView`에서 표시되는 데이터를 포맷팅하는 함수들 제공

<details>
<summary> 더보기 </summary>

#### formattedValue 함수
- `formattedValue` 함수는 입력값에 다양한 포맷팅 옵션을 적용하여 포맷팅된 문자열과 색상을 포함하는 값을 반환합니다.
- 함수는 `FormattedValueOptions` 옵션을 받아, `천 단위 구분자`, `부호 추가`, `백분율`, `부호에 따른 색상` 등을 적용할 수 있습니다.
- 포맷팅된 문자열을 통해 UI에서 가독성 높은 데이터를 표시할 수 있도록 지원합니다.

</details> 

<br>

## 📂 ViewModel

### 1) ViewModel.swift 
> 데이터를 가공하여 `View`에 제공하며, 검색, 정렬, 실시간 업데이트 등 주요 로직을 관리

<details>
<summary> 더보기 </summary>

#### startPeriodicFetch 메서드
- 1초마다 서버에서 최신 시세 데이터를 가져오는 메서드입니다.
- `repository.fetchTickersPeriodically()`를 사용하여 주기적인 데이터를 수신하고, 새로운 데이터를 `updateTickers(with:)` 메서드를 통해 반영합니다.

#### updateTickers 메서드
- 새로운 데이터와 기존 데이터를 비교하여 변경된 부분만 업데이트하는 메서드입니다.
- `tickers` 배열의 항목을 순회하며 기존 항목과 비교하고, 가격, 변동률, 거래대금 등 주요 데이터가 변경된 경우에만 업데이트하여 성능을 최적화합니다.
- 업데이트 시 기존 항목의 `fullName`과 `bookmark` 상태를 유지하여 UI의 일관성을 보장합니다.

#### fetchTickers 메서드
- 초기 데이터를 단발성으로 가져오는 메서드로, `Repository`의 `fetchTickersWithCurrencies()`를 호출하여 시세 및 통화 데이터를 가져옵니다.
- 데이터가 성공적으로 로드되면, 즐겨찾기 상태와 정렬 기준을 적용하여 `tickers`를 업데이트하고, `isDataLoaded` 값을 `true`로 변경합니다.

#### updateSortOption 메서드
- 정렬 기준을 변경하는 메서드로, 현재 선택된 기준을 다시 선택하면 오름차순/내림차순을 토글하고, 새로운 기준을 선택하면 내림차순으로 설정합니다.
- 변경된 기준에 따라 `sortTickers()`를 호출하여 데이터를 정렬합니다.

#### sortTickers 메서드
- `currentSortOption`에 따라 시세 데이터를 정렬하는 메서드입니다.
- 가상자산명, 현재가, 변동률, 거래대금을 기준으로 오름차순/내림차순 정렬이 가능하며, `currentSortOption`의 값을 사용하여 동적으로 정렬 기준을 결정합니다.
- 사용자 경험을 개선하기 위해 동일한 값일 경우 종목명을 기준으로 재정렬하여 UI 일관성을 유지합니다.

#### toggleBookmark 메서드
- 특정 항목의 즐겨찾기 상태를 토글하는 메서드로, `bookmarkManager.toggleBookmark`를 통해 즐겨찾기 추가/삭제를 수행합니다.
- 즐겨찾기 상태가 변경되면 `tickers` 배열에서 해당 항목을 찾아 상태를 업데이트하고, 성공 시 사용자에게 토스트 메시지를 표시합니다.

#### removeAllBookmarks 메서드
- 모든 즐겨찾기를 초기화하는 메서드로, `bookmarkManager.clearAllBookmarks()`를 호출하여 모든 항목을 삭제합니다.
- 즐겨찾기가 삭제되면 `tickers` 배열에서 모든 항목의 `bookmark` 상태를 초기화하고, 사용자에게 성공 메시지를 표시합니다.

</details> 

<br>

## 📂 View

### 1) MainView.swift

- MainView는 앱의 전체적인 메인 인터페이스 역할을 하는 뷰입니다.
- 하단 탭을 통해 MarketView와 BookmarkView를 전환할 수 있는 탭 네비게이션을 제공합니다.
- 상단에는 검색 바가 포함되어 있어 사용자가 검색어를 입력할 수 있으며, 각 뷰는 검색 결과에 따라 필터링된 암호화폐 목록을 보여줍니다.

### 2) TabView.swift

- TabView는 MarketView와 BookmarkView를 이동할 수 있는 탭 네비게이션 역할을 하는 뷰입니다.
- 검색 바 하단에 고정되어 있어 사용자가 손쉽게 화면을 전환할 수 있도록 돕습니다.

### 3) SortView.swift

- SortView는 MarketView에서 암호화폐 목록을 정렬할 때 사용하는 옵션을 제공하는 뷰입니다.
- 현재가, 변동률, 거래대금 등의 정렬 기준을 설정할 수 있으며, 각 기준에 따라 오름차순/내림차순 정렬을 할 수 있도록 UI를 제공합니다.

### 4) MarketView.swift

- MarketView는 모든 암호화폐 목록을 표시하는 뷰로, 최신 데이터를 기반으로 시세 정보를 제공합니다.
- 리스트 형태로 각 암호화폐의 정보(현재가, 변동률 등)를 TickerView를 통해 보여주며, 즐겨찾기 추가 기능을 제공합니다.
- 검색어 입력을 통해 실시간으로 목록을 필터링하며, 정렬 기준을 변경할 수 있습니다.

### 5) BookmarkView.swift 
- BookmarkView는 사용자가 즐겨찾기로 추가한 암호화폐 목록을 보여주는 뷰입니다.
- 검색어를 기반으로 즐겨찾기 목록을 필터링하여 표시하며, 각 암호화폐의 정보를 보여주는 TickerView를 포함합니다.
- 즐겨찾기 목록에서 암호화폐를 제거할 수 있으며, 제거 시 ToastView를 사용해 알림 메시지를 제공합니다.

### 6) TickerView.swift

- TickerView는 각 암호화폐의 시세 정보를 표시하는 단일 행 뷰입니다.
- 암호화폐의 이름, 현재가, 변동률, 거래대금 등의 정보를 보여주며, 즐겨찾기를 추가/제거하는 버튼을 포함합니다.
- 실시간으로 데이터를 업데이트하며, 현재가 변동에 따라 색상 변화를 주는 등 시각적인 피드백을 제공합니다.

### 7) ToastView.swift

- ToastView는 즐겨찾기 추가/삭제 시 사용자가 변경 사항을 알 수 있도록 알림을 제공하는 뷰입니다.
- BookmarkView와 MarketView에서 즐겨찾기 상태가 변경될 때 짧은 시간 동안 화면에 메시지를 표시해 줍니다.
- UI/UX를 고려하여 메시지는 일정 시간 후 자동으로 사라지도록 애니메이션을 적용할 수 있습니다.

<br>
