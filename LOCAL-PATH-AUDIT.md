# 本地路径硬编码审计报告

- 审计对象：`Fabric_Generator_1.21.8` 源码工作区
- 审计依据：`user_docs/standards-generator.md`（2026-11 更新版）
- 审计日期：2026-11-14
- 审计范围：`plugin/src`、`plugin/tools`、`plugin` 根配置与文档、工作区根文档
- 排除项：`.git/`、`build/`、`.gradle/`、`caches/`、`Reference resources/`、生成物 `workspace/`
- 结论（修复前）：**存在 3 处本地绝对路径（模板会阻断分发，插件 wrapper 会阻断换机构建，另一处为死配置），另有 3 处工具脚本默认/示例路径、1 处插件外 fixture 依赖、2 类文档示例和 1 项缓存重定向缺口。**
- 修复状态：**已修复，版本 `2026.3-1.0.2.1-beta`**。本报告保留修复前证据用于追溯；修复记录见下节。

> 说明：检测到的真实盘符和用户目录已在本文中用 `<local-workspace>`、`<local-drive>`、`<user-home>` 脱敏；文件和行号均为修复前源码中的实际位置。

## 0. 修复记录（2026.3-1.0.2.1-beta）

- 四个 `gradle-wrapper.properties` 的 `distributionUrl` 全部改为公共地址 `https\://services.gradle.org/distributions/gradle-9.8.0-bin.zip`；不再引用 `Reference resources`。
- 删除 `plugin/gradle.properties` 中未被消费的 `gradle_distribution_url`。
- 三个 workspacebase 的 `gradlew` / `gradlew.bat` 均把 `GRADLE_USER_HOME` 重定向到生成工程内的 `caches/gradle`（相对 `APP_HOME`，无绝对路径）。
- `validate.ps1`、`smoke-test.ps1` 的 `MCreatorPath` 改为必填参数或 `MCREATOR_PATH` 环境变量，不再内置本机默认值。
- 最小 fixture 移入 `plugin/tools/fixtures/test-min/elements`，`smoke-test.ps1` 不再依赖插件目录外的 `workspace/test-min`。
- README、MIGRATION-REPORT、`开发与交付规范.md` 中的盘符示例和本地 URL 说明已替换为占位符/公共策略；旧规范已标记 `OBSOLETE`。
- 三个 base 层与主 workspacebase 的 Gradle 版本统一为 `9.8.0`。

---

## 1. 执行摘要

| 级别 | 数量 | 说明 |
|---|---:|---|
| P0（阻断分发） | 1 | Fabric 工作区模板的 Gradle wrapper 指向本机 `file:///` 绝对路径，所有生成工程都会继承 |
| P0（阻断构建） | 2 | 插件自身 wrapper 与 `gradle.properties` 指向同一本机绝对路径 |
| P1（工具不可移植） | 3 | 校验/冒烟脚本把 MCreator 安装路径写死为本机路径（修复前） |
| P1（规范缺口） | 1 | 三个 workspacebase 均未把 Gradle/Loom 缓存重定向到 `<workspace>/caches` |
| P2（文档/一致性） | 4 | README、MIGRATION-REPORT 的示例/说明；旧规范残留；base wrapper 版本不一致；冒烟测试依赖插件外 fixture |

---

## 2. 源码中的绝对路径

### 2.1 P0：Fabric workspacebase 的 Gradle wrapper

**文件**：`plugin/src/main/resources/fabric-1.21.8/workspacebase/gradle/wrapper/gradle-wrapper.properties:3`

**检测值（脱敏）**：

```properties
distributionUrl=file\:///<local-workspace>/Reference%20resources/gradle-9.8.0-bin.zip
```

**影响**：

- 这是 `workspacebase`，会被复制到每一个新生成的 Fabric 1.21.8 工程；
- 用户机器上没有 `B:` 盘或没有该 `Reference resources` 目录时，`gradlew` 直接失败；
- ZIP 中携带开发者本机绝对路径，违反“生成器模板不得写入本地路径”；
- 当前 `workspace/test-min`、`test-p01`、`test-croparium`、`test-everrose`、`test-betterMelon` 的 wrapper 都已出现同一路径，证明该问题会向下游传播。

**结论**：**必须在发布前修复，且不能只修测试工作区，必须修模板。**

### 2.2 P0：插件工程自身的 Gradle wrapper

**文件**：`plugin/gradle/wrapper/gradle-wrapper.properties:3`

**检测值（脱敏）**：

```properties
distributionUrl=file\:///<local-workspace>/Reference%20resources/gradle-9.8.0-bin.zip
```

**影响**：

- 插件工程不是自包含的；换机器/换目录后 `plugin/gradlew` 无法解析发行包；
- 与“默认公共 URL、仅网络失败时回退本地且文件存在”的新规范直接冲突。

### 2.3 P0：插件 `gradle.properties` 的本地 URL

**文件**：`plugin/gradle.properties:9`

**检测值（脱敏）**：

```properties
gradle_distribution_url=file\:///<local-workspace>/Reference%20resources/gradle-9.8.0-bin.zip
```

**补充**：

- 当前源码中没有发现 `gradle_distribution_url` 的消费方（`plugin` 内仅此一处），属于**死配置**；
- 但它是明确的绝对路径，且注释声称“故意使用本地文件 URL”，与新规范相反；
- 若后续脚本读取该属性，会把本地路径重新带入构建。

---

## 3. 工具脚本默认路径

### 3.1 `validate.ps1`

**文件**：`plugin/tools/validate.ps1:4`

```powershell
[string]$MCreatorPath = '<local-workspace>\MCreatorEAP2026344621'
```

**影响**：

- 默认值写死盘符与目录；
- 虽然可用 `-MCreatorPath` 覆盖，但“默认即可运行”的脚本在新机器上失败；
- 与“脚本不得硬编码盘符/用户目录/固定绝对路径”冲突。

### 3.2 `smoke-test.ps1`

**文件**：`plugin/tools/smoke-test.ps1:6`

```powershell
[string]$MCreatorPath = '<local-workspace>\MCreatorEAP2026344621'
```

**影响**：同上；且 `smoke-test.ps1:67` 还依赖插件目录之外的 `workspace/test-min/elements`（见 4.3）。

### 3.3 `verify-workspace.ps1` 使用示例

**文件**：`plugin/tools/verify-workspace.ps1:4`

```powershell
# Usage: pwsh plugin/tools/verify-workspace.ps1 -Workspace "<local-drive>:\path\to\workspace" [-Tasks build]
```

**影响**：

- 仅是注释示例，但属于“文档示例硬编码盘符”；
- 实际参数 `$Workspace` 是调用方传入的，脚本本身没有该默认值。

---

## 4. 工作区模板与缓存重定向

### 4.1 P1：workspacebase 未设置 Gradle 缓存目录

**文件**：

- `plugin/src/main/resources/fabric-1.21.8/workspacebase/gradle.properties`
- `plugin/src/main/resources/fabric-1.21.8-base/datapack/workspacebase/gradle.properties`
- `plugin/src/main/resources/fabric-1.21.8-base/neoforge/workspacebase/gradle.properties`

**现状**：

- 三个模板只设置 `org.gradle.jvmargs`、`org.gradle.parallel` 等；
- 未发现 `GRADLE_USER_HOME`、`-g`、`org.gradle.user.home` 或等价重定向；
- 直接运行生成工程的 `gradlew` 会使用默认 Gradle 用户目录（`<user-home>/.gradle` 或 MCreator 配置的位置），不在 `<workspace>/caches` 下。

**运行时证据**：

- `workspace/test-min/.mcreator/generatorGradleCache:1` 使用 MCreator 安装目录的 JDK；
- `workspace/test-min/run/logs/debug.log:106` 等行显示 Loom/Gradle 类路径来自 `<user-home>\.mcreator\gradle`，而不是 `workspace/test-min/caches`。

**结论**：这不是“硬编码为某个盘符”的路径，但**违反了新规范的缓存强制重定向要求**；生成工程必须在 wrapper 脚本或 MCreator 生成流程中显式设置 `GRADLE_USER_HOME`/`-g` 到 `<workspace>/caches/gradle`。

### 4.2 P2：base workspacebase 的 Gradle 版本不一致

**文件**：

- `plugin/src/main/resources/fabric-1.21.8-base/datapack/workspacebase/gradle/wrapper/gradle-wrapper.properties:3`
- `plugin/src/main/resources/fabric-1.21.8-base/neoforge/workspacebase/gradle/wrapper/gradle-wrapper.properties:3`

**现状（修复前）**：两者使用公共 URL，但版本为 `gradle-9.8.2-bin.zip`；Fabric 主 workspacebase 与文档使用 `9.8.0`。它们不是本地路径违规，但会造成：

- 同一插件内 Gradle 版本不一致；
- 与“公共 URL 的 `{gradle_version}` 单一来源”不一致；
- base 层若被用于生成，可能引入与主工作区不同的 Gradle 行为。

**修复后**：三个 workspacebase 与插件自身 wrapper 均统一为 `gradle-9.8.0-bin.zip`，版本单一来源。

### 4.3 P2：冒烟测试依赖插件目录外的 fixture

**文件**：`plugin/tools/smoke-test.ps1:67`

```powershell
"-Dsmoke.fixtures=$repoRoot\workspace\test-min\elements"
```

**影响**：

- 这是相对工作区根解析的路径，不是绝对盘符，但 `plugin/` 单独复制后该目录不存在；
- 与“插件目录自包含，只允许依赖 `reference_resources` 本地 Gradle 包”不一致；
- 建议把最小 fixture 移入 `plugin/tools/fixtures`，或改为可选参数并在缺失时跳过并给出明确提示。

---

## 5. 文档中的本地路径

### 5.1 `plugin/README.md`

**文件**：`plugin/README.md:99`

```powershell
pwsh .\plugin\tools\verify-workspace.ps1 -Workspace "<local-drive>:\path\to\workspace" -Tasks build
```

**问题**：示例硬编码盘符；应改为 `<workspace>` 或 `$env:WORKSPACE` 等占位符。

同一文件的 `README.md:110` 使用 `$env:USERPROFILE`，属于动态环境变量，不是固定绝对路径；可以保留，但建议注明“按实际插件目录调整”。

### 5.2 `plugin/MIGRATION-REPORT.md`

**命中行**：

- `MIGRATION-REPORT.md:14`：表格写作 “local `file:///` distribution”；
- `MIGRATION-REPORT.md:204`：正文直接给出 `file:///<local-workspace>/...`；
- `MIGRATION-REPORT.md:331`：示例参数 `<local-drive>:\path\to\workspace`；
- `MIGRATION-REPORT.md:367`：Known Limitations 声称“absolute local path ... as required by the delivery rules”。

**问题**：

- 与新版规范冲突，属于**过时说明**；
- 会误导后续维护者继续使用本地 URL；
- 应改为公共 URL 策略，并说明本地回退只在“网络失败且压缩包存在”时由脚本动态生成。

### 5.3 旧规范文档残留

**文件**：`开发与交付规范.md:23`

**检测值（脱敏）**：

```properties
distributionUrl=file\:///<local-workspace>/Reference%20resources/gradle-9.8.0-bin.zip
```

**问题**：

- 这是旧规范，已被 `user_docs/standards-generator.md` 取代；
- 但文件仍在工作区根目录，且明确要求本地 URL；
- 建议删除、改名并标注 `OBSOLETE`，或至少在新规范中明确“本文件不可作为实施依据”，避免后续误用。

---

## 6. 未发现问题的区域

以下区域已检查，未发现本地绝对路径（`file:///`、盘符路径、`/home/`、`/Users/` 等）：

- `plugin/plugin.json`
- `plugin/build.gradle`
- `plugin/settings.gradle`
- `plugin/src/main/resources/fabric-1.21.8/generator.yaml`
- `plugin/src/main/resources/fabric-1.21.8/templates/**`
- `plugin/src/main/resources/fabric-1.21.8/definitions/**`（YAML 定义）
- `plugin/src/main/resources/fabric-1.21.8/mappings/**`
- `plugin/src/main/resources/fabric-1.21.8-base/**` 的模板、定义、映射（但 base workspacebase 的 wrapper 版本问题见 4.2）
- `plugin/tools/build-plugin.ps1`、`GeneratorValidator.java`、`SmokeTest.java`
- `plugin/src/main/resources/fabric-1.21.8/workspacebase/build.gradle`、`settings.gradle`
- `plugin/src/main/resources/fabric-1.21.8/workspacebase/gradlew` / `gradlew.bat`（标准 Gradle 启动脚本，无绝对路径）

说明：`distributionBase=GRADLE_USER_HOME` 是 Gradle 的符号变量，不是本地绝对路径；问题在于默认解析到了用户目录，而不是 `caches/`。

---

## 7. 修复建议（按优先级）

### P0（发布前必须完成）

1. **修 Fabric workspacebase**
   - 将 `distributionUrl` 改为公共地址：
     `https\://services.gradle.org/distributions/gradle-9.8.0-bin.zip`
   - 不把 `Reference resources` 或任何盘符写入模板。
2. **修插件自身 wrapper**
   - `plugin/gradle/wrapper/gradle-wrapper.properties` 同样改为公共地址。
3. **处理 `plugin/gradle.properties`**
   - 删除 `gradle_distribution_url` 死配置，或改为由构建脚本从工作区根动态解析并仅在网络失败时使用；
   - 移除“故意本地文件 URL”的注释。

### P1（下一轮修复）

4. **工具脚本默认路径**
   - `validate.ps1` / `smoke-test.ps1` 的 `MCreatorPath` 改为必填参数，或按以下顺序解析：
     `-MCreatorPath` → `$env:MCREATOR_HOME` → `<workspace>/apps/<MCreator 目录>` → 明确报错；
   - 不在参数默认值中写盘符。
5. **缓存重定向**
   - 生成工程的 `gradlew`/`gradlew.bat` 或生成器调用层显式设置 `GRADLE_USER_HOME` 到 `<project>/caches/gradle`；
   - 同步覆盖 Loom/MCreator 缓存，避免 `<user-home>/.mcreator/gradle`；
   - 用相对脚本目录解析项目根，禁止写死绝对路径。
6. **Gradle 本地回退**
   - 默认公共 URL；
   - 仅网络失败且 `reference_resources/gradle-9.8.0-bin.zip` 存在时，由脚本动态拼接本地 URL；
   - 文件不存在时保留公共 URL 并输出清晰错误；
   - 不把回退 URL 静态写入任何模板。

### P2（文档与一致性）

7. **文档**
   - `README.md:99`、`MIGRATION-REPORT.md:331` 改用 `<workspace>` 占位符；
   - `MIGRATION-REPORT.md:204/367` 删除绝对路径与“本地路径是规定要求”的过期说明；
   - 旧 `开发与交付规范.md` 标记为废弃或移出。
8. **base wrapper 版本**
   - 将 datapack/neoforge workspacebase 的 9.8.2 统一为 9.8.0，或明确说明它们不使用；
   - Gradle 版本保持单一来源。
9. **冒烟测试 fixture**
   - 移入 `plugin/tools/fixtures`，或改为可选参数；
   - 缺失时跳过并给出提示，不阻断其他检查。

---

## 8. 修复后的验收检查

```powershell
# 1. 源码中不应再出现本地绝对路径（排除历史/生成目录）
rg -n --glob '!**/.git/**' --glob '!**/build/**' --glob '!**/.gradle/**' `
  'file\\:///|(^|[^A-Za-z])[A-Za-z]:[\\/]' plugin

# 2. 打包后检查 workspacebase wrapper
#    应只看到 https://services.gradle.org/...，不得出现 file:/// 或盘符

# 3. 在另一个目录生成测试工作区，执行
.\gradlew --version
#    确认 distributionUrl 使用公共地址或动态回退

# 4. 检查缓存位置
Get-ChildItem .\caches
#    确认 Gradle/Loom 缓存位于 <workspace>/caches，而非用户目录
```

## 9. 修复后验证（2026-11-14）

- 版本：`2026.3-1.0.2.1-beta`。
- `validate.ps1`：172 个 YAML、1754 个 Freemarker 模板、653 个模板引用、889 个 include，全部通过。
- `smoke-test.ps1`（隔离加载打包 ZIP）：插件加载成功、无失败插件、37 个 definition、44 个 base template、35 个 element 文件，`SMOKE TEST PASSED`。
- 打包 ZIP 扫描：`generator.yaml` 恰好 1 个；`file:///` 与盘符路径匹配 0 处；三个 `gradle-wrapper.properties` 均为公共 9.8.0 地址；三组 `gradlew` / `gradlew.bat` 均包含 `GRADLE_USER_HOME`。
- `workspace/test-min`、`test-p01`、`test-croparium`、`test-everrose`、`test-betterMelon` 的 wrapper 已刷新为公共地址与工程内缓存。
- 源码/文档全量扫描后，除本报告为追溯而保留的脱敏历史描述外，未再发现本地绝对路径。

**本轮只做审计，未修改源码。** 上述 P0 项建议在下次构建/发布前处理。
