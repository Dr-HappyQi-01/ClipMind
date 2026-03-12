//
//  SearchEngine.cpp
//  ClipMind
//
//  Created by HappyQi on 2026/3/11.
//

#include "SearchEngine.hpp"

#include <ctime>

SearchEngine::SearchEngine() {
    database_.initialize();

    if (database_.fetchAllClips().empty()) {
        database_.upsertClip("welcome-1",
                             "System",
                             "Welcome to ClipMind",
                             std::time(nullptr));

        database_.upsertClip("welcome-2",
                             "Hint",
                             "Copy any text on your Mac and it will appear here.",
                             std::time(nullptr) + 1);
    }
}

void SearchEngine::addOrUpdateItem(const std::string& id,
                                   const std::string& source,
                                   const std::string& text) {
    if (id.empty() || text.empty()) {
        return;
    }

    database_.upsertClip(id, source, text, std::time(nullptr));
}

std::vector<DisplayItem> SearchEngine::search(const std::string& query) const {
    std::vector<DisplayItem> results;
    std::vector<ClipRecord> records;

    if (query.empty()) {
        records = database_.fetchAllClips();
    } else {
        records = database_.searchClips(query);
    }

    for (const auto& item : records) {
        results.push_back({item.id, "[" + item.source + "] " + item.text});
    }

    return results;
}

std::vector<DisplayItem> SearchEngine::allItems() const {
    std::vector<DisplayItem> results;
    std::vector<ClipRecord> records = database_.fetchAllClips();

    for (const auto& item : records) {
        results.push_back({item.id, "[" + item.source + "] " + item.text});
    }

    return results;
}

void SearchEngine::deleteItem(const std::string& id) {
    if (id.empty()) {
        return;
    }
    
    database_.deleteClip(id);
}

void SearchEngine::deleteAllItems() {
    database_.deleteAllClips();
}
