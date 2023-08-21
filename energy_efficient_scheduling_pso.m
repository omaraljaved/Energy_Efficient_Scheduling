clear;
clc;

numParticles = 30;
maxIterations = 100;
numJobs = 10;
numMachines = 5;

w = 0.6;
c1 = 1.8;
c2 = 1.8;

maxSetupTime = 5;
processingRates = randi([5, 15], numJobs, numMachines);
energyProfiles = rand(numJobs, numMachines);

particles = randi([1, numMachines], numParticles, numJobs);
velocities = zeros(numParticles, numJobs);

globalBestParticle = particles(1, :);
globalBestFitness = calculateFitness(globalBestParticle, processingRates, energyProfiles);

localBestParticles = particles;
localBestFitnesses = arrayfun(@(p) calculateFitness(p, processingRates, energyProfiles), particles);

for iteration = 1:maxIterations
    for p = 1:numParticles
        particle = particles(p, :);
        
        velocities(p, :) = w * velocities(p, :) + c1 * rand(1, numJobs) .* (localBestParticles(p, :) - particle) + c2 * rand(1, numJobs) .* (globalBestParticle - particle);
        
        particle = particle + round(velocities(p, :));
        particle(particle > numMachines) = numMachines;
        particle(particle < 1) = 1;
        
        fitness = calculateFitness(particle, processingRates, energyProfiles);
        if fitness < localBestFitnesses(p)
            localBestParticles(p, :) = particle;
            localBestFitnesses(p) = fitness;
        end
        
        if fitness < globalBestFitness
            globalBestParticle = particle;
            globalBestFitness = fitness;
        end
    end
end

disp('Optimal Schedule:');
disp(globalBestParticle);
disp('Energy Consumption:');
disp(globalBestFitness);

figure;
bar(1:numJobs, energyProfiles(globalBestParticle, :));
xlabel('Jobs');
ylabel('Energy Consumption');
title('Optimal Job Scheduling for Energy Efficiency');

function fitness = calculateFitness(schedule, processingRates, energyProfiles)
    makespan = max(sum(processingRates(:, schedule)));
    energyConsumption = sum(energyProfiles(sub2ind(size(energyProfiles), 1:length(schedule), schedule)));
    fitness = makespan + energyConsumption;
end
