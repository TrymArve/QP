function[A_eq,b_eq] = FullSpace(A,B,N)
    nx = size(A,1);
    A_diag = kron( -diag(ones(N-1,1),-1), A);
    A_diag = eye(N*nx) + A_diag;
    B_diag = kron( -diag(ones(N,1)), B);
    A_eq = [A_diag B_diag];
    b_eq = zeros(N*nx,1);
end