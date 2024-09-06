# GitHub配置Giscus & Discussions

## **1、创建 GitHub Token:**

1. 登录你的 GitHub 账户。
2. 点击右上角的头像，选择 “Settings”。
3. 在左侧菜单中选择 “Developer settings”。
4. 点击 “Personal access tokens” > “Tokens (classic)” > “Generate new token”。
5. 选择需要的权限，生成 Token。

在生成 Token 的页面，你需要为这个 Token 选择权限。权限决定了这个 Token 能做什么操作。常见的权限包括：

- `repo`: 访问公共和私有仓库。
- `gist`: 访问 Gist。
- `admin:org`: 管理组织。
- `workflow`: 访问和管理 GitHub Actions 工作流。

根据你的需求选择合适的权限。如果你不确定需要哪些权限，通常 `repo` 是一个比较常用的选项，它允许你对仓库进行读写操作。

6. 设置 Token 的名称和有效期

在权限设置的上方，你可以为这个 Token 设置一个描述性的名称，并选择 Token 的有效期（例如30天，60天等）。选择合理的有效期后，你的 Token 将在此期限后自动失效。

7. 生成 Token

点击 **“Generate token”** 按钮，GitHub 会生成一个新的 Token，并展示在页面上。

**Generate new token (Beta) **
允许你为特定的仓库或一组仓库生成 Token，并为每个仓库选择更细致的权限。这种 Token 更安全，因为它只授予你选择的特定权限和仓库。

**Generate new token (classic):**
这是传统的 Token 类型，适用于更广泛的使用场景。你可以为所有的仓库生成一个全局的 Token，适合需要在多个仓库中执行操作的用户。

8. 复制 Token

生成的 Token 只会显示一次，确保你在页面上将 Token 复制到安全的地方保存。如果你忘记保存，需要重新生成一个新的 Token。



## 2、GitHub API 获取仓库信息

复制生成的token进行身份验证，用于获取GitHub 仓库的相关信息（例如仓库的 ID 或其他 metadata）

```bash
curl -H "Authorization: token YOUR_GITHUB_TOKEN" https://api.github.com/repos/用户名/仓库名
```

其中，`YOUR_GITHUB_TOKEN` 是你的 GitHub Personal Access Token。你需要替换 `用户名/仓库名` 为你要查询的 GitHub 仓库。

在返回的 JSON 数据中，你可以找到 `id` 字段，这就是 `repo_id`



## 3、启用 GitHub Discussions

Giscus 依赖于 GitHub Discussions 功能，因此你需要在仓库中启用 Discussions。你可以按照以下步骤来启用：

1. 进入你的 GitHub 仓库 `joshzhong66/Josh-Mkdocs`。
2. 点击上方的 “Settings”。
3. 在左侧菜单中找到 “Features” 选项。
4. 确保 “Discussions” 已经勾选并启用。

## 4、安装Giscus

访问地址[Giscus地址](https://github.com/marketplace/giscus)安装Giscus：

1. **点击** “**Install it for free**” 按钮。
2. **选择仓库**：在接下来的页面中，你可以选择将 Giscus 安装到 **所有仓库** 或 **特定的仓库**。选择 **“Only select repositories”**，然后选择你要使用的仓库（例如 `joshzhong66/Josh-Mkdocs`）。
3. **确认安装**：点击 **Install** 按钮，确认将 Giscus 安装到所选的仓库。



![image-20240901170546972](C:\Users\JoshZhong\AppData\Roaming\Typora\typora-user-images\image-20240901170546972.png)



5、配置Giscus

1.访问[Giscus网址](https://giscus.app/zh-CN)

2.输入仓库名称进行验证

![image-20240901173036838](C:\Users\JoshZhong\AppData\Roaming\Typora\typora-user-images\image-20240901173036838.png)

### 

```
<script src="https://giscus.app/client.js"
        data-repo="joshzhong66/Josh-Mkdocs"
        data-repo-id="R_kgDOMrJV0A"
        data-category="Announcements"
        data-category-id="DIC_kwDOMrJV0M4CiH4K"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="0"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="light"
        data-lang="zh-CN"
        crossorigin="anonymous"
        async>
</script>
```

