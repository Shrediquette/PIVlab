function [types, labels] = flow_types_3d
% Flow types of the 3D particle image generator (setup.flow.Type) and their names in the panel,
% in the order of the popup menu.
types = {'vortex_jet', 'rankine', 'uniform', 'rotation', 'membrane'};
labels = {'Vortex with out-of-plane jet', 'Rankine vortex', 'Uniform displacement', 'Solid body rotation', 'Membrane'};
end
