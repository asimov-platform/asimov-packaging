# Snap Package for ASIMOV Platform

This repository provides the Snap package for the [ASIMOV Platform]

## **Prerequisites**

- A Linux distribution with [Snap support](https://snapcraft.io/docs/installing-snapd).
- Snapd installed and enabled.
- `wget` (for downloading the `.snap` file).

## **Download**

The Snap package will be downloaded into the `asimov` directory inside the home folder (`~/asimov`).

```bash
# Create and navigate to the download directory
mkdir -p ~/asimov && cd ~/asimov

# Detect architecture
ARCH="$(uname -m)"

# Detect libc (musl or glibc)
if ldd --version 2>&1 | grep -qi musl; then
  LIBC="musl"
else
  LIBC="gnu"
fi

# Map to the correct snap name
case "$ARCH-$LIBC" in
  x86_64-gnu)
    SNAP_NAME="asimov-x86-gnu.snap"
    ;;
  x86_64-musl)
    SNAP_NAME="asimov-x86-musl.snap"
    ;;
  aarch64-gnu)
    SNAP_NAME="asimov-arm-gnu.snap"
    ;;
  aarch64-musl)
    SNAP_NAME="asimov-arm-musl.snap"
    ;;
  *)
    echo "❌ Unsupported architecture or libc: $ARCH-$LIBC"
    exit 1
    ;;
esac

# Download the snap file from the latest release
wget "https://github.com/asimov-platform/asimov-packaging/releases/latest/download/$SNAP_NAME" -O asimov-cli.snap
```

## Installation

Once the download is complete, install the Snap package locally in classic mode using:

```bash
sudo snap install --dangerous --classic ~/asimov/asimov-cli.snap
```

## Usage

After installation, you can run the CLI with:

```bash
asimov --help
```

To check the installed version:

```bash
asimov --version
```

## Troubleshooting

If the Snap does not run as expected, check the logs:

```bash
snap logs asimov-cli
```

Ensure that Snap is installed and enabled on your system:

```bash
snap version
```

For additional help, refer to the [Snapcraft documentation](https://snapcraft.io/docs).

[ASIMOV Platform]: https://github.com/asimov-platform
[asimov-cli]: https://github.com/asimov-platform/asimov-cli
