use std::net::TcpStream;
use std::time::{Duration, Instant};

use tauri::Manager;
use tauri_plugin_shell::process::CommandChild;
use tauri_plugin_shell::ShellExt;

const PORT: u16 = 7788;

struct Server(std::sync::Mutex<Option<CommandChild>>);

/// GUI apps launched from Finder inherit a minimal PATH. Use the login shell PATH
/// so git, claude, and opencode installed via Homebrew or ~/.local/bin are found.
fn login_shell_path() -> Option<String> {
    #[cfg(target_os = "macos")]
    {
        use std::process::Command;
        let out = Command::new("/bin/bash")
            .args(["-lc", "printf %s \"$PATH\""])
            .output()
            .ok()?;
        if out.status.success() {
            let path = String::from_utf8_lossy(&out.stdout).trim().to_string();
            if !path.is_empty() {
                return Some(path);
            }
        }
    }
    None
}


fn wait_for_server(timeout: Duration) -> bool {
    let deadline = Instant::now() + timeout;
    while Instant::now() < deadline {
        if TcpStream::connect(("127.0.0.1", PORT)).is_ok() {
            return true;
        }
        std::thread::sleep(Duration::from_millis(150));
    }
    false
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {


            let already_up = TcpStream::connect(("127.0.0.1", PORT)).is_ok();

            if !already_up {
                let data_dir = app.path().app_data_dir()?;
                std::fs::create_dir_all(&data_dir)?;

                let mut sidecar = app
                    .shell()
                    .sidecar("myaudit-serve")?
                    .env("PORT", PORT.to_string())
                    .env("MYAUDIT_DB", data_dir.join("myaudit.db").to_string_lossy().to_string())
                    .env("REAL_CLAUDE", "1")
                    .current_dir(data_dir);
                if let Some(path) = login_shell_path() {
                    sidecar = sidecar.env("PATH", path);
                }
                let (_rx, child) = sidecar.spawn()?;

                app.manage(Server(std::sync::Mutex::new(Some(child))));
            }


            let handle = app.handle().clone();
            std::thread::spawn(move || {
                wait_for_server(Duration::from_secs(30));
                if let Some(w) = handle.get_webview_window("main") {
                    let _ = w.eval("location.replace(location.href)");
                    let _ = w.show();
                    let _ = w.set_focus();
                }
            });

            Ok(())
        })
        .on_window_event(|window, event| {
            if let tauri::WindowEvent::Destroyed = event {
                if let Some(state) = window.app_handle().try_state::<Server>() {
                    if let Some(child) = state.0.lock().unwrap().take() {
                        let _ = child.kill();
                    }
                }
            }
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
