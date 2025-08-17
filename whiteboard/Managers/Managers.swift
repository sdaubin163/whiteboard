// 
// Managers.swift
// whiteboard
//
// 管理器模块索引文件
//

import Foundation

// MARK: - 管理器模块导出
// 这个文件作为管理器模块的统一入口点

// 可用管理器:
// - AppStateManager: 应用状态管理器，控制窗口显示/隐藏和菜单栏模式
// - GlobalHotKeyManager: 全局快捷键管理器，处理 Option+Esc 快捷键
// - MenuBarManager: 菜单栏管理器，处理菜单栏图标和菜单

// 功能说明:
// - 全局快捷键: Option+Esc 切换应用显示/隐藏
// - 菜单栏模式: 应用隐藏时在菜单栏显示图标
// - 程序坞控制: 隐藏时从程序坞移除，显示时恢复