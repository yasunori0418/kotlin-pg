{
  description = "A playground for building APIs with Kotlin and Spring Boot!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        inputs.devenv.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = import inputs.systems;
      perSystem =
        {
          # config,
          # self',
          # inputs',
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [];
          };

          treefmt.programs = {
            ktlint = {
              enable = true;
            };
          };

          devenv.shells.default = {
            languages = {
              kotlin.enable = true;
              java = {
                enable = true;
                gradle = {
                  enable = true;
                  package = pkgs.gradle_8;
                };
              };
            };
            packages = with pkgs; [
              kotlin
              kotlin-language-server
            ];
            scripts = {
              gw = {
                exec = ''
                  $REPO_ROOT/gradlew $@
                '';
                description = "exeute gradlew of repository root";
              };
              run = {
                exec = ''
                  $REPO_ROOT/gradlew run
                '';
                description = "exeute `gradlew run`";
              };
              kotest = {
                exec = ''
                  $REPO_ROOT/gradlew test
                '';
                description = "exeute `gradlew test`";
              };
              doc = {
                exec = ''
                  $REPO_ROOT/gradlew dokkaHtml
                '';
                description = "exeute `gradlew dokkaHtml`";
              };
              report = {
                exec = ''
                  kotest
                  doc
                  # xdg-open build/dokka/html/index.html
                  # xdg-open build/reports/tests/test/index.html
                '';
                description = "open test and javadoc report in browser by xdg-open.";
              };
            };
            enterShell = ''
              kls_classpath="kls-classpath"
              cat <<EOF > $kls_classpath
              #!/usr/bin/env bash
              echo $(find ~/.gradle -type f -name '*.jar' | paste -sd:)
              EOF

              chmod +x $kls_classpath
            '';
          };
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
