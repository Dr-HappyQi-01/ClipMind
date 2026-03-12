//
//  DatabaseManager.hpp
//  ClipMind
//
//  Created by HappyQi on 2026/3/12.
//

#pragma once

#include <string>
#include <vector>

struct ClipRecord {
    std::string id;
    std::string source;
    std::string text;
    long long createdAt;
};

class DatabaseManager {
public:
    DatabaseManager();

    bool initialize();
    bool upsertClip(const std::string& id,
                    const std::string& source,
                    const std::string& text,
                    long long createdAt);

    std::vector<ClipRecord> fetchAllClips() const;
    std::vector<ClipRecord> searchClips(const std::string& query) const;
    bool deleteClip(const std::string& id);
    bool deleteAllClips();

private:
    std::string databasePath() const;
};


