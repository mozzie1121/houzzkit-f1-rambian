# assets

放二进制/生成物（不入库或走 Release 下载）：

- `rk3568-jl-rm01.dtb`：已放入
  `overlay/platform-files/rockchip/bootfs/dtb/rockchip/`（SHA-256
  `16523c4fae0f3c139d028e707830a15d57b6ce0dac735b083a00eb29d4307f4e`）。
  基于 `rk3568-jl-rm01-uart3m1.dtb`（Zigbee UART3 M1），并把 UART2
  （serial@fe660000）打开作为 Armbian 串口控制台。
- `idbloader-rm01-pmic-src-no-optee.img` + `u-boot-rm01-recovery-loader-v17.itb`：
  U-Boot 方案 B 使用的预编译文件。

## 重新生成 dtb

```bash
bash scripts/build-armbian-dtb.sh \
  <haos-kernel>/arch/arm64/boot/dts/rockchip/rk3568-jl-rm01-uart3m1.dtb \
  overlay/platform-files/rockchip/bootfs/dtb/rockchip/rk3568-jl-rm01.dtb
```
