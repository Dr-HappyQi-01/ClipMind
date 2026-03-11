import SwiftUI
import AppKit
import Combine

struct ContentView: View {
    @State private var query: String = ""
    @State private var results: [String] = []
    @State private var clipboardPreview: String = "No clipboard text captured yet"
    @State private var lastChangeCount: Int = NSPasteboard.general.changeCount

    private let bridge = SearchEngineBridge()
    private let pollTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ClipMind")
                .font(.largeTitle)
                .bold()

            Text("Local clipboard search prototype")
                .foregroundStyle(.secondary)

            TextField("Search your clips...", text: $query)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    runSearch()
                }

            HStack(spacing: 12) {
                Button("Search") {
                    runSearch()
                }

                Button("Show All") {
                    results = bridge.allItems()
                }
            }

            GroupBox("Latest Clipboard Text") {
                Text(clipboardPreview)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }

            List(results, id: \.self) { item in
                Text(item)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding()
        .frame(width: 720, height: 520)
        .onAppear {
            results = bridge.allItems()
            captureClipboardIfNeeded(force: true)
        }
        .onReceive(pollTimer) { _ in
            captureClipboardIfNeeded(force: false)
        }
    }

    private func runSearch() {
        results = bridge.search(withQuery: query)
    }

    private func captureClipboardIfNeeded(force: Bool) {
        let pasteboard = NSPasteboard.general
        guard force || pasteboard.changeCount != lastChangeCount else {
            return
        }

        lastChangeCount = pasteboard.changeCount

        guard let text = pasteboard.string(forType: .string) else {
            return
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        clipboardPreview = trimmed
        let identifier = "clipboard-\(pasteboard.changeCount)"
        bridge.addItem(withId: identifier, source: "Clipboard", text: trimmed)

        if query.isEmpty {
            results = bridge.allItems()
        } else {
            runSearch()
        }
    }
}

#Preview {
    ContentView()
}
