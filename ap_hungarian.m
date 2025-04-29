function ap_hungarian()
    n = 5;
    prefs = [ 8   2  -1   5   4;
             10   9   2   8   4;
              5   4   9   6  -1;
              3   6   2   8   7;
              5   6  10   4   3 ];

    max_pref = max(prefs(:));
    inf_val = Inf;
    cost = zeros(n);
    for i = 1:n
        for j = 1:n
            if prefs(i,j) < 0
                cost(i,j) = inf_val;
            else
                cost(i,j) = max_pref - prefs(i,j);
            end
        end
    end

    fprintf('initial cost matrix:\n');
    disp(cost);

    for i = 1:n
        cost(i,:) = cost(i,:) - min(cost(i,:));
    end
    fprintf('cost after row reduction:\n');
    disp(cost);

    for j = 1:n
        cost(:,j) = cost(:,j) - min(cost(:,j));
    end
    fprintf('cost after column reduction:\n');
    disp(cost);

    assignment = zeros(1,n);
    crossed_zeros = zeros(n);

    while true
        crossed_zeros(:) = 0;
        assignment(:) = 0;
        change_flag = true;
        while change_flag
            change_flag = false;

            for row = 1:n
                zero_cols = find(cost(row,:)==0 & ~crossed_zeros(row,:) & assignment(row)==0);
                if numel(zero_cols) == 1
                    assignment(row) = zero_cols;
                    crossed_zeros(setdiff(1:n,row), zero_cols) = 1;
                    change_flag = true;
                end
            end

            for col = 1:n
                zero_rows = find(cost(:,col)==0 & ~crossed_zeros(:,col) & assignment'==0);
                if numel(zero_rows) == 1
                    assignment(zero_rows) = col;
                    crossed_zeros(zero_rows, setdiff(1:n,col)) = 1;
                    change_flag = true;
                end
            end
        end

        if all(assignment)
            break;
        end

        row_marked = assignment == 0;
        col_marked = false(1,n);
        change_flag = true;
        while change_flag
            change_flag = false;
            for row = find(row_marked)
                marked_cols = find(crossed_zeros(row,:));
                for col = marked_cols
                    if ~col_marked(col)
                        col_marked(col) = true;
                        change_flag = true;
                    end
                end
            end
            for col = find(col_marked)
                matched_row = find(assignment == col);
                if ~row_marked(matched_row)
                    row_marked(matched_row) = true;
                    change_flag = true;
                end
            end
        end

        row_cover = ~row_marked;
        col_cover = col_marked;

        delta_val = inf_val;
        for row = find(~row_cover)
            for col = find(~col_cover)
                delta_val = min(delta_val, cost(row,col));
            end
        end

        for row = 1:n
            for col = 1:n
                if ~row_cover(row) && ~col_cover(col)
                    cost(row,col) = cost(row,col) - delta_val;
                elseif row_cover(row) && col_cover(col)
                    cost(row,col) = cost(row,col) + delta_val;
                end
            end
        end

        fprintf('matrix after adjustment:\n');
        disp(cost);
    end
        
    best_score = sum(prefs(sub2ind(size(prefs), 1:n, assignment)));
    fprintf('maximum total preference: %d\n', best_score);

    flights = {'i','ii','iii','iv','v'};
    pilots  = {'a','b','c','d','e'};
    for idx = 1:n
        fprintf('%s assigned to flight %s with pref %d\n', pilots{idx}, flights{assignment(idx)}, prefs(idx, assignment(idx)));
    end
end
