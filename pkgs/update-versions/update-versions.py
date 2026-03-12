import sys
import os
import re
from github import Github
from github import Auth

TOML_PATH = "modules/versions/versions.toml"


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def fetch_latest_version(g, repo_name):
    """Fetches the latest release using PyGithub and strips the leading 'v'."""
    try:
        repo = g.get_repo(repo_name)
        release = repo.get_latest_release()

        # Prefer the git tag, fallback to the release title/name
        raw_version = release.tag_name or release.title

        if not raw_version:
            eprint(
                f"Error: Could not find tag or name in release data for {repo_name}"
            )
            return None

        # Strip leading 'v' if it exists
        return raw_version[1:] if raw_version.startswith("v") else raw_version

    except Exception as e:
        eprint(f"Failed to fetch release for {repo_name}: {e}")
        return None


def main():
    # Authenticate via GitHub token (Highly recommended for CI environments)
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        eprint("Error: GITHUB_TOKEN environment variable is not set.")
        sys.exit(1)

    auth = Auth.Token(token)
    g = Github(auth=auth)

    target_dep = sys.argv[1] if len(sys.argv) > 1 else None

    if not os.path.exists(TOML_PATH):
        eprint(f"Error: Could not find {TOML_PATH}")
        sys.exit(1)

    with open(TOML_PATH, "r") as f:
        lines = f.readlines()

    current_block = None
    repo_name = None
    changes_made = False

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Detect TOML table headers like [some_dep_one]
        if stripped.startswith("[") and stripped.endswith("]"):
            current_block = stripped[1:-1]
            repo_name = None
            continue

        # Skip other dependencies if a specific target is provided
        if target_dep and current_block != target_dep:
            continue

        # Extract the repo string
        if stripped.startswith("repo"):
            repo_match = re.search(r'repo\s*=\s*"([^"]+)"', stripped)
            if repo_match:
                repo_name = repo_match.group(1)

        # When we hit the version line, fetch and update
        elif stripped.startswith("version") and repo_name:
            version_match = re.search(r'version\s*=\s*"([^"]+)"', stripped)
            if version_match:
                current_version = version_match.group(1)
                eprint(f"Checking {current_block} ({repo_name})...")

                latest_version = fetch_latest_version(g, repo_name)

                if latest_version and latest_version != current_version:
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
                elif latest_version == current_version:
                    eprint(f" -> Already up to date ({current_version})")

    if changes_made:
        with open(TOML_PATH, "w") as f:
            f.writelines(lines)
        eprint("Successfully updated version.toml!")
    else:
        eprint("No updates needed.")


if __name__ == "__main__":
    main()
