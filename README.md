# Houzzkit F1 Armbian（rambian）

基于 [mozzie1121/amlogic-s9xxx-armbian](https://github.com/mozzie1121/amlogic-s9xxx-armbian)
（ophub 构建体系）适配 RK3568-JL-RM01（Houzzkit F1）的 Armbian 镜像项目，走 GitHub
Actions 云打包路线。

## 设备信息

| 项目 | 值 |
| --- | --- |
| SoC | Rockchip RK3568（3568A） |
| 型号 | Houzzkit F1 / SZZN RK3568-JL-RM01 |
| 内存/eMMC | 4GB LPDDR4X / 三星 32GB eMMC |
| 调试串口 | UART2（`serial@fe660000`，1500000） |
| Zigbee | 主板 8pin 立式座外接模块，ttyS3（UART3） |
| 现有 bootchain | idbloader @ LBA 0x40 + U-Boot FIT @ LBA 0x4000（no-OPTEE） |
| Recovery | 按住 Recovery 上电进 RockUSB LOADER |

## 文档

- [适配方案](docs/ADAPTATION-PLAN.md)
- [云构建工作流](.github/workflows/build-armbian-houzzkit-f1.yml)
- [设备 boot 配置草稿](device/houzzkit-f1/armbianEnv.txt)
