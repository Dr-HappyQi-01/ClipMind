import SwiftUI
import AppKit
import Combine

struct ClipDisplayItem: Identifiable, Hashable {
    let id: String
    let text: String
}

struct ContentView: View {
    @State private var query: String = ""
    @State private var results: [ClipDisplayItem] = []
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
                    let raw = bridge.allItems()
                    results = mapBridgeResults(raw)
                }
                Button("Clear All") {
                    bridge.deleteAllItems()
                    results = []
                    clipboardPreview = "No clipboard text captured yet"
                }
            }

            GroupBox("Latest Clipboard Text") {
                Text(clipboardPreview)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }

            List {
                ForEach(results) { item in
                    Text(item.text)
                        .textSelection(.enabled)
                }
                .onDelete(perform: deleteItems)
            }

            Spacer()
        }
        .padding()
        .frame(width: 720, height: 520)
        .onAppear {
            let raw = bridge.allItems()
            results = mapBridgeResults(raw)
            captureClipboardIfNeeded(force: true)
        }
        .onReceive(pollTimer) { _ in
            captureClipboardIfNeeded(force: false)
        }
    }

    private func runSearch() {
        let raw = bridge.search(withQuery: query)
        results = mapBridgeResults(raw)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = results[index]
            bridge.deleteItem(withId: item.id)
        }

        if query.isEmpty {
            results = mapBridgeResults(bridge.allItems())
        } else {
            runSearch()
        }
    }
    
    private func mapBridgeResults(_ rawItems: [[AnyHashable: Any]]) -> [ClipDisplayItem] {
        rawItems.compactMap { item in
            guard
                let id = item["id"] as? String,
                let text = item["text"] as? String
            else {
                return nil
            }

            return ClipDisplayItem(id: id, text: text)
        }
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
            let raw = bridge.allItems()
            results = mapBridgeResults(raw)
        } else {
            runSearch()
        }
    }
}

#Preview {
    ContentView()
}
