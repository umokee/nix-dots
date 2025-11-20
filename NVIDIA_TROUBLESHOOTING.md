# 🔧 ПОШАГОВАЯ ДИАГНОСТИКА NVIDIA АРТЕФАКТОВ

## ШАГ 1: Применить новые изменения

```bash
cd ~/nix-dots
sudo nixos-rebuild switch --flake .#desktop
sudo reboot
```

## ШАГ 2: После перезагрузки - проверить переменные

```bash
# Проверить что WLR использует pixman (software renderer)
echo $WLR_RENDERER
# Должно быть: pixman

# Проверить что hardware cursors отключены
echo $WLR_NO_HARDWARE_CURSORS
# Должно быть: 1

# Проверить kernel параметры
cat /proc/cmdline | grep nvidia
# Должно содержать:
# - nvidia-drm.modeset=1
# - nvidia.NVreg_EnableGpuFirmware=0
```

## ШАГ 3: Тестирование

### ВАРИАНТ A: Если артефакты ВСЁ ЕЩЁ есть с pixman

**Это значит проблема не в renderer'е. Попробуйте:**

1. Временно отключить sing-box:
```bash
sudo systemctl stop singbox-wrapper
```

2. Открыть приложение и проверить артефакты

3. Если помогло - проблема в sing-box конфликте

### ВАРИАНТ B: Если с pixman НЕТ артефактов, но медленно

**Нужно найти рабочий hardware renderer. Попробуйте по очереди:**

#### B.1: Попробовать GLESv2
```bash
WLR_RENDERER=gles2 mango  # или ваш WM
```

#### B.2: Попробовать Vulkan с другими настройками
```bash
WLR_RENDERER=vulkan WLR_DRM_NO_ATOMIC=0 mango
```

#### B.3: Вернуться к open source драйверам
В `/home/user/nix-dots/modules/nixos/1-hardware/nvidia.nix`:
```nix
open = true;  # Вместо false
```

### ВАРИАНТ C: Артефакты только в определенных приложениях

**Если артефакты только в VSCode/браузере/electron:**

1. Для VSCode - добавить в settings.json:
```json
{
  "window.titleBarStyle": "custom",
  "window.enableMenuBarMnemonics": false
}
```

2. Для Electron apps - запускать с:
```bash
chromium --disable-gpu-compositing
zen-browser --disable-gpu-compositing
```

3. Для GTK приложений:
```bash
GDK_BACKEND=x11 your-app  # Попробовать через XWayland
```

## ШАГ 4: Если pixman помог - оптимизируем

Если с `WLR_RENDERER=pixman` артефактов нет, но медленно:

### Вариант 1: Hybrid подход
В `~/.config/mango/mango.conf` добавить:
```
# Использовать pixman только для проблемных элементов
export WLR_RENDERER_ALLOW_SOFTWARE=1
```

### Вариант 2: Попробовать старую версию драйвера
В `/home/user/nix-dots/modules/nixos/1-hardware/nvidia.nix`:
```nix
package = config.boot.kernelPackages.nvidiaPackages.production;  # Вместо latest
```

## ШАГ 5: Диагностика железа

Проверить что GPU работает нормально:

```bash
# Проверить температуру и частоты
nvidia-smi

# Проверить ошибки в dmesg
sudo dmesg | grep -i nvidia | grep -i error

# Проверить ошибки в журнале
journalctl -b | grep -i nvidia | grep -i error
```

## ШАГ 6: Если НИЧЕГО не помогает

### Крайний вариант 1: Попробовать Hyprland вместо mangowc

Mangowc может иметь специфические проблемы с NVIDIA.

В `~/nix-dots/shared/config.nix`:
```nix
workspace = {
  enable = [
    "hyprland"  # Вместо "mangowc"
    "wallpapers"
    "themes"
  ];
};
```

### Крайний вариант 2: Использовать XWayland форсированно

Для всех приложений через XWayland (работает, но не native Wayland):
```bash
GDK_BACKEND=x11 code
GDK_BACKEND=x11 zen
```

## ОТЧЕТ ДЛЯ ОТЛАДКИ

После тестирования, ответьте на вопросы:

1. **Результат с pixman renderer:**
   - [ ] Артефакты пропали
   - [ ] Артефакты остались
   - [ ] Стало хуже

2. **Где артефакты появляются:**
   - [ ] Везде
   - [ ] Только в electron/chromium приложениях (VSCode, браузеры)
   - [ ] Только в GTK приложениях
   - [ ] Только при перемещении окон
   - [ ] Только при скроллинге

3. **Характер артефактов:**
   - [ ] Черные квадраты/прямоугольники
   - [ ] Белые вспышки
   - [ ] Размытие/смазывание
   - [ ] "Тиринг" (разрывы изображения)
   - [ ] Мерцание целого экрана

4. **Помогло ли отключение sing-box:**
   - [ ] Да, артефакты пропали
   - [ ] Нет, не помогло
   - [ ] Не тестировал

5. **Версия драйвера:**
```bash
nvidia-smi | grep "Driver Version"
```

---

## БЫСТРЫЕ ТЕСТЫ

```bash
# Тест 1: Software rendering
WLR_RENDERER=pixman mango

# Тест 2: GLES2
WLR_RENDERER=gles2 mango

# Тест 3: Без atomic
WLR_RENDERER=vulkan WLR_DRM_NO_ATOMIC=0 mango

# Тест 4: XWayland для одного приложения
GDK_BACKEND=x11 code
```
