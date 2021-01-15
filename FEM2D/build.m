function [] = build(Nh, N)

    % compute number of Dirichlet's nodes
    Nd = N - Nh;
    % import number of DOFs defined on each element (depending on the subspace of the basis functions)
    global Ndof;
    % assemble the linear terms according to the choice of the subspace
    if Ndof==3
        P1solver(Nh, Nd);
        % adding Neumann's borders nodes contribution to the source vector
        P1Neumann();
    else
        P2solver(Nh, Nd);
        % adding Neumann's borders nodes contribution to the source vector
        P2Neumann();
    end
    
end