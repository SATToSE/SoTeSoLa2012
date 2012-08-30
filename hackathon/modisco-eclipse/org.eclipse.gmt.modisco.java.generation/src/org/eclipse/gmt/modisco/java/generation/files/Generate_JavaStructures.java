/*******************************************************************************
 * Copyright (c) 2010 Mia-Software.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Fabien Giquel (Mia-Software) - initial API and implementation
 *******************************************************************************/
package org.eclipse.gmt.modisco.java.generation.files;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.Monitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.gmt.modisco.java.generation.Messages;
import org.eclipse.gmt.modisco.java.generation.utils.JavaUtils;

/**
 * 
 * @deprecated use GenerateJavaExtended
 *
 */
@Deprecated
public class Generate_JavaStructures extends GenerateJavaExtended {

	public Generate_JavaStructures() {
	    super();
	}

	public Generate_JavaStructures(URI modelURI, File targetFolder,
			List<? extends Object> arguments) throws IOException {
    	super(modelURI, targetFolder, arguments);
	}

	public Generate_JavaStructures(EObject model, File targetFolder,
			List<? extends Object> arguments) throws IOException {
    	super(model, targetFolder, arguments);
	}

	@Override
	public void doGenerate(Monitor monitor) throws IOException {
		super.doGenerate(monitor);
	}

	/**
	 * This can be used to launch the generation from a standalone application.
	 * 
	 * @param args
	 *            Arguments of the generation.
	 */
	@Deprecated
	public static void main(String[] args) {
		GenerateJavaExtended.main(args);
    }

}
