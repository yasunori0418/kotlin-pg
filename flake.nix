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
          config,
          # self',
          # inputs',
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [

              (final: prev: {
                kotlin = prev.kotlin.overrideAttrs (oldAttrs: rec {
                  version = "2.1.10";
                  src = prev.fetchurl {
                    url = "https://github.com/JetBrains/kotlin/releases/download/v${version}/kotlin-compiler-${version}.zip";
                    hash = "sha256-xuniY2iJgo4ZyIEdWriQhiU4yJ3CoxAZVt/uPCqLprE=";
                  };
                });
              })

            ];
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
              atlas
              kotlin-language-server
            ];
            processes = {
              gradlew-bootRun = {
                exec = ''
                  $REPO_ROOT/gradlew bootRun
                '';
              };
            };
            services = {
              postgres = {
                enable = true;
                package = pkgs.postgresql_17_jit;
                initialDatabases = [
                  {
                    name = "app";
                    user = "admin";
                    pass = "admin";
                  }
                ];
                port = 5432;
                listen_addresses = "127.0.0.1";
                settings = {
                  log_connections = true;
                  log_statement = "all";
                  logging_collector = true;
                  log_disconnections = true;
                  log_destination = pkgs.lib.mkForce "syslog";
                };
              };
            };
            scripts =
              let
                atlas-connect-db-url = "postgres://admin:admin@localhost:5432/app?sslmode=disable";
              in
              {
                list =
                  let
                    inherit (pkgs) lib;
                  in
                  {
                    exec = ''
                      echo
                      echo 🦾 Helper scripts you can run to make your development richer:
                      echo 🦾
                      ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF \
                      | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
                      ${lib.generators.toKeyValue { } (
                        lib.mapAttrs (name: value: value.description) config.devenv.shells.default.scripts
                      )}
                      EOF
                      echo
                    '';
                    description = "defined scripts in devenv shells";
                  };
                gw = {
                  exec = ''
                    $REPO_ROOT/gradlew $@
                  '';
                  description = "exeute gradlew of repository root";
                };
                kotest = {
                  exec = ''
                    $REPO_ROOT/gradlew test
                  '';
                  description = "exeute gradlew test";
                };
                doc = {
                  exec = ''
                    $REPO_ROOT/gradlew dokkaHtml
                  '';
                  description = "exeute gradlew dokkaHtml";
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
                sql = {
                  exec = ''
                    ${pkgs.usql}/bin/usql postgresql://admin:admin@localhost:5432/app
                  '';
                  description = "connect local postgresql";
                };
                schema-dump = {
                  exec = ''
                    atlas schema inspect \
                      -u ${atlas-connect-db-url} \
                      > $REPO_ROOT/database/schema.hcl
                  '';
                  description = "do dump current local db schema";
                };
                schema-apply = {
                  exec = ''
                    atlas schema apply \
                      -u ${atlas-connect-db-url} \
                      --to file://$REPO_ROOT/database/schema.hcl
                  '';
                  description = "adapting change local db schema";
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
