#include "flutter_window.h"

#include <dwmapi.h>
#include <flutter/standard_method_codec.h>

#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif

#ifndef DWMWA_BORDER_COLOR
#define DWMWA_BORDER_COLOR 34
#endif

#ifndef DWMWA_CAPTION_COLOR
#define DWMWA_CAPTION_COLOR 35
#endif

#ifndef DWMWA_TEXT_COLOR
#define DWMWA_TEXT_COLOR 36
#endif

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  window_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "saldo.sh/window",
          &flutter::StandardMethodCodec::GetInstance());
  window_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "setTitleBarTheme") {
          result->NotImplemented();
          return;
        }

        bool dark = false;
        const auto* arguments =
            std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments != nullptr) {
          const auto dark_entry =
              arguments->find(flutter::EncodableValue("dark"));
          if (dark_entry != arguments->end()) {
            const auto* value = std::get_if<bool>(&dark_entry->second);
            if (value != nullptr) {
              dark = *value;
            }
          }
        }

        ApplyTitleBarTheme(dark);
        result->Success();
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (window_channel_) {
    window_channel_->SetMethodCallHandler(nullptr);
    window_channel_.reset();
  }
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_DWMCOLORIZATIONCOLORCHANGED:
      ApplyTitleBarTheme(title_bar_dark_);
      return 0;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::ApplyTitleBarTheme(bool dark) {
  title_bar_dark_ = dark;
  const HWND window = GetHandle();
  if (window == nullptr) {
    return;
  }

  const BOOL use_dark_mode = dark ? TRUE : FALSE;
  const COLORREF caption_color =
      dark ? RGB(23, 27, 32) : RGB(243, 241, 233);
  const COLORREF text_color =
      dark ? RGB(243, 241, 233) : RGB(23, 27, 32);

  DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE,
                        &use_dark_mode, sizeof(use_dark_mode));
  DwmSetWindowAttribute(window, DWMWA_CAPTION_COLOR, &caption_color,
                        sizeof(caption_color));
  DwmSetWindowAttribute(window, DWMWA_TEXT_COLOR, &text_color,
                        sizeof(text_color));
  DwmSetWindowAttribute(window, DWMWA_BORDER_COLOR, &caption_color,
                        sizeof(caption_color));
  RedrawWindow(window, nullptr, nullptr,
               RDW_FRAME | RDW_INVALIDATE | RDW_UPDATENOW);
}
