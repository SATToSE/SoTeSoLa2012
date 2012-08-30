---------------------------------------------------------------			
If you have any questions and/or comments about this tool, 
please use the MoDisco newsgroup:

	news://news.eclipse.org/eclipse.modeling.gmt.modisco

---------------------------------------------------------------	

---------------
Prerequisites:
---------------
1) Install Eclipse with EMF + the ATL and AM3 plugins:

	--> To install ATL, follow the instructions of the "installation of ADT from source" Eclipse Wiki page 
		which is available from http://wiki.eclipse.org/index.php/ATL/How_Install_ATL_From_CVS/
	
	--> To install AM3, simply follow the same process (except that the repository path is "/cvsroot/technology"). 
		You just have to select the "org.eclipse.gmt/AM3" folder and to checkout the following plugins: 
			* org.eclipse.am3.core
    		* org.eclipse.am3.tools.tge
    		* org.eclipse.am3.ui
    		* org.eclipse.gmt.am3.dsls.km3
    		* org.eclipse.gmt.am3.tools.ant
    		
2) Import the "org.eclipse.gmt.modisco.tool.metricsvisualizationbuilder" ATL project into your development workspace:

	--> Right-click anywhere on the "Navigator" view and choose "Import...", the "Import" 
		wizard is now opened.
	
	--> Select "General/Existing Projects into Workspace" and click on "Next" button.
	
	--> Click on "Select archive file" and "Browse..." to open the 
		"MetricsVisualizationBuilder_MoDisco-Toolbox-incubation.zip" archive file.
		
	--> Check that the "org.eclipse.gmt.modisco.tool.metricsvisualizationbuilder" project is selected and
		click on the "Finish" button.
		
	--> The "org.eclipse.gmt.modisco.tool.metricsvisualizationbuilder" project is now opened into your
		development workspace. 
	

-----------------------------------------
This project contains different folders:
-----------------------------------------
						
	--> "Metamodels":		The metamodels, used within this tool, expressed in two different formats 
							(the KM3 language and the Ecore XMI format).
							
	--> "Sample":			A sample "build.xml" file for launching (from another project) the building
							of the visualizations. A sample "Bug_GMT-Metrics.ecore" Metrics model for 
							testing the tool.
							
	--> "Transformations:	The ATL transformations developped in order to implement the different steps 
							of the visualizations building.
							The "Table2XXX" sub-folder contains the transformations used to produce models 
							related to different visualization's formats. Its "Extractor" sub-folder
							contains the transformations used to build software readable files from these 
							models.

The "build-XXX.xml" ANT scripts, which allow executing the different steps of the process, are stored in the 
root of the project. 
Note that the values of the properties must be set for each of the scripts before launching.
