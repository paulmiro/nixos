{
  config,
  lib,
  pkgs,
  ...
}:
let
  zfsPackage = config.boot.zfs.package;

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

  system-config = config;

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

  transformPathToRsyncCopyDir = name: path: "${path}/.borg-copy";
in
{
  options.clan.core.state = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        let
          # Get all unique ZFS datasets used for backups
          allBackupDatasets = lib.unique (lib.filter (d: d != null) (map pathToDataset config.folders));

          # Find root datasets (datasets that are not children of other datasets in our list)
          rootDatasets = lib.filter (
            ds: !lib.any (other: ds != other && lib.hasPrefix "${other.device}/" ds.device) allBackupDatasets
          ) allBackupDatasets;
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
              description = "Use rsync snapshots for this backup job";
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

          assertions = [
            {
              assertion = !(config.useZfsSnapshots && config.useRsyncSnapshots);
              message = "Cannot use ZFS snapshots and rsync copies at the same time";
            }
            {
              assertion = !lib.strings.hasInfix "/" name;
              message = "State names cannot contain '/'";
            }
            {
              assertion =
                config.useZfsSnapshots -> (lib.all (folder: pathToDataset folder != null) config.folders);
              message = "ZFS snapshots can only be used if all folders are in ZFS datasets. Make sure the disko config is up to date.";
            }
            {
              assertions = lib.all (
                serviceName:
                lib.filterAttrs (name: value: value.name == serviceName) system-config.systemd.services != { }
              ) config.servicesToStop;
              message = "State is configured to stop services that don't exist";
            }
          ];

          config = lib.mkMerge [
            {
              preBackupScript = lib.mkOrder 100 ''
                export PATH="${
                  lib.makeBinPath (
                    [
                      config.systemd.package
                      pkgs.coreutils
                    ]
                    ++ (lib.optional config.useRsyncCopy pkgs.rsync)
                    ++ (lib.optionas config.useZfsSnapshots zfsPackage)
                  )
                }:$PATH"
              '';
              postBackupScript = lib.mkOrder 100 ''
                export PATH="${
                  lib.makeBinPath (
                    [
                      config.systemd.package
                      pkgs.coreutils
                    ]
                    ++ (lib.optional config.useRsyncCopy pkgs.rsync)
                    ++ (lib.optionas config.useZfsSnapshots zfsPackage)
                  )
                }:$PATH"
              '';
              preRestoreScript = lib.mkOrder 100 ''
                export PATH="${
                  lib.makeBinPath [
                    config.systemd.package
                    pkgs.coreutils
                  ]
                }:$PATH"
              '';
              postRestoreScript = lib.mkOrder 100 ''
                export PATH="${
                  lib.makeBinPath [
                    config.systemd.package
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
                  service_status["${serviceName}"]=$(systemctl is-active ${serviceName})

                  if [ "$''${service_status["${serviceName}"]}" = "active" ]; then
                    systemctl stop ${serviceName}
                  fi
                '') config.servicesToStop}
              '';
            }
            {
              preBackupScript = lib.mkIf config.useZfsSnapshots lib.mkOrder 1300 ''
                echo "Creating ZFS snapshots for borgbackup job ${name}"
                set -e

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
                  ls "${fs.mountPoint}/.zfs/snapshot/borg-${name}/" > /dev/null || {
                    echo "Warning: Could not access snapshot directory ${fs.mountPoint}/.zfs/snapshot/borg-${name}/"
                  }
                '') allBackupDatasets}

                set +e
              '';
            }
            {
              preBackupScript = lib.mkIf config.useRsyncCopy lib.mkOrder 1300 ''
                echo "Creating Copy for borgbackup job ${name}"
                set -e

                ${lib.concatMapStringsSep "\n" (folder: ''
                  echo "Copying folder ${folder}"
                  rsync -avH --delete --numeric-ids "${folder}/" "${transformPathToRsyncCopyDir folder}/"
                '') config.folders}

                set +e
              '';
              # remember to create the .borg-copy directory

            }
            {
              preBackupScript = lib.mkOrder 1400 ''
                echo "Restarting services after borgbackup job ${name}"

                ${lib.concatMapStringsSep "\n" (serviceName: ''
                  if [ "$''${service_status["${serviceName}"]}" = "active" ]; then
                    systemctl start ${serviceName}
                  fi
                '') config.servicesToStop}
              '';
            }
            # postBackupScript
            {
              postBackupScript = lib.mkIf config.useZfsSnapshots lib.mkOrder 1200 ''
                echo "Cleaning up ZFS snapshots for borgbackup job ${name}"

                # Destroy recursive snapshots (only need to destroy root datasets)
                ${lib.concatMapStringsSep "\n" (fs: ''
                  if ${zfsPackage}/bin/zfs list -H -o name "${fs.device}@borg-${name}" >/dev/null 2>&1; then
                    ${zfsPackage}/bin/zfs destroy -r "${fs.device}@borg-${name}" || echo "Warning: Failed to destroy recursive snapshot ${fs.device}@borg-${name}"
                  fi
                '') rootDatasets}
              '';
            }
            # preRestoreScript
            {
              preRestoreScript = lib.mkOrder 1200 ''
                declare -A service_status

                # Fill the service_status array
                ${lib.concatMapStringsSep "\n" (serviceName: ''
                  service_status["${serviceName}"]="$(systemctl is-active ${serviceName})"
                '') config.servicesToStop}

                touch /tmp/clan_restore_stopped_services_${name}

                # Check if the service is running
                for service_name in "''${!service_status[@]}"; do
                  if [ "''${service_status[$service_name]}" = "active" ]; then
                    systemctl stop "''$service_name"
                    echo "$service_name"
                  fi 
                done > /tmp/clan_restore_stopped_services_${name}
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
      lib.types.submodule (
        { config, name, ... }:
        {
          options = {
            useZfsSnapshots = lib.mkOption {
              type = lib.types.bool;
              default = system-config.clan.core.state.${name}.useZfsSnapshots or false;
              description = "Use ZFS snapshots for this backup job";
            };

            useRsyncCopy = lib.mkOption {
              type = lib.types.bool;
              default = system-config.clan.core.state.${name}.useRsyncCopy or false;
              description = "Use rsync copies for this backup job";
            };

            # Clan will use the unmodified paths for restores, so we have to edit them as they're being passed to borgbackup
            paths = lib.mkOption {
              apply =
                paths:
                if config.useZfsSnapshots then
                  map (transformPathToZfsSnapshot name) paths
                else if config.useRsyncCopy then
                  map (transformPathToRsyncCopyDir name) paths
                else
                  paths;
            };
          };
        }
      )
    );
  };
}
