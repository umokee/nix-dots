{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "singbox-wrapper";
  version = "1.0";

  src = pkgs.writeText "wrapper.c" ''
    #include <unistd.h>
    #include <signal.h>
    #include <sys/wait.h>
    #include <stdlib.h>

    int main() {
        pid_t pid = fork();
        if (pid == 0) {
            char *args[] = {"${pkgs.sing-box}/bin/sing-box", "run", "-c", "/etc/sing-box-config.json", NULL};
            execv(args[0], args);
            return 1;
        } else if (pid > 0) {
            int status;
            waitpid(pid, &status, 0);
            return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
        } else {
            return 1;
        }
    }
  '';

  nativeBuildInputs = [
    pkgs.gcc
    pkgs.patchelf
  ];

  unpackPhase = "true";

  buildPhase = ''
    gcc $src -o singbox-wrapper
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 singbox-wrapper $out/bin/
  '';
}
