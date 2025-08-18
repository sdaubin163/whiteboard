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
// - NotePersistenceManager: 笔记持久化管理器，处理笔记的保存和加载
// - ProxyManager: 代理管理器，处理全局HTTP代理设置

// 功能说明:
// - 全局快捷键: Option+Esc 切换应用显示/隐藏
// - 菜单栏模式: 应用隐藏时在菜单栏显示图标
// - 程序坞控制: 隐藏时从程序坞移除，显示时恢复
// - 笔记管理: 处理笔记的增删改查和持久化存储
// - 代理设置: 配置全局HTTP/HTTPS/SOCKS5代理