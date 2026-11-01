// Test builds only (compiled with -D QT_SELFTEST by macos/selftest.sh, never into the real app).
// Once the app page loads, this clicks through it the way a person would, answers the page's
// dialogs from $QT_SELFTEST_ANSWERS, writes what happened to $QT_SELFTEST_OUT/report.json with two
// snapshots, then uses Stop Server and Quit.
#if QT_SELFTEST
  import AppKit
  import WebKit

  @MainActor
  enum SelfTest {
    static var started = false
    static var answers = (ProcessInfo.processInfo.environment["QT_SELFTEST_ANSWERS"] ?? "")
      .split(separator: "|").map(String.init)
    static var links: [String] = []
    static var dialogs: [String] = []
    static let out = URL(fileURLWithPath: ProcessInfo.processInfo.environment["QT_SELFTEST_OUT"] ?? NSTemporaryDirectory())
  }

  extension AppDelegate {
    var selfTestErrorCapture: WKUserScript {
      WKUserScript(
        source: """
          window.__qtErrors = [];
          addEventListener("error", (e) => __qtErrors.push(String(e.message)));
          addEventListener("unhandledrejection", (e) => __qtErrors.push(String(e.reason)));
          addEventListener("securitypolicyviolation", (e) => __qtErrors.push(`CSP ${e.violatedDirective} ${e.blockedURI}`));
          """, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    }

    func selfTestRecordLink(_ url: URL) { SelfTest.links.append(url.absoluteString) }

    // Answers each dialog with the next entry: text for a prompt, "ok" or "cancel" for a confirm.
    func selfTestAnswer(_ alert: NSAlert, field: NSTextField?) {
      let answer = SelfTest.answers.isEmpty ? "ok" : SelfTest.answers.removeFirst()
      SelfTest.dialogs.append("\(alert.messageText) -> \(answer)")
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        field?.stringValue = answer
        let ok = field != nil || answer != "cancel"
        self.window.endSheet(alert.window, returnCode: ok ? .alertFirstButtonReturn : .alertSecondButtonReturn)
      }
    }

    func selfTestStart() {
      // Only macos/selftest.sh sets this; without it a test build does nothing on its own.
      guard !SelfTest.started, ProcessInfo.processInfo.environment["QT_SELFTEST_OUT"] != nil else { return }
      SelfTest.started = true
      Task { await selfTestRun() }
    }

    private func js(_ body: String) async -> Any? {
      do { return try await webView.callAsyncJavaScript(body, contentWorld: .page) } catch { return "JS error: \(error)" }
    }

    private func pause(_ seconds: Double) async { try? await Task.sleep(nanoseconds: UInt64(seconds * 1e9)) }

    /// Clicks the element from script. WebKit runs callAsyncJavaScript as a user gesture, so file
    /// pickers, new windows and downloads behave as they do for a person's click. (Synthesised mouse
    /// events don't work here: a window opened in the background takes its first click to activate.)
    private func click(_ selector: String) async {
      let found = await js("const el = document.querySelector(\(json(selector))); if (!el) return false; el.click(); return true")
      if found as? Bool != true { SelfTest.dialogs.append("missing \(selector)") }
    }

    private func json(_ s: String) -> String {
      String(data: try! JSONSerialization.data(withJSONObject: [s]), encoding: .utf8)!.dropFirst().dropLast().description
    }

    private func snapshot(_ name: String) async {
      guard let image = try? await webView.takeSnapshot(configuration: nil), let tiff = image.tiffRepresentation,
        let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
      else { return }
      try? png.write(to: SelfTest.out.appendingPathComponent(name))
    }

    private func selfTestRun() async {
      var report: [String: Any] = ["serverWasRunning": serverWasRunning, "origin": origin?.absoluteString ?? ""]
      await pause(5)
      report["loaded"] = await js("""
        return { title: document.title, charts: document.querySelectorAll("#grid canvas").length,
          legend: document.querySelector(".legend")?.textContent.slice(0, 40), notification: typeof Notification,
          permission: Notification.permission, inlineScripts: document.querySelectorAll("script:not([src])").length }
        """)
      await snapshot("1-loaded.png")

      await click("#csvBtn")  // chart CSV download
      await click("#snapBtn")  // chart image download
      await pause(2)
      report["downloads"] = (try? FileManager.default.contentsOfDirectory(atPath: downloadsFolder.path))?.sorted() ?? []

      await click("a.tb[target=_blank]")  // Help: opens in the browser, the window stays on the app
      await pause(0.8)
      report["links"] = SelfTest.links
      report["stillOnApp"] = webView.url?.absoluteString ?? ""

      await click("#bottomTabs [data-tab=tester]")
      await pause(1)
      await click("#tSave")  // prompt: name the strategy
      await pause(1.2)
      await click("#sideTabs [data-tab=watchlist]")
      await pause(0.8)
      await click("#wlNew")  // prompt: new list
      await pause(1.2)
      let afterNew = await js("return Object.keys(app.state.watchlists)")
      await click("#wlDel")  // confirm, answered Cancel
      await pause(1.2)
      let afterCancel = await js("return Object.keys(app.state.watchlists)")
      await click("#wlDel")  // confirm, answered OK
      await pause(1.2)
      report["dialogs"] = [
        "asked": SelfTest.dialogs, "strategies": await js("return Object.keys(app.state.strategies || {})") ?? [],
        "listsAfterNew": afterNew ?? [], "listsAfterCancel": afterCancel ?? [],
        "listsAfterOk": await js("return Object.keys(app.state.watchlists)") ?? [],
      ]

      await click("#bottomTabs [data-tab=tester]")
      await pause(1)
      await click("#tImpBars")  // file picker: imports $QT_SELFTEST_FILE
      await pause(4)
      report["import"] = await js("return [...document.querySelectorAll('.toast')].map((t) => t.textContent)") ?? []
      report["chartSymbol"] = await js("return app.active.cfg.symbol") ?? ""
      report["errors"] = await js("return window.__qtErrors") ?? []
      await snapshot("2-after.png")

      if let data = try? JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]) {
        try? data.write(to: SelfTest.out.appendingPathComponent("report.json"))
      }
      stopServerAndQuit()
    }
  }
#endif
