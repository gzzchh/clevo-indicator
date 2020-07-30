# 蓝天笔记本风扇调速

蓝天笔记本调速工具,支持 CPU/GPU

修改自下列项目

- https://github.com/davidrohr/clevo-indicator
- https://github.com/SkyLandTW/clevo-indicator

做了以下修改

- 已解锁 GUI 手工调速下限为 40%
- 汉化了说明,挖掘了更多参数

## 构建/Build

```bash
# For Ubuntu/Debian
sudo apt install libappindicator3-dev libgtk-3-dev
git clone https://github.com/gzzchh/clevo-indicator
cd clevo-indicator
make install
```

```bash
# For CentOS/Fedora
sudo dnf install \
libappindicator-gtk3-devel \
libappindicator-gtk3 \
libappindicator \
libappindicator-devel
git clone https://github.com/gzzchh/clevo-indicator
cd clevo-indicator
make install
```

## 用法/Usage

clevo-indicator set [fan-duty-percentage(int)] 设定 CPU 风扇百分比  
clevo-indicator setg [fan-duty-percentage(int)] 设定 GPU 风扇百分比  
clevo-indicator help 打印帮助  
clevo-indicator dump 获取温度  
clevo-indicator dumpall 获取温度(原始数据)  
clevo-indicator auto 自动设定风扇速度并退出(适合定时脚本)  
clevo-indicator indicator 显示调速 GUI

fan-duty-percentage 是一个 int  
指定风扇百分比

## 笔记/Note

简单来说调用 EC 接口需要 root 权限  
但是一般 Linux 桌面都是给普通用户的  
所以你需要 setuid

操作方法如下

```bash
sudo chown root clevo-indicator
sudo chmod u+s  clevo-indicator
```

本程序与任何通过低级调用访问 EC 的程序冲突,可能会发生未知的行为  
本程序也没有对 EC 访问做保护

The executable has setuid flag on, but must be run by the current desktop user,
because only the desktop user is allowed to display a desktop indicator in
Ubuntu, while a non-root user is not allowed to control Clevo EC by low-level
IO ports. The setuid=root creates a special situation in which this program can
fork itself and run under two users (one for desktop/indicator and the other
for EC control), so you could see two processes in ps, and killing either one
of them would immediately terminate the other.

Be careful not to use any other program accessing the EC by low-level IO
syscalls (inb/outb) at the same time - I don't know what might happen, since
every EC actions require multiple commands to be issued in correct sequence and
there is no kernel-level protection to ensure each action must be completed
before other actions can be performed... The program also attempts to prevent
abortion while issuing commands by catching all termination signals except
SIGKILL - don't kill the indicator by "kill -9" unless absolutely necessary.

## 修改/Hack

如果想要给 GUI 菜单添加更多的选项,可以去 `clevo-indicator.c` 第 138 行左右  
找到一个数组,然后 Just Copy

```c
static menuitems[] = {
    {"Set FAN to AUTO", G_CALLBACK(ui_command_set_fan), 0, AUTO, NULL},
    {"", NULL, 0L, NA, NULL},
    {"Set FAN to  40%", G_CALLBACK(ui_command_set_fan), 40, MANUAL, NULL},
    {"Set FAN to  50%", G_CALLBACK(ui_command_set_fan), 50, MANUAL, NULL},
    {"Set FAN to  60%", G_CALLBACK(ui_command_set_fan), 60, MANUAL, NULL},
    {"Set FAN to  70%", G_CALLBACK(ui_command_set_fan), 70, MANUAL, NULL},
    {"Set FAN to  80%", G_CALLBACK(ui_command_set_fan), 80, MANUAL, NULL},
    {"Set FAN to  90%", G_CALLBACK(ui_command_set_fan), 90, MANUAL, NULL},
    {"Set FAN to 100%", G_CALLBACK(ui_command_set_fan), 100, MANUAL, NULL},
    {"", NULL, 0L, NA, NULL},
    {"Quit", G_CALLBACK(ui_command_quit), 0L, NA, NULL}};
```

关于百分比计算规则,目前是放在 `clevo-indicator.c` 第 884 行左右,如下

```c
static int ec_auto_duty_adjust(void)
{
    int temp = MAX(share_info->cpu_temp, share_info->gpu_temp);
    int duty = share_info->fan_duty;
    //
    if (temp >= 80 && duty < 100)
        return 100;
    // 篇幅关系 省略大部分
    //
    return 0;
}
```
