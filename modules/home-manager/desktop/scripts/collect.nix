{
  pkgs,
  ...
}:
{
  config = {
    home.file.".local/bin/collect" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash

        if [ "$#" -lt 2 ]; then
          echo "Usage: $0 <directory> <extension> [output_file] [excluded_dirs]"
          echo "Example: $0 /path/to/dir .txt output.txt"
          echo "Example with multiple extensions: $0 /path/to/dir '.txt .md .sh' output.txt"
          echo "Example with excluded dirs: $0 /path/to/dir .txt output.txt 'node_modules .git dist'"
          exit 1
        fi

        DIRECTORY="$1"
        EXTENSIONS="$2"
        OUTPUT_FILE="''${3:-merged_output.txt}"
        EXCLUDED_DIRS="''${4:-}"

        if [ ! -d "$DIRECTORY" ]; then
          echo "Error: Directory '$DIRECTORY' does not exist"
          exit 1
        fi

        > "$OUTPUT_FILE"

        echo "Starting file collection from: $DIRECTORY"
        echo "Extensions: $EXTENSIONS"
        echo "Output file: $OUTPUT_FILE"
        if [ -n "$EXCLUDED_DIRS" ]; then
          echo "Excluded directories: $EXCLUDED_DIRS"
        fi
        echo ""

        COUNT=0

        build_exclude_args() {
          local args=()
          if [ -n "$EXCLUDED_DIRS" ]; then
            local first=true
            for dir in $EXCLUDED_DIRS; do
              if [ "$first" = true ]; then
                args+=("(" "-path" "*/$dir" "-prune")
                first=false
              else
                args+=("-o" "-path" "*/$dir" "-prune")
              fi
            done
            args+=(")" "-o")
          fi
          printf '%s\n' "''${args[@]}"
        }

        process_extension() {
          local ext="$1"
          
          ext="''${ext#.}"
          
          local exclude_args=()
          if [ -n "$EXCLUDED_DIRS" ]; then
            readarray -t exclude_args < <(build_exclude_args)
          fi
          
          while IFS= read -r -d ''' file; do
            echo "Обработка: $file"
            echo "================== BEGIN FILE ==================" >> "$OUTPUT_FILE"
            echo "File: $file" >> "$OUTPUT_FILE"
            echo "Extension: .$ext" >> "$OUTPUT_FILE"
            echo "================================================" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            
            cat "$file" >> "$OUTPUT_FILE"
            
            echo "" >> "$OUTPUT_FILE"
            echo "=================== END FILE ===================" >> "$OUTPUT_FILE"
            echo "File: $file" >> "$OUTPUT_FILE"
            echo "================================================" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            
            ((COUNT++))
          done < <(
            if [ ''${#exclude_args[@]} -gt 0 ]; then
              find "$DIRECTORY" "''${exclude_args[@]}" -type f -name "*.$ext" -print0
            else
              find "$DIRECTORY" -type f -name "*.$ext" -print0
            fi
          )
        }

        for extension in $EXTENSIONS; do
          process_extension "$extension"
        done

        echo ""
        echo "Complete! Files processed: $COUNT"
        echo "Result saved to: $OUTPUT_FILE"
      '';
    };
  };
}
