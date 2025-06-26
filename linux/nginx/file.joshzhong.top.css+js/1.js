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
  // ✅ 添加站点头部栏
  const header = document.createElement("div");
  header.id = "custom-header";
  header.innerHTML = `
    // 使用高32 * 宽36的图片分辨率作为头像
    <img src="https://pic.joshzhong.top/i/2025/06/11/inpo3t.png" alt="头像" id="site-logo">
    <span id="site-title">Josh's Download Site</span>
    `;
  //document.body.insertBefore(header, document.body.firstChild);
  document.body.insertBefore(musicContainer, document.body.firstChild);


    // ✅ 添加字体样式（只改站点文字）
  const titleStyle = document.createElement("style");
  titleStyle.textContent = `
    #site-title {
        font-size: 28px;
        font-weight: bold;
    }
    `;
  document.head.appendChild(titleStyle);
  // ✅ 添加网易云风格样式
  const style = document.createElement("style");
  style.textContent = `
    #music-player {
      display: flex;
      //justify-content: center;     /* ✅ 音乐播放器 居中 */
      //justify-content: flex-start;   /* ✅ 音乐播放器 左对齐 */
      margin-left: 20px;             /* ✅ 与头像左边对齐 */
      align-items: center;
      gap: 20px;
      margin: 20px auto;
    }
    #music-player button {
      background: none;
      border: none;
      font-size: 20px;
      color: #666;
      cursor: pointer;
      transition: transform 0.2s ease;
    }
    #music-player button:hover {
      transform: scale(1.2);
      color: #111;
    }
    // #play {
    //   background-color:rgb(165, 105, 105);     /* 底色 */
    //   color: white;                    /* 白色图标 */
    //   border: none;
    //   border-radius: 50%;              /* 圆形 */
    //   width: 50px;
    //   height: 50px;
    //   font-size: 24px;
    //   box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    //   cursor: pointer;
    //   transition: transform 0.2s ease, background-color 0.2s ease;
    // }
    // #play:hover {
    //   background-color: #ff0000;    /* 鼠标悬停更深红色 */
    //   background-color: #a94cff;
    // }
    #play {
      background-color:rgb(150, 103, 103);
      border: none;
      border-radius: 50%;
      width: 64px;
      height: 64px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;

       /* 增强视觉的 box-shadow */
      box-shadow: 0 0 0 6px rgba(255, 60, 60, 0.1), 0 6px 12px rgba(0, 0, 0, 0.3);
      transition: background-color 0.3s ease, transform 0.2s ease;
    }

    #play:hover {
      background-color:rgb(209, 195, 223);
      background-color:rgb(145, 140, 150);
      transform: scale(1.1);
    }
    .play-icon {
      color: white;
      font-size: 28px;
      font-weight: bold;
    }
  `;
  document.head.appendChild(style);

  // ✅ 插入播放器界面
  const musicContainer = document.createElement("div");
  musicContainer.id = "music-player";
  musicContainer.innerHTML = `
    <button id="prev" title="上一首">⏮️</button>
    <button id="play" title="播放/暂停">▶️</button>
    <button id="next" title="下一首">⏭️</button>
    <button id="mode-toggle" title="播放模式">🔁</button>
    <audio id="player" controls style="display:none;"></audio>
  `;
//  插入播放器界面（到web中间）
//   const insertTarget = document.getElementById("directory-listing");
//   if (insertTarget && insertTarget.parentNode) {
//     insertTarget.parentNode.insertBefore(musicContainer, insertTarget);
//   } else {
//     document.body.insertBefore(musicContainer, document.body.firstChild);
//   }

  // 插入到站点和log头像下方
  const customHeader = document.getElementById("custom-header");
  if (customHeader && customHeader.parentNode) {
    customHeader.parentNode.insertBefore(musicContainer, customHeader.nextSibling);
  } else {
    document.body.insertBefore(musicContainer, document.body.firstChild);
  }


  // ✅ 播放器逻辑
  const player = document.getElementById("player");
  const playlist = [
    "/8_Music/Love_Music/0110.反方向的钟.mp3",
    "/8_Music/Love_Music/1404.花海.mp3"
  ];
  let currentIndex = 0;
  let isRandom = false;

  function playSong(index) {
    if (!playlist || playlist.length === 0) {
      alert("播放列表为空！");
      return;
    }

    currentIndex = (index + playlist.length) % playlist.length;
    player.pause();
    player.src = playlist[currentIndex];
    player.load();
    player.style.display = "block";
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
});
