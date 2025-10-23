{
  lib,
  pkgs,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "virtual-machine";
in
{
  config = lib.mkIf enable {
    networking = {
      bridges.br0.interfaces = [ "enp4s0" ];
      interfaces.br0.ipv4.addresses = [
        {
          address = "192.168.1.100";
          prefixLength = 24;
        }
      ];
      defaultGateway = "192.168.1.1";
      nameservers = [
        "192.168.1.1"
        "8.8.8.8"
      ];
    };

    virtualisation.libvirtd = {
      enable = true;
      allowedBridges = [ "br0" ];

      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;

        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };

        verbatimConfig = ''
          namespaces = []
        '';
      };
    };

    users.users = lib.genAttrs [ conf.username ] (user: {
      extraGroups = [
        "libvirtd"
        "kvm"
      ];
    });

    environment.sessionVariables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };

    environment.systemPackages = with pkgs; [
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
    ];

    #systemd.services.libvirt-network-default = {
    #  description = "Autostart libvirt default network";
    #  after = [ "libvirtd.service" ];
    #  requires = [ "libvirtd.service" ];
    #  wantedBy = [ "multi-user.target" ];
    #  serviceConfig = {
    #    Type = "oneshot";
    #    RemainAfterExit = true;
    #  };
    #  script = ''
    #    ${pkgs.libvirt}/bin/virsh net-list --all | grep -q default || \
    #    ${pkgs.libvirt}/bin/virsh net-define ${pkgs.libvirt}/share/libvirt/networks/default.xml
    #    ${pkgs.libvirt}/bin/virsh net-autostart default
    #    ${pkgs.libvirt}/bin/virsh net-start default || true
    #  '';
    #};
  };
}
