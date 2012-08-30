Contributors:
--------------
Hugo Bruneliere - INRIA and EMN, France
Jean-Sébastien Sottet CRP Henri Tudor, Luxembourg

USEFUL INFORMATION TO USE AND RUN THIS MODISCO PROJECT FOR THE SoTeSoLa HACKATHON
----------------------------------------------------------------------------------------------

This contribution is based on Eclipse (Juno version , Modelling Tool bundle) available at : http://www.eclipse.org/downloads/packages/eclipse-modeling-tools/junor
MoDisco, ATL, Acceleo & Xtext have to be previously installed (from the Eclipse Modeling Tools bundle).
This can be done via a dedicated wizard named "Install Modeling Components", as available from the workbench icon bar,
or directly using the official update site of your Eclipse install release.

The plugins also have to be installed by copying them (from the "RequiredPlugin" folder
of the SoTeSoLa-Hackathon project) to the "dropins" folder of your Eclipse install. 
The list of plugins to be installed is : 
- org.eclipse.m2m.atl.projectors.xml 
- lu.tudor.genius.json
- lu.tudor.modelling.json
- org.eclipse.modisco.json.discoverer

Note that the org.eclipse.gmt.modisco.java.generation and org.eclipse.gmt.modisco.tool.metricsvisualizationbuilder 
projects (already provided) can also be checked out from the MoDisco source code repository.
	
The project provides three workflows implementing two different model driven reverse engineering scenarios:
    1) Simple metrics computation and rendering
         - Java model discovery from the "javaStatic" project
         - Metrics computation via an ATL model-to-model transformation from the discovered Java model
         - Visualizations generation (in HTML) from the produced Metrics model
    
    2) Java code refactoring
         - Java model discovery from the "javaStatic" project
         - Java refactoring via an ATL model-to-model transformation on the discovered Java model
         - Java code regeneration (into the "javaStatic_refined" project) from the refined Java model

	3) Json data extraction
		- Json model discovery from "Wiki101FullJson.json" (json version of the wiki)
		- Json transformation via ATL model-to-model into UML structure: Class and Instances models (conform to the UML specification of Eclipse uri=http://www.eclipse.org.uml2/3.0.0/uml)

These already prepared workflows can be directly run as standard Eclipse launch configurations. These workflows are:
- Hackathon-ComputeClassStatistics-HTMLVisu.launch for the simple metric computation and rendering
-Hackathon-CreateAbstractClass-Refactoring.launch for the
refactoring part
- Hackathon-CreateUMLStructureFromJson.launch for the Json discovery
They can also be modified and/or augmented with upgraded transformations, new generations, etc.
