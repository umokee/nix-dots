{
  pkgs,
  ...
}:
{
  config = {
    home.file.".local/bin/detect-process" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail

        if [ $# -eq 0 ]; then
            echo "Использование: $0 <имя_процесса>"
            echo "Пример: $0 bottles"
            echo "Пример: $0 mullvad-browser"
            exit 1
        fi

        PROCESS_NAME="$1"
        TEMP_FILE=$(mktemp)

        echo "🔍 Ищем процессы для: $PROCESS_NAME"
        echo ""

        # Найти все запущенные процессы
        ps -eo pid,comm,args | grep -i "$PROCESS_NAME" | grep -v grep | grep -v "$0" > "$TEMP_FILE" || {
            echo "❌ Процесс '$PROCESS_NAME' не запущен"
            echo "Запустите приложение и попробуйте снова"
            rm -f "$TEMP_FILE"
            exit 1
        }

        echo "📋 Найденные процессы:"
        cat "$TEMP_FILE"
        echo ""

        # Собираем уникальные исполняемые пути
        declare -A paths
        declare -A packages

        while read -r line; do
            # Извлекаем PID
            pid=$(echo "$line" | awk '{print $1}')
            
            # Получаем реальный путь к исполняемому файлу
            if [ -e "/proc/$pid/exe" ]; then
                exe_path=$(sudo readlink -f "/proc/$pid/exe" 2>/dev/null || echo "")
                if [ -n "$exe_path" ]; then
                    paths["$exe_path"]=1
                    
                    # Определяем Nix пакет - ИСПРАВЛЕНО
                    nix_store_regex='^/nix/store/([^/]+)'
                    if [[ "$exe_path" =~ $nix_store_regex ]]; then
                        pkg="''${BASH_REMATCH[1]}"
                        packages["$pkg"]=1
                    fi
                fi
            fi
            
            # Также парсим аргументы командной строки
            args=$(echo "$line" | awk '{$1=$2=""; print $0}' | xargs)
            
            # Ищем /nix/store пути в аргументах - ИСПРАВЛЕНО
            for arg in $args; do
                if [[ "$arg" =~ $nix_store_regex ]]; then
                    pkg="''${BASH_REMATCH[1]}"
                    packages["$pkg"]=1
                fi
            done
        done < "$TEMP_FILE"

        rm -f "$TEMP_FILE"

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✨ Результат для Sing-Box конфигурации"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Генерируем process_path_regex
        echo "📝 process_path_regex (добавить в route.rules):"
        echo ""
        echo "{"
        echo "  process_path_regex = ["

        for path in "''${!paths[@]}"; do
            # Создаём regex из пути
            # Заменяем хеши Nix на .*
            regex=$(echo "$path" | sed 's|/nix/store/[^/]*|/nix/store/[^/]*|g')
            
            # Обобщаем путь для разных версий пакета - ИСПРАВЛЕНО
            version_regex='(.*/)[^/]+-([0-9]+\.[0-9]+.*)/(.+)'
            if [[ "$regex" =~ $version_regex ]]; then
                base="''${BASH_REMATCH[1]}"
                name_part=$(echo "$path" | grep -oP '/nix/store/[^/]+-\K[^-/]+' | head -1 || echo "")
                suffix="''${BASH_REMATCH[3]}"
                if [ -n "$name_part" ] && [ -n "$suffix" ]; then
                    regex=".*/$name_part.*/$suffix"
                fi
            fi
            
            echo "    \"$regex\""
        done

        # Добавляем дополнительные общие паттерны
        echo "    \".*$PROCESS_NAME.*\""

        echo "  ];"
        echo "  outbound = \"proxy\";"
        echo "}"
        echo ""

        # Генерируем package_name (если будет поддерживаться)
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 Обнаруженные Nix пакеты:"
        echo ""
        for pkg in "''${!packages[@]}"; do
            echo "  - $pkg"
        done
        echo ""

        # Создаём полный пример конфига
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📄 Полный пример для NixOS конфига:"
        echo ""
        echo "route = {"
        echo "  rules = ["
        echo "    # DNS hijack должен быть первым"
        echo "    {"
        echo "      protocol = \"dns\";"
        echo "      action = \"hijack-dns\";"
        echo "    }"
        echo "    # Правило для $PROCESS_NAME"
        echo "    {"
        echo "      process_path_regex = ["

        for path in "''${!paths[@]}"; do
            regex=$(echo "$path" | sed 's|/nix/store/[^/]*|/nix/store/[^/]*|g')
            echo "        \"$regex\""
        done
        echo "        \".*$PROCESS_NAME.*\""

        echo "      ];"
        echo "      outbound = \"proxy\";"
        echo "    }"
        echo "    # ... остальные правила"
        echo "  ];"
        echo "};"
      '';
    };
  };
}
