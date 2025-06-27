import SwiftUI

struct FloatingSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: () -> Content

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                VStack {
                    Spacer()
                    VStack {
                        content()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.systemGray5))
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 500)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .frame(maxHeight: .infinity, alignment: .bottom)
                //.ignoresSafeArea()
            }
        }
    }
}

// Пример кастомного контента для выбора валюты
struct CurrencySheetContent: View {
    var onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Валюта")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 8)

            Divider()

            Button {
                onSelect("RUB")
            } label: {
                Text("Российский рубль ₽")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.navigation)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .contentShape(Rectangle())
            }
            .background(Color.clear)

            Divider()

            Button {
                onSelect("USD")
            } label: {
                Text("Американский доллар $")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.navigation)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .contentShape(Rectangle())
            }
            .background(Color.clear)

            Divider()

            Button {
                onSelect("EUR")
            } label: {
                Text("Евро €")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.navigation)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .contentShape(Rectangle())
            }
            .background(Color.clear)
        }
    }
}

// Превью и пример использования
struct FloatingSheet_Previews: PreviewProvider {
    struct Demo: View {
        @State private var showSheet = true
        @State private var selected: String? = nil

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                VStack {
                    Text("Выбрано: \(selected ?? "-")")
                        .font(.title2)
                    Button("Показать sheet") {
                        showSheet = true
                    }
                }
                if showSheet {
                    FloatingSheet(isPresented: $showSheet) {
                        CurrencySheetContent { code in
                            selected = code
                            showSheet = false
                        }
                    }
                }
            }
        }
    }
    static var previews: some View {
        Demo()
    }
}
