## Github获取repo-id

### 1. GitHub 仓库信息

如果你想获取 GitHub 仓库的相关信息（例如仓库的 ID 或其他 metadata），你可以使用 GitHub API 或者通过 GitHub 网站直接获取。

**使用 GitHub API 获取仓库信息：**
你可以通过以下命令获取一个仓库的详细信息，包括 `repo_id` 等数据。

```bash
curl -H "Authorization: token YOUR_GITHUB_TOKEN" https://api.github.com/repos/用户名/仓库名
```

其中，`YOUR_GITHUB_TOKEN` 是你的 GitHub Personal Access Token。你需要替换 `用户名/仓库名` 为你要查询的 GitHub 仓库。

**示例:**

```bash
curl -H "Authorization: token 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" https://api.github.com/repos/joshzhong66/Josh-Mkdocs
```

在返回的 JSON 数据中，你可以找到 `id` 字段，这就是 `repo_id`。

### 2. Git 本地仓库信息
如果你是想获取本地 Git 仓库的配置信息，可以使用以下命令：

**查看 Git 配置:**
```bash
git config --list
```

这个命令会列出当前仓库的所有 Git 配置，包括用户信息、远程仓库地址等。

**获取当前仓库的远程仓库 URL:**
```bash
git remote -v
```

这个命令会显示当前 Git 仓库配置的所有远程仓库 URL。

**查看当前仓库的状态:**
```bash
git status
```

这个命令会显示当前仓库的状态信息，包括未提交的更改、分支信息等。

### 3. 获取 GitHub Token
如果你需要访问 GitHub API 或进行其他与 GitHub 相关的操作，可能需要一个 GitHub Personal Access Token。

**创建 GitHub Token:**
1. 登录你的 GitHub 账户。
2. 点击右上角的头像，选择 “Settings”。
3. 在左侧菜单中选择 “Developer settings”。
4. 点击 “Personal access tokens” > “Tokens (classic)” > “Generate new token”。
5. 选择需要的权限，生成 Token。

生成的 Token 需要妥善保管，因为它只能在生成时查看一次。

### 4. 使用 GitHub CLI
GitHub 提供了一个命令行工具 `gh`，可以用来获取很多与 GitHub 相关的信息。

**安装 GitHub CLI:**
```bash
brew install gh  # macOS
sudo apt install gh  # Ubuntu/Debian
```

**登录 GitHub CLI:**
```bash
gh auth login
```

**获取仓库信息:**
```bash
gh repo view 用户名/仓库名 --json id,name,description
```

这个命令会返回包含仓库 ID、名称和描述的 JSON 数据。

通过这些方法，你可以获取与 Git 相关的各种信息。根据你的需求选择合适的方法。