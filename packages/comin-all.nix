{
  pkgs,
  pname,
  ...
}:
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = with pkgs; [
    mprocs
    openssh
  ];
  text = ''
    mprocs \
      "ssh -At root@x.tail01dbd.ts.net 'comin status; exec bash'" \
      "ssh -At root@m2.tail01dbd.ts.net 'comin status; exec bash'" \
      "ssh -At root@gdrn.tail01dbd.ts.net 'comin status; exec bash'" \
      "ssh -At root@g.tail01dbd.ts.net 'comin status; exec bash'" \
      "ssh -At root@pbt.tail01dbd.ts.net 'comin status; exec bash'" \
      "ssh -At root@joip.tail01dbd.ts.net 'comin status; exec bash'" \
      "ssh -At root@gkr.tail01dbd.ts.net '/run/current-system/sw/bin/comin status; exec bash'"
  '';
}
