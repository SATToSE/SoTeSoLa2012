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
 * Entry point of the 'GenerateJava' generation module with additional post action : Java formatting.
 * @see GenerateJava
 *
 */
public class GenerateJavaExtended extends GenerateJava {

	public GenerateJavaExtended() {
	    super();
	}

	public GenerateJavaExtended(URI modelURI, File targetFolder,
			List<? extends Object> arguments) throws IOException {
    	super(modelURI, targetFolder, arguments);
	}

	public GenerateJavaExtended(EObject model, File targetFolder,
			List<? extends Object> arguments) throws IOException {
    	super(model, targetFolder, arguments);
	}

	@Override
	public void doGenerate(Monitor monitor) throws IOException {
		super.doGenerate(monitor);
		
		// apply default java code formatting to generated files
	    if (monitor != null) {
	    	monitor.setTaskName(Messages.Generate_JavaStructures_0);
	    }
		JavaUtils.formatJavaCode(this.targetFolder);
	}
	
	/**
	 * This can be used to launch the generation from a standalone application.
	 * 
	 * @param args
	 *            Arguments of the generation.
	 */
	public static void main(String[] args) {
    try {
      if (args.length < 2) {
        System.out.println(org.eclipse.gmt.modisco.java.generation.files.Messages.GenerateJava_0);
      } else {
        URI modelURI = URI.createFileURI(args[0]);
        File folder = new File(args[1]);
        List<String> arguments = new ArrayList<String>();
        for (int i = 2; i < args.length; i++) {
          arguments.add(args[i]);
        }
        GenerateJavaExtended generator = new GenerateJavaExtended(modelURI, folder, arguments);
        generator.doGenerate(new BasicMonitor());
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
  }


}
