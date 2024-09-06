Kiwi Syslog server
交换机配置
```python
system-view
info-center enable
info-center source default loghost level debugging
info-center loghost 10.0.0.15 facility local0
save force
```
参考：[https://blog.51cto.com/u_1737585/2549136](https://blog.51cto.com/u_1737585/2549136)
