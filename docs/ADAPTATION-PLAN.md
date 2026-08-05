# Houzzkit F1 Armbian 适配方案

## 1. 目标

基于 `amlogic-s9xxx-armbian`（ophub 体系，已支持 rockchip/rk3568 家族）新增
`houzzkit-f1` 设备，产出可在 TF/SD/USB 启动、可安装到 eMMC 的 Armbian 镜像，
并通过 GitHub Actions 云端自动打包发布。

## 2. 现状与可复用资产

- 上游仓库已具备 rockchip 平台：`platform-files/rockchip`、`different-files/<board>`、
  `model_database.conf` 设备注册表、GitHub Actions 云构建工作流。
- 可直接参考的 rk3568 模板：`rock-3b`、`r66s`、`mrkaio-m68s`、`nsy-g16-plus`。
- 本项目已有资产：
  - 稳定 bootchain：`idbloader-rm01-pmic-src-no-optee.img`（LBA 0x40）
    + `u-boot-rm01-recovery-loader-v17.itb`（LBA 0x4000，recovery 进 RockUSB LOADER）。
  - 设备树源码 `rk3568-jl-rm01.dts` / 运行中内核 dtb（可从 HAOS boot 分区提取）。
  - 已验证的硬件细节：NPU、PMIC（no-OPTEE）、Zigbee UART3（ttyS3）、eMMC GPT。

## 3. 接入点（上游机制）

### 3.1 设备注册表

`build-armbian/armbian-files/common-files/etc/model_database.conf` 新增一行：

```text
<ID>  :Houzzkit-F1  :rk3568  :rk3568-jl-rm01.dtb  :NA  :u-boot.itb  :idbloader.img  :4GB-LPDDR4,32G-eMMC,Zigbee  :rk35xx/6.1.y  :rockchip  :rk3568  :armbianEnv.txt  :mozzie1121  :houzzkit-f1  :yes
```

### 3.2 设备文件

`build-armbian/armbian-files/different-files/houzzkit-f1/`：

```text
bootfs/
  armbianEnv.txt     # fdtfile=rockchip/rk3568-jl-rm01.dtb, console=ttyS2,1500000
  boot.cmd / boot.scr
rootfs/
  etc/armbian-board-release.conf   # 高级定制：写 bootloader、skip_mb 等
```

### 3.3 设备树

两条路径（可并行）：

1. 将 `rk3568-jl-rm01.dtb` 放入
   `build-armbian/armbian-files/platform-files/rockchip/bootfs/dtb/rockchip/`，
   随镜像发布（适合快速起步）。
2. 将 `rk3568-jl-rm01.dts` 以 patch 形式合入 Armbian 内核（rk35xx 系列），
   这样内核发布包自带 dtb，升级内核不丢设备支持。

### 3.4 U-Boot

方案 A（推荐起步）：保留现有 eMMC bootchain，Armbian 镜像不覆盖
bootloader 区（`skip_mb` + `write_board_bootloader` 仅写系统分区）。
我们的 v17 U-Boot 已能正常加载 extlinux/boot.scr 启动 HAOS，先验证其
加载 Armbian `/boot`（Image + uInitrd + dtb）的兼容性。

方案 B（后续）：在 `ophub/u-boot` 体系新增 `houzzkit-f1` 目录，放入
`idbloader.img` + `u-boot.itb`（v17），让云构建直接产出含完整 bootchain
的镜像。

### 3.5 云构建

采用 **overlay 云构建**（本仓库 = 轻量设备层）：

1. 从 Armbian 官方下载 rock-3a（RK3568）底包（默认 noble vendor minimal）
   作为 rootfs 基础，随后由 rebuild 替换内核/dtbs/u-boot 为 houzzkit-f1 配置。
2. GitHub Actions checkout 上游 `amlogic-s9xxx-armbian`，
   `scripts/apply-overlay.sh` 把 `overlay/` 合并进上游树
   （different-files、platform-files、model_database 行）。
3. 调用上游 composite action（`armbian_path` 传底包 URL），`-b houzzkit-f1` 构建。
4. 产物上传 Releases。

这样无需把整个上游 fork 进来，也不依赖上游仓库先合并我们的设备。
后续若上游合入设备支持，可切换到纯上游 workflow。

## 4. 里程碑

| 阶段 | 内容 | 状态 |
| --- | --- | --- |
| M0 | 立项：方案文档 + 仓库骨架 + 云工作流草稿 | 进行中 |
| M1 | 内核/设备树：dtb 已放入 overlay（uart3m1 底 + uart2 控制台开启）；待验证 rk35xx 内核可启动；补 NPU/网卡配置 | 部分完成 |
| M2 | U-Boot：验证 v17 直接启动 Armbian；确定 A/B 方案 | 未开始 |
| M3 | 设备接入：model_database 行（r232）+ different-files 文件已就绪 | 草稿完成 |
| M4 | 云打包：工作流跑通，产出 img.gz | 未开始 |
| M5 | 实机验证：TF/USB 启动、eMMC 安装、外设 | 未开始 |

## 5. 已知风险

- `rebuild` 对 rockchip 平台会移除 `usr/sbin/armbian-install`，eMMC 安装需
  自定义流程（保留 bootchain + dd 系统分区，或镜像内自带安装脚本）。
- mainline 内核与厂商驱动的差异：NPU（rknpu）、Zigbee、网络 PHY 需要实测。
- 厂商 U-Boot（含我们的 v17）需要确认 extlinux/boot.scr 启动参数兼容 Armbian。
- ophub/kernel 的 rk35xx 内核包默认不带 `rk3568-jl-rm01.dtb`，M1 需确认
  dtb 落地路径。

## 6. 交付物

- 可刷写的 Armbian 镜像（img.gz，含 bootchain 或不含、按方案 A/B 定）。
- 云构建工作流 + Releases 自动发布。
- 设备接入改动以 PR 形式提交到 `amlogic-s9xxx-armbian` 上游仓库。
