import SwiftUI

extension ContentView {
    var navy: Color { Color(red: 0.16, green: 0.20, blue: 0.34) }

    // MARK: - Playback controls

    var controlBar: some View {
        VStack(spacing: 10) {
            // TODO: re-enable playlist button once per-segment tracks are done
            // HStack {
            //     Spacer()
            //     Button { vm.showQueue = true } label: {
            //         Image(systemName: "list.bullet")
            //             .font(.system(size: 16, weight: .medium))
            //             .foregroundStyle(navy.opacity(0.7))
            //             .frame(width: 32, height: 32)
            //             .background(Circle().fill(.white.opacity(0.85)))
            //             .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
            //     }
            // }
            // .padding(.horizontal, 24)

            HStack {
                Spacer()

                Button { vm.goBack() } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(navy)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Button { vm.togglePlay(bgMusic: bgMusic) } label: {
                    ZStack {
                        Circle()
                            .strokeBorder(vm.theme.accent, lineWidth: 2)
                            .frame(width: 52, height: 52)
                        Circle()
                            .fill(.white)
                            .frame(width: 46, height: 46)
                            .shadow(color: .black.opacity(0.14), radius: 8, y: 3)
                        Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(navy)
                            .offset(x: vm.isPlaying ? 0 : 2)
                    }
                }

                Spacer()

                Button { vm.goNext() } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(navy)
                        .frame(width: 44, height: 44)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.white.opacity(0.85)))
            .shadow(color: .black.opacity(0.10), radius: 10, y: 4)
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $vm.showQueue) {
            QueueSheet(
                rosary: vm.rosary,
                currentBead: vm.currentBead,
                onSelect: { beadIndex in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        vm.currentBead = beadIndex
                        vm.currentPrayer = 0
                        vm.currentText = 0
                    }
                    vm.showQueue = false
                },
                onStop: {
                    vm.showQueue = false
                    dismiss()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Close button

    var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(navy)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.white.opacity(0.85)))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        }
        .accessibilityLabel("Back to home")
    }

    // MARK: - Zoom toggle

    var zoomToggle: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    rosaryZoom = min(3.0, rosaryZoom + 0.25)
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(rosaryZoom >= 3.0 ? navy.opacity(0.3) : navy)
                    .frame(width: 36, height: 34)
            }
            .disabled(rosaryZoom >= 3.0)

            Rectangle()
                .fill(navy.opacity(0.15))
                .frame(width: 20, height: 1)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    rosaryZoom = max(0.5, rosaryZoom - 0.25)
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(rosaryZoom <= 0.5 ? navy.opacity(0.3) : navy)
                    .frame(width: 36, height: 34)
            }
            .disabled(rosaryZoom <= 0.5)
        }
        .background(Capsule().fill(.white.opacity(0.85)))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }

    // MARK: - Prayer card (liquid glass, legacy)

    func prayerCard(glass: Bool = true) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(glass ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(.white.opacity(glass ? 0.45 : 0), lineWidth: 1)
                )
                .shadow(color: .black.opacity(glass ? 0.08 : 0), radius: 12, y: 4)

            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 8) {
                    Text(vm.prayer?.title ?? "")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(navy)

                    if let step = vm.bead.decadeStep, let total = vm.bead.totalSteps {
                        Text("\(step)/\(total)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(navy.opacity(0.50))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(navy.opacity(0.08)))
                    } else if let prayer = vm.prayer, prayer.texts.count > 1 {
                        Text("\(vm.currentText + 1)/\(prayer.texts.count)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(navy.opacity(0.50))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(navy.opacity(0.08)))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

                Divider().opacity(0.25).padding(.horizontal, 16)

                ScrollView(showsIndicators: false) {
                    Text(vm.prayerText)
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .foregroundStyle(navy.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .id("\(vm.currentBead)-\(vm.currentPrayer)-\(vm.currentText)")
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: vm.currentText)
            .animation(.easeInOut(duration: 0.3), value: vm.currentPrayer)
            .animation(.easeInOut(duration: 0.3), value: vm.currentBead)
        }
        .id("\(vm.currentBead)-\(vm.currentPrayer)")
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: vm.currentPrayer)
        .animation(.easeInOut(duration: 0.3), value: vm.currentBead)
    }

    // MARK: - Focused prayer card

    var focusedCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.99, green: 0.97, blue: 0.94))
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(.white, lineWidth: 2.5)
                        if showPrayerProgress {
                            BorderProgressFromTopRight(progress: vm.textProgress, cornerRadius: 22)
                                .stroke(vm.theme.accent.opacity(0.85),
                                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        }
                    }
                )
                .shadow(color: vm.theme.accent.opacity(0.30), radius: 18, x: 0, y: 0)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

            VStack(spacing: 0) {
                titleText
                    .padding(.top, 18)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                accentDivider(showResponseBadge: true).padding(.vertical, 14)

                ScrollView(showsIndicators: false) {
                    Text(vm.prayerText)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(navy.opacity(0.80))
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                }
                .frame(maxHeight: .infinity, alignment: .top)

                accentDivider().padding(.vertical, 12)
            }
            .id("\(vm.currentBead)-\(vm.currentPrayer)-\(vm.currentText)")
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: vm.currentText)
            .animation(.easeInOut(duration: 0.3), value: vm.currentPrayer)
            .animation(.easeInOut(duration: 0.3), value: vm.currentBead)
        }
        .id("\(vm.currentBead)-\(vm.currentPrayer)")
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: vm.currentPrayer)
        .animation(.easeInOut(duration: 0.3), value: vm.currentBead)
    }

    var titleText: Text {
        let base = Text(vm.prayer?.title ?? "")
            .font(.system(size: 22, weight: .semibold, design: .serif))
            .foregroundStyle(navy)
        if let step = vm.bead.decadeStep, let total = vm.bead.totalSteps {
            return base + Text("  \(step)/\(total)")
                .font(.system(size: 12, weight: .medium))
                .baselineOffset(8)
                .foregroundStyle(navy.opacity(0.42))
        } else if let p = vm.prayer, p.texts.count > 1 {
            return base + Text("  \(vm.currentText + 1)/\(p.texts.count)")
                .font(.system(size: 12, weight: .medium))
                .baselineOffset(8)
                .foregroundStyle(navy.opacity(0.42))
        }
        return base
    }

    func accentDivider(showResponseBadge: Bool = false) -> some View {
        HStack(spacing: 6) {
            Rectangle().fill(vm.theme.accent.opacity(0.30)).frame(height: 0.5)
            if showResponseBadge && vm.isResponseSegment {
                Text("Response")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(vm.theme.accent))
                    .fixedSize()
            } else {
                Rectangle()
                    .fill(vm.theme.accent.opacity(0.80))
                    .frame(width: 5, height: 5)
                    .rotationEffect(.degrees(45))
            }
            Rectangle().fill(vm.theme.accent.opacity(0.30)).frame(height: 0.5)
        }
        .padding(.horizontal, 28)
        .animation(.easeInOut(duration: 0.2), value: vm.isResponseSegment)
    }
}
