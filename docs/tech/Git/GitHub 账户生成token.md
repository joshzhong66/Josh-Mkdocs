获取 GitHub Token 需要按照以下步骤进行：

### 1. 登录 GitHub 账户
首先，你需要登录到你的 GitHub 账户。

### 2. 进入个人设置
在登录后，点击右上角的头像，然后选择 **“Settings”** 进入个人设置页面。

### 3. 进入 Developer Settings
在设置页面的左侧菜单栏中，向下滚动找到 **“Developer settings”** 并点击进入。

### 4. 进入 Personal Access Tokens
在 Developer settings 页面，选择 **“Personal access tokens”**，然后点击 **“Tokens (classic)”**。这是用来生成 GitHub Token 的页面。

### 5. 生成新 Token
在 Tokens (classic) 页面，点击 **“Generate new token”** 按钮，开始生成新的 Token。

### 6. 选择权限
在生成 Token 的页面，你需要为这个 Token 选择权限。权限决定了这个 Token 能做什么操作。常见的权限包括：

- `repo`: 访问公共和私有仓库。
- `gist`: 访问 Gist。
- `admin:org`: 管理组织。
- `workflow`: 访问和管理 GitHub Actions 工作流。

根据你的需求选择合适的权限。如果你不确定需要哪些权限，通常 `repo` 是一个比较常用的选项，它允许你对仓库进行读写操作。

### 7. 设置 Token 的名称和有效期
在权限设置的上方，你可以为这个 Token 设置一个描述性的名称，并选择 Token 的有效期（例如30天，60天等）。选择合理的有效期后，你的 Token 将在此期限后自动失效。

### 8. 生成 Token
确认设置无误后，点击页面底部的 **“Generate token”** 按钮。此时，GitHub 会生成一个新的 Token，并展示在页面上。

![image-20240901155934907](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/09/01/25f3dffa9216005f4d05ac6cf89974e9-image-20240901155934907-128a9b.png)

**Generate new token (Beta) - Fine-grained, repo-scoped:**
这是一个新的、更精细化的 Token 类型，允许你为特定的仓库或一组仓库生成 Token，并为每个仓库选择更细致的权限。这种 Token 更安全，因为它只授予你选择的特定权限和仓库。

**Generate new token (classic):**
这是传统的 Token 类型，适用于更广泛的使用场景。你可以为所有的仓库生成一个全局的 Token，适合需要在多个仓库中执行操作的用户。

![image-20240901160226617](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/09/01/9ba605fb1b87feb87e08e49216c82c5f-image-20240901160226617-d4c3dc.png)

### 9. 复制 Token

**注意：** 生成的 Token 只会显示一次，确保你在页面上将 Token 复制到安全的地方保存。如果你忘记保存，需要重新生成一个新的 Token。

### 10. 使用 Token
你可以在命令行或其他应用中使用这个 Token。例如，通过命令行访问 GitHub API 或在你的 Git 客户端中使用 Token 进行身份验证。

```bash
curl -H "Authorization: token YOUR_GITHUB_TOKEN" https://api.github.com/repos/用户名/仓库名
```





