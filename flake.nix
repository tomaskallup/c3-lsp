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
          version = "0.3.0";
          src = ./.;

          modRoot = "./server";

          vendorHash = "sha256-bqz5BM8NMJyiXhjaUpNsqihnl7Kkm+/K8xz/jxD1ENM=";

          preInstall = ''
            mv $GOPATH/bin/lsp $GOPATH/bin/c3-lsp
          '';

          meta = {
            homepage = "https://github.com/pherrymason/c3-lsp";
            description = "Language Server for C3 Language";
            license = pkgs.lib.licenses.gpl3Only;
            maintainers = [ ];
            platforms = pkgs.lib.platforms.all;
            mainProgram = "c3-lsp";
          };
        };
      }
    );
}
