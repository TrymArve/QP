function[A_RED_N,B_RED_N] = ReducedSpace_full(A,B,N)
    A_RED_N = [];
    [nx,nu] = size(B);
    B_RED_N = zeros(nx*N,nu*N);
    for i = 1:N
        [A_red_i,B_red_i] = ReducedSpace_k(A,B,i);
        A_RED_N = [A_RED_N; A_red_i];
        B_RED_N((i-1)*nx + (1:nx), 1:(nu*i)) = B_red_i;
    end
end