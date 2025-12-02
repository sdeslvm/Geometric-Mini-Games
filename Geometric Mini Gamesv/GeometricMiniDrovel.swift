import Foundation
import SwiftUI

struct GeometricMiniEntryScreen: View {
    @StateObject private var loader: GeometricMiniWebLoader

    init(loader: GeometricMiniWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            GeometricMiniWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                GeometricMiniProgressIndicator(value: percent)
            case .failure(let err):
                GeometricMiniErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                GeometricMiniOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct GeometricMiniProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            GeometricMiniLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct GeometricMiniErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct GeometricMiniOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}

