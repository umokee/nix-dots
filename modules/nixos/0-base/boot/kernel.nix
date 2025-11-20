{ lib, super, ... }:
{
  overlays = [
    (
      self: super: {
        linuxPackages = super.linuxPackages // {
          kernel = super.linuxPackages.kernel.override {
            structuredExtraConfig = with lib.kernel; {
              HZ_1000 = yes;
              HZ = 1000;
              PREEMPT_FULL = yes;
              IOSCHED_BFQ = yes;
              DEFAULT_BFQ = yes;
              DEFAULT_IOSCHED = "bfq";
              V4L2_LOOPBACK = module;
              HID = yes;
            };
          };
        };
      }
    )
  ];

  udevRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}="bfq"
  '';
}
