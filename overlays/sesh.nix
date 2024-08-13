final: prev: {
  sesh =
    let
      version = ".2.0.0-beta.3";
      src = prev.fetchFromGitHub {
        owner = "joshmedeski";
        repo = "sesh";
        rev = "v${version}";
        sha256 = "sha256-EKIekXABLnCAPMJNRPTdPXeWI5KK0HStyPT/OK7U8R8=";
      };
    in
    prev.sesh.override rec {
      buildGoModule =
        args:
        prev.buildGoModule (
          args
          // {
            inherit src version;
            vendorHash = "sha256-a45P6yt93l0CnL5mrOotQmE/1r0unjoToXqSJ+spimg=";
            doCheck = false;
          }
        );
    };
}
