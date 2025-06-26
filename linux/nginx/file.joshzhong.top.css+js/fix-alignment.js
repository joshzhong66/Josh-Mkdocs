document.addEventListener('DOMContentLoaded', function () {
    // 月份转换映射
    const monthMap = {
        Jan: "01", Feb: "02", Mar: "03", Apr: "04",
        May: "05", Jun: "06", Jul: "07", Aug: "08",
        Sep: "09", Oct: "10", Nov: "11", Dec: "12"
    };

    // 日期格式转换函数
    function formatDate(input) {
        const timeRegex = /(\d{2})-([A-Za-z]{3})-(\d{4})(?:\s+(\d{2}:\d{2}))?/;
        const match = input.match(timeRegex);
        if (!match) return input;
        const [, day, mon, year, time] = match;
        return `${year}-${monthMap[mon]}-${day}${time ? ' ' + time : ''}`;
    }

    // 自然排序
    function naturalSort(a, b) {
        const nameA = a.link.match(/<a href="[^"]+">([^<]+)<\/a>/)[1];
        const nameB = b.link.match(/<a href="[^"]+">([^<]+)<\/a>/)[1];
        return nameA.localeCompare(nameB, undefined, {
            numeric: true,
            sensitivity: 'base'
        });
    }

    // 获取原始的pre元素
    const pre = document.querySelector('pre');
    if (!pre) return;

    // 创建目录列表容器
    const container = document.createElement('div');
    container.id = 'directory-listing';

    // 创建表头
    const header = document.createElement('div');
    header.id = 'directory-header';
    header.innerHTML = `
        <div>Type</div>
        <div>Name</div>
        <div>Last Modified</div>
        <div>Size</div>
    `;
    container.appendChild(header);

    // 解析pre中的每一行
    const lines = pre.innerHTML.split('\n');
    const entries = [];

    // 提取所有条目（跳过标题行和空行）
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;

        if (line.includes('<a href="')) {
            const match1 = line.match(/(<a href="\.\.\/">\.\.\/<\/a>)/);
            const match2 = line.match(/(<a href="[^"]+">[^<]+<\/a>)\s+(\d{2}-[A-Za-z]{3}-\d{4}(?:\s+\d{2}:\d{2})?)\s+(\S+)/);

            if (match1) {
                entries.push({
                    link: match1[1],
                    date: "",
                    size: ""
                });
            } else if (match2) {
                entries.push({
                    link: match2[1],
                    date: formatDate(match2[2]),  // 在此处格式化时间
                    size: match2[3]
                });
            }
        }
    }


    // 排序（父目录保留在最上方）
    entries.sort((a, b) => {
        const aIsParent = a.link.includes('../');
        const bIsParent = b.link.includes('../');
        if (aIsParent) return -1;
        if (bIsParent) return 1;
        return naturalSort(a, b);
    });


    // 创建所有条目行
    entries.forEach(entry => {
        const row = document.createElement('div');
        row.className = 'directory-row';

        const linkMatch = entry.link.match(/<a href="([^"]+)">([^<]+)<\/a>/);
        if (!linkMatch) return;

        const href = linkMatch[1];
        const text = (linkMatch[2] === '../') ? '<font color="black"><b>Parent Directory</b></font>' : linkMatch[2];

        const isDir = href.endsWith('/');
        const isParent = href === '../';

        row.innerHTML = `
            <div>${isParent ? '⬆' : isDir ? '📁' : '📄'}</div>
            <div class="filename"><a href="${href}">${text}</a></div>
            <div class="date">${entry.date}</div>
            <div class="size">${entry.size}</div>
        `;

        container.appendChild(row);
    });

    // 替换原始的pre元素
    pre.parentNode.replaceChild(container, pre);

    // 移除原始的水平线
    const hr = document.querySelector('hr');
    if (hr) hr.remove();

    // 移除原始标题（因为我们在sub_filter中已经修改了标题）
    const oldHeader = document.querySelector('h1');
    if (oldHeader && oldHeader.textContent.startsWith('Index of')) {
        oldHeader.remove();
    }
});


document.addEventListener("DOMContentLoaded", function () {
  // 1. 插入播放器容器
  const musicContainer = document.createElement("div");
  musicContainer.id = "music-player";
  musicContainer.style.cssText = "margin: 20px 0; display: flex; align-items: center; gap: 12px; font-size: 20px;";

  musicContainer.innerHTML = `
    <button id="mode-toggle" title="播放模式" style="cursor:pointer;">🔁</button>
    <button id="prev" title="上一首" style="cursor:pointer;">⏮️</button>
    <button id="play" title="播放/暂停" style="cursor:pointer;">▶️</button>
    <button id="next" title="下一首" style="cursor:pointer;">⏭️</button>
    <audio id="player" controls style="display:none;"></audio>
  `;

  const insertTarget = document.getElementById('directory-listing');
  if (insertTarget && insertTarget.parentNode) {
    insertTarget.parentNode.insertBefore(musicContainer, insertTarget);
  } else {
    document.body.insertBefore(musicContainer, document.body.firstChild);
  }


  // 动态加载 music_list.js
  const script = document.createElement("script");
  script.src = "/music_list.js";
  script.onload = function () {
    if (!window.musicFiles || window.musicFiles.length === 0) {
      console.warn("⚠️ musicFiles 加载后为空！");
    } else {
      console.log("✅ 加载成功，共有", window.musicFiles.length, "首歌曲");
      initPlayer();
    }
  };
  document.head.appendChild(script);


  function initPlayer() {
    const player = document.getElementById("player");
    let playlist = window.musicFiles || [];
    let currentIndex = 0;
    let isRandom = false;

    function playSong(index) {
      if (!playlist || playlist.length === 0) {
        alert("没有音乐可播放！");
        return;
      }

      currentIndex = (index + playlist.length) % playlist.length;
      player.pause();
      player.src = playlist[currentIndex];
      player.load();
      player.play().catch(err => {
        console.warn("播放失败：", err);
      });
    }

    document.getElementById("play").addEventListener("click", () => {
      if (player.paused) {
        if (!player.src) playSong(currentIndex);
        else player.play();
      } else {
        player.pause();
      }
    });

    document.getElementById("next").addEventListener("click", () => {
      currentIndex = isRandom
        ? Math.floor(Math.random() * playlist.length)
        : currentIndex + 1;
      playSong(currentIndex);
    });

    document.getElementById("prev").addEventListener("click", () => {
      currentIndex = isRandom
        ? Math.floor(Math.random() * playlist.length)
        : currentIndex - 1;
      playSong(currentIndex);
    });

    document.getElementById("mode-toggle").addEventListener("click", () => {
      isRandom = !isRandom;
      document.getElementById("mode-toggle").textContent = isRandom ? "🔀" : "🔁";
    });

    player.addEventListener("ended", () => {
      document.getElementById("next").click();
    });
  }
});

