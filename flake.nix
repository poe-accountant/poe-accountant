{
  description = "Development environment for poe-accountant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22
            yarn-berry
            curl
            go-task
            opentofu
            kubectl
            kubernetes-helm
            bash
            jq
            redis
            postgresql
          ];

          nativeBuildInputs = with pkgs; [
            nodejs_22
          ];

          shellHook = ''
            echo "Development environment loaded!"
            echo "Node.js version: $(node --version)"
            echo "Yarn version: $(yarn --version)"
            echo "Curl version: $(curl --version | head -n1)"
            echo "Task version: $(task --version)"
            echo "Terraform version: $(tofu --version | head -n1)"
            echo "kubectl version: $(kubectl version --client --short 2>/dev/null || echo 'Not connected to cluster')"
            echo "Helm version: $(helm version --short 2>/dev/null || echo 'Helm available')"
            echo "Redis version: $(redis-cli --version)"
            echo "PostgreSQL version: $(psql --version)"
          '';
        };
      });
}
