## GitHub开启 Discussions

### 1. 启用 GitHub Discussions
Giscus 依赖于 GitHub Discussions 功能，因此你需要在仓库中启用 Discussions。你可以按照以下步骤来启用：

1. 进入你的 GitHub 仓库 `joshzhong66/Josh-Mkdocs`。
2. 点击上方的 “Settings”。
3. 在左侧菜单中找到 “Features” 选项。
4. 确保 “Discussions” 已经勾选并启用。

### 2. 创建一个 Discussions
启用 Discussions 后，你需要创建一个 Discussions：

1. 打开仓库的 Discussions 页面，点击仓库主页面中的 **Discussions** 标签。
2. 点击 **New discussion** 按钮，创建一个新的讨论。
3. 在创建过程中，为讨论添加标题和内容，然后提交。

### 3. 获取 Discussions 的编号
提交 Discussions 后，你可以通过以下两种方式获取编号：

#### 方法一：查看 URL
1. 打开你刚刚创建的 Discussions。
2. 在浏览器的地址栏中查看 URL。URL 类似于以下格式：
   ```
   https://github.com/joshzhong66/Josh-Mkdocs/discussions/6
   ```
3. URL 中的最后一部分数字（例如 `/6`）就是这个 Discussions 的编号。这个编号就是你要在 `data-term` 中使用的值。

#### 方法二：使用 GitHub API
你也可以通过 GitHub API 获取 Discussions 的编号：

1. 通过 API 获取仓库 Discussions 列表：
   ```bash
   curl -H "Authorization: token YOUR_GITHUB_TOKEN" https://api.github.com/repos/joshzhong66/Josh-Mkdocs/discussions
   ```
2. 在返回的 JSON 数据中查找 Discussions 的 `number` 字段，这就是你需要的编号。

### 4. 在 Giscus 中使用编号
将获取的编号填入 `data-term` 参数中：

```html
<script src="https://giscus.app/client.js"
    data-repo="joshzhong66/Josh-Mkdocs"
    data-repo-id="850548176"
    data-mapping="number"
    data-term="6"  <!-- 这里的 6 就是 Discussions 的编号 -->
    data-reactions-enabled="1"
    data-emit-metadata="0"
    data-input-position="bottom"
    data-theme="light"
    data-lang="zh-CN"
    crossorigin="anonymous"
    async>
</script>
```

通过这些步骤，你可以确保 `data-term` 参数的值正确无误，从而避免与 Discussions 关联时出现问题。