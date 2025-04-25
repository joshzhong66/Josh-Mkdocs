#!/usr/bin/env python3
"""
WinGet 预索引源生成工具
版本: 1.1
功能: 自动扫描 manifests 目录并生成符合微软规范的 index.db 和 index.json
"""

import os
import sqlite3
import yaml
import json
from pathlib import Path
from datetime import datetime

# 配置区 ========================================================
MANIFESTS_PATH = "/data/mirrors/tools/winget-pkgs/manifests"  # 清单文件目录
OUTPUT_PATH = "/data/mirrors/tools/winget-pkgs"               # 输出目录
BASE_URL = "https://mirrors.sunline.cn/tools/winget-pkgs/"    # 最终访问URL
# ==============================================================

class WinGetIndexGenerator:
    def __init__(self):
        self.conn = None
        self.total_files = 0
        self.processed_files = 0
        self.errors = []

    def create_database(self):
        """创建符合微软规范的 SQLite 数据库结构"""
        db_path = os.path.join(OUTPUT_PATH, "index.db")
        Path(OUTPUT_PATH).mkdir(parents=True, exist_ok=True)

        if os.path.exists(db_path):
            os.remove(db_path)

        self.conn = sqlite3.connect(db_path)
        cursor = self.conn.cursor()

        # 创建主表（根据微软官方实现逆向工程）
        cursor.execute('''
            CREATE TABLE manifests(
                rowid INTEGER PRIMARY KEY,
                package_id TEXT NOT NULL,
                version TEXT NOT NULL,
                channel TEXT NOT NULL,
                path TEXT NOT NULL,
                manifest_type INTEGER NOT NULL
            )
        ''')

        # 创建索引（加速查询）
        cursor.execute('''
            CREATE INDEX idx_package ON manifests (package_id)
        ''')
        cursor.execute('''
            CREATE INDEX idx_version ON manifests (version)
        ''')
        
        self.conn.commit()

    def process_manifest(self, file_path):
        """处理单个清单文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                manifest = yaml.safe_load(f)

            # 验证必要字段
            required_fields = ['PackageIdentifier', 'PackageVersion']
            for field in required_fields:
                if field not in manifest:
                    raise ValueError(f"缺少必要字段: {field}")

            # 确定清单类型 (1=Version, 3=Install, 5=DefaultLocale)
            manifest_type = 1  # 默认为 Version 类型
            if 'Installers' in manifest:
                manifest_type = 3
            elif 'PackageLocale' in manifest:
                manifest_type = 5

            # 转换路径格式（确保使用URL斜杠）
            rel_path = os.path.relpath(file_path, MANIFESTS_PATH)
            rel_path = rel_path.replace(os.sep, '/')

            # 插入数据库
            cursor = self.conn.cursor()
            cursor.execute('''
                INSERT INTO manifests 
                (package_id, version, channel, path, manifest_type)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                manifest['PackageIdentifier'],
                manifest['PackageVersion'],
                "",  # channel 通常为空
                rel_path,
                manifest_type
            ))

            self.processed_files += 1
            if self.processed_files % 100 == 0:
                self.print_progress()

        except Exception as e:
            self.errors.append(f"{file_path}: {str(e)}")

    def generate_index_json(self):
        """生成辅助的 index.json 文件"""
        index_data = {
            "Format": "1.0.0",
            "SourceIdentifier": "MirrorSource",
            "ServerData": {
                "DateGenerated": datetime.utcnow().isoformat() + "Z",
                "SourceIdentifier": "MirrorSource",
                "BaseUrl": BASE_URL
            }
        }

        with open(os.path.join(OUTPUT_PATH, "index.json"), 'w') as f:
            json.dump(index_data, f, indent=2)

    def scan_total_files(self):
        """预先扫描总文件数"""
        print("正在扫描清单文件总数...")
        self.total_files = sum(
            1 for _, _, files in os.walk(MANIFESTS_PATH) 
            for f in files 
            if f.endswith(('.yaml', '.yml'))
        )
        print(f"发现 {self.total_files} 个清单文件")

    def print_progress(self):
        """显示处理进度"""
        progress = self.processed_files / self.total_files * 100
        print(
            f"[{datetime.now().strftime('%H:%M:%S')}] "
            f"已处理 {self.processed_files}/{self.total_files} "
            f"({progress:.1f}%)"
        )

    def run(self):
        """主运行流程"""
        print("="*50)
        print("WinGet 本地源索引生成工具")
        print(f"清单目录: {MANIFESTS_PATH}")
        print(f"输出目录: {OUTPUT_PATH}")
        print("="*50 + "\n")

        # 初始化
        self.scan_total_files()
        self.create_database()

        # 遍历处理文件
        start_time = datetime.now()
        for root, _, files in os.walk(MANIFESTS_PATH):
            for file in files:
                if file.lower().endswith(('.yaml', '.yml')):
                    full_path = os.path.join(root, file)
                    self.process_manifest(full_path)

        # 收尾工作
        self.conn.commit()
        self.conn.close()
        self.generate_index_json()

        # 生成报告
        print("\n" + "="*50)
        print(f"处理完成！耗时: {datetime.now() - start_time}")
        print(f"成功处理: {self.processed_files}/{self.total_files}")
        print(f"错误数量: {len(self.errors)}")

        if self.errors:
            print("\n错误列表（前20项）:")
            for error in self.errors[:20]:
                print(f"  {error}")

if __name__ == "__main__":
    try:
        generator = WinGetIndexGenerator()
        generator.run()
    except KeyboardInterrupt:
        print("\n用户中断操作！")