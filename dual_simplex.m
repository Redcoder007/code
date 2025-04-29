clc, clearvars

n=input('Enter the number of variables: ');
m=input('Enter the number of constraints: ');
lessThan=input('Enter the number of less than equal constraints: ');
equalTo=input('Enter the number of equal to constraints: ');
greaterThan=input('Enter the number of greater than constraints: ');

A=input('Enter the coefficient matrix:(less than, equal to and greater than) \n');
b=input('Enter the constant column vector(RHS): \n');
C=input('Enter the coefficient of objective function:\n');

extraMat=[];    

for i=lessThan+1:lessThan+greaterThan
    A(i,:)=-1*A(i,:);
    b(i)=-1*b(i);
end

for i=1:lessThan+greaterThan
    col=zeros(m,1);
    col(i)=1;
    extraMat=[extraMat,col];
end

A=[A,extraMat];
table=[A,b];

C=[C,zeros(1,lessThan+greaterThan)];

coeffIdx=n+1:n+lessThan+greaterThan;

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

xb=zeros(1,n+lessThan+greaterThan);
for i=1:m
    xb(coeffIdx(i))=table(i,end);
end

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

xb=zeros(1,n+lessThan+greaterThan);
for i=1:m
    xb(coeffIdx(i))=table(i,end);
end

fprintf('Optimum solution:\n');
disp(xb);
fprintf('Maximum objective value: %d\n',xb*C');

