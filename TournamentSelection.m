function best = TournamentSelection(pop, k)
    best = size(pop, 1);
    fitness = zeros(size(pop, 1), 1);
    for n = 1:length(fitness)
        fitness(n, 1) = pop(n, end);
    end
    for i = 1:k
        
        index = randi([1, size(pop,1)]);
        
        if (or(best == size(pop, 1), fitness(index) > fitness(best)))
            best = index;
        end
    end