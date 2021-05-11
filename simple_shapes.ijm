//Simple shape measurements for thresholded and scaled binary images of single or multiple clasts on a background
//The macro is designed to be used after thresholding images with the 'Simple threshold' macro.
//The macro will sequentially open binary image files in subdirectories within an 'output' directory'.
//Shape results .csv files are saved in the input file folder by default
//Requires Shape Filter plugin for ImageJ (Help > Update... > Update sites > Biomedgroup)


//Default settings
//Default size minimum of 100 pixels (Lines 34-39) allow the user to define in a dialog box - deactivate (//) line 40 if using
//Silhouettes are measured by default. To change to image with holes, reactivate lines 48-52

	setOption("BlackBackground", true);
	parent=getDirectory("Select 'output' directory");
	list=getFileList(parent);

	
	run("Clear Results"); //reset results table, close open images, clear log
	if (nImages>0) 
		close("*");
	print("\\Clear");

	for (i = 0; i < list.length; i++) {
		dirName = list[i];
		print(dirName);
		dir=parent+dirName;
		
		thresholdimage=dir+"threshold.tif";
		print(thresholdimage);	
		if (File.exists(thresholdimage))
			open(thresholdimage);
		else
			continue
		original=getImageID();
			
		//Option to define minimum particle area (pixels)
		//***********************************************
		//Dialog.create("Particle measurement options");
		//Dialog.addNumber("Minimum particle area to be measured (in pixels)", 100);
		//Dialog.show();
		//minParea = Dialog.getNumber();
		minParea=100;
		//setBatchMode(true);
		run("Clear Results");
		run("Select None");
		run("Analyze Particles...", "size=minParea-Infinity pixel show=Masks");
		masks=getTitle();
		//Option to revert to image with holes
		//************************************************
		//imageCalculator("AND create", original, masks);
		//sieved=getTitle();
		//selectImage(original);
		//close();
		//selectWindow(sieved);
	
		run("Make Binary");
		run("Invert");
		run("Clear Results"); 
		run("Shape Filter", "area=0-Infinity area_convex_hull=0-Infinity perimeter=0-Infinity perimeter_convex_hull=0-Infinity feret_diameter=0-Infinity min._feret_diameter=0-Infinity max._inscr._circle_diameter=0-Infinity area_eq._circle_diameter=0-Infinity long_side_min._bounding_rect.=0-Infinity short_side_min._bounding_rect.=0-Infinity aspect_ratio=1-Infinity area_to_perimeter_ratio=0-Infinity circularity=0-Infinity elongation=0-1 convexity=0-1 solidity=0-1 num._of_holes=0-Infinity thinnes_ratio=0-1 contour_temperatur=0-1 orientation=0-180 fractal_box_dimension=0-2 option->box-sizes=2,3,4,6,8,12,16,32,64 draw_holes fill_results_table exclude_on_edges");
		
		n = nResults;
		area1 = newArray(n); 
		length1 = newArray(n); 
		area2 = newArray(n); 
		length2 = newArray(n);
		ff1 = newArray(n);
		feret1 = newArray(n); 
		minferet1 = newArray(n);
		orientation1 = newArray(n);
		roiLabel1 = newArray(n);
		
		for (j = 0; j<n; j++) {
			orientation1[j] = getResult('Orientation', j); 
			length1[j] = getResult('Peri.', j);
			area1[j] = getResult('Area', j);
			area2[j] = getResult('Area Conv. Hull', j);
			length2[j] = getResult('Peri. Conv. Hull', j);
			ff1[j] = getResult('Thinnes Rt.', j);
			feret1[j] = getResult('Feret', j);
			minferet1[j] = getResult('Min. Feret', j);
		}
		
		run("Clear Results"); 
		for (j = 0; j<n; j++) { 
			setResult("Area", j, area1[j]);
			setResult("Perim.", j, length1[j]); 
			setResult("CH Area", j, area2[j]); 
			setResult("CH Perim.", j, length2[j]); 
			setResult("Solidity", j, area1[j]/area2[j]); 
			setResult("Convexity", j, length2[j]/length1[j]); 
			setResult("FormFactor", j, ff1[j]);
			setResult("Circularity", j, length1[j]/(2*sqrt(PI*area1[j])));
			setResult("Roundness", j, 4*area1[j]/(PI*pow(feret1[j],2)));
			setResult("AR feret", j, minferet1[j]/feret1[j]);
			setResult("Feret d", j, feret1[j]); 
			setResult("MinFeret d", j, minferet1[j]);
			setResult("Orientation", j, orientation1[j]);
		} 
		
		updateResults();
		savepath=File.directory+File.separator+"results.csv";
		selectWindow("Results");
		saveAs("results", savepath);
		close("Results");
		close("*");
	}