# YOLO26 NU4100 Demo 操作指导

**适用对象**：拿到本 Demo 包、需要在 Windows PC + NU4100 评估套件上演示 YOLO26 全家族模型的工程师或客户演示人员。

**包版本**：2026-10-09（对应应用程序 example_yolo26 v2.1，2026-10-08 构建）

---

## 1. Demo 简介

本 Demo 在 Inuitive NU4100 NPU 上运行完整的 YOLO26 模型家族，共 **5 类任务、8 个可选网络**：

| 任务 | 网络 | 输入尺寸 |
| --- | --- | --- |
| 目标检测 | Yolo26m / Yolo26n | 320×320、640×640 |
| 实例分割 | Yolo26n-seg | 640×384 |
| 人体骨架姿态 | Yolo26n-pose | 640×384 |
| 手掌/手部姿态 | Yolo26n-palm | 320×320 |
| 单目深度 | Yolo26n-depth | 640×640 |

每种网络均支持三种输入方式：**实时相机**（菜单 1–8）、**视频文件注入**（菜单 9–16，使用包内自带演示视频）、**批量图片调试**（隐藏菜单 94/96/97/98，处理 `input_images\` 目录）。

结果通过 OpenCV 窗口可视化：检测框、类别标签、分割掩膜、骨架连线、深度伪彩图、FPS、按类别目标计数等，并可按键录制 MP4。

---

## 2. 包内容清单

```
Yolo26_NU4100_Demo20261009\
├── run_yolo26_demo_admin.bat    ★ 主启动脚本（右键"以管理员身份运行"）
├── restore_boot_admin.bat       ★ 应急恢复脚本（异常退出后恢复固件用）
├── README_操作指导.md           本文档
├── VERSION.txt                  版本信息
├── example_yolo26.exe           Demo 主程序（勿改名、勿移出本目录）
├── opencv_world480.dll          OpenCV 运行库（程序依赖，勿删除）
├── opencv_videoio_ffmpeg480_64.dll  视频解码插件（视频注入模式必需，勿删除）
├── sw_graph_boot10311.xml       传感器启动描述文件
├── demo_video.mp4               检测任务注入视频
├── demo_video_seg.mp4           分割/深度任务注入视频
├── demo_pose.mp4                人体姿态注入视频
├── demo_hand_pose.mp4           手掌姿态注入视频
├── YOLO_NETS\                   8 个网络模型 + 标签文件 + Demo 专用固件
│   ├── nn_bin_yolov26_320/640.bin         (检测 Yolo26m)
│   ├── nn_bin_yolov26n_320/640.bin        (检测 Yolo26n)
│   ├── nn_bin_yolov26n_seg.bin            (实例分割)
│   ├── nn_bin_yolov26n_pose.bin           (人体姿态)
│   ├── nn_bin_yolov26n_palm.bin           (手掌姿态)
│   ├── nn_bin_yolov26n_depth.bin          (单目深度)
│   ├── labels_80.txt / pose_labels_1.txt / palm_labels.txt / depth_labels.txt
│   └── cnn_boot_app.bin        Demo 专用 NPU 固件（支持片上后处理）
├── input_images\                批量调试模式的输入图片（可自行替换）
└── result_images\               批量调试模式的输出目录（自动生成）
```

> 注意：整个文件夹必须**保持完整放在同一目录**下运行，不要单独移动 exe 或 YOLO_NETS。

---

## 3. 运行前提

| 项目 | 要求 |
| --- | --- |
| 操作系统 | Windows 10/11 **64 位** |
| InuDev SDK | 已安装 InuDev（默认路径 `C:\Program Files\Inuitive\InuDev`），推荐 **4.39** 版（4.36 通常也可运行，脚本仅提示警告） |
| 相机 | NU4100 评估套件/模组已通过 USB 连接并上电 |
| 运行库 | Microsoft VC++ 2015–2022 x64 Redistributable（多数机器已自带；缺失时程序报 `VCRUNTIME140.dll`/`MSVCP140.dll` 错误，安装即可） |
| 权限 | 需要**管理员权限**（脚本要替换固件文件并重启 InuService 服务） |
| 显示 | 需要有桌面环境（OpenCV 弹窗），不能在纯远程命令行下运行 |

---

## 4. 快速开始（三步）

1. **连接相机**：NU4100 通过 USB 接入 PC，确认 InuService 服务已随 InuDev 安装并在运行。
2. **启动 Demo**：在包目录中找到 `run_yolo26_demo_admin.bat`，**右键 → 以管理员身份运行**。
   - 脚本会自动完成：环境检查 → 备份原厂固件 `cnn_boot_app.bin` → 替换为 Demo 专用固件 → 重启 InuService → 启动 Demo。
3. **选择模式**：程序启动后显示菜单，输入数字回车：
   - `1` = 实时相机 Yolo26n 320×320 检测（最快，约 52 FPS，推荐首次演示用）
   - `9` = 视频注入检测（无需对准场景，直接播放包内 demo_video.mp4）
   - `8` = 实时相机单目深度，`5` = 实时实例分割，`6` = 人体姿态，`7` = 手掌姿态
   - `17` = **实时检测 + 立体深度（D2C 对齐）**，点选图像即可读数物体距离（详见 §5）

4. **切换演示 / 结束会话**：在视频窗口按 **Q** 或 **ESC** 结束当前演示，程序退出后脚本窗口提示
   `Press C for another demo, Q to finish and restore:`——按 **C** 立即回到程序菜单选择其他示例
   （固件保持替换状态，不重启服务，切换零等待）；按 **Q** 结束整个演示，脚本自动恢复原厂固件
   并重启 InuService。

---

## 5. 模式选择菜单详解

程序启动后显示：

```text
 1: Live  Yolo26m       (320x320 detection)      ← 实时相机
 2: Live  Yolo26m       (640x640 detection)
 3: Live  Yolo26n       (320x320 detection)
 4: Live  Yolo26n       (640x640 detection)
 5: Live  Yolo26n-seg   (640x384 segmentation)
 6: Live  Yolo26n-pose  (640x384 body skeleton pose)
 7: Live  Yolo26n-palm  (320x320 hand/palm pose)
 8: Live  Yolo26n-depth (640x640 depth)
 9: Video Yolo26m       (320x320 detection)      ← 视频注入
10: Video Yolo26m       (640x640 detection)
11: Video Yolo26n       (320x320 detection)
12: Video Yolo26n       (640x640 detection)
13: Video Yolo26n-seg   (640x384 segmentation)
14: Video Yolo26n-pose  (640x384 body skeleton pose)
15: Video Yolo26n-palm  (320x320 hand/palm pose)
16: Video Yolo26n-depth (640x640 depth)
17: Live  Yolo26n + StereoDepth (D2C aligned, click RGB for depth)
```

- **实时（Live，1–8）**：使用相机 RGB 流，NPU 在固件内完成 letterbox 缩放。
- **视频注入（Video，9–16）**：解码本地 mp4（检测用 `demo_video.mp4`，分割/深度用 `demo_video_seg.mp4`，人体姿态用 `demo_pose.mp4`，手掌姿态用 `demo_hand_pose.mp4`），主机端缩放后注入 NPU。
- 编号规律：**N 和 N+8 是同一个网络**，只是一个走实时、一个走视频。

> 画面右上角信息框的读法：`Yolo26n in:320x320 | RGB 1280x720 | Live` —— `in:320x320` 是**网络输入尺寸**（送 NPU 前的缩放尺寸），`RGB 1280x720` 是**实际显示的图像分辨率**，二者无关。

### 模式 17：实时检测 + 立体深度对齐（D2C）

在实时 RGB 上跑 Yolo26n 320×320 检测，同时启动**配准到 RGB 视点的真实立体深度流**（固件级 `ActivateRegisteredDepth`，深度通道 5 → RGB 通道 23，输出自动重采样到 1280×720）：

- 窗口为**双面板**：左 = RGB + 检测框，右 = 伪彩**实测**深度图（非网络估计的单目深度）
- 按 `S` 后**点击任一面板**任意位置，双面板同位置显示十字标记 + `(x,y) depth:NNNmm`（3 秒后消失）
- 按 `B` 打开背景去除滑条，可按实测深度阈值抹除 RGB 面板中的远处区域
- 典型用途：检测框 + 点选测距（物体到相机距离），验证 YOLO 识别与深度在同一坐标系
- 深度面板中**黑色区域 = 无有效深度**（配准输出的左右 padding 条、立体匹配空洞）；`near:/far:` 文本只按有效像素统计，点击黑色区域显示 `depth:0mm` 属正常

### 隐藏的批量图片调试模式（菜单中不显示，直接输入数字）

| 输入 | 网络 | 说明 |
| --- | --- | --- |
| `94` | Yolo26n-depth 640×640 | 批量处理 `input_images\` 全部图片 |
| `96` | Yolo26n-palm 320×320 | 同上 |
| `97` | Yolo26n-pose 640×384 | 同上 |
| `98` | Yolo26n-seg 640×384 | 同上 |

批量模式不弹窗口，逐张把标注结果写入 `result_images\`，处理完自动退出。把自己想测的 jpg/png 放进 `input_images\` 即可。

---

## 6. 键盘控制（先点击一下视频窗口获得焦点）

| 按键 | 功能 | 适用模式 |
| --- | --- | --- |
| `Q` / `ESC` | **结束当前演示**（完整释放 NPU/相机资源后程序退出，脚本随后询问继续或结束，见 §4 步骤 4） | 全部 |
| `F` | 开关 FPS 显示 | 全部 |
| `C` | 开关右上角按类别目标计数 HUD | 除深度外 |
| `R` | 开关 MP4 录制（输出 `recording_<时间戳>.mp4` 到包目录） | 全部 |
| `O` | 开关分割掩膜轮廓线 | 仅分割（5/13/98） |
| `M` | 掩膜分辨率 高/低 切换 | 仅分割、仅主机后处理版本 |
| `L` | 开关骨架连线（默认开） | 姿态/手掌（6/7/14/15/96/97） |
| `S` | 深度取点采样：在任一面板点一下，显示该点 x、y 和深度毫米数（3 秒） | 深度（8/16）实时/视频；**模式 17** |
| `B` | 深度背景去除：弹出滑条设置最大深度百分比，超出阈值的像素在 RGB 面板被抹除 | 深度（8/16）实时/视频；**模式 17** |

> `S`、`B` 对深度网络（8/16）和模式 17（D2C 立体深度）有效，其他网络下按键无任何反应属正常现象。

---

## 7. 正常退出与异常恢复（重要）

**正常流程**：视频窗口按 `Q`/`ESC` → 当前演示退出 → 脚本提示 `Press C for another demo, Q to finish and restore:` →
按 **Q** → 脚本自动恢复原厂固件、重启 InuService → 显示 "Demo completed" 后按任意键关闭。
（按 **C** 则不还原，直接回到程序菜单继续换演示；在脚本窗口按 CTRL+C 并确认终止属于异常退出，见下。）

**如果脚本窗口被直接关闭 / 程序崩溃 / 断电**，原厂固件可能没有恢复。此时任选其一：

1. **再次运行 `run_yolo26_demo_admin.bat`**：脚本检测到残留备份会先自动恢复原厂固件，再重新进入正常流程（不想演示可在恢复完成、菜单出现前 CTRL+C）；
2. **运行 `restore_boot_admin.bat`**（管理员）：专用于恢复原厂固件并重启服务，恢复后 InuSpector 等原厂工具即可正常使用。

检查是否已恢复：查看 `C:\Program Files\Inuitive\InuDev\bin\NU4100\boot300\` 目录——若存在 `cnn_boot_app.bin_ORIGINAL` 文件，说明尚未恢复，请执行上面任一操作。

> Demo 专用固件不恢复不影响 Windows 正常使用，但 InuSpector/原厂 CNN 功能可能异常，因此演示完请务必确认恢复。

---

## 8. 常见问题（FAQ）

**Q1：脚本提示 "must be run as Administrator"**
右键 bat → 以管理员身份运行。

**Q2：提示缺少某个文件（Missing required file）**
包不完整，重新解压/拷贝完整文件夹。注意不要把 exe 单独拿出来运行。

**Q3：提示找不到 InuStreams.dll / 请安装 InuDev**
未安装 InuDev SDK，或安装路径不是默认的 `C:\Program Files\Inuitive\InuDev`。安装 InuDev 4.39 后重试。

**Q4：InuService 起不来（InuService is not running）**
手动执行：管理员命令行中 `net start InuService`；仍失败请检查 USB 连接与驱动。

**Q5：程序启动后 "InuSensor failed to Init" 反复重试**
相机未被识别：重新插拔 USB、换 USB3 口、确认仅一个程序占用相机（先关掉 InuSpector/InuView），再重启脚本。

**Q6：视频模式报错 Failed to open xxx.mp4 / 黑屏**
依次确认：① 包内 4 个 mp4 与 exe 同目录且未改名；② `opencv_videoio_ffmpeg480_64.dll` 与
`opencv_world480.dll` 在包根目录（视频解码必需，缺失会退回系统解码器并可能失败）。

**Q7：程序一闪就退、报 VCRUNTIME140.dll / MSVCP140.dll 缺失**
安装 Microsoft Visual C++ 2015–2022 x64 运行库。

**Q8：FPS 偏低**
选小尺寸输入（320）、关录制（R）、关轮廓线（O）；深度/大模型本来帧率就低，参见性能表。

**Q9：批量模式没结果**
确认 `input_images\` 里有 jpg/png 等图片，输出看 `result_images\`。

**Q10：深度图整体比例不对**
深度标定常数问题，属模型标定范畴，请联系提供方；演示时可换检测/分割模式。

---

## 9. 性能参考（低延迟模式实测）

| 任务 | 模型 | 输入 | 全流程耗时 | FPS |
| --- | --- | :---: | ---: | ---: |
| 检测 | yolo26n | 320×320 | 18.9 ms | 52 |
| 检测 | yolo26n | 640×640 | 66.8 ms | 15 |
| 检测 | yolo26m | 320×320 | 59 ms | 16 |
| 检测 | yolo26m | 640×640 | 242 ms | 4.1 |
| 实例分割 | yolo26n | 640×384 | 49.5 ms | 19.5 |
| 人体姿态 | yolo26n | 640×384 | 38.2 ms | 25 |
| 手掌姿态 | yolo26n | 320×320 | 20 ms | 50 |
| 单目深度 | yolo26n | 640×640 | 90 ms | 11 |

（后处理默认在 NPU 片上固件内完成，主机 CPU 占用低。）

---

## 10. 技术支持

遇到无法解决的问题，请截取脚本窗口和程序控制台的完整文字/截图，并附上 `VERSION.txt` 内容，联系包提供方。
