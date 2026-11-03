import freemarker.template.Configuration;
import freemarker.template.Template;
import org.snakeyaml.engine.v2.api.Load;
import org.snakeyaml.engine.v2.api.LoadSettings;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

/**
 * Static validation for the Fabric 1.21.8 generator plugin.
 *
 * <p>Checks that every shipped YAML file parses, that every Freemarker template parses, that all
 * templates referenced from YAML exist in the generator search path, and that all Freemarker
 * includes resolve. It is intentionally independent of a running MCreator instance so it can be
 * executed in CI or in a sandboxed environment.</p>
 *
 * <p>Usage: {@code java GeneratorValidator <path-to-src/main/resources>}</p>
 */
public class GeneratorValidator {

	private static final String[] GENERATORS = { "fabric-1.21.8", "fabric-1.21.8-base/datapack",
			"fabric-1.21.8-base/neoforge" };
	/** Folders MCreator uses as Freemarker template roots (the editor type roots and the shared utils root). */
	private static final String[] TEMPLATE_ROOTS = { "templates", "procedures", "triggers", "aitasks", "cmdargs",
			"jsontriggers", "features", "enchantmenteffects", "utils" };

	private static Path resources;
	private static final List<String> errors = new ArrayList<>();
	private static int yamlCount;
	private static int templateCount;
	private static int referenceCount;
	private static int includeCount;
	private static final Set<String> generators = new LinkedHashSet<>(Arrays.asList(GENERATORS));

	public static void main(String[] args) throws Exception {
		resources = Paths.get(args.length > 0 ? args[0] : "src/main/resources").toAbsolutePath().normalize();
		if (!Files.isDirectory(resources)) {
			System.err.println("Resources directory not found: " + resources);
			System.exit(2);
		}

		LoadSettings settings = LoadSettings.builder().setLabel("generator").build();
		Load yaml = new Load(settings);

		for (String generator : GENERATORS) {
			Path root = resources.resolve(generator);
			if (!Files.isDirectory(root)) {
				errors.add("Missing generator directory: " + generator);
				continue;
			}
			try (Stream<Path> files = Files.walk(root)) {
				for (Path file : files.filter(Files::isRegularFile).toList()) {
					String name = file.getFileName().toString();
					if (name.endsWith(".yaml")) {
						yamlCount++;
						try (Reader reader = Files.newBufferedReader(file, StandardCharsets.UTF_8)) {
							Object loaded = yaml.loadFromReader(reader);
							if (loaded != null && !(loaded instanceof Map)) {
								errors.add("YAML root is not a map: " + rel(file));
							}
							if (loaded instanceof Map<?, ?> map) {
								checkTemplateReferences(rel(file), map);
							}
						} catch (Exception e) {
							errors.add("YAML parse error in " + rel(file) + ": " + e.getMessage());
						}
					} else if (name.endsWith(".ftl")) {
						templateCount++;
						checkTemplate(file);
					}
				}
			}
		}

		System.out.printf("YAML files: %d, Freemarker templates: %d, template references: %d, includes: %d%n", yamlCount,
				templateCount, referenceCount, includeCount);
		if (errors.isEmpty()) {
			System.out.println("Validation passed.");
		} else {
			System.out.println("Validation failed with " + errors.size() + " error(s):");
			errors.forEach(e -> System.out.println("  - " + e));
			System.exit(1);
		}
	}

	private static void checkTemplate(Path file) {
		String name = rel(file);
		try {
			String content = Files.readString(file, StandardCharsets.UTF_8);
			Configuration cfg = new Configuration(Configuration.VERSION_2_3_35);
			cfg.setTemplateLoader(new freemarker.cache.StringTemplateLoader());
			try {
				new Template(name, new StringReader(content), cfg);
			} catch (Exception e) {
				errors.add("Freemarker parse error in " + name + ": " + e.getMessage());
			}

			Matcher inc = Pattern.compile("#include\\s+\"([^\"]+)\"").matcher(content);
			while (inc.find()) {
				includeCount++;
				checkInclude(file, inc.group(1));
			}
			Matcher add = Pattern.compile("<@addTemplate\\s+file=\"([^\"]+)\"").matcher(content);
			while (add.find()) {
				includeCount++;
				checkInclude(file, add.group(1));
			}
		} catch (IOException e) {
			errors.add("Read error in " + name + ": " + e.getMessage());
		}
	}

	private static void checkInclude(Path from, String target) {
		if (target.contains("${"))
			return; // dynamic includes are resolved at render time
		String current = rel(from);
		String generator = generatorPath(current);
		String inGenerator = current.equals(generator) ? "" : current.substring(generator.length() + 1);
		String root = inGenerator.contains("/") ? inGenerator.substring(0, inGenerator.indexOf('/')) : "";
		String currentInRoot = root.isEmpty() ? inGenerator : inGenerator.substring(root.length() + 1);

		// Includes in MCreator are resolved against the editor root of the current template and the shared utils root
		String normalized = Paths.get(currentInRoot).getParent() == null ?
				target :
				Paths.get(currentInRoot).getParent().resolve(target).normalize().toString().replace('\\', '/');
		List<String> candidates = new ArrayList<>();
		candidates.add(normalized);
		if (!normalized.equals(target))
			candidates.add(target);
		for (String candidate : candidates) {
			if (candidate.startsWith("../"))
				continue;
			for (String candidateRoot : new String[] { root, "utils" }) {
				if (candidateRoot.isEmpty())
					continue;
				for (String gen : generators) {
					if (Files.isRegularFile(resources.resolve(gen).resolve(candidateRoot).resolve(candidate)))
						return;
				}
			}
		}

		errors.add("Missing include/addTemplate target '" + target + "' referenced from " + current);
	}

	private static void checkTemplateReferences(String yamlFile, Object node) {
		if (node instanceof Map<?, ?> map) {
			for (Map.Entry<?, ?> entry : map.entrySet()) {
				if ("template".equals(String.valueOf(entry.getKey())) && entry.getValue() instanceof String template) {
					referenceCount++;
					if (!templateExists(template)) {
						errors.add("Missing template '" + template + "' referenced from " + yamlFile);
					}
				}
				checkTemplateReferences(yamlFile, entry.getValue());
			}
		} else if (node instanceof List<?> list) {
			for (Object item : list)
				checkTemplateReferences(yamlFile, item);
		}
	}

	private static boolean templateExists(String template) {
		for (String generator : generators) {
			for (String root : new String[] { "templates", "utils" }) {
				if (Files.isRegularFile(resources.resolve(generator).resolve(root).resolve(template).normalize()))
					return true;
			}
		}
		return false;
	}

	private static String generatorPath(String rel) {
		for (String generator : GENERATORS) {
			if (rel.equals(generator) || rel.startsWith(generator + "/"))
				return generator;
		}
		return rel.contains("/") ? rel.substring(0, rel.indexOf('/')) : rel;
	}

	private static String rel(Path file) {
		return resources.relativize(file).toString().replace('\\', '/');
	}
}
