# GitHub 仍然阻止了您的推送

因为提交中的内容包含敏感信息`docs/tech/Git/Github获取repo-id.md:25`

```
remote:       —— GitHub Personal Access Token ——————————————————————
remote:        locations:
remote:          - commit: 2b31f3e717c36d7cef273e1ff310dbca62aa3093
remote:            path: docs/tech/Git/Github获取repo-id.md:19
remote:          - commit: 7690cabb1ca5cf842f511bb586b396945a82c1f9
remote:            path: docs/tech/Git/Github获取repo-id.md:19
remote:          - commit: 2b31f3e717c36d7cef273e1ff310dbca62aa3093
remote:            path: docs/tech/Git/Github获取repo-id.md:25
remote:
remote:        (?) To push, remove secret from commit(s) or follow this URL to allow the secret.
remote:        https://github.com/joshzhong66/Josh-Mkdocs/security/secret-scanning/unblock-secret/2lSrrQiEjBVFhIRKMt6bRtdCwc7
remote:
remote:
remote:
To https://github.com/joshzhong66/Josh-Mkdocs.git
 ! [remote rejected] master -> master (push declined due to repository rule violations)

```



根据日志信息，可以通过访问指定的 URL 来解除对特定提交的阻止。如果您确定提交中的内容不是敏感信息或者您已经处理了相关内容，可以按照以下步骤来解除限制并继续推送：

在浏览器中打开以下链接：

```
https://github.com/joshzhong66/Josh-Mkdocs/security/secret-scanning/unblock-secret/2lSrrNaIXxv0fv0MOrM9wAZSZQ9
```

这个链接将带您进入 GitHub 的解除阻止页面，您需要在这个页面上确认是否允许推送包含检测到的“敏感信息”的提交。

![image-20240901181935581](C:\Users\JoshZhong\AppData\Roaming\Typora\typora-user-images\image-20240901181935581.png)



**重新推送**：

- 完成上述操作后，返回命令行，再次尝试推送：
  ```bash
  git push origin master
  ```
- 如果解除限制成功，推送应该可以顺利完成。