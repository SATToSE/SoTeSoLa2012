/*******************************************************************************
 * Copyright (c) 2009 Mia-Software.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Fabien Giquel (Mia-Software) - initial API and implementation
 *******************************************************************************/
package org.eclipse.gmt.modisco.java.generation.utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Map;

import org.eclipse.core.runtime.Platform;
import org.eclipse.gmt.modisco.infra.common.core.internal.utils.FolderUtils;
import org.eclipse.gmt.modisco.infra.common.core.logging.MoDiscoLogger;
import org.eclipse.gmt.modisco.java.generation.Activator;
import org.eclipse.gmt.modisco.java.generation.Messages;

/**
 * Util Class for formatting Java code.
 * 
 * @author fgiquel
 * 
 */
public final class JavaUtils {

	private static org.eclipse.jdt.core.formatter.CodeFormatter sourceFormatter = null;

	private JavaUtils() {
	}

	/**
	 * Formats java source for a hierarchy.
	 * 
	 * @param directory
	 */
	public static void formatJavaCode(final File directory) {
		File[] files = directory.listFiles();
		for (File file : files) {
			if (file.isDirectory()) {
				formatJavaCode(file);
			} else if (file.getName().endsWith(".java")) { //$NON-NLS-1$
				String source = FolderUtils.getFileContent(file);
				String target = formatJavaCode(source);

				try {
					FileWriter fw = new FileWriter(file, false);
					fw.write(target);
					fw.close();
				} catch (IOException e) {
					if (Platform.isRunning()) {
						MoDiscoLogger.logWarning(e, Messages.JavaUtils_1
								+ file.getAbsoluteFile(), Activator
								.getDefault());
					} else {
						System.err.println(Messages.JavaUtils_2
								+ file.getAbsoluteFile());
					}
				}
			}
		}
	}

	private static String formatJavaCode(final String source) {
		org.eclipse.jdt.core.formatter.CodeFormatter formatter = getDefaultFormatter();

		// format the source code, at this time always use LF as line separator
		org.eclipse.jface.text.IDocument document = new org.eclipse.jface.text.Document(
				source);
		org.eclipse.text.edits.TextEdit textEdit = formatter
				.format(
						org.eclipse.jdt.core.formatter.CodeFormatter.K_COMPILATION_UNIT,
						source, 0, source.length(), 0, "\n"); //$NON-NLS-1$

		if (textEdit != null) {
			try {
				textEdit.apply(document);
				return document.get();
			} catch (Exception e) {
				if (Platform.isRunning()) {
					MoDiscoLogger.logWarning(e, Messages.JavaUtils_4, Activator
							.getDefault());
				} else {
					System.err.println(Messages.JavaUtils_5 + e.getMessage());
				}
			}
		} else {
			MoDiscoLogger.logWarning(Messages.JavaUtils_4, Activator
					.getDefault());
		}
		return source;
	}

	@SuppressWarnings("unchecked")
	private static org.eclipse.jdt.core.formatter.CodeFormatter getDefaultFormatter() {
		if (JavaUtils.sourceFormatter == null) {
			// Take default Eclipse formatting options
			Map<Object, Object> options = org.eclipse.jdt.core.formatter.DefaultCodeFormatterConstants
					.getEclipseDefaultSettings();

			// Initialize the compiler settings
			options.put(org.eclipse.jdt.core.JavaCore.COMPILER_COMPLIANCE,
					org.eclipse.jdt.core.JavaCore.VERSION_1_5);
			options
					.put(
							org.eclipse.jdt.core.JavaCore.COMPILER_CODEGEN_TARGET_PLATFORM,
							org.eclipse.jdt.core.JavaCore.VERSION_1_5);
			options.put(org.eclipse.jdt.core.JavaCore.COMPILER_SOURCE,
					org.eclipse.jdt.core.JavaCore.VERSION_1_5);

			// Instantiate the default code formatter with the given options
			JavaUtils.sourceFormatter = org.eclipse.jdt.core.ToolFactory
					.createCodeFormatter(options);
		}
		return JavaUtils.sourceFormatter;
	}
}
