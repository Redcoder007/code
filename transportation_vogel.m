function transportation_vogel()
supply = input("Enter the supply row");
demand = input("Enter the demand row ");
cost = input("Enter tthe cost matrix ");
total_s = sum(supply);
total_d = sum(demand);
if total_s > total_d
    demand = [demand , total_s - total_d];
    cost = [cost zeros(size(cost,1),1)];
    supply_surplus = total_s - total_d;
    demand_surplus = 0;
elseif total_d > total_s
    supply = [supply total_d - total_s];
    cost = [cost ; zeros(1,size(cost,2))];
    demand_surplus = total_d - total_s;
    supply_surplus = 0;

else
    demand_surplus = 0;
    supply_surplus = 0;
end
fprintf("Balanced cost matrix: ");
disp(cost)
[m,n] = size(cost);
allocations = zeros(m,n);
total_s = supply;
total_d = demand;
active_r = true(m,1);
active_c = true(1,n);
basic = false(m,n);
while nnz(basic) < m + n -1
    row_pen = -Inf(m,1);
    for i = 1:m
        if active_r(i)
            col = find(active_c);
            if numel(col) >=2 %calculates no. of values in col
                c = sort(cost(i,col));
                row_pen(i) = c(2) - c(1);
            else 
                row_pen(i) = 0;
            end
        end
    end
    col_pen = -Inf(1,n);
    for j = 1:n
        if active_c(j)
            row = find(active_r);
            if numel(row) >= 2
                r = sort(cost(row,j));
                col_pen(j) = col(2) - col(1);
            else col_pen(j) = 0;
            end
        end
    end
    % pick high penalty cell
    [pr,r] = max(row_pen);
    [pc,c] = max(col_pen);
    if pr>=pc
       i = r;
       cols = find(active_c);
       [~,idx] = min(cost(i,cols));
       j = cols(idx);
    else j = c;
        rows = find(active_r);
        [~,idx] = min(cost(rows,j));
        i = rows(idx);
    end
    %mark this cell as basic 
    basic(i,j) = true;
    q = min(total_s(i),total_d(j));
    allocations(i,j) = q;
    total_s(i) = total_s(i) - q;
    total_d(j) = total_d(j) - q;
    %if both hit zero only drop one
    if total_s(i) == 0 & total_d(j) == 0
        active_r(i) = false;
    elseif total_s(i) == 0
        active_r(i) = false;
    else total_d(j) == 0
        active_c(j) = false;
    end
    %compute cost 
    total_cost = sum(sum(allocations .* cost));
    fprintf("total cost of allocations is:");
    disp(total_cost)
    fprintf("Allocations:\n")
    disp(allocations)
    end











