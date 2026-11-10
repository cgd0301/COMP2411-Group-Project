下面是阶段 0 和阶段 1 的细化步骤。8 张表的建表语句按指南属于核心实现，由你们自己写（按分工是 SHI 执笔）。我这里给出结构、模板、核对清单和容易出错的地方，写完可以发给我审阅。

有一个前提要先说明：我没能连上本机的 MySQL（root 需要密码，我没有去猜）。所以下文标着"探针"的几处 MySQL 行为，是根据 MySQL 8.4 官方文档判断的，需要你们在 1.6 节实际跑一遍确认。

---

# 阶段 0：Stage 1 收尾与全局约定

这一阶段的目标是：存好 Stage 1 的状态，搭好 Stage 2 的工作环境，并把所有后续阶段都要遵守的约定一次定下来，避免以后返工。

## 0.1 给 Stage 1 打一个存档点

- **Git tag（标签）** 是给某个提交贴上永久的名字，以后可以随时回到"Stage 1 提交时的样子"，写 change log 时也方便对比。
- **branch（分支）** 让你们各自在独立的线上开发，写完再合并回 `main`。合并时如果走 PR（Pull Request，合并请求），另一人在 PR 里审阅。这样每项任务都有"一人负责、一人审阅"的记录，正好对应 proposal 第 8.1 节的分工安排。

```powershell
cd D:\programs\COMP2411\comp2411-project
git tag -a stage1-submitted -m "Stage 1 as submitted on 26 Oct 2026"
git push origin stage1-submitted
git switch -c stage2/setup        # 阶段 0 的工作在这个分支上做，完成后合并
```

打 tag 前先确认当前 `main` 就是提交时的状态。如果之后还改过，用 `git log` 找到对应的提交，再执行 `git tag -a stage1-submitted <提交号>`。

## 0.2 建 Stage 2 的目录骨架

建议直接在一个和最终 ZIP 同名的文件夹里开发，最后打包时只需要压缩这个文件夹。草稿、笔记、报告源码放在它外面，避免误打进 ZIP。

```
comp2411-project/stage2/
  COMP2411_2026_G085_Stage2/     ← 最终交付物，结构严格按指南第 9.1 节
    sql/  queries/  tests/negative/  evidence/query_results/
  notes/                         ← checklist、changelog、decisions、约束清单
  scratch/                       ← 探针脚本等草稿（不提交给课程）
  report/                        ← report 的 LaTeX 源码
  presentation/
```

```powershell
$pkg = "stage2\COMP2411_2026_G085_Stage2"
"sql","queries","tests\negative","evidence\query_results" | % { New-Item -ItemType Directory -Force "$pkg\$_" | Out-Null }
"notes","scratch","report","presentation" | % { New-Item -ItemType Directory -Force "stage2\$_" | Out-Null }
Get-ChildItem stage2 -Recurse -Directory | ? { -not (Get-ChildItem $_.FullName -Force) } | % { New-Item "$($_.FullName)\.gitkeep" -ItemType File | Out-Null }
```

Git 不会记录空文件夹，所以要在空文件夹里放一个占位文件 `.gitkeep`，文件夹才能进仓库。打包前要删掉交付目录里的所有 `.gitkeep`，因为指南不允许多余文件。这一条现在就写进 checklist。

## 0.3 找回 Stage 1 的最终 LaTeX 源码

仓库里的 `stage1/proposal/main.tex` 是旧模板，可追溯矩阵、分工和风险表都是空的；真正提交的 `proposal.pdf`（21 页）是完整的。`report.pdf` 大约一半内容要沿用 proposal，包括业务规则、用例、管理问题、ER 图、数据字典和范式化，所以必须先拿到最终源码：

1. 到当时编译 PDF 的地方去找：Overleaf 项目，或者另一位成员的电脑。
2. 把它放进仓库，覆盖旧的 `main.tex`，提交信息写明 "final source of submitted proposal"。
3. 重新编译一次，和提交的 `proposal.pdf` 对比页数与内容，确认一致。
4. 把它复制到 `stage2/report/` 作为 report 的起点。

## 0.4 建三份工作文档（放在 `stage2/notes/`）

| 文件           | 作用                                 | 怎么建                                                                                                                                                 |
| -------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `checklist.md` | Stage 2 的自检清单                   | 按 Stage 1 checklist 的做法，把指南第 6.1–6.5、9.1–9.4、10 节逐条拆成可以打勾的项，每项标出指南的节号                                                  |
| `changelog.md` | report 里必须有的 change log 的底稿  | 表头：`ID \| 日期 \| Stage 1 位置 \| 改动 \| 原因 \| 影响的文件`。第一条记录："Stage 1 feedback received: no issues raised; no design change planned." |
| `decisions.md` | 记录不属于设计改动、但影响实现的约定 | 0.5 节定下来的所有约定写进这里，每条一两句理由                                                                                                         |

区分"设计改动"和"约定"很重要：前者进 report 的 change log，比如新增一个 UNIQUE；后者只是实现层面的选择，比如基线日期选哪天，写进 README 或 report 的实现说明就够了。

## 0.5 定全局约定（两人一起，最重要的一步）

### (a) 季节日历

种子数据需要 4 个季度。下面的日期我已经用脚本核对过，都是星期一，相邻季度的范围互不重叠：

| 季度        | 第一个配送计划日 D | 订阅范围（D−6 ~ D+77）  | 报名窗口（BR4）                  | 基线日的状态          |
| ----------- | ------------------ | ----------------------- | -------------------------------- | --------------------- |
| Autumn 2025 | 2025-09-08         | 2025-09-02 ~ 2025-11-24 | Summer 2025 的范围（该季不入库） | finished              |
| Spring 2026 | 2026-03-02         | 2026-02-24 ~ 2026-05-18 | 2025-11-25 ~ 2026-02-23          | finished              |
| Summer 2026 | 2026-06-01         | 2026-05-26 ~ 2026-08-17 | 2026-02-24 ~ 2026-05-18          | active                |
| Autumn 2026 | 2026-09-07         | 2026-09-01 ~ 2026-11-23 | 2026-05-26 ~ 2026-08-17          | planned（窗口正开放） |

- **为什么要 Autumn 2025：** 春季的"上一个可订阅季"是上一年的秋季，这是 BR4 里最不容易想到的跨年规则。有了这个季度，Spring 2026 的续订价格（160/192）才有数据支撑。
- **为什么季度之间不能重叠：** 你们的范式分析里写了函数依赖 `submission_date → season_id`，以及候选键 `{customer_id, submission_date}`。这两条成立的前提是"任何一天最多只有一个季度开放报名"。日历一旦重叠，范式分析的结论就不成立了。这一点建议在 report 里点明。

### (b) 基线参考日期：`2026-07-07`（星期二）

选这一天，是因为五个用例在种子数据上都能直接演示：

- Spring 2026 和 Autumn 2025 已经结束，MQ1–MQ5 的数据完整。
- Summer 2026 第 6 周的配送日是 7 月 6 日（昨天），状态还是 planned，可以演示**记录配送结果（UC2）**。
- 第 7 周（7 月 13 日）的改动窗口是 7 月 7 日到 12 日，周配和双周配都在窗口内，可以演示**跳过（UC3）**和**加购（UC5）**。
- Autumn 2026 的报名窗口正在开放，Summer 的活跃订阅者来报名就是续订，可以演示**报名和续订折扣（UC1）**。
- 可以**取消 Summer 的活跃订阅（UC4 情况 B）**和 **Autumn 的已计划订阅（UC4 情况 A）**。

另外，proposal 风险表里举的例子是 `@ref_date = '2026-04-20'`，现在改为新的基线，在 `decisions.md` 记一笔即可。

### (c) 日期在脚本里怎么写

| 脚本              | 写法                                                                                                     |
| ----------------- | -------------------------------------------------------------------------------------------------------- |
| 测试和操作脚本    | 开头写 `SET @ref_date = '2026-07-07';`，后面一律和 `@ref_date` 比较                                      |
| `queries/Qxx.sql` | 指南要求每个文件只有一条 SELECT，所以先约定：日期直接写成字面量并加注释，或者从数据推出来。阶段 5 再细化 |
| 所有脚本          | 禁止使用 `CURDATE()` 和 `NOW()`                                                                          |

### (d) 命名约定

| 对象        | 规则                                                               | 例子（格式示意）      |
| ----------- | ------------------------------------------------------------------ | --------------------- |
| 表名和列名  | 沿用 Stage 1，snake_case；`chosen_products` 保持复数，不要悄悄改名 | —                     |
| CHECK       | `ck_<表>_<含义>`                                                   | `ck_delivery_week_no` |
| UNIQUE      | `uq_<表>_<列>`                                                     | `uq_customer_email`   |
| FOREIGN KEY | `fk_<子表>_<父表>`                                                 | `fk_add_on_delivery`  |

坚持命名有三个理由：

- MySQL 违反 CHECK 时会报出约束名，例如 `Check constraint 'ck_delivery_week_no' is violated.`，有名字才能看出是哪条规则挡住了数据。
- 官方文档规定，CHECK 名和外键名在整个库内都必须唯一，加表名前缀可以避免重名。
- 可追溯矩阵和负向测试都能直接引用这些名字。

### (e) SQL 风格和测试编号

- SQL 关键字大写，一行一列。每张表上方写一行注释，标明它实现了哪些 BR。
- 不写 `INT(11)` 这类显示宽度：MySQL 8.4 会发出弃用警告，`TINYINT(1)` 除外。
- 测试编号沿用 Stage 1：POS01…（正向测试）、TXC01（事务提交）、TXR01（事务回滚）、N01…（负向测试）。
- 每个 SQL 文件开头统一写一个注释块：文件用途、对应的 BR / Query ID / Test ID、运行前提。

## 0.6 统一两人的数据库环境

两个人各自在 DBeaver 里执行：

```sql
SELECT VERSION(), @@sql_mode, @@autocommit, @@default_storage_engine,
       @@character_set_server, @@collation_server;
```

| 项目             | 期望值                                                             | 为什么重要                                                                                                                                 |
| ---------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `VERSION()`      | `8.4.11`                                                           | 评分环境的版本                                                                                                                             |
| `@@sql_mode`     | 包含 `STRICT_TRANS_TABLES` 和 `ONLY_FULL_GROUP_BY`（8.4 默认就有） | **严格模式**下，插入超出范围或类型不对的值会直接报错，而不是悄悄截断，负向测试才有意义。`ONLY_FULL_GROUP_BY` 会影响阶段 5 的 GROUP BY 写法 |
| `@@autocommit`   | `1`                                                                | 阶段 7 写事务时，README 要说明这个设置                                                                                                     |
| 存储引擎         | `InnoDB`                                                           | 只有 InnoDB 支持事务和外键                                                                                                                 |
| 字符集和排序规则 | `utf8mb4` / `utf8mb4_0900_ai_ci`                                   | 见 1.2 节第 ②点：这种排序规则不区分大小写                                                                                                  |

把两个人的输出保存到 `decisions.md`，以后写 README 的 Environment 部分要用。

然后建库，并建议建一个专用账号。账号这一步可选，但它和评分环境"一个专用数据库"的设定一致，README 写账号权限时也有依据：

```sql
-- 在 DBeaver 里用 root 执行一次，不要放进任何要提交的脚本
CREATE DATABASE comp2411_g085;
CREATE DATABASE comp2411_g085_scratch;      -- 给 1.6 节的探针测试专用
CREATE USER 'g085_dev'@'localhost' IDENTIFIED BY '<自己设的密码>';
GRANT ALL PRIVILEGES ON comp2411_g085.*         TO 'g085_dev'@'localhost';
GRANT ALL PRIVILEGES ON comp2411_g085_scratch.* TO 'g085_dev'@'localhost';
```

再确认能用**命令行客户端（CLI）**跑脚本。CLI 就是 MySQL 自带的命令行程序 `mysql.exe`，它最接近评分者执行脚本的方式。DBeaver 会自己拆分语句、自己处理报错，有时会掩盖问题。

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u g085_dev -p comp2411_g085
```

进入 `mysql>` 提示符后，用 `source` 执行脚本，路径用正斜杠：

```
source D:/programs/COMP2411/comp2411-project/stage2/COMP2411_2026_G085_Stage2/sql/01_schema.sql
```

注意 PowerShell 不支持 `mysql ... < file.sql` 这种输入重定向，所以用 `source`。

## 0.7 metadata、ai_usage 和致谢核查

- **`metadata.json`：** 在交付目录里新建一份，改成 `"stage": 2`。`scenario_id` 改成大写的 `D17-W04`。`canvas_group_name` 从 Canvas 原样复制，Stage 1 版本末尾多了一个空格。`dbms_version` 填 0.6 节实际查到的版本。最后执行 `python -m json.tool metadata.json` 验证格式。
- **`ai_usage.md`：** 新建 Stage 2 版本，表头按指南第 8 节：工具、用途、影响的文件或章节、采纳还是拒绝、你们怎么核对的。第一行记录这次规划对话。
- **致谢核查：** 用 PDF 阅读器打开指南，Ctrl+F 搜索 `Yuawqv`。如果高亮出现在看得见的文字上，就是正式要求；如果搜得到但页面上看不见（比如白色字），就去问助教。把结论写进 `decisions.md`。

## 阶段 0 完成标准

- [ ] 已经打好 `stage1-submitted` 标签，Stage 2 目录骨架已提交
- [ ] Stage 1 的最终 LaTeX 源码已入库，编译结果和提交的 PDF 一致
- [ ] `checklist.md`、`changelog.md`、`decisions.md` 已建好，且 decisions 里写明了日历、基线日期、命名、两人的环境输出
- [ ] 两台机器都通过了 0.6 节的检查，CLI 能连上数据库
- [ ] Stage 2 的 `metadata.json` 和 `ai_usage.md` 已建好，致谢问题已有结论

---

# 阶段 1：建表脚本 `sql/01_schema.sql`

这一阶段的目标是：在空库上用 CLI 一次跑通，零报错零警告；每一条约束都经过一个能通过和一个会失败的样例验证；DDL 和数据字典逐列一致。

## 1.1 先做"约束清单"，再写 DDL

在 `stage2/notes/constraint_inventory.md` 里，把数据字典和 `businessRules.md` 的 Enforcement 栏中**所有要写进 DDL 的约束**列成一张表。DDL 照着这张表写；它以后还会变成负向测试清单（阶段 7），也是可追溯矩阵里约束名的来源。

| 约束名                          | 表           | 类型   | 列或表达式               | BR  | 违反样例                     | 预期错误 | 实测错误     |
| ------------------------------- | ------------ | ------ | ------------------------ | --- | ---------------------------- | -------- | ------------ |
| uq_subscription_customer_season | subscription | UNIQUE | (customer_id, season_id) | BR2 | 同一客户、同一季度插入第二条 | 1062     | （1.6 节填） |
| ck_delivery_week_no             | delivery     | CHECK  | week_no 在 1 到 12 之间  | BR7 | week_no = 13                 | 3819     |              |
| …                               |              |        |                          |     |                              |          |              |

清单写完后核对一下数量：外键应该正好 **10 个**，分别是：

- product → season
- subscription → customer
- subscription → season
- chosen_products → subscription
- chosen_products → product
- delivery → subscription
- add_on → delivery（复合外键）
- add_on → product
- refund → subscription
- refund → delivery（复合外键）

数不对，说明 ER 映射时漏了关系。

## 1.2 写之前要拍板的五个问题

这些问题在数据字典里没写到，写 DDL 时一定会遇到。每个问题的决定写进 `decisions.md`；如果属于设计改动，写进 `changelog.md`。

**① 外键要不要显式写 `ON DELETE RESTRICT`？**

官方文档原话是：被 CHECK 引用的列，不能再挂外键的引用动作（ON UPDATE / ON DELETE）。你们的 `refund.week_no` 同时出现在 `ck_refund_link` 和指向 delivery 的复合外键里，正好卡在这条规则上。

文档没有说清楚：显式写出 `RESTRICT` 算不算"引用动作"？我判断多半不算，因为通常只有 CASCADE、SET NULL 这类会改动数据的动作才被禁止，但需要在 1.6 节实测。

在 InnoDB 里，不写引用动作时的默认行为本来就是 RESTRICT，所以最稳妥的做法是：涉及 CHECK 列的外键干脆不写 ON DELETE 子句，在注释里说明"默认即为 RESTRICT"。

**② 状态类取值要不要区分大小写？**

默认排序规则 `utf8mb4_0900_ai_ci` 里的 `ci` 表示不区分大小写，所以 `'PLANNED'` 也能通过 `CHECK (status IN ('planned', …))`，存进库里却是大写。这会影响后续查询的一致性。有两种选择：

- 接受这一点，写进 limitations；
- 给这些列加上 `COLLATE utf8mb4_bin`（按二进制比较，区分大小写）。

这正是能拿到"独立设计理由"的小决定。附带说明：`email` 的 UNIQUE 不区分大小写，反而是想要的效果。

**③ 范式分析里的候选键，DDL 里落实了吗？**

你们的 `normalization.md` 声明了两个数据字典里**没有**做成 UNIQUE 的候选键：

- `subscription` 的 `{customer_id, submission_date}`
- `refund` 的 `{subscription_id, type, refund_date}`

评分标准里"范式化与完整性"一项看的是"已实现的约束"，和"一致性"有关。两种处理都可以：一是加上 UNIQUE（属于设计改动，记入 change log）；二是在 report 里说明为什么不加，例如"这条由其他规则和日历保证"。但不能让 report 和 DDL 互相矛盾。

**④ 要不要补几条低成本的 CHECK？**

只有能对应到某条已有规则的才值得加，不要为了数量而加。可以考虑的方向：

| 候选 CHECK                                                      | 对应的规则                          |
| --------------------------------------------------------------- | ----------------------------------- |
| `status = 'cancelled'` 当且仅当 `cancellation_date IS NOT NULL` | BR3、BR10                           |
| `cancellation_date >= submission_date`                          | BR10                                |
| `is_farmers_choice IN (0, 1)`                                   | BR6（TINYINT 本身允许 −128 到 127） |
| `YEAR(first_planning_day) = year`                               | BR3                                 |

每加一条，都要同步更新 businessRules 的 Enforcement 栏、change log 和约束清单。

**⑤ 有符号还是无符号？这决定负向测试报哪个错**

- `remaining_refundable_skip` 在数据字典里是**有符号**的 `TINYINT`，这样是对的：把 0 再减 1 得到 −1，会触发 CHECK，报 **3819**。如果改成 UNSIGNED，同样的 UPDATE 会报 **1690**（数值超出范围），和 Stage 1 写的预期 3819 对不上。
- `week_no` 是 `TINYINT UNSIGNED`：插入 13 会报 3819，但插入 −1 报的是 **1264**（超出范围），不是 3819。设计负向测试时，要选能真正触发 CHECK 的违规值。

## 1.3 脚本整体结构

```
-- 文件头注释：用途、G085 / D17-W04、目标 MySQL 8.4.11、运行前提（已选中一个空的专用库）
-- 第 1 段：DROP TABLE IF EXISTS，按"子表 → 父表"的顺序
-- 第 2 段：CREATE TABLE，按"父表 → 子表"的顺序
```

**建表顺序**要满足一个条件：被引用的表必须先建（这叫拓扑排序）。你们 8 张表的依赖关系是：

```
第 1 层：customer, season
第 2 层：product（引用 season）, subscription（引用 customer、season）
第 3 层：chosen_products（引用 subscription、product）, delivery（引用 subscription）
第 4 层：add_on（引用 delivery、product）, refund（引用 subscription、delivery）
```

DROP 的顺序反过来，从第 4 层删到第 1 层。

**为什么要写 `DROP TABLE IF EXISTS`：** 有了它，脚本可以反复执行，开发时随时重建表结构。评分者用的是空库，这些语句只是什么都不做，没有害处。

**明确禁止的写法：**

- `CREATE DATABASE`、`DROP DATABASE`、`USE ...`（评分者会自己选库，表名不能带库名前缀）
- `SET FOREIGN_KEY_CHECKS = 0`（指南明确禁止用它掩盖建表顺序问题）
- 任何账号或密码

## 1.4 语法模板（只用占位名，不是你们的表）

```sql
-- 模板：表名和列名都是占位符
CREATE TABLE child_tbl (
    parent_id  INT UNSIGNED      NOT NULL,
    line_no    TINYINT UNSIGNED  NOT NULL,
    kind       VARCHAR(10)       NOT NULL DEFAULT 'k1',
    ref_no     TINYINT UNSIGNED  NULL,
    PRIMARY KEY (parent_id, line_no),                              -- 复合主键
    CONSTRAINT uq_child_tbl_parent_ref UNIQUE (parent_id, ref_no),
    CONSTRAINT fk_child_tbl_parent
        FOREIGN KEY (parent_id) REFERENCES parent_tbl (parent_id),
    CONSTRAINT fk_child_tbl_other                                  -- 复合外键
        FOREIGN KEY (parent_id, ref_no) REFERENCES other_tbl (parent_id, line_no),
    CONSTRAINT ck_child_tbl_line_no CHECK (line_no BETWEEN 1 AND 20),
    CONSTRAINT ck_child_tbl_kind_ref CHECK (                       -- 条件型 CHECK
           (kind IN ('k1','k2') AND ref_no IS NOT NULL)
        OR (kind = 'k3'         AND ref_no IS NULL))
) ENGINE = InnoDB;
```

要点说明：

- **主键名：** MySQL 的主键名永远是 `PRIMARY`，写了 `CONSTRAINT pk_x` 也会被忽略，所以不用给主键起名。
- **复合外键：** 列的个数和顺序必须和被引用表的主键（或某个 UNIQUE 索引）一致，类型也要完全相同，包括 UNSIGNED。不满足时常见的报错是：
  - 类型不兼容：3780
  - 被引用的列上没有索引：1822
  - 被引用的表还没建：1824

  具体报什么以实测为准。

- **含 NULL 的复合外键：** 只要外键里有一列是 NULL，MySQL 就不检查这个外键（这种规则叫 MATCH SIMPLE）。你们的"取消退款不关联任何配送"正是靠这个特性实现的，所以 1.6 节要专门验证一次。
- **字符串里的单引号：** 要写两次，即 `'farmer''s choice'`。以后每个查询都要这样写，建议在 decisions 里提醒自己。
- **CHECK 里允许用的东西：** 只能用确定性函数，`DAYOFWEEK()` 可以，`CURDATE()` 不行。不能引用 AUTO_INCREMENT 列，不能用子查询，不能用变量。

## 1.5 逐表核对清单（内容全部来自你们的数据字典）

| 表              | 主键                                   | UNIQUE                                  | 外键                                                  | CHECK / DEFAULT                                                                                                           | 要特别注意的                                                         |
| --------------- | -------------------------------------- | --------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| customer        | customer_id                            | email                                   | —                                                     | —                                                                                                                         | 地址的三列都是 NOT NULL                                              |
| season          | season_id                              | (season_name, year)；first_planning_day | —                                                     | season_name 只能取 3 个值；DAYOFWEEK(first_planning_day) = 2                                                              | `year` 是 MySQL 的非保留关键字，可以直接当列名，但要留意编辑器的高亮 |
| product         | product_id                             | (season_id, name)                       | → season                                              | price_per_kg ≥ 0；is_farmers_choice 默认 0                                                                                | season_id 的类型是 SMALLINT UNSIGNED，必须和 season 一致             |
| subscription    | subscription_id                        | (customer_id, season_id)                | → customer，→ season                                  | status 4 个值（默认 'planned'）；plan_type 2 个值；frequency 2 个值；套餐与价格匹配；剩余跳过次数在 0 到 2 之间（默认 2） | cancellation_date 允许 NULL；1.2 节第 ③、④点                         |
| chosen_products | (subscription_id, product_id)          | —                                       | → subscription，→ product                             | —                                                                                                                         | 只有两列，都属于主键                                                 |
| delivery        | (subscription_id, week_no)             | —                                       | → subscription                                        | week_no 在 1 到 12 之间；status 5 个值（默认 'planned'）                                                                  | 弱实体：主键里包含所属订阅的主键                                     |
| add_on          | (subscription_id, week_no, product_id) | —                                       | (subscription_id, week_no) → delivery；→ product      | weight ≥ 0.10                                                                                                             | 指向 delivery 的是**一个**复合外键，不是两个单列外键                 |
| refund          | refund_id                              | (subscription_id, week_no)              | → subscription；(subscription_id, week_no) → delivery | amount > 0；type 3 个值；ck_refund_link                                                                                   | week_no 允许 NULL；1.2 节第 ①、③点                                   |

写的时候一张表一张表来：写完一张就执行一次，通过了再写下一张，不要 8 张全写完再一起调试。

## 1.6 探针验证

**探针（probe）** 是指对每条约束各执行一条应该成功的语句和一条应该失败的语句，确认它真的生效，并且报的是预期的错误号。

- 在 `comp2411_g085_scratch` 库里做，脚本放在 `stage2/scratch/schema_probe.sql`。这个文件不提交给课程，但要提交到 Git，作为开发过程的证据。
- 每次探针前先重跑 `01_schema.sql` 清空数据，有了 DROP IF EXISTS 这一步很快。
- 用 Ctrl+Enter 逐条执行，把实测的错误号填进约束清单的"实测错误"一栏。

每条探针按下面的格式写：

```sql
-- PROBE-xx | BR? | 约束名 | 预期：成功 / 错误号
-- 前置：先插入最少量的合法父表数据
-- 动作：一条语句
-- 实测：（执行后填写）
```

**必须覆盖的特殊探针**，也就是前面提到的、需要实测才能确认的行为：

1. 显式写 `ON DELETE RESTRICT` 的外键 + `ck_refund_link`，建表能否成功？还是报 3823 一类的错？（1.2 节第 ①点）
2. 一条 cancellation 退款（week_no 为 NULL）能否插入？一条 skip 退款指向第 5 周、但该订阅没有第 5 周配送，是否报 1452？（复合外键遇到 NULL 的行为）
3. 用 `'PLANNED'` 作为状态值能否通过 CHECK？（1.2 节第 ②点）
4. 剩余跳过次数为 0 时再减 1，报 3819 吗？week_no 填 13 和填 −1 分别报什么？（1.2 节第 ⑤点）
5. 用星期二作为 first_planning_day，是否报 3819？
6. 重量填 0.05 应报 3819。顺带试一下 0.104：DECIMAL(5,2) 会把它四舍五入成 0.10，然后通过检查。这是一个值得写进 limitations 的边界。
7. 套餐是 farmer's choice、价格填 240，是否报 3819？
8. 删除一个还有订阅的客户，是否报 1451？

这些探针在阶段 7 基本可以直接改写成 `tests/negative/Nxx.sql`，现在多花些功夫，后面能省很多事。

## 1.7 用系统表核对建出来的结构

`information_schema` 是 MySQL 自带的"关于数据库本身的数据库"，可以用 SQL 查出建好的所有表、列和约束。把查询结果导出成 CSV，和约束清单、数据字典逐行对照：

```sql
-- 所有约束（核对数量和名字）
SELECT TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME;

-- CHECK 的实际表达式（MySQL 会改写格式，核对逻辑是否一致）
SELECT CONSTRAINT_NAME, CHECK_CLAUSE
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE();

-- 外键的列对应关系（复合外键会显示多行）
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION;

-- 列定义（和数据字典逐列对照：类型、是否允许 NULL、默认值）
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

另外，在 DBeaver 里双击库，打开 **ER Diagram** 标签页，把它和 Stage 1 的 `relational_schema.pdf` 对照，看连线和键是否一致。

## 1.8 从零重建测试（用 CLI）

1. 用 root 执行 `DROP DATABASE comp2411_g085; CREATE DATABASE comp2411_g085;`，模拟评分者的空库。这两句只在本机跑，不放进脚本。
2. 用 CLI 执行 `source .../01_schema.sql`，要求零个 ERROR。
3. 紧接着执行 `SHOW WARNINGS;`，要求为空。有警告就要查清楚原因，最常见的是写了显示宽度。
4. 再 `source` 一次，验证脚本可以重复执行。
5. **换另一位成员**在他的电脑上从第 1 步重做一遍。

## 1.9 文档同步

- 用 1.7 节导出的列定义逐列对照 `DataDictionary.md`：每一处不一致，要么改 DDL，要么改数据字典并写进 change log。
- 1.2 节的五个决定分别归档到 decisions 或 changelog。
- `businessRules.md` 的 Enforcement 栏如果有变化（新增 CHECK、新增 UNIQUE），同步修改。
- 约束清单的"实测错误"一栏全部填满。

## 1.10 交叉审阅与提交（CHEN 审阅）

审阅人按下面的清单逐项检查，结果写在 PR 评论或 `meetings.md` 里：

- [ ] 8 张表、10 个外键，数量和名字与约束清单一致
- [ ] 每个外键两侧的类型完全一致，包括 UNSIGNED
- [ ] 每个约束名都带表名前缀，全库没有重名
- [ ] 没有 `CREATE/DROP DATABASE`、`USE`、`FOREIGN_KEY_CHECKS`，也没有密码
- [ ] CLI 连续执行两次都零错误零警告，另一台机器也通过
- [ ] 每张表上方的注释标出了对应的 BR
- [ ] 审阅人随机抽两条规则，能讲清楚它从 ER 构造、到表、到约束、再到探针的完整链条

审阅通过后合并到 `main`，并在 `ai_usage.md` 里记录本阶段使用 AI 的情况，比如请我审阅 DDL。

## 阶段 1 完成标准

- [ ] `sql/01_schema.sql` 在空库上用 CLI 执行，零报错零警告，可以重复执行
- [ ] 约束清单上每一条都有通过和失败的探针，实测错误号已记录
- [ ] 1.2 节的五个问题都已拍板，并归档到相应文档
- [ ] DDL、数据字典、businessRules 三者一致
- [ ] 另一位成员已经独立复现

---

你们按这份推进时，任何一步都可以把草稿发给我审阅，比如约束清单、某张表的 DDL 或探针的实测结果。准备好了，我们再细化阶段 2（种子数据）和阶段 3（业务操作脚本）。这两个阶段关系最紧：种子数据要在基线日期 2026-07-07 那一天前后完全自洽，比较难做。
