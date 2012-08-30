/*
 * Copyright (c) 2010 Mia-Software.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Gabriel Barbier (Mia-Software) - initial API and implementation
 */
package org.eclipse.gmt.modisco.java.generation.actions;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.gmt.modisco.infra.common.core.logging.MoDiscoLogger;
import org.eclipse.gmt.modisco.infra.discoverymanager.AbstractDiscovererImpl;
import org.eclipse.gmt.modisco.infra.discoverymanager.DiscoveryParameter;
import org.eclipse.gmt.modisco.infra.discoverymanager.DiscoveryParameterDirectionKind;
import org.eclipse.gmt.modisco.infra.discoverymanager.DiscoveryParameterImpl;
import org.eclipse.gmt.modisco.java.actions.DefaultDiscoverer;
import org.eclipse.gmt.modisco.java.generation.Activator;
import org.eclipse.gmt.modisco.java.generation.files.GenerateJava;

public class GenerateJavaModel extends AbstractDiscovererImpl {

	private final DiscoveryParameter generationTargetFolder;

	public DiscoveryParameter getGenerationTargetFolder() {
		return this.generationTargetFolder;
	}

	public GenerateJavaModel() {
		super();
		this.generationTargetFolder = new DiscoveryParameterImpl(
				"generationTargetFolder", DiscoveryParameterDirectionKind.out, //$NON-NLS-1$
				IContainer.class, false);
		getBasicDiscovererParameters().add(this.generationTargetFolder);
	}

	public boolean isApplicableTo(final Object source) {
		boolean result = false;
		if (source instanceof IFile) {
			IFile iFile = (IFile) source;
			String extension = iFile.getFileExtension();
			result = (extension != null)
					&& (extension.equals(DefaultDiscoverer.JAVA_FILE_EXTENSION));
		}
		return result;
	}

	public void discoverElement(final Object source,
			final Map<DiscoveryParameter, Object> parameters) {
		final IFile iFile = (IFile) source;
		final String sourcePath = iFile.getLocation().toString();
		URI javaModelUri = URI.createFileURI(sourcePath);

		// target generation folder ...
		File folder = iFile.getProject().getLocation().toFile();
		if (parameters.containsKey(getGenerationTargetFolder())) {
			IFolder ifolder = (IFolder) parameters.get(getGenerationTargetFolder());
			folder = ifolder.getLocation().toFile();
		}

		GenerateJava generator;
		try {
			List<?> arguments = new ArrayList<Object>();
			generator = new GenerateJava(javaModelUri, folder,
					arguments);
			generator.doGenerate(new BasicMonitor());
		} catch (IOException e) {
			MoDiscoLogger.logWarning(e, Activator.getDefault());
		}

		// refresh workspace ...
		try {
			iFile.getWorkspace().getRoot().refreshLocal(
					IResource.DEPTH_INFINITE, new NullProgressMonitor());
		} catch (CoreException e) {
			MoDiscoLogger.logWarning(e, Activator.getDefault());
		}
	}

}
