# assets

放二进制/生成物（不入库或走 Release 下载）：

- `rk3568-jl-rm01.dtb`：运行中内核设备树（从 HAOS boot 分区提取后放入
  `platform-files/rockchip/bootfs/dtb/rockchip/`）。
- `idbloader-rm01-pmic-src-no-optee.img` + `u-boot-rm01-recovery-loader-v17.itb`：
  U-Boot 方案 B 使用的预编译文件。

## 提取命令（设备上执行）

```bash
# 从运行中的 HAOS boot 分区提取 dtb
mkdir -p /tmp/dtb && cp /boot/dtb/rockchip/rk3568-jl-rm01.dtb /tmp/dtb/ 2>/dev/null
# 或从线刷包 Image/hassos-boot.img 中解出
```
