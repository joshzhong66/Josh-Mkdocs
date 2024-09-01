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

```
(venv) [root@josh Josh-Mkdocs]# curl -H "Authorization: token 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" https://api.github.com/repos/joshzhong66/Josh-Mkdocs
{
  "id": 850548176,
  "node_id": "R_kgDOMrJV0A",
  "name": "Josh-Mkdocs",
  "full_name": "joshzhong66/Josh-Mkdocs",
  "private": false,
  "owner": {
    "login": "joshzhong66",
    "id": 142572177,
    "node_id": "U_kgDOCH96kQ",
    "avatar_url": "https://avatars.githubusercontent.com/u/142572177?v=4",
    "gravatar_id": "",
    "url": "https://api.github.com/users/joshzhong66",
    "html_url": "https://github.com/joshzhong66",
    "followers_url": "https://api.github.com/users/joshzhong66/followers",
    "following_url": "https://api.github.com/users/joshzhong66/following{/other_user}",
    "gists_url": "https://api.github.com/users/joshzhong66/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/joshzhong66/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/joshzhong66/subscriptions",
    "organizations_url": "https://api.github.com/users/joshzhong66/orgs",
    "repos_url": "https://api.github.com/users/joshzhong66/repos",
    "events_url": "https://api.github.com/users/joshzhong66/events{/privacy}",
    "received_events_url": "https://api.github.com/users/joshzhong66/received_events",
    "type": "User",
    "site_admin": false
  },
  "html_url": "https://github.com/joshzhong66/Josh-Mkdocs",
  "description": "博客笔记，记录日常，沉淀生活",
  "fork": false,
  "url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs",
  "forks_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/forks",
  "keys_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/keys{/key_id}",
  "collaborators_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/collaborators{/collaborator}",
  "teams_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/teams",
  "hooks_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/hooks",
  "issue_events_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/issues/events{/number}",
  "events_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/events",
  "assignees_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/assignees{/user}",
  "branches_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/branches{/branch}",
  "tags_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/tags",
  "blobs_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/git/blobs{/sha}",
  "git_tags_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/git/tags{/sha}",
  "git_refs_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/git/refs{/sha}",
  "trees_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/git/trees{/sha}",
  "statuses_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/statuses/{sha}",
  "languages_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/languages",
  "stargazers_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/stargazers",
  "contributors_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/contributors",
  "subscribers_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/subscribers",
  "subscription_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/subscription",
  "commits_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/commits{/sha}",
  "git_commits_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/git/commits{/sha}",
  "comments_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/comments{/number}",
  "issue_comment_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/issues/comments{/number}",
  "contents_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/contents/{+path}",
  "compare_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/compare/{base}...{head}",
  "merges_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/merges",
  "archive_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/{archive_format}{/ref}",
  "downloads_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/downloads",
  "issues_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/issues{/number}",
  "pulls_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/pulls{/number}",
  "milestones_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/milestones{/number}",
  "notifications_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/notifications{?since,all,participating}",
  "labels_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/labels{/name}",
  "releases_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/releases{/id}",
  "deployments_url": "https://api.github.com/repos/joshzhong66/Josh-Mkdocs/deployments",
  "created_at": "2024-09-01T05:03:26Z",
  "updated_at": "2024-09-01T07:50:44Z",
  "pushed_at": "2024-09-01T07:50:41Z",
  "git_url": "git://github.com/joshzhong66/Josh-Mkdocs.git",
  "ssh_url": "git@github.com:joshzhong66/Josh-Mkdocs.git",
  "clone_url": "https://github.com/joshzhong66/Josh-Mkdocs.git",
  "svn_url": "https://github.com/joshzhong66/Josh-Mkdocs",
  "homepage": null,
  "size": 1062,
  "stargazers_count": 0,
  "watchers_count": 0,
  "language": "HTML",
  "has_issues": true,
  "has_projects": true,
  "has_downloads": true,
  "has_wiki": false,
  "has_pages": false,
  "has_discussions": false,
  "forks_count": 0,
  "mirror_url": null,
  "archived": false,
  "disabled": false,
  "open_issues_count": 0,
  "license": null,
  "allow_forking": true,
  "is_template": false,
  "web_commit_signoff_required": false,
  "topics": [

  ],
  "visibility": "public",
  "forks": 0,
  "open_issues": 0,
  "watchers": 0,
  "default_branch": "master",
  "permissions": {
    "admin": true,
    "maintain": true,
    "push": true,
    "triage": true,
    "pull": true
  },
  "network_count": 0,
  "subscribers_count": 1
}
```

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