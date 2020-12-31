function [A, Ad, f, gd] = P2solver(Nh, Nd)

    % import all the necessary functions of the variational problem
    global boundary_functions;
    % import geometric entities of the domain
    global triangles;
    global nodes;
    % initialise linear system
    A = zeros(Nh, Nh);
    f = zeros(Nh, 1);
    Ad = zeros(Nh, Nd);
    gd = zeros(Nd,1);
    % assemble the linear system
    for e=1:length(triangles(:,1))
        v1 = abs(nodes(triangles(e,1),1));
        x1 = nodes(v1,3);
        y1 = nodes(v1,4);
        % extract e-th triangle's area
        area = triangles(e,7);
        % compute the incremental quantities for the e-th triangle
        [dx,dy] = delta(nodes,triangles(e,1:3));
        % assemble the jacobian of the mapping
        B = [dx(3) -dx(2); -dy(3) dy(2)];
        diffB = inv(B)*inv(transpose(B));
        for j=1:6
            % check if there exist a trial basis function (i.e. the j-th node of the e-th triangle is a DOF for the linear system)
            if nodes(triangles(e,j),1)>0
                for k=1:6
                    % perform the mapping to the reference triangle                                                       
                    [vj, vk] = map([j,k,e], B);
                    % check if there exist a test basis function (i.e. the k-th node of the e-th triangle is a DOF for the linear system)
                    if nodes(triangles(e,k),1)>0
                        % compute the entry of A for the j_g-th trial basis function and the k_g-th test basis functions
                        A(vj(1),vk(1)) = A(vj(1),vk(1)) + ...
                            2*area*quad_diffusive(j,k,diffB) + ...
                            0 + ...
                            0;
                    else
                        % convert the Dirichlet pivot into natural integer
                        vk(1) = -vk(1);
                        % extract the marker of the BC associated to the k_g-th node
                        marker = nodes(triangles(e,k),2);
                        if marker == 0
                            error('One DOF has been wrongfuly stored as a boundary node');
                        end
                        % compute the entry of Ad for the j_g-th trial basis function and the k_g-th test basis functions
                        Ad(vj(1),vk(1)) = Ad(vj(1),vk(1)) + ...
                            2*area*quad_diffusive(j,k,diffB) + ...
                            0 + ...
                            0;
                        % compute the boundary function value associated to the k_g node
                        gd(vk(1)) = boundary_functions{1, marker}(nodes(triangles(e,k),3), nodes(triangles(e,k),4));
                    end
                end
                % compute the (j_g) entry of the source vector
                ref_x = [x1,y1];
                f(vj(1)) = f(vj(1)) + 2*area*quad_source(j,dx,dy,ref_x);
            end
        end
    end

end