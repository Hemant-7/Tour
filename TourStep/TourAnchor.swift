//
//  TourAnchor.swift
//  TourStep
//
//  Created by Hemant kumar on 09/05/25.
//

import SwiftUI

// MARK: - Data Model
// MARK: - TourStep Model
struct TourStep: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
}

struct TourAnchorModifier: ViewModifier {
    let id: String
    @Binding var currentStep: String?
    let steps: [TourStep]

    func body(content: Content) -> some View {
        content
            .opacity(currentStep == nil || currentStep == id ? 1 : 0.3)
            .overlay(
                currentStep == id ?
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                : nil
            )
            .onTapGesture {
                currentStep = id
            }
            .popover(isPresented: Binding(
                get: { currentStep == id },
                set: { isPresented in
                    if !isPresented {
                        currentStep = nil
                    }
                })
            ) {
                if let index = steps.firstIndex(where: { $0.id == id }) {
                    let step = steps[index]
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(index + 1) of \(steps.count)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Button(action: {
                                    currentStep = nil
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.black)
                                }
                            }
                        }

                        Text(step.title)
                            .font(.title3)
                            .bold()

                        Text(step.description)
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        HStack {
                            Button("Skip") {
                                currentStep = nil
                            }
                            .frame(minWidth: 70)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundColor(.blue)
                            .overlay(
                                Capsule()
                                    .stroke(Color.blue, lineWidth: 1)
                            )

                            Spacer()

                            if index > 0 {
                                Button("Back") {
                                    currentStep = steps[index - 1].id
                                }
                                .frame(minWidth: 70)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }

                            if index < steps.count - 1 {
                                Button("Next") {
                                    currentStep = steps[index + 1].id
                                }
                                .frame(minWidth: 70)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            } else {
                                Button("Done") {
                                    currentStep = nil
                                }
                                .frame(minWidth: 70)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                    .frame(width: 480)
                    .background(Color.clear)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                    .padding()
                }
            }
    }
}

extension View {
    func tourAnchor(id: String, currentStep: Binding<String?>, steps: [TourStep]) -> some View {
        self.modifier(TourAnchorModifier(id: id, currentStep: currentStep, steps: steps))
    }
}
