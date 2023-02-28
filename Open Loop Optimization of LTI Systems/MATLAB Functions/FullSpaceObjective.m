function[H] = FullSpaceObjective(Q,R,N)
    H_Q = kron(diag(ones(N,1)), Q);
    H_R = kron(diag(ones(N,1)), R);
    H = blkdiag(H_Q,H_R);
end