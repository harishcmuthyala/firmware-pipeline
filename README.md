# firmware-pipeline

Automated CI/CD pipeline that builds EDK2's OVMF firmware and boot-tests it in QEMU on every push and pull request.

**Status:** just getting started — OVMF build + boot check working. Custom UEFI apps and OpenBMC CI are planned.

---

## How it works

```
Push / PR
   → GitHub Actions runner (Ubuntu)
   → Build OVMF
   → Boot it headlessly in QEMU
   → Confirm it reaches the UEFI Shell
   → Pass/fail reported on the commit / PR
```

---

## Running it locally in Ubuntu.

```bash
sudo apt update && sudo apt install -y build-essential nasm iasl uuid-dev qemu-system-x86 git python3

git clone --recursive https://github.com/tianocore/edk2.git
cd edk2
source edksetup.sh
build -p OvmfPkg/OvmfPkgX64.dsc -a X64 -t GCC5 -b DEBUG
```