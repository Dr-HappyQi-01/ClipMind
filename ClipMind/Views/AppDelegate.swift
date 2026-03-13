//
//  AppDelegate.swift
//  ClipMind
//
//  Created by HappyQi on 2026/3/13.
//

import Cocoa
import SwiftUI
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private weak var mainWindow: NSWindow?
    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyHandlerRef: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        registerGlobalHotKey()

        DispatchQueue.main.async { [weak self] in
            self?.mainWindow = NSApp.windows.first
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else {
            return
        }

        button.title = "ClipMind"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open ClipMind",
                                action: #selector(openClipMind),
                                keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Hide Window",
                                action: #selector(closeMainWindow),
                                keyEquivalent: "w"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit",
                                action: #selector(quitApp),
                                keyEquivalent: "q"))

        menu.items.forEach { $0.target = self }
        statusItem?.menu = menu
    }

    private func registerGlobalHotKey() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { _, eventRef, userData in
            guard let userData, let eventRef else {
                return noErr
            }

            let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()

            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(eventRef,
                                           EventParamName(kEventParamDirectObject),
                                           EventParamType(typeEventHotKeyID),
                                           nil,
                                           MemoryLayout<EventHotKeyID>.size,
                                           nil,
                                           &hotKeyID)

            if status == noErr && hotKeyID.id == 1 {
                DispatchQueue.main.async {
                    delegate.openClipMind()
                }
            }

            return noErr
        }

        let selfPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        InstallEventHandler(GetApplicationEventTarget(),
                            handler,
                            1,
                            &eventType,
                            selfPointer,
                            &hotKeyHandlerRef)

        let hotKeyID = EventHotKeyID(signature: OSType(0x434C4950), id: 1)

        RegisterEventHotKey(UInt32(kVK_Space),
                            UInt32(cmdKey | shiftKey),
                            hotKeyID,
                            GetApplicationEventTarget(),
                            0,
                            &hotKeyRef)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openClipMind()
        }
        return true
    }

    @objc private func openClipMind() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.unhide(nil)

        if mainWindow == nil || !(mainWindow?.isReleasedWhenClosed == false || mainWindow?.windowController != nil || mainWindow?.contentView != nil) {
            mainWindow = NSApp.windows.first
        }

        guard let window = mainWindow ?? NSApp.windows.first else {
            return
        }

        mainWindow = window
        window.collectionBehavior.remove(.transient)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    @objc private func closeMainWindow() {
        guard let window = mainWindow ?? NSApp.keyWindow ?? NSApp.windows.first else {
            return
        }

        mainWindow = window
        window.orderOut(nil)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
