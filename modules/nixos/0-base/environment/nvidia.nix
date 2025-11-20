{ lib, helpers, ... }:
lib.mkIf helpers.hasNvidia {
  # Базовые NVIDIA настройки
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  LIBVA_DRIVER_NAME = "nvidia";

  # VRR/G-Sync - ОТКЛЮЧАЕМ для тестирования
  __GL_GSYNC_ALLOWED = "0";
  __GL_VRR_ALLOWED = "0";

  # КРИТИЧНО: Отключить hardware cursors
  WLR_NO_HARDWARE_CURSORS = "1";

  # NVIDIA + Wayland оптимизации (МАКСИМАЛЬНО АГРЕССИВНЫЕ)
  __GL_THREADED_OPTIMIZATION = "0";
  __GL_SHADER_DISK_CACHE = "0"; # Полностью отключить shader cache
  __GL_SYNC_TO_VBLANK = "0"; # Отключить vsync на уровне драйвера
  __GL_YIELD = "USLEEP"; # Лучше для wlroots

  # VRAM preservation
  NVIDIA_PRESERVE_VIDEO_MEMORY_ALLOCATIONS = "1";
  __GL_MaxFramesAllowed = "1"; # Отключить triple buffering

  # Для wlroots: ПОПРОБУЕМ PIXMAN вместо Vulkan
  WLR_RENDERER = "pixman"; # Software renderer - МОЖЕТ ПОМОЧЬ!
  WLR_DRM_NO_ATOMIC = "1";
  WLR_NO_HARDWARE_CURSORS = "1"; # Дублируем для уверенности

  # Electron/Chromium приложения
  ELECTRON_OZONE_PLATFORM_HINT = "auto";

  # НОВОЕ: Дополнительные NVIDIA специфичные переменные
  __GL_ALLOW_UNOFFICIAL_PROTOCOL = "1";
  __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
}
