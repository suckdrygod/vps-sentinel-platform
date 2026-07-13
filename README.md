# VPS Sentinel Platform

VPS Sentinel Platform 是一个面向 Komari / TCPing 安全探针体系的“平台级入口仓库”。

它只做三件事：

1. 固定当前线上稳定版本；
2. 提供独立部署、回滚与文档入口；
3. 为后续主题、部署和安全策略留出标准目录。

它不会修改现有的 `komari`、`tcpping`、`komari-web` 仓库代码，也不会影响当前正在运行的线上系统。

## 当前锁定版本

| 子系统 | 仓库 | 锁定版本 | 锁定提交 |
| --- | --- | --- | --- |
| Komari Panel | [suckdrygod/komari](https://github.com/suckdrygod/komari) | `release/1.2.6-tg.32` | `689968acc219f227338e473a886f5590cee6026d` |
| Safe Agent / TCPing | [suckdrygod/tcpping](https://github.com/suckdrygod/tcpping) | `v1.2.13-safe.13` | `aa379696c97d9ad09eff82b0065a89cfa00ae3a0` |
| Komari Web | [suckdrygod/komari-web](https://github.com/suckdrygod/komari-web) | `radix` snapshot | `96d3c74eacf476aa915d6448fb95ee9663942b98` |

> 禁止使用 `latest` 作为生产部署依据。所有组件都通过 ref/commit 固定，生产镜像使用明确版本号，禁止跟随 `latest`。

## 目录结构

```text
deploy/
  docker-compose.yml   # 平台编排文件，默认不启动任何 profile
  install.sh           # 一键拉取/校验/生成 .env，可选启动
  uninstall.sh         # 停止平台容器，默认保留数据
docs/
  architecture.md      # 架构说明
  security.md          # 安全原则
  deployment.md        # 部署与回滚说明
config/
  example.env          # 环境变量模板
  versions.lock        # 子仓库版本锁
scripts/
  bootstrap.sh         # install.sh 的薄包装入口
```

## 快速开始

```bash
git clone https://github.com/suckdrygod/vps-sentinel-platform.git
cd vps-sentinel-platform

# 只拉取版本锁定源码、生成 .env、准备外部网络；默认不启动服务
./deploy/install.sh

# 手动启动面板后端，默认映射到 127.0.0.1:25874，避免覆盖现有线上端口
./deploy/install.sh --start-backend
```

访问地址默认是：

```text
http://127.0.0.1:25874
```

## 可选：打印安全探针安装命令

默认不会自动启动 agent，也不会自动连接任何已有节点。

```bash
./deploy/install.sh --print-agent-command
```

输出的命令需要你手动填入面板生成的 node token。

## 回滚

```bash
./deploy/install.sh --rollback
```

回滚只会停止本平台 compose 容器，并尝试恢复上一个备份的 `deploy/docker-compose.yml`。它不会删除数据卷、不会修改防火墙、不会影响现有线上容器。

## 安全边界

本仓库默认不做以下任何操作：

- 不自动开启 SSH 自动封禁；
- 不自动修改防火墙；
- 不自动修改 `iptables` / `nftables`；
- 不自动修改系统 SSH 配置；
- 不下发远程命令；
- 不启动 agent 自动接入生产面板。

所有安全能力都必须由用户在明确理解后手动开启。

## 主题预留

为后续主题系统预留静态路径约定：

```text
/theme/emerald-pro/index.css
```

本仓库只在文档和配置中保留该入口约定，不会修改 `komari-web`，也不会自动加载该主题。

