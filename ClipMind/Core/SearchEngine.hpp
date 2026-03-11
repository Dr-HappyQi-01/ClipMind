//
//  SearchEngine.hpp
//  ClipMind
//
//  Created by HappyQi on 2026/3/11.
//

#pragma once

#include <string>
#include <vector>

struct SearchItem {
    std::string id;
    std::string source;
    std::string text;
};

class SearchEngine {
public:
    SearchEngine();

    void addOrUpdateItem(const std::string& id,
                         const std::string& source,
                         const std::string& text);

    std::vector<std::string> search(const std::string& query) const;
    std::vector<std::string> allItems() const;

private:
    std::vector<SearchItem> items_;
};
