# firmware-pipeline

Automated CI/CD pipeline for server firmware development using EDK2/UEFI. Every push and PR triggers:
- **Unit tests** for firmware logic (pure C, no EDK2 dependencies)
- **OVMF firmware build** (provides the UEFI environment)
- **Custom platform firmware build** (your actual firmware modules)
- **Boot-integration tests** (QEMU boots the firmware, captures output, validates behavior)

**Philosophy:** Write firmware logic once, test it twice — as standalone C unit tests *and* as real UEFI applications running in QEMU. The pipeline auto-discovers new modules, so adding features doesn't require CI changes.

---

## Project Structure

```
firmware-pipeline/
├── Source/FanControl/          # Example firmware module (fan control logic)
│   ├── FanControl.c/.h         # Pure C logic (testable without EDK2)
│   ├── FanControlApp.c         # UEFI application wrapper
│   └── FanControlApp.inf       # EDK2 module definition
├── Platform/
│   └── ServerPlatform.dsc      # Platform description (lists all firmware modules)
├── Tests/
│   ├── UnitTests/              # Standalone C tests (gcc, no EDK2)
│   │   └── test_fancontrol.c
│   └── BootTests/              # Integration tests (pytest, reads boot logs)
│       └── test_boot.py
├── scripts/
│   └── run_platform_boot_tests.sh  # Generic QEMU boot test script
└── .github/workflows/
    └── edk2-build.yml          # CI pipeline definition
```

---

## How the CI Pipeline Works

### 1. **Unit Tests** (fast, no firmware build required)
```
For every test_*.c file in Tests/UnitTests/:
  gcc compiles it with the pure C logic files from Source/
  Runs the test binary
  All assertions must pass
```

### 2. **Firmware Build**
```
Clone EDK2 → Install TianoCore tooling (stuart) → Build OVMF
Copy custom source into EDK2 tree → Build Platform/ServerPlatform.dsc
Result: FanControlApp.efi (and future modules) ready to run
```

### 3. **Boot-Integration Tests**
```
QEMU boots OVMF + custom apps → Captures serial output to boot_output.log
pytest runs Tests/BootTests/test_boot.py
Each test function checks for expected behavior in the log
```

**Key insight:** The boot test script (`run_platform_boot_tests.sh`) is **generic** — it auto-discovers all `.efi` apps and runs them. No hardcoded filenames. When you add a new module, you just add a new pytest function to check its output.

---

## Adding a New Firmware Module

Example: Adding a power sequencing driver

1. **Create the source:**
   ```
   Source/PowerSequencing/
   ├── PowerSequencing.c/.h       # Pure C logic
   ├── PowerSequencingApp.c       # UEFI wrapper
   └── PowerSequencingApp.inf     # EDK2 module definition
   ```

2. **Register it in the platform:**
   Edit `Platform/ServerPlatform.dsc`, add under `[Components]`:
   ```
   Source/PowerSequencing/PowerSequencingApp.inf
   ```

3. **Add a unit test:**
   ```
   Tests/UnitTests/test_powersequencing.c
   ```
   The CI auto-discovers and runs it.

4. **Add a boot-integration test:**
   Edit `Tests/BootTests/test_boot.py`, add:
   ```python
   def test_power_sequencing_stages_correctly():
       log = read_log()
       assert "Power stage 1 OK" in log
   ```

5. **Push.** The pipeline builds, boots, and tests everything automatically.

---

## Running Locally (Ubuntu/WSL)

### Install dependencies:
```bash
sudo apt update
sudo apt install -y build-essential nasm iasl uuid-dev \
  qemu-system-x86 python3 python3-pip xvfb gcc
pip install pytest
```

### Clone EDK2:
```bash
git clone --recursive --depth 1 https://github.com/tianocore/edk2.git
cd edk2
pip install --upgrade -r pip-requirements.txt
make -C BaseTools
```

### Build OVMF:
```bash
stuart_setup -c OvmfPkg/PlatformCI/PlatformBuild.py TOOL_CHAIN_TAG=GCC -a X64
stuart_update -c OvmfPkg/PlatformCI/PlatformBuild.py TOOL_CHAIN_TAG=GCC -a X64
stuart_build -c OvmfPkg/PlatformCI/PlatformBuild.py TOOL_CHAIN_TAG=GCC -a X64
```

### Build your custom platform:
```bash
# From the firmware-pipeline repo root:
mkdir -p edk2/Source edk2/Platform
cp -r Source/* edk2/Source/
cp Platform/ServerPlatform.dsc edk2/Platform/

cd edk2
source edksetup.sh
build -p Platform/ServerPlatform.dsc -a X64 -t GCC -b DEBUG
```

### Run boot tests:
```bash
# From the firmware-pipeline repo root:
bash scripts/run_platform_boot_tests.sh
pytest Tests/BootTests/ -v
```

### Run unit tests:
```bash
gcc -I Source/FanControl Tests/UnitTests/test_fancontrol.c Source/FanControl/FanControl.c -o /tmp/test
/tmp/test
```

---

## Current Modules

- **FanControl** — Temperature-based fan speed control with tiered thresholds

## Roadmap

- [ ] Thermal monitoring driver (read real sensor data)
- [ ] Power sequencing (controlled power-on stages)
- [ ] BMC integration (OpenBMC build + test in separate job)
- [ ] Hardware-in-the-loop testing (real server boot validation)