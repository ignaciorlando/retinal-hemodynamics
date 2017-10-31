# Simulation of retinal hemodynamics

This code corresponds to our project on simulation of the retinal hemodynamics.


## Installation

1. Clone the repository using git.
2. Open MATLAB and move to the root folder of the repository.
3. Run ```setup```in the MATLAB console to add the folder to the path.

## Data preparation

We used publicly available data sets for running our experiments. In order to set up the data in a proper way, you can use some of the scripts in the ```data-preparation``` folder.

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

```displayGraph(graph, [image])```

Display a given ```graph```. If ```image``` is given, the graph is display over the input image.