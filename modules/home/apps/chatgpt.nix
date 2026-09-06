{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
let
  baseline = pkgs.callPackage ../../../pkgs/chatgpt { };
  stateDirectory = "${config.xdg.stateHome}/chatgpt";
  expression = pkgs.writeText "chatgpt-update.nix" ''
    { version, sha256 }:
    let
      pkgs = import ${pkgs.path} {
        system = "x86_64-linux";
        config.allowUnfreePredicate = package: (package.pname or "") == "chatgpt";
      };
    in pkgs.callPackage ${../../../pkgs/chatgpt} { inherit version sha256; }
  '';
  keyring =
    pkgs.runCommand "chatgpt-repository-keyring.gpg" { nativeBuildInputs = [ pkgs.gnupg ]; }
      ''
        gpg --batch --dearmor --output "$out" ${../../../files/chatgpt/repository.asc}
      '';
  launcher = pkgs.writeShellApplication {
    name = "chatgpt";
    text = ''
      updated=${lib.escapeShellArg "${stateDirectory}/profile/bin/chatgpt"}
      if [[ -x "$updated" ]]; then
        exec "$updated" "$@"
      fi
      exec ${baseline}/bin/chatgpt "$@"
    '';
  };
  updater = pkgs.writeShellApplication {
    name = "chatgpt-update";
    runtimeInputs = [
      pkgs.curl
      pkgs.python3
      pkgs.gnupg
      pkgs.dpkg
      unstablePkgs.nixVersions.latest
    ];
    text = ''
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export CURL_CA_BUNDLE="$SSL_CERT_FILE"
      exec python ${../../../scripts/update-chatgpt.py} \
        --expression ${expression} --keyring ${keyring} --fallback ${baseline} \
        --state-directory ${lib.escapeShellArg stateDirectory} "$@"
    '';
  };
in
{
  home.packages = [
    launcher
    updater
  ];
  xdg.desktopEntries.chatgpt = {
    name = "ChatGPT";
    genericName = "AI assistant";
    exec = "chatgpt %U";
    icon = "${baseline}/share/pixmaps/chatgpt.png";
    categories = [
      "Utility"
      "Development"
    ];
    mimeType = [ "x-scheme-handler/codex" ];
    terminal = false;
  };
  systemd.user.services.chatgpt-update = {
    Unit.Description = "Update ChatGPT from the signed official Linux repository";
    Service = {
      Type = "oneshot";
      ExecStart = "${updater}/bin/chatgpt-update";
      TimeoutStartSec = "30min";
      Nice = 10;
    };
  };
  systemd.user.timers.chatgpt-update = {
    Unit.Description = "Check for the latest ChatGPT Linux preview every hour";
    Timer = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "5min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
