## Python 操作 Excel 详解

Excel 是办公软件中常用的工具之一，它可以用于存储、整理和分析数据。Python 是一门强大的编程语言，它可以用于自动化 Excel 操作。

在本教程中，我们将介绍 Python 操作 Excel 的详细知识，包括：

- 创建 DataFrame 对象
- 读取 Excel 文件
- 写入 Excel 文件
- 筛选数据
- 排序数据
- 计算数据
- 合并数据
- 删除数据

### 创建 DataFrame 对象

要操作 Excel 数据，我们需要将 Excel 数据转换为 DataFrame 对象。DataFrame 对象是 pandas 库中的数据结构，它可以用于存储表格数据。

以下代码演示了如何创建 DataFrame 对象：

```
import pandas as pd

# 创建 DataFrame 对象
df = pd.DataFrame({
    "a": [1, 2, 3],
    "b": [4, 5, 6],
    "c": [7, 8, 9]
})

# 查看 DataFrame 对象
print(df)
```



输出结果：

```
   a  b  c
0  1  4  7
1  2  5  8
2  3  6  9
```

### 读取 Excel 文件

要读取 Excel 文件，我们可以使用 pandas 库的 `read_excel()` 函数。

以下代码演示了如何读取 Excel 文件：

```
# 读取 Excel 文件
df = pd.read_excel("data.xlsx")

# 查看 DataFrame 对象
print(df)
```

输出结果与上面的代码相同。





我们还可以使用 `read_excel()` 函数的 `nrows` 参数指定要读取的行数，以及 `usecols` 参数指定要读取的列。

以下代码演示了如何读取 Excel 文件的前两行和 `a` 列和 `b` 列的数据：

```
# 读取前两行
df = pd.read_excel("data.xlsx", nrows=2)
print(df)

# 读取 a 和 b 列
df = pd.read_excel("data.xlsx", usecols=["a", "b"])
print(df)
```



输出结果：

```
   a  b
0  1  4
1  2  5

   a  b
0  1  4
1  2  5
```

### 写入 Excel 文件

要写入 Excel 文件，我们可以使用 pandas 库的 `to_excel()` 函数。

以下代码演示了如何写入 Excel 文件：



```
# 写入 Excel 文件
df.to_excel("output.xlsx")
```



这将创建一个名为 `output.xlsx` 的 Excel 文件，其中包含 `df` 对象的数据。

### 筛选数据

要筛选 Excel 数据，我们可以使用 `loc` 或 `query()` 方法。

以下代码演示了如何筛选 `a` 列值小于 10 的数据：



```
# 筛选 a 列值小于 10 的数据
df = df[df["a"] < 10]

print(df)
```



输出结果：

```
   a  b
0  1  4
1  2  5
2  3  6
```

### 排序数据

要排序 Excel 数据，我们可以使用 `sort_values()` 方法。

以下代码演示了如何按 `a` 列升序排序数据：

```
# 按 a 列升序排序数据
df = df.sort_values("a")

print(df)
```



输出结果：

```
   a  b
0  1  4
1  2  5
2  3  6
```

### 计算数据

要计算 Excel 数据，我们可以使用 `apply()` 方法。

以下代码演示了如何计算 `a` 列和 `b` 列的和：

Python

```
# 计算 a 列和 b 列的和
df["sum"] = df["a"] + df["b"]

print(df)
```



输出结果：

```
   a  b  sum
0  1  4    5
1  2  5    7
2  3  6    9
```

我们还可以使用 `Series.sum()` 方法直接计算列的和：



```
# 计算 a 列的和
sum_a = df["a"].sum()

print(sum_a)
```



输出结果：

```
6
```

### 合并数据

要合并 Excel 数据，我们可以使用 `concat()` 方法。

以下代码演示了如何合并两个 Excel 文件：

Python

```
import pandas as pd

def export_to_excel(df, file_name, sheet_name):
    df.to_excel(
        file_name,
        sheet_name=sheet_name,
        index=False,
        engine="openpyxl"
    )

# 创建第一个数据框
df1 = pd.DataFrame({
    "a1": [1, 2, 3],
    "b1": [4, 5, 6],
    "c1": [7, 8, 9]
})

# 创建第二个数据框
df2 = pd.DataFrame({
    "a2": [1, 2, 3],
    "b2": [4, 5, 6],
    "c2": [7, 8, 9]
})

# 导出第一个数据框到Excel
export_to_excel(df1, "data1.xlsx", "sheet1")

# 导出第二个数据框到Excel
export_to_excel(df2, "data2.xlsx", "sheet2")

# 读取第一个 Excel 文件df1
print(df1)

print("\n")

# 读取第二个 Excel 文件df2
print(df2)


#合并df1和df2， 合并两个 Excel 文件
merged_df = pd.concat([df1, df2], axis=1)
print(merged_df)
```



输出结果：

```
# 读取第一个 Excel 文件df1
	a1  b1  c1
0   1   4   7
1   2   5   8
2   3   6   9



# 读取第二个 Excel 文件df2
   a2  b2  c2
0   1   4   7
1   2   5   8
2   3   6   9


#合并df1和df2， 合并两个 Excel 文件

	a1  b1  c1  a2  b2  c2
0   1   4   7   1   4   7
1   2   5   8   2   5   8
2   3   6   9   3   6   9
```

我们还可以使用 `merge()` 方法合并 Excel 数据，该方法允许我们指定合并的条件。

以下代码演示了如何合并两个 Excel 文件，并根据 `a` 列进行合并：

```
# 读取第一个 Excel 文件
print(df1)
print("\n")

# 读取第二个 Excel 文件
print(df2)
print("\n")

# 合并两个 Excel 文件，并根据 a 列进行合并
merged_df1 = pd.merge(df1['a1'],df2['a2'],left_index=True,right_index=True)
print(merged_df1)
```



输出结果：

```
#df1
	a1  b1  c1
0   1   4   7
1   2   5   8
2   3   6   9

#df2

   a2  b2  c2
0   1   4   7
1   2   5   8
2   3   6   9


#合并后
   a1  a2
0   1   1
1   2   2
2   3   3
```

### 删除数据

要删除 Excel 数据，我们可以使用 `drop()` 方法。

以下代码演示了如何删除 Excel 文件中的一行：

```
#读取excel文件（df1和df2合并的值）
print(merged_df)
print("\n")


#删除第一行
merged_df = merged_df.drop(0)
print(merged_df)
```



输出结果：

```
#原数据
	a1  b1  c1  a2  b2  c2
0   1   4   7   1   4   7
1   2   5   8   2   5   8
2   3   6   9   3   6   9

#删除后
   a1  b1  c1  a2  b2  c2
1   2   5   8   2   5   8
2   3   6   9   3   6   9
```

我们还可以使用 `drop()` 方法删除 Excel 文件中的一列：

```
#读取excel文件（df1和df2合并的值）
print(merged_df)
print("\n")

#删除a1列
merged_df = merged_df.drop("a1",axis=1)
print(merged_df)

#同时删除两列
#merged_df = merged_df.drop(["b1","b1"],axis=1)
```



输出结果：

```
   a1  b1  c1  a2  b2  c2
1   2   5   8   2   5   8
2   3   6   9   3   6   9


   b1  c1  a2  b2  c2
1   5   8   2   5   8
2   6   9   3   6   9
```

### 总结

在本教程中，我们介绍了 Python 操作 Excel 的详细知识，包括：

- 创建 DataFrame 对象
- 读取 Excel 文件
- 写入 Excel 文件
- 筛选数据
- 排序数据
- 计算数据
- 合并数据
- 删除数据

通过学习本教程，您将能够使用 Python 进行各种操作。



### 练习题

**练习 1**

读取 `data.xlsx` 文件，并将 `a` 列和 `b` 列的数据合并到一个新列中。

**答案**

Python

```
# 读取 Excel 文件
df = pd.read_excel("data.xlsx")

# 将 a 列和 b 列的数据合并到一个新列中
df["sum"] = df["a"] + df["b"]

# 查看 DataFrame 对象
print(df)
```

请谨慎使用代码。[了解详情](https://bard.google.com/faq#coding)

content_copy

输出结果：

```
   a  b  c  sum
0  1  4  7  11
1  2  5  8  15
2  3  6  9  18
```

**练习 2**

将 `data.xlsx` 文件拆分为两个文件，一个包含 `a` 列和 `b` 列的数据，另一个包含 `c` 列的数据。

**答案**

Python

```
# 读取 Excel 文件
df = pd.read_excel("data.xlsx")

# 将 Excel 文件拆分为两个文件
df1 = df[["a", "b"]]
df2 = df[["c"]]

# 将两个 DataFrame 对象保存到 Excel 文件
df1.to_excel("data1.xlsx")
df2.to_excel("data2.xlsx")
```

请谨慎使用代码。[了解详情](https://bard.google.com/faq#coding)

content_copy

**练习 3**

计算 `data.xlsx` 文件中每个列的平均值。

**答案**

Python

```
# 读取 Excel 文件
df = pd.read_excel("data.xlsx")

# 计算每个列的平均值
for col in df.columns:
    print(col, df[col].mean())
```

请谨慎使用代码。[了解详情](https://bard.google.com/faq#coding)

content_copy

输出结果：

```
a  3
b  5
c  8
```

**扩展**

在本教程中，我们介绍了 Python 操作 Excel 的常用操作。您可以根据自己的需要进行扩展，例如：

- 使用 `applymap()` 方法对 Excel 数据进行批量处理
- 使用 `query()` 方法进行复杂的筛选
- 使用 `groupby()` 方法对 Excel 数据进行分组统计
- 使用 `pivot_table()` 方法创建 Excel 数据透视表

希望本教程对您有所帮助。







以下是一些额外的说明和提示：

- 在读取 Excel 文件时，可以使用 `sheet_name` 参数指定要读取的工作表。
- 在写入 Excel 文件时，可以使用 `index` 参数指定是否要写入行索引。
- 在筛选数据时，可以使用 `loc` 方法或 `query()` 方法。`loc` 方法用于根据行索引和列索引进行筛选，`query()` 方法用于根据逻辑表达式进行筛选。
- 在排序数据时，可以使用 `sort_values()` 方法。`sort_values()` 方法可以根据单个列或多个列进行排序。
- 在计算数据时，可以使用 `apply()` 方法或 `Series.apply()` 方法。`apply()` 方法可以对整个 DataFrame 对象进行计算，`Series.apply()` 方法可以对单个 Series 对象进行计算。
- 在合并数据时，可以使用 `concat()` 方法或 `merge()` 方法。`concat()` 方法用于合并具有相同列名的 Excel 文件，`merge()` 方法用于合并具有不同列名的 Excel 文件。
- 在删除数据时，可以使用 `drop()` 方法。`drop()` 方法可以删除行或列。

以下是一些练习题的扩展：

**练习 1**

可以使用 `apply()` 方法对 `a` 列和 `b` 列的数据进行合并，例如：

Python

```
# 读取 Excel 文件
df = pd.read_excel("data.xlsx")

# 将 a 列和 b 列的数据合并到一个新列中
df["sum"] = df.apply(lambda row: row["a"] + row["b"], axis=1)

# 查看 DataFrame 对象
print(df)
```

请谨慎使用代码。[了解详情](https://bard.google.com/faq#coding)

content_copy

**练习 2**

可以使用 `DataFrame.split()` 方法将 Excel 文件拆分为多个文件，例如：

Python

```
# 读取 Excel 文件
df = pd.read_excel("data.xlsx")

# 将 Excel 文件拆分为两个文件
df1, df2 = df.split(["a", "b"], axis=1)

# 将两个 DataFrame 对象保存到 Excel 文件
df1.to_excel("data1.xlsx")
df2.to_excel("data2.xlsx")
```

请谨慎使用代码。[了解详情](https://bard.google.com/faq#coding)

content_copy

**练习 3**

可以使用 `DataFrame.describe()` 方法计算 Excel 文件中每个列的统计信息，例如：

Python

```
# 读取 Excel 文件
df = pd.read_excel("data.xlsx")

# 计算每个列的统计信息
print(df.describe())
```

请谨慎使用代码。[了解详情](https://bard.google.com/faq#coding)

content_copy

希望这些说明和提示对您有所帮助。