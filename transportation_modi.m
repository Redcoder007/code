function X = transportation_modi (C, X, basic_cell) 
    [m, n] = size(C);
    
    while true

        u = nan(m,1);
        v = nan(n,1);
        u(1) = 0; 
        known = true;

        while known
            known = false;
            for i = 1:m
                for j = 1:n
                    if basic_cell(i,j) == 1 
                        if ~isnan(u(i)) && isnan(v(j))
                            v(j) = C(i,j) - u(i);
                            known = true;
                        elseif isnan(u(i)) && ~isnan(v(j))
                            u(i) = C(i,j) - v(j);
                            known = true;
                        end
                    end
                end
            end
        end
        
        delta = nan(m,n);
        for i = 1:m
            for j = 1:n
                delta(i,j) = u(i) + v(j) - C(i, j);
            end
        end

        [minDelta, idx] = max(delta(:));
        if isempty(minDelta) || minDelta <= 0
            break;
        end
        
        [r, s] = ind2sub([m, n], idx);

        [d, loop] = get_loop(basic_cell, r, s);
        
        theta = inf;
        for k = 1: size(loop, 1)
            r_ = loop(k, 1);
            s_ = loop(k, 2);
            if mod(d(r_, s_), 2) == 1
                theta = min(theta, X(r_, s_));
            end
        end

        replaced = false;   
        for k = 1: size(loop, 1)
            r_ = loop(k, 1);
            s_ = loop(k, 2);
            if mod(d(r_, s_), 2) == 1
                X(r_, s_) = X(r_, s_) - theta;
                if X(r_, s_) == 0 && ~replaced
                    replaced = true;
                    basic_cell(r_, s_) = 0;
                    basic_cell(r, s) = 1;
                end
            else
                X(r_, s_) = X(r_, s_) + theta;
            end 
        end
    end
end

function [d, loop] = get_loop (X, r, s)
    [m, n] = size(X);
    
    d = Inf(m, n);
    p = nan(m, n, 2);

    q = zeros(n+m+3, 2);
    front = 1;
    back = 1;

    q(1, :) = [r s];
    d(r, s) = 0;
    back = back + 1;

    loop_p1 = [];
    loop_p2 = [];

    while (back - front ~= 0) 
        r_ = q(front, 1);
        s_ = q(front, 2);

        front = front + 1;
        for j = 1: n
            if X(r_, j) == 1 
                if d(r_, j) > d(r_, s_) + 1
                    d(r_, j) = d(r_, s_) + 1;
                    q(back, :) = [r_, j];
                    back = back + 1;
                    p(r_, j, :) = [r_ s_];
                elseif d(r_, j) == d(r_, s_) + 1

                    loop_p1 = zeros(d(r_, j), 2);
                    loop_p1(1, :) = [r_ j];
                    loop_p2 = zeros(d(r_, s_), 2);
                    loop_p2(1, :) = [r_ s_];
                end
            end
        end
        for i = 1: m
            if X(i, s_) == 1 && d(i, s_) > d(r_, s_) + 1
                d(i, s_) = d(r_, s_) + 1;
                q(back, :) = [i s_];
                back = back + 1;
                p(i, s_, :) = [r_ s_];
            elseif d(i, s_) == d(r_, s_) + 1

                loop_p1 = zeros(d(i, s_), 2);
                loop_p1(1, :) = [i s_];
                loop_p2 = zeros(d(r_, s_), 2);
                loop_p2(1, :) = [r_ s_];
            end
        end
    end

    for idx = 2: size(loop_p1, 1)
        loop_p1(idx, :) = p(loop_p1(idx-1, 1), loop_p1(idx-1, 2), :);
    end

    for idx = 2: size(loop_p2, 1)
        loop_p2(idx, :) = p(loop_p2(idx-1, 1), loop_p2(idx-1, 2), :);
    end
    loop = [loop_p1; loop_p2; r s];
end