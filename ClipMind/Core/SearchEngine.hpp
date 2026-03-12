//
//  SearchEngine.hpp
//  ClipMind
//
//  Created by HappyQi on 2026/3/11.
//

#pragma once

#include <string>
#include <vector>

#include "DatabaseManager.hpp"

struct DisplayItem {
    std::string id;
    std::string displayText;
};

class SearchEngine {
public:
    SearchEngine();

    void addOrUpdateItem(const std::string& id,
                         const std::string& source,
                         const std::string& text);

    std::vector<DisplayItem> search(const std::string& query) const;
    std::vector<DisplayItem> allItems() const;
    void deleteItem(const std::string& id);
    void deleteAllItems();

private:
    DatabaseManager database_;
};
