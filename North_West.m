supply = input("enter the supply row ");
demand = input("enter the demand row ");
cost_matrix = input("enter the cost matrix");
total_supply = sum(supply);
total_demand = sum(demand);
allocation_matrix = zeros(size(cost_matrix));
if total_supply > total_demand
    demand = [demand,total_supply - total_demand];
    cost_matrix = [cost_matrix , zeros(size(cost_matrix,1),1)];
    supply_surplus = total_supply - total_demand;
    demand_surplus = 0;

elseif total_demand > total_supply
    supply = [supply , total_demand - total_supply];
    cost_matrix = [cost_matrix ; zeros(1,size(cost_matrix , 2))];
    supply_surplus = 0;
    demand_surplus = total_demand - total_supply;
else
    supply_surplus = 0;
    demand_surplus = 0;
end
%now matrix is balanced 
i = 1;
j = 1;
total_supply = supply;
total_demand = demand;

while i <= length(total_supply) && j <= length(total_demand)
    allocation = min(total_supply(i),total_demand(j));
    allocation_matrix(i,j) = allocation;
    total_demand(j) = total_demand(j) - allocation;
    total_supply(i) = total_supply(i) - allocation;
    if total_demand(j) == 0 & j<length(demand)
        j = j+1;
    elseif total_supply(i) == 0 & i < length(supply)
        i = i+1;
    else 
        break;
    end
       
end
if supply_surplus > 0
    actual_allocation = allocation_matrix(:,1:end-1);
    actual_cost_matrix = cost_matrix(:,1:end-1);
elseif demand_surplus > 0
    actual_allocation = allocation_matrix(1:end-1,:);
    actual_cost_matrix = cost_matrix(1:end-1 , :);
else
    actual_allocation = allocation_matrix;
    actual_cost_matrix = costmatrix;
end
total_cost = sum(sum(actual_allocation .* actual_cost_matrix));
fprintf('\nAllocation Matrix:\n');
disp(allocation_matrix);

fprintf('Total Transportation Cost: %d\n', total_cost);

if supply_surplus > 0
    fprintf('\nSupply Surplus: %d units\n', supply_surplus);
elseif demand_surplus > 0
    fprintf('\nDemand Surplus: %d units\n', demand_surplus);
end



     

