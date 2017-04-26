cd('/Applications/MATLAB_R2016b.app/toolbox/local')
c = parcluster;             % Get a handle to the cluster.
j=c.batch('/Users/JurassicPark/Google Drive/GIT/Masters Project/testingACENET')
c.Jobs

cd('/Users/JurassicPark/Google Drive/GIT/Masters Project')