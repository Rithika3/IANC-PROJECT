function BOUNDRY(d)
    if nargin < 1
        % getting input of distance from user
        d = input('Enter the distance between nodes: ');
    end
    fprintf('Given distance between nodes: %.2f\n', d);

    % Definition of initial coordinates for 12 nodes
    initial_coordinates = [0, 0, 0;
                            0, 0, d;
                            0, d, d;
                            0, d, d;
                            d, 0, 0;
                            d, 0, d;
                            d, d, d;
                            d, d, 0;
                            2*d, 0, 0;
                            2*d, 0, d;
                            2*d, d, d;
                            2*d, d, 0];

    fprintf('Initial coordinates:\n');

    % Displaying of initial coordinates
    num_nodes = size(initial_coordinates, 1);
    for i = 1:num_nodes
        fprintf('Node %d: [%.2f, %.2f, %.2f]\n', i, initial_coordinates(i,1), initial_coordinates(i,2), initial_coordinates(i,3));
    end

    % type of joints and its boundary condition
    fprintf('Enter the nodes which are constrained (e.g., [1 3 5]): ');
    fixed_nodes = input('');
    fixed_dof = zeros(3, length(fixed_nodes));
    try
        % Initializing lists for different types of joints
        fixed_nodes = [];
        pin_nodes = [];
        roller_nodes = [];
        % nodes under fixed joint
        while true
            fprintf('Enter the node under fixed joint (or -1 to finish): ');
            node = input('');
            if node == -1
                break;
            else
                fixed_nodes = [fixed_nodes, node];
            end
        end
        % Displaying the list of nodes under fixed joint
        fprintf('Nodes under Fixed Joint:\n');
        disp(fixed_nodes);
        % Defining boundary conditions for nodes under fixed joint
        fixed_boundary_conditions = [];
        if ~isempty(fixed_nodes)
            fprintf('Boundary Conditions for Fixed Joint:\n');
            disp(fixed_boundary_conditions);
            fprintf('These nodes are fixed in all directions (x, y, and z) due to the two red lines connecting it to the ground.\n', node);
        end
        % Ask for nodes under pin joint
        while true
            fprintf('Enter the node under pin joint (or -1 to finish): ');
            node = input('');
            if node == -1
                break;
            else
                pin_nodes = [pin_nodes, node];
            end
        end
        % Displaying the list of nodes under pin joint
        fprintf('Nodes under Pin Joint:\n');
        disp(pin_nodes);
        % Defining boundary conditions for nodes under pin joint
        pin_boundary_conditions = [];
        if ~isempty(pin_nodes)
            fprintf('Boundary Conditions for Pin Joint:\n');
            disp(pin_boundary_conditions);
            fprintf('These nodes are fixed in the horizontal direction (x) and allowed to move freely in the vertical direction (y) and rotational direction (z).\n');
        end
        % Ask for nodes under roller joint
        while true
            fprintf('Enter the node under roller joint (or -1 to finish): ');
            node = input('');
            if node == -1
                break;
            else
                roller_nodes = [roller_nodes, node];
            end
        end
        % Displaying the list of nodes under roller joint
        fprintf('Nodes under Roller Joint:\n');
        disp(roller_nodes);
        % Defining boundary conditions for nodes under roller joint
        roller_boundary_conditions = [];
        if ~isempty(roller_nodes)
            fprintf('Boundary Conditions for Roller Joint:\n');
            disp(roller_boundary_conditions);
            fprintf('These nodes are only the translational degrees of freedom in the x and y directions are free, while the rotational degree of freedom and translational degree of freedom in the z-direction are constrained.\n');
        end
    catch
    end

    % Reading the load values
    fprintf('Enter the nodes where loads are applied (e.g., [2 4]): ');
    loaded_nodes = input('');
    load = zeros(3, num_nodes);
    for i = 1:length(loaded_nodes)
        node = loaded_nodes(i);
        fprintf('Enter the load on node %d: ', node);
        load(3, node) = input('');
    end

    % Printing loads
    fprintf('Loads:\n');
    disp(load);

    % taking the input of modulus of elasticity
    E = input('Enter the modulus of elasticity (in GPa): ');

    % Determining the material type based on modulus of elasticity using if
    % else
    if 68.9 <= E && E < 70.3
        material = 'Aluminum Alloy 6061-T6';
    elseif 70.3 <= E && E < 71.7 
        material = 'Aluminum Alloy 7075-T6';
    elseif 200 <= E && E < 204
        material = 'Carbon Steel A36 (ASTM A36)';
    elseif 205 <= E && E < 210
        material = 'Carbon Steel A992 (ASTM A992)';
    elseif 196 <= E && E < 200
        material = 'Stainless Steel 17-4 PH (UNS S17400)';
    else
        error('Invalid modulus of elasticity.');
    end

    % Display the determined material
    fprintf('Based on the provided modulus of elasticity, the material is: %s\n', material);

    % switch case for choose between rod and square
    fprintf('Choose the type of structure:\n');
    fprintf('1. Rod\n');
    fprintf('2. Square\n');
    structure_choice = input('Enter the number corresponding to the structure: ');

    % Calculation of cross-sectional area
    switch structure_choice
        case 1
            % For rod: cross-sectional area = pi * radius^2
            radius = input('Enter the radius (in meters): ');
            A = pi * radius^2;
        case 2
            % For square: cross-sectional area = side^2
            side = input('Enter the side length (in meters): ');
            A = side^2;
        otherwise
            error('Invalid structure choice.');
    end

    % Displaying the calculated cross-sectional area
    fprintf('The cross-sectional area is: %.2f square meters\n', A);

    % Displaying the material properties
    fprintf('Material properties:\n');
    fprintf('Modulus of elasticity: %.2f GPa\n', E);
    fprintf('Material: %s\n', material);
    fprintf('Cross-sectional area: %.2f square meters\n', A);
    
    % Calculating deformation for each node
    deformation = zeros(num_nodes, 3);
    for i = 1:num_nodes
        if load(3, i) ~= 0 % Check if there is a load on the node
            deformation(i, 3) = load(3, i) * d / (A * E); % Z-axis deformation
            deformation(i, 1) = deformation(i, 3) * (initial_coordinates(i,1) / d); % X-axis deformation
            deformation(i, 2) = deformation(i, 3) * (initial_coordinates(i,2) / d); % Y-axis deformation
        else
            fprintf('Node %d has no load applied.\n', i);
        end
    end

    % Printing deformation only on load applied node
    for i = 10:11
        fprintf('Deformation at Node %d (X-axis): %f m\n', i, deformation(i, 1) / 1e6);
        fprintf('Deformation at Node %d (Y-axis): %f m\n', i, deformation(i, 2) / 1e6);
        fprintf('Deformation at Node %d (Z-axis): %f m\n', i, deformation(i, 3) / 1e6);
    end

end

