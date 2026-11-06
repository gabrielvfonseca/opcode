{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.opcode;
in
{
  options.programs.opcode = {
    enable = lib.mkEnableOption "Opcode local voice dictation";
    package = lib.mkOption {
      type = lib.types.package;
      description = "Opcode package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.elem pkgs.stdenv.hostPlatform.system [
          "x86_64-linux"
          "aarch64-linux"
        ];
        message = "The Opcode Nix package supports x86_64-linux and aarch64-linux only.";
      }
    ];
    environment.systemPackages = [ cfg.package ];
  };
}
