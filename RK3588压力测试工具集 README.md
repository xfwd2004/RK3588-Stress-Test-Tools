# RK3588 整机压力测试工具集

## 项目简介
该脚本套件用于 **RK3588** 平台整机压力稳定性测试，可同时对 CPU、内存 MEM、GPU、NPU 进行加压，并且实时采集 CPU占用、内存占用、GPU负载&频率、NPU负载&频率、各模块温度，输出日志文件，用于长时间稳定性、功耗、温度、降频、死机稳定性验证。

### 文件清单（全部放在 `/root/rk3588_stress`）

| 文件 | 作用 |
|---|---|
| `monitor.sh` | 综合资源监控脚本，采集CPU/MEM/GPU/NPU/温度，5秒采样，输出带时间戳log |
| `monitor_temp.sh` | 独立温度CSV监控脚本，2秒采样，输出csv格式方便后期绘图 |
| `cpu_stress.sh` | CPU压力脚本，8核80%负载 matrixprod运算加压 |
| `mem_stress.sh` | 内存压力脚本，占用总内存80%做内存压力 |
| `gpu_stress.sh` | GPU压力脚本，使用glmark2‑es2离屏持续跑benchmark加压 |
| `npu_stress.py` | NPU压力Python脚本，多线程调用RKNNLite跑yolov8.rknn模型压NPU 3核 |
| `npu_stress.sh` | NPU压力启动shell封装（调用虚拟环境） |
| `start_stress.sh` | **一键启动全套压力（CPU+MEM+GPU+NPU+monitor.sh）** |
| `stop_stress.sh` | **一键停止所有压力程序，清理残留进程** |
| `rk3588_full_stress.sh` | 旧版完整压力脚本（注意：内部调用npu_test.sh，本套件没有该文件，建议优先使用`start_stress.sh`） |

> ⚠️ 注意：`rk3588_full_stress.sh` 脚本内部调用`npu_test.sh`，仓库无此文件，请不要直接运行，优先使用`start_stress.sh`。

---

## 一、依赖软件与环境安装

### 1. 系统工具依赖
```bash
# 更新源
apt update
apt install -y stress-ng glmark2-es2 mesa-utils bc
```
- `stress‑ng`：CPU、内存压力工具
- `glmark2‑es2`：GPU压力测试工具，RK3588 开源图形压测
- `bc`：shell浮点运算依赖
- `mesa‑utils`：图形库依赖

### 2. NPU运行环境（RKNN）
> npu_stress.py依赖 rknnlite，需要RKNN SDK的python包，需要构建python虚拟环境

#### 2.1 创建虚拟环境（脚本默认路径 `/root/test/rknn_venv`）
```bash
# 安装虚拟环境工具
apt install -y python3-venv python3-pip
mkdir -p /root/test
cd /root/test
python3 -m venv rknn_venv
source rknn_venv/bin/activate

# 安装依赖包
pip install numpy
# 重点：安装rknnlite，需要把RKNN SDK中的rknn_api wheel包拷贝过来安装
# 示例，替换成你实际的rknn_lite的whl路径
pip install ./rknn_api/python/rknn_toolkit_lite2-*.whl
```
> 重要：`rknn_toolkit_lite2` 是瑞芯微RK3588板端SDK包，需要从官方RKNN SDK包获取，公网不能直接pip安装。

#### 2.2 模型准备
脚本`npu_stress.py`写死模型路径：
```python
MODEL_PATH = "/home/linaro/yolov8/yolov8.rknn"
```
1. 将yolov8转换得到的 **yolov8.rknn** 放到路径 `/home/linaro/yolov8/yolov8.rknn`
2. 或者修改npu_stress.py中MODEL_PATH变量修改模型路径。
> 模型必须是适配RK3588的rknn格式，int8量化模型。

---

## 二、部署步骤
1. 创建工作目录
```bash
mkdir -p /root/rk3588_stress
cd /root/rk3588_stress
```
2. 将所有sh脚本、npu_stress.py复制到此目录
3. 添加执行权限
```bash
chmod +x *.sh
chmod +x npu_stress.py
```

---

## 三、使用说明

### 3.1 一键启动全部压力（CPU+MEM+GPU+NPU+资源监控）
```bash
cd /root/rk3588_stress
./start_stress.sh
```
启动输出提示：
```
============================
RK3588 Stress Start
============================

Stress running

Monitor log:
tail -f logs/*.log

NPU log:
cat /tmp/npu_stress.log

Stop:
./stop_stress.sh
```

### 3.2 查看实时日志
1. 综合监控日志（CPU/MEM/GPU/NPU/温度）
```bash
tail -f /root/rk3588_stress/logs/stress_*.log
```
2. NPU运行日志
```bash
tail -f /tmp/npu_stress.log
```
3. GPU运行日志
```bash
tail -f /tmp/gpu1.log /tmp/gpu2.log
```
4. 独立温度csv监控（可选，手动单独运行）
```bash
./monitor_temp.sh
# 输出文件 /root/rk3588_stress/temp.log 逗号分隔csv，可以导入excel绘图
```

### 3.3 停止全部压力测试
> ⚠️ 不要直接Ctrl‑C，部分后台进程不会退出，务必执行停止脚本
```bash
cd /root/rk3588_stress
./stop_stress.sh
```
脚本会读取pid文件kill进程，并且pkill清理stress‑ng、glmark2等残留进程，最后打印剩余压力进程确认。

### 3.4 单独启动某一项压力（调试用）
```bash
#仅CPU压力
./cpu_stress.sh

#仅内存压力
./mem_stress.sh

#仅GPU压力
./gpu_stress.sh

#仅NPU压力（两种方式）
source /root/test/rknn_venv/bin/activate
python3 npu_stress.py

#或者调用封装脚本
./npu_stress.sh

#仅监控，不加压
./monitor.sh
```

---

## 四、日志说明
1. monitor.sh日志目录：`/root/rk3588_stress/logs/`
文件名示例：`stress_20261028_152230.log`
每行输出格式：
```
2026‑10‑28 15:22:35 | CPU:98.2% | MEM:78.3% | GPU:96@800MHz | NPU:C0:99% C1:98% C2:97%@1000MHz | TEMP:soc:78C big0:79C big1:77C center:76C gpu:78C npu:80C
```

2. monitor_temp.sh输出 `temp.log` csv格式
```
time,soc,cpu_big,cpu_little,gpu,npu
15:22:10,76,78,72,77,79
```
可以直接用excel、python pandas读取做温度曲线图。

3. NPU日志 `/tmp/npu_stress.log`：输出每个线程实时FPS，观察NPU推理性能。

---

## 五、常见问题
### Q1 NPU脚本启动失败 load failed
1. 检查模型文件 `/home/linaro/yolov8/yolov8.rknn` 是否存在，权限可读
2. 确认使用rknn_venv虚拟环境，已经正确安装rknn_toolkit_lite2
3. RKNNLite只支持板端运行，不能在PC上运行

### Q2 GPU负载一直为0
1. glmark2‑es2必须正常安装；
2. RK3588内核开启devfreq，`/sys/class/devfreq/fb000000.gpu`目录存在；
3. 使用off‑screen离屏渲染，不需要接显示器。

### Q3 温度读取为空
不同RK3588固件thermal_zone type名称略有差异，如果读不到温度，可以cat查看：
```bash
cat /sys/class/thermal/thermal_zone*/type
```
核对type名字，修改monitor.sh monitor_temp.sh里面case匹配字符串。

### Q4 stop之后stress‑ng进程残留
stop_stress.sh里面有pkill兜底，如果还有残留手动执行：
```bash
pkill -9 stress-ng
pkill -9 glmark2-es2
```

### Q5 内存压力OOM重启
mem_stress.sh默认占用总内存80%，如果板子内存较小，修改mem_stress.sh，降低`MEM_USE=$((MEM_TOTAL*80/100))`中的80改为60/70。

---

## 六、长时间测试建议
1. 测试前确认散热方案；
2. 建议把日志挂载到非系统盘，防止日志占满根分区；
3. 可以配合`dmesg -w`观察内核报错、降频、OOM；
4. 建议测试时间：2h~72h长时间烤机。

---

## 七、目录结构完整参考
```
/root/rk3588_stress/
├── monitor.sh
├── monitor_temp.sh
├── cpu_stress.sh
├── mem_stress.sh
├── gpu_stress.sh
├── npu_stress.py
├── npu_stress.sh
├── start_stress.sh
├── stop_stress.sh
├── rk3588_full_stress.sh
├── logs/          # monitor.sh自动生成，存放压力log
├── cpu.pid
├── mem.pid
├── gpu.pid
├── gpu_child.pid
├── npu.pid
└── monitor.pid
```

> pid文件是脚本运行时动态生成，停止测试后可以手动删除。
