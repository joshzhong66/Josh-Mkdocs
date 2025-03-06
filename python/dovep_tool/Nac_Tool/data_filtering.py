class DataFiltering:
    def __init__(self, df, merge_path):
        self.df = df
        self.merge_path = merge_path
        self.departments_json = {
            "长亮科技": [
                "集团总裁办",
                "总裁办公室",
                "董事会办公室",
                "干部部",
                "战略规划部",
                "集团产品发展部",
                "研发体系",
                "研发中心",
                "销售总部",
                "集团解决方案部",
                "市场部",
                "集团项目管理部",
                "运营中心",
                "北京运营中心",
                "财务中心",
                "人力资源中心",
                "共享服务中心",
                "信息服务中心",
                "内部审计部",
                "税务部",
                "公共关系部",
                "健康督导办公室",
                "战略发展部"
            ],
            "数据总部": [],
            "数金总部": [],
            "长亮合度": [],
            "长亮金服": [],
            "长亮控股": [],
            "临时用户": [],
            "来宾用户": [],
            "前程无忧社保咨询": []
        }

    def update_department(self, row):
        row_clean = row.split()

        # 特定部门的快速匹配 ，例如针对研发中心开头的"研发中心 平台研发部 平台研发2部"直接定义为字典指定值
        specific_departments = {
            "核心业务线": "数金总部",
            "财金业务线": "数金总部",
            "解决方案及架构线": "数金总部",
            "平台技术服务线": "数金总部",
            "信贷业务线": "数金总部",
            "银行卡业务线": "数金总部",
            "银行管理业务线": "长亮合度",
            "价值管理业务线": "长亮合度",
            "交付中心": "长亮控股",
            "运营中心": "长亮控股",
            "研发中心": "研发中心",
            "销售总部": "销售总部"
        }

        for key, value in specific_departments.items():
            if key in row_clean[0]:
                return value

        # 遍历其他部门
        for top_level, sub_departments in self.departments_json.items():
            if row_clean[0] in top_level and len(sub_departments):
                if row_clean[1] == "集团解决方案及市场部":
                    if row_clean[2] == "市场部":
                        return row_clean[2]
                    else:
                        return "集团解决方案部"
                else:
                    return row_clean[1]
            else:
                if row_clean[0] == "长亮控股Sunline.Holding":
                    return "长亮控股"
                return row_clean[0]  # 如果没有匹配到任何部门，则返回公司部门

    def department_modification(self):
        # 处理部门数据
        self.df['Department'] = self.df['Department'].apply(self.update_department)
        self.df.to_excel(self.merge_path, index=False)
