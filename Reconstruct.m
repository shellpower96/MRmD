function Reconstruct_set = Reconstruct(set,lambda)

if ~isempty(set)

    max_level = max(set(2,:));
    if max_level ~=1
        index = find(set(2,:)==max_level);
        set(5,index) = set(3,index);
        for i = max_level-1:-1:1
            index = find(set(2,:)==i);
            for j = 1:numel(index)
                next_level_index = find(set(2,:)==i+1 & set(4,:)== set(1,index(j)));
%                 [~,id] = mink(abs(set(1,index(j))-set(1,next_level_index)),2);
                set(5,index(j)) = set(3,index(j))+lambda*(sum(set(5,next_level_index)));
            end
        end
    end
end
Reconstruct_set = set;