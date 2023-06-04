clear;
clc;
count = 0;

% INPUT parameters
% Bus data
% Bus No		P,MW		Q,MVAR		V_mag,PU	V_phase		
Bus1=   [1		 0.0		0.0			1.0			 0.0	;
         0          0       0           0               0;
         0          0       0           0               0;         
	 	 4       2.0     	1.6 		0.991		-0.370  ;
	 	 5       3.0     	0.4 		0.9888		-0.544  ;
	 	 6       2.0     	-0.4 		0.986		-0.697  ;
	 	 7       1.5     	1.2 		0.985		-0.704  ;
	 	 8       4.0     	2.7 		0.979		-0.763  ;
	 	 9       5.0     	0.8 		0.971		-1.451  ;
	 	 10      1.0     	0.9 		0.977		-0.770  ;
	 	 11      0.6     	-0.5		0.971		-1.525  ;
	 	 12      4.5     	-1.7 		0.969		-1.836  ;
	 	 13      1.0     	0.9 		0.994		-0.332  ;
	 	 14      1.0     	-1.1 		0.995		-0.459  ;
	 	 15      1.0     	0.9 		0.992		-0.527  ;
	 	 16      2.1     	-0.8		0.991		-0.596  ];
		   
% Branch data
%		Line	Bus		Bus	PU Branch 	PU Branch	
%		no:		1	    2	resistance	reactance	

   Line=[ 1      0      1       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
          11	 1		4 	 0.075   	0.1     	;
          12     4   	5 	 0.08    	0.11    	;
          13     4   	6 	 0.09    	0.18    	;
          14     6   	7 	 0.04    	0.04    	;
          15     5   	11 	 0.04    	0.04    	;
          16     1   	8 	 0.11    	0.11    	;
          17     8   	10	 0.11    	0.11    	;
          18     8   	9 	 0.08    	0.11    	;          
          19     9   	11	 0.11    	0.11    	;
          20     9   	12	 0.08    	0.11    	;
          21     10  	14	 0.04    	0.04    	;
          22     1   	13	 0.11    	0.11    	;
          23     13  	15	 0.08    	0.11    	;
          24     13  	14	 0.09    	0.12    	;          
          25     15  	16	 0.04    	0.04    	;     
	      26     7   	16 	 0.09    	0.12    	];
      
%    Loop data
Loop        = [11 12 15	19	18	16 0 0 0 0 0 0 0; 16	17	21	24	22 0 0 0 0 0 0 0 0;   13 14 26 25 23 24 21 17 18 19 15 12 20];

%Branch & possible parents
Parent =   [1   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            11  1   12  16  13  22;
            12  11  13  15  0   0 ;
            13  11  12  14  0   0;
            14  13  26  0   0   0;
            15  12  19  0   0   0;
            16  1   11  17  18  22;
            17  16  18  21  0   0;
            18  16  17  19  20  0;
            19  15  18  20  0   0;
            20  18  19  0   0   0;
            21  17  24  0   0   0;
            22  1   11  16  23  24;
            23  22  24  25  0   0;
            24  21  22  23  0   0;
            25  23  26   0  0   0;
            26  14  25  0   0   0];
root_branch = 1;                 %root branch

% Initializations
Bus1(:,2:3)   = Bus1(:,2:3)/100;
Bus=Bus1;
 sizeof_bus=size(Bus);
 sizeof_line = size(Line);
 sizeof_loop = size(Loop);
 sizeof_parent = size(Parent);
 
Tie_list=Loop;  %any loop element can act as tie
c = max(Tie_list);
d = sort(c);
phero_matrix_size = d(end);   %matrix size with maximum switch number
n_ant = 6;     % minimum no. of ants should be max. loop size
n_stage = 3;    %Number of loops
Iter_max = 20;	% Maximum number of iterations
alpha =1; %5   %5          %1;	% Parameter representing the importance of trail
beta = 8 ;%10  %8         %5;	% Parameter representing the importance of visibility
rho = .5; %1   %1        %0.5;	% Evaporation
Q = 20 ; %10       %10;	% A constant
best = zeros(Iter_max,n_stage);  %best path of each iteration
pheromone = ones(phero_matrix_size,phero_matrix_size);    %pheromone content of paths from one stage to next
eta = zeros(phero_matrix_size,phero_matrix_size);   %inverse of power loss corresponding to the above


%==================== Outer most loop (Loop-1)
iter_iter = 0;			% Start of iterations
for iter_iter = 0:Iter_max-1      %iterations
    t = cputime;
    rand_order1 = [];
    rand_position = [];
    Tie_list_stage1 = Tie_list(1,:);
    zero = find(Tie_list_stage1 == 0);
    for x = 1:n_ant
        n_switch(x,1) = length(Tie_list_stage1)-size(zero,2); %size(zero,2) gives the total 0s in the tie_list_stage
    end    
    for i2 = 1:ceil(n_ant/n_switch(1,1))
        rand_order1 = [rand_order1,randperm(n_switch(1,1))];
    end
    rand_order = rand_order1(1:n_ant);
    for i2 = 1:length(rand_order)
        rand_position(i2) = Tie_list_stage1(rand_order(i2));
    end
    tabu_list(:,1) = (rand_position(1:n_ant))';    % the ants are placed randomly in each switch
    %iter_iter
    %n_switch
    %tabu_list
    
    %==================== Stage (loops in the network) loop (Loop-2 onwards)
    for iter_stage = 2:n_stage        
        Tie_list_stage  = Tie_list(iter_stage,:);
        Tie_list_stage1 = [];
        for x = 1:sizeof_loop(2)
            if Tie_list_stage(x) ~= 0
                Tie_list_stage1=[Tie_list_stage1,Tie_list_stage(x)];
            end
        end
        %Tie_list_stage1
        sizeof_tie_list_stage1=size(Tie_list_stage1);
        %==================== Ant (in each loop)
        for iter_ant = 1:n_ant  
            switch_opened = tabu_list(iter_ant,1:(iter_stage-1)); %upto previous loop
            Tie_list_stage = [];
            Tie_list_stage2 = [];
            for x = 1:sizeof_tie_list_stage1(2)
                if Tie_list_stage1(x) ~= switch_opened
                    Tie_list_stage2 = [Tie_list_stage2,Tie_list_stage1(x)]; %avoid all previous ties in the present tie list options
                end
            end
            %switch_opened
            %Tie_list_stage2
            sizeof_tie_list_stage2 = size(Tie_list_stage2);
            ant_iter = 0;      %actual tie list size of the present ant in this stage
            Tie_open = zeros(1:n_stage);
            for j2 = 1:iter_stage-1
                Tie_open(j2) = tabu_list(iter_ant,j2);
            end
            Tie_list_stage5 = [];
            for x = 1:sizeof_tie_list_stage2(2) %check whether any node is left without supply
                Tie_open(iter_stage) = Tie_list_stage2(x);
                %Tie_open                  
                %[order_loop,continuous] = order(Bus,Line,Loop,Parent,Tie_open,iter_stage)
                [order_loop,continuous] = order_voltage(Bus,Line,Loop,Parent,Tie_open,iter_stage);
                if continuous == 1
                    ant_iter = ant_iter+1;  %changes from ant to ant in any stage
                    Tie_list_stage5 = [Tie_list_stage5,Tie_list_stage2(x)];
                end
            end
            Tie_list_stage = [];
            Tie_list_stage = Tie_list_stage5;
            sizeof_tie_list_stage = size(Tie_list_stage);
            n_switch(iter_ant,iter_stage) = ant_iter;
            probability = zeros(1,n_switch(iter_ant,iter_stage));
            %Tie_list_stage            
            %====================tie switch (for each ant in a loop)
            for iter_switch = 1:n_switch(iter_ant,iter_stage)  %each switch at a particular loop
                Tie_open(iter_stage) = Tie_list_stage(iter_switch);                
                %[order_loop,continuous] = order(Bus,Line,Loop,Parent,Tie_open,iter_stage);
                [order_loop,continuous] = order_voltage(Bus,Line,Loop,Parent,Tie_open,iter_stage);
                %iter_switch
                %[Total_powerloss_system] = powerloss(Bus,Line,order_loop,iter_stage)
                [Total_powerloss_system,voltage_system] = powerloss_voltage(Bus,Line,order_loop,iter_stage);
                eta(switch_opened(end),Tie_list_stage(iter_switch)) = 1.0/Total_powerloss_system; %corresponding to previous loop-tie, current tie-option
                probability(iter_switch) = (pheromone(switch_opened(end),Tie_list_stage(iter_switch)))^alpha*(eta(switch_opened(end),Tie_list_stage(iter_switch)))^beta;
            end
            probability	= probability/sum(probability);
            pcum = cumsum(probability);
            select = find(pcum >= rand);
            to_open = Tie_list_stage(select(1));
            tabu_list(iter_ant,iter_stage) = to_open;
            %tabu_list has information of aech ants position at each stage corresponding to one iteration
        end
    end
    
    %calculating the minimum loss path and average loss in each iteration
    for i2 = 1:n_ant    %total powerloss corresponding to each ant
        Tie_open = tabu_list(i2,:);
        %[order_loop] = order(Bus,Line,Loop,Parent,Tie_open,iter_stage);
        [order_loop,continuous] = order_voltage(Bus,Line,Loop,Parent,Tie_open,iter_stage);
        %[Total_powerloss_system] = powerloss(Bus,Line,order_loop,iter_stage);
        [Total_powerloss_system,voltage_system] = powerloss_voltage(Bus,Line,order_loop,iter_stage);
        total_loss(i2) = Total_powerloss_system;
    end
    loss_min(iter_iter+1) = min(total_loss);
    position = find(total_loss == loss_min(iter_iter+1));
    best(iter_iter+1,:) = tabu_list(position(1),:); %best ant path of the iteration
    loss_average(iter_iter+1) = mean(total_loss);
    delta_pheromone	= zeros(phero_matrix_size,phero_matrix_size);
    ant1_loss(iter_iter+1) = total_loss(1);
    ant2_loss(iter_iter+1) = total_loss(2);
    ant3_loss(iter_iter+1) = total_loss(3);
    %ant4_loss(iter_iter+1) = total_loss(4);
    %ant5_loss(iter_iter+1) = total_loss(5);
    %ant6_loss(iter_iter+1) = total_loss(6);
    %ant7_loss(iter_iter+1) = total_loss(7);
    %ant8_loss(iter_iter+1) = total_loss(8);
    %ant9_loss(iter_iter+1) = total_loss(9);
    %ant10_loss(iter_iter+1) = total_loss(10);
    %ant11_loss(iter_iter+1) = total_loss(11);
    %ant12_loss(iter_iter+1) = total_loss(12);
    %ant13_loss(iter_iter+1) = total_loss(13);
    %ant14_loss(iter_iter+1) = total_loss(14);
    %ant15_loss(iter_iter+1) = total_loss(15);
    %ant16_loss(iter_iter+1) = total_loss(16);
    for i_1 = 1:n_ant
        for j_1 = 1:(n_stage-1) %pheromone change 
            delta_pheromone(tabu_list(i_1,j_1),tabu_list(i_1,j_1+1)) = delta_pheromone(tabu_list(i_1,j_1),tabu_list(i_1,j_1+1))+Q/total_loss(i_1);
        end
    end
    ant = tabu_list;
    pheromone = (1-rho).*pheromone+delta_pheromone;
    old_tabu_list = tabu_list;
    tabu_list = zeros(n_ant,n_stage);
    time= cputime-t;
    if best(iter_iter+1,:) == [19 17 26]
    count=count+1;
end
end
Total_loss_ant = total_loss
Solution = best(Iter_max,:)
Solution_path_loss = loss_min(end)
Average_loss = loss_average(end) 
Iteration_time=time
best
loss_min_iteration=loss_min'
count
%--------------------------------------------------------------------------
figure(1)
set(gcf,'Name','Ant Colony Optimization！！Figure of loss_min','Color','w')
plot(loss_min,'r')
set(gca,'Color','w')
%hold on
%plot(loss_average,'k')
xlabel('Iterations')
ylabel('Min powerloss')
title('Powerloss')

figure(2)    
set(gcf,'Name','Ant Colony Optimization！！Ant paths','Color','w')
plot(ant(1,:),'g','LineWidth',2)
hold on
plot(ant(2,:),'m','LineWidth',2)
hold on
plot(ant(3,:),'b','LineWidth',2)
%hold on
%plot(ant(4,:),'r')
%hold on
%plot(ant(5,:),'g')
%hold on
%plot(ant(6,:),'b')
%hold on
%plot(ant(7,:),'k')
%hold on
%plot(ant(8,:),'y')
%hold on
%plot(ant(9,:),'m')
%hold on
%plot(ant(10,:),'c')
%hold on
%plot(ant(11,:),'r')
%hold on
%plot(ant(12,:),'g')
%hold on
%plot(ant(13,:),'b')
%hold on
%plot(ant(14,:),'k')
%hold on
%plot(ant(15,:),'b')
%hold on
%plot(ant(16,:),'r')
xlabel('Stages')
ylabel('Tie Switches')
title('Ant paths')

Original=[0.9951;0.9951;0.9951;0.9912;0.9888;0.9861;0.9850;0.9777;0.9710;0.9770;0.9710;0.9690;0.9944;0.9950;0.9915;0.9910];
%Original=Bus(:,4)';
New=voltage_system(:,2)';
%Total_powerloss_system;
figure(3)
set(gcf,'Name','Voltage_Profile！！Original ang New Voltages','Color','w')
plot(Original,'k','LineWidth',2)
set(gca,'Color','w')
hold on
plot(New,'r','LineWidth',2)
axis([1 16 0.92 1.05])
xlabel('Nodes')
ylabel('Voltage')
title('Voltage_Profile')