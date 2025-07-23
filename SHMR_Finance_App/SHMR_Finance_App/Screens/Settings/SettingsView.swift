//
//  SettingsView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI

struct AppStrings {
    static func title(_ key: String, lang: String) -> String {
        let ru: [String: String] = [
            "settings": "Настройки",
            "theme": "Тёмная тема",
            "language": "Язык",
            "appearance": "ВНЕШНИЙ ВИД",
            "general": "ОБЩЕЕ"
        ]
        let en: [String: String] = [
            "settings": "Settings",
            "theme": "Dark theme",
            "language": "Language",
            "appearance": "APPEARANCE",
            "general": "GENERAL"
        ]
        switch lang {
        case "en": return en[key] ?? key
        default: return ru[key] ?? key
        }
    }
}

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = Locale.current.languageCode ?? "ru"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(AppStrings.title("appearance", lang: appLanguage)).font(.caption).foregroundColor(.gray)) {
                    Toggle(AppStrings.title("theme", lang: appLanguage), isOn: $isDarkMode)
                }
                Section(header: Text(AppStrings.title("general", lang: appLanguage)).font(.caption).foregroundColor(.gray)) {
                    Picker(AppStrings.title("language", lang: appLanguage), selection: $appLanguage) {
                        Text("Русский").tag("ru")
                        Text("English").tag("en")
                    }
                }
            }
            .navigationTitle(AppStrings.title("settings", lang: appLanguage))
        }
    }
}

#Preview {
    SettingsView()
}
