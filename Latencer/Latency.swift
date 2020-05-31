//
//  Latency.swift
//  Latencer
//
//  Created by Sai Vittal B on 20/05/2020.
//  Copyright © 2020 Sai Vittal B. All rights reserved.
//

import Cocoa

class Latency {
    static let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength);
    
    static func run() {
        item.button?.title = "0";
        item.menu = createMenu();
        ping();
    }
    
    static func createMenu() -> NSMenu {
        let menu = NSMenu();
        
        let donate = NSMenuItem(title: "Donate", action: #selector(self.donate), keyEquivalent: "");
        donate.target = self;
        menu.addItem(donate);
        
        let separator = NSMenuItem.separator();
        menu.addItem(separator);
        
        let quit = NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "");
        quit.target = self;
        menu.addItem(quit);
        
        return menu;
    }
    
    @objc static func donate() {
        let url = URL(string: "https://www.paypal.me/saivittalb33")!;
        NSWorkspace.shared.open(url);
    }
    
    @objc static func quit() {
        NSApplication.shared.terminate(nil);
    }
    
    static func ping() {
        let regex = try! NSRegularExpression(pattern: "time=[0-9\\.]+ ms");
        
        let onOutput = {(text: String) in
            if let result = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                
                let range = NSMakeRange(result.range.location + 5, result.range.length - 5 - 3);
                
                var latency = Float((text as NSString).substring(with: range))!
                latency = min(999, max(10, round(latency / 10) * 10));
                
                item.button?.title = String(format: "%.0f", round(latency));
            }
            else {
                item.button?.title = "0";
            }
        }
        
        let onError = {(text: String) in
            let _ = text;
            item.button?.title = "0";
        }
        
        runCommand("/sbin/ping", ["-i 0.5", "8.8.8.8"], onOutput, onError);
    }
    
    static func runCommand(_ cmd: String, _ args: [String], _ onOutput: @escaping (String) -> Void, _ onError: @escaping (String) -> Void) {
        
        let process = Process();
        process.launchPath = cmd;
        process.arguments = args;
        
        let output = Pipe();
        process.standardOutput = output;
        output.fileHandleForReading.readabilityHandler = { file in
            let data = file.availableData;
            
            if let output = String(data: data, encoding: .ascii) {
                DispatchQueue.main.async {
                    onOutput(output);
                }
            }
        }
        
        let error = Pipe();
        process.standardError = error;
        error.fileHandleForReading.readabilityHandler = { file in
            let data = file.availableData;
            
            if let output = String(data: data, encoding: .ascii) {
                DispatchQueue.main.async {
                    onError(output);
                }
            }
        }
        
        process.launch();
    }
}
