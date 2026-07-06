import sys
import os
import re
from github import Github
from github import Auth
import semver

TOML_PATH = "modules/versions/versions.toml"
GH = None


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def fetch_latest_version(repo_name, repo_type):
    try:
        raw_version = None
        match repo_type:
            case "github":
                raw_version = fetch_latest_version_github(repo_name)
            case "ghcr":
                raw_version = fetch_latest_version_ghcr(repo_name)
            case _:
                eprint(f"Error: Unknown repo type {repo_type}")
                return None

        if not raw_version:
            return None

        eprint(f"Found newest version: {raw_version}")
        return clean(raw_version)

    except Exception as e:
        eprint(f"Failed to fetch release for {repo_name}: {e}")
        return None


def fetch_latest_version_github(repo_name):
    """Fetches the latest version from GitHub Releases."""
    repo = GH.get_repo(repo_name)
    release = repo.get_latest_release()

    # Prefer the git tag, fallback to the release title/name
    if release.tag_name:
        eprint(f"Found version in release tag: {release.tag_name}")
        return release.tag_name
    elif release.title:
        eprint(f"Found version in release title: {release.title}")
        return release.title
    else:
        eprint(f"Error: Could not find tag or name in release data for {repo_name}")
        return None


def fetch_latest_version_ghcr(repo_name):
    """Fetches the latest version from the GitHub Container Registry."""
    (org, repo) = repo_name.split("/")
    response = GH.requester.requestJsonAndCheck(
        "GET",
        f"/orgs/{org}/packages/container/{repo}/versions",
    )[1]
    for release in response:
        if "latest" in release["metadata"]["container"]["tags"]:
            tags = release["metadata"]["container"]["tags"]
            search_prefix = "release-v"
            raw_version = None
            for tag in tags:
                if tag.startswith(search_prefix):
                    raw_version = tag
                    search_prefix = tag  # keep serching for a more specific version
            if not raw_version:
                eprint(f"Error: Could not find any 'release-v*' tags for {repo_name}")
                return None
            return raw_version
        else:
            eprint(f"Error: Could not find 'latest' tag for {repo_name}")
            return None


def clean(version):
    """Cleans a version string by removing leading 'v' and 'release-'."""
    if version and version.startswith("release-"):
        version = version[8:]
    if version and version.startswith("v"):
        version = version[1:]

    eprint(f"Stripped version: {version}")
    return version


def semver_same_up_to(a, b, level):
    """Compares two semantic versions and returns false if the difference is at or above the specified level."""
    semver_a = semver.Version.parse(clean(a))
    semver_b = semver.Version.parse(clean(b))

    if level == "patch" and semver_a == semver_b:
        return True

    semver_a = semver_a.replace(patch=0)
    semver_b = semver_b.replace(patch=0)
    if level == "minor" and semver_a == semver_b:
        return True

    semver_a = semver_a.replace(minor=0)
    semver_b = semver_b.replace(minor=0)
    if level == "major" and semver_a == semver_b:
        return True

    return False


def main():
    # Authenticate via GitHub token (Highly recommended for CI environments)
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        eprint("Error: GITHUB_TOKEN environment variable is not set.")
        sys.exit(1)

    auth = Auth.Token(token)
    global GH
    GH = Github(auth=auth)

    target_dep = sys.argv[1] if len(sys.argv) > 1 else None

    if not os.path.exists(TOML_PATH):
        eprint(f"Error: Could not find {TOML_PATH}")
        sys.exit(1)

    with open(TOML_PATH, "r") as f:
        lines = f.readlines()

    current_block = None
    repo_name = None
    repo_type = None
    repo_level = None
    changes_made = False

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Detect TOML table headers like [some_dep_one]
        if stripped.startswith("[") and stripped.endswith("]"):
            current_block = stripped[1:-1]
            repo_name = None
            repo_type = None
            repo_level = None
            continue

        # Skip other dependencies if a specific target is provided
        if target_dep and current_block != target_dep:
            continue

        # Extract the repo string
        if stripped.startswith("repo"):
            repo_match = re.search(r'repo\s*=\s*"([^"]+)"', stripped)
            if repo_match:
                repo_name = repo_match.group(1)

        # Extract the type string
        if stripped.startswith("type"):
            type_match = re.search(r'type\s*=\s*"([^"]+)"', stripped)
            if type_match:
                repo_type = type_match.group(1)

        # Extract the level string
        if stripped.startswith("level"):
            level_match = re.search(r'level\s*=\s*"([^"]+)"', stripped)
            if level_match:
                repo_level = level_match.group(1)

        # When we hit the version line, fetch and update
        elif stripped.startswith("version") and repo_name:
            version_match = re.search(r'version\s*=\s*"([^"]+)"', stripped)
            if version_match:
                current_version = version_match.group(1)
                eprint(f"Checking {current_block} ({repo_type}: {repo_name})...")
                eprint(f"Current version: {current_version}")

                latest_version = fetch_latest_version(repo_name, repo_type)

                if not latest_version:
                    continue

                if latest_version == current_version:
                    eprint(f" -> Already up to date ({current_version})")
                    continue

                if repo_level and semver_same_up_to(current_version, latest_version, repo_level):
                    eprint(f" -> Version is already at the same {repo_level} level ({current_version} -> {latest_version})")
                    continue

                print(f"{current_version} -> {latest_version}")
                eprint(
                    f" -> Updating from {current_version} to {latest_version}"
                )
                lines[i] = re.sub(
                    r'(version\s*=\s*)"[^"]+"',
                    f'\\g<1>"{latest_version}"',
                    line,
                )
                changes_made = True

    if changes_made:
        with open(TOML_PATH, "w") as f:
            f.writelines(lines)
        eprint("Successfully updated versions.toml!")
    else:
        eprint("No updates needed.")


if __name__ == "__main__":
    main()
