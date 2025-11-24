{
  config,
  lib,
  pkgs,
  ...
}:
let
  system-config = config;

  zfsPackage = config.boot.zfs.package;

  stateForPath =
    path:
    lib.findSingle (state: (builtins.elem path state.folders))
      (throw "Could not find state for path: ${path}") # never happens because paths are only added through clan
      (throw "Found multiple states for path: ${path}") # never happens because we assert that paths are unique
      (builtins.attrValues config.clan.core.state);

  # Get all ZFS filesystems
  zfsFileSystems = lib.filter (fs: fs.fsType == "zfs") (lib.attrValues config.fileSystems);

  # Map paths to their ZFS datasets (find the most specific match)
  pathToDataset =
    path:
    let
      matching = lib.filter (fs: lib.hasPrefix fs.mountPoint path) zfsFileSystems;
      # Sort by length descending to get the most specific match first
      sorted = lib.sort (a: b: lib.stringLength a.mountPoint > lib.stringLength b.mountPoint) matching;
    in
    if sorted != [ ] then lib.head sorted else null;

  # Get all unique ZFS datasets used for backups
  allBackupDatasetsFor = folders: lib.unique (lib.filter (d: d != null) (map pathToDataset folders));

  # Find root datasets (datasets that are not children of other datasets in our list)
  rootDatasetsFor =
    folders:
    lib.filter (
      ds:
      !lib.any (other: ds != other && lib.hasPrefix "${other.device}/" ds.device) (
        allBackupDatasetsFor folders
      )
    ) (allBackupDatasetsFor folders);

  # Transform a backup path to use the snapshot directory
  transformPathToZfsSnapshot =
    name: path:
    let
      dataset = pathToDataset path;
    in
    if dataset != null then
      # Replace the mount point with the .zfs/snapshot path
      let
        relativePath = lib.removePrefix dataset.mountPoint path;
        # Ensure we have a leading slash for non-empty relative paths
        relativePathWithSlash =
          if relativePath == "" then
            ""
          else if lib.hasPrefix "/" relativePath then
            relativePath
          else
            "/${relativePath}";
      in
      "${dataset.mountPoint}/.zfs/snapshot/borg-${name}${relativePathWithSlash}"
    else
      path;

  transformPathToRsyncCopyDir = path: "${path}/.borg-copy";
in
{
  options.clan.core.state = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        let
          # Get all unique ZFS datasets used for backups
          allBackupDatasets = allBackupDatasetsFor config.folders;

          # Find root datasets (datasets that are not children of other datasets in our list)
          rootDatasets = rootDatasetsFor config.folders;
        in
        {
          options = {
            useZfsSnapshots = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Use ZFS snapshots for this backup job";
            };

            useRsyncCopy = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Use rsync to copy the data to a temporary folder for this backup job";
            };

            servicesToStop = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = ''
                List of services to stop before backuing the state folders, or restoring it from a backup

                Utilize this to stop services which currently access these folders or other services affected by the backup/restore
              '';
            };
          };

          config = lib.mkMerge [
            {
              preBackupScript = lib.mkOrder 100 ''
                export PATH="${
                  lib.makeBinPath (
                    [
                      system-config.systemd.package
                      pkgs.coreutils
                    ]
                    ++ (lib.optional config.useRsyncCopy pkgs.rsync)
                    ++ (lib.optional config.useZfsSnapshots zfsPackage)
                  )
                }:$PATH"
              '';
              preRestoreScript = lib.mkOrder 100 ''
                export PATH="${
                  lib.makeBinPath [
                    system-config.systemd.package
                    pkgs.coreutils
                  ]
                }:$PATH"
              '';
              postRestoreScript = lib.mkOrder 100 ''
                export PATH="${
                  lib.makeBinPath [
                    system-config.systemd.package
                    pkgs.coreutils
                  ]
                }:$PATH"
              '';
            }
            # preBackupScript
            {
              preBackupScript = lib.mkOrder 1200 ''
                declare -A service_status
                ${lib.concatMapStringsSep "\n" (serviceName: ''
                  # Check if the service is running
                  service_status["${serviceName}"]=$(systemctl is-active ${serviceName} || true)

                  if [ "''${service_status[${serviceName}]}" = "active" ]; then
                    echo "Stopping service ${serviceName}"
                    systemctl stop ${serviceName}
                  fi
                '') config.servicesToStop}
              '';
            }
            {
              preBackupScript = lib.mkIf config.useZfsSnapshots (
                lib.mkOrder 1300 ''
                  echo "Cleaning up previous ZFS snapshots for ${name}"
                  # Destroy recursive snapshots (only need to destroy root datasets)
                  ${lib.concatMapStringsSep "\n" (fs: ''
                    if ${zfsPackage}/bin/zfs list -H -o name "${fs.device}@borg-${name}" >/dev/null 2>&1; then
                      ${zfsPackage}/bin/zfs destroy -r "${fs.device}@borg-${name}" || echo "Warning: Failed to destroy recursive snapshot ${fs.device}@borg-${name}"
                    fi
                  '') rootDatasets}

                  echo "Creating ZFS snapshots for ${name}"
                  # Create recursive snapshots for root datasets only
                  ${lib.concatMapStringsSep "\n" (fs: ''
                    if ${zfsPackage}/bin/zfs list -H -o name "${fs.device}" >/dev/null 2>&1; then
                      ${zfsPackage}/bin/zfs snapshot -r "${fs.device}@borg-${name}" || {
                        echo "Failed to create recursive snapshot for ${fs.device}"
                        exit 1
                      }
                      echo "Created recursive snapshot: ${fs.device}@borg-${name}"
                    fi
                  '') rootDatasets}

                  # Ensure snapshot directories are accessible (trigger automount)
                  echo "Ensuring snapshot directories are accessible..."
                  ${lib.concatMapStringsSep "\n" (fs: ''
                    ls -A "${fs.mountPoint}/.zfs/snapshot/borg-${name}/" > /dev/null || {
                      echo "Warning: Could not access snapshot directory ${fs.mountPoint}/.zfs/snapshot/borg-${name}/"
                    }
                  '') allBackupDatasets}

                  # Ensure folders are accessible
                  echo "Ensuring folders are accessible..."
                  ${lib.concatMapStringsSep "\n" (folder: ''
                    ls -A "${folder}/" > /dev/null || {
                      echo "Warning: Could not access folder ${folder}/"
                    }
                  '') config.folders}
                ''
              );
            }
            {
              preBackupScript = lib.mkIf config.useRsyncCopy (
                lib.mkOrder 1300 ''
                  echo "Creating Copy for ${name}"

                  ${lib.concatMapStringsSep "\n" (folder: ''
                    echo "Copying folder ${folder}"
                    rsync -avH --delete --numeric-ids --exclude ".borg-copy" "${folder}/" "${transformPathToRsyncCopyDir folder}/"
                  '') config.folders}
                ''
              );
            }
            {
              preBackupScript = lib.mkOrder 1400 ''
                echo "Restarting services for ${name}"

                ${lib.concatMapStringsSep "\n" (serviceName: ''
                  if [ "''${service_status[${serviceName}]}" = "active" ]; then
                    echo "Restarting service ${serviceName}"
                    systemctl start ${serviceName}
                  fi
                '') config.servicesToStop}
              '';
            }
            # preRestoreScript
            {
              preRestoreScript = lib.mkOrder 1200 ''
                declare -A service_status

                # Fill the service_status array
                ${lib.concatMapStringsSep "\n" (serviceName: ''
                  service_status[${serviceName}]="$(systemctl is-active ${serviceName} || true)"
                '') config.servicesToStop}

                touch /tmp/clan_restore_stopped_services_${name}

                # Check if the service is running
                for service_name in "''${!service_status[@]}"; do
                  if [ "''${service_status[$service_name]}" = "active" ]; then
                    systemctl stop "''$service_name"
                    echo "$service_name"
                  fi
                done > /tmp/clan_restore_stopped_services_${name}

                echo "Stopped services:"
                cat /tmp/clan_restore_stopped_services_${name})
              '';
            }
            # postRestoreScript
            {
              postRestoreScript = lib.mkOrder 800 ''
                # Check if the service is running
                readarray -t stopped_services < /tmp/clan_restore_stopped_services_${name}

                for service_name in "''${stopped_services[@]}"; do
                  systemctl start "''${service_name}"
                done
              '';
            }
          ];
        }
      )
    );
  };

  options.services.borgbackup.jobs = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          includesZfsSnapshots = lib.mkOption {
            type = lib.types.bool;
            # this assumes all paths get backet up to all destinations. this is currently true.
            default = lib.any (state: state.useZfsSnapshots) (
              builtins.attrValues system-config.clan.core.state
            );
            description = "Use ZFS snapshots for this backup job";
          };

          includesRsyncCopies = lib.mkOption {
            type = lib.types.bool;
            # this assumes all paths get backet up to all destinations. this is currently true.
            default = lib.any (state: state.useRsyncCopy) (builtins.attrValues system-config.clan.core.state);
            description = "Use rsync copies for this backup job";
          };

          # Clan needs to use the unmodified paths for restores, so we have to edit them as they're being passed to borgbackup
          paths = lib.mkOption {
            apply =
              paths:
              map (
                path:
                let
                  state = stateForPath path;
                in
                if state.useZfsSnapshots then
                  (transformPathToZfsSnapshot state.name path)
                else if state.useRsyncCopy then
                  (transformPathToRsyncCopyDir path)
                else
                  path
              ) paths;
          };

          startAt = lib.mkOption {
            # better default for me than what clan does
            # + 5 minutes to avoid collisiions with auto-snapshots
            apply = schedule: if schedule == "*-*-* 01:00:00" then "*-*-* 05:05:00" else schedule;
          };
        };

        config = {
          extraCreateArgs = [
            "--debug"
            "--progress"
            "--show-rc"
          ];
        };
      }
    );
  };

  config = {
    # Extend systemd services for borgbackup jobs that use ZFS snapshots
    systemd.services = lib.mapAttrs' (
      name: job:
      lib.nameValuePair "borgbackup-job-${name}" (
        lib.mkIf (job.includesZfsSnapshots or false) {
          serviceConfig = {
            PrivateDevices = lib.mkForce false; # ZFS needs access to /dev/zfs
          };

          path = [ zfsPackage ];
        }
      )
    ) config.services.borgbackup.jobs;

    assertions =
      (lib.concatMap (state: [
        {
          assertion = !(state.useZfsSnapshots && state.useRsyncCopy);
          message = "State ${state.name}: ZFS snapshots and rsync copies cannot be used at the same time";
        }
        {
          assertion = state.useZfsSnapshots -> lib.all (folder: pathToDataset folder != null) state.folders;
          message = "State ${state.name}: ZFS snapshots can only be used if all folders are in ZFS datasets. Make sure the disko config is up to date.";
        }
        {
          assertion = lib.all (
            serviceName:
            lib.filterAttrs (name: value: value.name == serviceName) system-config.systemd.services != { }
          ) state.servicesToStop;
          message = "State ${state.name} is configured to stop services that don't exist: [ ${lib.concatStringsSep ", " state.servicesToStop} ]";
        }
        {
          assertion = !lib.strings.hasInfix "/" state.name;
          message = "State names cannot contain '/': ${state.name}";
        }
      ]) (builtins.attrValues config.clan.core.state))
      ++ [
        {
          assertion = lib.allUnique (
            lib.flatten (map (state: state.folders) (builtins.attrValues config.clan.core.state))
          );
          message = "State paths must be unique";
        }
      ];
  };
}
