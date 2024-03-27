//
//  ContentView.swift
//  Droplet
//
//  Created by Irlan Abushakhmanov on 27.03.2024.
//

import SwiftUI

struct ContentView: View {
    private enum Constants {
        static let treshold = GraphicsContext.Filter.alphaThreshold(min: 0.5)
        static let blur = GraphicsContext.Filter.blur(radius: circleRadius / 2)
        static let circleRadius = 75.0
        static let circleSize = CGSize(width: circleRadius * 2, height: circleRadius * 2)
        static let firstCirceId = UUID()
        static let secondCirceId = UUID()
    }

    @State private var offset = CGSize.zero

    private let screenMiddlePoint = CGPoint(x: bounds.midX, y: bounds.midY)
    private let gradient = RadialGradient(
        gradient: Gradient(colors: [.yellow, .red]),
        center: .center,
        startRadius: Constants.circleRadius,
        endRadius: Constants.circleRadius * 2
    )

    var body: some View {
        Rectangle()
            .fill(gradient)
            .mask { canvas }
            .overlay { weatherImage }
            .gesture(gesture)
            .ignoresSafeArea()
            .background(.black)
    }

    private var canvas: Canvas<some View> {
        Canvas { context, _ in
            guard
                let symbol = context.resolveSymbol(id: Constants.firstCirceId),
                let constantSymbol = context.resolveSymbol(id: Constants.secondCirceId)
            else {
                return
            }
            context.addFilter(Constants.treshold)
            context.addFilter(Constants.blur)

            context.drawLayer { context in
                context.draw(symbol, at: screenMiddlePoint)
                context.draw(constantSymbol, at: screenMiddlePoint)
            }
        } symbols: {
            Circle()
                .frame(width: Constants.circleSize.width, height: Constants.circleSize.height)
                .offset(x: offset.width, y: offset.height)
                .tag(Constants.firstCirceId)

            Circle()
                .frame(width: Constants.circleSize.width, height: Constants.circleSize.height)
                .tag(Constants.secondCirceId)
        }
    }

    private var weatherImage: some View {
        Image(systemName: "cloud.sun.rain.fill")
            .symbolRenderingMode(.hierarchical)
            .font(.largeTitle)
            .foregroundStyle(.white)
            .offset(x: offset.width, y: offset.height)
    }

    private var gesture: some Gesture {
        DragGesture()
        .onChanged {
            offset = $0.translation
        }
        .onEnded { _ in
            withAnimation(.bouncy(extraBounce: 0.1)) {
                offset = .zero
            }
        }
    }
}

private let bounds = UIScreen.main.bounds

#Preview {
    ContentView()
}
