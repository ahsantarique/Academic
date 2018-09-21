function assignment()
trainFile = load('trainNN.txt');
Xtrain = trainFile(:,1:end-1);
Ytrain = trainFile(:,end);

classes  = unique(Ytrain);

numFeatures = size(Xtrain,2);
numClasses = size(classes,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

layers = load('layer_configuration.txt');

numLayers = size(layers,2);

weight{1} = rand(layers(1,1), 1+numFeatures);
nn_params = weight{1};

for i=2:numLayers
    weight{i}=rand(layers(1,i), 1+layers(1,i-1));
    nn_params = [nn_params(:) ; weight{i}(:)];
end
weight{numLayers+1} = rand(numClasses, 1+layers(1,numLayers));
nn_params = [nn_params(:) ; weight{numLayers+1}(:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%learning

% find cost and gradient using forward and back propagation respectively

[J, grad] = costfn(nn_params, numFeatures, layers, numClasses, Xtrain, Ytrain); 
Jold = 1e9;
cnt = 0;
step_size = 0.7;

while (J < Jold && cnt < 1e4)
    nn_params = nn_params - step_size * grad;
    Jold = J;
    [J, grad] = costfn(nn_params, numFeatures, layers, numClasses, Xtrain, Ytrain); 
    cnt = cnt + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testFile = load('testNN.txt');
Xtest = testFile(:,1:end-1);
Ytest = testFile(:,end);

p = predict(nn_params, numFeatures, layers, numClasses, Xtest); 

disp([testFile p]);
end




function [J, grad] = costfn(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y)

numLayers = size(hidden_layer_size,2);

weight{1} = reshape(nn_params(1:hidden_layer_size(1,1) * (input_layer_size + 1)), ...
                 hidden_layer_size(1,1), (input_layer_size + 1));
 
start = 1+ hidden_layer_size(1,1)* (input_layer_size + 1);
             
for i=2:numLayers
    fin = start-1 +  hidden_layer_size(1,i)*(hidden_layer_size(1,i-1) + 1);
    weight{i} = reshape(nn_params(start:fin), ...
                 hidden_layer_size(1,i), (hidden_layer_size(1,i-1) + 1));
    
    start = fin + 1;
end
weight{numLayers+1} = reshape(nn_params(start:end), ...
                 num_labels, (hidden_layer_size(1,numLayers) + 1));

% number of training samples
m = size(X, 1);
         
% cost
J = 0;
%gradient
for i=1: (numLayers+1)
    weight_grad{i}= zeros(size(weight{i}));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tempx = [ ones(size(X,1),1) X];
h = zeros(m,num_labels);

%forward propagation

for i = 1:m
    z{1}= weight{1}*tempx(i,:)';
    a{1} = sigmoid(z{1});
    for j=2:(numLayers+1)
        a{j-1} = [1; a{j-1}];
        z{j} = weight{j}*a{j-1};
        a{j} = sigmoid(z{j});
    end
    h(i,:)= a{(numLayers+1)}';
end



%sizing tempy
tempy = zeros(m,num_labels);

for i=1:m
    tempy(i,y(i,1))=1;
end

l1 = log(h);
l2 = log(1-h);

for i=1:m
    J = J+ sum(-tempy(i,:).*l1(i,:)-(1-tempy(i,:)).*l2(i,:));
end
J = J/m;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%back propagation

for i = 1:m
    a{1} = tempx(i,:)';
    for j=1:(numLayers)
        z{j+1} = weight{j}*a{j};
        a{j+1} = sigmoid(z{j+1});
        a{j+1} = [1; a{j+1}];
    end
    z{numLayers+2} = weight{numLayers+1}*a{numLayers+1};
    a{numLayers+2} = sigmoid(z{numLayers+2});

    delta{numLayers+2} = a{numLayers+2}-tempy(i,:)';
    
    for j=(numLayers+1):-1:2
        delta{j} = weight{j}(:,2:end)'*delta{j+1}.* sigmoidGradient(z{j});
    end
    for j=1:numLayers+1
        weight_grad{j} = weight_grad{j}+ delta{j+1}*a{j}';
    end
end

for j = 1:(numLayers+1)
    weight_grad{j} =  weight_grad{j}/m;
end

%disp(weight_grad);

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [];
for j = 1:(numLayers+1)
    grad = [grad; weight_grad{j}(:)];
end

end

function p = predict(nn_params, ...
                       input_layer_size, ...
                       hidden_layer_size, ...
                       num_labels, ...
                       X)

numLayers = size(hidden_layer_size,2);

weight{1} = reshape(nn_params(1:hidden_layer_size(1,1) * (input_layer_size + 1)), ...
                 hidden_layer_size(1,1), (input_layer_size + 1));
 
start = 1+ hidden_layer_size(1,1)* (input_layer_size + 1);
             
for i=2:numLayers
    fin = start-1 +  hidden_layer_size(1,i)*(hidden_layer_size(1,i-1) + 1);
    weight{i} = reshape(nn_params(start:fin), ...
                 hidden_layer_size(1,i), (hidden_layer_size(1,i-1) + 1));
    
    start = fin + 1;
end
weight{numLayers+1} = reshape(nn_params(start:end), ...
                 num_labels, (hidden_layer_size(1,numLayers) + 1));
             
% number of training samples
m = size(X, 1); 
tempx = [ ones(size(X,1),1) X];
h = zeros(m,num_labels);

%forward propagation

for i = 1:m
    z{1}= weight{1}*tempx(i,:)';
    a{1} = sigmoid(z{1});
    for j=2:(numLayers+1)
        a{j-1} = [1; a{j-1}];
        z{j} = weight{j}*a{j-1};
        a{j} = sigmoid(z{j});
    end
    h(i,:)= a{(numLayers+1)}';
end

[dummy, p] = max(h, [], 2);

% =========================================================================


end




function g = sigmoid(z)
g = 1.0 ./ (1.0 + exp(-z));
end

function g = sigmoidGradient(z)

g = zeros(size(z));
g = sigmoid(z).*(ones(size(z))-sigmoid(z));
end
