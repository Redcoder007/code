clc, clearvars
format long;
n=input('Enter the number of variables: ');
m=input('Enter the number of constraints: ');
lessThan=input('Enter the number of less than equal constraints: ');
equalTo=input('Enter the number of equal to constraints: ');
greaterThan=input('Enter the number of greater than constraints: ');

A=input('Enter the coefficient matrix: \n');
b=input('Enter the constant column vector(RHS): \n');
C=input('Enter the coefficient of objective function:\n');

extraMat=[];

for i=1:lessThan
    col=zeros(m,1);
    col(i)=1;
    extraMat=[extraMat,col];
end

for i=1:greaterThan
    col=zeros(m,1);
    col(lessThan+equalTo+i)=-1;
    extraMat=[extraMat,col];
end

for i=1:equalTo
    col=zeros(m,1);
    col(lessThan+i)=1;
    extraMat=[extraMat,col];
end

for i=1:greaterThan
    col=zeros(m,1);
    col(lessThan+equalTo+i)=1;
    extraMat=[extraMat,col];
end

A=[A,extraMat];
table=[A,b];

M=1e7;
C=[C,zeros(1,lessThan+greaterThan)];
for i=1:greaterThan+equalTo
    C=[C,-M];
end

coeffIdx=n+1:n+lessThan;
for i=1:size(C,2)
    if C(i)==-M
        coeffIdx=[coeffIdx,i];
    end
end

c1=[];
for i=1:m
    c1=[c1,C(coeffIdx(i))];
end

Zj_Cj= c1*A-C;

fprintf('\nInitial Simplex table\n');
disp(table);
fprintf('Zj-Cj:\n');
disp(Zj_Cj);

itr=0;
while any(Zj_Cj<0)
    itr=itr+1;
    [mincol,colIdx]=min(Zj_Cj);
    pivotCol=table(:,colIdx);
    if all(pivotCol<0)
        fprintf('Unbounded Solution\n');
        return;
    end
    ratios=table(:,end) ./ (pivotCol + (pivotCol==0)*eps);
    minRat=1e6;
    rowIdx=1;
    for i=1:m
        if ratios(i)<minRat && ratios(i)>0
            minRat=ratios(i);
            rowIdx=i;
        end
    end

    table(rowIdx,:)=table(rowIdx,:) / table(rowIdx,colIdx);
    for i=1:m
        if i~=rowIdx
            table(i,:)=table(i,:)-table(i,colIdx)*table(rowIdx,:);
        end
    end
    coeffIdx(rowIdx)=colIdx;
    c1=[];
    for i=1:m
        c1=[c1,C(coeffIdx(i))];
    end
    A=table(:,1:end-1);

    Zj_Cj=c1*A-C;
    fprintf('Simplex table after iteration %d\n',itr);
    disp(table);
    fprintf('Zj-Cj:\n')
    disp(Zj_Cj);    
end

xb=zeros(1,n+lessThan+greaterThan);
for i=1:m
    xb(coeffIdx(i))=table(i,end);
end

fprintf('Optimum solution using simplex:\n');
disp(xb);

% ILP starts here

tol = 1e-10;  % Tolerance to treat near-zero as zero
    frac = [];
    
    for i = 1:m
        val = table(i,end);
        fl = floor(val);
        
        % fprintf('%f %f\n', val, fl);
        
        diff = val - fl;
        if abs(diff) < tol || abs(diff) > 0.9999999
            diff = 0;  % Snap it to zero if it's basically zero
        end
        
        frac = [frac, diff];
    end
if any(frac>0)
    fprintf('Fractional solution obtained. Proceeding further for integer solution\n\n');
else
    C=C(:,1:end-equalTo-greaterThan);
    fprintf('Maximum objective value: %d\n',xb*C');
end

epoch=0;
while any(frac>0)
    epoch=epoch+1;
    fprintf('epoch: %d\n',epoch);
    [maxf,idxf]=max(frac);
    
    newrow=zeros(1,size(table,2)-1);
    for j=1:size(table,2)-1
        newrow(j)=floor(table(idxf,j))-table(idxf,j);
    end
    newrow=[newrow,1,-maxf];
    endcol=table(:,end);
    table=table(:,1:end-1);
    table=[table,zeros(m,1)];
    table=[table,endcol];
    table=[table;newrow];
    
    disp(table);
    C=[C,0];
    coeffIdx=[coeffIdx,m+1];
    c1=[c1,0];
    m=m+1;
    
    itr=0;
    while any(table(:,end)<0)
        itr=itr+1;
        [minRow,rowIdx]=min(table(:,end));
        pivotRow=[];
        for i=1:n+lessThan+greaterThan
            if table(rowIdx,i)<0
                pivotRow=[pivotRow,Zj_Cj(i)/table(rowIdx,i)];
            else
                pivotRow=[pivotRow, -1e7];
            end
        end
        [maxCol,colIdx]=max(pivotRow);
    
        table(rowIdx,:)=table(rowIdx,:) / table(rowIdx,colIdx);
        for i=1:m
            if i~=rowIdx
                table(i,:)=table(i,:)-table(i,colIdx)*table(rowIdx,:);
            end
        end
        coeffIdx(rowIdx)=colIdx;
        c1=[];
        for i=1:m
            c1=[c1,C(coeffIdx(i))];
        end
        A=table(:,1:end-1);
    
        Zj_Cj=c1*A-C;
        fprintf('Simplex table after iteration %d\n',itr);
        disp(table);
        fprintf('Zj-Cj:\n')
        disp(Zj_Cj);    
    end
    tol = 1e-10;  % Tolerance to treat near-zero as zero
    frac = [];
    
    for i = 1:m
        val = table(i,end);
        fl = floor(val);
        
        % fprintf('%f %f\n', val, fl);
        
        diff = val - fl;
        if abs(diff) < tol || abs(diff) > 0.9999999
            diff = 0;  % Snap it to zero if it's basically zero
        end
        
        frac = [frac, diff];
    end

    % disp(frac);
    n=n+1;
    xb=zeros(1,n+lessThan+equalTo+greaterThan);
    for i=1:m
        xb(coeffIdx(i))=table(i,end);
    end
    % disp(xb);
end



fprintf('Optimum solution:\n');
disp(xb);
fprintf('Maximum objective value: %d\n',xb*C');