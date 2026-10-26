function [types, labels] = flow_types_3d
% Flow types of the particle image generator (setup.flow.Type) and their names in the panel,
% in the order of the popup menu.
types = {'rankine', 'oseen', 'vortex_jet', 'uniform', 'rotation', 'membrane', 'sphere', 'jet'};
labels = {'Rankine vortex', 'Hamel-Oseen vortex', 'Vortex with out-of-plane jet', 'Uniform displacement', ...
    'Solid body rotation', 'Membrane', 'Sphere wake (3D flow simulation)', 'Free jet (3D flow simulation)'};
end
