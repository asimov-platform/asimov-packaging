# Flatpak Package for ASIMOV Platform
This repository provides a Flatpak package for the [ASIMOV Platform]

## **Prerequisites**

- A Linux distribution with [Flatpak](https://flatpak.org/setup/) installed.
- The Freedesktop 24.08 runtime. If you haven't installed it already, run the command below to install it from Flathub:

    ```bash
    flatpak install flathub org.freedesktop.Platform//24.08
    ```

## Installation

1. Add the ASIMOV Platform Flatpak remote

```bash
flatpak remote-add --if-not-exists --user asimov-cli --no-gpg-verify https://asimov-platform.github.io/asimov-packaging
```

2. Install the [asimov-cli]

```bash
flatpak install asimov-cli so.asimov.cli
```

## Updating

To update to the latest version, simply run:
```bash
flatpak update com.asimov_platform.asimov_cli
```

## Usage

After installation, you can run the CLI with:

```bash
flatpak run so.asimov.cli --help
```

To check the version:

```bash
flatpak run so.asimov.cli --version
```

## Troubleshooting

If you encounter any issues with the runtime, please verify that the Freedesktop Platform 24.08 is installed. For additional help, refer to the  [Flatpak documentation](https://docs.flatpak.org/).

[ASIMOV Platform]: https://github.com/asimov-platform
[asimov-cli]: https://github.com/asimov-platform/asimov-cli
