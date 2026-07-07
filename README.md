# Yosys OpenROAD Nangate45 Lab

이 저장소는 **Yosys 합성**과 **OpenROAD 물리 구현**을 이용해 RTL에서 **CTS, routing, GDS**까지 한 번에 따라갈 수 있도록 정리한 실습용 환경이다.  
기본 예제는 `OpenROAD-flow-scripts`(ORFS)의 **Nangate45 / gcd** 디자인을 사용한다.

## 1. 배경 지식

이 흐름에서 각 도구의 역할은 다음과 같다.

| 도구 | 역할 |
| --- | --- |
| Yosys | Verilog/SystemVerilog RTL을 합성해 게이트 수준 넷리스트를 생성 |
| OpenROAD | floorplan, placement, CTS, routing, finishing, signoff report 수행 |
| OpenROAD-flow-scripts | Yosys + OpenROAD + KLayout 실행을 묶은 자동화 플로우 |
| Nangate45 | 공개 표준셀 기반 45nm 예제 플랫폼 |
| KLayout | 최종 GDS 생성과 일부 물리 검증 단계에 사용 |

흐름 자체는 대략 아래 순서로 진행된다.

1. **Synthesis**: RTL을 표준셀 넷리스트로 변환
2. **Floorplan**: 코어 크기, utilization, PDN, I/O 배치 준비
3. **Placement**: 표준셀 배치와 timing/congestion 보정
4. **CTS**: clock tree 합성
5. **Routing**: global/detail routing
6. **Finish**: fill, DEF/GDS/최종 넷리스트/리포트 생성

## 2. 저장소 구성

이 저장소는 **내가 추가한 스크립트/문서**와 **외부 의존 프로젝트(submodule)** 를 분리해 둔다.

| 경로 | 설명 |
| --- | --- |
| `scripts/setup-toolchain.sh` | Yosys/OpenROAD를 로컬 prefix에 빌드/설치 |
| `scripts/run-nangate45-gcd.sh` | 검증된 Nangate45 gcd 샘플 플로우 실행 |
| `submodules/yosys` | Yosys 서브모듈 |
| `submodules/openroad` | OpenROAD 서브모듈 |
| `submodules/openroad-flow-scripts` | ORFS 서브모듈 |
| `.toolchain/` | 빌드 결과 설치 prefix (git ignore) |
| `build/` | out-of-tree build 디렉터리 (git ignore) |
| `work/` | ORFS 결과물/로그/리포트 저장 경로 (git ignore) |

핵심은 **서브모듈은 원본 그대로 두고**, **내가 추가한 파일은 루트와 `scripts/` 아래만 관리**하는 것이다.

## 3. 의존 패키지

이 저장소는 시스템 패키지를 직접 설치하지 않는다. 아래 패키지는 먼저 사용자가 설치해야 한다.

### Ubuntu / Debian 예시

```bash
sudo apt update
sudo apt install -y --no-install-recommends \
  build-essential clang bison flex pkg-config \
  libreadline-dev libffi-dev git python3 python3-pip \
  cmake ninja-build tcl-dev tk-dev libeigen3-dev \
  libboost-all-dev libsqlite3-dev libx11-dev \
  libglu1-mesa-dev libglew-dev qtbase5-dev libqt5svg5-dev \
  libspdlog-dev zlib1g-dev libssl-dev libncurses-dev \
  graphviz doxygen autoconf automake libtool ccache \
  magic netgen klayout
```

### 실제로 중요한 최소 구성

- **빌드 도구**: `git`, `cmake`, `ninja`, `gcc/g++`, `make`, `pkg-config`
- **Yosys 빌드용**: `bison`, `flex`, `python3`, `tcl`, `readline`, `zlib`, `libffi`
- **OpenROAD 빌드용**: `boost`, `eigen`, `sqlite3`, `x11`, `glew`, `qt`, `spdlog`
- **플로우 마무리용**: `klayout`

## 4. 처음 받는 방법

새 GitHub 저장소에 올린 뒤 다른 환경에서 받을 때는 반드시 **submodule까지 같이** 받아야 한다.

```bash
git clone --recurse-submodules <your-repo-url>
cd yosys-openroad-nangate45-lab
```

이미 clone한 뒤라면:

```bash
git submodule update --init --recursive
```

## 5. 툴체인 빌드

이 저장소는 기본적으로 `$REPO/.toolchain` 아래에 로컬 설치한다.  
그래서 `~/.local` 같은 전역 사용자 경로를 오염시키지 않는다.

```bash
chmod +x scripts/setup-toolchain.sh
./scripts/setup-toolchain.sh
```

빌드가 끝나면 주요 바이너리는 아래에 생긴다.

```text
.toolchain/bin/yosys
.toolchain/bin/openroad
```

버전 확인:

```bash
./.toolchain/bin/yosys -V
./.toolchain/bin/openroad -v
```

## 6. 검증된 샘플 플로우 실행

현재 이 저장소에서 검증한 샘플은 **ORFS의 `nangate45/gcd`** 이다.

```bash
chmod +x scripts/run-nangate45-gcd.sh
./scripts/run-nangate45-gcd.sh
```

이 스크립트는 다음을 보장한다.

- ORFS 서브모듈 내부를 직접 더럽히지 않음
- 결과물은 `work/openroad-flow-scripts/` 아래에 모음
- `OPENROAD_EXE`, `YOSYS_EXE`, `KLAYOUT_CMD` 를 명시적으로 넘겨 버전 불일치 방지

생성되는 주요 결과물:

```text
work/openroad-flow-scripts/results/nangate45/gcd/base/6_final.gds
work/openroad-flow-scripts/results/nangate45/gcd/base/6_final.def
work/openroad-flow-scripts/results/nangate45/gcd/base/6_final.v
work/openroad-flow-scripts/reports/nangate45/gcd/base/
work/openroad-flow-scripts/logs/nangate45/gcd/base/
```

## 7. 커스텀 디자인으로 확장할 때

가장 쉬운 방법은 ORFS의 기존 디자인 디렉터리를 참고하는 것이다.

예:

```text
submodules/openroad-flow-scripts/flow/designs/nangate45/gcd/
```

보통 아래 입력이 필요하다.

- RTL 또는 합성 대상 Verilog
- SDC 제약 파일
- 플랫폼 정보(lib/lef)는 ORFS의 공개 플랫폼 사용 또는 별도 플랫폼 준비

직접 실행 예시는 아래와 같다.

```bash
cd submodules/openroad-flow-scripts/flow
make DESIGN_CONFIG=./designs/nangate45/gcd/config.mk \
  WORK_HOME="$PWD/../../../work/openroad-flow-scripts" \
  OPENROAD_EXE="$PWD/../../../.toolchain/bin/openroad" \
  YOSYS_EXE="$PWD/../../../.toolchain/bin/yosys" \
  KLAYOUT_CMD="$(command -v klayout)"
```

## 8. 왜 apt의 yosys 대신 로컬 빌드를 쓰는가

이 저장소에서 검증하면서 확인한 문제는 다음과 같다.

- Ubuntu apt의 `yosys 0.33` 은 최신 ORFS 스크립트가 사용하는 `read_liberty` 옵션 조합과 호환되지 않을 수 있음
- 그래서 ORFS synthesis 단계가 초반에 실패할 수 있음

이 저장소의 `setup-toolchain.sh` 는 이 문제를 피하려고 **최신 Yosys를 서브모듈에서 직접 빌드**한다.

## 9. 추천 사용 순서

1. 시스템 패키지 설치
2. `git clone --recurse-submodules`
3. `./scripts/setup-toolchain.sh`
4. `./scripts/run-nangate45-gcd.sh`
5. `work/openroad-flow-scripts/results/.../6_final.gds` 확인

## 10. 트러블슈팅

### `klayout` 이 없다고 나올 때

```bash
command -v klayout
```

없으면 시스템 패키지 설치가 먼저 필요하다.

### 서브모듈이 비어 있을 때

```bash
git submodule update --init --recursive
```

### OpenROAD-flow-scripts가 다른 yosys를 잡을 때

이 저장소의 실행 스크립트는 `YOSYS_EXE` 를 명시적으로 넘기므로 보통 발생하지 않는다.  
직접 `make` 를 치는 경우에는 `.toolchain/bin/yosys` 를 지정하는 편이 안전하다.

### 결과물이 안 보일 때

기본 결과 경로는 서브모듈 내부가 아니라 아래다.

```text
work/openroad-flow-scripts/results/
```
