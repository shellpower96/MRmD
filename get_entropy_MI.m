function entropy_MI = get_entropy_MI(matrix)
    I_c_num = sum(matrix,1)./sum(matrix,'all');
    I_x_num = sum(matrix,2)./sum(matrix,'all');
    
    temp = matrix./sum(matrix,'all') .* log2(matrix./sum(matrix,'all'));
    temp(isnan(temp))=0;
    temp = -sum(temp,'all');
    
    
    I_c = I_c_num.*log2(I_c_num);
    I_x = I_x_num.*log2(I_x_num);
    I_c(isnan(I_c))=0;
    I_x(isnan(I_x))=0;
    I_c = -sum(I_c);
    I_x = -sum(I_x);
    %%% lambda >=1
    %% I(x|c) + lambda*MI 
    lambda = 1;
    entropy_MI =  lambda*(I_x+I_c - temp);