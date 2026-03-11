//
//  SearchEngine.cpp
//  ClipMind
//
//  Created by HappyQi on 2026/3/11.
//

#include "SearchEngine.hpp"

#include <algorithm>
#include <cctype>

namespace {
std::string toLowerCopy(const std::string& value) {
    std::string lowered = value;
    std::transform(lowered.begin(), lowered.end(), lowered.begin(), [](unsigned char ch) {
        return static_cast<char>(std::tolower(ch));
    });
    return lowered;
}
}

SearchEngine::SearchEngine() {
    items_.push_back({"welcome-1", "System", "Welcome to ClipMind"});
    items_.push_back({"welcome-2", "Hint", "Copy any text on your Mac and it will appear here."});
}

void SearchEngine::addOrUpdateItem(const std::string& id,
                                   const std::string& source,
                                   const std::string& text) {
    if (id.empty() || text.empty()) {
        return;
    }

    auto existing = std::find_if(items_.begin(), items_.end(), [&](const SearchItem& item) {
        return item.id == id;
    });

    if (existing != items_.end()) {
        existing->source = source;
        existing->text = text;
        return;
    }

    items_.insert(items_.begin(), {id, source, text});
}

std::vector<std::string> SearchEngine::search(const std::string& query) const {
    if (query.empty()) {
        return allItems();
    }

    const std::string loweredQuery = toLowerCopy(query);
    std::vector<std::string> results;

    for (const auto& item : items_) {
        const std::string haystack = toLowerCopy(item.source + " " + item.text);
        if (haystack.find(loweredQuery) != std::string::npos) {
            results.push_back("[" + item.source + "] " + item.text);
        }
    }

    return results;
}

std::vector<std::string> SearchEngine::allItems() const {
    std::vector<std::string> results;
    results.reserve(items_.size());

    for (const auto& item : items_) {
        results.push_back("[" + item.source + "] " + item.text);
    }

    return results;
}
