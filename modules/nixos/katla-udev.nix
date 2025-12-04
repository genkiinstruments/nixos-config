{
  # USB device access for katla-frontpanel
  services.udev.extraRules = ''
    # Genki katla-frontpanel USB device (both product IDs)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="27dd", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="20b1", MODE="0666", TAG+="uaccess"
  '';
}
