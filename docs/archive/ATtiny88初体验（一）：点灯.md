# ATtiny88初体验（一）：点灯

最近逛淘宝时，发现一块ATtiny88核心板（MH-ET LIVE Tiny88）用完红包后只剩4块钱了，果断下单，准备好好把玩一番。

## MH-ET LIVE Tiny88介绍

这块核心板使用的MCU型号是ATtiny88，主要参数如下：

| 资源 | 主要特征 |
| :---: | :---: |
| Flash | 8KB |
| SRAM | 512B |
| 频率 | 12MHz |
| EEPROM | 64B |
| 定时器 | 1个8bit，1个16bit |
| PWM | 2通道 |
| ADC | 8通道10bit |
| 比较器 | 1 |
| GPIO | 28 |
| SPI | 1 |
| TWI | 1 |
| 看门狗 | 1 |
| 电压 | 0~4MHz @ 1.8~5.5V <br/> 0~8MHz @ 2.7~5.5V <br/> 0~12MHz @ 4.5~5.5V |

MH-ET LIVE Tiny88的引脚图如下：

![MHET_Tiny.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/MHET_Tiny.png)

板子共引出了26个IO口，少了的2个IO口是PB6和PC6，其中PB6没有引出，可以通过熔丝位将RST引脚配置为PC6。另外，1号和2号引脚是连接到USB口的，供VUSB使用，最好不要另作他用。

值得注意的是，板子搭载的晶振频率为16MHz，已经超过了[ATtiny88手册](https://ww1.microchip.com/downloads/en/DeviceDoc/doc8008.pdf)里标明的最大工作频率12MHz，超频了33%。

## 熔丝位

ATtiny88拥有3个字节的熔丝位，和一般的逻辑相反，熔丝位中的 `1` 表示未编程（禁止）， `0` 表示已编程（启用）。修改熔丝位时需要谨慎再谨慎，否则可能造成锁死单片机（俗称变砖）。

### 熔丝扩展位

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230818202138.png)

- `SELFPRGEN` ：设为 `0` 表示启用自编程（ `SPM` 指令）

### 熔丝高位

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230818202408.png)

- `RSTDISBL` ：设为 `0` 时将复位引脚用作普通IO（PC6），**修改需谨慎！**
- `DWEN` ：设为 `0` 时启用调试接口
- `SPIEN` ：设为 `0` 时可以通过SPI下载程序和数据，**修改需谨慎！**
- `WDTON` ：设为 `0` 时将总是启用看门狗
- `EESAVE` ：设为 `0` 时擦除芯片时会保留EEPROM中的内容
- `BODLEVEL[2:0]` ：设置欠压检测等级
	![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230818203322.png)

### 熔丝低位

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230818202428.png)

- `CKDIV8` ：设为 `0` 时系统时钟会进行8分频
- `CKOUT` ：设为 `0` 时启用时钟输出（通过CLKO引脚）
- `SUT[1:0]` ：设置启动时间
	![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230818203643.png)
- `CKSEL[1:0]` ：设置时钟源
	![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230818203724.png)

### 修改熔丝位

在Windows环境下，可以借助[PROGISP](https://github.com/gen-so/PROGISP-V1.72)软件查看和修改熔丝位。

通过USBasp将核心板与电脑连接，打开PROGISP软件，在“Select Chip”下选择“ATtiny88”，点击“RD”按钮，如果连接没有问题，会提示“读出ID成功”。

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819144736.png)

点击“自动”按钮旁边的“...”按钮。

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819144941.png)

在弹出的小窗口中点击下方“位配置方式”标签页中的“读出”按钮，提示“熔丝位读出成功”。

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819145411.png)

点击需要修改熔丝位即可切换该位的值，设置完毕后点击“位配置方式”中的“写入”按钮，提示“熔丝位写入成功”。

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819145921.png)

至此，便完成了熔丝位的修改。

## 点灯

“点灯”程序就是单片机开发中的“Hello World！”，借助它，可以大致体会单片机开发的完整流程。

### 寄存器介绍

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819150514.png)

在ATtiny88中，每个IO口都可作为输入或者输出，并且都有一个独立可控的内部上拉电阻。

与IO相关的寄存器主要有 `MCUCR` 、 `PORTCR` 、 `PORTx` 、 `DDRx` 、 `PINx` 。

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819151033.png)

- `PUD` ：写 `1` 禁止内部上拉电阻（全局）

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819151051.png)

- `BBMx` ：写 `1` 使能对应端口的Break-Before-Make模式
- `PUDx` ：写 `1` 禁止对应端口的内部上拉电阻

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819151114.png)

`PORTx` 寄存器存放输出数据， `PINx` 寄存器存放输入数据， `DDRx` 寄存器用于配置端口方向， `0` 表示输入， `1` 表示输出。

当IO配置为输入模式时，向 `PORTx` 寄存器中写 `1` 表示启用内部上拉电阻。

不管是输入还是输出模式，向 `PINx` 寄存器中写 `1` 都表示翻转 `PORTx` 寄存器中对应位的状态。

IO口的具体配置组合如下所示：

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819093204.png)

### 代码

代码文件的整体结构如下所示：

```
.
├── Makefile
├── inc
└── src
    └── main.c
```

为了方便编译，在根目录下编写一个 `Makefile` 文件：

```makefile title='Makefile'
CC = avr-gcc
CP = avr-objcopy
SZ = avr-size
DP = avr-objdump
AVRDUDE = avrdude

TARGET = led
BUILD_DIR = build
C_SOURCES = src/main.c
C_INCLUDES = -Iinc
C_DEFS = -DF_CPU=16000000

LIBS = -lc -lm
LIBDIRS =
MCU = -mmcu=attiny88
OPT = -Og
CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -g -std=gnu99 -Wall -fdata-sections -ffunction-sections
LDFLAGS = $(MCU) $(LIBS) $(LIBDIRS) -Wl,--gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref

PROGRAMMER_ID = usbasp
PARTNO = t88
PORT =
BAUDRATE =

OBJECTS = $(addprefix $(BUILD_DIR)/,$(C_SOURCES:.c=.o))
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)" -Wa,-adhmls=$(@:%.o=%.lst)
AVRDUDE_FLAGS = -c $(PROGRAMMER_ID) -p $(PARTNO)
ifneq ($(PORT),)
        AVRDUDE_FLAGS += -P $(PORT)
endif
ifneq ($(BAUDRATE),)
        AVRDUDE_FLAGS += -b $(BAUDRATE)
endif

.PHONY: all clean flash
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).txt $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
        $(CC) -c $(CFLAGS) -o $@ $<

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
        $(CC) $(LDFLAGS) $(OBJECTS) -o $@
        $(SZ) $@

$(BUILD_DIR)/$(TARGET).txt: $(BUILD_DIR)/$(TARGET).elf
        $(DP) -h -S $< > $@

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
        $(CP) -O ihex $< $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
        $(CP) -O binary -S $< $@

$(BUILD_DIR):
        mkdir -p $(sort $(dir $(OBJECTS)))

clean:
        rm -rf $(BUILD_DIR)

flash: $(BUILD_DIR)/$(TARGET).hex
        $(AVRDUDE) $(AVRDUDE_FLAGS) -U flash:w:$<:i

-include $(OBJECTS:%.o=%.d)
```

`Makefile` 文件中的 `TARGET` 变量指定目标名称， `BUILD_DIR` 变量指定编译目录， `C_SOURCES` 指定C源文件， `C_DEFS` 指定C宏定义， `C_INCLUDES` 指定头文件目录。

MH-ET LIVE Tiny88板载的LED连接到0号引脚，对应的是PD0，高电平点亮。在 `src` 目录下新建一个 `main.c` 源文件，输入如下代码，实现：设置PD0位输出模式，然后每隔一段时间翻转PD0的输出。

```c title='src/main.c'
#include <stdint.h>
#include <avr/io.h>

static void delay(void);

int main(void)
{
    DDRD |= 0x01;
    PORTD |= 0x01;

    for (;;) {
        PIND = 0x01;
        delay();
    }
}

static void delay(void)
{
    for (volatile uint32_t i = 0; i < 0x20000; i++);
}
```

编译代码：

```bash
make
```

将在 `build` 文件夹下生成ELF/HEX/BIN文件。

### 下载

在 `/etc/udev/rules.d/` 目录下创建一个USBasp的规则文件 `99-usbasp.rules` ，内容如下：

```title='/etc/udev/rules.d/99-usbasp.rules'
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", MODE="664", GROUP="plugdev"
```

其中，注意 `idVector` 和 `idProduct` 需要根据实际情况填写。

安装 `avrdude` 软件：

```bash
sudo apt install avrdude
```

连接USBasp，进行下载：

```bash
make flash
```

上述命令实际上执行的是：

```bash
avrdude -c usbasp -p t88 -U flash:w:build/led.hex:i
```

`avrdude` 中常用的选项如下

| 选项 | 含义 | 取值 |
| --- | --- | --- |
| `-c programmer-id` | 指定编程器 | `usbasp` ：USBasp <br/> `arduino` ：ArduinoISP |
| `-p partno` | 指定单片机 | `t88` ：ATtiny88 <br/> `m328p`：ATmega328P <br/> `m32u4` ：ATmega32U4 |
| `-P port` | 指定端口 |  |
| `-b baudrate` | 指定波特率 |  |
| `-U memtype:op:filename[:format]` | 指定执行的操作 <br/> `memtype` ：内存区域 <br/> `op` ：操作 <br/> `filename` ：文件名 <br/> `format` ：文件格式 | `memtype` 的取值： <br/> `flash` ：Flash ROM <br/> `eeprom` ：EEPROM <br/> `efuse` / `hfuse` / `lfuse` ：扩展/高/低熔丝位 <br/> `op` 的取值： <br/> `r` ：读 <br/> `w` ：写 <br/> `v` ：校验 <br/> `format` 的取值： <br/> `i` ：Intel Hex <br/> `r` ：raw binary <br/> `e` ：ELF |

输出如下信息表示下载成功：

![image.png](https://cdn.jsdelivr.net/gh/chinjinyu/image-hosting-website@main/images/20230819154855.png)

## 参考资料

1. [ATtiny88 Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc8008.pdf)
2. [PROGISP](https://github.com/gen-so/PROGISP-V1.72)
3. [AVRDUDE User Manual](https://www.nongnu.org/avrdude/user-manual/avrdude.html)
