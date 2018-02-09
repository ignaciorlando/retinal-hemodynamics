# Simulation of retinal hemodynamics

This code corresponds to our project on simulation of the retinal hemodynamics.


## Installation

1. Clone the repository doing ```git clone https://github.com/ignaciorlando/retinal-hemodynamics.git```.
2. Run ```git submodule update --recursive```
3. Move to ```external/cnn-finetune/dependencies```  and run ```git submodule update --init```
4. Open MATLAB and move to the root folder of the repository.
5. Run ```setup``` in the MATLAB console to add the folder to the path.

> --- **Note** --- If you get an error when compiling Matconvnet, it might be that you don't have libdevjpeg installed in your computer. Run ```sudo apt-get install libjpeg-dev```.

## Data preparation

We used publicly available data sets for running our experiments. In order to set up the data in a proper way, you can use some of the scripts in the ```data-organization``` folder.

- ```script_setup_rite_data```: downloads the [RITE dataset](https://medicine.uiowa.edu/eye/rite-dataset) and generates folders for arteries and veins.

## Precomputed resources

The folder ```./precomputed-data``` contains precomputed data such as manual optic disc segmentations.

## Data structures

Arterial branches are mapped to an intermediate graph representation, which is obtained from the centerline of the arterial segmentation. This graph structure is a MATLAB ```struct``` with the following fields:

- ```node```: is a cell array of nodes. Each node has the following fields:
    - ```node.idx```: array of indices of pixels in the branching/root node.
    - ```node.links```: array with the ids of the links spanning from the node.
    - ```node.conn```: array with the ids of the nodes connected with the current node through a link. The order of the ids coincides with the order of the links in ```node.links```.
    - ```node.numLinks```: length of the array of links.
    - ```node.is_root```: a logical value indicating if the node is a root.
    - ```node.tree_id```: id of the tree where the node is located.
    - ```node.comx```: mean x coordinate of the node.
    - ```node.comy```: mean y coordinate of the node.

- ```link```: is a cell array of links.
    - ```link.n1```: one of the nodes connected by the link.
    - ```link.n2```: the other node connected by the link. If the link is a terminal link, ```n2``` is equal to -1.
    - ```link.point```: list of points in the centerline that are part of the link.
    - ```link.tree_id```: id of the tree where the link is located.

- ```w```: is the width of the associated image.
- ```h```: is the hight of the associated image.
- ```roots```: is an array with the ids of the root nodes for each subtree. The position in the array is associated with the ```tree_id```, while the content of the position is the id of the node which is root of that tree.




## Experiments

### Manual labeling

```script_delineate_od```

The root nodes of the computation graph are determined by analyzing the intersection between the arterial trees and the optic disc. To this end, it is essential to count with a (corse) segmentation of the optic disc. This script allows you to manually delineate an ellipse around the optic disc, and saves the output segmentations in a separate folder.

### Input data generation

```script_generate_input_data```

This script allows you to compute the input data needed to perform the hemodynamic simulation and saves it as a .MAT file. In particular, it computes the arterial trees centerlines (```trees_ids```), their radius at each point (```trees_radius```) and the graph structure (```graph```).

> --- **Important!** --- The data set that you will process will require to count with the arterial segmentations (in an ```arteries``` folder) and the optic disc segmentations (in an ```od-masks```).

### Figure generation

```display_graph(graph, [image])```

Display a given ```graph```. If ```image``` is given, the graph is display over the input image.

### VTK data generation

```script_generate_input_data_vtk```

This script allows you to export the skeletonizations generated with the ```script_generate_input_data``` script to VTK files.
Such files are the imput to the code that computes hemodynamics. The pixel spacing is hardcoded in this script.

### Run hemodynamic simulations

```script_run_simulation```

This script allows you to run a set of scenarios defined by a total blood flow and ophthalmic pressures.
It is mandatory to generate the VTK files before running this script.
The pixel spacing is hardcoded in this script, and should match the one used to generate the VTK files.
The scripts reads data folders from ```config_generate_input_data```.
The output is stored in the folder ```RITE-<test|training>/hemodynamic-simulation/```.
For each scenario, a .VTK and a .mat files contaning the simulation results are generated.
The file name follows the encoding: ```<ImageID>_<test|training>_SC<scenarioID>_sol.<mat|vtk>```.
The .mat file contains a variable named ```sol```, which is a 3D matrix of dimensions [width,height,5]. 
Matrix dimensions represents the radius (in [cm]), the flow (in [ml/s]), the pressure (in [mmHg]), the velocity (in [cm/s]) and
a mask indicating if the centerline pixel is arterial segment (0), a root (1), a terminal (2) or a bifurcation (3).

### Perform data analysis

```script_hemodynamics_sensitivity_analysis```

This script allows you to exploratory data analysis and statistics on the hemodynamics simulations results.
UNDER DEVELOPMENT!



