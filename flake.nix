{
  description = "C3 Language server";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            tree-sitter
            gnumake
            go_1_23
          ];
        };

        packages.default = pkgs.buildGo123Module {
          pname = "c3-lsp";
          version = "0.4.1";
          src = ./.;

          modRoot = "./server";
          proxyVendor = true;

          vendorHash = "sha256-T3wR6td9GHVHI9kNCchxsZyQR1/AIVDqAOsKfXI1GP8=";
          # vendorHash = nixpkgs.lib.fakeHash;

          preInstall = ''
            mv $GOPATH/bin/lsp $GOPATH/bin/c3lsp
          '';

          meta = {
            homepage = "https://github.com/pherrymason/c3-lsp";
            description = "Language Server for C3 Language";
            license = pkgs.lib.licenses.gpl3Only;
            maintainers = [ ];
            platforms = pkgs.lib.platforms.all;
            mainProgram = "c3lsp";
          };
        };
      }
    );
}
