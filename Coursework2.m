load("xy.mat");

cities_x = xy(:,1);
cities_y = xy(:,2);

iterations = 2000;
population_size = 100;
CHR_size = 100;

%% Start - Generate random popolation for n chromosomes
population = zeros(population_size,CHR_size);
for i = 1:population_size
    temp_chromosome = randperm(100);
    population(i,1:100) = temp_chromosome;
    population(i,101) =temp_chromosome(1);
end

%% Add extra colums at the end
population = [population zeros(population_size,1)];

%% Fitness - Evaluate fitness of each chromosome
for iter = 1:iterations
    %%Fitness
    totalDist = zeros(population_size,1);
    for i = 1:population_size
        
        dist = pdist2(xy(population(i,100),:),xy(population(i,1),:), 'euclidean'); %closed path
        for n = 2:CHR_size
            m = n-1;
            dist = dist + pdist2(xy(population(i,m),:),xy(population(i,n),:), 'euclidean');
        end
        population(i,end) = 1/dist;
    end
   [iter, 1/population(1, end), 1/population(end, end)] %check the distance for each iteration
    
    %% Selection -Best of 2
      population = sortrows(population,size(population,2));
      population_new = zeros(population_size,101);
      population_new(1:2,:) = population(population_size-1:population_size,1:101);
      population_new_num = 2;
    
    %% New population
    while (population_new_num < population_size)
        %% Selection
        weights= population(:,end)/sum(population(:,end));
        
        %% Roulette Wheel Selection
        %choice1 = Selection(weights);
        %choice2 = Selection(weights);
        
        %% Tournament Selection
        choice1 = TournamentSelection(population,2);
        choice2 = TournamentSelection(population,2);
        
        temp_chromosome1 = population(choice1, 1:100);
        temp_chromosome2 = population(choice2, 1:100);
        
     
    %% Crossover PMX
    %Select two random points where to make the cuts
    if (rand < 0.8)
        lo = randi([1,99]);
        up = randi([lo+1,100]);
        
        if(or(up - lo < 3, up - lo >10))
            is_okay = true;
        end
        
        if(is_okay)
            lo = 11;
            up = 18;
        end
        
        %Choose values in between the cut points
        child1_seg = temp_chromosome2(lo:up);
        child2_seg = temp_chromosome1(lo:up);
        
        child1 = temp_chromosome1;
        child2 = temp_chromosome2;
        
        %Swap segments between the children
        
       child1(lo:up) = child1_seg;
       child2(lo:up) = child2_seg;
       
       %Find relation map
       temp1_map = [];
       temp2_map = [];
       
       for j = 1:length(child1_seg)
           temp1_map_value = child1_seg(j);
           temp2_map_value = child2_seg(j);
           
           if(~ismember(temp1_map_value, child2_seg)) %if the swiched value in child1(j) is NOT in the child2 segment
               if(ismember(temp2_map_value, child1_seg)) %if the swiched value in child2(j) is NOT in the child1 segment
                   %find the same value for child1 segment and child2(j)
                   %and swap
                   temp2_map_value = child2_seg(find(child1_seg == temp2_map_value));
               end
               temp1_map = [temp1_map, child1_seg(j)];
               temp2_map = [temp2_map,  temp2_map_value];
           end
       end
       
       %Swap genes according to relation map
       for i = 1:length(temp1_map)
           child1(find(child1 == temp1_map(i))) = temp2_map(i);
           child2(find(child2 == temp2_map(i))) = temp1_map(i);
       end
       
       % Undo swapped elements in segment
       child1(lo:up) = child1_seg;
       child2(lo:up) = child2_seg;
  
       
       temp_chromosome1 = child1;
       temp_chromosome1(101) = temp_chromosome1(1);
       
       temp_chromosome2 = child2;
       temp_chromosome2(101) = temp_chromosome2(1);
    
   
  
       
    end
        %% Mutation 
       if (rand < 0.2)
        %Pick random segements to swap
        temp_i = randi([1, 99]);
        temp_j = randi([temp_i+1, 100]);
        
        %swap 2 values in temp_chromosome1
        temp_i_value = temp_chromosome1(temp_i);
        temp_chromosome1(temp_i) = temp_chromosome1(temp_j);
        temp_chromosome1(temp_j) = temp_i_value;
        

        %Pick random segements to swap
        temp_i = randi([1, 99]);
        temp_j = randi([temp_i+1, 100]);
        
        %Swap two values in temp_chromosome_2
        temp_i_value = temp_chromosome2(temp_i);
        temp_chromosome2(temp_i) = temp_chromosome2(temp_j);
        temp_chromosome2(temp_j) = temp_i_value;
       
       end 
       temp_chromosome1(101) = temp_chromosome1(1);
       temp_chromosome2(101) = temp_chromosome2(1);
    %% Accepting
    population_new_num = population_new_num +1;
    population_new(population_new_num, :) = temp_chromosome1;
    
    if (population_new_num < population_size)
         population_new_num = population_new_num + 1;
         population_new(population_new_num,:) = temp_chromosome2;
    end
    end
    
    population(:,1:end - 1) = population_new;
    
    
end


    %% Replace
    for i = 1:population_size
        
        dist_new = pdist2(xy(population(i,100),:),xy(population(i,1),:), 'euclidean'); %closed path
        for n = 2:CHR_size
            m = n-1;
            dist_new = dist_new + pdist2(xy(population(i,m),:),xy(population(i,n),:), 'euclidean');
        end
        population(i,end) = 1/dist_new;
    end
 
    %%Optimal Route
    optRoute = zeros(1, 100);
    for n = 1:100
        optRoute(1, n) = population(end, n);
        %[population(end, n), cities(population(end, n), 1), cities(population(end, n), 2), optRoute(n, :)]
    end
    
    minDist = 1/population(end, end);

    %% Figure for path
     figure('Name','TSP_GA | Results','Numbertitle','off');
     subplot(2,2,1);
     pclr = ~get(0,'DefaultAxesColor');
     plot(xy(:,1),xy(:,2),'.','Color',pclr);
     title('City Locations');
     subplot(2,2,2);
     rte = optRoute([1:100 1]);
     plot(xy(rte,1),xy(rte,2),'r.-');
     title(sprintf('Total Distance = %1.4f',minDist));
    
population = sortrows(population, 102);
1/population(end,102)

  %%
               
       
            
    

        
        