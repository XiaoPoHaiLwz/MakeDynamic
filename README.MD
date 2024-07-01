# MakeDynamic ![](https://img.shields.io/badge/Languages-Rust-blue) ![](https://img.shields.io/badge/Environment-ARM64_X86-red)

MakeDynamic 是一个自动生成 dynamic_partitions_op_list_a 的项目

- 方便性：你可以在 arm64 上使用它
  </br>
- 简单性：只需要几步配置就可以使用
  </br>
- 作者：XPH

---

## 目录

- [配置你的机型](#配置你的机型)

  - 关于 Config 的配置
  - 关于 Image 的放置

- [如何使用 MakeDynamic](#如何使用MakeDynamic)
  - ARM64 环境下的使用
  - X86 环境下的使用

---

### 配置你的机型

- **关于 Config 的配置**

  - 第一步
    <sub>创建对于机型的.conf 文件</sub>
    ```
    先在devices/config文件夹中创建相关conf文件
    如你的机型为 marble
    则先创建一个marble文件夹
    例如:device/config/marble
    然后你在device/config/marble创建marble.conf
    例如: devices/config/marble/marble.conf
    ```
  - 第二步
    <sub>向.conf 里面添加东西</sub>

    ```
    [settings]
    super_size = "Size"
    super_list = ["item1","item2","item3"]
    ```

    例如: devices/config/marble/marble.conf

    ```
    # marble.conf
    [settings]
    super_size = "9663676416"
    super_list = ["system", "system_ext", "vendor", "product", "odm", "mi_ext", "vendor_dlkm"]
    ```

- **关于镜像**

  ```
  放置在images文件夹内
  例如：images/
  ```

### 如何使用MakeDynamic
- **Args**
    ```
    ./MakeDynamic args1
    args1:your device
    它需要在Root/Sudo/Su的环境下才能运行
    ```
- **关于ARM64使用**
    ```
    MT管理器
    --将MakeDynamic放到data目录下
    --终端
    --su
    --cd your_path
    --./MakeDynamic args1
    ```
- **关于X86使用**
    ```
    --终端
    --cd your_path
    --sudo ./MakeDynamic args1
    ```

- **文件结构示意图**
```
.
├── device
│   └── config
│       └── marble
│           └── marble.conf
├── image
│   ├── mi_ext.img
│   ├── odm.img
│   ├── product.img
│   ├── system_ext.img
│   ├── system.img
│   ├── vendor_dlkm.img
│   └── vendor.img
└── MakeDynamic
```