function res = NB_MRmD(DATA)

rng('default')
feat = DATA(:,1:end-1);
label = DATA(:,end);
class_lab = unique(label);
NUM_CLASSES = numel(class_lab);


    all_feat = feat;
    all_label = label;
    indices = crossvalind('Kfold',all_label,10,'Classes',class_lab);
    rates =zeros(10,1);
        for k =1:10
            NUM_CLASSES = numel(class_lab);
            test_id = find(indices ==k);
            train_id = find(indices ~=k);

            te_feat = all_feat(test_id,:);
            te_label = all_label(test_id,:);

            tr_feat = all_feat(train_id,:);
            tr_label = all_label(train_id,:);
            
            prior_prob =zeros(NUM_CLASSES,1);
            for c = 1:NUM_CLASSES
               prior_prob(c) = (numel(find(tr_label == c))+1/numel(class_lab))/(numel(tr_label)+1);
            end
            class_ratio = (max(prior_prob)-min(prior_prob))/max(prior_prob); 
            NUM_TE_SAMP = numel(te_label);

            [rows,cols] = size(tr_feat);
            m_cutPoints = zeros(cols,rows);
            count = zeros(cols,1);
            %% derive the discretization scheme
            for j = 1:cols
                    all_attribute = tr_feat(:,j);
                    [A,I] = sort(all_attribute);
                    labels =tr_label(I);
                   
                    set = cutPointsForSubset(A,labels,1,rows+1,0,0);
                    
                    set = Reconstruct(set,1);
                    if size(set,2)+1 >NUM_CLASSES
                        select_set = MRmD(tr_feat(:,j),tr_label,te_feat(:,j),te_label,set,50);
                    else
                        select_set = MRmD(tr_feat(:,j),tr_label,te_feat(:,j),te_label,set,50);
                    end
                    if isempty(select_set)
                        temp =[];
                    else
                        temp = select_set(1,:);
                    end
                    count(j) = numel(temp);
                    m_cutPoints(j,1:count(j))= temp;
                end

           %% transformation on whole set
            [rows,cols] = size(tr_feat);
            new_tr_feat = zeros(rows,cols);
            for i = 1:rows
               for j = 1:cols
                    cutPoint = m_cutPoints(j,1:count(j));
                    [~,idx] =min(abs(tr_feat(i,j)-cutPoint));
                    if numel(cutPoint) ==0
                        new_tr_feat(i,j) = 1;
                    else
                        if tr_feat(i,j) <= cutPoint(idx)
                            new_tr_feat(i,j) = idx;
                        else
                            new_tr_feat(i,j) = idx+1;
                        end
                    end
               end
            end
            [rows,cols] =size(te_feat);
            new_te_feat = zeros(size(te_feat));
            for i = 1:rows
               for j = 1:cols
                    cutPoint = m_cutPoints(j,1:count(j));
                    [~,idx] =min(abs(te_feat(i,j)-cutPoint));
                    if numel(cutPoint) ==0
                        new_te_feat(i,j) = 1;
                    else
                        if te_feat(i,j) <= cutPoint(idx)
                            new_te_feat(i,j) = idx;
                        else
                            new_te_feat(i,j) = idx+1;
                        end
                    end
               end
            end
                tr_feat = new_tr_feat;
                te_feat = new_te_feat;



            NUM_CLASSES = numel(class_lab);
            predt_label = zeros(NUM_TE_SAMP,1);
            
            for i =1:NUM_TE_SAMP
                prob = zeros(cols,NUM_CLASSES);
                for j = 1:cols
                    attribute = tr_feat(:,j);
                    for c =1:NUM_CLASSES
                        [m_count,ia,ic] = unique(attribute(tr_label==c));
                        mWeight = accumarray(ic,1);
                        id = find(m_count == te_feat(i,j));
                        if isempty(mWeight)
                            prob(j,c) = 1/numel(unique(attribute))/(sum(mWeight)+1);
                        else
                            if isempty(id)
                                prob(j,c) = 1/numel(unique(attribute))/(sum(mWeight)+1);
                            else
                                prob(j,c) = (mWeight(id)+1/numel(unique(attribute)))/ (sum(mWeight)+1);
                            end
                        end
                    end
                end
                post_prob = prior_prob'.*exp(sum(log(prob)));

               [~,id] = max(post_prob);
               predt_label(i) = id;
            end
            rate = numel(find(predt_label ==te_label))/NUM_TE_SAMP;
            res(k) = rate;
        end
end