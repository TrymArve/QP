function[A_red_k, B_red_k] = ReducedSpace_k(A,B,k)
    A_red_k = A;
    B_red_k = B;
    for i = 1:k-1
        B_red_k = [A_red_k*B B_red_k];
        A_red_k = A*A_red_k;
    end 
end