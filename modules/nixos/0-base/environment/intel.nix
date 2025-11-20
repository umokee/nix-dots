{ lib, helpers, ... }:
lib.mkIf (!helpers.hasNvidia && helpers.hasIntel) {
  LIBVA_DRIVER_NAME = "iHD";
}
