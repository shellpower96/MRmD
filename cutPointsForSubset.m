function cutPoints = cutPointsForSubset(attribute,labels, first, last,level,parent)

currentCutPoint = - realmax('double');
bestCutPoint = -1;
bestIndex = -1;
numCutPoints = 0;

if last - first< 2
    cutPoints = [];
else
    num_classes = numel(unique(labels));
    counts = zeros(2,num_classes);
    num_Inst = numel(attribute(first:last-1));
    [c_label,~,ic] = unique(labels(first:last-1));
    counts(2,c_label) = accumarray(ic,1)';

    priorCounts = counts(2,:);
    priorEntropy =entropy(priorCounts);
    bestEntropy = 0;

    bestCounts = zeros(2,num_classes);
    for i=first:(last-2)
        counts(1,labels(i)) = counts(1,labels(i)) +1;
        counts(2,labels(i)) = counts(2,labels(i)) -1;
        %%mean
        
        if attribute(i) < attribute(i+1)
            currentCutPoint = (attribute(i) + attribute(i+1)) /2.0;
            currentEntropy = get_entropy_MI(counts);
            
%             MI_entropy = get_entropy_MI(counts);
            if currentEntropy > bestEntropy 
                bestEntropy = currentEntropy;
                bestCutPoint = currentCutPoint;
                
                bestIndex = i;
                bestCounts = counts;
            end
            numCutPoints = numCutPoints +1;
        end 
       
    end
    numCutPoints = last - first -1;
    gain = bestEntropy;

    if gain <= 0 
        cutPoints = [];
    else
        level = level+1;
        mutual_gain = gain *(last-first)/numel(attribute);
%         accept = FayyadAndIranisMDL(priorCounts,bestCounts,num_Inst,numCutPoints);
%             inte_gain = inte_gain+gain*(last-first)/numel(attribute);
%         accept = FayyadAndIranisMDL(priorCounts,bestCounts,num_Inst,numCutPoints);
%         if accept
                left = cutPointsForSubset(attribute,labels,first,bestIndex+1,level,bestCutPoint);
                right = cutPointsForSubset(attribute,labels,bestIndex+1,last,level,bestCutPoint);
                if isempty(left)&& isempty(right)
                    cutPoints = [bestCutPoint;level;mutual_gain;parent];
                elseif isempty(right)
                    cutPoints = [left, [bestCutPoint;level;mutual_gain;parent]];
                elseif isempty(left)
                    cutPoints = [[bestCutPoint;level;mutual_gain;parent],right];
                else
                    cutPoints = [left,[bestCutPoint;level;mutual_gain;parent],right];
                end
%         else
%             cutPoints=[];
%         end
            
        
    end
end