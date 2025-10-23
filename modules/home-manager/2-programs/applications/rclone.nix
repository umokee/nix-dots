{ config, pkgs, ... }:
let
  knastuConfig = ''
    ## Remotes:
    remoteA = "${config.home.homeDirectory}/knastu"
    remoteB = "cloud:sync/knastu"

    workdirA = None
    workdirB = None

    name = "knastu-sync"

    ## rclone flags
    rclone_exe = "rclone"

    filter_flags = [
      '--exclude', '*.tmp',
      '--exclude', '*.temp',
      '--exclude', '*.cache',
      '--exclude', '*.log',
      '--exclude', '.git/**',
      '--exclude', '.git',
      '--exclude', 'node_modules/**',
      '--exclude', '__pycache__/**',
      '--exclude', '*.pyc',
      '--exclude', '.DS_Store',
      '--exclude', 'Thumbs.db',
      '--exclude', '~$*',
      '--exclude', '.~lock.*',
      '--exclude', '*.swp',
      '--exclude', '*.swo',
      '--exclude', '.syncrclone/**',
    ]

    rclone_flags = []

    rclone_env = {}

    rclone_flagsA = []
    rclone_flagsB = []

    ## Sync Options
    compare = "mtime"

    dt = 1.1

    conflict_mode = "newer"
    tag_conflict = False

    reuse_hashesA = False
    reuse_hashesB = False

    always_get_mtime = True

    backup = True
    backup_with_copy = None

    sync_backups = False

    hash_fail_fallback = "mtime"

    set_lock = True

    action_threads = 4

    cleanup_empty_dirsA = None
    cleanup_empty_dirsB = None

    avoid_relist = True

    ## Rename Tracking
    renamesA = "hash"
    renamesB = "hash"

    ## Status
    list_status_dt = 10

    ## Logs
    save_logs = True
    local_log_dest = ""  # NOT on a remote

    pre_sync_shell = ""
    post_sync_shell = ""

    stop_on_shell_error = False

    tempdir = None

    ## Version
    _syncrclone_version = "20230310.0.BETA"
  '';

  nixosConfig = ''
     ## Remotes:
    remoteA = "${config.home.homeDirectory}/nixos"
    remoteB = "cloud:sync/nixos"

    workdirA = None
    workdirB = None

    name = "nixos-sync"

    ## rclone flags
    rclone_exe = "rclone"

    filter_flags = [
      '--exclude', '*.tmp',
      '--exclude', '*.temp',
      '--exclude', '*.cache',
      '--exclude', '*.log',
      '--exclude', '.git/**',
      '--exclude', '.git',
      '--exclude', 'node_modules/**',
      '--exclude', '__pycache__/**',
      '--exclude', '*.pyc',
      '--exclude', '.DS_Store',
      '--exclude', 'Thumbs.db',
      '--exclude', '~$*',
      '--exclude', '.~lock.*',
      '--exclude', '*.swp',
      '--exclude', '*.swo',
      '--exclude', '.syncrclone/**',
    ]

    rclone_flags = []

    rclone_env = {}

    rclone_flagsA = []
    rclone_flagsB = []

    ## Sync Options
    compare = "mtime"

    dt = 1.1

    conflict_mode = "newer"
    tag_conflict = False

    reuse_hashesA = False
    reuse_hashesB = False

    always_get_mtime = True

    backup = True
    backup_with_copy = None

    sync_backups = False

    hash_fail_fallback = "mtime"

    set_lock = True

    action_threads = 4

    cleanup_empty_dirsA = None
    cleanup_empty_dirsB = None

    avoid_relist = True

    ## Rename Tracking
    renamesA = "hash"
    renamesB = "hash"

    ## Status
    list_status_dt = 10

    ## Logs
    save_logs = True
    local_log_dest = ""  # NOT on a remote

    pre_sync_shell = ""
    post_sync_shell = ""

    stop_on_shell_error = False

    tempdir = None

    ## Version
    _syncrclone_version = "20230310.0.BETA"
  '';
in
{
  home.packages = [
    pkgs.rclone
    pkgs.rclone-browser
    pkgs.syncrclone
  ];

  home.file = {
    ".syncrclone/knastu.py".text = knastuConfig;
    ".syncrclone/nixos.py".text = nixosConfig;
  };

  home.file.".local/bin/sync-folders" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -e

      echo "=== Syncing knastu ==="
      ${pkgs.syncrclone}/bin/syncrclone ${config.home.homeDirectory}/.syncrclone/knastu.py

      echo "=== Syncing nixos ==="
      ${pkgs.syncrclone}/bin/syncrclone ${config.home.homeDirectory}/.syncrclone/nixos.py

      echo "=== Sync completed ==="
    '';
  };
}
