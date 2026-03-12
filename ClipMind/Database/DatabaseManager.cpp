//
//  DatabaseManager.cpp
//  ClipMind
//
//  Created by HappyQi on 2026/3/12.
//

#include "DatabaseManager.hpp"

#include <sqlite3.h>

#include <cstdlib>
#include <filesystem>

namespace {
const char* kCreateTableSQL =
    "CREATE TABLE IF NOT EXISTS clips ("
    "id TEXT PRIMARY KEY, "
    "source TEXT NOT NULL, "
    "text TEXT NOT NULL, "
    "created_at INTEGER NOT NULL"
    ");";
}

DatabaseManager::DatabaseManager() {}

std::string DatabaseManager::databasePath() const {
    const char* home = std::getenv("HOME");
    if (!home) {
        return "clipmind.db";
    }

    std::filesystem::path dir = std::filesystem::path(home) /
                                "Library" /
                                "Application Support" /
                                "ClipMind";

    std::filesystem::create_directories(dir);

    return (dir / "clipmind.db").string();
}

bool DatabaseManager::initialize() {
    sqlite3* db = nullptr;
    if (sqlite3_open(databasePath().c_str(), &db) != SQLITE_OK) {
        if (db) sqlite3_close(db);
        return false;
    }

    char* errorMessage = nullptr;
    int rc = sqlite3_exec(db, kCreateTableSQL, nullptr, nullptr, &errorMessage);

    if (errorMessage) {
        sqlite3_free(errorMessage);
    }

    sqlite3_close(db);
    return rc == SQLITE_OK;
}

bool DatabaseManager::upsertClip(const std::string& id,
                                 const std::string& source,
                                 const std::string& text,
                                 long long createdAt) {
    sqlite3* db = nullptr;
    if (sqlite3_open(databasePath().c_str(), &db) != SQLITE_OK) {
        if (db) sqlite3_close(db);
        return false;
    }

    const char* sql =
        "INSERT OR REPLACE INTO clips (id, source, text, created_at) "
        "VALUES (?, ?, ?, ?);";//占位符

    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        sqlite3_close(db);
        return false;
    }

    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, source.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, text.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 4, createdAt);

    bool success = sqlite3_step(stmt) == SQLITE_DONE;

    sqlite3_finalize(stmt);
    sqlite3_close(db);

    return success;
}

std::vector<ClipRecord> DatabaseManager::fetchAllClips() const {
    sqlite3* db = nullptr;
    std::vector<ClipRecord> results;

    if (sqlite3_open(databasePath().c_str(), &db) != SQLITE_OK) {
        if (db) sqlite3_close(db);
        return results;
    }

    const char* sql =
        "SELECT id, source, text, created_at "
        "FROM clips "
        "ORDER BY created_at DESC;";

    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        sqlite3_close(db);
        return results;
    }

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        ClipRecord record;
        record.id = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0));
        record.source = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));
        record.text = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2));
        record.createdAt = sqlite3_column_int64(stmt, 3);
        results.push_back(record);
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);

    return results;
}

std::vector<ClipRecord> DatabaseManager::searchClips(const std::string& query) const {
    sqlite3* db = nullptr;
    std::vector<ClipRecord> results;

    if (sqlite3_open(databasePath().c_str(), &db) != SQLITE_OK) {
        if (db) sqlite3_close(db);
        return results;
    }

    const char* sql =
        "SELECT id, source, text, created_at "
        "FROM clips "
        "WHERE source LIKE ? OR text LIKE ? "
        "ORDER BY created_at DESC;";

    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        sqlite3_close(db);
        return results;
    }

    std::string pattern = "%" + query + "%";
    sqlite3_bind_text(stmt, 1, pattern.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, pattern.c_str(), -1, SQLITE_TRANSIENT);

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        ClipRecord record;
        record.id = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0));
        record.source = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));
        record.text = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2));
        record.createdAt = sqlite3_column_int64(stmt, 3);
        results.push_back(record);
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);

    return results;
}

bool DatabaseManager::deleteClip(const std::string& id) {
    sqlite3* db = nullptr;
    if (sqlite3_open(databasePath().c_str(), &db) != SQLITE_OK) {
        if (db) sqlite3_close(db);
        return false;
    }
    
    const char* sql =
        "DELETE FROM clips "
        "WHERE id = ?;";
    
    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_TRANSIENT);
    
    bool success = sqlite3_step(stmt) == SQLITE_DONE;
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
    return success;
}

bool DatabaseManager::deleteAllClips() {
    sqlite3* db = nullptr;
    if (sqlite3_open(databasePath().c_str(), &db) != SQLITE_OK) {
        if (db) sqlite3_close(db);
        return false;
    }

    const char* sql = "DELETE FROM clips;";
    char* errorMessage = nullptr;

    int rc = sqlite3_exec(db, sql, nullptr, nullptr, &errorMessage);

    if (errorMessage) {
        sqlite3_free(errorMessage);
    }

    sqlite3_close(db);

    return rc == SQLITE_OK;
}
