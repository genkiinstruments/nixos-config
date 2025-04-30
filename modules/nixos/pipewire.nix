_: {
  security.rtkit.enable = true;
  services.pipewire = {
    jack.enable = true;
    # apple airplay support
    # raopOpenFirewall = true;
    # extraConfig.pipewire."raop-sink" = {
    #   "context.modules" = [
    #     {
    #       name = "libpipewire-module-raop-discover";
    #       args = { };
    #     }
    #   ];
    # };
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
