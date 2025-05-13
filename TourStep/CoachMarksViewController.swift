import SwiftUI

// MARK: - Walkthrough Data Model
struct WalkthroughData: Identifiable {
    let id: String
    let title: String
    let description: String
}

// MARK: - PreferenceKey
struct WalkthroughElementPreferenceKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    func walkthroughElement(_ id: String) -> some View {
        self.anchorPreference(key: WalkthroughElementPreferenceKey.self, value: .bounds) { anchor in
            [id: anchor]
        }
    }
}

// MARK: - Main ContentView
struct ContentView: View {
    @State private var isWalkthroughActive = false
    @State private var currentStepIndex = 0
    @State private var searchText = ""
    
    private let walkthroughSteps: [WalkthroughData] = [
        WalkthroughData(id: "helpButton", title: "Help Button", description: "Home Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
        WalkthroughData(id: "filterButton", title: "Filter Button", description: "Tap here to filter the content."),
        WalkthroughData(id: "searchBar", title: "Search Bar", description: "Type keywords to search through the content."),
        WalkthroughData(id: "contentArea", title: "Content Area", description: "Browse the available items here."),
        WalkthroughData(id: "actionButton", title: "Action Button", description: "Tap here for more actions.")
    ]
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    HStack {
                        Button(action: {
                            isWalkthroughActive = true
                            currentStepIndex = 0
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.title)
                        }
                        .walkthroughElement("helpButton")
                        
                        Spacer()
                        
                        Button("Filter") {
                            
                        }
                        .walkthroughElement("filterButton")
                    }
                    .padding()
                    
                    HStack {
                        TextField("Search...", text: $searchText)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    }
                    .padding(.horizontal)
                    .walkthroughElement("searchBar")
                    
                    ScrollView {
                        VStack {
                            ForEach(0..<20) { index in
                                Text("Content item \(index)")
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(white: 0.95))
                                    .cornerRadius(8)
                                    .padding(.vertical, 4)
                            }
                        }
                        .padding()
                    }
                    .walkthroughElement("contentArea")
                    
                    Button("Action") {}
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .walkthroughElement("actionButton")
                    
                    Spacer()
                }
                .disabled(isWalkthroughActive)
                
                if isWalkthroughActive {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                }
            }
            .overlayPreferenceValue(WalkthroughElementPreferenceKey.self) { preferences in
                GeometryReader { innerProxy in
                    if isWalkthroughActive, currentStepIndex < walkthroughSteps.count,
                       let anchor = preferences[walkthroughSteps[currentStepIndex].id] {
                        let targetFrame = innerProxy[anchor]
                        
                        WalkthroughTooltipView(
                            containerSize: innerProxy.size,
                            targetFrame: targetFrame,
                            title: walkthroughSteps[currentStepIndex].title,
                            description: walkthroughSteps[currentStepIndex].description,
                            isLastStep: currentStepIndex == walkthroughSteps.count - 1,
                            onNext: {
                                //withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                                if currentStepIndex < walkthroughSteps.count - 1 {
                                    currentStepIndex += 1
                                } else {
                                    isWalkthroughActive = false
                                }
                                // }
                            },
                            onPrevious: {
                                //withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                                if currentStepIndex > 0 {
                                    currentStepIndex -= 1
                                }
                                //                                }
                            },
                            onSkip: {
                                isWalkthroughActive = false
                            },
                            stepIndex: currentStepIndex,
                            totalSteps: walkthroughSteps.count
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Tooltip View with Dynamic Height
struct WalkthroughTooltipView: View {
    var containerSize: CGSize
    var targetFrame: CGRect
    var title: String
    var description: String
    var isLastStep: Bool
    var onNext: () -> Void
    var onPrevious: () -> Void
    var onSkip: () -> Void
    var stepIndex: Int
    var totalSteps: Int
    @State private var isVisible = false
    @State private var contentHeight: CGFloat = .zero
    
    var body: some View {
        let arrowHeight: CGFloat = 10
        let arrowWidth: CGFloat = 20
        let bubbleWidth: CGFloat = 400
        
        let topMargin: CGFloat = 10
        let bottomMargin: CGFloat = 10
        let requiredHeight = contentHeight + arrowHeight
        
        let availableSpaceAbove = targetFrame.minY - topMargin
        let availableSpaceBelow = containerSize.height - targetFrame.maxY - bottomMargin
        
        let showAbove: Bool
        if availableSpaceBelow >= requiredHeight {
            showAbove = false
        } else if availableSpaceAbove >= requiredHeight {
            showAbove = true
        } else {
            showAbove = availableSpaceAbove > availableSpaceBelow
        }
        
        var bubbleX = targetFrame.midX - bubbleWidth / 2
        bubbleX = max(10, min(bubbleX, containerSize.width - bubbleWidth - 10))
        let arrowOffset = min(max(targetFrame.midX - bubbleX - arrowWidth / 2, 10),
                              bubbleWidth - arrowWidth - 10)
        
        let totalHeight = contentHeight + arrowHeight
        let viewY: CGFloat = showAbove ?
        (targetFrame.minY - topMargin - totalHeight / 2) :
        (targetFrame.maxY + bottomMargin + totalHeight / 2)
        
        let computedPosition = CGPoint(x: bubbleX + bubbleWidth / 2, y: viewY)
        
        return VStack(spacing: 0) {
            if !showAbove {
                ArrowView()
                    .frame(width: arrowWidth, height: arrowHeight)
                    .offset(x: arrowOffset - bubbleWidth / 2 + arrowWidth / 2)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("\(stepIndex + 1) / \(totalSteps)")
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                        Button(action: onSkip) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                    }
                }
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Button("Skip", action: onSkip)
                        .frame(minWidth: 70)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundColor(.blue)
                        .overlay(Capsule().stroke(Color.blue, lineWidth: 1))
                    
                    Spacer()
                    
                    if stepIndex > 0 {
                        Button("Back", action: onPrevious)
                            .frame(minWidth: 70)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Button(isLastStep ? "Done" : "Next", action: onNext)
                        .frame(minWidth: 70)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .frame(width: bubbleWidth)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        contentHeight = geo.size.height
                    }
                }
            )
            
            if showAbove {
                ArrowView()
                    .frame(width: arrowWidth, height: arrowHeight)
                    .rotationEffect(.degrees(180))
                    .offset(x: arrowOffset - bubbleWidth / 2 + arrowWidth / 2)
            }
        }
        .position(computedPosition)
        //        .scaleEffect(isVisible ? 1 : 0.8)
        //        .opacity(isVisible ? 1 : 0)
        //        .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: isVisible)
        //        .onAppear {
        //            isVisible = true
        //        }
    }
}

// MARK: - Arrow
struct ArrowView: View {
    var body: some View {
        Triangle().fill(Color.white)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
