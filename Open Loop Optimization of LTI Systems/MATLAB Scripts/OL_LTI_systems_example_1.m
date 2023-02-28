
%% DEFINITION
clc;clear;close all
% Model:
% ( x_{k+1} = A*x_{k} + B*u_{k} )
A = [ -2.1  0.7  0.3 ;
        1    0    0  ;
        0    1    0  ];
B = [ 0.8 ;
       0  ;
      3.2 ];

[nx,nu] = size(B);

% Initial state
x0 = [ 1.1 ;
        0  ;
        0  ];

% Desired end state
xf = [ 2.3  ;
        1   ;
      -1  ];

% Bounds on input:
ulb = -7*ones(nu,1); 
uub = 8*ones(nu,1);

% Horizon
N = 10;

%% Reduced Space Method 1 - Fixed end state

% Get A_red_N and B_red_N:
[A_red_N,B_red_N] = ReducedSpace_k(A,B,N);

% Apply desired end state via equality constraints:
Aeq = B_red_N;
beq = xf-A_red_N*x0;

% Input limits:
Ulb = kron(ones(N,1),ulb);
Uub = kron(ones(N,1),uub);

% Solve:
U = quadprog(2*eye(N*nu),[],[],[],Aeq,beq,Ulb,Uub)

%% Reduced Space Method 2 - State Constraints

% Get A_RED_N and B_RED_N:
[A_RED_N, B_RED_N] = ReducedSpace_full(A,B,N);

% Define state limits:
xlb =  -inf(3,1);
xub =  ones(3,1)*14.5;

% Apply limits to trajectory:
Xlb = kron(ones(N,1),xlb);
Xub = kron(ones(N,1),xub);

% Apply desired end state
Xlb(end+1-nx:end) = xf;
Xub(end+1-nx:end) = xf;

% Input limits:
Ulb = kron(ones(N,1),ulb);
Uub = kron(ones(N,1),uub);

% Implement state limits:
Ain = [ B_RED_N;
       -B_RED_N];
bin = [ Xub - A_RED_N*x0;
       -Xlb + A_RED_N*x0];

% Solve:
U = quadprog(2*(eye(N*nu) + B_RED_N'*B_RED_N),2*x0'*A_RED_N'*B_RED_N,Ain,bin,[],[],Ulb,Uub)

% % View resulting state trajectory:
X = A_RED_N*x0 + B_RED_N*U;
X = reshape(X,nx,[])


%% Full Space

% Obtain full space equality constaints:
[Aeq,beq] = FullSpace(A,B,N);

% Add initial value separately:
beq(1:nx) = A*x0;

% Define state limits:
xlb =  -inf(3,1);
xub =  ones(3,1)*14.5;

% Apply limits to trajectory:
Xlb = kron(ones(N,1),xlb);
Xub = kron(ones(N,1),xub);

% Apply desired end state
Xlb(end+1-nx:end) = xf;
Xub(end+1-nx:end) = xf;

% Input limits:
Ulb = kron(ones(N,1),ulb);
Uub = kron(ones(N,1),uub);

% Limits:
lb = [Xlb;Ulb];  ub = [Xub;Uub];

% state costs:
q(1) = 0.87;
q(2) = 1.21;
q(3) = 1.15;
Q = diag(q);

% input cost:
r(1) = 6.45;
R = diag(r);

% Build objective hessian:
H = FullSpaceObjective(Q,R,N);

% Solve:
z = quadprog(2*H,[],[],[],Aeq,beq,lb,ub);

% Extract solution:
U = z((N*nx) + (1:N*nu))
X = reshape(z(1:(N*nx)),nx,[])


%% Functions

% Also see separate folder for these functions

% function[A_red_k, B_red_k] = ReducedSpace_k(A,B,k)
%     A_red_k = A;
%     B_red_k = B;
%     for i = 1:k-1
%         B_red_k = [A_red_k*B B_red_k];
%         A_red_k = A*A_red_k;
%     end 
% end
% 
% function[A_RED_N,B_RED_N] = ReducedSpace_full(A,B,N)
%     A_RED_N = [];
%     [nx,nu] = size(B);
%     B_RED_N = zeros(nx*N,nu*N);
%     for i = 1:N
%         [A_red_i,B_red_i] = ReducedSpace_k(A,B,i);
%         A_RED_N = [A_RED_N; A_red_i];
%         B_RED_N((i-1)*nx + (1:nx), 1:(nu*i)) = B_red_i;
%     end
% end
% 
% 
% function[A_eq,b_eq] = FullSpace(A,B,N)
%     nx = size(A,1);
%     A_diag = kron( -diag(ones(N-1,1),-1), A);
%     A_diag = eye(N*nx) + A_diag;
%     B_diag = kron( -diag(ones(N,1)), B);
%     A_eq = [A_diag B_diag];
%     b_eq = zeros(N*nx,1);
% end
% 
% function[H] = FullSpaceObjective(Q,R,N)
%     H_Q = kron(diag(ones(N,1)), Q);
%     H_R = kron(diag(ones(N,1)), R);
%     H = blkdiag(H_Q,H_R);
% end



















