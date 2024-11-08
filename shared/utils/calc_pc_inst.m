% Function: calc_pc_inst
% Desc: Given samples of particles trajectories and hardbody radius, the
% function calculates instantaneous particle collision probability for each
% timestep
%
% Inputs:
%   positionA:      Position vectors of Object A [dim: sample x time x
%   position]
%
%   positionB:      Position vectors of Object B [dim: sample x time x
%   position]
%
%   hardbody_radius:    Combined harbody radius of object A and object B
%
% Outputs:
%   pc_inst:         Instantaneous Probability of Collision for each time
%   step

function [pc_inst] = calc_pc_inst(positionA, positionB, hardbody_radius)
    num_samples = length(positionA(:,1,:));
    time_length = length(positionA(1,:,:));
    pc_inst = zeros(time_length, 1);
    parfor time = 1:time_length
        pc_inst(time) = 0;
        posA = reshape(positionA(:, time, :), num_samples, 3);
        posB = reshape(positionB(:, time, :), num_samples, 3);
        for i = 1:num_samples
            posA_sample = posA(i, :);
            for j = 1:num_samples
                posB_sample = posB(j, :);
                if norm(posA_sample - posB_sample) < hardbody_radius
                    pc_inst(time) = pc_inst(time) + 1;
                end
            end
        end
        pc_inst(time) = (pc_inst(time) / (num_samples * num_samples));
    end
    

end

