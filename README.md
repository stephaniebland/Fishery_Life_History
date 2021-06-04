# Fishery_Life_History
Masters Project
Code used to run simulations in Bland S, Valdovinos FS, Hutchings JA, Kuparinen A. The role of fish life histories in allometrically scaled food‐web dynamics. Ecol Evol. 2019;00:1–10.

Thesis: https://dalspace.library.dal.ca/handle/10222/76695

First Author Paper: https://www.researchgate.net/publication/331280117_The_role_of_fish_life_histories_in_allometrically_scaled_food-web_dynamics

## List and description of all the files

### Simulations

- [START\_RunCluster](MATLAB_code/RunCluster.m) Runs the model with appropriate parameters and saves
results. 
	- Launch this one first with command for an easy demonstration:
		- START\_RunCluster(0,x,x) where x is a positive integer.

	- A note about input parameters: 
		- str2num converts shell script parameters to parameters MATLAB can use. It is necessary for running the model in the cluster. However, it breaks when you run the model from MATLAB, so to run in MATLAB it is necessary to comment out all the str2num lines. 
		- START\_RunCluster(seed\_0, simnum\_0, simnum\_f, var_fishpred, var_splitdiet)
		- IMPORTANT: Not all input parameters are necessary – they will default to those in “Parameter.m” instead. 
		- seed\_0 makes the simulation reproducible. 
		- simnum\_0 and simnum\_f are the simulation numbers to run, so the model will run all simulations simnum\_0 through simnum\_f. 
		- So to call the model all you need is the first three parameters 
			- ex: START\_RunCluster(0,2,2).
			- I suggest setting simnum\_0=simnum\_f. The simulation is reproducible, meaning the output will be identical for any given simnum (simulation number).

- [DateVersion](MATLAB_code/DateVersion.m) Labels output with version number. Normally it's set to something like run_name='2018Feb28_2';

- [Parameters](MATLAB_code/Parameters.m) Sets the parameters for the model.

- [simulations](MATLAB_code/simulations.m) Solves the ODEs, runs the simulations, and plots graphs. Saves all simulation relevant results. This is the computationally expensive part of the model.

### Initializing

- [setup](MATLAB_code/setup.m) Creates the food web, sets all the web-dependent parameter
values and the initial conditions for biomasses and efforts.

- [NicheModel](MATLAB_code/NicheModel.m) Calls “CreateWeb.m” and then tests whether it satisfies the
conditions we want our original web to meet.

- [CreateWeb](MATLAB_code/CreateWeb.m) Function called by “NicheModel.m” that takes the number of
species and the connectance as inputs and calculates a “nicheweb” matrix
of feeding links (rows eat columns). This function is called twice, so
it has the restrictions that we want any web to meet (ex: all new life
stages have some prey).

- [TrophicLevels](MATLAB_code/TrophicLevels.m) Function called by “setup.m” that calculates the trophic
levels of every species. Called a second time for the new life stages.

- [MassCalc](MATLAB_code/MassCalc.m) Called by “setup.m” to calculate their body-size

- [LifeHistories](MATLAB_code/LifeHistories.m) Called by “setup.m” to declare new life stages. Finds
the body size for new species using von-Bertalanffy. Keeps track of
which nodes belong to which species, how many nodes each species has, etc.
And extends the food web to include the new lifestages (Various methods
– some of them are deterministic, others call “CreateWeb.m” to fill in
empty rows/columns while preserving original nodes). Also calls
“LeslieMatrix.m”.

- [LeslieMatrix](MATLAB_code/LeslieMatrix.m) Called by “LifeHistories.m” and makes a leslie growth
matrix.

- [metabolic\_scaling](MATLAB_code/metabolic\_scaling.m) Called by “setup.m” to calculate their metabolic
rates.

- [func\_resp\_scaling](MATLAB_code/func\_resp\_scaling.m) Function called by “setup.m” that calculates the
parameters values for the functional response: half saturation density
and predator interference.

- [attach](MATLAB_code/attach.m) Function from:\
https://www.mathworks.com/matlabcentral/fileexchange/35436-attach/content/attach.m\
that allows parameters to be packaged as fields to get pushed through
functions cleanly, without long function calls.

### Dynamics

- [Dietary\_evolution](MATLAB_code/Dietary\_evolution.m) Called by “simulations.m” and shifts the food web
to represent diet food shifts that occur when fish species get smaller.
This only has an effect if evolv\_diet is non zero – that tells you how
much the web is shifted by, and in which direction. It’s a test for
later (evolv\_diet is currently set at 0).

- [prob\_of\_maturity](MATLAB_code/prob\_of\_maturity.m) Called by “simulations.m” and finds the probability
of each life stage maturing.

- [dynamic\_fn](MATLAB_code/dynamic\_fn.m) Function that takes all the web parameters as inputs and
solves the differential equations using the “ode45” function. It takes
into account the extinction threshold.

- [biomass](MATLAB_code/biomass.m) Function called by the “ode45” function that calculates the
derivatives of the biomasses and the efforts as a unique array dx/dt.

- [gr\_func](MATLAB_code/gr\_func.m) Function called by “biomass.m” to calculate the growth vector
for the biomasses, using the ATN equations.

### Analysis

- [isConnected](MATLAB_code/isConnected.m) Function that takes the food web matrix as input and
determines whether the graph is connected (no isolated species, no
partitioning into several isolated sub-webs).

- [web\_properties](MATLAB_code/web\_properties.m) Function that takes the food web matrix as input and
calculates the 17 structural properties of a web.
