import net.mcreator.Launcher;
import net.mcreator.blockly.data.BlocklyLoader;
import net.mcreator.element.GeneratableElement;
import net.mcreator.element.ModElementType;
import net.mcreator.element.ModElementTypeLoader;
import net.mcreator.element.parts.MItemBlock;
import net.mcreator.element.types.ArmorTrim;
import net.mcreator.generator.Generator;
import net.mcreator.generator.GeneratorConfiguration;
import net.mcreator.generator.GeneratorFile;
import net.mcreator.generator.GeneratorTemplate;
import net.mcreator.generator.template.TemplateGenerator;
import net.mcreator.plugin.PluginLoader;
import net.mcreator.preferences.PreferencesManager;
import net.mcreator.ui.init.BlocklyJavaScriptsLoader;
import net.mcreator.ui.init.BlocklyToolboxesLoader;
import net.mcreator.ui.init.EntityAnimationsLoader;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.init.UIRES;
import net.mcreator.util.MCreatorVersionNumber;
import net.mcreator.util.TerribleModuleHacks;
import net.mcreator.workspace.Workspace;
import net.mcreator.workspace.elements.ModElement;
import net.mcreator.workspace.elements.VariableTypeLoader;
import net.mcreator.workspace.settings.WorkspaceSettings;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.Set;

/**
 * Offline smoke test for the Fabric 1.21.8 generator plugin.
 *
 * <p>Loads the plugin archive through the real MCreator plugin loader, builds the generator
 * configuration (definitions, imports, mappings), creates a workspace, renders every base template,
 * writes a block / item / procedure and checks the generated files. Gradle is not invoked.</p>
 */
public class SmokeTest {

	private static final List<String> failures = new ArrayList<>();
	private static final List<GeneratableElement> elements = new ArrayList<>();
	private static int baseTemplates;
	private static int elementFiles;

	public static void main(String[] args) throws Exception {
		TerribleModuleHacks.openAllFor(ClassLoader.getSystemClassLoader().getUnnamedModule());
		TerribleModuleHacks.openMCreatorRequirements();
		Properties conf = new Properties();
		conf.load(SmokeTest.class.getResourceAsStream("/mcreator.conf"));
		Launcher.version = new MCreatorVersionNumber(conf);

		PreferencesManager.init();
		PluginLoader.initInstance();
		L10N.initTranslations();
		UIRES.preloadImages();
		net.mcreator.plugin.modapis.ModAPIManager.initAPIs();
		VariableTypeLoader.loadVariableTypes();
		BlocklyJavaScriptsLoader.init();
		BlocklyToolboxesLoader.init();
		BlocklyLoader.init();
		EntityAnimationsLoader.init();
		ModElementTypeLoader.loadModElements();

		boolean pluginLoaded = PluginLoader.INSTANCE.getPlugins().stream()
				.anyMatch(p -> "generator-fabric-1.21.8".equals(p.getID()) && p.isLoaded());
		check(pluginLoaded, "plugin generator-fabric-1.21.8 loaded");
		check(PluginLoader.INSTANCE.getFailedPlugins().isEmpty(), "no failed plugins");

		java.util.Set<String> generatorFiles = PluginLoader.INSTANCE.getResources(java.util.regex.Pattern.compile("generator\\.yaml"));
		for (String generatorFile : generatorFiles) {
			String generatorName = generatorFile.replace("/generator.yaml", "");
			Generator.GENERATOR_CACHE.put(generatorName, new GeneratorConfiguration(generatorName));
		}
		GeneratorConfiguration configuration = Generator.GENERATOR_CACHE.get("fabric-1.21.8");
		check(configuration != null, "generator configuration loaded");
		check(configuration.getBaseTemplates().size() > 10, "base templates declared");

		int definitions = 0;
		for (ModElementType<?> type : ModElementTypeLoader.getAllModElementTypes()) {
			if (configuration.getDefinitionsProvider().getModElementDefinition(type) != null)
				definitions++;
		}
		check(definitions >= 30, "definitions loaded: " + definitions);
		check(configuration.getDefinitionsProvider().getModElementDefinition(ModElementType.ARMORTRIM) != null,
				"armor trim definition present");

		File out = new File(System.getProperty("smoke.out", "build/smoke-workspace"));
		if (out.exists())
			deleteRecursively(out);
		out.mkdirs();
		WorkspaceSettings settings = new WorkspaceSettings("porttest");
		settings.setModName("port-test");
		settings.setVersion("1.0.0");
		settings.setAuthor("MCreator");
		settings.setDescription("Generator smoke test");
		settings.setLicense("Not specified");
		settings.setWebsiteURL("https://mcreator.net");
		settings.setModElementsPackage("net.mcreator.porttest");
		settings.setCurrentGenerator("fabric-1.21.8");
		settings.setRequiredMods(Set.of());
		settings.setDependencies(Set.of());
		settings.setDependants(Set.of());

		Workspace workspace = Workspace.createWorkspace(new File(out, "porttest.mcreator"), settings);
		Generator generator = workspace.getGenerator();
		check(generator != null, "workspace created with the Fabric generator");

		File fixtures = new File(System.getProperty("smoke.fixtures", "workspace/test-min/elements"));
		addElement(workspace, "TestBlock", ModElementType.BLOCK, "test_block", fixtures);
		addElement(workspace, "TestItem", ModElementType.ITEM, "test_item", fixtures);
		addElement(workspace, "TestProcedure", ModElementType.PROCEDURE, "test_procedure", fixtures);
		addArmorTrim(workspace, "TestTrim", "test_trim");

		TemplateGenerator templateGenerator = generator.getTemplateGeneratorFromName("templates");
		for (GeneratorTemplate template : generator.getModBaseGeneratorTemplatesList()) {
			String name = String.valueOf(template.getTemplateDefinition().get("template"));
			try {
				templateGenerator.generateBaseFromTemplate(name, template.getDataModel(),
						(String) template.getTemplateDefinition().get("variables"));
				baseTemplates++;
			} catch (Throwable e) {
				failures.add("base template " + name + ": " + e);
			}
		}
		check(baseTemplates >= 15, "base templates rendered: " + baseTemplates);

		generator.generateBase(false);
		File modFile = new File(workspace.getWorkspaceFolder(), "src/main/java/net/mcreator/porttest/PorttestMod.java");
		check(modFile.isFile(), "mod base class written");
		File mixins = new File(workspace.getWorkspaceFolder(), "src/main/resources/porttest.mixins.json");
		check(mixins.isFile(), "mixin configuration written");
		File trimAtlas = new File(workspace.getWorkspaceFolder(),
				"src/main/resources/assets/minecraft/atlases/armor_trims.json");
		check(trimAtlas.isFile(), "armor trim atlas written");
		if (trimAtlas.isFile()) {
			String atlas = Files.readString(trimAtlas.toPath(), StandardCharsets.UTF_8);
			check(atlas.contains("trims/entity/humanoid/test_trim")
					&& atlas.contains("trims/entity/humanoid_leggings/test_trim")
					&& !atlas.contains("trims/models/armor"), "armor trim atlas uses 1.21.8 texture paths");
		}

		for (GeneratableElement element : elements) {
			try {
				elementFiles += generator.generateElement(element, false).size();
			} catch (Throwable e) {
				failures.add("element " + element.getModElement().getName() + ": " + e);
			}
		}
		check(elementFiles >= 8, "element files generated: " + elementFiles);
		check(new File(workspace.getWorkspaceFolder(),
				"src/main/java/net/mcreator/porttest/block/TestBlockBlock.java").isFile(), "block class written");
		check(new File(workspace.getWorkspaceFolder(),
				"src/main/java/net/mcreator/porttest/item/TestItemItem.java").isFile(), "item class written");
		check(new File(workspace.getWorkspaceFolder(),
				"src/main/java/net/mcreator/porttest/procedures/TestProcedureProcedure.java").isFile(),
				"procedure class written");

		if (!failures.isEmpty()) {
			System.out.println("SMOKE TEST FAILED");
			failures.forEach(f -> System.out.println("  - " + f));
			System.exit(1);
		}
		System.out.println("SMOKE TEST PASSED");
		System.exit(0);
	}

	private static void addArmorTrim(Workspace workspace, String name, String registryName) {
		try {
			ModElement element = new ModElement(workspace, name, ModElementType.ARMORTRIM);
			element.setRegistryName(registryName);
			workspace.addModElement(element);
			ArmorTrim trim = new ArmorTrim(element);
			trim.name = "Test Trim";
			trim.item = new MItemBlock(workspace, "Items.IRON_INGOT");
			trim.armorTextureFile = "test";
			// The smoke test does not ship armor textures; create placeholders so finalizeModElementGeneration
			// can exercise the texture copy step without logging errors.
			File armorDir = new File(workspace.getWorkspaceFolder(),
					"src/main/resources/assets/porttest/textures/models/armor");
			armorDir.mkdirs();
			Files.write(new File(armorDir, "test_layer_1.png").toPath(), new byte[] { (byte) 0x89, 'P', 'N', 'G' });
			Files.write(new File(armorDir, "test_layer_2.png").toPath(), new byte[] { (byte) 0x89, 'P', 'N', 'G' });
			workspace.getModElementManager().storeModElement(trim);
			elements.add(trim);
		} catch (Throwable e) {
			failures.add("loading " + name + ": " + e);
		}
	}

	private static void addElement(Workspace workspace, String name, ModElementType<?> type, String registryName,
			File fixtures) {
		try {
			ModElement element = new ModElement(workspace, name, type);
			element.setRegistryName(registryName);
			workspace.addModElement(element);
			String json = Files.readString(new File(fixtures, name + ".mod.json").toPath(), StandardCharsets.UTF_8);
			GeneratableElement ge = workspace.getModElementManager()
					.fromJSONtoGeneratableElement(json, element, message -> { });
			workspace.getModElementManager().storeModElement(ge);
			elements.add(ge);
		} catch (Throwable e) {
			failures.add("loading " + name + ": " + e);
		}
	}

	private static void check(boolean condition, String message) {
		System.out.println((condition ? "  ok   " : "  FAIL ") + message);
		if (!condition)
			failures.add(message);
	}

	private static void deleteRecursively(File file) {
		File[] children = file.listFiles();
		if (children != null)
			for (File child : children)
				deleteRecursively(child);
		file.delete();
	}
}


