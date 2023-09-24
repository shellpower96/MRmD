%% input:tree
%% output:cut point set
function IL_cutPoint = MRmD(tr_feat,tr_label,te_feat,te_label,overall_tree,N_0)
rng("default")

NUM_ITER = 0;
    IL_cutPoint=[];
if ~isempty(overall_tree)
    NUM_ITER = numel(overall_tree(2,:));
    
    if NUM_ITER>1
        [~,I] = sort(overall_tree(5,:));
        overall_tree = overall_tree(:,I);
    end
    
    
    if NUM_ITER >500
        seq = NUM_ITER:-1:0;
    else
        seq=NUM_ITER:-1:0;
    end
    NUM = 1;
    iter_set = overall_tree;
    max_MI_min_diff = 0;
    
    IL_cutPoint= [];
    for j = seq
        
        [~,I] = sort(iter_set(1,:));
        
        new_tr_feat = tr_feat;
        new_te_feat = te_feat;
        cutPoint = iter_set(1,I);
        for i = 1:numel(tr_label)
            [~,idx] =min(abs(tr_feat(i)-cutPoint));
            if numel(cutPoint) ==0
                new_tr_feat(i) = 1;
            else
                if tr_feat(i) <= cutPoint(idx)
                    new_tr_feat(i) = idx;
                else
                    new_tr_feat(i) = idx+1;
                end
            end
        end
        
        new_te_feat = zeros(size(te_feat));
        for i = 1:numel(te_label)
            [~,idx] =min(abs(te_feat(i)-cutPoint));
            if numel(cutPoint) ==0
                new_te_feat(i) = 1;
            else
                if te_feat(i) <= cutPoint(idx)
                    new_te_feat(i) = idx;
                else
                    new_te_feat(i) = idx+1;
                end
            end
        end
        
        %% norm term
        attr =new_tr_feat;
        [x1,~,ic] = unique(attr);
        tr_mWeight = accumarray(ic,1);
        
        attr = new_te_feat;
        [x2,~,ic] = unique(attr);
        te_mWeight = accumarray(ic,1);
        
        attr_all = [new_tr_feat;new_te_feat];
        [x,~,ic] = unique(attr_all);
        
        tr_prob = zeros(1,numel(x))+eps;
        tr_prob(x1) = tr_mWeight/sum(tr_mWeight);
        te_prob = zeros(1,numel(x))+eps;
        te_prob(x2) =te_mWeight/sum(te_mWeight);
        KL_ent = KL_entropy(x,tr_prob',te_prob','js');
        
        %% cross entropy
        MI = sum(iter_set(3,:));
        sigma = exp(-size(iter_set,2)/N_0);
        temp =(sigma*MI)- KL_ent;
        if j ==NUM_ITER
            max_MI_min_diff = temp;
            IL_cutPoint = iter_set(:,I);
            temp_set = iter_set;
        else
            if max_MI_min_diff <= temp
                IL_cutPoint = iter_set(:,I);
                max_MI_min_diff = temp;
                temp_set = iter_set;
            end
        end
        iter_set = iter_set(:,(1+NUM):j);
        
    end
end
end