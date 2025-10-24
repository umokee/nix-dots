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
          echo "Usage: $0 <directory> <extension> [output_file]"
          echo "Example: $0 /path/to/dir .txt output.txt"
          echo "Example with multiple extensions: $0 /path/to/dir '.txt .md .sh' output.txt"
          exit 1
        fi

        DIRECTORY="$1"
        EXTENSIONS="$2"
        OUTPUT_FILE="''${3:-merged_output.txt}"

        if [ ! -d "$DIRECTORY" ]; then
          echo "Error: Directory '$DIRECTORY' does not exist"
          exit 1
        fi

        > "$OUTPUT_FILE"

        echo "Starting file collection from: $DIRECTORY"
        echo "Extensions: $EXTENSIONS"
        echo "Output file: $OUTPUT_FILE"
        echo ""

        COUNT=0

        process_extension() {
          local ext="$1"
          
          ext="''${ext#.}"
          
          while IFS= read -r -d ''' file; do
            echo "Обработка: $file"
            echo "================== BEGIN FILE ==================" >> "$OUTPUT_FILE"
            echo "File: $file" >> "$OUTPUT_FILE"
            echo "Extension: .$ext" >> "$OUTPUT_FILE"
            echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT_FILE"
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
          done < <(find "$DIRECTORY" -type f -name "*.$ext" -print0)
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
