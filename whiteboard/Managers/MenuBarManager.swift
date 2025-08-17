import Foundation
import AppKit
import SwiftUI

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private weak var appDelegate: AppDelegate?
    
    var toggleCallback: (() -> Void)?
    
    init(appDelegate: AppDelegate?) {
        self.appDelegate = appDelegate
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem else { return }
        
        // 设置图标
        if let button = statusItem.button {
            // 使用应用图标或者默认图标
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "智能工作台")
            button.image?.size = NSSize(width: 18, height: 18)
            button.image?.isTemplate = true
            
            // 设置工具提示
            button.toolTip = "智能工作台 - 点击显示/隐藏窗口"
            
            // 设置点击动作
            button.action = #selector(toggleWindow)
            button.target = self
        }
        
        // 创建菜单
        let menu = NSMenu()
        
        // 显示/隐藏窗口
        let toggleItem = NSMenuItem(title: "显示/隐藏窗口", action: #selector(toggleWindow), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 偏好设置
        let preferencesItem = NSMenuItem(title: "偏好设置...", action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 关于
        let aboutItem = NSMenuItem(title: "关于智能工作台", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        // 退出
        let quitItem = NSMenuItem(title: "退出智能工作台", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        // 右键菜单
        statusItem.menu = menu
    }
    
    @objc private func toggleWindow() {
        toggleCallback?()
    }
    
    @objc private func openPreferences() {
        // 打开偏好设置窗口（暂时显示关于对话框）
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    @objc private func quitApp() {
        NSApp.terminate(self)
    }
    
    func updateMenuItemTitle(isWindowVisible: Bool) {
        guard let statusItem = statusItem,
              let menu = statusItem.menu,
              let toggleItem = menu.item(at: 0) else { return }
        
        toggleItem.title = isWindowVisible ? "隐藏窗口" : "显示窗口"
    }
    
    deinit {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}