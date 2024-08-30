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
            go
          ];
        };

        packages.default = pkgs.buildGoModule {
          pname = "c3-lsp";
          version = "0.3.0";
          src = ./.;

          modRoot = "./server";

          vendorHash = "sha256-y+Qs3zuvTq/KRc1ziH0R7E10et+MaQW9xOsFmSdI7PM=";

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
